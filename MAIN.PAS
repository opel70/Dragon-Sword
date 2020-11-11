UNIT MAIN;

INTERFACE

USES
    CRT, GRAPH, VARIABLE;

FUNCTION GETAORAN (LETTER1 : CHAR) : STRING;
PROCEDURE GETMAZE;
PROCEDURE TAKESTAIRS (UP : BOOLEAN);
PROCEDURE SAVEGAME;
PROCEDURE LOADGAME;
FUNCTION PARTYNOTDEAD : BOOLEAN;
PROCEDURE BEGINENCOUNTER;
PROCEDURE ACCOMPLISHENCOUNTER;
PROCEDURE ATTACK;
PROCEDURE SHOWENCOUNTER;
PROCEDURE MOVE;

IMPLEMENTATION

USES
    GENERAL, DRAW, CITY, SPELLS;

VAR
   STRING3 : STRING[3];
   NOMONEY : BOOLEAN;

{*******************************************************************}

PROCEDURE RESETAC (AMOUNT : SHORTINT; VAR TURNOFF : BOOLEAN);

BEGIN
     SHIELDICON (NOT TURNOFF);
     FOR INT := 1 TO PEOPLE DO
       INC (ROSTER[INT].AC, AMOUNT);
     FOR INT := 1 TO PEOPLE DO
       WRITECHARACTER (INT, FALSE);
     TURNOFF := NOT TURNOFF;

END; {OF PROCEDURE RESETAC}

{*******************************************************************}

FUNCTION GETAORAN (LETTER1 : CHAR) : STRING;

BEGIN
     IF LETTER1 IN ['A', 'E', 'I', 'O', 'U'] THEN
       GETAORAN := 'AN '
     ELSE
       GETAORAN := 'A ';

END; {OF PROCEDURE GETAORAN}

{*******************************************************************}

PROCEDURE CHECKLEVEL;

BEGIN
     IF LEV = 0 THEN
       CASE N OF
         20 : FILENAME1 := 'DSDATA.F01';
         21 : FILENAME1 := 'DSDATA.F02';
         9  : FILENAME1 := 'DSDATA.F03';
         1  : FILENAME1 := 'DSDATA.F04';
         6  : FILENAME1 := 'DSDATA.F05';
       END; {OF CASE}

END;

{*******************************************************************}

PROCEDURE GETMAZE;

TYPE
    NUMLEVEL = ARRAY[1..21, 1..21] OF LONGINT;

VAR
   NUMDATA : NUMLEVEL;
   LOAD : FILE OF NUMLEVEL;

BEGIN
     C := 0;
     PSTAIRS := FALSE;
     ASSIGN (LOAD, FILENAME1);
     RESET (LOAD);
     TOPLEV := FILESIZE (LOAD) - 1;
     IF (FILENAME1[10] = '4') THEN
       BEGIN
         IF LEV = 4 THEN
           C := RANDOM (5);
         IF LEV = 5 THEN
           C := 4;
       END;
     SEEK (LOAD, LEV+C);
     READ (LOAD, NUMDATA);
     IF IORESULT <> 0 THEN
       DISKERROR (FILENAME1, TRUE);
     CLOSE (LOAD);
     FOR J := 1 TO 21 DO
       FOR K := 1 TO 21 DO
         STR (NUMDATA[J,K], DATA[J,K]);
     BAR (345, 112, 540, 133);
     SETTEXTSTYLE (TRIPLEXFONT, 0, 3);
     SETCOLOR (LTYELLOW);
     IF LEV = 0 THEN
       OUTTEXTXY (350, 108, 'Bralka')
     ELSE
       CASE FILENAME1[10] OF
         '1' : OUTTEXTXY (350, 108, 'Perion''s Place');
         '2' : OUTTEXTXY (360, 108, 'Galt''s Home');
         '3' : OUTTEXTXY (370, 108, 'Shit Hole');
         '4' : OUTTEXTXY (355, 108, 'Tower o'' Fun');
         '5' : OUTTEXTXY (380, 108, 'The Lair');
       END;
     SETTEXTSTYLE (DEFAULTFONT, 0, 1);

END; {OF PROCEDURE GETMAZE}

{*******************************************************************}

PROCEDURE CITYSQUARE;

BEGIN
     CASE FILENAME1[10] OF
       '1' : BEGIN
               N := 19;
               E := 20;
               DIRECTION := 'N';
             END;
       '2' : BEGIN
               N := 20;
               E := 2;
               DIRECTION := 'N';
             END;
       '3' : BEGIN
               N := 9;
               E := 16;
               DIRECTION := 'E';
             END;
       '4' : BEGIN
               N := 3;
               E := 3;
               DIRECTION := 'S';
             END;
       '5' : BEGIN
               N := 9;
               E := 11;
               DIRECTION := 'S';
             END;
     END; {OF CASE}

END; {OF PROCEDURE CITYSQUARE}

{*******************************************************************}

PROCEDURE TAKESTAIRS (UP : BOOLEAN);

BEGIN
     IGNORE := TRUE;
     CLEAR;
     SETTEXTSTYLE (SMALLFONT, HORIZDIR, 6);
     SETCOLOR (LTBLUE);
     IF UP THEN
       OUTTEXTXY (210, 12, 'STAIRS UP--TAKE THEM?')
     ELSE
       OUTTEXTXY (210, 12, 'STAIRS DOWN--TAKE THEM?');
     REPEAT
       RESPONCE := UREADKEY;
     UNTIL RESPONCE IN ['Y', 'N'];
     IF RESPONCE = 'Y' THEN
       BEGIN
         OUTTEXTXY (270, 80, 'ONE MOMENT');
         IF LEV = 0 THEN
           BEGIN
             CHECKLEVEL;
             N := 1;
             E := 1;
           END;
         IF ((LEV = 1) AND (FILENAME1[10] IN ['2', '3']) AND (UP)) OR
            ((LEV = 1) AND (FILENAME1[10] IN ['1', '4', '5']) AND (NOT UP)) THEN
           CITYSQUARE;
         IF FILENAME1[10] IN ['2', '3'] THEN
           IF UP THEN
             DEC (LEV)
           ELSE
             INC (LEV)
         ELSE
           IF UP THEN
             INC (LEV)
           ELSE
             DEC (LEV);
         GETMAZE;
       END;
     SETTEXTSTYLE (DEFAULTFONT, HORIZDIR, 1);

END; {OF PROCEDURE TAKESTAIRS}

{*******************************************************************}

PROCEDURE SAVEGAME;

VAR
   SAVEPLACE : PL;
   SAVESHIELD : CHAR;

BEGIN
     CLEAR;
     SAVESHIELD := ' ';
     SETCOLOR (LTRED);
     OUTTEXTXY (190, 55, 'LAST SAVE GAME WILL BE DESTROYED.');
     OUTTEXTXY (260, 75, 'SAVE ANYWAY?');
     REPEAT
       RESPONCE := UREADKEY;
     UNTIL RESPONCE IN ['Y', 'N'];
     IF RESPONCE = 'Y' THEN
       BEGIN
         SETCOLOR (LTBLUE);
         OUTTEXTXY (230, 65, 'SAVING--PLEASE WAIT.');
         IF SHELD THEN
           BEGIN
             RESETAC (1, SHELD);
             SAVESHIELD := 'S';
           END;
         IF ARMOR THEN
           BEGIN
             RESETAC (2, ARMOR);
             SAVESHIELD := 'A';
           END;
         IF INVULN THEN
           BEGIN
             RESETAC (3, INVULN);
             SAVESHIELD := 'I';
           END;
         SAVEPLACE.ARR5[1] := LEV;
         SAVEPLACE.ARR5[2] := N;
         SAVEPLACE.ARR5[3] := E;
         SAVEPLACE.ARR5[4] := PEOPLE;
         SAVEPLACE.ARR5[5] := ORD (DIRECTION);
         SAVEPLACE.FILENAME := FILENAME1;
         REWRITE (SGPL);
         WRITE (SGPL, SAVEPLACE);
         IF IORESULT <> 0 THEN
           DISKERROR ('SAVEGAME.PLC', FALSE);
         CLOSE (SGPL);
         REWRITE (SGCH);
         WRITE (SGCH, ROSTER);
         IF IORESULT <> 0 THEN
           DISKERROR ('SAVEGAME.ROS', FALSE);
         CLOSE (SGCH);
         CASE SAVESHIELD OF
           'S' : RESETAC (-1, SHELD);
           'A' : RESETAC (-2, ARMOR);
           'I' : RESETAC (-3, INVULN);
         END; {OF CASE}
       END; {OF IF THEN}

END; {OF SAVEGAME}

{*******************************************************************}

PROCEDURE LOADGAME;

VAR
   SAVEPLACE : PL;

BEGIN
     RESET (SGCH);
     READ (SGCH, ROSTER);
     IF IORESULT <> 0 THEN
       DISKERROR ('SAVEGAME.ROS', TRUE);
     CLOSE (SGCH);
     RESET (SGPL);
     READ (SGPL, SAVEPLACE);
     IF IORESULT <> 0 THEN
       DISKERROR ('SAVEGAME.PLC', TRUE);
     CLOSE (SGPL);
     LEV := SAVEPLACE.ARR5[1];
     N := SAVEPLACE.ARR5[2];
     E := SAVEPLACE.ARR5[3];
     PEOPLE := SAVEPLACE.ARR5[4];
     DIRECTION := CHR (SAVEPLACE.ARR5[5]);
     FILENAME1 := SAVEPLACE.FILENAME;
     FOR INT := 0 TO PEOPLE DO
       WRITECHARACTER (INT, FALSE);
     GETMAZE;
     CLEAR;
     IF (LEV = 0) AND (ROOM[5] <> 'D') THEN
       VIEWAHEAD;
     MOVE;

END; {OF PROCEDURE LOADGAME}

{*******************************************************************}
{*******************************************************************}

PROCEDURE WAKEUP;

