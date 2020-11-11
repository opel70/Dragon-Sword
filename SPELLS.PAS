UNIT SPELLS;

INTERFACE

USES
    CRT, GRAPH, VARIABLE;

PROCEDURE GETSPELLLEVEL;
FUNCTION ENOUGHSP (MINUS : BYTE) : BOOLEAN;
PROCEDURE CURING (ADD : WORD; SINT : INTEGER);
PROCEDURE FIX (WHATSWRONG : SPEC; POSSIBILITY, SINT : INTEGER);
PROCEDURE AGROUP (MSGNUM, ACTION : INTEGER; KIND : CHAR; DMGS : BYTE);
PROCEDURE ALLMONSTERS (ACTION : INTEGER; KIND : CHAR; DMGS : BYTE);
PROCEDURE CAST;
PROCEDURE LOCATE;
PROCEDURE SHIELD (AMOUNT : BYTE);
PROCEDURE RECALL;
PROCEDURE CLERICMENUS;
PROCEDURE MAGEMENUS;

IMPLEMENTATION

USES
    DRAW, GENERAL, MAIN, CITY;

{*******************************************************************}

PROCEDURE FIX (WHATSWRONG : SPEC; POSSIBILITY, SINT : INTEGER);

BEGIN
     IF SINT = -1 THEN
       BEGIN
         CLEAR;
         OUTTEXTXY (120, 35, 'WHO NEEDS HEALING?');
         SINT := GETPERSON (0, PEOPLE + 1);
       END;
     IF SINT >= 0 THEN
       IF (RANDOM(100)+1) < POSSIBILITY THEN
         WITH ROSTER[SINT] DO
           BEGIN
             IF SPECIAL = WHATSWRONG THEN
               BEGIN
                 SPECIAL := OK;
                 WRITECHARACTER (SINT, FALSE);
                 EXIT;
               END
             ELSE
               IF SINT <> 0 THEN
                 BEGIN
                   OUTTEXTXY (120, 65, 'PAY ATTENTION!!');
                   OUTTEXTXY (120, 75, 'THAT''S NOT WHAT''S WRONG WITH HIM!');
                 END; {OF IF THEN ELSE}
           END {OF WITH}
       ELSE
         OUTTEXTXY (120, 65, 'ATTEMPT FAILED.');
     TDELAY (THYME);

END; {OF PROCEDURE FIX}

{*******************************************************************}

PROCEDURE CURING (ADD : WORD; SINT : INTEGER);

BEGIN
     IF SINT = -1 THEN
       BEGIN
         CLEAR;
         OUTTEXTXY (120, 35, 'WHO NEEDS HEALING?');
         SINT := GETPERSON (0, PEOPLE + 1);
       END;
     IF SINT >= 0 THEN
       WITH ROSTER[SINT] DO
         BEGIN
           INC (HPLEFT, ADD);
           IF HPLEFT > HPTOT THEN
             HPLEFT := HPTOT;
         END; {OF WITH DO}
     WRITECHARACTER (SINT, TRUE);

END; {OF PROCEDURE CURING}

{*******************************************************************}

PROCEDURE GETSPELLLEVEL;

BEGIN
     WITH ROSTER[INT] DO
       BEGIN
         REPEAT
           REPEAT
             SETCOLOR (LTYELLOW);
             OUTTEXTXY (120, 35, 'WHAT LEVEL SPELL WOULD '+NAME+' LIKE TO CAST?');
             C := GETPERSON (0, SPELLLEVEL+1);
           UNTIL (C = -10) OR (C <= SPELLLEVEL);
           IF (SPECIAL <> SILENCE) AND (C <> -10) THEN
             CASE CLASS[4] OF
               'R' : CLERICMENUS;
               'I' : MAGEMENUS;
             END {OF CASE}
           ELSE
             IF (SPECIAL = SILENCE) AND (C <> -10) THEN
               BEGIN
                 OUTTEXTXY (120, 75, NAME+'TRIES TO CAST A SPELL,');
                 OUTTEXTXY (120, 85, 'BUT HE''S SILENCED.');
               END;
         UNTIL (SINT > 0) OR (C = -10);
       END; {OF WITH ROSTER[INT]}

END; {OF PROCEDURE GETSPELLLEVEL}

{*******************************************************************}

PROCEDURE CAST;

BEGIN
     CLEAR;
     IF NOT FIGHT THEN
       BEGIN
         OUTTEXTXY (120, 25, 'WHO WISHES TO CAST A SPELL?');
         INT := GETPERSON (0, PEOPLE + 1);
       END;
     IF (INT > 0) AND (ROSTER[INT].CLASS[4] = 'I') OR
        (ROSTER[INT].CLASS[4] = 'R') THEN
       GETSPELLLEVEL;

END; {OF PROCEDURE CAST}

{*******************************************************************}

FUNCTION ENOUGHSP (MINUS : BYTE) : BOOLEAN;

BEGIN
     WITH ROSTER[INT] DO
       IF SPELLPTLEFT >= MINUS  THEN
         BEGIN
           DEC (SPELLPTLEFT, MINUS);
           ENOUGHSP := TRUE;
         END
       ELSE
         BEGIN
           OUTTEXTXY (120, 95, 'YOU DON''T HAVE ENOUGH SPELL POINTS FOR THAT SPELL!');
           MAKENOISE;
           TDELAY (THYME);
           ENOUGHSP := FALSE;
         END;
     WRITECHARACTER (INT, TRUE);

END; {OF PROCEDURE ENOUGHSP}

{*******************************************************************}

PROCEDURE KILLMSG (DMGS : BYTE);

BEGIN
     WITH ENCOUNTER[ROSTER[INT].ATTGROUP] DO
       BEGIN
         STR (DMGS, HPNUM);
         OUTTEXTXY (120, 65, GETAORAN(NAME[1])+NAME+' SUFFERS '+HPNUM+' POINTS OF DAMAGE!');
         OUTTEXTXY (120, 75, 'YOU KILLED '+GETAORAN(NAME[1])+NAME+'!');
       END; {OF WITH ROSTER[INT]}

END; {OF PROCEDURE KILLMSG}

{*******************************************************************}

PROCEDURE NOTKILLMSG (DMGS : BYTE);

