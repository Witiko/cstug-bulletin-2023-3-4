defaultcolormodel:=7;
sirkasazby=27cc;
fous=1mm;
tloustkaramu=0.1mm;
tloustkacary:=tloustkaramu;
tloustkapuntiku=0.8mm;
bls=12pt;
u=mm;
ods=10u;

cmykcolor cerna,seda,bila;
cerna=(0,0,0,1);
seda=(0,0,0,0.4);
bila=(0,0,0,0);
string tt,sf,rm;
tt="cstt10";
sf="csss10";
rm="csr10";

path bpath[];
picture tmppic,tmppic[];
def ram(expr cislo,pozice,napis,pismo,barva)=
  tmppic:=napis infont pismo;
  tmppic:=tmppic shifted -(.5[llcorner tmppic, urcorner tmppic]);
  numeric S,V;
  (S,V)=urcorner tmppic+(fous,fous);
  z[cislo]=pozice;
  bpath[cislo]=((-S,-V)--(S,-V)--(S,V)--(-S,V)--cycle) shifted pozice;
  fill bpath[cislo] withcmykcolor bila;
  draw bpath[cislo] withpen pencircle scaled tloustkaramu withcmykcolor barva;
  draw tmppic shifted pozice;
enddef;
def soubor(expr cislo, pozice, napis)= ram(cislo, pozice, napis, sf, cerna); enddef;
def prikaz(expr cislo, pozice, napis)= ram(cislo, pozice, napis, tt, seda); enddef;

def Ram(expr cislo,pozice,napisA,napisB,pismo,barva)=
  tmppic1:=napisA infont pismo;
  tmppic1:=tmppic1 shifted -(.5[llcorner tmppic1, urcorner tmppic1]) shifted (0,bls/2);
  tmppic2:=napisB infont pismo;
  tmppic2:=tmppic2 shifted -(.5[llcorner tmppic2, urcorner tmppic2]) shifted (0,-bls/2);
  tmppic3:=image(draw tmppic1;draw tmppic2;);
  tmppic3:=tmppic3 shifted -(.5[llcorner tmppic3, urcorner tmppic3]);
  numeric S,V;
  (S,V)=urcorner tmppic3+(fous,fous);
  z[cislo]=pozice;
  bpath[cislo]=((-S,-V)--(S,-V)--(S,V)--(-S,V)--cycle) shifted pozice;
  fill bpath[cislo] withcmykcolor bila;
  draw bpath[cislo] withpen pencircle scaled tloustkaramu withcmykcolor barva;
  draw tmppic3 shifted pozice;
enddef;
def Soubor(expr cislo, pozice, napisA, napisB)= Ram(cislo, pozice, napisA, napisB, sf, cerna); enddef;
def Prikaz(expr cislo, pozice, napisA, napisB)= Ram(cislo, pozice, napisA, napisB, tt, seda); enddef;

def sipka(expr odkud, kam, sekA, sekB)=
  drawarrow (odkud--kam) cutbefore bpath[sekA] cutafter bpath[sekB];
enddef;

def puntik(expr cislo)=
  fill fullcircle scaled tloustkapuntiku shifted z[cislo] withcmykcolor cerna;
enddef;

beginfig(1)
  pickup pencircle scaled tloustkacary;
  s0=35u;
  v0=3u;
  z0=(5u,0);
  bpath0=(s0,0){up}...{left}(0,v0);
  bpath0:=(bpath0--(reverse bpath0 xscaled-1)--(bpath0 scaled-1)--(reverse bpath0 yscaled-1)--cycle) shifted z0;
  draw bpath0 withpen pencircle scaled tloustkaramu withcmykcolor cerna;
  label(btex \TeX etex,z0);
  
  soubor(1,(25u,35u),"dokumentace.tex");
  soubor(2,(-25u,y1),"dokumentace.ds");
  soubor(3,(-5u,-50u),"dokumentace.pdf");
  soubor(4,(x1+5u,y3),"program.txt");
  
  z12=z1;
  z11=z12-(ods,0);
  z13-z12=z12-z11;
  for i=11 upto 13:
    sipka(z[i],(x[i],y0),1,0);
  endfor
  
  z17=(x11,ypart llcorner bpath1);
  z18=(x12,y17);
  z19=(x13,y17);
  for i=1 upto 3:
    label.llft((decimal(i)&".") infont rm,z[16+i]);
  endfor
  
  z21=z2+(2u,0);
  z22=z21+(ods,0);
  for i=21 upto 22:
    sipka(z[i],(x[i],y0),2,0);
  endfor
  
  z28=(x21,ypart llcorner bpath2);
  z29=(x22,y28);
  for i=1 upto 2:
    label.llft((decimal(i)&".") infont rm,z[27+i]);
  endfor
  
  z32=z3;
  z31=z32-(ods,0);
  z33-z32=z32-z31;
  for i=31 upto 33:
    sipka((x[i],y0),z[i],0,3);
  endfor
  
  z37=(x31,ypart llcorner bpath0);
  z38=(x32,y37);
  z39=(x33,y37);
  for i=1 upto 3:
    label.llft((decimal(i)&".") infont rm,z[36+i]);
  endfor

  z41=z4;
  z53=(x33,y41+25u);
  puntik(53);
  draw z53--(x41,y53);
  sipka((x41,y53),z41,0,4);
  
   
  z26=(xpart llcorner bpath2 + (xpart urcorner bpath2-x22),y22);
  z27=z26+(0.2ods,0);
  
  z52=(x32,y53);
  z51=(x31,y52+(x27-x26));
  puntik(52);
  puntik(51);

  draw z51--(x27,y51);
  draw z52--(x26,y52);
  sipka((x26,y52),z26,0,2);
  sipka((x27,y51),z27,0,2);
  
  prikaz(111,(z11-(2u,10u)),"\BEGSRC<>{}");
  prikaz(112,((x12,y111-8u)),"\BEGSRC<>");
  prikaz(113,((x13,y111)),"\BEGSRC");
  
  prikaz(121,(x21-3u,y111),"\DEFSRC");
  prikaz(122,(x22+(x21-x121),y121),"\ADDSRC");
  Prikaz(124,(.5[x21,x22],y121-12u),"\SRCbeginline","\SRCreadblock");
  
  Prikaz(126,(.5[x26,x27],y51+10u),"\SRCwritedsline","\SRCblock");
  
  Prikaz(132,(x52,y52-10u),"\SRCprintline","\SRCprintblock");
  Prikaz(141,(x41,y132),"\SRCwriteline","\SRCwriteblock");
  
%if true:
if false:
  currentpicture:=currentpicture shifted -(.5[llcorner currentpicture, urcorner currentpicture]);
  dole=ypart llcorner currentpicture;
  hore=ypart urcorner currentpicture;
  
  for i=-1,1:
    draw ((0,dole)--(0,hore)) shifted (i/2*sirkasazby,0) withpen pencircle scaled 0.1mm withcmykcolor seda;
  endfor;
fi

endfig;
end
