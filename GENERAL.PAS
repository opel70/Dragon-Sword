UNIT GENERAL;

INTERFACE

USES
    CRT, DOS, GRAPH, VARIABLE;

PROCEDURE QUITGAME;
PROCEDURE CLEAR;
PROCEDURE CLEARBOTTOM (INT : INTEGER);
PROCEDURE CLEAROPTIONS;
PROCEDURE CLEARMONSTERROW (J : INTEGER);
PROCEDURE MAKENOISE;
PROCEDURE TDELAY (THYME : INTEGER);
FUNCTION UREADKEY : CHAR;
FUNCTION GETPERSON (GREATER, LESS :INTEGER) : INTEGER;
PROCEDURE CHECKFORDEAD (INT : INTEGER);
PROCEDURE DIVY;
PROCEDURE POOL;
PROCEDURE TRADEMONEY;
PROCEDURE DROP (VAR CHARACTER : PERSON);
PROCEDURE DROPITEM;
PROCEDURE TRADEITEM;
PROCEDURE EQUIP (CH : CHAR);
PROCEDURE READLINE (VAR INPUTSTR : STRING20; C, I, K : INTEGER);
PROCEDURE CHANGEDELAY;
PROCEDURE ABILADJUST (VAR CHARACTER : PERSON);
PROCEDURE FINDMONSTER;
PROCEDURE PLACEATEND;
PROCEDURE JUMPERS;
PROCEDURE CHECKSPECIAL;
PROCEDURE GETSPECIAL;
PROCEDURE USE;

IMPLEMENTATION

USES
    DRAW, MAIN, SPELLS, CITY;

{*******************************************************************}

PROCEDURE QUITGAME;

VAR
   QUIT : BOOLEAN;

BEGIN
     SETTEXTSTYLE (DEFAULTFONT, HORIZDIR, 1);
     QUIT := FALSE;
     CLEAR;
     SETCOLOR (LTYELLOW);
     OUTTEXTXY (220, 65, 'DO YOU REALLY WANT TO QUIT?');
     REPEAT
       RESPONCE := UREADKEY;
       IF RESPONCE = 'Y' THEN
         QUIT := TRUE;
     UNTIL RESPONCE IN ['Y', 'N'];
     IF QUIT THEN
       BEGIN
         PLAYSONG := FALSE;
         SONGON := FALSE;
         DELAY (100);
         HALT (0);
       END;
     CLEAR;

END; {OF PROCEDURE QUITGAME}

{*******************************************************************}

PROCEDURE CLEAR;

BEGIN
     SETFILLSTYLE (EMPTYFILL, BLACK);
     BAR (95, 2, 545, 108);

END; {PROCEDURE CLEAR}

{*******************************************************************}

PROCEDURE CLEARBOTTOM (INT : INTEGER);

BEGIN
     BAR (100, 136+(INT+1)*8, 540, 143+(INT+1)*8);

END; {PROCEDURE CLEARBOTTOM}

{*******************************************************************}

PROCEDURE CLEAROPTIONS;

BEGIN
     BAR (100, 65, 540, 105);

END; {OF PROCEDURE CLEAROPTIONS}

{*******************************************************************}

PROCEDURE CLEARMONSTERROW (J : INTEGER);

BEGIN
     BAR (100, 10+J*8, 540, 18+J*8);

END;

{*******************************************************************}

PROCEDURE MAKENOISE;

BEGIN
     FOR LEN := 1 TO 1500 DO
       BEGIN
         SOUND (330);
         SOUND (660);
         SOUND (770);
       END;
     NOSOUND;

END; {OF PROCEDURE MAKENOISE}

{*******************************************************************}

PROCEDURE TDELAY (THYME : INTEGER);

VAR
   TEMP : INTEGER;

BEGIN
     TEMP := THYME;
     REPEAT
       DELAY (10);
       DEC (TEMP);
       IF KEYPRESSED THEN
         RESPONCE := UREADKEY;
     UNTIL (TEMP = 0) OR (RESPONCE = ' ');
     RESPONCE := 'Z';

END; {OF PROCEDURE TDELAY}

{*******************************************************************}

FUNCTION UREADKEY : CHAR;

BEGIN
     RESPONCE := UPCASE (READKEY);
     IF RESPONCE = #17 THEN
       QUITGAME;
     UREADKEY := RESPONCE;

END; {OF FUNCTION UREADKEY}

{*******************************************************************}

FUNCTION GETPERSON (GREATER, LESS : INTEGER) : INTEGER;

BEGIN
     REPEAT
       RESPONCE := UREADKEY;
       VAL (RESPONCE, PNUM, CODE);
     UNTIL (CODE = 0) AND (PNUM > GREATER) AND (PNUM < LESS) OR (RESPONCE = 'Q');
     IF (CODE = 0) THEN
       GETPERSON := PNUM
     ELSE
       GETPERSON := -10;

END; {OF PROCEDURE GETPERSON}

{*******************************************************************}
{*******************************************************************}

PROCEDURE CHECKFORDEAD (INT : INTEGER);

BEGIN
     WITH ROSTER[INT] DO
       BEGIN
         IF HPLEFT <= 0 THEN
           BEGIN
             HPLEFT := 0;
             SPECIAL := DEAD;
           END;
         IF LEVEL < 1 THEN
           BEGIN
             LEVEL := 0;
             SPECIAL := DEAD;
           END;
         IF (INT = 0) AND (NAME <> '') AND (HPLEFT <= 0) THEN
           BEGIN
             NAME := '';
             FOR L := 1 TO PEOPLE DO
               IF ROSTER[L].CLASS = 'MAGIC USER' THEN
                 BEGIN
                   ROSTER[L].CLASS := 'MAGIC-USER';
                   DEC (ROSTER[L].HPLEFT, HPTOT);
                   DEC (ROSTER[L].HPTOT, HPTOT);
                   WRITECHARACTER (L, FALSE);
                END;
           END;
         WRITECHARACTER (INT, TRUE);
       END; {OF WITH ROSTER[INT]}

END; {OF PROCEDURE CHECKFORDEAD}