BEGIN
     IF (BEFORE^.NEXT^.GROUP = ROSTER[INT].ATTGROUP) THEN
       BEGIN
         IF DMGS = 0 THEN
           OUTTEXTXY (120, 75, 'YOUR SPELL HAS NO AFFECT!!')
         ELSE
           BEGIN
             STR (DMGS, HPNUM);
             OUTTEXTXY (120, 75, 'YOU DID '+HPNUM+' POINTS OF DAMAGE!');
           END;
         FIND^.GROUP := -1*FIND^.GROUP;
       END;

END; {OF PROCEDURE NOTKILLMSG}

{*******************************************************************}

PROCEDURE AFFECTEDMSG;

BEGIN
     OUTTEXTXY (120, 65, 'YOUR SPELL TAKES AFFECT!!');

END; {OF PROCEDURE AFFECTEDMSG}

{*******************************************************************}

PROCEDURE GOKILL (DMGS, ALTER1 : BYTE);

BEGIN
     WITH ROSTER[INT] DO
       BEGIN
         DMGS := RANDOM (DMGS)+ALTER1+DMGS DIV 3;
         IF ENCOUNTER[ATTGROUP].HDICE*4 < DMGS THEN
           BEGIN
             BEFORE^.NEXT := PTR;
             DISPOSE (FIND);
             DEC (ENCOUNTER[ATTGROUP].NUMBER);
             INC (NUMKILLED[ATTGROUP]);
             KILLMSG (DMGS);
             SHOWENCOUNTER;
           END
         ELSE
           NOTKILLMSG (DMGS);
       END;

END; {OF PROCEDURE GOKILL}

{*******************************************************************}

PROCEDURE GODISPOSE;

BEGIN
     WITH ROSTER[INT] DO
       BEGIN
         OUTTEXTXY (120, 65, ENCOUNTER[ATTGROUP].NAME+' SHAKES HANDS AND LEAVES!');
         DEC (ENCOUNTER[ATTGROUP].NUMBER);
         DISPOSE (FIND);
         BEFORE^.NEXT := PTR;
         IF ENCOUNTER[ATTGROUP].NUMBER > 0 THEN
           SHOWENCOUNTER
         ELSE
           DEC (GROUPTOT);
       END; {OF WITH ROSTER[INT]}

END; {OF PROCEDURE GODISPOSE}

{*******************************************************************}

PROCEDURE GOADDAC;

BEGIN
     OUTTEXTXY (120, 65, 'WOW, HE''S EASIER TO HIT!');
     INC (ENCOUNTER[ROSTER[INT].ATTGROUP].AC, 2);
     FIND^.GROUP := -1*FIND^.GROUP;

END; {OF PROCEDURE GOADDAC}

{*******************************************************************}

PROCEDURE PSPELLATTACK (ACTION : INTEGER; ALTER1, ALTER2, DMGS : BYTE);

BEGIN
     WITH ROSTER[INT] DO
       BEGIN
         CLEAROPTIONS;
         FINDMONSTER;
         IF (ENCOUNTER[ATTGROUP].NUMBER > 0) AND (BEFORE^.NEXT^.GROUP = ATTGROUP) THEN
           IF (ALTER2 = 0) OR ((RANDOM (ALTER2) > 10) AND (LEVEL > ENCOUNTER[ATTGROUP].HDICE DIV 2))
              AND (RANDOM (100) > 25-(LEVEL-ENCOUNTER[ATTGROUP].HDICE)) THEN
             BEGIN
               CASE ACTION OF
                 1 : GOKILL (DMGS, ALTER1);
                 2 : GODISPOSE;
                 3 : GOADDAC;
               END; {OF CASE ACTION}
             END
           ELSE
             NOTKILLMSG (0)
         ELSE
           NOTKILLMSG (0);
         TDELAY (THYME);
       END; {OF WITH ROSTER[INT]}

END; {OF PROCEDURE PSPELLATTACK}

{*******************************************************************}

PROCEDURE SPELLMSGONE (MSGNUM : INTEGER);

BEGIN
     CASE MSGNUM OF
       1  : OUTTEXTXY (120, 65, 'CAST OPEN WOUND ON WHOM?');
       3  : OUTTEXTXY (120, 65, 'CAUSE WOUNDS ON WHOM?');
       4  : OUTTEXTXY (120, 65, 'TURN WHICH MONSTER TO STONE?');
       6  : OUTTEXTXY (120, 65, 'WHO DO YOU WISH TO TOUCH WITH DEATH?');
       7  : OUTTEXTXY (120, 65, 'CAST SPARK ON WHICH MONSTER?');
       8  : OUTTEXTXY (120, 65, 'AT WHOM DO YOU AIM YOUR DART OF FLAME?');
       9  : OUTTEXTXY (120, 65, 'ATTACH WHICH GROUP WITH YOUR MAGESWORD?');
       10 : OUTTEXTXY (120, 65, 'INVOKE DEATH UPON WHOM?');
       11 : OUTTEXTXY (120, 65, 'WHICH MONSTER DO YOU WANT TO TURN TO DUST?');
       12 : OUTTEXTXY (120, 65, 'DESTROY WHICH MONSTER?');
       13 : OUTTEXTXY (120, 65, 'USE WEAPON OF SILVER ON WHOM?');
     END; {OF CASE}

END; {OF PROCEDURE SPELLMSGONE}

{*******************************************************************}

PROCEDURE SPELLMSGGROUP (MSGNUM : INTEGER);

BEGIN
     CASE MSGNUM OF
       1  : OUTTEXTXY (120, 65, 'DOUSE HOLY WATER ON WHICH GROUP?');
       4  : OUTTEXTXY (120, 65, 'CAST FIREBALL ON WHICH GROUP?');
       5  : OUTTEXTXY (120, 65, 'WHICH GROUP DO YOU AIM THE LIGHTNING AT?');
       6  : OUTTEXTXY (120, 65, 'WHICH GROUP DO YOU WANT TO FREEZE IN ICE?');
       9  : OUTTEXTXY (120, 65, 'MAKE WHICH GROUP EASY TO HIT');
       10 : OUTTEXTXY (120, 65, 'MAKE WHICH GROUP EASIER TO HIT');
       11 : OUTTEXTXY (120, 65, 'MAKE FRIENDS WITH WHOM?');
       14 : OUTTEXTXY (120, 65, 'TELEPORT WHICH GROUP?');
       15 : OUTTEXTXY (120, 65, 'USE ITEM ON WHICH GROUP?');
       16 : OUTTEXTXY (120, 65, 'TRY TURNING WHICH GROUP?');
       17 : OUTTEXTXY (120, 65, 'ATTACK WHICH GROUP?');
       20 : OUTTEXTXY (120, 65, 'SET THE AIR AFIRE AROUND WHICH GROUP?');
     END; {OF CASE}

