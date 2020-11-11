UNIT CITY;

INTERFACE

USES
    CRT, DOS, GRAPH, VARIABLE;

PROCEDURE BANKSTUFF;
PROCEDURE HALLSTUFF;
PROCEDURE TEMPLESTUFF;
PROCEDURE SHOPSTUFF;
FUNCTION FINDPLACE (CHARACTER : PERSON) : BOOLEAN;
PROCEDURE GUILDSTUFF;

IMPLEMENTATION

USES
    DRAW, GENERAL, MAIN, SPELLS;

VAR
   ACCOUNT : LONGINT;
   LOADPERSON : FILE OF PERSON;

CONST
     X = 430;
     Y = 35;

{*******************************************************************}

PROCEDURE NEWDIR;

BEGIN
     CASE DIRECTION OF
       'N' : BEGIN
               INC (N);
               DIRECTION := 'S';
             END;
       'S' : BEGIN
               DEC (N);
               DIRECTION := 'N';
             END;
       'E' : BEGIN
               DEC (E);
               DIRECTION := 'W';
             END;
       'W' : BEGIN
               INC (E);
               DIRECTION := 'E';
             END;
     END; {OF CASE}

END; {OD PROCEDURE NEWDIR}

{*******************************************************************}

PROCEDURE BANKMENU;

BEGIN
     CLEAR;
     OUTTEXTXY (160, 25, 'WHAT TYPE OF TRANSACTION DO YOU WISH?');
     OUTTEXTXY (240, 45, '<P>OOL');
     OUTTEXTXY (240, 55, '<D>EPOSIT');
     OUTTEXTXY (240, 65, '<W>ITHDRAWL');
     OUTTEXTXY (240, 75, '<V>IEW ACCOUNT');
     OUTTEXTXY (240, 85, '<Q>UIT');

END; {BANKMENU}

{*******************************************************************}

PROCEDURE DEPOSIT;

BEGIN
     CLEAR;
     STR (ROSTER[INT].MONEY, OUTGOLD);
     OUTTEXTXY (120, 45, 'YOU HAVE:  '+OUTGOLD+' IN GOLD THAT YOU CAN DEPOSIT.');
     OUTTEXTXY (220, 55, 'HOW MUCH WILL YOU DEPOSIT?');
     REPEAT
       READLINE (OUTGOLD, 9, 270, 65);
       VAL (OUTGOLD, GOLD, CODE);
       IF CODE = 0 THEN
       IF GOLD <= ROSTER[INT].MONEY THEN
         BEGIN
           RESET (MON);
           READ (MON, ACCOUNT);
           IF IORESULT <> 0 THEN
             DISKERROR ('DSDATA.F06', TRUE);
           CLOSE (MON);
           INC (ACCOUNT, GOLD);
           IF ACCOUNT <= 999999999 THEN
             BEGIN
               DEC (ROSTER[INT].MONEY, GOLD);
               REWRITE (MON);
               WRITE (MON, ACCOUNT);
               IF IORESULT <> 0 THEN
                 DISKERROR ('DSDATA.F06', FALSE);
               CLOSE (MON);
             END
           ELSE
             BEGIN
               OUTTEXTXY (180, 85, 'WE ARE SORRY, BUT IT IS AGAINST OUR POLICY');
               OUTTEXTXY (180, 95, 'TO LET ANYONE ACCUMULATE THAT MUCH MONEY.');
               TDELAY (THYME);
             END
         END
       ELSE
         IF ORD(GOLD) <> 13 THEN
           BEGIN
             OUTTEXTXY (220, 85, 'YOU DON''T HAVE THAT MUCH!');
             MAKENOISE;
             TDELAY (THYME);
           END;
     UNTIL CODE = 0;

END; {OF PROCEDURE DEPOSIT}

{*******************************************************************}

PROCEDURE WITHDRAW;

BEGIN
     RESET (MON);
     READ (MON, ACCOUNT);
     IF IORESULT <> 0 THEN
       DISKERROR ('DSDATA.F06', TRUE);
     CLOSE (MON);
     CLEAR;
     STR (ACCOUNT, OUTGOLD);
     OUTTEXTXY (160, 35, 'YOU NOW HAVE '+OUTGOLD+' GOLD ON ACCOUNT.');
     OUTTEXTXY (180, 55, 'HOW MUCH DO YOU WISH TO WITHDRAWL?');
     REPEAT
       READLINE (OUTGOLD, 9, 270, 65);
       VAL (OUTGOLD, GOLD, CODE);
       IF CODE = 0 THEN
         BEGIN
           DEC (ACCOUNT, GOLD);
           IF ACCOUNT < 0 THEN
             BEGIN
               INC (ACCOUNT, GOLD);
               OUTTEXTXY (190, 75, 'YOU CAN''T WITHDRAWL THAT MUCH!!');
               MAKENOISE;
               TDELAY (THYME);
             END
           ELSE
             BEGIN
               INC (ROSTER[INT].MONEY, GOLD);
               REWRITE (MON);
               WRITE (MON, ACCOUNT);
               IF IORESULT <> 0 THEN
                 DISKERROR ('DSDATA.F06', FALSE);
               CLOSE (MON);
             END;
         END;
     UNTIL CODE = 0;

END; {OF PROCEDURE WITHDRAW}

{*******************************************************************}

PROCEDURE VIEWACCOUNT;

BEGIN
     RESET (MON);
     READ (MON, ACCOUNT);
     IF IORESULT <> 0 THEN
       DISKERROR ('DSDATA.F06', TRUE);
     CLOSE (MON);
     STR (ACCOUNT, OUTGOLD);
     CLEAR;
     OUTTEXTXY (150, 55, 'YOU NOW HAVE '+OUTGOLD+' ON ACCOUNT.');
     LEN := LENGTH (OUTGOLD);
     TDELAY (LEN*THYME);

END; {OF PROCEDURE VIEWACCOUNT}

{*******************************************************************}

PROCEDURE BANKSTUFF;