{*******************************************************************}

PROCEDURE DIVY;

BEGIN
     GOLD := 0;
     FOR J := 1 TO PEOPLE DO
       BEGIN
         INC (GOLD, ROSTER[J].MONEY);
         ROSTER[J].MONEY := 0;
       END;
     FOR J := 1 TO PEOPLE DO
       IF (J = 1) AND (PEOPLE > 1) THEN
         IF J = 1 THEN
           BEGIN
             ROSTER[J].MONEY := GOLD DIV PEOPLE;
             INC (ROSTER[J].MONEY, GOLD MOD PEOPLE);
           END
         ELSE {DO NOTHING}
       ELSE
         ROSTER[J].MONEY := GOLD DIV PEOPLE;

END; {OF PROCEDURE DIVY}

{*******************************************************************}

PROCEDURE POOL;

BEGIN
     CLEAR;
     GOLD := 0;
     FOR J := 1 TO PEOPLE DO
       BEGIN
         INC (GOLD, ROSTER[J].MONEY);
         ROSTER[J].MONEY := 0;
       END;
     ROSTER[INT].MONEY := GOLD;
     STR (GOLD, OUTGOLD);
     OUTTEXTXY (130, 45, 'YOU NOW HAVE:  '+OUTGOLD+' IN GOLD.');
     TDELAY (2*THYME);

END; {OF PROCEDURE POOL}

{*******************************************************************}

PROCEDURE TRADEMONEY;

BEGIN
     WITH ROSTER[INT] DO
       BEGIN
         REPEAT
           CLEAR;
           STR (MONEY, OUTGOLD);
           OUTTEXTXY (130, 45, 'YOU NOW HAVE:  '+OUTGOLD+' IN GOLD.');
           OUTTEXTXY (130, 55, 'HOW MUCH DO YOU WISH TO TRADE?');
           READLINE (INPUTSTR, 10, 240, 75);
           VAL (INPUTSTR, GOLD, CODE);
           IF CODE = 0 THEN
             IF GOLD > MONEY THEN
               BEGIN
                 OUTTEXTXY (130, 85, 'YOU DON''T HAVE THAT MUCH!!');
                 MAKENOISE;
                 TDELAY (THYME);
               END;
         UNTIL (CODE = 0) AND (GOLD <= MONEY);
         IF GOLD <> 0 THEN
           BEGIN
             OUTTEXTXY (130, 85, 'TO WHOM DO YOU WISH TO GIVE YOUR MONEY?');
             C := GETPERSON (0, PEOPLE + 1);
             IF C > 0 THEN
               BEGIN
                 DEC (MONEY, GOLD);
                 INC (ROSTER[C].MONEY, GOLD);
               END;
           END; {OF IF THEN}
         END; {OF WITH ROSTER[INT]}

END; {OF TRADEMONEY}

{*******************************************************************}

PROCEDURE DROP (VAR CHARACTER : PERSON);

BEGIN
     CHARACTER.EQUIPMENT[C] :=  SCUM;
     CONDENSEEQUIPMENT (CHARACTER);

END; {OF DROP}

{*******************************************************************}

PROCEDURE DROPITEM;

BEGIN
     OUTTEXTXY (110, 90, 'WHICH ITEM DO YOU WISH TO DROP?');
     C := GETPERSON (0, 9);
     IF C > 0 THEN
       BEGIN
         REPEAT
           OUTTEXTXY (110, 100, 'ARE YOU SURE? YOU MAY NEVER FIND ANOTHER.');
           RESPONCE := UREADKEY;
         UNTIL RESPONCE IN ['Y', 'N'];
         IF RESPONCE = 'Y' THEN
           DROP (ROSTER[INT]);
       END; {OF IF THEN}

END; {OF DROPITEM}

{*******************************************************************}

PROCEDURE TRADEITEM;

BEGIN
     WITH ROSTER[INT] DO
       BEGIN
         OUTTEXTXY (120, 90, 'WHICH ITEM DO YOU WISH TO TRADE?');
         REPEAT
           RESPONCE := UREADKEY;
           VAL (RESPONCE, C, CODE);
         UNTIL (CODE = 0) AND (C > 0) AND (C < 9) AND
               (EQUIPMENT[C].ITEM <> '') OR (RESPONCE = 'Q');
         OUTTEXTXY (120, 100, 'WHO IS TO GET YOUR WONDERFUL '+EQUIPMENT[C].ITEM+'?');
         T := GETPERSON (0, PEOPLE + 1);
         IF (T > 0) AND (FINDPLACE (ROSTER[T])) THEN
           BEGIN
             IF EQUIPMENT[C].EQUIPED THEN
               BEGIN
                 EQUIPMENT[C].EQUIPED := FALSE;
                 INC (AC, EQUIPMENT[C].PROTECTION);
                 WRITECHARACTER (INT, FALSE);
               END;
             ROSTER[T].EQUIPMENT[J] := EQUIPMENT[C];
             EQUIPMENT[C] := SCUM;
             CONDENSEEQUIPMENT (ROSTER[INT]);
           END
         ELSE
           BEGIN
             BAR (120, 90, 120, 105);
             OUTTEXTXY (120, 90, 'HE''S ALREADY FULL!!');
             MAKENOISE;
             TDELAY (THYME);
           END;
       END; {OF WITH ROSTER[INT]}

END; {OF PROCEDURE TRADEITEM}

{*******************************************************************}

FUNCTION CANUSE : BOOLEAN;