END; {OF PROCEDURE SPELLMSGGROUP}

{*******************************************************************}

PROCEDURE GETALTERS (KIND : CHAR; VAR ALTER1, ALTER2 : BYTE);

BEGIN
     ALTER1 := 0;
     ALTER2 := 0;
     CASE ENCOUNTER[ROSTER[INT].ATTGROUP].MONSTERTYPE OF
       'F' : IF KIND = 'F' THEN
               ALTER1 := 20;
       'C' : IF KIND = 'C' THEN
               ALTER1 := 20;
       'U' : IF KIND = 'U' THEN
               ALTER1 := 40;
       'R' : ALTER2 := 20;
       'K' : ALTER2 := 30;
     END; {OF CASE}

END; {OF PROCEDURE GETALTERS}

{*******************************************************************}

PROCEDURE ONEMONSTER (MSGNUM, ACTION : INTEGER; KIND : CHAR; DMGS : BYTE);

VAR
   ALTER1, ALTER2 : BYTE;

BEGIN
     WITH ROSTER[INT] DO
       BEGIN
         CLEAR;
         SHOWENCOUNTER;
         SPELLMSGONE (MSGNUM);
         REPEAT
           ATTGROUP := GETPERSON (0, GROUPTOT+1);
         UNTIL (ENCOUNTER[ATTGROUP].NUMBER > 0) AND (ATTGROUP <> -10);
         GETALTERS (KIND, ALTER1, ALTER2);
         IF (MSGNUM = 12) AND (ENCOUNTER[SINT].MONSTERTYPE <> 'U') THEN
           BEGIN
             OUTTEXTXY (120, 75, 'THE SPELL HAS NO AFFECT!');
             EXIT;
           END;
         PSPELLATTACK (ACTION, ALTER1, ALTER2, DMGS);
       END; {OF WITH ROSTER[INT]}

END; {OF PROCEDURE ONEMONSTER}

{*******************************************************************}

PROCEDURE AGROUP (MSGNUM, ACTION : INTEGER; KIND : CHAR; DMGS : BYTE);

VAR
   ALTER1, ALTER2 : BYTE;

BEGIN
     WITH ROSTER[INT] DO
       BEGIN
         CLEAR;
         SHOWENCOUNTER;
         SPELLMSGGROUP (MSGNUM);
         REPEAT
           ATTGROUP := GETPERSON (0, GROUPTOT+1);
         UNTIL (ENCOUNTER[ATTGROUP].NUMBER > 0) AND (ATTGROUP <> -10);
         GETALTERS (KIND, ALTER1, ALTER2);
         IF (MSGNUM = 19) AND (ENCOUNTER[SINT].MONSTERTYPE <> 'U') THEN
           BEGIN
             OUTTEXTXY (120, 75, 'THE SPELL HAS NO AFFECT!');
             EXIT;
           END;
         REPEAT
           IF (BEFORE^.GROUP <> -1*ROSTER[INT].ATTGROUP) OR (CHECK) THEN
             BEGIN
               PSPELLATTACK (ACTION, ALTER1, ALTER2, DMGS);
               CHECK := FALSE;
             END
           ELSE
             CHECK := TRUE;
         UNTIL (BEFORE^.NEXT = NIL) OR (ENCOUNTER[ATTGROUP].NUMBER < 1);
       END;

END; {OF PROCEDURE AGROUP}

{*******************************************************************}

PROCEDURE ALLMONSTERS (ACTION : INTEGER; KIND : CHAR; DMGS : BYTE);

VAR
   ALTER1, ALTER2 : BYTE;

BEGIN
     WITH ROSTER[INT] DO
       BEGIN
         CLEAR;
         SHOWENCOUNTER;
         FOR SINT := 1 TO GROUPTOT DO
           BEGIN
             ATTGROUP := SINT;
             GETALTERS (KIND, ALTER1, ALTER2);
             BEFORE := START;
             REPEAT
               IF (BEFORE^.NEXT <> NIL) THEN
                 PSPELLATTACK (ACTION, ALTER1, ALTER2, DMGS);
             UNTIL (BEFORE^.NEXT = NIL) OR (ENCOUNTER[ATTGROUP].NUMBER < 1);
           END;
       END; {OF WITH ROSTER}

END; {OF PROCEDURE ALLMONSTERS}

{*******************************************************************}

PROCEDURE AID (MINUS : SHORTINT; WHAT : BOOLEAN);

BEGIN
     IF WHAT THEN
       BEGIN
         CLEAR;
         SHOWENCOUNTER;
         OUTTEXTXY (120, 65, 'BESTOW AID SPELL UPON WHOM?');
         REPEAT
           SINT := GETPERSON (0, PEOPLE+1);
         UNTIL (SINT > 0);
         OUTTEXTXY (120, 75, ROSTER[SINT].NAME+' IS PROTECTED BY A SPELL.');
         TDELAY (THYME);
       END; {OF IF WHAT????}
     WITH ROSTER[SINT] DO
       BEGIN
         INC (SPAC, MINUS);
         IF ABS (SPAC) > 100 THEN
           DEC (SPAC, MINUS);
         DEC (AC, MINUS);
       END;
     WRITECHARACTER (SINT, TRUE);

END; {OF PROCEDURE AID}

{*******************************************************************}
{*******************************************************************}

PROCEDURE LOCATE;

BEGIN
     CLEAR;
     STR (LEV, STRINGONE);
     STR (N, NUMSTR);
     STR (E, NUMSTR2);
     CASE DIRECTION OF
       'N' : HPNUM := 'NORTH';
       'S' : HPNUM := 'SOUTH';
       'E' : HPNUM := 'EAST';
       'W' : HPNUM := 'WEST';
     END; {OF CASE}
     OUTTEXTXY (190, 55, 'YOU ARE ON LEVEL '+STRINGONE+' FACING '+HPNUM+',');
     OUTTEXTXY (170, 63, NUMSTR+' SQUARES SOUTH AND '+NUMSTR2+' SQUARES EAST.');
     REPEAT UNTIL KEYPRESSED;