BEGIN
     IF (FIGHT) THEN
       FOR INT := 1 TO PEOPLE DO
         WITH ROSTER[INT] DO
           BEGIN
             IF SPECIAL = POISON THEN
               BEGIN
                 DEC (HPLEFT);
                 CHECKFORDEAD (INT);
               END;
             IF (SPECIAL = ASLEEP) AND (RANDOM(3) = 2) THEN
               SPECIAL := OK;
             IF RANDOM(5) > 3 THEN
               NOSPEAK := FALSE;
           END {OF WITH ROSTER[INT]}
     ELSE
       FOR INT := 1 TO PEOPLE DO
         IF ROSTER[INT].SPECIAL = ASLEEP THEN
           ROSTER[INT].SPECIAL := OK;

END; {OF PROCEDURE WAKEUP}

{*******************************************************************}

PROCEDURE SORTENCOUNTER;

VAR
   TEMPENC : GROUP;

BEGIN
     FOR I := 1 TO 3 DO
       FOR K := 1 TO 3 DO
         IF (ENCOUNTER[K].NUMBER < 1) AND (ENCOUNTER[K].EXPERIENCEPER <> 0) THEN
           BEGIN
             TEMPENC := ENCOUNTER[K];
             ENCOUNTER[K] := ENCOUNTER[K+1];
             ENCOUNTER[K+1] := TEMPENC;
             TEMP := NUMKILLED[K];
             NUMKILLED[K] := NUMKILLED[K+1];
             NUMKILLED[K+1] := TEMP;
             TEMP := HITSTOKILL[K];
             HITSTOKILL[K] := HITSTOKILL[K+1];
             HITSTOKILL[K+1] := TEMP;
           END;
     FOR I := 1 TO GROUPTOT DO
       IF ENCOUNTER[I].NUMBER < 1 THEN
         DEC (GROUPTOT);
     IF GROUPTOT < 1 THEN
       FIGHT := FALSE;

END; {OF SORTENCOUNTER}

{*******************************************************************}

FUNCTION ITEMNUMBER : INTEGER;

BEGIN
     CASE LEV OF
       1..5   : TEMP := 25;
       6..12  : TEMP := 50;
       13..16 : TEMP := 60;
       17..22 : TEMP := 70;
     ELSE
       TEMP := 79
     END; {OF CASE}
     ITEMNUMBER := RANDOM (TEMP);

END; {OF FUNCTION ITEMNUMBER}

{*******************************************************************}

PROCEDURE GETITEMS;

BEGIN
     FULL := FALSE;
     INT := RANDOM(PEOPLE)+1;
     WITH ROSTER[INT] DO
       BEGIN
         IF FINDPLACE (ROSTER[INT]) THEN
           BEGIN
             RESET (SHOPFILE);
             SEEK (SHOPFILE, ITEMNUMBER);
             READ (SHOPFILE, ITEMDATA);
             IF IORESULT <> 0 THEN
               DISKERROR ('DSDATA.F10', TRUE);
             CLOSE (SHOPFILE);
             BIGNUM := LEV*LEV*LEV*20;
             IF ITEMDATA.COST <= BIGNUM THEN
               BEGIN
                 EQUIPMENT[J] := ITEMDATA;
                 OUTTEXTXY (120, 75, NAME+' FOUND '+GETAORAN (EQUIPMENT[J].ITEM[1])+EQUIPMENT[J].ITEM+'.');
                 TDELAY (THYME);
               END;
           END; {OF IF FINDPLACE}
       END; {OF WITH ROSTER[INT]}

END; {OF PROCEDURE GETITEMS}

{*******************************************************************}

PROCEDURE GETMONEY;

BEGIN
     CLEAR;
     GOLD := 0;
     C := 0;
     FOR J := 1 TO 4 DO
       INC (GOLD, (ENCOUNTER[J].GOLDPER)*NUMKILLED[J]);
     FOR INT := 1 TO PEOPLE DO
       IF ROSTER[INT].SPECIAL IN [OK, POISON] THEN
         INC (C);
     GOLD := GOLD DIV C;
     STR (GOLD, HPNUM);
     OUTTEXTXY (120, 65, 'EACH SURVIVOR RECIEVES '+HPNUM+' IN GOLD.');
     TDELAY (THYME);
     FOR INT := 1 TO PEOPLE DO
       WITH ROSTER[INT] DO
         BEGIN
           IF SPECIAL IN [OK, POISON] THEN
             INC (MONEY, GOLD);
           IF (RANDOM(100) > 40) AND (FULL) THEN
             GETITEMS;
         END; {OF WITH ROSTER[INT]}

END; {OF PROCEDURE GETMONEY}

{*******************************************************************}

PROCEDURE OPENCHESTMENU;

BEGIN
     CLEAR;
     OUTTEXTXY (120, 35, 'YOU FIND A CHEST!');
     OUTTEXTXY (120, 45, 'YOU MAY:');
     OUTTEXTXY (120, 65, '<C>AST UNTRAP    <E>XAMINE IT   <O>PEN IT');
     OUTTEXTXY (120, 75, '<D>ISARM IT      <L>EAVE');
     REPEAT
       RESPONCE := UREADKEY;
     UNTIL RESPONCE IN ['C', 'E', 'O', 'D', 'L'];

END; {OF PROCEDURE OPENCHESTMENU}

{*******************************************************************}

PROCEDURE GETTRAPTYPE;

BEGIN
     TRAPTYPE := '         ';
     C := RANDOM(50)+ROSTER[1].LEVEL;
     IF C > 95 THEN
       C := 57;
     CASE C OF
       1..25  : TRAPTYPE := 'DART';
       26..40 : TRAPTYPE := 'KNIVES';
       41..50 : TRAPTYPE := 'POISON';
       51..55 : TRAPTYPE := 'ACID';
       56..60 : TRAPTYPE := 'ALARM';
       61..65 : TRAPTYPE := 'BLASTER';
       66..70 : TRAPTYPE := 'TELEPORTER';
       71..75 : TRAPTYPE := 'FIRE';
       76..90 : TRAPTYPE := 'MAGEBANE';
       91..95 : TRAPTYPE := 'LEVELDRAIN';
     END; {OF CASE}

END; {OF PROCEDURE GETTRAPTYPE}

{*******************************************************************}

PROCEDURE SETOFFTRAP;

BEGIN
     CLEAR;
     OUTTEXTXY (120, 55, 'OOPS! '+ROSTER[INT].NAME+' SET OF A '+TRAPTYPE+' TRAP!!');
     CASE TRAPTYPE[1] OF
       'D' : BEGIN
               INT := RANDOM(PEOPLE)+1;
               DEC (ROSTER[INT].HPLEFT, RANDOM(5)+1);
             END;
       'K' : BEGIN
               FOR INT := 1 TO 3 DO
                 DEC (ROSTER[INT].HPLEFT, RANDOM(10)+1);
             END;
       'P' : ROSTER[INT].SPECIAL := POISON;
       'A' : BEGIN
               NOMONEY := FALSE;
               IF TRAPTYPE[2] = 'C' THEN
                 OUTTEXTXY (120, 65, 'ACIDS DISOLVES ALL THE TREASURE!')
               ELSE
                 ACCOMPLISHENCOUNTER;
             END;
       'B' : FOR INT := 1 TO PEOPLE DO
               DEC (ROSTER[INT].HPLEFT, RANDOM(10)+10);
       'T' : BEGIN
               N := RANDOM(21)+1;
               E := RANDOM(21)+1;
             END;
       'F' : IF (TRAPTYPE[2] = 'I') THEN
               BEGIN
                 INT := RANDOM(PEOPLE)+1;
                 DEC (ROSTER[INT].HPLEFT, RANDOM(20)+10);
               END;
       'M' : FOR INT := 1 TO PEOPLE DO
               WITH ROSTER[INT] DO
                 IF SPELLPTLEFT > 0 THEN
                   DEC (SPELLPTLEFT, SPELLPTLEFT DIV 2);
       'L' : BEGIN
               DEC (ROSTER[INT].LEVEL);
               CHECKFORDEAD (INT);
             END;
     END; {OF CASE}
     FOR INT := 1 TO PEOPLE DO
       CHECKFORDEAD (INT);
     OPENED := TRUE;

END; {OF PROCEDURE SETOFFTRAP}

{*******************************************************************}

PROCEDURE EXAMINETRAP;

BEGIN
     CLEAR;
     OUTTEXTXY (120, 65, 'WHO WISHES TO EXAMINE THE CHEST?');
     REPEAT
       INT := GETPERSON (0, PEOPLE+1);
       IF (INT < 0) THEN
         EXIT;
       IF NOT (ROSTER[INT].SPECIAL IN [OK, POISON]) THEN
         OUTTEXTXY (120, 75, 'HE CAN''T EXAMINE THE CHEST!');
     UNTIL (INT > 0) AND (ROSTER[INT].SPECIAL IN [OK, POISON]);
     WITH ROSTER[INT] DO
       IF CLASS[4] = 'E' THEN
         IF TRAP THEN
           OUTTEXTXY (120, 75, NAME+' FIND A '+TRAPTYPE+' TRAP!')
         ELSE
           OUTTEXTXY (120, 75, NAME+' FAILS TO FIND A TRAP.')
       ELSE
         IF (RANDOM(100)+1 > 80) AND (TRAP) THEN
           OUTTEXTXY (120, 75, NAME+' FOUND A '+TRAPTYPE+' TRAP!')
         ELSE
           IF TRAP THEN
             SETOFFTRAP;
     TDELAY (THYME);

END; {OF PROCEDURE EXAMINETRAP}

{*******************************************************************}

PROCEDURE OPENCHEST;

BEGIN
     CLEAR;
     OUTTEXTXY (120, 55, 'WHO WISHES TO OPEN THE CHEST?');
     REPEAT
       INT := GETPERSON (0, PEOPLE+1);
       IF (INT < 0) THEN
         EXIT;
       IF NOT (ROSTER[INT].SPECIAL IN [OK, POISON]) THEN
         OUTTEXTXY (120, 75, 'HE CAN''T OPEN THE CHEST!');
     UNTIL (INT > 0) AND (ROSTER[INT].SPECIAL IN [OK, POISON]);
     IF (ROSTER[INT].CLASS[4] = 'E') AND (RANDOM(100) > 70) THEN
       IF TRAP THEN
         BEGIN
           OUTTEXTXY (120, 65, 'WHILE OPENING THE CHEST, '+ROSTER[INT].NAME);
           OUTTEXTXY (120, 75, 'DISCOVERS A TRAP.');
           OPENED := FALSE;
         END
       ELSE
         OPENED := TRUE
     ELSE
       IF TRAP THEN
         IF (RANDOM(100)+1) > 80 THEN
           OPENED := TRUE
         ELSE
           SETOFFTRAP
       ELSE
         OPENED := TRUE;