BEGIN
     CLEAR;
     SETTEXTSTYLE (DEFAULTFONT, 0, 1);
     OUTTEXTXY (250, 45, 'YOU ENTER THE BANK.');
     OUTTEXTXY (195, 55, 'WHO WISHES TO MAKE A TRANSACTION?');
     INT := GETPERSON (0, PEOPLE + 1);
     WHILE (INT > 0) AND (RESPONCE <> 'Q') DO
       BEGIN
         BANKMENU;
         RESPONCE := UREADKEY;
         CASE RESPONCE OF
           'P' : POOL;
           'D' : DEPOSIT;
           'W' : WITHDRAW;
           'V' : VIEWACCOUNT;
           'Q' :; {DO NOTHING}
         ELSE
           MAKENOISE;
         END; {OF CASE}
       END; {OF WHILE}
     NEWDIR;

END; {BANKSTUFF}

{*******************************************************************}
{*******************************************************************}

PROCEDURE CHANGEABILITIES;

BEGIN
     C := 0;
     WITH ROSTER[INT] DO
       FOR J := 1 TO 7 DO
         IF (RANDOM(5)+1 <= 3) AND (ABILITIES[J] < 18) THEN
           BEGIN
             INC (C);
             IF (RANDOM(20)+ABILITIES[7])+ABILITIES[J] > 16  THEN
               BEGIN
                 SETCOLOR (LTRED);
                 INC (ABILITIES[J]);
                 HPNUM := 'UP!';
               END
             ELSE
               IF ABILITIES[J] > 4 THEN
                 BEGIN
                   SETCOLOR (DKRED);
                   DEC (ABILITIES[J]);
                   HPNUM := 'DOWN.';
                 END;
             CASE J OF
               1 : OUTTEXTXY (120, 35+C*9, 'YOUR STRENGTH WENT '+HPNUM);
               2 : OUTTEXTXY (120, 35+C*9, 'YOUR INTELIGENCE WENT '+HPNUM);
               3 : OUTTEXTXY (120, 35+C*9, 'YOUR WISDOM WENT '+HPNUM);
               4 : OUTTEXTXY (120, 35+C*9, 'YOUR DEXTERITY WENT '+HPNUM);
               5 : OUTTEXTXY (120, 35+C*9, 'YOUR CONSTITUTION WENT '+HPNUM);
               6 : OUTTEXTXY (120, 35+C*9, 'YOUR CHARISMA WENT '+HPNUM);
               7 : OUTTEXTXY (120, 35+C*9, 'YOUR LUCK WENT '+HPNUM);
             END; {OF CASE}
           END;

END; {OF PROCEDURE CHANGEABILITIES}

{*******************************************************************}

PROCEDURE MADELEVEL;

BEGIN
     WITH ROSTER[INT] DO
       BEGIN
         INC (LEVEL);
         TEMP := ABILITIES[5] DIV 6;
         TEMP2 := (ABILITIES[7]+ABILITIES[2]+ABILITIES[3]) DIV 9;
         CASE CLASS[4] OF
           'B' : C := RANDOM(6)+TEMP;
           'H' : C := RANDOM(5)+TEMP;
           'K' : C := RANDOM(4)+TEMP;
           'E' : C := RANDOM(2)+TEMP;
           'R' : BEGIN
                   C := RANDOM(4)+TEMP;
                   IF SPELLLEVEL < 10 THEN
                     SPELLLEVEL := (LEVEL DIV 2);
                   IF SPELLLEVEL = 0 THEN
                     SPELLLEVEL := 1;
                   L := RANDOM(3)+TEMP2;
                   INC (SPELLPTSTOT, L);
                   INC (SPELLPTLEFT, L);
                 END;
           'I' : BEGIN
                   C := RANDOM(2)+TEMP;
                   IF SPELLLEVEL < 10 THEN
                     SPELLLEVEL := (LEVEL DIV 2);
                   IF SPELLLEVEL = 0 THEN
                     SPELLLEVEL := 1;
                   L := RANDOM(3)+TEMP2;
                   INC (SPELLPTSTOT, L);
                   INC (SPELLPTLEFT, L);
                 END;
         END; {OF CASE}
         SETCOLOR (LTYELLOW);
         OUTTEXTXY (120, 25, NAME+' MADE THE NEXT LEVEL!');
         STR (LEVEL, NUMSTR);
         OUTTEXTXY (150, 34, 'YOU ARE NOW LEVEL '+NUMSTR);
         INC (HPLEFT, C);
         INC (HPTOT, C);
         IF CLASS[4] IN ['B', 'H', 'K', 'E'] THEN
           NUMATTACKS := (LEVEL DIV 3)+1;
         CHANGEABILITIES;
         ABILADJUST (ROSTER[INT]);
         WRITECHARACTER (INT, FALSE);
         TDELAY (THYME*3);
       END;

END; {OF PROCEDURE MADELEVEL}

{*******************************************************************}

PROCEDURE FAILURE;

BEGIN
     SETCOLOR (LTRED);
     WITH ROSTER[INT] DO
       BEGIN
         OUTTEXTXY (120, 75, NAME+' STILL NEEDS '+NUMSTR+' EXPERIENCE');
         OUTTEXTXY (120, 85, 'POINTS TO ATTAIN THE NEXT LEVEL.');
         TDELAY (THYME);
       END;

END; {OF PROCEDURE FAILURE}

{*******************************************************************}

PROCEDURE RAISE (EXPNEEDED, TOPEXP : LONGINT);

BEGIN
     WITH ROSTER[INT] DO
       BEGIN
         IF LEVEL <= 10 THEN
           IF EXP > EXPNEEDED THEN
             MADELEVEL
           ELSE
             BEGIN
               NUM := EXPNEEDED - EXP;
               STR (NUM, NUMSTR);
               FAILURE;
             END
         ELSE
           IF EXP > TOPEXP THEN
             MADELEVEL
           ELSE
             BEGIN
               NUM := TOPEXP - EXP;
               STR (NUM, NUMSTR);
               FAILURE;
             END;
         IF LEVEL > 251 THEN
           BEGIN
             LEVEL := 1;
             EXP := 1;
           END;
       END; {OF WITH}

END; {OF RAISE}

{*******************************************************************}

PROCEDURE RAISELEVEL;

BEGIN
     CLEAR;
     WITH ROSTER[INT] DO
       BEGIN
         BIGNUM := 1;
         IF LEVEL <= 9 THEN
           BIGNUM := BIGNUM SHL (LEVEL - 1);
         CASE CLASS[4] OF
           'B' : RAISE (900 * BIGNUM, 230400 + (LEVEL-9) * 230400);
           'H' : RAISE (800 * BIGNUM, 204800 + (LEVEL-9) * 204800);
           'K' : RAISE (1000 * BIGNUM, 256000 + (LEVEL-9) * 256000);
           'E' : RAISE (700 * BIGNUM, 179200 + (LEVEL-9) * 179200);
           'R' : RAISE (750 * BIGNUM, 192000 + (LEVEL-9) * 192000);
           'I' : RAISE (1050 * BIGNUM, 268800 + (LEVEL-9) * 268800);
         END; {OF CASE}
       END;