END; {OF PROCEDURE LOCATE}

{*******************************************************************}

PROCEDURE SHIELD (AMOUNT : BYTE);

BEGIN
     IF (NOT SHELD) AND (NOT ARMOR) AND (NOT INVULN) THEN
       FOR INT := 0 TO PEOPLE DO
         BEGIN
           DEC (ROSTER[INT].AC, AMOUNT);
           WRITECHARACTER (INT, TRUE);
         END;
     SHIELDICON (TRUE);

END; {OF PROCEDURE SHIELD}

{*******************************************************************}

PROCEDURE HEAL;

BEGIN
     WITH ROSTER[SINT] DO
       BEGIN
         CURING (HPTOT, -1);
         IF (SPECIAL = POISON) OR (SPECIAL = PARALYS) THEN
           SPECIAL := OK;
       END;
     WRITECHARACTER (SINT, TRUE);

END; {OF PROCEDURE HEAL}

{*******************************************************************}

PROCEDURE PARTYHEAL;

BEGIN
     FOR SINT := 1 TO PEOPLE DO
       WITH ROSTER[SINT] DO
         IF (SPECIAL <> STONE) AND (SPECIAL <> DEAD) THEN
           BEGIN
             HPLEFT := HPTOT;
             WRITECHARACTER (SINT, TRUE);
           END; {OF IF THEN}

END; {OF PROCEDURE PARTYHEAL}

{*******************************************************************}

PROCEDURE RECALL;

BEGIN
     IF NOT FIGHT THEN
       BEGIN
         FOR INT := 1 TO PEOPLE DO
           DEC (ROSTER[INT].MONEY, RANDOM (ROSTER[INT].MONEY));
         GUILDSTUFF;
       END;

END; {OF PROCEDURE RECALL}

{*******************************************************************}

PROCEDURE RESTOREPARTY;

BEGIN
     FOR SINT := 1 TO PEOPLE DO
       WITH ROSTER[SINT] DO
         IF (SPECIAL <> STONE) AND (SPECIAL <> DEAD) THEN
           BEGIN
             HPLEFT := HPTOT;
             SPECIAL := OK;
             WRITECHARACTER (SINT, TRUE);
           END; {OF IF THEN}

END; {OF PROCEDURE RESTOREPARTY}

{*******************************************************************}

PROCEDURE TELEPORTTOSTAIRS;

BEGIN
     FOR TEMP := 1 TO 21 DO
       FOR TEMP2 := 1 TO 21 DO
         IF (FILENAME1[10] IN ['2', '3']) THEN
           IF (DATA[TEMP, TEMP2][5] = '3') THEN
             EXIT
           ELSE
         ELSE
           IF (DATA[TEMP, TEMP2][5] = '4') THEN
             EXIT;
     E := TEMP;
     N := TEMP2;

END; {OF PROCEDURE TELEPORTTOSTAIRS}

{*******************************************************************}

PROCEDURE PRAYER;

BEGIN
     CLEAR;
     OUTTEXTXY (120, 15, 'YOU MAY PRAY FOR:');
     OUTTEXTXY (120, 25, '1) RESTORE PARTY');
     OUTTEXTXY (120, 35, '2) RESURRECT');
     OUTTEXTXY (120, 45, '3) REPEL MONSTERS');
     SINT := GETPERSON (0, 2);
     CASE SINT OF
       1 : RESTOREPARTY;
       2 : FIX (DEAD, 75, -1);
       3 : REPELL := TRUE;
     END; {OF CASE}

END; {OF PROCEDURE PRAYER}

{*******************************************************************}

PROCEDURE SPELL1;

BEGIN
     CLEAR;
     SETCOLOR (LTRED);
     OUTTEXTXY (120, 25, 'WHICH SPELL DO YOU WISH TO CAST?');
     OUTTEXTXY (120, 35, '1) [1] LIGHT');
     OUTTEXTXY (120, 45, '2) [2] LOCATE');
     OUTTEXTXY (120, 55, '3) [3] SANCTUARY');
     OUTTEXTXY (120, 65, '4) [3] MEND WOUNDS');
     OUTTEXTXY (120, 75, '5) [4] EASY HIT');
     SINT := GETPERSON (0, 6);
     IF SINT > 0 THEN
       CASE SINT OF
         1 : IF ENOUGHSP (1) THEN
               BEGIN
                 LIGHTSP := TRUE;
                 LIGHTICON (TRUE);
               END;
         2 : IF ENOUGHSP (2) THEN
               LOCATE;
         3 : IF (FIGHT) AND (ENOUGHSP (3)) THEN
               AID (1, TRUE);
         4 : IF ENOUGHSP (3) THEN
               CURING ((RANDOM(10)+1), -1);
         5 : IF (FIGHT) AND (ENOUGHSP (4)) THEN
               AGROUP (9, 3, 'N', 0);
       END; {OF CASE}

END; {OF PROCEDURE SPELL1}

{*******************************************************************}

PROCEDURE SPELL2;

BEGIN
     CLEAR;
     SETCOLOR (LTRED);
     OUTTEXTXY (120, 25, 'WHICH SPELL DO YOU WISH TO CAST?');
     OUTTEXTXY (120, 35, '1) [2] UNTRAP');
     OUTTEXTXY (120, 45, '2) [4] OPEN WOUND');
     OUTTEXTXY (120, 55, '3) [4] SHIELD');
     OUTTEXTXY (120, 65, '4) [6] HOLY WATER');
     SINT := GETPERSON (0, 5);
     IF SINT > 0 THEN
       CASE SINT OF
         1 :; {DO NOTHING HERE}
         2 : IF (FIGHT) AND (ENOUGHSP (4)) THEN
               ONEMONSTER (1, 1, 'N', 3*ROSTER[INT].LEVEL);
         3 : IF ENOUGHSP (4) THEN
               BEGIN
                 SHIELD (1);
                 SHELD := TRUE;
               END;
         4 : IF (FIGHT) AND (ENOUGHSP (6)) THEN
               AGROUP (1, 1, 'U', 25);
       END; {OF CASE}

END; {OF PROCEDURE SPELL2}

{*******************************************************************}

PROCEDURE SPELL3;