BEGIN
     WITH ROSTER[INT].EQUIPMENT[C] DO
       BEGIN
         FULL := FALSE;
         CASE ROSTER[INT].CLASS[4] OF
           'B' : IF NOTUSEDBY IN ['A', 'R', 'I', 'C', 'D', 'E'] THEN
                   FULL := TRUE;
           'H' : IF NOTUSEDBY IN ['A', 'R', 'I', 'C', 'D', 'E', 'N'] THEN
                   FULL := TRUE;
           'K' : IF NOTUSEDBY IN ['A', 'J', 'R', 'I', 'C', 'D', 'M'] THEN
                   FULL := TRUE;
           'E' : IF NOTUSEDBY IN ['A', 'J', 'R', 'I', 'D', 'L'] THEN
                   FULL := TRUE;
           'R' : IF NOTUSEDBY IN ['A', 'H', 'J', 'G', 'I', 'C'] THEN
                   FULL := TRUE;
           'I' : IF NOTUSEDBY IN ['A', 'H', 'J', 'R', 'K'] THEN
                   FULL := TRUE;
         END; {OF CASE}
         CANUSE := FULL;
       END; {OF WITH ROSTER[INT].EQUIPMENT[C]}

END; {OF PROCEDURE CANUSE}

{*******************************************************************}

FUNCTION CHECKEQUIPED : BOOLEAN;

BEGIN
     IF CANUSE THEN
       BEGIN
         FULL := TRUE;
         PSEUDONYM := '        ';
         TEMP2 := 0;
         STRINGONE := ROSTER[INT].EQUIPMENT[C].WHATTYPE;
         FOR J := 1 TO 8 DO
           WITH ROSTER[INT].EQUIPMENT[J] DO
             IF (WHATTYPE = ' ') OR (NOT EQUIPED) THEN
               PSEUDONYM[J] := ' '
             ELSE
               BEGIN
                 PSEUDONYM[J] := WHATTYPE;
                 IF (WHATTYPE = 'S') OR (WHATTYPE = 'O') THEN
                   INC (TEMP2)
                 ELSE
                   IF (WHATTYPE = 'T') THEN
                     INC (TEMP2, 2);
               END;{OF ELSE}
         FOR J := 1 TO 8 DO
           CASE STRINGONE[1] OF
             'A' : IF 'A' = PSEUDONYM[J] THEN
                     FULL := FALSE;
             'S' : IF ('S' = PSEUDONYM[J]) OR (TEMP2 > 1) THEN
                     FULL := FALSE;
             'H' : IF 'H' = PSEUDONYM[J] THEN
                     FULL := FALSE;
             'G' : IF 'G' = PSEUDONYM[J] THEN
                     FULL := FALSE;
             'O' : IF (TEMP2 > 1) THEN
                     FULL := FALSE;
             'T' : IF (TEMP2 > 0) THEN
                     FULL := FALSE;
             'R' : IF 'R' = PSEUDONYM[J] THEN
                     FULL := FALSE;
             'C' : IF 'C' = PSEUDONYM[J] THEN
                     FULL := FALSE;
             'K' : FULL := FALSE;
           END; {OF CASE}
       END;
     CHECKEQUIPED := FULL;

END; {OF CHECKEQUIPED}

{*******************************************************************}

PROCEDURE EQUIP (CH : CHAR);

BEGIN
     VAL (CH, C, CODE);
     IF (CODE = 0) AND (C > 0) AND (C < 9) THEN
       WITH ROSTER[INT].EQUIPMENT[C] DO
         IF ITEM <> '' THEN
           IF EQUIPED THEN
             BEGIN
               INC (ROSTER[INT].AC, PROTECTION);
               EQUIPED := FALSE
             END
           ELSE
             IF CHECKEQUIPED THEN
               BEGIN
                 DEC (ROSTER[INT].AC, PROTECTION);
                 EQUIPED := TRUE;
               END
             ELSE
               BEGIN
                 OUTTEXTXY (120, 95, 'YOU CAN''T EQUIP THAT!');
                 TDELAY (THYME);
               END;

END; {OF PROCEDURE EQUIP}

{*******************************************************************}

PROCEDURE READLINE (VAR INPUTSTR : STRING20; C, I, K :INTEGER);

BEGIN
     INPUTSTR := '';
     T := 0;
     CHECK := TRUE;
     FULL := FALSE;
     REPEAT
       BAR (I, K, 540, K+10);
       OUTTEXTXY (I, K, INPUTSTR);
       CH := UREADKEY;
       CASE CH OF
         #32..#125 : BEGIN
                       IF CHECK THEN
                         INPUTSTR := '';
                       IF LENGTH(INPUTSTR) < C THEN
                         IF (T <> 0) OR ((T = 0) AND (CH <> ' ')) THEN
                           BEGIN
                             INC (T);
                             INSERT (CH, INPUTSTR, T);
                           END;
                     END;
         #8 : IF T > 0 THEN
                   BEGIN
                     DELETE (INPUTSTR, T, 1);
                     DEC (T);
                   END;
         #13 : IF (ORD (INPUTSTR[1]) <= 125) AND (ORD (INPUTSTR[1]) >= 32)
                  AND (INPUTSTR <> '') THEN
                 FULL := TRUE;
      ELSE
        MAKENOISE;
      END; {OF CASE}
      CHECK := FALSE;
  UNTIL FULL;

END; {OF READLINE}

{*******************************************************************}

PROCEDURE CHANGEDELAY;

BEGIN
     CLEAR;
     STR (THYME, HPNUM);
     OUTTEXTXY (170, 45, 'WHAT DO YOU WANT THE DELAY TO BE?');
     OUTTEXTXY (170, 55, '(1 TO 999) CURRENT SETTING = '+HPNUM);
     OUTTEXTXY (260, 65, '>');
     REPEAT
       READLINE (INPUTSTR, 3, 270, 65);
       VAL (INPUTSTR, THYME, CODE);
     UNTIL (THYME > 0) AND (THYME < 1000) AND (CODE = 0);

END; {OF PROCEDURE CHANGEDELAY}

{*******************************************************************}

PROCEDURE ADJUSTHP;

BEGIN
     WITH CHARACTER DO
       IF ABILITIES[5] > 16 THEN
         BEGIN
           INC (HPTOT, (ABILITIES[5]-17));
           INC (HPLEFT, (ABILITIES[5]-17));
         END;

END; {OF PROCEDURE ADJUSTHP}

{*******************************************************************}

PROCEDURE ADJUSTACTHACO;