END; {OF PROCEDURE OPENCHEST}

{*******************************************************************}

PROCEDURE DISARMTRAP;

BEGIN
     REPEAT
       CLEAR;
       OUTTEXTXY (120, 35, 'WHO FEELS LUCKY?');
       INT := GETPERSON (0, PEOPLE+1);
       IF (INT < 0) THEN
         EXIT;
       IF NOT (ROSTER[INT].SPECIAL IN [OK, POISON]) THEN
         BEGIN
           OUTTEXTXY (120, 45, 'HE CAN''T DISARM ANYTHING!!');
           TDELAY (THYME);
         END;
     UNTIL (INT > 0) OR (ROSTER[INT].SPECIAL IN [OK, POISON]);
     OUTTEXTXY (120, 55, 'WHAT TYPE OF TRAP DO YOU THINK IT IS?');
     READLINE (DISARMING, 10, 120, 65);
     IF TRAP THEN
       IF (DISARMING = TRAPTYPE) AND (ROSTER[INT].CLASS[4] = 'E') THEN
         OPENED := TRUE
       ELSE
         IF (RANDOM(100)+1) > 80 THEN
           OPENED:= FALSE
         ELSE
           BEGIN
             SETOFFTRAP;
             TDELAY (THYME);
           END
      ELSE
        OPENED := TRUE;

END; {OF PROCEDURE DISARMTRAP}

{*******************************************************************}

PROCEDURE UNTRAP;

BEGIN
     OUTTEXTXY (120, 85, 'WHO WISHES TO CAST UNTRAP?');
     INT := GETPERSON (0, PEOPLE + 1);
     IF INT <> -10 THEN
       WITH ROSTER[INT] DO
         BEGIN
           IF (CLASS[4] = 'R') AND (SPELLLEVEL >= 2) AND
              (SPECIAL IN [OK, POISON]) THEN
             IF (ENOUGHSP (2)) AND (RANDOM(100) > (35-ABILITIES[3])) THEN
               OPENED := TRUE
             ELSE
               BEGIN
                 OUTTEXTXY (120, 95, 'ATTEMPT FAILED.');
                 TDELAY (THYME);
               END
           ELSE
             BEGIN
               OUTTEXTXY (120, 95, 'HE CAN''T CAST THAT!');
               TDELAY (THYME);
             END;
         END; {OF WITH ROSTER[INT]}

END; {OF PROCEDURE UNTRAP}

{*******************************************************************}

PROCEDURE LOCKCHEST;

BEGIN
     FULL := TRUE;
     IF RANDOM(100)+1 < 50 THEN
       BEGIN
         TRAP := TRUE;
         GETTRAPTYPE;
       END;
     REPEAT
       OPENCHESTMENU;
       CASE RESPONCE OF
         'C' : UNTRAP;
         'E' : EXAMINETRAP;
         'O' : OPENCHEST;
         'D' : DISARMTRAP;
         'L' : OPENED := TRUE;
       END; {OF CASE}
     UNTIL OPENED;
     IF RESPONCE <> 'L' THEN
       GETMONEY;

END; {OF PROCEDURE LOCKCHEST}

{*******************************************************************}

PROCEDURE TREASURE;

BEGIN
     IF NOMONEY THEN
       BEGIN
         FULL := FALSE;
         TRAP := FALSE;
         OPENED := FALSE;
         IF (RANDOM(100)+1 < 45) AND (LEV <> 0) THEN
           LOCKCHEST
         ELSE
           GETMONEY;
       END; {IF PLACE}

END; {OF PROCEDURE TREASURE}

{*******************************************************************}

PROCEDURE RESETVARIABLES;

BEGIN
     NORUN := FALSE;
     PBREATH := FALSE;
     PROTECTIONSP := FALSE;
     THYMESTOP := 0;
     NUM := 0;
     FOR INT := 0 TO PEOPLE DO
       WITH ROSTER[INT] DO
         BEGIN
           INC (AC, SPAC);
           SPAC := 0;
         END;

END; {OF PROCEDURE RESETVARIABLES}

{*******************************************************************}

PROCEDURE ENDBATTLE;

BEGIN
     WAKEUP;
     RESETVARIABLES;
     IF NUMKILLED[4] > 0 THEN
       BEGIN
         IF NOMONEY THEN
           TREASURE;
         BIGNUM := 0;
         C := 0;
         FOR K := 1 TO 4 DO
           INC (BIGNUM, (ENCOUNTER[K].EXPERIENCEPER * NUMKILLED[K]));
         FOR INT := 1 TO PEOPLE DO
           IF ROSTER[INT].SPECIAL IN [OK, POISON] THEN
             INC (C);
         BIGNUM := BIGNUM DIV C;
         CLEAR;
         STR (BIGNUM , NUMSTR);
         OUTTEXTXY (120, 55, 'EACH SURVIVOR RECIEVED '+NUMSTR+' EXPERIENCE POINTS.');
         TDELAY (THYME);
         FOR INT := 1 TO PEOPLE DO
           IF ROSTER[INT].SPECIAL IN [OK, POISON] THEN
             INC (ROSTER[INT].EXP, BIGNUM);
       END; {IF NUMKILLED > 0}

END; {OF PROCEDURE ENDBATTLE}

{*******************************************************************}

PROCEDURE SORTHELPLESS;

BEGIN
     FOR J := 1 TO PEOPLE - 1 DO
       FOR INT := 1 TO PEOPLE - 1 DO
         IF NOT (ROSTER[INT].SPECIAL IN [OK, POISON, SILENCE]) THEN
           BEGIN
             CHARACTER := ROSTER[INT];
             ROSTER[INT] := ROSTER[INT+1];
             ROSTER[INT+1] := CHARACTER;
           END;

END; {OF PROCEDURE SORTHELPLESS}

{*******************************************************************}

PROCEDURE NORMALATTACK;

BEGIN
     WITH ENCOUNTER[J] DO
       BEGIN
         CODE := RANDOM(DMG)+1;
         IF ROSTER[INT].AC < 0 THEN
           DEC (CODE, -1*ROSTER[INT].AC DIV 2);
         IF CODE <= 0 THEN
           CODE := 1;
         STR (CODE, HPNUM);
         OUTTEXTXY (120, 65, GETAORAN(NAME[1])+NAME+' HIT '+ROSTER[INT].NAME+'!!');
         OUTTEXTXY (120, 75, 'IT DID '+HPNUM+' POINTS OF DAMAGE!');
         DEC (ROSTER[INT].HPLEFT, CODE);
         CHECKFORDEAD (INT);
         TDELAY (THYME);
       END; {OF WITH ENCOUNTER[J]}

END; {OF PROCEDURE NORMALATTACK}

{*******************************************************************}

PROCEDURE MISSMESSAGE;

BEGIN
     OUTTEXTXY (120, 65, GETAORAN(ENCOUNTER[J].NAME[1])+ENCOUNTER[J].NAME+' RUSHES THE PARTY,');
     OUTTEXTXY (120, 75, 'BUT HIS ATTACK FAILS!');
     TDELAY (THYME);

END; {OF PROCEDURE MISSMESSAGE}

{*******************************************************************}

PROCEDURE POISONATTACK;

BEGIN
     WITH ROSTER[INT] DO
       IF SPECIAL IN [OK, POISON] THEN
         BEGIN
           SPECIAL := POISON;
           NORMALATTACK;
           OUTTEXTXY (120, 85, 'THE '+ENCOUNTER[J].NAME+' POISONED '+NAME+'!');
           TDELAY (THYME);
         END
       ELSE
         MISSMESSAGE;

END; {OF PROCEDURE POISONATTACK}

{*******************************************************************}

PROCEDURE SLEEPATTACK;

BEGIN
     WITH ROSTER[INT] DO
       IF SPECIAL IN [OK, POISON] THEN
         BEGIN
           OUTTEXTXY (120, 65, 'IT MUST BE NAP-TIME FOR '+NAME+'.');
           OUTTEXTXY (120, 73, GETAORAN(ENCOUNTER[J].NAME[1])+ENCOUNTER[J].NAME+' JUST PUT HIM TO SLEEP!');
           SPECIAL := ASLEEP;
           WRITECHARACTER (INT, TRUE);
           TDELAY (THYME);
         END
       ELSE
         MISSMESSAGE;

END; {OF PROCEDURE SLEEPATTACK}

{*******************************************************************}

PROCEDURE PARALYSISATTACK;

BEGIN
     WITH ROSTER[INT] DO
       IF SPECIAL IN [OK, POISON, ASLEEP] THEN
         IF RANDOM(100)+1 < (ENCOUNTER[J].HDICE-LEVEL)+50 THEN
           BEGIN
             OUTTEXTXY (120, 65, NAME+' IS PARALYZED!');
             OUTTEXTXY (120, 73, 'HE WAS HIT BY '+GETAORAN(ENCOUNTER[J].NAME[1])+ENCOUNTER[J].NAME+'.');
             SPECIAL := PARALYS;
             WRITECHARACTER (INT, TRUE);
             TDELAY (THYME);
           END
         ELSE
           BEGIN
             OUTTEXTXY (120, 65, GETAORAN(ENCOUNTER[J].NAME[1])+ENCOUNTER[J].NAME+' TRIES TO PARALYZE');
             OUTTEXTXY (120, 75, NAME+' BUT THE ATTEMPT FAILS!');
             TDELAY (THYME);
           END
       ELSE
         MISSMESSAGE;

END; {OF PROCEDURE PARALYSISATTACK}

{*******************************************************************}

PROCEDURE STONEATTACK;

