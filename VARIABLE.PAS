UNIT VARIABLE;

INTERFACE

USES
    CRT, DOS, GRAPH, DSFONT, DSDRIV;

CONST
     X = 95;
     Y = 2;
     XR = 545;
     YB = 108;

TYPE
    STRING14 = STRING[14];
    STRING12 = STRING[12];
    STRING10 = STRING[10];
    STRING19 = STRING[19];
    STRING20 = STRING[20];
    ARR4     = ARRAY[1..4] OF BYTE;
    SPEC     = (OK, DEAD, STONE, PARALYS, POISON, ASLEEP, SILENCE);
    INFOPTR  = ^INFOPOINT;
    INFOPOINT = RECORD
                  ITEM : STRING19;
                  COST : INTEGER;
                  PLACE : INTEGER;
                  PREV : INFOPTR;
                  NEXT : INFOPTR;
                END;
    INFO = RECORD
             ITEM : STRING19;
             EQUIPED : BOOLEAN;
             WHATTYPE : CHAR;
             NOTUSEDBY : CHAR;
             COST : LONGINT;
             NUMBER : BYTE;
             USE : BYTE;
             CHARGES : SHORTINT;
             DMG : BYTE;
             PROTECTION : BYTE;
           END; {OF RECORD}
    PERSON    = RECORD
                  NAME        : STRING20;
                  RACE        : STRING[8];
                  CLASS       : STRING10;
                  LEVEL       : BYTE;
                  AC          : -100..10;
                  SPAC        : SHORTINT;
                  ABILITIES   : ARRAY[1..7] OF 3..18;
                  NUMATTACKS  : 1..9;
                  ATTGROUP    : -4..4;
                  THACO       : 1..20;
                  DAMAGE      : BYTE;
                  HPTOT       : INTEGER;
                  HPLEFT      : INTEGER;
                  EQUIPMENT   : ARRAY[1..8] OF INFO;
                  EXP         : LONGINT;
                  MONEY       : LONGINT;
                  SPELLLEVEL  : BYTE;
                  SPELLPTSTOT : WORD;
                  SPELLPTLEFT : WORD;
                  SPECIAL     : SPEC;
                  STATUS      : STRING[7];
                END; {OF RECORD}
    GROUP     = RECORD
                  NAME : STRING[19];
                  NUMBER : SHORTINT;
                  HDICE : BYTE;
                  AC : SHORTINT;
                  THACO : BYTE;
                  DMG : BYTE;
                  SPECIALATT : ARRAY[1..5] OF BYTE;
                  EXPERIENCEPER : INTEGER;
                  GOLDPER : INTEGER;
                  HITSTOKILL : BYTE;
                  MONSTERTYPE : CHAR;
                END; {OF RECORD}
    ENCGROUPS = ARRAY[1..4] OF GROUP;
    LEVEL     = ARRAY[1..21,1..21] OF STRING[9];
    POS       = ARRAY[1..8] OF STRING20;
    ROSTARRAY = ARRAY[0..6] OF PERSON;
    DATAPTR   = ^PTRTYPE;
    PTRTYPE   = RECORD
                  GROUP : SHORTINT;
                  NUMBER : -1..99;
                  RANK : WORD;
                  NEXT : DATAPTR;
                END;
    MSGPTR    = ^MSGLIST;
    MSGLIST   = RECORD
                  WORDS : STRING14;
                  NEXT : MSGPTR;
                END;
    WORDL     = ^WORDSARR;
    WORDSARR  = ARRAY[0..1030] OF STRING14;
    NOTES     = ARRAY[1..2] OF BYTE;
    SONGPTR   = ^SONGINFO;
    SONGINFO  = RECORD
                  INFO : NOTES;
                  NEXT : SONGPTR;
                END;
    PL        = RECORD
                  ARR5 : ARRAY[1..5] OF BYTE;
                  FILENAME : STRING12;
                END;

CONST
     SCUM : INFO = (ITEM : '';
                    EQUIPED : FALSE;
                    WHATTYPE : ' ';
                    NOTUSEDBY : ' ';
                    COST : 0;
                    NUMBER : 0;
                    USE : 0;
                    CHARGES : 0;
                    DMG : 0;
                    PROTECTION : 0);