BEGIN
     WITH CHARACTER DO
       IF ABILITIES[4] > 16 THEN
         BEGIN
           AC := 10-(ABILITIES[4]-16);
           FOR J := 1 TO 8 DO
             IF EQUIPMENT[J].EQUIPED THEN
               DEC (AC, EQUIPMENT[J].PROTECTION);
           DEC (THACO, (ABILITIES[4]-16));
         END;

END; {OF PROCEDURE ADJUSTACTHACO}

{*******************************************************************}

PROCEDURE ADJUSTSP;

BEGIN
     WITH ROSTER[INT] DO
       IF ABILITIES[2] > 16 THEN
         BEGIN
           TEMP := 2*(ABILITIES[2]-16);
           INC (SPELLPTSTOT, TEMP);
           INC (SPELLPTLEFT, TEMP);
         END;

END; {OF PROCEDURE ADJUSTSP}

{*******************************************************************}

PROCEDURE ABILADJUST (VAR CHARACTER : PERSON);

BEGIN
     WITH CHARACTER DO
       BEGIN
         THACO := 17;
         CASE CLASS[4] OF
           'B' : BEGIN
                   IF ABILITIES[1] > 16 THEN
                     DAMAGE := (ABILITIES[1]-16);
                   ADJUSTHP;
                   INC (HPTOT, 2);
                   INC (HPLEFT, 2);
                 END;
           'H' : BEGIN
                   IF ABILITIES[1] > 16 THEN
                     DAMAGE := (ABILITIES[1]-16);
                   ADJUSTACTHACO;
                   ADJUSTHP;
                 END;
           'K' : BEGIN
                   IF ABILITIES[1] > 16 THEN
                     DAMAGE := (ABILITIES[1]-16);
                   ADJUSTACTHACO;
                   DEC (AC, (LEVEL DIV 3)*2);
                 END;
           'E' : BEGIN
                   ADJUSTACTHACO;
                   ADJUSTHP;
                 END;
           'R' : BEGIN
                   ADJUSTSP;
                   ADJUSTACTHACO;
                 END;
           'I' : BEGIN
                   ADJUSTSP;
                   ADJUSTHP;
                 END;
         END; {OF CASE}
         DEC (THACO, LEVEL DIV 2);
         INC (DAMAGE, 1);
       END; {WITH CHARACTER}

END; {OF PROCEDURE ABILADJUST}

{*******************************************************************}

PROCEDURE FINDMONSTER;

BEGIN
     BEFORE := START;
     WHILE (BEFORE^.NEXT^.GROUP <> ROSTER[INT].ATTGROUP) AND
           (BEFORE^.NEXT <> NIL) DO
       BEFORE := BEFORE^.NEXT;
     IF (BEFORE^.NEXT^.GROUP = ROSTER[INT].ATTGROUP) AND (BEFORE^.NEXT <> NIL) THEN
       BEGIN
         FIND := BEFORE^.NEXT;
         IF FIND^.NEXT <> NIL THEN
           PTR := FIND^.NEXT
         ELSE
           PTR := NIL;
       END;

END; {OF PROCEDURE FINDMONSTER}

{*******************************************************************}

PROCEDURE PLACEATEND;

BEGIN
     IF CHECK THEN
       BEGIN
         START := START^.NEXT;
         LAST^.NEXT := BEFORE;
         LAST := BEFORE;
         LAST^.NEXT := NIL;
         LAST^.NUMBER  := -1;
         BEFORE := START;
       END
     ELSE
       BEGIN
         BEFORE^.NEXT := FIND^.NEXT;
         LAST^.NEXT := FIND;
         LAST := FIND;
         LAST^.NEXT := NIL;
         LAST^.NUMBER := -1;
       END;

END; {OF PROCEDURE PLACEATEND}

{*******************************************************************}
{*******************************************************************}

PROCEDURE GETNUMBERS;

BEGIN
     NUMSTR := '  ';
     NUMSTR2 := '  ';
     IF LENGTH (MIDWORD^.WORDS) = 5 THEN
       BEGIN
         NUMSTR[1] := MIDWORD^.WORDS[1];
         NUMSTR[2] := MIDWORD^.WORDS[2];
         NUMSTR2[1] := MIDWORD^.WORDS[4];
         NUMSTR2[2] := MIDWORD^.WORDS[5];
       END
     ELSE
       BEGIN
         NUMSTR[1] := '0';
         NUMSTR[2] := MIDWORD^.WORDS[1];
         NUMSTR2[1] := MIDWORD^.WORDS[3];
         NUMSTR2[2] := MIDWORD^.WORDS[4];
       END;
     VAL (NUMSTR, TEMP, CODE);
     VAL (NUMSTR2, TEMP2, CODE);

END; {OF PROCEDURE GETNUMBERS}

{*******************************************************************}

PROCEDURE SPECIALTELEPORT;

BEGIN
     NUMSTR := '  ';
     NUMSTR2 := '  ';
     NUMSTR[1] := ROOM[6];
     NUMSTR[2] := ROOM[7];
     NUMSTR2[1] := ROOM[8];
     NUMSTR2[2] := ROOM[9];
     VAL (NUMSTR, TEMP, CODE);
     VAL (NUMSTR2, TEMP2, CODE);
     N := TEMP;
     E := TEMP2;

END; {OF PROCEDURE TELEPORT}

{*******************************************************************}

PROCEDURE OTHERS;

BEGIN
     FOR INT := 0 TO PEOPLE DO
       WITH ROSTER[INT] DO
         BEGIN
           VAL (DATA[J,K][9], TEMP2, CODE);
           TEMP := RANDOM(TEMP2)+1;
           IF DATA[J,K][7] = '2' THEN
             TEMP := -1*TEMP;
           IF DATA[J,K][8] = '1' THEN
             BEGIN
               INC (HPLEFT, TEMP);
               IF (HPLEFT > HPTOT) THEN
                 HPLEFT := HPTOT;
             END
           ELSE
             BEGIN
               IF (CLASS[4] IN ['R', 'I']) THEN
                 INC (SPELLPTLEFT, TEMP);
               IF (SPELLPTLEFT > SPELLPTSTOT) THEN
                 SPELLPTLEFT := SPELLPTSTOT;
               IF (SPELLPTLEFT < 0) THEN
                 SPELLPTLEFT := 0;
             END;
           CHECKFORDEAD (INT);
         END;