END; {OF PROCEDURE RAISELEVEL}

{*******************************************************************}

PROCEDURE HALLSTUFF;

BEGIN
     REPEAT
       CLEAR;
       SETCOLOR (LTGREEN);
       OUTTEXTXY (250, 55, 'YOU ARE IN A HALL!');
       OUTTEXTXY (240, 65, 'WHO WISHES TO TRAIN?');
       INT := GETPERSON (0, PEOPLE + 1);
       IF INT > 0 THEN
         RAISELEVEL;
     UNTIL INT < 0;
     NEWDIR;

END; {OF HALLSTUFF}

{*******************************************************************}
{*******************************************************************}

FUNCTION HEALMSG (POSSIBILITY : INTEGER) : BOOLEAN;

BEGIN
     CLEAR;
     OUTTEXTXY (120, 35, 'MUMBLE . . . MUMBLE . . . MUMBLE . . .');
     TDELAY (THYME);
     OUTTEXTXY (120, 45, 'MURMUR . . . MURMUR . . . MURMUR . . .');
     TDELAY (THYME);
     IF RANDOM(100)+1 < POSSIBILITY THEN
       BEGIN
         OUTTEXTXY (120, 55, 'TWIDDLE--DIDDLE--DI!');
         TDELAY (THYME*2);
         OUTTEXTXY (120, 75, 'SUCCESS!!!');
         HEALMSG := TRUE;
       END
     ELSE
       BEGIN
         OUTTEXTXY (120, 55, 'TWIDDLE--DIDDLE--DUMB!');
         TDELAY (THYME);
         OUTTEXTXY (120, 75, 'OOPS!--FAILED AGAIN.  SORRY.');
         HEALMSG := FALSE;
       END;

END; {OF FUNCTION HEALINGMSG}

{*******************************************************************}

PROCEDURE DOOK;

BEGIN
     WITH ROSTER[INT] DO
       BEGIN
         CLEAR;
         GOLD := 10*(HPTOT-HPLEFT);
         STR (GOLD, HPNUM);
         OUTTEXTXY (140, 45, 'IT WILL COST '+HPNUM+' GOLD PIECES TO HEAL HIM.');
         OUTTEXTXY (270, 55, 'WHO WILL PAY?');
         REPEAT
           SINT := GETPERSON (0, PEOPLE + 1);
           IF (SINT = -10) THEN
             EXIT;
         UNTIL SINT > 0;
         IF ROSTER[SINT].MONEY >= GOLD THEN
           BEGIN
             IF HEALMSG (100) THEN;
             CURING (HPTOT - HPLEFT, INT);
             DEC (ROSTER[SINT].MONEY, GOLD);
           END
         ELSE
           OUTTEXTXY (240, 75, 'HE DOESN''T HAVE ENOUGH!');
       END; {OF WITH DO}

END; {OF PROCEDURE DOOK}

{*******************************************************************}

PROCEDURE DOSPECIAL (COST : INTEGER; WHATSWRONG : SPEC;
                    POSSIBILITY : INTEGER);

BEGIN
     WITH ROSTER[INT] DO
       BEGIN
         CLEAR;
         IF (SPECIAL = DEAD) AND (LEVEL = 0) THEN
           BEGIN
             OUTTEXTXY (120, 35, 'OH, A SPECIAL CASE!');
             GOLD := 10000;
           END
         ELSE
           GOLD := COST*LEVEL;
         STR (GOLD, HPNUM);
         OUTTEXTXY (140, 45, 'IT WILL COST '+HPNUM+' GOLD PIECES TO HEAL HIM.');
         OUTTEXTXY (270, 55, 'WHO WILL PAY?');
         REPEAT
           SINT := GETPERSON (0, PEOPLE + 1);
           IF (SINT = -10) THEN
             EXIT;
         UNTIL SINT > 0;
         IF ROSTER[SINT].MONEY >= GOLD THEN
           BEGIN
             IF HEALMSG (POSSIBILITY) THEN
               BEGIN
                 FIX (WHATSWRONG, 100, INT);
                 IF LEVEL = 0 THEN
                   INC (LEVEL);
               END
             ELSE;
             DEC (ROSTER[SINT].MONEY, GOLD);
           END
         ELSE
           OUTTEXTXY (240, 75, 'HE DOESN''T HAVE ENOUGH!');
       END; {OF WITH ROSTER[INT] DO}

END; {OF PROCEDURE DOSPECIAL}

{*******************************************************************}

PROCEDURE TEMPLESTUFF;

BEGIN
     REPEAT
       CLEAR;
       SINT := 1;
       SETCOLOR (LTRED);
       OUTTEXTXY (240, 55, 'YOU ARE IN A TEMPLE!');
       OUTTEXTXY (250, 65, 'WHO NEEDS HEALING?');
       INT := GETPERSON (0, PEOPLE + 1);
       IF INT > 0 THEN
         WITH ROSTER[INT] DO
           BEGIN
             CASE SPECIAL OF
               OK      : IF HPLEFT < HPTOT THEN
                           DOOK
                         ELSE
                           OUTTEXTXY (240, 75, 'HE''S PERFECTLY FINE!');
               POISON  : DOSPECIAL (100, POISON, 95);
               PARALYS : DOSPECIAL (200, PARALYS, 90);
               STONE   : DOSPECIAL (400, STONE, 80);
               DEAD    : DOSPECIAL (500, DEAD, 75);
             END; {OF CASE}
             WRITECHARACTER (INT, FALSE);
             IF (SINT > 0) THEN
               TDELAY (THYME);
           END; {OF IF THEN}
     UNTIL INT = -10;
     NEWDIR;

END; {OF TEMPLESTUFF}

{*******************************************************************}
{****************     Shop Menus     *******************************}
{*******************************************************************}

PROCEDURE BUYMENU;

