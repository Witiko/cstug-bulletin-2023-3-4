local ForgetfulModel = {}

function ForgetfulModel.new(context_size)
  local model = {}
  model.context_size = context_size
  model.forward_graph = {}
  model.reverse_graph = {}
  local mt = {
    __index = ForgetfulModel }
  setmetatable(model, mt)
  return model
end

local function trim_context(context,
                            max_context_size)
  local context_size = utf8.len(context)
  if context_size > max_context_size then
    local character_offset = context_size - max_context_size + 1
    local byte_offset = utf8.offset(context, character_offset)
    context = context:sub(byte_offset, #context)
  end
  return context
end

local function add_name(graph, name, max_context_size)
  name = name
       .. "\n"
  local context = ""
  for _, code in utf8.codes(name) do
    if graph[context] == nil then
      graph[context] = {}
    end
    local vertex = graph[context]
    local character = utf8.char(code)
    if vertex[character] == nil then
      vertex[character] = 0
      table.insert(vertex, character)
    end
    vertex[character] =
      vertex[character] + 1
    context = trim_context(
      context .. character,
      max_context_size)
  end
end

local function reverse(name)
  local index = utf8.len(name)
  local result = {}
  for _, code in utf8.codes(name) do
    local character = utf8.char(code)
    result[index] = character
    index = index - 1
  end
  local reversed_name = table.concat(result)
  return reversed_name
end

function ForgetfulModel.add_name(model, name)
  add_name(model.forward_graph,
           name,
           model.context_size)
  add_name(model.reverse_graph,
           reverse(name),
           model.context_size)
end

function ForgetfulModel.input_names(model, filename)
  local file = io.open(filename, "r")
  assert(file)
  for name in file:lines() do
    if #name:match("^%s*(.-)%s*$") == 0
    then
      goto continue
    end
    model:add_name(name)
    ::continue::
  end
end
local BackoffModel = {}

function BackoffModel.new(min_context_size, max_context_size)
  local model = {}
  model.min_context_size =
    min_context_size
  model.max_context_size =
    max_context_size
  model.submodels = {}
  for context_size = min_context_size, max_context_size do
    model.submodels[context_size]
      = ForgetfulModel.new(context_size)
  end
  local mt = {
    __index = BackoffModel }
  setmetatable(model, mt)
  return model
end

function BackoffModel.for_each_submodel(model, func,
                                        min_context_size,
                                        max_context_size)
  assert(min_context_size >= model.min_context_size)
  assert(max_context_size <= model.max_context_size)
  local i, j = min_context_size, max_context_size
  for context_size = j, i, -1 do
    local submodel
      = model.submodels[
        context_size]
    local result = func(submodel)
    if result == false then
      break
    end
  end
end

function BackoffModel.add_name(model, name)
  model:for_each_submodel(
    function(submodel)
      submodel:add_name(name)
    end,
    model.min_context_size,
    model.max_context_size)
end

function BackoffModel.input_names(model, filename)
  model:for_each_submodel(
    function(submodel)
      submodel:input_names(
        filename)
    end,
    model.min_context_size,
    model.max_context_size)
end
local Random = { A = 771645345, M = 1073741789 }

function Random.new(seed)
  assert(seed >= 0 and
         seed <= 2147483647)
  seed = seed
       % (Random.M - 1) + 1
  local random = { x = seed }
  local mt = { __index = Random }
  setmetatable(random, mt)
  return random
end

local function multiply_modulo(a, x, m)
  local result = 0
  a = a % m
  while x > 0 do
    if x % 2 == 1 then
      result = (result + a) % m
    end
    a = (a * 2) % m
    x = x // 2
  end
  return result
end

function Random.get_next_number(random, from, to)
  random.x = multiply_modulo(Random.A, random.x, Random.M)
  local result = from
               + (random.x
                 % (to - from + 1))
  return result
end

local function take_random_step(graph, context, random)
  if graph[context] == nil then
    return nil
  end
  local vertex = graph[context]
  assert(#graph[context] > 0)
  local total_weight = 0
  local weight
  for _, character in ipairs(vertex) do
    weight = vertex[character]
    total_weight = total_weight + weight
  end
  local random_number =
    random:get_next_number(0, total_weight)
  local weight_accumulator = 0
  for _, character in ipairs(vertex) do
    weight = vertex[character]
    weight_accumulator = weight_accumulator + weight
    if weight_accumulator >= random_number then
      return character
    end
  end
  assert(false)
end

function ForgetfulModel.take_random_step(model, graph_type,
                                         context, random)
  local graph = model[
    graph_type .. "_graph"]
  assert(graph ~= nil)
  context = trim_context(
    context,
    model.context_size)
  return take_random_step(graph, context, random)
end

function BackoffModel.take_random_walk(model, graph_type,
                                       affix, random,
                                       min_context_size,
                                       max_context_size)
  local name = affix
  if graph_type == "reverse"
    then name = reverse(name)
  end
  while true do
    local character
    model:for_each_submodel(
      function(submodel)
        character = submodel:take_random_step(
          graph_type, name, random)
        if character ~= nil then
          return false
        end
      end,
      min_context_size,
      max_context_size)
    if character == nil then
      return nil
    end
    if character == "\n" then
      break
    end
    name = name .. character
  end
  if graph_type == "reverse"
    then name = reverse(name)
  end
  return name
end
local randomnames = {}

local models = {}
local randoms = {}

local function hash(name)
  local result = 0
  local modulus = Random.M - 1
  for _, code in utf8.codes(name) do
    result = multiply_modulo(result, 65599, modulus)
    result = (result + code) % modulus
  end
  return result
end

function randomnames.new_model(name, min_context_size,
                               max_context_size, seed)
  assert(models[name] == nil,
         [[Model named "]] .. name .. [[" already exists]])
  min_context_size =
    min_context_size or 1
  max_context_size =
    max_context_size or 3
  local model =
    BackoffModel.new(min_context_size, max_context_size)
  if seed == nil then
    seed = hash(name)
  end
  local random =
    Random.new(seed)
  models[name] = model
  randoms[name] = random
end

local function get_model(name)
  local model
  model = models[name]
  assert(model ~= nil,
         [[Model named "]] .. name .. [[" does not exist]])
  return model
end

function randomnames.add_name(model_name, name)
  local model =
    get_model(model_name)
  model:add_name(name)
end

function randomnames.input_names(model_name, filename)
  local model =
    get_model(model_name)
  model:input_names(filename)
end

function randomnames.take_random_walk(name, graph_type,
                                      affix, seed,
                                      min_context_size,
                                      max_context_size)
  local model =
    get_model(name)
  graph_type = graph_type
            or "forward"
  affix = affix
        or ""
  local random
  if seed == nil then
    random = randoms[name]
  else
    random =
      Random.new(seed)
  end
  if min_context_size
       == nil then
     min_context_size =
       model.
         min_context_size
  end
  if max_context_size == nil then
     max_context_size = model.max_context_size
  end
  local result =
    model:take_random_walk(graph_type, affix, random,
                           min_context_size,
                           max_context_size)
  return result
end
return randomnames
