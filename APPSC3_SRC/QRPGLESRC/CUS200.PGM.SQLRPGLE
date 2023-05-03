**FREE
//%METADATA
// %TEXT Work with Customers
//%EMETADATA

  Ctl-Opt dftactgrp(*no) bnddir('SAMPLE');

  Dcl-F custome2   Keyed rename(fcust:fcust2);
  Dcl-F custome1   Usage(*Update:*Delete:*Output) Keyed;
  Dcl-F cus200d    WORKSTN
                           indds(indds)
                           sfile(sfl01:rrn01)
                           Infds(Info);

  /COPY ../QPROTOSRC/COUNTRY.RPGLEINC
  /COPY ../QPROTOSRC/PARAMETER.RPGLEINC

  Dcl-Pr orders extpgm('ORD200');
    id              like(cuid);
  End-Pr;

  Dcl-Ds indds;
    help            Ind             Pos(1);
    exit            Ind             Pos(3);
    prompt          Ind             Pos(4);
    refresh         Ind             Pos(5);
    create          Ind             Pos(6);
    cancel          Ind             Pos(12);
    GetPrivilege    Ind             Pos(13);
    morekeys        Ind             Pos(24);
    pagedown        Ind             Pos(25);
    sflclr          Ind             Pos(30);
    sfldsp          Ind             Pos(31);
    sfldspctl       Ind             Pos(32);
    sflnxtchg       Ind             Pos(33);
    dspatr_ri       Ind             Pos(34);
    sflmsg          Ind             Pos(35);
    ErrCountry      Ind             Pos(40);
    ErrName         Ind             Pos(41);
    ErrDup          Ind             Pos(42);
    ErrPhone        Ind             Pos(43);
    ErrPhoneNum     Ind             Pos(44);
    ErrCategory     Ind             Pos(45);
    InvalidPassword Ind             Pos(46);
    privilegedUser  ind             pos(50);
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
  Dcl-S step02          Char(3)         inz(prp);
  Dcl-S step03          Char(3)         inz(prp);
  Dcl-S savId           like(cuid);
  Dcl-S savName         like(custnm);
  Dcl-S User            Char(10)        inz(*user);
  Dcl-S count           Int(3);
  Dcl-S dup             Int(3);
  dcl-s privilege       int(3);


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
  when panel = 2;
    exsr pnl02;
  when panel = 3;
    exsr pnl03;
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
    when step01 = chk ;
      exsr s01chk;
    when step01 = act ;
      exsr s01act ;
    endsl;
  endsr;
  //--- Clear Subfile  ----------------------------------------------------
  begsr s01prp;
    RRn01 = 0;
    sflclr = *on;
    write ctl01;
    sflclr = *off;
    step01 = lod;
    clear savid;
    savName = posTo;
    clear posTo;
    rrs01 = 0;
  endsr;
  //--- Load Subfile  -----------------------------------------------------
  begsr s01lod;
    exsr s01rst;
    RRb01 = RRn01 + 1;
    opt01 = 0;
    count = 0;
    read custome2;
    dow not %eof(custome2) and count < 14;
      RRN01 += 1;
      count += 1;
      write sfl01;
      read custome2;
    enddo;
    sflend = %eof(custome2);
    step01 = dsp;
    exsr s01sav;
  endsr;
  //--- restore last read -------------------------------------------------
  begsr s01rst;
    setll (savName:savid)  custome2;
    rrn01 = rrs01;
  endsr;
  //--- Save last read -------------------------------------------------
  begsr s01sav;
    savid = cuid;
    savName = custNm;
    rrs01 = rrn01;
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
      panel  = panel  - 1;
    when refresh;
      step01 = prp;
    when GetPrivilege;
      exfmt wdw01;
      if cancel;
        step01 = dsp;
      elseif password = 'ARCAD';
        step01 = prp;
        exec sql set privilege = 1;
        close custome1;
        close custome2;
        open custome1;
        open custome2;
        privilegedUser = *on;
      else;
        InvalidPassword = *on;
      ENDIF;
    when create;
      step01 = dsp;
      panel  = 2;
      step02 = dsp;
      mode = CRT;
      reset fcust;
      exec sql set :Cuid  = NEXT VALUE FOR CusSeq     ;
    when pagedown;
      step01 = lod;
    other;
      step01 = chk;
    endsl;
  endsr;
  //--- Check Subfile  ----------------------------------------------------
  begsr s01chk;
    step01 = act;
    err01 = *off;
    sflnxtchg = *on;
    readc(e) sfl01;
    dow not %error and not %eof;
      if opt01  <> 0 and opt01  <> 2 and opt01  <> 5 and opt01 <> 6;
        step01 = dsp;
        dspatr_ri = *on;
        sflmsg = *on;
        if not err01;
          rrb01 = rrn01;
          err01 = *on;
        endif;
      endif;
      if opt01  = 2 and not privilegedUser;
        step01 = dsp;
        dspatr_ri = *on;
        sflmsg = *on;
        if not err01;
          rrb01 = rrn01;
          err01 = *on;
        endif;
      endif;
      update sfl01;
      dspatr_ri = *off;
      readc(e) sfl01;
    enddo;
    sflnxtchg = *off;
  endsr;
  //--- action Subfile  ---------------------------------------------------
  begsr s01act;
    readc(e) sfl01;
    select;
    when %error or %eof;
      if posto <> ' ';
        step01 = prp;
      else;
        step01 = dsp;
      endif;
    when opt01 = 2;
      mode = upd;
      panel = 2;
      step02 = prp;
      opt01 = 0;
      update sfl01;
    when opt01 = 5;
      panel = 3;
      step03 = prp;
      opt01 = 0;
      update sfl01;
    when opt01 = 6;
      orders(cuid);
      opt01 = 0;
      update sfl01;
    other;

    endsl;
  endsr;


  //--- Format 02 Subroutines ------------------------------------     ---
  begsr pnl02;
    select ;
    when step02 = prp ;
      exsr s02prp;
    when step02 = dsp ;
      exsr s02dsp;
    when step02 = key ;
      exsr s02key;
    when step02 = chk ;
      exsr s02chk;
    when step02 = act ;
      exsr s02act ;
    endsl;

  endsr;
  //--- clear & Load ------------------------------------------------------
  begsr S02prp;
    chain cuid custome1;
    // Value generated by a SQL Mask
    coname = GetCountryName(CuCoun);
    catName = GetPARM2('CUSCAT':cucat);
    if CULASTORD = 0;
      LASTORD = datBlank;
    else;
      LASTORD  =%date(CULASTORD:*iso);
    ENDIF;
    step02 = dsp;
  endsr;
  //--- Display  ----------------------------------------------------------
  begsr S02dsp;
    exfmt fmt02;
    step02 = key;
  endsr;
  //--- command Keys  -----------------------------------------------------
  begsr S02key;
    select;
    when exit;
      panel  = 1;
      step02 = prp;
    when cancel;
      step02 = prp;
      panel  = panel  - 1;
    when prompt;
      step02 = dsp;
      cucoun = SltCountry(cucoun);
      coname = GetCountryName(CuCoun);
    other;
      step02 = chk;
    endsl;
  endsr;
  //--- check -------------------------------------------------------------
  begsr S02chk;
    step02 = act;
    if not ExistCountry(cucoun);
      errCountry = *on;
      step02 = dsp;
    endif;
    if not ExistParm('CUSCAT':cucat);
      errCategory = *on;
      step02 = dsp;
    endif;
    if custnm = *blanks;
      errName = *on;
      step02 = dsp;
    endif;
    if cuphone = *blanks;
      errPhone = *on;
      step02 = dsp;
    else;
      cuphone = %trim(cuphone);
      if %check('0123456789':%trim(cuphone)) > 0;
        errPhoneNum = *on;
        step02 = dsp;
      ENDIF;
      exec sql select count(*) into :dup from customer
               where UPPER(custnm) = UPPER(:Custnm)
                 and cuphone = :cuphone ;
      if mode = CRT and dup > 0 or mode = UPD and dup > 1;
        errData = custnm + cuphone;
        errDup = *on;
        step02 = dsp;
      ENDIF;
    endif;

  endsr;
  //--- Action ------------------------------------------------------------
  begsr S02act;
    step02 = prp;
    if mode = upd;
      update fcust;
    else;
      write fcust;
    endif;
    panel = 1;
  endsr;

  //--- Format 03 Subroutines ------------------------------------     ---
  begsr pnl03;
    select ;
    when step03 = prp ;
      exsr s03prp;
    when step03 = dsp ;
      exsr s03dsp;
    when step03 = key ;
      exsr s03key;
    when step03 = chk ;
      exsr s03chk;
    when step03 = act ;
      exsr s03act ;
    endsl;

  endsr;
  //--- clear & Load ------------------------------------------------------
  begsr S03prp;
    chain cuid custome1;
    catName = GetPARM2('CUSCAT':cucat);
    coname = GetCountryName(CuCoun);
    step03 = dsp;
  endsr;
  //--- Display  ----------------------------------------------------------
  begsr S03dsp;
    exfmt fmt03;
    step03 = key;
  endsr;
  //--- command Keys  -----------------------------------------------------
  begsr S03key;
    select;
    when exit;
      panel  = 1;
      step03 = prp;
    when cancel;
      step03 = prp;
      panel  = 1;
    other;
      step03 = chk;
    endsl;
  endsr;
  //--- check -------------------------------------------------------------
  begsr S03chk;
    step03 = act;

  endsr;
  //--- Action ------------------------------------------------------------
  begsr S03act;
    step03 = prp;
    panel = 1;
  endsr;

  //--------INITIALIZATION ----------------------------------
  begsr *inzsr;
    cumodid = user;
    cucrea = %date();
    LASTORD = datblank;
    exec sql set :privilege = privilege;
    privilegedUser = privilege = 1;
  endsr;
  //--------END SUBROUTINE ----------------------------------
  begsr pnl00;
    *inlr = *on;
    exec sql set privilege = 0;
  endsr;