BEGIN
     SETCOLOR (DKYELLOW);
     OUTTEXTXY (405, 10, '<N>EXT');
     OUTTEXTXY (405, 20, '<P>REVIOUS');
     OUTTEXTXY (405, 30, '<T>OP OF LIST');
     OUTTEXTXY (405, 40, '<B>UY ITEM');
     OUTTEXTXY (405, 50, '<Q>UIT');
     STR (ROSTER[INT].MONEY, PSEUDONYM);
     BAR (400, 65, 535, 75);
     OUTTEXTXY (405, 65, 'GOLD: '+PSEUDONYM);

END; {OF PROCEDURE BUYMENU}

{*******************************************************************}

PROCEDURE SHOPMENU;

BEGIN
     CLEAR;
     SETCOLOR (DKYELLOW);
     OUTTEXTXY (150, 15, 'WELCOME TO ALDEBAR''S SHOP.');
     OUTTEXTXY (150, 25, 'WHAT IS YOUR BUSINESS?');
     SETCOLOR (LTRED);
     OUTTEXTXY (250, 45, '<B>UY');
     OUTTEXTXY (250, 55, '<S>ELL');
     OUTTEXTXY (250, 65, '<P>OOL');
     OUTTEXTXY (250, 75, '<Q>UIT');

END; {OF SHOPMENU}

{*******************************************************************}

PROCEDURE GETLIST;

BEGIN
     WITH ITEMDATA DO
       BEGIN
         RESET (SHOPFILE);
         READ (SHOPFILE, ITEMDATA);
         IF IORESULT <> 0 THEN
           DISKERROR ('DSDATA.F10', TRUE);
         NEW (FIRST);
         FIRST^.ITEM := ITEM;
         FIRST^.COST := COST;
         FIRST^.PLACE := 0;
         TOP := FIRST;
         GRMODE := 1;
         WHILE NOT EOF (SHOPFILE) DO
           BEGIN
             READ (SHOPFILE, ITEMDATA);
             IF IORESULT <> 0 THEN
               DISKERROR ('DSDATA.F10', TRUE);
             IF NUMBER > 0 THEN
               BEGIN
                 NEW (MIDDLE);
                 TOP^.NEXT := MIDDLE;
                 MIDDLE^.PREV := TOP;
                 TOP := MIDDLE;
                 MIDDLE^.ITEM := ITEM;
                 MIDDLE^.COST := COST;
                 MIDDLE^.PLACE := GRMODE;
               END; {IF ITEMDATA.NUMBER}
             INC (GRMODE);
           END; {WHILE NOT EOF}
         TOP^.NEXT := FIRST;
         FIRST^.PREV := TOP;
         TOP := FIRST;
         BOTTOM := FIRST;
         CLOSE (SHOPFILE);
       END; {OF WITH ITEMDATA}

END; {OF PROCEDURE GETLIST}

{*******************************************************************}

PROCEDURE WRITELIST;

BEGIN
     BAR (95, 2, 400, 108);
     BOTTOM := TOP;
     FOR TEMP := 1 TO 8 DO
       BEGIN
         SETCOLOR (LTYELLOW);
         STR (TEMP, NUMSTR);
         OUTTEXTXY (120, TEMP*9, NUMSTR+') '+BOTTOM^.ITEM);
         STR (BOTTOM^.COST, NUMSTR);
         FOR I := 5 DOWNTO LENGTH (NUMSTR) DO
           NUMSTR := ' '+NUMSTR;
         OUTTEXTXY (300, TEMP*9, NUMSTR);
         BOTTOM := BOTTOM^.NEXT;
       END;

END; {WRITELIST}

{*******************************************************************}

PROCEDURE PREVIOUS;

BEGIN
     BOTTOM := TOP;
     FOR J := 1 TO 9 DO
       TOP := TOP^.PREV;

END; {OF PROCEDURE PREVIOUS}

{*******************************************************************}

FUNCTION CHECKMONEY : BOOLEAN;

BEGIN
     IF MIDDLE^.COST <= ROSTER[INT].MONEY THEN
       CHECKMONEY := TRUE
     ELSE
       BEGIN
         CHECKMONEY := FALSE;
         SETCOLOR (LTGREEN);
         OUTTEXTXY (120, 92, 'YOU DON''T HAVE ENOUGH MONEY!');
         MAKENOISE;
         TDELAY (THYME);
       END;

END; {OF CHECKMONEY}

{*******************************************************************}

FUNCTION FINDPLACE (CHARACTER : PERSON) : BOOLEAN;

BEGIN
     J := 0;
     REPEAT
       INC (J);
       IF CHARACTER.EQUIPMENT[J].ITEM = '' THEN
         PLACE := TRUE
       ELSE
         PLACE := FALSE;
     UNTIL (PLACE) OR (J = 8);
     FINDPLACE := PLACE;

END; {OF PROCEDURE FINDPLACE}

{*******************************************************************}

PROCEDURE PURCHASE;

BEGIN
     IF FINDPLACE (ROSTER[INT]) THEN
       BEGIN
         RESET (SHOPFILE);
         SEEK (SHOPFILE, MIDDLE^.PLACE);
         READ (SHOPFILE, ITEMDATA);
         IF IORESULT <> 0 THEN
           DISKERROR ('DSDATA.F10', TRUE);
         ROSTER[INT].EQUIPMENT[J] := ITEMDATA;
         OUTTEXTXY (120, 92, 'IT''S A VERY FINE '+MIDDLE^.ITEM);
         DEC (ROSTER[INT].MONEY, MIDDLE^.COST);
         SEEK (SHOPFILE, MIDDLE^.PLACE);
         DEC (ITEMDATA.NUMBER);
         WRITE (SHOPFILE, ITEMDATA);
         CLOSE (SHOPFILE);
         IF ITEMDATA.NUMBER = 0 THEN
           BEGIN
             MIDDLE^.PREV^.NEXT := MIDDLE^.NEXT;
             MIDDLE^.NEXT^.PREV := MIDDLE^.PREV;
             IF MIDDLE = FIRST THEN
               FIRST := FIRST^.NEXT;
             DISPOSE (MIDDLE);
           END;
       END
     ELSE
       OUTTEXTXY (120, 92, 'YOU DON''T HAVE ENOUGH ROOM');
     TDELAY (THYME);

END; {OF PURCHASE}

{*******************************************************************}

PROCEDURE BUY;