BEGIN
     CLEAR;
     SETCOLOR (LTRED);
     OUTTEXTXY (120, 25, 'WHICH SPELL DO YOU WISH TO CAST?');
     OUTTEXTXY (120, 35, '1) [5] LONG LIGHT');
     OUTTEXTXY (120, 45, '2) [6] CAUSE WOUNDS');
     OUTTEXTXY (120, 55, '3) [8] CURE WOUNDS');
     OUTTEXTXY (120, 65, '4) [8] EASIER HIT');
     OUTTEXTXY (120, 75, '5) [9] CURE POISON');
     SINT := GETPERSON (0, 6);
     IF SINT > 0 THEN
       CASE SINT OF
         1 : IF ENOUGHSP (5) THEN
               BEGIN
                 LGLIGHTSP := TRUE;
                 LIGHTICON (TRUE);
               END;
         2 : IF (FIGHT) AND (ENOUGHSP (6)) THEN
               ONEMONSTER (3, 1, 'N', 5*ROSTER[INT].LEVEL);
         3 : IF ENOUGHSP (8) THEN
               CURING (((RANDOM(9)+1)*3), -1);
         4 : IF (FIGHT) AND (ENOUGHSP (8)) THEN
               AGROUP (10, 3, 'N', 0);
         5 : IF ENOUGHSP (9) THEN
               FIX (POISON, 90, -1);
       END; {OF CASE}

END; {OF PROCEDURE SPELL3}

{*******************************************************************}

PROCEDURE SPELL4;

BEGIN
     CLEAR;
     SETCOLOR (LTRED);
     OUTTEXTXY (120, 25, 'WHICH SPELL DO YOU WISH TO CAST?');
     OUTTEXTXY (120, 35, '1) [8]  ARMOUR');
     OUTTEXTXY (120, 45, '2) [9]  STONE');
     OUTTEXTXY (120, 55, '3) [9]  HEAL');
     OUTTEXTXY (120, 65, '4) [11] CURE PARALYSIS');
     OUTTEXTXY (120, 75, '5) [12] CURE STONE');
     SINT := GETPERSON (0, 6);
     IF SINT > 0 THEN
       CASE SINT OF
         1 : IF ENOUGHSP (8) THEN
               BEGIN
                 SHIELD (2);
                 ARMOR := TRUE;
               END;
         2 : IF (FIGHT) AND (ENOUGHSP (9)) THEN
               ONEMONSTER (4, 1, 'N', 0);
         3 : IF ENOUGHSP (9) THEN
               HEAL;
         4 : IF ENOUGHSP (11) THEN
               FIX (PARALYS, 80, -1);
         5 : IF ENOUGHSP (12) THEN
               FIX (STONE, 60, -1);
       END; {OF CASE}

END; {OF PROCEDURE SPELL4}

{*******************************************************************}

PROCEDURE SPELL5;

BEGIN
     CLEAR;
     SETCOLOR (LTRED);
     OUTTEXTXY (120, 25, 'WHICH SPELL DO YOU WISH TO CAST?');
     OUTTEXTXY (120, 35, '1) [14] PARTY HEAL');
     OUTTEXTXY (120, 45, '2) [14] PROTECTION FROM BREATH');
     OUTTEXTXY (120, 55, '3) [15] RECALL');
     OUTTEXTXY (120, 65, '4) [16] RAISE DEAD');
     OUTTEXTXY (120, 75, '5) [16] TELEPORT TO STAIRS');
     SINT := GETPERSON (0, 6);
     IF SINT > 0 THEN
       CASE SINT OF
         1 : IF ENOUGHSP (14) THEN
               PARTYHEAL;
         2 : IF (FIGHT) AND (ENOUGHSP (14)) THEN
               PBREATH := TRUE;
         3 : IF ENOUGHSP (15) THEN
               RECALL;
         4 : IF ENOUGHSP (16) THEN
               FIX (DEAD, 40, -1);
         5 : IF (LEV <> 0) AND (ENOUGHSP (16)) THEN
               TELEPORTTOSTAIRS;
       END; {OF CASE}

END; {OF PROCEDURE SPELL5}

{*******************************************************************}

PROCEDURE SPELL6;

BEGIN
     CLEAR;
     SETCOLOR (LTRED);
     OUTTEXTXY (120, 25, 'WHICH SPELL DO YOU WISH TO CAST?');
     OUTTEXTXY (120, 35, '1) [15] PROTECTION FROM SPELLS');
     OUTTEXTXY (120, 45, '2) [17] INVULNERABILITY');
     OUTTEXTXY (120, 55, '3) [20] TOUCH OF DEATH');
     OUTTEXTXY (120, 65, '4) [25] PRAYER');
     SINT := GETPERSON (0, 7);
     IF SINT > 0 THEN
       CASE SINT OF
         1 : IF (FIGHT) AND (ENOUGHSP (15)) THEN
               PROTECTIONSP := TRUE;
         2 : IF (FIGHT) AND (ENOUGHSP (17)) THEN
               BEGIN
                 SHIELD (3);
                 INVULN := TRUE;
               END;
         3 : IF (FIGHT) AND (ENOUGHSP (20)) THEN
               ONEMONSTER (6, 1, 'N', 130);
         4 : IF (NOT FIGHT) AND (ENOUGHSP (25)) THEN
               PRAYER;
       END; {OF CASE}

END; {OF PROCEDURE SPELL6}

{*******************************************************************}

PROCEDURE CLERICMENUS;

BEGIN
     DONTKILL := FALSE;
     CASE C OF
       1 : SPELL1;
       2 : SPELL2;
       3 : SPELL3;
       4 : SPELL4;
       5 : SPELL5;
       6 : SPELL6;
     END; {OF CASE}
     IF SINT < 0 THEN
       BEGIN
         CLEAR;
         GETSPELLLEVEL;
       END;
     CLEAR;

END; {OF PROCEDURE CLERICMENUS}

{*******************************************************************}
{*******************************************************************}

PROCEDURE PET (PETRACE : STRING10; PETAC : INTEGER; ABILROLL, PNUMATT,
               PTHACO, PDMG, PHP : BYTE; FAMIL : BOOLEAN);

