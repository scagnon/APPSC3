**FREE
//%METADATA                                                                          *
// %TEXT Order detail                                                                *
//%EMETADATA                                                                         *

Ctl-Opt dftactgrp(*no) bnddir('SAMPLE');

Dcl-F custome1   Keyed;
Dcl-F article1   Keyed;
Dcl-F detord1    Keyed;
Dcl-F order1     Keyed;
Dcl-F ord202d    WORKSTN
                         indds(indds)
                         sfile(sfl01:rrn01)
                         Infds(Info);

Dcl-Pr ord202;
  id              like(orid);
End-Pr;
Dcl-Pi ord202;
  id              like(orid);
End-Pi;
Dcl-Ds indds;
  help            Ind             Pos(1);
  exit            Ind             Pos(3);
  prompt          Ind             Pos(4);
  refresh         Ind             Pos(5);
  create          Ind             Pos(6);
  cancel          Ind             Pos(12);
  morekeys        Ind             Pos(24);
  pagedown        Ind             Pos(25);
  sflclr          Ind             Pos(30);
  sfldsp          Ind             Pos(31);
  sfldspctl       Ind             Pos(32);
  sflnxtchg       Ind             Pos(33);
  dspatr_ri       Ind             Pos(34);
  sflmsg          Ind             Pos(35);
  sflend          Ind             Pos(80);
End-Ds;

Dcl-Ds info;
  lrrn            Int(5)          Pos(378);
End-Ds;

Dcl-S rrn01           Int(5);
Dcl-S rrs01           Int(5);
Dcl-S err01           Ind;

Dcl-S panel           Int(3)          INZ(1);
Dcl-S step01          Char(3)         inz(prp);
Dcl-S User            Char(10)        inz(*user);
Dcl-S count           Int(3);
Dcl-S mode            Char(3);

Dcl-C crt             'CRT';
Dcl-C upd             'UPD';
Dcl-C prp             'prp';
Dcl-C lod             'lod';
Dcl-C dsp             'dsp';
Dcl-C key             'key';
Dcl-C chk             'chk';
Dcl-C act             'act';
Dcl-C datBlank        d'1940-01-01';
select;
when panel = 1;
  exsr pnl01;
other;
  exsr pnl00;
endsl;
//- Subfiles  01 Subroutines --------------------------------------  ---
begsr pnl01;
  select ;
  when step01 = prp ;
    exsr s01prp;
  when step01 = lod ;
    exsr s01lod;
  when step01 = dsp ;
    exsr s01dsp;
  when step01 = key ;
    exsr s01key;
  when step01 = act ;
    exsr s01act ;
  endsl;
endsr;
//--- Clear Subfile  ----------------------------------------------------
begsr s01prp;
  chain id order1;
  chain orcuid custome1;
  datord = %date(ordate:*iso);
  if ordatdel > 0;
    datliv = %date(ordatdel:*iso);
  endif;
  if ordatclo > 0;
    datclo = %date(ordatclo:*iso);
  endif;
  RRn01 = 0;
  sflclr = *on;
  write ctl01;
  sflclr = *off;
  step01 = lod;
endsr;
//--- Load Subfile  -----------------------------------------------------
begsr s01lod;
  RRb01 = RRn01 + 1;
  tot = 0;
  totvat = 0;
  setll id detord1;
  reade id detord1;
  dow not %eof(detord1);
    tot += odtot;
    totvat += odtotvat;
    chain odarid article1;
    RRN01 += 1;
    write sfl01;
    reade id detord1;
  enddo;
  sflend = *on;
  step01 = dsp;
endsr;
//--- Display Subfile  --------------------------------------------------
begsr s01dsp;
  sfldspctl = *on;
  sfldsp = RRn01 > 0;

  write key01;
  exfmt ctl01;
  if LRRN <>0;
    RRb01 = LRRN;
  endif;
  step01 = key;
endsr;
//--- Command Keys  -----------------------------------------------------
begsr s01key;
  select;
  when exit;
    panel  = 0;
    step01 = prp;
  when cancel;
    step01 = prp;
    panel  = 0 ;
  other;
    step01 = act;
  endsl;
endsr;
//--- action Subfile  ---------------------------------------------------
begsr s01act;
  panel = 0;
endsr;

//--------INITIALIZATION ----------------------------------
begsr *inzsr;
  datord = datBlank;
  datclo = datBlank;
  datliv = datBlank;
endsr;
//--------END SUBROUTINE ----------------------------------
begsr pnl00;
  *inlr = *on;
endsr;