BEGIN
     WITH ROSTER[INT] DO
       IF SPECIAL IN [OK, POISON, ASLEEP] THEN
         IF RANDOM(100)+1 > (ENCOUNTER[J].HDICE-LEVEL)+70 THEN
           BEGIN
             OUTTEXTXY (120, 65, NAME+' WAS TURNED TO STONE BY '+GETAORAN(ENCOUNTER[J].NAME[1])+ENCOUNTER[J].NAME+'!');
             SPECIAL := STONE;
             WRITECHARACTER (INT, TRUE);
             TDELAY (THYME);
           END
         ELSE
           BEGIN
             OUTTEXTXY (120, 65, NAME+' FEELS HIS MUSCLES BEGIN TO STIFFEN,');
             OUTTEXTXY (120, 75, 'BUT LUCKILY THE FEELING PASSES!');
             TDELAY (THYME);
           END
       ELSE
         MISSMESSAGE;

END; {OF PROCEDURE STONEATTACK}

{*******************************************************************}

PROCEDURE CRITICALHITS;

BEGIN
     WITH ROSTER[INT] DO
       IF SPECIAL IN [OK, POISON] THEN
         IF RANDOM(100)+1 < (ENCOUNTER[J].HDICE-LEVEL)+70 THEN
           BEGIN
             OUTTEXTXY (120, 65, GETAORAN(ENCOUNTER[J].NAME[1])+ENCOUNTER[J].NAME+' CRITACALLY HIT '+NAME);
             OUTTEXTXY (120, 73, 'AND KILLED HIM DEAD!');
             HPLEFT := 0;
             SPECIAL := DEAD;
             WRITECHARACTER (INT, TRUE);
             TDELAY (THYME);
           END
         ELSE
           BEGIN
             OUTTEXTXY (120, 65, NAME+' DODGES A BLOW THAT VERY NEARLY');
             OUTTEXTXY (120, 75, 'COST HIM HIS LIFE!');
             TDELAY (THYME);
           END
       ELSE
         MISSMESSAGE;

END; {OF PROCEDURE CRITICALHITS}

{*******************************************************************}

PROCEDURE STEAL;

BEGIN
     WITH ROSTER[INT] DO
       IF (SPECIAL IN [OK, POISON]) AND (RANDOM (100) < 40 ) THEN
         BEGIN
           OUTTEXTXY (120, 65, GETAORAN(ENCOUNTER[J].NAME[1])+ENCOUNTER[J].NAME+' STOLE AND ITEM FROM '+NAME);
           OUTTEXTXY (120, 73, 'THEN HE RAN AWAY!');
           TDELAY (THYME);
           IF EQUIPMENT[1].EQUIPED THEN
             EQUIP ('1');
           EQUIPMENT[1] := SCUM;
           CONDENSEEQUIPMENT (ROSTER[INT]);
           BEFORE := START;
           START := START^.NEXT;
           DISPOSE (BEFORE);
           DEC (ENCOUNTER[J].NUMBER);
         END
       ELSE
         MISSMESSAGE;
     SHOWENCOUNTER;

END; {OF PROCEDURE STEAL}

{*******************************************************************}

PROCEDURE CALLHELP;

BEGIN
     WITH ENCOUNTER[J] DO
       BEGIN
         OUTTEXTXY (120, 65, GETAORAN(ENCOUNTER[J].NAME[1])+NAME+' CALLS FOR HELP,');
         IF RANDOM (100)+1 < 45 THEN
           BEGIN
             OUTTEXTXY (120, 75, 'AND '+GETAORAN(ENCOUNTER[J].NAME[1])+NAME+' COMES TO ITS AID!');
             INC (NUMBER);
             SHOWENCOUNTER;
           END
         ELSE
           OUTTEXTXY (120, 75, 'BUT NO ONE ARRIVES!');
         TDELAY (THYME);
       END; {OF WITH ENCOUNTER[J]}

END; {OF PROCEDURE CALLHELP}

{*******************************************************************}

PROCEDURE HURTPERSON (INT, DMG : INTEGER);

BEGIN
     IF (INT = 0) AND (ROSTER[INT].NAME = '') THEN
       EXIT;
     WITH ROSTER[INT] DO
       BEGIN
         CLEAROPTIONS;
         OUTTEXTXY (120, 65, GETAORAN(ENCOUNTER[J].NAME[1])+ENCOUNTER[J].NAME+' CASTS A SPELL AT THE PARTY!');
         IF RANDOM(40)+1 < ABILITIES[3] + ABILITIES[7] THEN
           BEGIN
             T := ((RANDOM(ENCOUNTER[J].HDICE)+1)*RANDOM(DMG)+1)+1;
             IF LEVEL+ABILITIES[7] > RANDOM (50) THEN
               T := T DIV 4;
             STR (T, HPNUM);
             OUTTEXTXY (120, 75, 'IT HIT '+NAME+' FOR '+HPNUM+' POINTS OF DAMAGE!');
             DEC (HPLEFT, T);
             CHECKFORDEAD (INT);
           END
         ELSE
           OUTTEXTXY (120, 75, 'LUCKILY, IT MISSED '+NAME+'.');
         TDELAY (THYME);
     END; {OF WITH ROSTER[INT]}

END; {OF PROCEDURE HURTPERSON}

{*******************************************************************}

PROCEDURE TELEPORTAWAY;

BEGIN
     CLEAROPTIONS;
     OUTTEXTXY (120, 65, 'YOU FEEL YOURSELVES BEING CAST AWAY');
     OUTTEXTXY (120, 75, 'THROUGH SPACE AND TIME . . .');
     N := RANDOM(21)+1;
     E := RANDOM(21)+1;
     FIGHT := FALSE;
     GROUPTOT := 0;
     FOR K := 1 TO 4 DO
       NUMKILLED[K] := 0;
     WHILE START^.NEXT <> NIL DO
       BEGIN
         BEFORE := START;
         START := START^.NEXT;
         DISPOSE (BEFORE);
       END;
     TDELAY (THYME);

END; {OF PROCEDURE TELEPORTAWAY}

{*******************************************************************}

PROCEDURE LEVELDRAIN (INT : INTEGER);

BEGIN
     WITH ROSTER[INT] DO
       BEGIN
         IF (INT = 0) AND (NAME = '') THEN
           INT := 1;
         OUTTEXTXY (120, 65, GETAORAN(ENCOUNTER[J].NAME[1])+ENCOUNTER[J].NAME+' DRAINS A LEVEL FROM '+NAME+'!');
         DEC (LEVEL);
         TDELAY (THYME);
       END; {OF WITH ROSTER[INT]}

END; {OF PROCEDURE LEVELDRAIN}

{*******************************************************************}

PROCEDURE CAUSESP (INT : INTEGER; WHATSWRONG : SPEC);

BEGIN
     IF (INT = 0) AND (ROSTER[INT].NAME = '') THEN
       INT := 1;
     WITH ROSTER[INT] DO
       BEGIN
         CLEAROPTIONS;
         IF ENCOUNTER[J].HDICE > LEVEL THEN
           BEGIN
             IF WHATSWRONG = SILENCE THEN
               OUTTEXTXY (120, 65, NAME+' HAS BEEN SILENCED!')
             ELSE
               OUTTEXTXY (120, 65, NAME+' WAS HIT BY A SPELL!');
             SPECIAL := WHATSWRONG;
             WRITECHARACTER (INT, TRUE);
           END
         ELSE
           BEGIN
             OUTTEXTXY (120, 65, GETAORAN(ENCOUNTER[J].NAME[1])+ENCOUNTER[J].NAME+' CAST A SPELL AT '+NAME);
             OUTTEXTXY (120, 75, 'BUT '+NAME+' RESISTED THE AFFECTS!');
           END;
         TDELAY (THYME);
       END; {OF WITH ROSTER[INT]}

END; {OF PROCEDURE CAUSESP}

{*******************************************************************}

PROCEDURE PARTYPROTECTED;

BEGIN
     CLEAROPTIONS;
     OUTTEXTXY (120, 65, GETAORAN(ENCOUNTER[J].NAME[1])+ENCOUNTER[J].NAME+' TRIES TO CAST A SPELL,');
     OUTTEXTXY (120, 75, 'BUT IT FAILS TO AFFECT THE PARTY!');
     TDELAY (THYME);

END; {OF PROCEDURE PARTYPROTECTED}

{*******************************************************************}

PROCEDURE MONSTERSILENCED;

BEGIN
     CLEAROPTIONS;
     OUTTEXTXY (120, 65, GETAORAN(ENCOUNTER[J].NAME[1])+ENCOUNTER[J].NAME+' TRIES TO CAST A SPELL,');
     OUTTEXTXY (120, 75, 'BUT HE''S SILENCED!');
     TDELAY (THYME);

END; {OF PROCEDURE MONSTERSILENCED}

{*******************************************************************}

PROCEDURE MSPELLS;

BEGIN
     SETCOLOR (LTRED);
     IF NOT NOSPEAK THEN
       BEGIN
         T := RANDOM(ENCOUNTER[J].HDICE)+1;
         IF T > 18 THEN
           T := RANDOM(18)+1;
         IF NOT PROTECTIONSP THEN
           CASE T OF
             1, 2   : HURTPERSON (RANDOM(PEOPLE+1), 3);
             3, 4   : FOR INT := 0 TO PEOPLE DO
                        HURTPERSON (INT, 3);
             5, 6   : FOR INT := 0 TO PEOPLE DO
                        HURTPERSON (INT, 5);
             7, 8   : FOR INT := 0 TO PEOPLE DO
                        HURTPERSON (INT, 10);
             9, 10,
             11     : FOR INT := 0 TO PEOPLE DO
                        HURTPERSON (INT, 15);
             12     : TELEPORTAWAY;
             13, 14 : LEVELDRAIN (RANDOM(PEOPLE+1));
             15, 16 : CAUSESP (RANDOM(PEOPLE+1), DEAD);
             17, 18 : BEGIN
                        IF T < 0 THEN
                          T := 0;
                        DEC (THYMESTOP, RANDOM(2)+1);
                        OUTTEXTXY (120, 65, GETAORAN(ENCOUNTER[J].NAME[1])+ENCOUNTER[J].NAME+' CASTS A TIME STOP SPELL!');
                        OUTTEXTXY (120, 75, 'TIME HAS COME TO A STANDSTILL AROUND YOU!');
                        TDELAY (THYME);
                      END;
           END {OF CASE}
         ELSE
           PARTYPROTECTED;
       END
     ELSE
       MONSTERSILENCED;