VAR
   SX, PY, PX, CHX,
   CHY, PXD, PYD, CHXD,
   ROOMAHEAD, SCRIPTFONT          : INTEGER;

   DKBLUE, DKGREEN, DKCYAN,
   DKRED, DKMAGENTA, DKYELLOW,
   DKWHITE, GREY, LTBLUE,
   LTGREEN, LTCYAN, LTRED,
   LTMAGENTA, LTYELLOW, LTWHITE   : BYTE;

   HITSTOKILL, NUMKILLED          : ARR4;

   CHECK, FULL, PLACE, FIGHT,
   LIGHTSP, ARMOR, SHELD, NORUN,
   LGLIGHTSP, INVULN, COMPAS,
   LGCOMPASS, PASS, IGNORE,
   SPELL, KILLED, QUEST, FDOOR,
   BANDW, DONTKILL, TRAP,
   PBREATH, OPENED, NOSPEAK,
   PROTECTIONSP, PLAYSONG, NOSONG,
   SONGON, PSTAIRS, REPELL        : BOOLEAN;

   I, J, K, L, N, E, LEV,
   GROUPTOT, TEMP, TEMP2,
   PEOPLE, DURATION, TOPLEV       : BYTE;

   RESPONCE, CH, LEFT,
   CENTER, RIGHT, DIRECTION       : CHAR;

   ENCOUNTER                      : ENCGROUPS;

   ITEMDATA                       : INFO;

   FIRST, TOP, BOTTOM, MIDDLE     : INFOPTR;

   LEN, C, T, INT, CODE, PNUM,
   THYME, GRDRIVER, GRMODE,
   ERRCODE, SINT, SC              : INTEGER;

   NUM, GOLD, BIGNUM,
   COUNT, ACCOUNT                 : LONGINT;

   DATA                           : LEVEL;

   WORDSTART, WORDEND, MIDWORD    : MSGPTR;

   INT1CSAVE, NEW1CINT, INT1BSAVE,
   NEW1BINT, EXITSAVE             : POINTER;

   POSSIBLEARRAY                  : POS;

   CHARACTER                      : PERSON;

   ROSTER                         : ROSTARRAY;

   DIRINFO                        : SEARCHREC;

   THYMESTOP                      : SHORTINT;

   GUILDSONG, SONGSTART           : SONGPTR;

   STRINGONE                      : STRING[1];

   HPNUM                          : STRING[5];

   PSEUDONYM                      : STRING[8];

   ROOM                           : STRING[9];

   NUMSTR, NUMSTR2, TRAPTYPE      : STRING10;

   INPUTSTR, OUTGOLD, OUTNAME,
   FILENAME1, DISARMING           : STRING20;

   START, LAST, PTR, BEFORE,
   FIND                           : DATAPTR;

   WORDLIST                       : WORDL;

   SHOPFILE                       : FILE OF INFO;

   SGCH                           : FILE OF ROSTARRAY;

   SGPL                           : FILE OF PL;

   MON                            : FILE OF LONGINT;

   MONSDATA                       : FILE OF GROUP;

PROCEDURE INITCHARACTER;
PROCEDURE FIRSTINIT;

IMPLEMENTATION

USES
    DRAW, MAIN;

{*******************************************************************}

PROCEDURE SONG (FLAGS, CS, IP, AX, BX, CX, DX, SI, DI, DS, ES, BP : WORD);
INTERRUPT;

BEGIN
     IF PLAYSONG THEN
       IF SONGON THEN
         BEGIN
           SOUND (GUILDSONG^.INFO[1]*4);
           SONGON := FALSE;
         END
       ELSE
         BEGIN
           DEC (DURATION);
           IF DURATION = 0 THEN
             BEGIN
               SONGON := TRUE;
               GUILDSONG := GUILDSONG^.NEXT;
               DURATION := GUILDSONG^.INFO[2];
             END;
         END
     ELSE
       NOSOUND;

END; {OF INTERRUPT SONG}

{*******************************************************************}

PROCEDURE GETSONG;

TYPE
    FLOAD = FILE OF NOTES;

VAR
   SONGFILE : FLOAD;
   MIDSONG : SONGPTR;