BEGIN
     WITH ROSTER[0] DO
       BEGIN
         IF NOT FAMIL THEN
           CLEAR;
         OUTTEXTXY (120, 65, 'A '+PETRACE+' COMES TO YOUR AID.');
         OUTTEXTXY (120, 75, 'WHAT DO YOU WISH TO NAME IT?');
         READLINE (INPUTSTR, 15, 120, 85);
         NAME := INPUTSTR;
         RACE :=  PETRACE;
         CLASS := 'PET';
         LEVEL := ROSTER[INT].LEVEL;
         AC := PETAC;
         SPAC := 0;
         FOR J := 1 TO 7 DO
           ABILITIES[J] := RANDOM(ABILROLL)+3;
         HPTOT := PHP*ROSTER[INT].LEVEL;
         HPLEFT := HPTOT;
         NUMATTACKS := PNUMATT;
         ATTGROUP := 1;
         THACO := PTHACO;
         DAMAGE := PDMG;
         SPECIAL := OK;
         FOR J := 1 TO 8 DO
           EQUIPMENT[J] := SCUM;
         EXP := 0;
         MONEY := 0;
         SPELLLEVEL := 0;
         SPELLPTSTOT := 0;
         SPELLPTLEFT := 0;
         STATUS := 'OK';
         IF FAMIL THEN
           BEGIN
             INC (ROSTER[INT].HPTOT, HPTOT);
             INC (ROSTER[INT].HPLEFT, HPTOT);
             ROSTER[INT].CLASS := 'MAGIC USER';
             WRITECHARACTER (INT, FALSE);
           END;
     END; {OF WITH ROSTER[0] DO}
     WRITECHARACTER (0, TRUE);

END; {OF PROCEDURE PET}

{*******************************************************************}

PROCEDURE FAMILIAR;

BEGIN
     CLEAR;
     IF ROSTER[0].NAME = '' THEN
       WITH ROSTER[INT] DO
         BEGIN
           OUTTEXTXY (120, 55, NAME+' CALLS FOR HELP . . .');
           IF RANDOM(100)+LEVEL+ABILITIES[2]+ABILITIES[7] > 80 THEN
             BEGIN
               SINT := RANDOM(85)+(RANDOM(LEVEL)+ABILITIES[7]);
               IF SINT > 100 THEN
                 SINT := 100;
               CASE SINT OF
                 0..35   : PET ('CAT', 8, 10, 1, 20, 4, 2, TRUE);
                 35..65  : PET ('OWL', 6, 13, 1, 17, 6, 4, TRUE);
                 65..85  : PET ('HAWK', 4, 16, 2, 15, 8, 4, TRUE);
                 85..100 : PET ('QUASIT', 2, 18, 3, 12, 10, 6, TRUE);
               END; {OF CASE}
             END
           ELSE
             OUTTEXTXY (120, 65, 'BUT UNFORTUNATELY NO ONE ANSWERS.');
         END
     ELSE
       OUTTEXTXY (120, 55, 'YOU ALREADY HAVE A PET IN THE PARTY!');
     TDELAY (THYME);

END; {OF PROCEDURE FAMILIAR}

{*******************************************************************}

PROCEDURE SSILENCE;

BEGIN
     WITH ROSTER[INT] DO
       BEGIN
         NOSPEAK := FALSE;
         CLEAR;
         SHOWENCOUNTER;
         OUTTEXTXY (120, 65, 'WHICH GROUP DO YOU WANT TO SILENCE?');
         REPEAT
           ATTGROUP := GETPERSON (0, GROUPTOT + 1);
         UNTIL ENCOUNTER[ATTGROUP].NUMBER > 0;
         IF (LEV-ENCOUNTER[SINT].HDICE)+RANDOM(ABILITIES[7]) > 5 THEN
           BEGIN
             NOSPEAK := TRUE;
             OUTTEXTXY (120, 75, 'THE GROUP IS SILENCED!');
           END
         ELSE
           OUTTEXTXY (120, 75, 'THE GROUP RESISTS THE SPELL!');
         TDELAY (THYME);
       END;

END; {OF PROCEDURE SSILENCE}

{*******************************************************************}

PROCEDURE HEALFAMILIAR;

BEGIN
     WITH ROSTER[0] DO
       BEGIN
         IF SPECIAL <> DEAD THEN
           FIX (SPECIAL, 100, 0);
         CURING (HPTOT, 0);
       END; {OF WITH DO}

END; {OF PROCEDURE HEALFAMILIAR}

{*******************************************************************}

PROCEDURE INVISIBILITY;

BEGIN
     CLEAR;
     SHOWENCOUNTER;
     FOR SINT := 1 TO PEOPLE DO
       AID (3, FALSE);
     OUTTEXTXY (120, 65, 'THE MONSTERS LOOK BEWILDERED AS THE PARTY VANISHES!!');
     TDELAY (THYME);

END; {OF PROCEDURE INVISIBILITY}

{*******************************************************************}

PROCEDURE OPENWALL;

BEGIN
     PASS := TRUE;
     CASE DIRECTION OF
       'N' : ROOM[2] := '1';
       'S' : ROOM[4] := '1';
       'E' : ROOM[3] := '1';
       'W' : ROOM[1] := '1';
     END; {OF CASE}

END; {OF PROCEDURE OPENWALL}

{*******************************************************************}

PROCEDURE PRINTTELE;

BEGIN
     STR (TEMP, NUMSTR);
     STR (TEMP2, NUMSTR2);
     BAR (190, 55, 210, 85);
     OUTTEXTXY (190, 55, NUMSTR);
     OUTTEXTXY (190, 65, NUMSTR2);
     STR (L, HPNUM);
     OUTTEXTXY (190, 75, HPNUM);

END; {OF PROCEDURE PRINTTELE}

{*******************************************************************}

PROCEDURE TELEPORTMENU;

BEGIN
     CLEAR;
     L := 1;
     TEMP := 1;
     TEMP2 := 1;
     OUTTEXTXY (120, 55, '<S>OUTH:');
     OUTTEXTXY (250, 55, '<T>ELEPORT');
     OUTTEXTXY (120, 65, '<E>AST :');
     OUTTEXTXY (250, 65, '<C>ANCEL');
     OUTTEXTXY (120, 75, '<L>EVEL:');
     PRINTTELE;
     REPEAT
       RESPONCE := UREADKEY;
         CASE RESPONCE OF
           'S' : BEGIN
                   INC (TEMP);
                   IF TEMP > 21 THEN
                     TEMP := 1;
                   PRINTTELE;
                 END;
           'E' : BEGIN
                   INC (TEMP2);
                   IF TEMP2 > 21 THEN
                     TEMP2 := 1;
                   PRINTTELE;
                 END;
           'L' : BEGIN
                   INC (L);
                   IF L > TOPLEV THEN
                     L := 1;
                   PRINTTELE;
                 END;
           'T' : BEGIN
                   N := TEMP;
                   E := TEMP2;
                   LEV := L;
                   GETMAZE;
                 END;
           'C' :; {DO NOTHING}
         END; {OF CASE}
       UNTIL RESPONCE IN ['T', 'C'];