END; {OF PROCEDURE MSPELLS}

{*******************************************************************}

PROCEDURE CSPELLS;

BEGIN
     SETCOLOR (LTYELLOW);
     WITH ENCOUNTER[J] DO
       IF NOT NOSPEAK THEN
         BEGIN
           T := RANDOM(HDICE)+1;
           IF T > 16 THEN
             T := RANDOM(16)+1;
           IF NOT PROTECTIONSP THEN
             CASE T OF
               1, 2    : HURTPERSON (RANDOM(PEOPLE+1), 2);
               3, 4    : HURTPERSON (RANDOM(PEOPLE+1), 5);
               5, 6    : HURTPERSON (RANDOM(PEOPLE+1), 10);
               7, 8    : FOR INT := 0 TO PEOPLE DO
                           CAUSESP (INT, SILENCE);
               9, 10   : CAUSESP (RANDOM(PEOPLE+1), PARALYS);
               11, 12  : CAUSESP (RANDOM(PEOPLE+1), STONE);
               13, 14  : FOR INT := 0 TO PEOPLE DO
                           HURTPERSON (INT, 9);
               15, 16  : CAUSESP (RANDOM(PEOPLE+1), DEAD);
             END {OF CASE}
           ELSE
             PARTYPROTECTED;
         END
       ELSE
         MONSTERSILENCED;

END; {OF PROCEDURE CSPELLS}

{*******************************************************************}

PROCEDURE BREATH;

BEGIN
     FULL := FALSE;
     INT := 1;
     L := 1;
     OUTTEXTXY (120, 65, GETAORAN(ENCOUNTER[J].NAME[1])+ENCOUNTER[J].NAME+' BREATHES AT THE PARTY.');
     REPEAT
       REPEAT
         IF (ROSTER[INT].EQUIPMENT[L].WHATTYPE = 'R') AND (ROSTER[INT].EQUIPMENT[L].ITEM[4] = 'B') THEN
           BEGIN
             OUTTEXTXY (120, 75, 'BUT THE PARTY IS PROTECTED!!');
             EXIT;
           END;
         INC (L);
       UNTIL L = 8;
       INC (INT);
     UNTIL INT = PEOPLE;
     FOR INT := 1 TO PEOPLE DO
       WITH ROSTER[INT] DO
         BEGIN
           CLEAROPTIONS;
           IF 16 > RANDOM(ABILITIES[7])+(LEVEL-ENCOUNTER[J].HDICE) THEN
             BEGIN
               GOLD := RANDOM(ENCOUNTER[J].DMG)+1;
               STR (GOLD, HPNUM);
               OUTTEXTXY (120, 75, 'IT HIT '+NAME+' FOR '+HPNUM+' POINTS DAMAGE!');
               DEC (HPLEFT, GOLD);
               CHECKFORDEAD (INT);
             END
           ELSE
             OUTTEXTXY (120, 75, NAME+' RESISTS THE AFFECTS.');
           TDELAY (THYME);
         END; {OF WITH ROSTER[INT]}

END; {OF PROCEDURE BREATH}

{*******************************************************************}

PROCEDURE SPECIALATTACKS;

BEGIN
     CLEAROPTIONS;
     C := RANDOM(5)+1;
     SETCOLOR (LTGREEN);
     CASE ENCOUNTER[J].SPECIALATT[C] OF
       1  : IF J < 3 THEN
              NORMALATTACK;
       2  : IF J < 3 THEN
              POISONATTACK;
       3  : SLEEPATTACK;
       4  : PARALYSISATTACK;
       5  : MSPELLS;
       6  : CSPELLS;
       7  : STONEATTACK;
       8  : STEAL;
       9  : IF J < 3 THEN
              CRITICALHITS;
       10 : IF J < 3 THEN
              LEVELDRAIN (INT);
       11 : CALLHELP;
       12 : BREATH;
     END; {OF CASE}

END; {OF PROCEDURE SPECIALATTACKS}

{*******************************************************************}

PROCEDURE PLACE;

BEGIN
     IF FIND^.RANK >= START^.RANK THEN
       BEGIN
         FIND^.NEXT := START;
         START := FIND;
       END
     ELSE
       BEGIN
         PTR := START;
         WHILE (PTR^.RANK > FIND^.RANK) AND (PTR^.NEXT <> NIL) DO
           BEGIN
             BEFORE := PTR;
             PTR := PTR^.NEXT;
           END;
         IF PTR^.RANK > FIND^.RANK THEN
           BEGIN
             FIND^.NEXT := NIL;
             LAST := FIND;
             PTR^.NEXT := FIND;
           END
         ELSE
           BEGIN
             FIND^.NEXT := PTR;
             BEFORE^.NEXT := FIND;
           END;
        END;

END; {OF PROCEDURE PLACE}

{*******************************************************************}

PROCEDURE PLACEPARTY;

BEGIN
     NEW (START);
     PTR := START;
     PTR^.GROUP := 5;
     PTR^.NUMBER := 1;
     WITH ROSTER[1] DO
       PTR^.RANK := ((ABILITIES[4]+ABILITIES[7]) DIV 2)*(RANDOM(9)+LEVEL);
     PTR^.NEXT := NIL;
     LAST := PTR;
     FOR INT := 2 TO PEOPLE DO
       WITH ROSTER[INT] DO
         BEGIN
           NEW (FIND);
           FIND^.GROUP := 5;
           FIND^.NUMBER := INT;
           FIND^.RANK := ((ABILITIES[4]+ABILITIES[7]) DIV 2)*(RANDOM(9)+LEVEL);
           PLACE;
         END; {OF WITH ROSTER[INT]}
     WITH ROSTER[0] DO
       IF NAME <> '' THEN
         BEGIN
           NEW (FIND);
           FIND^.GROUP := 5;
           FIND^.NUMBER := 0;
           FIND^.RANK := ((ABILITIES[4]+ABILITIES[7]) DIV 2)*(RANDOM(9)+LEVEL);
           PLACE;
           IF SPECIAL IN [OK, POISON] THEN
             STATUS := 'FIGHT1';
           WRITECHARACTER (0, TRUE);
         END;

END; {OF PROCEDURE PLACEPARTY}

{*******************************************************************}

PROCEDURE PLACEMONSTER;

BEGIN
     WITH ENCOUNTER[C] DO
       FOR J := 1 TO NUMBER DO
         BEGIN
           NEW (FIND);
           FIND^.GROUP := C;
           FIND^.NUMBER := J;
           FIND^.RANK := (30-THACO)*(RANDOM(9)+(HDICE DIV 2));
           PLACE;
         END;

END; {OF PLACEMONSTER}

{*******************************************************************}

FUNCTION CHECKFORHIT (THACO, AC, LEVEL : INTEGER) : BOOLEAN;

BEGIN
     IF ROSTER[INT].STATUS[1] = 'D' THEN
       DEC (AC);
     IF ((RANDOM(20)+1) > (THACO - AC)) OR (RANDOM(100) < 20+LEVEL) THEN
       CHECKFORHIT := TRUE
     ELSE
       CHECKFORHIT := FALSE;

END; {OF FUNCTION CHECKFORHIT}

{*******************************************************************}

FUNCTION PARTYNOTDEAD : BOOLEAN;

BEGIN
     T := 0;
     FOR I := 1 TO PEOPLE DO
       IF NOT (ROSTER[I].SPECIAL IN [OK, POISON]) THEN
         INC (T);
     IF T <> PEOPLE THEN
       PARTYNOTDEAD := TRUE
     ELSE
       PARTYNOTDEAD := FALSE;

END; {OF FUNCTION PARTYNOTDEAD}

{*******************************************************************}

PROCEDURE GETMONSTERS;

BEGIN
     FOR J := 1 TO 4 DO
       WITH ENCOUNTER[J] DO
         BEGIN
             NAME := '';
             NUMBER := 0;
             EXPERIENCEPER := 0;
             HITSTOKILL := 0;
         END; {OF WITH ENCOUNTER[J]}
     IF LEV = 0 THEN
       GROUPTOT := RANDOM(2)+1
     ELSE
       CASE (RANDOM(50)+1) OF
         1..15  : GROUPTOT := 1;
         16..42 : GROUPTOT := 2;
         43..48 : GROUPTOT := 3;
         49..50 : GROUPTOT := 4;
       END; {OF CASE}
     J := 0;
     RESET (MONSDATA);
     REPEAT
       INC (J);
       C := RANDOM(7)+1;
       IF C = 7 THEN
         INC (C, RANDOM(6));
       IF RANDOM (100) < 50 THEN
         C := -1*C;
       IF LEV <> 0 THEN
         CASE FILENAME1[10] OF
           '1' : INC (C, (LEV*12)-6);
           '2' : INC (C, ((LEV+6)*12)-6);
           '3' : INC (C, ((LEV+13)*12)-6);
           '4' : INC (C, ((LEV+17)*12)-6);
           '5' : INC (C, ((LEV+22)*12)-6);
         END; {OF CASE}
       IF C < 0 THEN
         C := 0;
       IF C > 359 THEN
         C := 359;
       SEEK (MONSDATA, C);
       READ (MONSDATA, ENCOUNTER[J]);
       IF IORESULT <> 0 THEN
         DISKERROR ('DSDATA.F12', TRUE);
       WITH ENCOUNTER[J] DO
         IF (LEV > 0) AND (GROUPTOT < 3) THEN
           NUMBER := RANDOM(NUMBER)+1
         ELSE
           NUMBER := RANDOM(4)+1;
      UNTIL J = GROUPTOT;
      CLOSE (MONSDATA);

END; {OF PROCEDURE GETMONSTERS}

{*******************************************************************}

PROCEDURE SHOWENCOUNTER;