END; {OF PROCEDURE LOOSEHP}

{*******************************************************************}

PROCEDURE JUMPERS;

BEGIN
     INT := 0;
     J := 0;
     REPEAT
       REPEAT
         WITH ROSTER[INT].EQUIPMENT[J] DO
           IF (WHATTYPE = 'R') AND (ITEM = 'NO JUMPER RING') THEN
             BEGIN
               DEC (CHARGES);
               CONDENSEEQUIPMENT (ROSTER[INT]);
               EXIT;
             END;
         INC (J);
       UNTIL J = 8;
       INC (INT);
     UNTIL INT = PEOPLE;
     INC (N, (RANDOM(3)-1));
     INC (E, (RANDOM(3)-1));
     INT := 0;
     J := 0;
     REPEAT
       REPEAT
         IF (ROSTER[INT].EQUIPMENT[J].WHATTYPE = 'C') THEN
           BEGIN
             OUTTEXTXY (200, 15, 'YOU''VE JUST PASSED THROUGH A JUMPER SQUARE!');
             TDELAY (THYME);
             EXIT;
           END;
         INC (J);
       UNTIL J = 8;
       INC (INT);
     UNTIL INT = PEOPLE;

END; {OF PROCEDURE JUMPERS}

{*******************************************************************}

PROCEDURE SPINNERS;

BEGIN
     INT := 0;
     J := 0;
     REPEAT
       REPEAT
         IF (ROSTER[INT].EQUIPMENT[J].WHATTYPE = 'R') AND
            (ROSTER[INT].EQUIPMENT[J].ITEM = 'NO SPIN RING') THEN
           EXIT;
         INC (J);
       UNTIL J = 8;
       INC (INT);
     UNTIL INT = PEOPLE;
     CASE RANDOM(4)+1 OF
       1 : DIRECTION := 'N';
       2 : DIRECTION := 'S';
       3 : DIRECTION := 'E';
       4 : DIRECTION := 'W';
     END; {OF CASE}

END; {OF PROCEDURE SPINNERS}

{*******************************************************************}

PROCEDURE DELMIDWORDS;

BEGIN
     WORDSTART := MIDWORD^.NEXT;
     MIDWORD^.WORDS := 'KJDF';
     DISPOSE (MIDWORD);
     MIDWORD := WORDSTART;

END; {OF PROCEDURE DELMIDWORDS}

{*******************************************************************}

PROCEDURE PRINTMESSAGES;

BEGIN
     CLEAR;
     L := 1;
     LEN := 25;
     WHILE (MIDWORD^.WORDS[1] <> '/') OR (MIDWORD^.WORDS = '/#L') DO
       BEGIN
         IF (MIDWORD^.WORDS  <> '/#L') AND (LEN < 360) THEN
           BEGIN
             SETCOLOR (LTGREEN);
             IF (MIDWORD^.WORDS[1] IN ['.', ',', '!', '?', '-']) AND (LEN > 0) THEN
               DEC (LEN, 8);
             OUTTEXTXY (130+LEN, 10+(L*10), MIDWORD^.WORDS);
             INC (LEN, (LENGTH (MIDWORD^.WORDS) + 1) SHL 3);
             DELMIDWORDS;
           END
         ELSE
           BEGIN
             LEN := 0;
             IF MIDWORD^.WORDS = '/#L' THEN
               BEGIN
                 DELMIDWORDS;
                 LEN := 25;
               END;
             INC (L);
           END;
         IF L = 8 THEN
           BEGIN
             LEN := 0;
             L := 1;
             SETCOLOR (CYAN);
             OUTTEXTXY (200, 90, 'PRESS SPACE BAR TO CONTINUE . . . ');
             REPEAT
               CH := UREADKEY;
             UNTIL CH = ' ';
             CLEAR;
           END;
       END; {OF WHILE LOOP}

END; {OF PROCEDURE PRINTMESSAGES}

{*******************************************************************}

PROCEDURE QUESTIONS;

BEGIN
     INC (L);
     OUTTEXTXY (130, 10+(L*10), '>');
     READLINE (INPUTSTR, 20, 140, 10+(L*10));
     DELMIDWORDS;
     IF INPUTSTR <> MIDWORD^.WORDS THEN
       BEGIN
         REPEAT
           DELMIDWORDS;
         UNTIL MIDWORD^.WORDS = '/#W';
       END;
     DELMIDWORDS;

END; {OF PROCEDURE QUESTIONS}

{*******************************************************************}

PROCEDURE PLACESTAIRS;

BEGIN
     GETNUMBERS;
     IF HPNUM[4] = 'U' THEN
       DATA[TEMP, TEMP2][5] := '3'
     ELSE
       DATA[TEMP, TEMP2][5] := '4';
     DELMIDWORDS;

END; {OF PROCEDURE PLACESTAIRS}

{*******************************************************************}

PROCEDURE REMOVEMESS;

BEGIN
     GETNUMBERS;
     DATA[TEMP,TEMP2][5] := '1';
     DATA[TEMP,TEMP2][6] := '0';
     DATA[TEMP,TEMP2][7] := '0';
     DATA[TEMP,TEMP2][8] := '0';
     DATA[TEMP,TEMP2][9] := '4';
     DELMIDWORDS;

END; {OF PROCEDURE REMOVEMESS}

{*******************************************************************}

PROCEDURE NEWPLACE;

BEGIN
     GETNUMBERS;
     N := TEMP;
     E := TEMP2;
     INT := LEV;
     NUMSTR := ' ';
     IF LENGTH (MIDWORD^.WORDS) = 5 THEN
       NUMSTR := MIDWORD^.WORDS[3]
     ELSE
       NUMSTR := MIDWORD^.WORDS[2];
     VAL (NUMSTR, LEV, CODE);
     IF LEV <> INT THEN
       GETMAZE;
     DELMIDWORDS;