END; {OF PROCEDURE TELEPORTMENU}

{*******************************************************************}

PROCEDURE PARTIALCURE;

BEGIN
     CURING (((RANDOM(10)+1)*2), -1);
     IF (ROSTER[SINT].SPECIAL = PARALYS) OR (ROSTER[SINT].SPECIAL = STONE) THEN
       ROSTER[INT].SPECIAL := OK;
     WRITECHARACTER (SINT, TRUE);

END; {OF PROCEDURE PARTIALCURE}

{*******************************************************************}

PROCEDURE TRANSMOGRIFY;

BEGIN
     CLEAR;
     SHOWENCOUNTER;
     OUTTEXTXY (120, 65, 'WHICH GROUP DO YOU WISH TO TRANSMOGRIFY?');
     SINT := GETPERSON (0, GROUPTOT+1);
     CLEAR;
     WITH ENCOUNTER[SINT] DO
       BEGIN
         OUTTEXTXY (120, 65, 'THE '+NAME+'S LOOK CONFUSED AS THEY ARE');
         TEMP := NUMBER;
         CASE RANDOM(100) OF
           0..50  : DEC (HDICE);
           51..75 : DEC (HDICE, 2);
           76..85 : DEC (HDICE, 3);
           86..95 : INC (HDICE);
           96..99 : INC (HDICE, 2);
         END;
         IF HDICE > 30 THEN
           HDICE := 30;
         IF LEV < 0 THEN
           HDICE := 0;
         SEEK (MONSDATA, HDICE*12);
         READ (MONSDATA, ENCOUNTER[SINT]);
         IF IORESULT <> 0 THEN
           DISKERROR ('DSDATA.F12', TRUE);
         NUMBER := TEMP;
         OUTTEXTXY (120, 75, 'SUDDENLY TRANSFORMED INTO '+NAME+'S!');
         SHOWENCOUNTER;
         TDELAY (THYME);
       END; {OF WITH ENCOUNTER[SINT]}

END; {OF PROCEDURE TRANSMOGRIFY}

{*******************************************************************}

PROCEDURE WISH;

BEGIN
     CLEAR;
     OUTTEXTXY (120, 15, 'YOU MAY CAST:');
     OUTTEXTXY (120, 25, '1) TEMPORAL STOP');
     OUTTEXTXY (120, 35, '2) ARMAGEDDON');
     OUTTEXTXY (120, 45, '3) TRANSMOGRIFY');
     SINT := GETPERSON (0, 2);
     CASE SINT OF
       1 : THYMESTOP := RANDOM(4)+1;
       2 : ALLMONSTERS (1, 'N', 130);
       3 : TRANSMOGRIFY;
     END; {OF CASE}

END; {OF PROCEDURE WISH}

{*******************************************************************}

PROCEDURE MSPELL1;

BEGIN
     CLEAR;
     SETCOLOR (LTRED);
     OUTTEXTXY (120, 25, 'WHICH SPELL DO YOU WISH TO CAST?');
     OUTTEXTXY (120, 35, '1) [1] COMPASS');
     OUTTEXTXY (120, 45, '2) [2] SPARK');
     OUTTEXTXY (120, 55, '3) [3] FAMILIAR');
     OUTTEXTXY (120, 65, '4) [3] FRIENDS');
     OUTTEXTXY (120, 75, '5) [4] SILENCE');
     OUTTEXTXY (120, 85, '6) [4] FIND SECRET DOORS');
     SINT := GETPERSON (0, 7);
     IF SINT > 0 THEN
       CASE SINT OF
         1 : IF ENOUGHSP (1) THEN
               BEGIN
                  COMPAS := TRUE;
                  COMPASSICON (TRUE);
               END;
         2 : IF (FIGHT) AND (ENOUGHSP (2)) THEN
               ONEMONSTER (7, 1, 'F', 3*ROSTER[INT].LEVEL);
         3 : IF ENOUGHSP (3) THEN
               FAMILIAR;
         4 : IF (FIGHT) AND (ENOUGHSP (3)) THEN
               AGROUP (11, 2, 'N', 0);
         5 : IF (FIGHT) AND (ENOUGHSP (4)) THEN
               SSILENCE;
         6 : IF ENOUGHSP (4) THEN
               BEGIN
                 FDOOR := TRUE;
                 DOORICON (TRUE);
               END;
       END; {OF CASE}

END; {OF PROCEDURE MSPELL1}

{*******************************************************************}

PROCEDURE MSPELL2;

BEGIN
     CLEAR;
     SETCOLOR (LTRED);
     OUTTEXTXY (120, 25, 'WHICH SPELL DO YOU WISH TO CAST?');
     OUTTEXTXY (120, 35, '1) [3] DART OF FLAME');
     OUTTEXTXY (120, 45, '2) [4] HEAL PET');
     OUTTEXTXY (120, 55, '3) [4] MAGESWORD');
     OUTTEXTXY (120, 65, '4) [5] WOLF');
     OUTTEXTXY (120, 75, '5) [5] FIREBALL');
     SINT := GETPERSON (0, 6);
     IF SINT > 0 THEN
       CASE SINT OF
         1 : IF (FIGHT) AND (ENOUGHSP (3)) THEN
               ONEMONSTER (8, 1, 'F', 5*ROSTER[INT].LEVEL);
         2 : IF ENOUGHSP (4) THEN
               HEALFAMILIAR;
         3 : IF (FIGHT) AND (ENOUGHSP (4)) THEN
               ONEMONSTER (9, 1, 'C', 7*ROSTER[INT].LEVEL);
         4 : IF ENOUGHSP (5) THEN
               PET ('WOLF', 5, 14, 1, 15, 10, 6, FALSE);
         5 : IF (FIGHT) AND (ENOUGHSP (5)) THEN
               AGROUP (4, 1, 'F', 30);
       END; {OF CASE}