BEGIN
     SETCOLOR (DKYELLOW);
     FOR I := 1 TO 4 DO
       WITH ENCOUNTER[I] DO
         IF NUMBER <> 0 THEN
           BEGIN
             STR (NUMBER, STRING3);
             IF NUMBER > 1 THEN
               OUTNAME := NAME+'S'
             ELSE
               OUTNAME := NAME;
             STR (I, STRINGONE);
             CLEARMONSTERROW (I);
             OUTTEXTXY (120, 10 + I*8, STRINGONE+') '+STRING3+' '+OUTNAME);
           END
         ELSE
           CLEARMONSTERROW(I);

END; {OF PROCEDURE SHOWENCOUNT}

{*******************************************************************}

PROCEDURE RUNNING;

BEGIN
     FOR SINT := 0 TO PEOPLE DO
       BEGIN
         ROSTER[SINT].STATUS := 'WIMP!!!';
         WRITECHARACTER (SINT, TRUE);
       END;
     IF (LEV <> 0) AND (RANDOM(100) < 20) THEN
       BEGIN
         N := RANDOM(21);
         E := RANDOM(21);
       END
     ELSE
       IF RANDOM (100) > 15 THEN
         BEGIN
           GROUPTOT := 0;
           FOR L := 1 TO 2 DO
             ENCOUNTER[L].NUMBER := 0;
         END;

END; {OF PROCEDURE RUNNING}

{*******************************************************************}

PROCEDURE FIGHTING;

BEGIN
     WITH ROSTER[INT] DO
       BEGIN
         IF GROUPTOT > 1 THEN
           BEGIN
             CLEAROPTIONS;
             OUTTEXTXY (120, 65, 'WHICH GROUP?');
             REPEAT
               ATTGROUP := GETPERSON (0, GROUPTOT + 1);
             UNTIL (ATTGROUP > 0) AND (ATTGROUP < 3);
           END
         ELSE
           ATTGROUP := 1;
         IF GROUPTOT > 1 THEN
           STATUS := 'FIGHT'+RESPONCE
         ELSE
           STATUS := 'FIGHT1';
       END; {OF WITH ROSTER[INT]}

END;

{*******************************************************************}

PROCEDURE PARTYATTACKS;

BEGIN
     REPEAT
       RESPONCE := ' ';
       HPNUM := '';
       PSEUDONYM := '';
       IF RANDOM (100) < 25 THEN
         NORUN := TRUE;
       FOR INT := 1 TO PEOPLE DO
         WITH ROSTER[INT] DO
           IF SPECIAL IN [OK, POISON] THEN
             BEGIN
               CLEAROPTIONS;
               SETCOLOR (DKRED);
               OUTTEXTXY (120, 65, NAME);
               OUTTEXTXY (120, 75, 'HAS THESE OPTIONS.');
               IF INT < 4 THEN
                 PSEUDONYM := '<F>IGHT  '
               ELSE
                 PSEUDONYM := '';
               IF NOT NORUN THEN
                 HPNUM := '<R>UN';
               OUTTEXTXY (120, 85, PSEUDONYM+'<D>EFEND  '+HPNUM);
               OUTTEXTXY (120, 95, '<U>SE');
               IF SPELLLEVEL > 0 THEN
                 OUTTEXTXY (191, 95, '<C>AST');
               IF CLASS[4] = 'R' THEN
                 OUTTEXTXY (271, 95, '<T>URN');
               REPEAT
                 RESPONCE := UREADKEY;
                 IF RESPONCE = 'U' THEN
                   BEGIN
                     RESPONCE := 'Q';
                     FOR J := 1 TO 8 DO
                       IF EQUIPMENT[J].USE = 0 THEN
                         RESPONCE := 'U';
                   END;
               UNTIL ((SPELLLEVEL > 0) AND (RESPONCE = 'C')) OR
                     ((CLASS[4] = 'R') AND (RESPONCE = 'T')) OR
                     ((RESPONCE = 'R') AND (NOT NORUN)) OR
                     ((RESPONCE = 'F') AND (INT < 4)) OR
                     (RESPONCE IN ['D', 'U']);
               CASE RESPONCE OF
                 'F' : FIGHTING;
                 'D' : STATUS := 'DEFEND';
                 'U' : STATUS := 'USING';
                 'C' : STATUS := 'CASTING';
                 'T' : STATUS := 'TURNING';
                 'R' : IF NOT NORUN THEN
                         BEGIN
                           RUNNING;
                           EXIT;
                         END;
               END; {OF CASE}
               WRITECHARACTER (INT, TRUE);
            END; {OF IF THEN}
       CLEAROPTIONS;
       SETCOLOR (LTRED);
       OUTTEXTXY (120, 75, 'KEEP THESE OPTIONS?');
       REPEAT
         RESPONCE := UREADKEY;
       UNTIL RESPONCE IN ['Y', 'N'];
       IF RESPONCE = 'N' THEN
         FOR INT := 1 TO PEOPLE DO
           WRITECHARACTER (INT, FALSE);
     UNTIL RESPONCE = 'Y';

END; {OF PROCEDURE PARTYATTACKS}

{*******************************************************************}

PROCEDURE KILLMONSTER;

BEGIN
     SETCOLOR (LTRED);
     WITH ROSTER[INT] DO
       BEGIN
         OUTTEXTXY (120, 75, 'THE '+ENCOUNTER[ATTGROUP].NAME+' DIES IN A FIT OF AGONY!');
         TDELAY (THYME);
         DEC (ENCOUNTER[ATTGROUP].NUMBER);
         INC (NUMKILLED[ATTGROUP]);
         FINDMONSTER;
         BEFORE^.NEXT := PTR;
         DISPOSE (FIND);
         SHOWENCOUNTER;
       END; {OF WITH ROSTER[INT]}

END; {OF PROCEDURE KILLMONSTER}

{*******************************************************************}

PROCEDURE HITMONST;

BEGIN
     SETCOLOR (DKRED);
     WITH ROSTER[INT] DO
       BEGIN
         T := 0;
         IF I <> 0 THEN
           FOR C := 1 TO NUMATTACKS DO
             INC (T, (RANDOM(EQUIPMENT[J].DMG)+1)+DAMAGE)
         ELSE
           T := (RANDOM(DAMAGE)+1)*NUMATTACKS;
         STR (T, HPNUM);
         OUTTEXTXY (120, 65, NAME+' DID '+HPNUM+' DAMAGE!');
         TDELAY (THYME);
         IF T >= ((RANDOM (ENCOUNTER[ATTGROUP].HDICE*8) DIV 2)+(ENCOUNTER[ATTGROUP].HDICE DIV 2))  THEN
           KILLMONSTER
         ELSE
           BEGIN
             DEC (HITSTOKILL[ATTGROUP]);
             IF HITSTOKILL[ATTGROUP] = 0 THEN
               BEGIN
                 KILLMONSTER;
                 HITSTOKILL[ATTGROUP] := ENCOUNTER[ATTGROUP].HITSTOKILL;
               END;
           END;
     END; {OF WITH ROSTER[INT]}

END; {OF PROCEDURE HITMONST}

{*******************************************************************}

PROCEDURE ATTACK;

BEGIN
     I := 0;
     SETCOLOR (LTGREEN);
     WITH ENCOUNTER[ROSTER[INT].ATTGROUP] DO
       BEGIN
         FOR J := 1 TO 8 DO
           IF (ROSTER[INT].EQUIPMENT[J].EQUIPED) AND
              (ROSTER[INT].EQUIPMENT[J].WHATTYPE IN ['T', 'O']) THEN
             BEGIN
               INC (I);
               IF NUMBER <> 0 THEN
                 BEGIN
                   CLEAROPTIONS;
                   IF CHECKFORHIT (ROSTER[INT].THACO, AC, HDICE) THEN
                     HITMONST
                   ELSE
                     BEGIN
                       OUTTEXTXY (120, 65, ROSTER[INT].NAME+' ATTACKS '+GETAORAN(NAME[1])+NAME+',');
                       OUTTEXTXY (120, 75, 'BUT HIS ATTACK FAILED!');
                       TDELAY (THYME);
                     END;
                 END;
             END;
         IF I = 0 THEN
           IF (NUMBER <> 0) AND (ROSTER[INT].NAME <> '') THEN
             BEGIN
               CLEAROPTIONS;
               IF CHECKFORHIT (ROSTER[INT].THACO, AC, HDICE) THEN
                 HITMONST
               ELSE
                 BEGIN
                   OUTTEXTXY (120, 65, ROSTER[INT].NAME+' TRIES TO ATTACK '+GETAORAN(NAME[1])+NAME);
                   OUTTEXTXY (120, 75, 'BUT THE FIEND DEFTLY DODGES HIS ATTACK!');
                   TDELAY (THYME);
                 END;
             END;
       END; {OF WITH ENCOUNTER[ROSTER[INT].ATTGROUP]}

END; {OF PROCEDURE ATTACK}

{*******************************************************************}

PROCEDURE PARTYFIGHT;

BEGIN
     IF (FIGHT) AND (ROSTER[INT].SPECIAL IN [OK, POISON]) THEN
       CASE ROSTER[INT].STATUS[1] OF
         'F' : ATTACK;
         'D' :; {DO NOTHING HERE}
         'U' : USE;
         'C' : IF FIGHT THEN
                 BEGIN
                   CAST;
                   SHOWENCOUNTER;
                 END;
         'T' : AGROUP (19, 2, 'U', 0);
       END; {OF CASE}
     FIGHT := FALSE;
     IF ROSTER[INT].STATUS[1] <> 'W' THEN
       FOR L := 1 TO GROUPTOT+1 DO
         IF ENCOUNTER[L].NUMBER > 0 THEN
           FIGHT := TRUE;
     BEFORE := START;
     WHILE BEFORE <> NIL DO
       BEGIN
         IF BEFORE^.GROUP < 0 THEN
           BEFORE^.GROUP := -1*BEFORE^.GROUP;
         BEFORE := BEFORE^.NEXT;
       END;

END; {OF PROCEDURE PARTYFIGHT}

{*******************************************************************}

PROCEDURE MONSTFIGHT;