BEGIN
     ASSIGN (SONGFILE, 'DSDATA.F07');
     RESET (SONGFILE);
     NEW (MIDSONG);
     READ (SONGFILE, MIDSONG^.INFO);
     IF IORESULT <> 0 THEN
       DISKERROR ('DSDATA.F07', FALSE);
     SONGSTART := MIDSONG;
     WHILE NOT EOF (SONGFILE) DO
       BEGIN
         GUILDSONG := MIDSONG;
         NEW (MIDSONG);
         READ (SONGFILE, MIDSONG^.INFO);
         IF IORESULT <> 0 THEN
           DISKERROR ('DSDATA.F07', FALSE);
         GUILDSONG^.NEXT := MIDSONG;
       END;
     GUILDSONG^.NEXT^.NEXT := SONGSTART;
     GUILDSONG := SONGSTART;
     DURATION := GUILDSONG^.INFO[2];

END; {OF PROCEDURE GETSONG}

{*******************************************************************}

PROCEDURE RESETCOLORS (A, B, C, D, E, F, G, H,
                       I, J, K, L, M, N, O : BYTE);

BEGIN
     DKBLUE := A;
     DKGREEN := B;
     DKCYAN := C;
     DKRED := D;
     DKMAGENTA := E;
     DKYELLOW := F;
     DKWHITE := G;
     GREY := H;
     LTBLUE := I;
     LTGREEN := J;
     LTCYAN := K;
     LTRED := L;
     LTMAGENTA := M;
     LTYELLOW := N;
     LTWHITE := O;

END; {OF PROCEDURE RESETCOLORS}

{*******************************************************************}

PROCEDURE INITCOLORS;

BEGIN
     CASE GRDRIVER OF
       CGA, MCGA,
       HERCMONO,
       PC3270, ATT400  : BEGIN
                           BANDW := TRUE;
                           RESETCOLORS (1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1);
                         END;
       EGA, EGA64,
       VGA, IBM8514    : RESETCOLORS (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15);
       EGAMONO         : BEGIN
                           BANDW := TRUE;
                           RESETCOLORS (1, 1, 1, 2, 1, 2, 0, 1, 1, 1, 1, 1, 1, 1, 1);
                         END;
     END; {OF CASE}

END; {OF PROCEDURE INITCOLORS}

{*******************************************************************}

PROCEDURE INITCHARACTER;

BEGIN
     WITH CHARACTER DO
       BEGIN
         NAME := '';
         RACE := '';
         CLASS := '';
         LEVEL := 1;
         AC := 10;
         SPAC := 0;
         HPTOT := 1;
         HPLEFT := 1;
         NUMATTACKS := 1;
         ATTGROUP := 1;
         THACO := 20;
         DAMAGE := 0;
         SPECIAL := OK;
         FOR J := 1 TO 7 DO
           ABILITIES[J] := 3;
         FOR J := 1 TO 8 DO
           EQUIPMENT[J] := SCUM;
         EXP := 0;
         MONEY := 0;
         SPELLLEVEL := 0;
         SPELLPTSTOT := 0;
         SPELLPTLEFT := 0;
         STATUS := 'OK';
       END; {OF WITH CHARACTER}

END; {OF INITCHARACTER}

{*******************************************************************}

PROCEDURE UNSCRAMBLE (VAR WORD1 : STRING14);

BEGIN
     FOR J := 1 TO LENGTH (WORD1) DO
       BEGIN
         CH := WORD1[J];
         NUM := ORD (CH);
         IF J MOD 2 = 0 THEN
           DEC (NUM, 90)
         ELSE
           INC (NUM, 17);
         CH := CHR (NUM);
         WORD1[J] := CH;
       END;

END; {OF PROCEDURE SCRAMBLE}

{*******************************************************************}

PROCEDURE FIRSTINIT;

VAR
   LOADWORDS : TEXT;
   STRIN : STRING;