BEGIN
     SETCOLOR (LTCYAN);
     OUTTEXTXY (120, 82, 'WHAT DO YOU WISH TO PURCHASE?');
     T := GETPERSON (0, 9);
     IF (T > 0) THEN
       BEGIN
         MIDDLE := TOP;
         FOR J := 2 TO T DO
           MIDDLE := MIDDLE^.NEXT;
         IF CHECKMONEY THEN
           PURCHASE;
       END; {IF T <> 0}

END; {OF PROCEDURE BUY}

{*******************************************************************}

PROCEDURE BUYSTUFF;

BEGIN
     GETLIST;
     WHILE RESPONCE <> 'Q' DO
       BEGIN
         WRITELIST;
         BUYMENU;
         RESPONCE := UREADKEY;
         CASE RESPONCE OF
           'N' : TOP := BOTTOM;
           'P' : PREVIOUS;
           'T' : TOP := FIRST;
           'B' : BUY;
           'Q' :; {DO NOTHING}
         ELSE
           MAKENOISE
         END; {OF CASE}
       END;
     TOP := FIRST^.NEXT;
     FIRST^.NEXT := NIL;
     WHILE TOP <> NIL DO
       BEGIN
         BOTTOM := TOP^.NEXT;
         DISPOSE (TOP);
         TOP := BOTTOM;
       END;
     RESPONCE := 'J';

END; {OF PROCEDURE BUYSTUFF}

{*******************************************************************}

PROCEDURE SELLITEM;

BEGIN
     WITH ROSTER[INT] DO
       BEGIN
         OUTTEXTXY (120, 98, 'DO YOU REALLY WISH TO SELL YOUR '+EQUIPMENT[T].ITEM+'?');
         RESPONCE := UREADKEY;
         BAR (120, 98, 500, 108);
         IF RESPONCE = 'Y' THEN
           BEGIN
             OUTTEXTXY (120, 98, 'SOLD!');
             INC (MONEY, EQUIPMENT[T].COST DIV 4);
             RESET (SHOPFILE);
             J := 0;
             REPEAT
               SEEK (SHOPFILE, J);
               READ (SHOPFILE, ITEMDATA);
               IF IORESULT <> 0 THEN
                 DISKERROR ('DSDATA.F10', TRUE);
               IF ITEMDATA.ITEM = EQUIPMENT[T].ITEM THEN
                 BEGIN
                   INC (ITEMDATA.NUMBER);
                   SEEK (SHOPFILE, J);
                   WRITE (SHOPFILE, ITEMDATA);
                 END;
               INC (J);
             UNTIL ITEMDATA.ITEM = EQUIPMENT[T].ITEM;
             CLOSE (SHOPFILE);
             TDELAY (THYME DIV J);
             EQUIPMENT[T] := SCUM;
             CONDENSEEQUIPMENT (ROSTER[INT]);
             RESPONCE := 'Q';
           END {OF IF THEN}
         ELSE
           BEGIN
             OUTTEXTXY (120, 98, 'IT''S ALRIGHT, WE UNDERSTAND.');
             MAKENOISE;
             TDELAY (THYME);
             RESPONCE := 'Q';
           END; {OF IF ELSE}
       END; {OF WITH DO}

END; {OF SELLITEM}

{*******************************************************************}

PROCEDURE SELLSTUFF;

BEGIN
     WITH ROSTER[INT] DO
       BEGIN
         REPEAT
           CLEAR;
           OUTTEXTXY (120, 10, 'WHICH ITEM DO YOU WISH TO SELL?');
           SHOWEQUIP (ROSTER[INT]);
           FOR J := 1 TO 8 DO
             BEGIN
               IF EQUIPMENT[J].COST <> 0 THEN
                 BEGIN
                   STR (EQUIPMENT[J].COST SHR 2, NUMSTR);
                   FOR L := 5 DOWNTO LENGTH(NUMSTR) DO
                     NUMSTR := ' '+NUMSTR;
                   OUTTEXTXY (250, 20+J*8, NUMSTR);
                 END
               ELSE; {DO NOTHING}
             END;
           T := GETPERSON (0, 9);
           IF (T > 0) AND (EQUIPMENT[T].ITEM <> '') THEN
             SELLITEM
         UNTIL T = -10;
         RESPONCE := 'J';
       END; {OF WITH ROSTER[INT]}

END; {OF SELLSTUFF}

{*******************************************************************}

PROCEDURE ENTERSHOP;

BEGIN
     REPEAT
       SHOPMENU;
       RESPONCE := UREADKEY;
       CASE RESPONCE OF
         'B' : BUYSTUFF;
         'S' : SELLSTUFF;
         'P' : POOL;
         'Q' :;
       ELSE
         MAKENOISE;
       END; {OF CASE}
     UNTIL RESPONCE = 'Q';
     RESPONCE := 'J';

END; {OF ENTERSHOP}

{*******************************************************************}

PROCEDURE SHOPSTUFF;

BEGIN
     REPEAT
       CLEAR;
       OUTTEXTXY (250, 55, 'YOU ARE IN A SHOP.');
       OUTTEXTXY (180, 65, 'WHO WISHES TO CONDUCT BUSINESS HERE?');
       INT := GETPERSON (0, PEOPLE + 1);
       IF INT > 0 THEN
         ENTERSHOP;
     UNTIL INT < 0;
     NEWDIR;

END; {OF SHOPSTUFF}

{*******************************************************************}
{****************     Guild Menus     ******************************}
{*******************************************************************}

FUNCTION ALREADYTHERE (CHARACTERNAME : STRING20) : BOOLEAN;

BEGIN
     ALREADYTHERE := TRUE;
     FOR SINT := 1 TO PEOPLE DO
       IF CHARACTERNAME = ROSTER[SINT].NAME THEN
         ALREADYTHERE := FALSE;

END; {OF FUNCTION ALREADYTHERE}

{*******************************************************************}

PROCEDURE GUILDMENU;

BEGIN
     SETCOLOR (LTYELLOW);
     SETTEXTSTYLE (TRIPLEXFONT,0 , 0);
     SETUSERCHARSIZE (1, 1, 3, 4);
     OUTTEXTXY (220, -3, 'MARCELD''S');
     SETTEXTSTYLE (DEFAULTFONT, 0, 1);
     SETCOLOR (LTRED);
     OUTTEXTXY (200, 25, '<M>AKE CHARACTER');
     OUTTEXTXY (200, 35, '<A>DD CHARACTER');
     OUTTEXTXY (200, 45, '<R>EMOVE CHARACTER');
     OUTTEXTXY (200, 55, '<C>HANGE NAME');
     OUTTEXTXY (200, 65, '<E>NTER CITY');
     OUTTEXTXY (200, 75, '<L>OAD GAME');
     OUTTEXTXY (200, 85, '<D>ELETE CHARACTER');
     OUTTEXTXY (200, 95, '<Q>UIT');
     SETCOLOR (LTYELLOW);