BEGIN
     INT := RANDOM(4);
     IF (INT > PEOPLE) OR ((INT = 0) AND (ROSTER[INT].NAME = '')) OR
        (ROSTER[INT].SPECIAL IN [DEAD, STONE, PARALYS]) THEN
       FOR TEMP := 3 DOWNTO 1 DO
         IF NOT (ROSTER[TEMP].SPECIAL IN [DEAD, STONE, PARALYS]) THEN
           INT := TEMP;
     WITH ROSTER[INT] DO
       IF CHECKFORHIT (ENCOUNTER[J].THACO, AC, LEVEL) THEN
         BEGIN
           SPECIALATTACKS;
           IF (SPECIAL IN [OK, POISON]) THEN
             WRITECHARACTER (INT, TRUE)
           ELSE
             WRITECHARACTER (INT, FALSE);
         END
       ELSE
         IF J < 3 THEN
           BEGIN
             CLEAROPTIONS;
             MISSMESSAGE;
           END;

END; {OF PROCEDURE MONSTFIGHT}

{*******************************************************************}

PROCEDURE ACTUALLYFIGHT;

BEGIN
     REPEAT
       IF THYMESTOP <> 0 THEN
         BEGIN
           IF (THYMESTOP > 0) AND (START^.GROUP <> 5) THEN
             PLACEATEND;
           IF (THYMESTOP < 0) AND (START^.GROUP = 5) THEN
             BEGIN
               BEFORE := START;
               START := BEFORE^.NEXT;
               DISPOSE (BEFORE);
             END;
         END;
       IF PARTYNOTDEAD THEN
         IF (START^.GROUP = 5) AND (THYMESTOP >= 0) THEN
           BEGIN
             INT := START^.NUMBER;
             PARTYFIGHT;
             BEFORE := START;
             START := START^.NEXT;
             DISPOSE (BEFORE);
           END
         ELSE
           IF (START^.NUMBER <> 0) AND (THYMESTOP <= 0) THEN
             BEGIN
               J := START^.GROUP;
               MONSTFIGHT;
               CHECK := TRUE;
               BEFORE := START;
               PLACEATEND;
             END
           ELSE
       ELSE
         BEGIN
           CLEAR;
           SETCOLOR (LTRED);
           OUTTEXTXY (150, 55, 'YOU HAVE BEEN RIPPED APART BY THE MONSTERS.');
           TDELAY (THYME);
           OUTTEXTXY (280, 65, 'TOO BAD.');
           TDELAY (THYME);
           SETCOLOR (LTBLUE);
           OUTTEXTXY (180, 95, 'PRESS SPACE BAR TO CONTINUE . . .');
           REPEAT
             RESPONCE := UREADKEY;
           UNTIL RESPONCE = ' ';

           HALT (0);
         END;
     UNTIL ((START^.NUMBER = -1) OR (START = NIL)) AND (PARTYNOTDEAD);
     IF THYMESTOP <> 0 THEN
       IF THYMESTOP > 0 THEN
         DEC (THYMESTOP)
       ELSE
         INC (THYMESTOP);

END; {OF PROCEDURE ACTUALLYFIGHT}

{*******************************************************************}

PROCEDURE BEGINENCOUNTER;

BEGIN
     CLEAR;
     FIGHT := TRUE;
     FOR J := 1 TO 4 DO
       BEGIN
         NUMKILLED[J] := 0;
         HITSTOKILL[J] := ENCOUNTER[J].HITSTOKILL;
       END;
     REPEAT
       SHOWENCOUNTER;
       PARTYATTACKS;
       PLACEPARTY;
       FOR C := 1 TO GROUPTOT DO
         PLACEMONSTER;
       ACTUALLYFIGHT;
       WAKEUP;
       SORTHELPLESS;
       FOR INT := 0 TO PEOPLE DO
         WRITECHARACTER (INT, FALSE);
       SORTENCOUNTER;
     UNTIL NOT FIGHT;
     IF GROUPTOT = 0 THEN
       ENDBATTLE;
     SORTHELPLESS;
     FOR INT := 0 TO PEOPLE DO
       WRITECHARACTER (INT, FALSE);
     CLEAR;

END; {OF BEGINENCOUNTER}

{*******************************************************************}

PROCEDURE ACCOMPLISHENCOUNTER;

BEGIN
     SETTEXTSTYLE (SMALLFONT, HORIZDIR, 5);
     SETCOLOR (LTGREEN);
     OUTTEXTXY (270, 10, 'AN ENCOUNTER!!');
     SETTEXTSTYLE (DEFAULTFONT, HORIZDIR, 1);
     SETCOLOR (DKYELLOW);
     TDELAY (THYME);
     GETMONSTERS;
     BEGINENCOUNTER;

END; {OF ACCOMPLISHENCOUNTER}

{*******************************************************************}
{*******************************************************************}

PROCEDURE CHECKCOUNT;

BEGIN
     IF COUNT MOD 123 = 0 THEN
       IF SHELD THEN
         RESETAC (1, SHELD);
     IF (COUNT MOD 175 = 0) AND (LIGHTSP) THEN
       BEGIN
         LIGHTSP := FALSE;
         LIGHTICON (FALSE);
       END;
     IF COUNT MOD 216 = 0 THEN
       BEGIN
         COMPAS := FALSE;
         COMPASSICON (FALSE);
         REPELL := FALSE;
       END;
     IF COUNT MOD 298 = 0 THEN
       BEGIN
         FDOOR := FALSE;
         DOORICON (FALSE);
       END;
     IF COUNT MOD 314 = 0 THEN
       IF ARMOR THEN
         RESETAC (2, ARMOR);
     IF (COUNT MOD 454 = 0) AND (LGCOMPASS) THEN
       BEGIN
         LGCOMPASS := FALSE;
         COMPASSICON (FALSE);
       END;
     IF LEV = 0 THEN
       BEGIN
         IF LGLIGHTSP OR LIGHTSP THEN
            LIGHTICON (FALSE);
         LGLIGHTSP := FALSE;
         LIGHTSP := FALSE;
         IF INVULN THEN
           RESETAC (3, INVULN);
       END;
     FOR INT := 0 TO PEOPLE DO
       WITH ROSTER[INT] DO
         IF SPECIAL = POISON THEN
           IF RANDOM(100) + 1 > 85 THEN
             BEGIN
               DEC (HPLEFT, RANDOM(3) + 1);
               CHECKFORDEAD (INT);
             END;

END; {OF PROCEDURE CHECKCOUNT}

{*******************************************************************}

FUNCTION CHECKHITWALL : BOOLEAN;

BEGIN
     BEGIN
       CHECKHITWALL := FALSE;
       IF NOT PASS THEN
         ROOM := DATA[N,E];
       CASE DIRECTION OF
         'N' : IF ROOM[2] = '2' THEN
                 CHECKHITWALL := TRUE;
         'S' : IF ROOM[4] = '2' THEN
                 CHECKHITWALL := TRUE;
         'E' : IF ROOM[3] = '2' THEN
                 CHECKHITWALL := TRUE;
         'W' : IF ROOM[1] = '2' THEN
                 CHECKHITWALL := TRUE;
       END; {OF CASE}
     END;

END; {OF PROCEDURE CHECKHITWALL}

{*******************************************************************}

PROCEDURE HITWALL;

BEGIN
     SETTEXTSTYLE (TRIPLEXFONT, HORIZDIR, 1);
     SETUSERCHARSIZE (3, 4, 9, 10);
     SETCOLOR (LTYELLOW);
     IF (((LIGHTSP) OR (LGLIGHTSP)) AND (ROOM[6] <> '4')) OR (LEV = 0) THEN
       OUTTEXTXY (150, 40, 'BOINK ! ! -- THIS IS A WALL !')
     ELSE
       OUTTEXTXY (170, 40, 'YOU STUMBLE INTO A WALL !');
     SETTEXTSTYLE (DEFAULTFONT, HORIZDIR, 1);
     TDELAY (THYME DIV 4);

END; {OF PROCEDURE HITWALL}

{*******************************************************************}

PROCEDURE MOVEFORWARD;

BEGIN
     IF (NOT CHECKHITWALL) OR (PASS) THEN
       BEGIN
         IGNORE := FALSE;
         PASS := FALSE;
         CASE DIRECTION OF
           'N' : DEC (N);
           'S' : INC (N);
           'E' : INC (E);
           'W' : DEC (E);
         END; {OF CASE}
         WRAPAROUND (N);
         WRAPAROUND (E);
       END
     ELSE
       HITWALL;

END; {OF PROCEDURE MOVEFORWARD}

{*******************************************************************}

PROCEDURE TURNAROUND;

BEGIN
     CASE DIRECTION OF
       'N' : DIRECTION := 'S';
       'S' : DIRECTION := 'N';
       'E' : DIRECTION := 'W';
       'W' : DIRECTION := 'E';
     END; {OF CASE}

END; {OF PROCEDURE TURNAROUND}

{********************************************************************}

PROCEDURE TURNRIGHT;

BEGIN
     CASE DIRECTION OF
       'N' : DIRECTION := 'E';
       'S' : DIRECTION := 'W';
       'E' : DIRECTION := 'S';
       'W' : DIRECTION := 'N';
     END; {OF CASE}

END; {OF PROCEDURE TURNRIGHT}

{*******************************************************************}

PROCEDURE TURNLEFT;

BEGIN
     CASE DIRECTION OF
       'N' : DIRECTION := 'W';
       'S' : DIRECTION := 'E';
       'E' : DIRECTION := 'N';
       'W' : DIRECTION := 'S';
     END; {OF CASE}

END; {OF PROCEDURE TURNLEFT}

{********************************************************************}

FUNCTION RANDENCOUNTER : BOOLEAN;

BEGIN
     RANDENCOUNTER := FALSE;
     VAL (ROOM[9], C, CODE);
     IF ROOM[6] = '4' THEN
       C := 6;
     CASE C OF
       1 : C := 300;
       2 : C := 60;
       3 : C := 50;
       4 : C := 45;
       5 : C := 40;
       6 : C := 35;
       7 : C := 30;
       8 : C := 25;
       9 : C := 10;
     END;
     IF (RANDOM(1000)+1) < C THEN
       RANDENCOUNTER := TRUE;

END; {OF PROCEDURE RANDENCOUNTER}

{********************************************************************}

PROCEDURE TIMSMARK;