END; {OF PROCEDURE NEWPLACE}

{*******************************************************************}

PROCEDURE CHANGEBOOLEAN;

BEGIN
     IF FILENAME1[10] = '1' THEN
       BEGIN
         IF LIGHTSP THEN
           LIGHTSP := FALSE;
         LGLIGHTSP := NOT LGLIGHTSP;
         LIGHTICON (LGLIGHTSP);
       END
     ELSE
       PSTAIRS := TRUE;

END; {OF PROCEDURE CHANGEBOOLEAN}

{*******************************************************************}

PROCEDURE GETOBJECT;

BEGIN
     INT := 0;
     FOR C := 1 TO PEOPLE DO
       IF (FINDPLACE (ROSTER[C])) AND (ROSTER[C].SPECIAL IN [OK, POISON]) THEN
         INT := C;
     WITH ROSTER[INT] DO
       IF INT <> 0 THEN
         BEGIN
           VAL (MIDWORD^.WORDS, BIGNUM, CODE);
           DELMIDWORDS;
           RESET (SHOPFILE);
           SEEK (SHOPFILE, BIGNUM);
           READ (SHOPFILE, EQUIPMENT[J]);
           IF IORESULT <> 0 THEN
             DISKERROR ('DSDATA.F10', TRUE);
           CLOSE (SHOPFILE);
           CLEAR;
           OUTTEXTXY (120, 55, NAME+' FOUND A '+EQUIPMENT[J].ITEM+'!');
         END;

END; {OF PROCEDURE GETOBJECT}

{*******************************************************************}

PROCEDURE CHECKFORSOMETHING;

VAR
   BRONZE, SILVER, GOLD : BOOLEAN;

BEGIN
     IF MIDWORD^.WORDS = '2' THEN
       BEGIN
         BRONZE := FALSE;
         SILVER := FALSE;
         GOLD := FALSE;
         FOR INT := 1 TO PEOPLE DO
           FOR J := 1 TO 8 DO
             BEGIN
               IF ROSTER[INT].EQUIPMENT[J].ITEM = 'BRONZE KEY' THEN
                 BRONZE := TRUE;
               IF ROSTER[INT].EQUIPMENT[J].ITEM = 'SILVER KEY' THEN
                 SILVER := TRUE;
               IF ROSTER[INT].EQUIPMENT[J].ITEM = 'GOLD KEY' THEN
                 GOLD := TRUE;
             END;
         IF (BRONZE) AND (SILVER) AND (GOLD) THEN
           REPEAT
             DELMIDWORDS;
           UNTIL MIDWORD^.WORDS = '/#Z';
       END
     ELSE
       IF NOT PSTAIRS THEN
         BEGIN
           REPEAT
             DELMIDWORDS;
           UNTIL MIDWORD^.WORDS = '/#W';
           DELMIDWORDS;
         END;
     DELMIDWORDS;

END; {OF PROCEDURE CHECKFORSOMETHING}

{*******************************************************************}

PROCEDURE DODMG;

BEGIN
     FOR INT := 0 TO PEOPLE DO
       BEGIN
         DEC (ROSTER[INT].HPLEFT, RANDOM (15)+1);
         CHECKFORDEAD (INT);
       END;

END; {OF PROCEDURE DODMG}

{*******************************************************************}

PROCEDURE GETEXP;

BEGIN
     CLEAR;
     OUTTEXTXY (120, 45, 'YOU''RE VALIANT EFFORTS REWARD YOU,');
     OUTTEXTXY (120, 55, 'YOU RECIEVE 1,000,000 EXPERIANCE POINTS');
     OUTTEXTXY (120, 65, 'FOR DEFEATING THE EVIL DRAGON!');
     FOR INT := 1 TO PEOPLE DO
       INC (ROSTER[INT].EXP, 1000000);

END; {OF PROCEDURE GETEXP}

{*******************************************************************}

PROCEDURE GETBATTLE (PLACE, J, NUMBER : INTEGER);

BEGIN
     SEEK (MONSDATA, PLACE);
     READ (MONSDATA, ENCOUNTER[J]);
     IF IORESULT <> 0 THEN
       DISKERROR ('DSDATA.F10', TRUE);
     ENCOUNTER[J].NUMBER := NUMBER;

END;

{*******************************************************************}

PROCEDURE BATTLES;

BEGIN
     FOR J := 1 TO 4 DO
       WITH ENCOUNTER[J] DO
         BEGIN
             NAME := '';
             NUMBER := 0;
             EXPERIENCEPER := 0;
             HITSTOKILL := 0;
         END; {OF WITH ENCOUNTER[J]}
     RESET (MONSDATA);
     VAL (MIDWORD^.WORDS, BIGNUM, CODE);
     GROUPTOT := 1;
     CASE BIGNUM OF
       1  : BEGIN
              FOR J := 1 TO 2 DO
                GETBATTLE (57, J, 5);
              GETBATTLE (360, 3, 1);
              GROUPTOT := 3;
            END;
       2  : BEGIN
              GETBATTLE (140, 1, 2);
              FOR J := 2 TO 3 DO
                GETBATTLE (137, J, 2);
              GETBATTLE (361, 4, 1);
              GROUPTOT := 3;
            END;
       3  : BEGIN
              FOR J := 1 TO 2 DO
                GETBATTLE (169, J, 6);
              GROUPTOT := 2;
            END;
       4  : BEGIN
              GETBATTLE (190, 1, 3);
              GETBATTLE (186, 2, 5);
              GETBATTLE (362, 3, 1);
              GROUPTOT := 3;
            END;
       5  : GETBATTLE (204, 1, 1);
       6  : GETBATTLE (205, 1, 1);
       7  : GETBATTLE (224, 1, 1);
       8  : GETBATTLE (225, 1, 1);
       9  : GETBATTLE (223, 1, 1);
       10 : GETBATTLE (212, 1, 1);
       11 : GETBATTLE (214, 1, 1);
       12 : GETBATTLE (206, 1, 1);
       13 : BEGIN
              FOR J := 1 TO 2 DO
                GETBATTLE (247, J, 3);
              GETBATTLE (244, 3, 5);
              GETBATTLE (363, 4, 1);
              GROUPTOT := 4;
            END;
       14 : GETBATTLE (365, 1, 1);
       15 : BEGIN
              FOR J := 1 TO 2 DO
                GETBATTLE (335, J, 8);
              GROUPTOT := 2;
            END;
       16 : BEGIN
              GETBATTLE (328, 1, 2);
              GETBATTLE (358, 2, 1);
              GETBATTLE (351, 3, 1);
              GETBATTLE (364, 4, 1);
              GROUPTOT := 4;
            END;
       17 : GETBATTLE (365, 1, 1);
     END; {OF CASE}
     CLOSE (MONSDATA);
     NORUN := TRUE;
     BEGINENCOUNTER;
     DELMIDWORDS;