BEGIN
     RANDOMIZE;
     C := REGISTERBGIDRIVER (@CGADriverProc);
     C := REGISTERBGIDRIVER (@EGAVGADriverProc);
     C := REGISTERBGIDRIVER (@HercDriverProc);
     C := REGISTERBGIFONT (@GothicFontProc);
     C := REGISTERBGIFONT (@SmallFontProc);
     C := REGISTERBGIFONT (@TriplexFontProc);
     SCRIPTFONT := REGISTERBGIFONT (@ScriptFontProc);

     GRDRIVER := DETECT;
     GRMODE := 0;
     NOSONG := FALSE;
     IF (PARAMCOUNT > 0) THEN
       FOR I := 1 TO PARAMCOUNT DO
         BEGIN
           STRIN := PARAMSTR(I);
           FOR J := 1 TO LENGTH(STRIN) DO
             STRIN[J] := UPCASE(STRIN[J]);
           IF (STRIN = 'NOSONG') THEN
             NOSONG := TRUE
           ELSE
             CASE UPCASE (STRIN[1]) OF
               ' ' : ;
               'C' : GRDRIVER := CGA;
               'G' : GRDRIVER := MCGA;
               'E' : GRDRIVER := EGA;
               'M' : GRDRIVER := EGAMONO;
               'H' : GRDRIVER := HERCMONO;
               'V' : GRDRIVER := VGA;
             END; {OF CASE}
         END;
     INITGRAPH (GRDRIVER, GRMODE , '');
     ERRCODE := GRAPHRESULT;
     IF ERRCODE <> GROK THEN
       BEGIN
         CLOSEGRAPH;
         CLRSCR;
         WRITELN ('UNABLE TO ENTER GRAPHICS. . .');
         WRITELN ('GRAPHICS ERROR:  ',GRAPHERRORMSG (ERRCODE));
         WRITELN;
         HALT (0);
       END;
     CASE GRDRIVER OF
       VGA,EGA  : SETGRAPHMODE (0);
       CGA      : SETGRAPHMODE (4);
       HERCMONO : SETVIEWPORT (20, 74, 660, 274, CLIPON);
     END;
     ERRCODE := GRAPHRESULT;
     IF ERRCODE <> GROK THEN
       BEGIN
         CLOSEGRAPH;
         CLRSCR;
         WRITELN ('UNABLE TO ENTER GRAPHICS. . .');
         WRITELN ('GRAPHICS ERROR:  ',GRAPHERRORMSG (ERRCODE));
         WRITELN;
         HALT (0);
       END;
     IF (NOT NOSONG) THEN
       BEGIN
         GETSONG;
         SONGON := TRUE;
         PLAYSONG := TRUE;
         NEW1CINT := @SONG;
         GETINTVEC ($1C, INT1CSAVE);
         SETINTVEC ($1C, NEW1CINT);
       END;
     ASSIGN (SGCH, 'SAVEGAME.ROS');
     ASSIGN (SGPL, 'SAVEGAME.PLC');
     ASSIGN (SHOPFILE, 'DSDATA.F10');
     ASSIGN (MONSDATA, 'DSDATA.F12');
     ASSIGN (MON, 'DSDATA.F06');
     BANDW := FALSE;
     SETFILLSTYLE (EMPTYFILL, BLACK);
     INITCOLORS;
     DRAWOPENING;
     DRAWHEADING;
     LIGHTSP := FALSE;
     LGLIGHTSP := FALSE;
     SHELD := FALSE;
     ARMOR := FALSE;
     INVULN := FALSE;
     COMPAS := FALSE;
     LGCOMPASS := FALSE;
     FDOOR := FALSE;
     COMPASSICON (FALSE);
     SHIELDICON (FALSE);
     LIGHTICON (FALSE);
     LEV := 0;
     FILENAME1 := 'DSDATA.F01';
     GETMAZE;
     NEW (WORDLIST);
     ASSIGN (LOADWORDS, 'DSDATA.F08');
     RESET (LOADWORDS);
     FOR LEN := 0 TO 1030 DO
       BEGIN
         READLN (LOADWORDS, WORDLIST^[LEN]);
         IF IORESULT <> 0 THEN
           DISKERROR ('DSDATA.F08', TRUE);
         UNSCRAMBLE (WORDLIST^[LEN]);
       END;
     CLOSE (LOADWORDS);
     IGNORE := FALSE;
     PASS := FALSE;

     FIGHT := FALSE;
     PBREATH := FALSE;
     PROTECTIONSP := FALSE;
     REPELL := FALSE;
     NORUN := FALSE;
     THYMESTOP := 0;
     COUNT := 1;
     THYME := 90;
     PEOPLE := 0;
     N := 13;
     E := 11;
     DIRECTION := 'S';
     INITCHARACTER;
     FOR J := 0 TO 6 DO
       ROSTER[J] := CHARACTER;
     ROSTER[0].SPECIAL := DEAD;

END; {OF PROCEDURE FIRSTINT}

{*******************************************************************}

END. {OF UNIT VARIABLE}