BEGIN
     CLEAR;
     SETTEXTSTYLE (SCRIPTFONT, HORIZDIR, 6);
     SETCOLOR (LTBLUE);
     OUTTEXTXY (175, -15, 'C');
     SETCOLOR (DKYELLOW);
     OUTTEXTXY (175+TEXTWIDTH('C'), -15, 'o');
     SETCOLOR (LTCYAN);
     OUTTEXTXY (175+TEXTWIDTH('Co'), -15, 'l');
     SETCOLOR (LTGREEN);
     OUTTEXTXY (175+TEXTWIDTH('Col'), -15, 'o');
     SETCOLOR (DKMAGENTA);
     OUTTEXTXY (175+TEXTWIDTH('Colo'), -15, 'r');
     SETCOLOR (LTYELLOW);
     OUTTEXTXY (175+TEXTWIDTH('Color'), -15, 's ');
     SETCOLOR (LTRED);
     OUTTEXTXY (175+TEXTWIDTH('Colors '), -15, 'b');
     SETCOLOR (LTMAGENTA);
     OUTTEXTXY (175+TEXTWIDTH('Colors b'), -15, 'y');
     SETCOLOR (BLUE);
     OUTTEXTXY (175, 35, 'T');
     SETCOLOR (CYAN);
     OUTTEXTXY (175+TEXTWIDTH('T'), 35, 'i');
     SETCOLOR (LTYELLOW);
     OUTTEXTXY (175+TEXTWIDTH('Ti'), 35, 'm ');
     SETCOLOR (LTMAGENTA);
     OUTTEXTXY (175+TEXTWIDTH('Tim '), 35, 'M');
     SETCOLOR (LTBLUE);
     OUTTEXTXY (175+TEXTWIDTH('Tim M'), 35, 'u');
     SETCOLOR (LTGREEN);
     OUTTEXTXY (175+TEXTWIDTH('Tim Mu'), 35, 's');
     SETCOLOR (DKWHITE);
     OUTTEXTXY (175+TEXTWIDTH('Tim Mus'), 35, 'a');
     REPEAT UNTIL KEYPRESSED;
     SETTEXTSTYLE (DEFAULTFONT, HORIZDIR, 1);
     CLEAR;

END; {OF PROCEDURE TIMSMARK}

{********************************************************************}

PROCEDURE JENNIFERSMARK;

VAR
   TEMP, SIZE, PLACE, PLACES, PLACEE, PLACEH : INTEGER;
   SIXTEENTH, EIGTH, HALF, MOVE : POINTER;

BEGIN
     CLEAR;
     SETTEXTSTYLE (TRIPLEXFONT, HORIZDIR, 5);
     SETLINESTYLE (SOLIDLN, 0, THICKWIDTH);
     SETCOLOR (LTRED);
     OUTTEXTXY (115, 28, 'JENNIFER ANDERSON');
     SETFILLSTYLE (SOLIDFILL, LTBLUE);
     SIZE := IMAGESIZE (110, 10, 154, 35);
     GETMEM (EIGTH, SIZE);
     GETMEM (HALF, SIZE);
     GETMEM (MOVE, SIZE);
     GETMEM (SIXTEENTH, SIZE);
     SETCOLOR (LTBLUE);
     FILLELLIPSE (125, 26, 6, 3);
     LINE (131, 26, 131, 11);
     ARC (131, 11, 270, 0, 10);
     GETIMAGE (110, 5, 154, 34, EIGTH^);
     PLACEE := 1;
     SETCOLOR (DKMAGENTA);
     CIRCLE (165, 95, 8);
     LINE (171, 95, 171, 80);
     GETIMAGE (155, 75, 199, 104, HALF^);
     PLACEH := 11;
     SETCOLOR (LTGREEN);
     SETFILLSTYLE (SOLIDFILL, LTGREEN);
     FILLELLIPSE (296, 97, 6, 3);
     FILLELLIPSE (328, 90, 6, 3);
     LINE (302, 97, 302, 82);
     LINE (334, 90, 334, 76);
     LINE (302, 82, 334, 76);
     LINE (302, 87, 334, 81);
     GETIMAGE (290, 75, 334, 104, SIXTEENTH^);
     PLACES := 14;
     REPEAT
       TEMP := RANDOM (3)+1;
       CASE TEMP OF
         1 : MOVE := HALF;
         2 : MOVE := SIXTEENTH;
         3 : MOVE := EIGTH;
       END; {OF CASE}
       REPEAT
         PLACE := RANDOM (18)+1;
       UNTIL NOT (PLACE IN [PLACEH, PLACES, PLACEE]);
       CASE TEMP OF
         1 : PLACEH := PLACE;
         2 : PLACES := PLACE;
         3 : PLACEE := PLACE;
       END; {OF CASE}
       CASE PLACE OF
         1  : PUTIMAGE (110, 10, MOVE^, NORMALPUT);
         2  : PUTIMAGE (155, 10, MOVE^, NORMALPUT);
         3  : PUTIMAGE (200, 10, MOVE^, NORMALPUT);
         4  : PUTIMAGE (245, 10, MOVE^, NORMALPUT);
         5  : PUTIMAGE (290, 10, MOVE^, NORMALPUT);
         6  : PUTIMAGE (335, 10, MOVE^, NORMALPUT);
         7  : PUTIMAGE (380, 10, MOVE^, NORMALPUT);
         8  : PUTIMAGE (425, 10, MOVE^, NORMALPUT);
         9  : PUTIMAGE (470, 10, MOVE^, NORMALPUT);
         10 : PUTIMAGE (110, 75, MOVE^, NORMALPUT);
         11 : PUTIMAGE (155, 75, MOVE^, NORMALPUT);
         12 : PUTIMAGE (200, 75, MOVE^, NORMALPUT);
         13 : PUTIMAGE (245, 75, MOVE^, NORMALPUT);
         14 : PUTIMAGE (290, 75, MOVE^, NORMALPUT);
         15 : PUTIMAGE (335, 75, MOVE^, NORMALPUT);
         16 : PUTIMAGE (380, 75, MOVE^, NORMALPUT);
         17 : PUTIMAGE (425, 75, MOVE^, NORMALPUT);
         18 : PUTIMAGE (470, 75, MOVE^, NORMALPUT);
       END; {OF CASE}
     UNTIL KEYPRESSED;
     FREEMEM (HALF, SIZE);
     FREEMEM (SIXTEENTH, SIZE);
     FREEMEM (EIGTH, SIZE);
     SETTEXTSTYLE (DEFAULTFONT, HORIZDIR, 1);
     SETLINESTYLE (SOLIDLN, 0, NORMWIDTH);
     SETFILLSTYLE (EMPTYFILL, BLACK);
     CLEAR;

END; {OF PROCEDURE JENNIFERSMARK}

{********************************************************************}

PROCEDURE BRIANSMARK;

BEGIN
     CLEAR;
     SETTEXTSTYLE (GOTHICFONT, HORIZDIR, 5);
     SETCOLOR (LTBLUE);
     OUTTEXTXY (100, 10, 'DRAGON SWORD');
     OUTTEXTXY (150, 50, 'BRIAN TIEMAN');
     REPEAT
     UNTIL KEYPRESSED;
     SETTEXTSTYLE (DEFAULTFONT, HORIZDIR, 1);
     CLEAR;

END; {OF PROCEDURE BRIANSMARK}

{********************************************************************}

PROCEDURE MOVE;

BEGIN
    REPEAT
      RESPONCE := UREADKEY;
      ROOM := DATA[N,E];
      CASE ORD (RESPONCE) OF
{CTRL}  0 : BEGIN
              RESPONCE := UREADKEY;
              IF COMPAS OR LGCOMPASS THEN
                COMPASSICON (FALSE);
              CASE ORD (RESPONCE) OF
{UP}            72 : MOVEFORWARD;
{DOWN}          80 : TURNAROUND;
{RIGHT}         77 : TURNRIGHT;
{LEFT}          75 : TURNLEFT;
{BRI'S MARK}    48 : BRIANSMARK;
{JEN'S MARK}    36 : JENNIFERSMARK;
{TIM'S MARK}    20 : TIMSMARK;
              END; {OF CASE}
              IF COMPAS OR LGCOMPASS THEN
                COMPASSICON (TRUE);
              PASS := FALSE;
            END;
{1..6}  49..54 : IF ORD (RESPONCE) <= (PEOPLE+48) THEN
                   VIEWCHAR;
{R}     82 : REORDER;
{S}     83 : SAVEGAME;
{U}     85 : BEGIN
               CLEAR;
               OUTTEXTXY (120, 55, 'WHO WISHES TO USE AN ITEM?');
               INT := GETPERSON (0, PEOPLE+1);
               IF INT <> -10 THEN
                 USE;
             END;
{C}     67 : CAST;
{D}     68 : CHANGEDELAY;
{G}     71 : BEGIN
               CLEAR;
               OUTTEXTXY (120, 55, 'GET RID OF PET?');
               RESPONCE := UREADKEY;
               IF (RESPONCE = 'Y') THEN
                 BEGIN
                   ROSTER[0].HPLEFT := 0;
                   CHECKFORDEAD (0);
                 END;
             END;
      END; {OF CASE}
      CHECKCOUNT;
      IF NOT PASS THEN
        ROOM := DATA[N,E];
      CHECKSPECIAL;
      IF (((LIGHTSP) OR (LGLIGHTSP)) AND (ROOM[6] <> '4')) OR (LEV = 0) THEN
        VIEWAHEAD
      ELSE
        CLEAR;
      SOUND (230);
      DELAY (20);
      NOSOUND;
      IF (RANDENCOUNTER) AND (ROOM[5] = '1') AND (NOT REPELL) THEN
        BEGIN
          NOMONEY := TRUE;
          ACCOMPLISHENCOUNTER;
          IF (((LIGHTSP) OR (LGLIGHTSP)) AND (ROOM[6] <> '4')) OR (LEV = 0) THEN
            VIEWAHEAD;
        END;
      INC (COUNT);
    UNTIL RESPONCE = #17;

END; {OF PROCEDURE MOVE)

{*******************************************************************}

END. {OF UNIT MAIN}