END; {OF PROCEDURE GUILDMENU}

{*******************************************************************}

PROCEDURE GETFILES;

BEGIN
     SETCOLOR (LTYELLOW);
     FOR J := 1 TO 8 DO
       POSSIBLEARRAY[J] := '';
     J := 0;
     WHILE (DOSERROR = 0) AND (J <> 8) DO
       BEGIN
         ASSIGN (LOADPERSON, DIRINFO.NAME);
         RESET (LOADPERSON);
         READ (LOADPERSON, CHARACTER);
         CLOSE (LOADPERSON);
         IF ALREADYTHERE (CHARACTER.NAME) THEN
           BEGIN
             INC (J);
             POSSIBLEARRAY[J] := CHARACTER.NAME;
             STR (J, NUMSTR);
             OUTTEXTXY (225, 15+J*10, NUMSTR+')');
             OUTTEXTXY (245, 15+J*10, POSSIBLEARRAY[J]);
           END;
         FINDNEXT (DIRINFO);
       END; {OF WHILE DO}

END; {OF PROCEUDURE GETFILES}

{*******************************************************************}

FUNCTION FILENAME (CHARACTERNAME :STRING20) : STRING12;

BEGIN
     PSEUDONYM := '';
     LEN := LENGTH (CHARACTERNAME);
     C := 0;
     FOR T := 1 TO LEN DO
       BEGIN
         CH := CHARACTERNAME[T];
         IF (CH <> ' ') AND (C < 8) THEN
           BEGIN
             PSEUDONYM := PSEUDONYM+CH;
             INC (C);
           END;
       END;
     FILENAME := PSEUDONYM+'.DSC';

END; {OF PROCEDURE FILENAME}

{*******************************************************************}

PROCEDURE GETRACE;

VAR
   PLUS : BOOLEAN;

BEGIN
   CLEAR;
   REPEAT
     PLUS := TRUE;
     SETCOLOR (LTRED);
     OUTTEXTXY (190, 8, 'WHICH RACE WOULD YOU LIKE TO BE?');
     SETCOLOR (LTGREEN);
     OUTTEXTXY (255, 25, '<D>WARF');
     OUTTEXTXY (255, 35, '<E>LF');
     OUTTEXTXY (255, 45, '<G>NOME');
     OUTTEXTXY (255, 55, 'H<A>LF-ELF');
     OUTTEXTXY (255, 65, 'H<O>BBIT');
     OUTTEXTXY (255, 75, '<H>UMAN');
     RESPONCE := UREADKEY;
     WITH CHARACTER DO
     CASE RESPONCE OF
       'D' : RACE := 'DWARF';
       'E' : RACE := 'ELF';
       'G' : RACE := 'GNOME';
       'A' : RACE := 'HALF-ELF';
       'O' : RACE := 'HOBBIT';
       'H' : RACE := 'HUMAN';
     ELSE
       BEGIN
         MAKENOISE;
         PLUS := FALSE;
       END
     END; { OF CASE}
   UNTIL PLUS;

END; {GETRACE}

{*******************************************************************}

PROCEDURE GETCLASS;

VAR
   PLUS : BOOLEAN;

BEGIN
   CLEAR;
   REPEAT
     PLUS := TRUE;
     SETCOLOR (LTRED);
     OUTTEXTXY (190, 8, 'WHICH CLASS WOULD YOU LIKE TO BE?');
     SETCOLOR (LTGREEN);
     OUTTEXTXY (255, 25, '<B>ARBARIAN');
     OUTTEXTXY (255, 35, '<F>IGHTER');
     OUTTEXTXY (255, 45, '<M>ONK');
     OUTTEXTXY (255, 55, '<T>HIEF');
     OUTTEXTXY (255, 65, '<C>LERIC');
     OUTTEXTXY (255, 75, 'M<A>GIC-USER');
     RESPONCE := UREADKEY;
     WITH CHARACTER DO
     CASE RESPONCE OF
      'B' : CLASS := 'BARBARIAN';
      'F' : CLASS := 'FIGHTER';
      'M' : CLASS := 'MONK';
      'T' : CLASS := 'THIEF';
      'C' : CLASS := 'CLERIC';
      'A' : CLASS := 'MAGIC-USER';
     ELSE
       BEGIN
         MAKENOISE;
         PLUS := FALSE;
       END
     END; { OF CASE}
   UNTIL PLUS;

END; {OF PROCEDURE GETCLASS}

{*******************************************************************}

PROCEDURE SHOWCHARACTER;

BEGIN
     CLEAR;
     SETCOLOR (LTRED);
     OUTTEXTXY (200, 8, 'DO YOU WANT THESE ABILITIES?');
     SETCOLOR (LTGREEN);
     OUTTEXTXY (230, 25, 'STRENGTH      :');
     OUTTEXTXY (230, 35, 'INTELIGENCE   :');
     OUTTEXTXY (230, 45, 'WISDOM        :');
     OUTTEXTXY (230, 55, 'DEXTERITY     :');
     OUTTEXTXY (230, 65, 'CONSTITUTION  :');
     OUTTEXTXY (230, 75, 'CHARISMA      :');
     OUTTEXTXY (230, 85, 'LUCK          :');
     K := 0;
     WITH CHARACTER DO
       FOR J := 1 TO 7 DO
         BEGIN
           STR(ABILITIES[J], NUMSTR);
           OUTTEXTXY (350, 25+K, NUMSTR);
           INC (K, 10);
         END; {FOR LOOP-J}

END; {OF PROCEDURE SHOWCHARACTER}

{*******************************************************************}

PROCEDURE ADJUSTFORRACE;