END; {OF PROCEDURE BATTLES}

{*******************************************************************}

PROCEDURE USEMESSAGES;

BEGIN
     REPEAT
       HPNUM := MIDWORD^.WORDS;
       DELMIDWORDS;
       CASE HPNUM[3] OF
         'M' : PRINTMESSAGES;
         'Q' : QUESTIONS;
         'B' : BATTLES;
         'P' : PLACESTAIRS;
         'G' : GETOBJECT;
         'R' : REMOVEMESS;
         'Z' : IGNORE := TRUE;
         'C' : CHECKFORSOMETHING;
         'H' : CHANGEBOOLEAN;
         'N' : NEWPLACE;
         'W' : WHILE MIDWORD^.WORDS <> '/#Z' DO
                 DELMIDWORDS;
         'X' : GETEXP;
         'D' : DODMG;
         'S' : FOR INT := 1 TO PEOPLE DO
                 BEGIN
                   ROSTER[INT].SPELLPTLEFT := ROSTER[INT].SPELLPTSTOT;
                   WRITECHARACTER (INT, FALSE);
                 END;
         'E' : BEGIN
                 OUTTEXTXY (200, 90, 'PRESS SPACE BAR TO CONTINUE . . . ');
                 REPEAT
                   CH := UREADKEY;
                 UNTIL CH = ' ';

                 HALT (0);
               END;
         'A' :; {DO NOTHING HERE}
         'F' :; {DO NOTHING HERE}
       END; {OF CASE}
     UNTIL IGNORE;

END; {OF PROCEDURE USEMESSAGES}

{*******************************************************************}

PROCEDURE GETMESSAGES;

VAR
   LOADM : FILE OF INTEGER;
   LOCAL : INTEGER;

BEGIN
     HPNUM := '   ';
     FOR J := 1 TO 3 DO
       HPNUM[J] := ROOM[6+J];
     VAL (HPNUM, GRMODE, CODE);
     ASSIGN (LOADM, 'DSDATA.F09');
     RESET (LOADM);
     NEW (WORDSTART);
     MIDWORD := WORDSTART;
     SEEK (LOADM, GRMODE);
     READ (LOADM, LOCAL);
     IF IORESULT <> 0 THEN
       DISKERROR ('DSDATA.F09', TRUE);
     SEEK (LOADM, LOCAL);
     REPEAT
       READ (LOADM, LOCAL);
       IF IORESULT <> 0 THEN
         DISKERROR ('DSDATA.F09', TRUE);
       MIDWORD^.WORDS := WORDLIST^[LOCAL];
       IF (MIDWORD^.WORDS[1] = '/') AND
          (MIDWORD^.WORDS[3] IN ['B', 'C', 'P', 'D', 'G', 'N', 'R']) THEN
         BEGIN
           NEW (WORDEND);
           MIDWORD^.NEXT := WORDEND;
           MIDWORD := WORDEND;
           READ (LOADM, LOCAL);
           IF IORESULT <> 0 THEN
             DISKERROR ('DSDATA.F09', TRUE);
           STR (LOCAL, MIDWORD^.WORDS);
         END;
       IF MIDWORD^.WORDS <> '/#Z' THEN
         BEGIN
           NEW (WORDEND);
           MIDWORD^.NEXT := WORDEND;
           MIDWORD := WORDEND;
         END
       ELSE
         MIDWORD^.NEXT := NIL;
     UNTIL MIDWORD^.WORDS = '/#Z';
     MIDWORD := WORDSTART;
     CLOSE (LOADM);
     USEMESSAGES;

END; {OF PROCEDURE GETMESSAGES}

{*******************************************************************}

PROCEDURE GETSPECIAL;

BEGIN
     CHECK := TRUE;
     IF NOT IGNORE THEN
       CASE ROOM[5] OF
{NO}     '1' :;
         '5' : CASE ROOM[6] OF
{MESSAGES}       '1' : BEGIN
                         GETMESSAGES;
                         SETCOLOR (CYAN);
                         OUTTEXTXY (200, 90, 'PRESS SPACE BAR TO CONTINUE . . . ');
                         REPEAT
                           CH := READKEY;
                         UNTIL CH = ' ';
                       END;
{SPINNERS}       '3' : BEGIN
                         SPINNERS;
                         IGNORE := TRUE;
                       END;
{JUMPERS}        '5' : JUMPERS;
{OTHERS}         '6' : BEGIN
                         OTHERS;
                         IGNORE := TRUE;
                       END;
{ANIT-MAGIC}     '2' : BEGIN
                         SPELL := FALSE;
                         IGNORE := TRUE;
                       END;
{DARKNESS}       '4' : IGNORE := TRUE;
               END; {OF CASE}
{TELE}   '2' : SPECIALTELEPORT;
{UP}     '3' : BEGIN
                 TAKESTAIRS (TRUE);
                 IGNORE := TRUE;
               END;
{DOWN}   '4' : BEGIN
                 TAKESTAIRS (FALSE);
                 IGNORE := TRUE;
               END;
{GUILD}  '6' : BEGIN
                 GUILDSTUFF;
                 IGNORE := TRUE;
               END;
{BANK}   '7' : BEGIN
                 BANKSTUFF;
                 IGNORE := TRUE;
               END;
{SHOP}   '8' : BEGIN
                 SHOPSTUFF;
                 IGNORE := TRUE;
               END;
{TEMP}   '9' : BEGIN
                 TEMPLESTUFF;
                 IGNORE := TRUE;
               END;
{HALL}   '0' : BEGIN
                 HALLSTUFF;
                 IGNORE := TRUE;
               END;
       END; {OF CASE}