END; {OF PROCEDURE MSPELL2}

{*******************************************************************}

PROCEDURE MSPELL3;

BEGIN
     CLEAR;
     SETCOLOR (LTRED);
     OUTTEXTXY (120, 25, 'WHICH SPELL DO YOU WISH TO CAST?');
     OUTTEXTXY (120, 35, '1) [5] INVISIBILITY');
     OUTTEXTXY (120, 45, '2) [5] LONG COMPASS');
     OUTTEXTXY (120, 55, '3) [7] LIGHTNING');
     OUTTEXTXY (120, 65, '4) [7] MOVE GROUP');
     OUTTEXTXY (120, 75, '5) [8] OPEN WALL');
     SINT := GETPERSON (0, 6);
     IF SINT > 0 THEN
       CASE SINT OF
         1 : IF (ENOUGHSP (5)) AND (FIGHT) THEN
               INVISIBILITY;
         2 : IF ENOUGHSP (5) THEN
               BEGIN
                 LGCOMPASS := TRUE;
                 COMPASSICON (TRUE);
               END;
         3 : IF (ENOUGHSP (7)) AND (FIGHT) THEN
               AGROUP (5, 1, 'N', 50);
         4 : IF (FIGHT) AND (ENOUGHSP (7)) THEN
               AGROUP (14, 2, 'N', 0);
         5 : IF (LEV <> 0) AND (ENOUGHSP (8)) THEN
               OPENWALL;
       END; {OF CASE}

END; {OF PROCEDURE MSPELL3}

{*******************************************************************}

PROCEDURE MSPELL4;

BEGIN
     CLEAR;
     SETCOLOR (LTRED);
     OUTTEXTXY (120, 25, 'WHICH SPELL DO YOU WISH TO CAST?');
     OUTTEXTXY (120, 35, '1) [9]  DEATH');
     OUTTEXTXY (120, 45, '2) [9]  WEAPON OF SILVER');
     OUTTEXTXY (120, 55, '3) [11] STINKING CLOUD');
     OUTTEXTXY (120, 65, '4) [12] PARTIAL CURE');
     OUTTEXTXY (120, 75, '5) [12] BLOCK OF ICE');
     SINT := GETPERSON (0, 6);
     IF SINT > 0 THEN
       CASE SINT OF
         1 : IF (ENOUGHSP (9)) AND (FIGHT) THEN
               ONEMONSTER (10, 1, 'N', 125);
         2 : IF (ENOUGHSP (9)) AND (FIGHT) THEN
               ONEMONSTER (13, 1, 'U', 60);
         3 : IF (ENOUGHSP (11)) AND (FIGHT) THEN
               ALLMONSTERS (1, 'N', 80);
         4 : IF ENOUGHSP (12) THEN
               PARTIALCURE;
         5 : IF (FIGHT) AND (ENOUGHSP (12)) THEN
               AGROUP (6, 1, 'C', 70);
       END; {OF CASE}

END; {OF PROCEDURE MSPELL4}

{*******************************************************************}

PROCEDURE MSPELL5;

BEGIN
     CLEAR;
     SETCOLOR (LTRED);
     OUTTEXTXY (120, 25, 'WHICH SPELL DO YOU WISH TO CAST?');
     OUTTEXTXY (120, 35, '1) [12] DESTROY');
     OUTTEXTXY (120, 45, '2) [13] DISINTIGRATE');
     OUTTEXTXY (120, 55, '3) [13] MOVE MONSTER');
     OUTTEXTXY (120, 65, '4) [15] ICE STORM');
     OUTTEXTXY (120, 75, '5) [16] SWARM');
     OUTTEXTXY (120, 85, '6) [17] TELEPORT');
     SINT := GETPERSON (0, 7);
     IF SINT > 0 THEN
       CASE SINT OF
         1 : IF (FIGHT) AND (ENOUGHSP (12)) THEN
               ONEMONSTER (12, 1, 'U', 135);
         2 : IF (FIGHT) AND (ENOUGHSP (13)) THEN
               ONEMONSTER (11, 1, 'N', 150);
         3 : IF (FIGHT) AND (ENOUGHSP (13)) THEN
               ALLMONSTERS (3, 'N', 0);
         4 : IF (FIGHT) AND (ENOUGHSP (15)) THEN
               ALLMONSTERS (1, 'C', 90);
         5 : IF (FIGHT) AND (ENOUGHSP (16)) THEN
               ALLMONSTERS (1, 'N', 100);
         6 : IF (LEV <> 0) AND (ENOUGHSP (17)) THEN
               TELEPORTMENU;
       END; {OF CASE}

END; {OF PROCEDURE MSPELL5}

{*******************************************************************}

PROCEDURE MSPELL6;

BEGIN
     CLEAR;
     SETCOLOR (LTRED);
     OUTTEXTXY (120, 25, 'WHICH SPELL DO YOU WISH TO CAST?');
     OUTTEXTXY (120, 35, '1) [20] BURNING AIR');
     OUTTEXTXY (120, 45, '2) [22] DEAMON');
     OUTTEXTXY (120, 55, '3) [25] WISH');
     SINT := GETPERSON (0, 6);
     IF SINT > 0 THEN
       CASE SINT OF
         1 : IF (FIGHT) AND (ENOUGHSP (20)) THEN
               AGROUP (20, 1, 'F', 120);
         2 : IF ENOUGHSP (22) THEN
               PET ('DEAMON', -7, 18, 3, 6, 30, 15, FALSE);
         3 : IF (FIGHT) AND (ENOUGHSP (25)) THEN
               WISH;
       END; {OF CASE}

END; {OF PROCEDURE MSPELL6}

{*******************************************************************}

PROCEDURE MAGEMENUS;

BEGIN
     DONTKILL := FALSE;
     CASE C OF
       1 : MSPELL1;
       2 : MSPELL2;
       3 : MSPELL3;
       4 : MSPELL4;
       5 : MSPELL5;
       6 : MSPELL6;
     END; {OF CASE}
     IF SINT < 0 THEN
       BEGIN
         CLEAR;
         GETSPELLLEVEL;
       END;
     CLEAR;

END; {OF PROCEDURE MAGEMENUS}

{*******************************************************************}

END. {OF UNIT SPELLS}