BEGIN
     WITH CHARACTER DO
       BEGIN
         CASE CHARACTER.RACE[2] OF
           'W' : BEGIN
                   INC (ABILITIES[1]);
                   INC (ABILITIES[5]);
                   DEC (ABILITIES[2], 2);
                 END;
           'L' : BEGIN
                   INC (ABILITIES[2]);
                   INC (ABILITIES[4]);
                   DEC (ABILITIES[1], 2);
                 END;
           'N' : INC (ABILITIES[3]);
           'A' : BEGIN
                   INC (ABILITIES[4]);
                   INC (ABILITIES[5]);
                   DEC (ABILITIES[1]);
                 END;
           'O' : BEGIN
                   INC (ABILITIES[5]);
                   INC (ABILITIES[7]);
                   DEC (ABILITIES[1], 2);
                 END;
           'U' : INC (ABILITIES[1]);
         END; {OF CASE}
         FOR J := 1 TO 7 DO
           IF ABILITIES[J] > 18 THEN
             ABILITIES[J] := 18;
       END; {WITH CHARACTER}

END; {OF ADJUSTFORRACE}

{*******************************************************************}

PROCEDURE RANDOMROLL (ABIL : STRING);

VAR
   TEMP : ARRAY[1..3] OF SHORTINT;
   P, INDEX, TEMPER, TIMES : SHORTINT;
   KEEP : BOOLEAN;

BEGIN
   REPEAT
     KEEP := FALSE;
     FOR J := 1 TO 7 DO
       BEGIN
         TEMP[1] := 0;
         TEMP[2] := 0;
         TEMP[3] := 0;
         VAL (ABIL[J], TIMES, CODE);
         FOR K := 1 TO TIMES DO
           BEGIN
             P := RANDOM(6)+1;
             FOR I := 1 TO 2 DO
               BEGIN
                 INDEX := I;
                 FOR L := I+1 TO 3 DO
                   IF TEMP[L] < TEMP[INDEX] THEN
                     INDEX := L;
                 TEMPER := TEMP[INDEX];
                 TEMP[INDEX] := TEMP[I];
                 TEMP[I] := TEMPER;
               END; {FOR LOOP-I}
             IF P > TEMP[1] THEN
               TEMP[1] := P;
           END; {FOR LOOP-K}
         CHARACTER.ABILITIES[J] := TEMP[1] + TEMP[2] + TEMP[3];
       END; {FOR LOOP-J}
     ADJUSTFORRACE;
     CHARACTER.MONEY := RANDOM(100)+50;
     SHOWCHARACTER;
     RESPONCE := UREADKEY;
     IF RESPONCE = 'Y' THEN
       KEEP := TRUE;
   UNTIL KEEP;

END; {OF PROCEDURE RANDOMROLL}

{*******************************************************************}

PROCEDURE ROLL;

VAR
   ABIL : STRING[7];

BEGIN
   WITH CHARACTER DO
    BEGIN
     CASE CLASS[4] OF
       'B' : BEGIN
               ABIL := '7335643';
               HPTOT := 12;
               RANDOMROLL (ABIL);
             END;
       'H' : BEGIN
               ABIL := '8345543';
               HPTOT := 10;
               RANDOMROLL (ABIL);
             END;
       'K' : BEGIN
               ABIL := '5376433';
               HPTOT := 8;
               RANDOMROLL (ABIL);
             END;
       'E' : BEGIN
               ABIL := '4337536';
               HPTOT := 6;
               RANDOMROLL (ABIL);
             END;
       'R' : BEGIN
               ABIL := '5373643';
               HPTOT := 8;
               SPELLPTSTOT := 10;
               SPELLLEVEL := 1;
               RANDOMROLL (ABIL);
             END;
       'I' : BEGIN
               ABIL := '3756433';
               HPTOT := 4;
               SPELLPTSTOT := 10;
               SPELLLEVEL := 1;
               RANDOMROLL (ABIL);
             END;
      END;
    END; {OF WITH CHARACTER}

END; {OF PROCEDURE ROLL}

{*******************************************************************}

PROCEDURE SAVECHARACTER;

BEGIN
     ASSIGN (LOADPERSON, FILENAME (CHARACTER.NAME));
     REWRITE (LOADPERSON);
     WRITE (LOADPERSON, CHARACTER);
     IF IORESULT <> 0 THEN
       DISKERROR (FILENAME (CHARACTER.NAME), FALSE);
     CLOSE (LOADPERSON);

END; {OF PROCEDURE SAVECHARACTER}

{*******************************************************************}

PROCEDURE DISPLAYCHARACTER;

BEGIN
     WITH CHARACTER DO
       BEGIN
         ABILADJUST (CHARACTER);
         HPLEFT := HPTOT;
         SPELLPTLEFT := SPELLPTSTOT;
         SHOWCHAR (CHARACTER);
         SETCOLOR (DKRED);
         OUTTEXTXY (200, 101, 'SAVE THIS CHARACTER TO DISK?');
         REPEAT
           RESPONCE := UREADKEY;
           IF RESPONCE = 'Y' THEN
             SAVECHARACTER;
         UNTIL RESPONCE IN ['Y', 'N'];
       END; {WITH CHARACTER DO}
     CLEAR;

END; {OF PROCEDURE DISPLAYCHARACTER}

{*******************************************************************}

PROCEDURE MAKECHARACTER;

BEGIN
     SETCOLOR (LTBLUE);
     INITCHARACTER;
     GETRACE;
     GETCLASS;
     ROLL;
     OUTTEXTXY (160, 96, 'WHAT SHALL YE BE NAMED? ');
     READLINE (CHARACTER.NAME, 20, 350, 96);
     DISPLAYCHARACTER;

END; {OF PROCEDURE MAKECHARACTER}

{*******************************************************************}

PROCEDURE PICKCHARACTER (VAR POSSIBLEARRAY : POS);

VAR
   LOAD : FILE OF PERSON;

BEGIN
     IF (INT > 0) THEN
       IF POSSIBLEARRAY[INT] <> '' THEN
         IF ALREADYTHERE (POSSIBLEARRAY[INT]) THEN
           BEGIN
             INC (PEOPLE);
             ASSIGN (LOADPERSON, FILENAME (POSSIBLEARRAY[INT]));
             RESET (LOADPERSON);
             READ (LOADPERSON, ROSTER[PEOPLE]);
             CLOSE (LOADPERSON);
             BAR (220, 15+INT*10, 450, 23+INT*10);
           END;
     IF PEOPLE > 0 THEN
       IF ROSTER[PEOPLE].NAME <> '' THEN
         WRITECHARACTER (PEOPLE, FALSE);

END; {OF PICKCHARACTER}

{*******************************************************************}