END; {OF PROCEDURE GETSPECIAL}

{*******************************************************************}

PROCEDURE CHECKSPECIAL;

BEGIN
     REPEAT
       IF NOT PASS THEN
         BEGIN
           IF ROOM[5] <> '1' THEN
             GETSPECIAL
           ELSE
             IGNORE := TRUE;
           ROOM := DATA[N,E];
        END;
     UNTIL (ROOM[5] <> '2') AND (ROOM[6] <> '5') AND (IGNORE);

END; {OF PROCEDURE CHECKSPECIAL}

{*******************************************************************}
{*******************************************************************}

PROCEDURE GETUSES;

BEGIN
     CLEAR;
     WITH ROSTER[INT] DO
       BEGIN
         OUTTEXTXY (120, 5, NAME+' CAN USE THE FOLLOWING.');
         K := 0;
         FOR J := 1 TO 8 DO
           IF (EQUIPMENT[J].USE <> -1) AND (EQUIPMENT[J].USE <> 0) THEN
             BEGIN
               INC (K);
               STR (K, HPNUM);
               OUTTEXTXY (120, 15+(9*(K-1)), HPNUM+') '+EQUIPMENT[J].ITEM);
             END;
         OUTTEXTXY (120, 90, 'WHAT DOES HE WISH TO USE?');
         C := GETPERSON (0, K+1);
         J := 0;
         IF C <> -10 THEN
           WHILE C <> 0 DO
             BEGIN
               INC (J);
               IF (EQUIPMENT[J].USE <> -1) AND (EQUIPMENT[J].USE <> 0) THEN
                 DEC (C);
             END
         ELSE
           BEGIN
             CLEAR;
             SHOWENCOUNTER;
           END;
       END; {OF WITH ROSTER[INT]}

END; {OF PROCEDURE GETUSES}

{*******************************************************************}

PROCEDURE WHOON;

BEGIN
     WITH ROSTER[INT].EQUIPMENT[J] DO
       IF (USE <= 5) OR ((USE >= 16) AND (USE <= 19)) THEN
         BEGIN
           CLEAR;
           OUTTEXTXY (120, 65, 'USE THE '+ITEM+' ON WHOM?');
           IF USE IN [6, 7] THEN
             BEGIN
               SHOWENCOUNTER;
               SINT := GETPERSON (0, GROUPTOT+1);
             END
           ELSE
             SINT := GETPERSON (0, PEOPLE+1);
           CLEAR;
         END;

END; {OF PROCEDURE WHOON}

{*******************************************************************}

PROCEDURE ADDEXP;

BEGIN
     IF RANDOM(100) > 15 THEN
       INC (ROSTER[SINT].EXP, 25000)
     ELSE
       BEGIN
         ROSTER[SINT].SPECIAL := DEAD;
         WRITECHARACTER (SINT, FALSE);
       END;

END; {OF PROCEDURE ADD EXP}

{*******************************************************************}

PROCEDURE GOUSE;

BEGIN
     WITH ROSTER[INT].EQUIPMENT[J] DO
       BEGIN
         CASE USE OF
           1  : ADDEXP;
           2  : CURING (DMG, SINT);
           3  : BEGIN
                  ROSTER[SINT].SPELLPTLEFT := ROSTER[SINT].SPELLPTSTOT;
                  WRITECHARACTER (SINT, TRUE);
                END;
           4  : FIX (STONE, DMG, SINT);
           5  : FIX (PARALYS, DMG, SINT);
           6  : IF FIGHT THEN
                  AGROUP (18, 1, 'N', DMG);
           7  : IF FIGHT THEN
                  ALLMONSTERS (1, 'N', DMG);
           8  : BEGIN
                  LIGHTSP := TRUE;
                  LIGHTICON (TRUE);
                END;
           9 : BEGIN
                  LGLIGHTSP := TRUE;
                  LIGHTICON (TRUE);
                END;
           10 : LOCATE;
           11 : BEGIN
                  COMPAS := TRUE;
                  COMPASSICON (TRUE);
                END;
           12 : SHIELD (1);
           13 : IF NOT FIGHT THEN
                  RECALL;
           14 : JUMPERS;
           15 : IF FIGHT THEN
                  ALLMONSTERS (1, 'N', 45);
           16 : FIX (POISON, 100, SINT);
           17 : FIX (PARALYS, 100, SINT);
           18 : FIX (STONE, 100, SINT);
           19 : FIX (DEAD, 100, SINT);
           20 : IF (FIGHT) AND (ENCOUNTER[1].NAME = 'OIJNGATE') THEN
                  BEGIN
                    OUTTEXTXY (120, 65, 'A BLINDING FLASH OF LIGHT LEAPS FROM THE SWORD!');
                    OUTTEXTXY (120, 75, 'OIJNGATE BELLOWS IN TERRIFIC PAIN!!');
                    TDELAY (THYME);
                    DEC (HITSTOKILL[1], 2);
                    IF HITSTOKILL[1] < 0 THEN
                      FIGHT := FALSE;
                  END;
         END; {OF CASE}
       IF CHARGES > 0 THEN
         DEC (CHARGES);
       IF CHARGES = 0 THEN
         ITEM := '';
       CONDENSEEQUIPMENT (ROSTER[INT]);
     END; {OF WITH ROSTER[INT].EQUIPMENT[J] DO}

END; {OF PROCEDURE GOUSE}

{*******************************************************************}

PROCEDURE USE;

BEGIN
     GETUSES;
     IF J <> -10 THEN
       BEGIN
         WHOON;
         GOUSE;
       END
     ELSE
       ATTACK;

END; {OF PROCEDURE USE}

{*******************************************************************}

END. {OF UNIT GENERAL}