PROCEDURE ADDCHARACTER;

BEGIN
     REPEAT
       FINDFIRST ('*.DSC', ANYFILE, DIRINFO);
       REPEAT
         CLEAR;
         SETCOLOR (LTRED);
         OUTTEXTXY (180, 10, 'WHICH CHARACTER DO YOU WISH TO ADD?');
         CHARACTER.NAME := '';
         GETFILES;
         REPEAT
           IF PEOPLE <> 6 THEN
             BEGIN
               RESPONCE := UREADKEY;
               VAL (RESPONCE, INT, CODE);
               IF CODE = 0 THEN
                 PICKCHARACTER (POSSIBLEARRAY);
             END;
         UNTIL (RESPONCE IN ['C', 'Q']) OR (PEOPLE = 6);
       UNTIL (RESPONCE = 'Q') OR (PEOPLE = 6) OR
             ((RESPONCE = 'C') AND (J < 8));
     UNTIL (RESPONCE = 'Q') OR (PEOPLE = 6) OR
           ((RESPONCE <> 'C') AND (J < 8));
     CLEAR;

END; {OF ADDCHARACTER}

{*******************************************************************}

PROCEDURE CONDENCEROSTER;

BEGIN
     FOR J := INT TO PEOPLE DO
       BEGIN
         ROSTER[J] := ROSTER[J+1];
         ROSTER[J+1].NAME := '';
       END;
END;

{*******************************************************************}

PROCEDURE REMOVECHARACTER;

BEGIN
     CLEAR;
     SETCOLOR (LTBLUE);
     OUTTEXTXY (260, 45, 'REMOVE WHOM?');
     INT := GETPERSON (0, PEOPLE + 1);
     IF (INT > 0) THEN
       BEGIN
         CHARACTER := ROSTER[INT];
         SAVECHARACTER;
         ROSTER[INT].NAME := '';
         DEC (PEOPLE);
         CONDENCEROSTER;
         FOR INT := 0 TO PEOPLE DO
           WRITECHARACTER (INT, FALSE);
         CLEARBOTTOM (PEOPLE+1);
       END;
       CLEAR;

END; {OF PROCEDURE REMOVECHARACTER}

{*******************************************************************}

PROCEDURE DELETECHARACTER;

BEGIN
     REPEAT
       FINDFIRST ('*.DSC', ANYFILE, DIRINFO);
       REPEAT
         CLEAR;
         SETCOLOR (LTRED);
         OUTTEXTXY (180, 10, 'WHICH CHARACTER DO YOU WISH TO DELETE?');
         GETFILES;
         INT := GETPERSON (0, J + 1);
         IF (INT > 0) THEN
           BEGIN
             CLEAR;
             OUTTEXTXY (140, 65, 'DO YOU REALLY WANT TO DELETE '+POSSIBLEARRAY[INT]+' ?');
             RESPONCE := UREADKEY;
             IF RESPONCE = 'Y' THEN
               BEGIN
                 ASSIGN (LOADPERSON, FILENAME (POSSIBLEARRAY[INT]));
                 ERASE (LOADPERSON);
                 RESPONCE := 'Q';
               END
             ELSE
               RESPONCE := 'Q';
           END
         ELSE
           RESPONCE := 'Q';
       UNTIL (RESPONCE IN ['Q', 'C']) AND (J < 8);
     UNTIL (RESPONCE IN ['Q', 'C']) AND (J < 8);
     CLEAR;

END; {OF DELETECHARACTER}

{*******************************************************************}

PROCEDURE CHANGENAME;

BEGIN
     CLEAR;
     SETCOLOR (LTGREEN);
     OUTTEXTXY (210, 45, 'CHANGE WHOSE NAME?');
     INT := GETPERSON (-1, PEOPLE + 1);
     IF INT >= 0 THEN
       BEGIN
         WITH CHARACTER DO
           BEGIN
             OUTTEXTXY (160, 76, 'WHAT SHALL '+NAME+' BE NAMED? ');
             READLINE (NAME, 20, 350, 96);
             IF FILENAME (ROSTER[INT].NAME) <> FILENAME (NAME) THEN
               BEGIN
                 ASSIGN (LOADPERSON, FILENAME (ROSTER[INT].NAME));
                 RENAME (LOADPERSON, FILENAME (NAME));
                 IF IORESULT <> 0 THEN
                   DISKERROR (FILENAME (NAME), FALSE);
                 REWRITE (LOADPERSON);
                 ROSTER[INT].NAME := NAME;
                 WRITE (LOADPERSON, ROSTER[INT]);
                 IF IORESULT <> 0 THEN
                   DISKERROR (FILENAME (NAME), FALSE);
                 CLOSE (LOADPERSON);
               END
             ELSE
               ROSTER[INT].NAME := NAME;
             WRITECHARACTER (INT, FALSE);
           END; {OF WITH CHARACTER}
       END;
       CLEAR;

END; {OF CHANGENAME}

{*******************************************************************}

PROCEDURE GUILDOPTION;

BEGIN
     FIGHT := TRUE;
     WHILE FIGHT DO
       BEGIN
         GUILDMENU;
         RESPONCE := UREADKEY;
         CASE RESPONCE OF
           'M' : MAKECHARACTER;
           'A' : ADDCHARACTER;
           'R' : REMOVECHARACTER;
           'C' : CHANGENAME;
           'E' : IF (PEOPLE >= 1) THEN
                   BEGIN
                     FIGHT := FALSE;
                     N := 14;
                     E := 11;
                   END;
           'L' : BEGIN
                   FIGHT := FALSE;
                   LOADGAME;
                   FIGHT := FALSE;
                   RESPONCE := 'Q';
                 END;
           'D' : DELETECHARACTER;
           'Q' : QUITGAME;
           'V' : PLAYSONG := NOT PLAYSONG;
           ' ' :;
         ELSE
           MAKENOISE;
         END; {OF CASE}
       END;
     FIGHT := FALSE;

END; {OF PROCEDURE GUILDOPTION}

{*******************************************************************}

PROCEDURE GUILDSTUFF;

BEGIN
     INITCHARACTER;
     CLEAR;
     RESPONCE := ' ';
     GUILDOPTION;
     DIRECTION := 'S';
     VIEWAHEAD;

END; {OF PROCEDURE GUILDSTUFF}

{*******************************************************************}

END. {OF UNIT CITY}