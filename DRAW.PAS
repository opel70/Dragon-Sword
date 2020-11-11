UNIT DRAW;

INTERFACE

USES
    CRT, GRAPH, VARIABLE;

PROCEDURE DISKERROR (NAME : STRING; IFREAD : BOOLEAN);
PROCEDURE COMPASSICON (ON : BOOLEAN);
PROCEDURE SHIELDICON (ON : BOOLEAN);
PROCEDURE LIGHTICON (ON : BOOLEAN);
PROCEDURE DOORICON (ON : BOOLEAN);
PROCEDURE DRAWHEADING;
PROCEDURE DRAWOPENING;
PROCEDURE WRAPAROUND (VAR INDEX : BYTE);
PROCEDURE VIEWAHEAD;
PROCEDURE VIEWCHAR;
PROCEDURE SHOWCHAR (CHARACTER : PERSON);
PROCEDURE SHOWEQUIP (CHARACTER : PERSON);
PROCEDURE WRITECHARACTER (INT : INTEGER; INFIGHT : BOOLEAN);
PROCEDURE GETSTATUS (INT : INTEGER);
PROCEDURE REORDER;
PROCEDURE CONDENSEEQUIPMENT (VAR CHARACTER: PERSON);

IMPLEMENTATION

USES
    GENERAL;

TYPE
    PIXEL = RECORD
              Y, X : BYTE;
            END;
    DAT = FILE OF PIXEL;

VAR
   PICTURE : DAT;
   POINT : PIXEL;
   C : CHAR;

{*******************************************************************}

PROCEDURE DISKERROR (NAME : STRING; IFREAD : BOOLEAN);

BEGIN
     CLEAR;
     SETTEXTSTYLE (DEFAULTFONT, HORIZDIR, 1);
     OUTTEXTXY (245, 55, 'DISK READ ERROR! ! !');
     IF IFREAD THEN
       OUTTEXTXY (200, 65, 'FILE ' + NAME + ' IS BAD OR MISSING.')
     ELSE
       OUTTEXTXY (200, 65, 'UNABLE TO WRITE '+NAME+'.');
     SETCOLOR (LTBLUE);
     MAKENOISE;
     OUTTEXTXY (200, 85, 'PRESS SPACE BAR TO CONTINUE . . .');
     REPEAT
       RESPONCE := UREADKEY;
     UNTIL RESPONCE = ' ';

     HALT (0);

END; {OF PROCEDURE DISKERROR}

{*******************************************************************}

PROCEDURE COMPASSICON (ON : BOOLEAN);

CONST
     CX = 145;
     CY = 123;

BEGIN
     IF NOT BANDW THEN
       BEGIN
         IF ((NOT COMPAS) AND (NOT LGCOMPASS)) THEN
           BEGIN
             BAR (CX-14, CY-8, CX+14, CY+8);
             SETCOLOR(GREY);
             LINE (CX, CY - 8, CX - 5, CY);    {N}
             LINE (CX, CY - 8, CX + 5, CY);
             LINE (CX, CY + 8, CX - 5, CY);    {S}
             LINE (CX, CY + 8, CX + 5, CY);
             LINE (CX, CY - 3, CX + 14, CY);    {E}
             LINE (CX, CY + 3, CX + 14, CY);
             LINE (CX, CY - 3, CX - 14, CY);    {W}
             LINE (CX, CY + 3, CX - 14, CY);
             SETFILLSTYLE (SOLIDFILL, LTBLUE);
             FLOODFILL (CX, CY, GREY);
             SETFILLSTYLE (SOLIDFILL, DKRED);
             FLOODFILL (CX, CY-7, GREY);
             FLOODFILL (CX, CY+7, GREY);
             FLOODFILL (CX+11, CY, GREY);
             FLOODFILL (CX-11, CY, GREY);
           END;
         IF COMPAS OR LGCOMPASS THEN
           IF ON THEN
             BEGIN
               SETFILLSTYLE (SOLIDFILL, LTRED);
               CASE DIRECTION OF
                 'N' : FLOODFILL (CX, CY-7, GREY);
                 'S' : FLOODFILL (CX, CY+7, GREY);
                 'E' : FLOODFILL (CX+11, CY, GREY);
                 'W' : FLOODFILL (CX-11, CY, GREY);
               END;
             END
           ELSE
             BEGIN
               SETFILLSTYLE (SOLIDFILL, DKRED);
               CASE DIRECTION OF
                 'N' : FLOODFILL (CX, CY-7, GREY);
                 'S' : FLOODFILL (CX, CY+7, GREY);
                 'E' : FLOODFILL (CX+11, CY, GREY);
                 'W' : FLOODFILL (CX-11, CY, GREY);
               END;
             END
       END {OF NOT BANDW?}
     ELSE
       BEGIN
         SETCOLOR (DKWHITE);
         CIRCLE (CX, CY, 18);
         SETFILLSTYLE (EMPTYFILL, BLACK);
         BAR (CX-2, CY-3, CX+4, CY+5);
         IF ON AND (COMPAS OR LGCOMPASS) THEN
           OUTTEXTXY (CX-2, CY-3, DIRECTION);
       END;
     SETFILLSTYLE (EMPTYFILL, BLACK);

END; {OF PROCEDURE COMPASSICON}

{*******************************************************************}

PROCEDURE SHIELDICON (ON : BOOLEAN);

CONST
     SX = 185;
     SY = 116;

BEGIN
     IF ((NOT SHELD) AND (NOT ARMOR) AND (NOT INVULN)) OR BANDW THEN
       BEGIN
         BAR (SX, SY, SX + 20, SY + 15);
         SETCOLOR (LTGREEN);
         LINE (SX, SY, SX + 20, SY);
         LINE (SX, SY, SX, SY + 8);
         LINE (SX + 20, SY, SX + 20, SY + 8);
         LINE (SX, SY + 8, SX + 10, SY + 15);
         LINE (SX + 20, SY + 8, SX + 10, SY + 15);
       END;
     IF ON THEN
       BEGIN
         SETFILLSTYLE (SOLIDFILL, LTBLUE);
         FLOODFILL (SX + 9, SY + 10, LTGREEN);
       END;
     SETCOLOR (LTRED);
     LINE (SX + 6, SY + 1, SX + 6, SY + 11);
     LINE (SX + 1, SY + 4, SX + 19, SY + 4);
     SETFILLSTYLE (EMPTYFILL, BLACK);

END; {OF PROCEDURE SHIELDICON}

{*******************************************************************}

PROCEDURE LIGHTICON (ON : BOOLEAN);

CONST
     LX = 250;
     LY = 120;

BEGIN
     BAR (LX - 17, LY - 8, LX + 17, LY + 12);
     SETCOLOR (GREY);
     ARC (LX, LY, 304, 244, 14);
     LINE (LX - 7, LY + 6, LX - 6, LY + 9);
     LINE (LX + 7, LY + 6, LX + 6, LY + 9);
     LINE (LX - 6, LY + 10, LX + 6, LY + 10);
     SETCOLOR (LTYELLOW);
     LINE (LX - 5, LY + 11, LX + 5, LY + 11);
     LINE (LX - 4, LY + 12, LX + 4, LY + 12);
     IF ON THEN
       BEGIN
         SETFILLSTYLE (SOLIDFILL, LTWHITE);
         FLOODFILL (LX, LY - 5, GREY);
       END;
     SETCOLOR (LTRED);
     LINE (LX - 3, LY, LX + 3, LY);
     SETCOLOR (BLACK);
     LINE (LX, LY + 1, LX, LY + 9);
     SETFILLSTYLE (EMPTYFILL, BLACK);

END; {OF PROCEDURE LIGHTICON}

{*******************************************************************}

PROCEDURE DOORICON (ON : BOOLEAN);

CONST
     DX = 300;
     DY = 117;

BEGIN
     BAR (DX - 8, DY - 3, DX + 28, DY + 15);
     IF ON THEN
       BEGIN
         SETCOLOR (LTGREEN);
         SETFILLSTYLE (CLOSEDOTFILL, LTGREEN);
         BAR3D (DX, DY, DX + 20, DY + 15, 0, FALSE);
         LINE (DX - 3, DY + 13, DX - 7, DY + 14);
         LINE (DX - 3, DY + 10, DX - 7, DY + 11);
         LINE (DX - 3, DY + 7, DX - 8, DY + 7);
         LINE (DX - 3, DY + 4, DX - 7, DY + 3);
         LINE (DX - 3, DY, DX - 7, DY - 3);
         LINE (DX + 23, DY + 13, DX + 27, DY + 14);
         LINE (DX + 23, DY + 10, DX + 27, DY + 11);
         LINE (DX + 23, DY + 7, DX + 28, DY + 7);
         LINE (DX + 23, DY + 4, DX + 27, DY + 3);
         LINE (DX + 23, DY, DX + 27, DY - 3);
         LINE (DX + 3, DY - 1, DX, DY - 3);
         LINE (DX + 10, DY - 1, DX + 10, DY - 3);
         LINE (DX + 17, DY - 1, DX + 19, DY - 3);
       END;
     SETFILLSTYLE (EMPTYFILL, BLACK);

END; {OF PROCEDURE DOORICON}

{*******************************************************************}

PROCEDURE BOX;

BEGIN
     SETLINESTYLE (0, 0, 3);
     SETCOLOR (WHITE);
     LINE (X-2, 0, XR+2, 0); {TOP}
     LINE (X-2, 0, X-2, 110); {LEFT}
     LINE (XR+2, 0, XR+2, 110); {RIGHT}
     LINE (X-2, 110, XR+2, 110); {BOTTOM}

END; {OF PROCEDURE BOX}

{*******************************************************************}

PROCEDURE LOGO;

CONST
     DOWN = 20;

BEGIN
     ASSIGN (PICTURE, 'DSDATA.F11');
     RESET (PICTURE);
     WHILE NOT EOF(PICTURE) DO
       BEGIN
         READ (PICTURE, POINT);
         IF IORESULT <> 0 THEN
           DISKERROR ('DSDATA.F11', TRUE);
         PUTPIXEL (POINT.X-5, DOWN+POINT.Y, BLUE);
         PUTPIXEL (645-POINT.X, DOWN+POINT.Y, BLUE);
       END;
     CLOSE (PICTURE);

END; {OF PROCEDURE LOGO}

{*******************************************************************}

PROCEDURE TITLE;

BEGIN
     SETTEXTSTYLE (TRIPLEXFONT, 0, 1);
     DELAY (1000);
     SETCOLOR (DKRED);
     OUTTEXTXY (10, 10, 'Dragon');
     SETCOLOR (DKWHITE);
     OUTTEXTXY (565, 10, 'Sword');

END; {OF PROCEDURE TITLE}

{*******************************************************************}

PROCEDURE CHARHEADING;

BEGIN
     SETCOLOR (DKWHITE);
     SETTEXTSTYLE (DEFAULTFONT, 0, 1);
     OUTTEXTXY (125, 134, 'CHARACTER NAME');
     OUTTEXTXY (315, 134, 'AC');
     OUTTEXTXY (365, 134, 'HP');
     OUTTEXTXY (415, 134, 'SP');
     OUTTEXTXY (465, 134, 'STATUS');
     SETLINESTYLE (SOLIDLN, 0, NORMWIDTH);
     LINE (95, 142, 545, 142);

END; {OF PROCEDURE CHARHEADING}

{*******************************************************************}

PROCEDURE DRAWHEADING;

BEGIN
     BOX;

     LOGO;

     TITLE;
     CHARHEADING;

END; {OF PROCEDURE HEADING}

{*******************************************************************}
{*******************************************************************}

PROCEDURE OPENTITLE;

BEGIN
   SETTEXTSTYLE (GOTHICFONT, HORIZDIR, 9);
   SETCOLOR (LTRED);
   OUTTEXTXY (50, -10, 'Dragon');
   SETCOLOR (LTWHITE);
   OUTTEXTXY (50, 60, 'Sword');
   SETCOLOR (LTBLUE);
   SETTEXTSTYLE (SMALLFONT, HORIZDIR, 4);
   OUTTEXTXY (50, 167, 'Written by :  Brian Tieman & Tim Musa');
   OUTTEXTXY (50, 177, 'Music by   :  Jennifer Anderson');
   OUTTEXTXY (50, 187, 'Copywrite 1990  ver. 2.718281828459045');

END; {OF PROCEDURE TITLE}

{*******************************************************************}

PROCEDURE SWORD;

CONST
     X = 460;
     Y = 30;
     SHAPE : array[1..6] of PointType =
             ((x: X ;     y: Y - 25),      {TOP}
              (x: X + 10; y: Y + 10),      {TOP RIGHT}
              (x: X + 15; y: Y + 103),     {BOTTOM RIGHT}
              (x: X ;     y: Y + 105),     {BOTTOM}
              (x: X - 15; y: Y + 103),     {BOTTOM LEFT}
              (x: X - 10; y: Y + 10));     {TOP LEFT}

BEGIN
     SETASPECTRATIO (4500, 10000);
     SETCOLOR (LTRED);
     SETFILLSTYLE (SOLIDFILL, LTRED);
     ARC (X - 185, Y + 115, 345, 5, 200);   {RIGHT ARC HANDLE}
     ARC (X + 185, Y + 115, 174, 195, 200); {LEFT ARC HANDLE}
     FILLELLIPSE (X, Y + 143, 13, 6);
     SETCOLOR (DKRED);
     ARC (X, Y + 125, 240, 300, 20);
     ARC (X, Y + 123, 205, 340, 15);
     ARC (X, Y + 117, 210, 333, 17);
     ARC (X, Y + 110, 219, 322, 19);
     ARC (X, Y + 103, 234, 308, 24);
     SETCOLOR (LTYELLOW);
     ARC (X, Y + 67, 224, 316, 90);        {BOTTOM ARC HANDLE}
     ARC (X, Y + 50, 239, 301, 115);       {TOP ARC HANDLE}
     SETFILLSTYLE (SOLIDFILL, LTYELLOW);
     FILLELLIPSE ( X + 66, Y + 92, 7, 3);
     FILLELLIPSE ( X - 66, Y + 92, 7, 3);
     SETCOLOR (LTWHITE);
     SETFILLSTYLE (SOLIDFILL, LTWHITE);
     FILLPOLY( 6, SHAPE);
     SETCOLOR (GREY);
     LINE (X, Y - 10, X , Y + 103);

END;

{*******************************************************************}

PROCEDURE DRAWOPENING;

BEGIN
     OPENTITLE;
     SWORD;
     REPEAT
     UNTIL (KEYPRESSED);
     IF (KEYPRESSED) THEN
        RESPONCE := UPCASE(READKEY);
     IF (RESPONCE = 'V') THEN
        PLAYSONG := NOT PLAYSONG;
     CLEARVIEWPORT;
     SETCOLOR (DKWHITE);
     SETFILLSTYLE (EMPTYFILL, BLACK);

END; {OF PROCEDURE DRAWOPENING}

{*******************************************************************}
{*******************************************************************}
{*******************************************************************}

PROCEDURE DRAWLEFT;

BEGIN
     LINE (X, Y, X+43, Y+10); {TOP WALL}
     LINE (X+43, Y+10, X+43, YB-10); {RIGHT SIDE}
     LINE (X, YB, X+43, YB-10); {BOTTOM WALL}

END; {OF PROCEDURE DRAWLEFT}

{*******************************************************************}

PROCEDURE DRAWLEFTDOOR;

BEGIN
     LINE (X, Y+10, X+30, Y+17); {1ST LEFT DOOR TOP}
     LINE (X+30, Y+17, X+30, YB-7); {1ST LEFT DOOR SIDE}

END; {OF PROCEDURE DRAWLEFTDOOR}

{*******************************************************************}

PROCEDURE DRAWFRONT;

BEGIN
     LINE (X+43, Y+10, XR-43, Y+10); {TOP}
     LINE (X+43, Y+10, X+43, YB-10); {LEFT}
     LINE (XR-43, Y+10, XR-43, YB-10); {RIGHT}
     LINE (X+43, YB-10, XR-43, YB-10); {BOTTOM}

END;

{*******************************************************************}

PROCEDURE DRAWFRONTDOOR;

BEGIN
     LINE (X+70, Y+25, XR-70, Y+25); {TOP}
     LINE (X+70, Y+25, X+70, YB-10); {LEFT}
     LINE (XR-70, Y+25, XR-70, YB-10); {RIGHT}

END; {OF PROCEDURE DRAWFRONTDOOR}

{********************************************************************}

PROCEDURE DRAWRIGHT;

BEGIN
     LINE (XR, Y, XR-43, Y+10); {TOP WALL}
     LINE (XR-43, Y+10, XR-43, YB-10); {LEFT SIDE}
     LINE (XR, YB, XR-43, YB-10); {BOTTOM WALL}

END; {OF PROCEDURE DRAWRIGHT}

{********************************************************************}

PROCEDURE DRAWRIGHTDOOR;

BEGIN
     LINE (XR, Y+10, XR-30, Y+17); {1ST RIGHT DOOR TOP}
     LINE (XR-30, Y+17, XR-30, YB-7); {1ST RIGHT DOOR SIDE}

END; {OF PROCEDURE DRAWRIGHTDOOR}

{********************************************************************}
         {************************************************}

PROCEDURE DRAWFIRSTLEFT;

BEGIN
     LINE (X+PX, Y+PY, X+PX, YB-PY); {LEFT WALL}
     LINE (X+PX, Y+PY, X+PX+CHX, Y+PY+CHY); {TOP WALL}
     LINE (X+PX+CHX, Y+PY+CHY, X+PX+CHX, YB-(PY+CHY)); {RIGHT SIDE}
     LINE (X+PX, YB-PY, X+PX+CHX, YB-(PY+CHY)); {BOTTOM WALL}

END; {OF PROCEDURE DRAWFIRSTLEFT}

{*******************************************************************}

PROCEDURE DRAWFIRSTLEFTDOOR;

BEGIN
     LINE (X+PX+PXD, Y+PY+PYD, X+PX+PXD, YB-ROUND((PX+PXD)*0.225)); {1ST LEFT DOOR LEFT}
     LINE (X+PX+PXD, Y+PY+PYD, X+PX+PXD+CHXD, Y+PY+CHY+ROUND(PYD*0.55)); {1ST LEFT DOOR TOP}
     LINE (X+PX+PXD+CHXD, Y+PY+CHY+ROUND(PYD*0.55), X+PX+PXD+CHXD, YB-ROUND((PX+PXD+CHXD)*0.225)); {1ST LEFT DOOR SIDE}

END; {OF PROCEDURE DRAWFIRSTLEFTDOOR}

{*******************************************************************}

PROCEDURE DRAWFIRSTFRONT;

BEGIN
     LINE (X+PX+CHX, Y+PY+CHY, XR-(PX+CHX), Y+PY+CHY); {TOP}
     LINE (X+PX+CHX, Y+PY+CHY, X+PX+CHX, YB-(PY+CHY)); {LEFT}
     LINE (XR-(PX+CHX), Y+PY+CHY, XR-(PX+CHX), YB-(PY+CHY)); {RIGHT}
     LINE (X+PX+CHX, YB-(PY+CHY), XR-(PX+CHX), YB-(PY+CHY)); {BOTTOM}

END; {OF PROCEDURE DRAWFIRSTFRONT}

{*******************************************************************}

PROCEDURE DRAWFIRSTFRONTDOOR;

BEGIN
     LINE (X+PX+CHX+PXD, Y+PY+CHY+PYD, XR-(PX+CHX+PXD), Y+PY+CHY+PYD); {TOP}
     LINE (X+PX+CHX+PXD, Y+PY+CHY+PYD, X+PX+CHX+PXD, YB-(PY+CHY)); {LEFT}
     LINE (XR-(PX+CHX+PXD), Y+PY+CHY+PYD, XR-(PX+CHX+PXD), YB-(PY+CHY)); {RIGHT}

END; {OF PROCEDURE DRAWFIRSTFRONTDOOR}

{*******************************************************************}

PROCEDURE DRAWFIRSTRIGHT;

BEGIN
     LINE (XR-PX, Y+PY, XR-PX, YB-PY); {RIGHT SIDE}
     LINE (XR-PX, Y+PY, XR-(PX+CHX), Y+PY+CHY); {TOP WALL}
     LINE (XR-(PX+CHX), Y+PY+CHY, XR-(PX+CHX), YB-(PY+CHY)); {LEFT SIDE}
     LINE (XR-PX, YB-PY, XR-(PX+CHX), YB-(PY+CHY)); {BOTTOM WALL}

END; {OF PROCEDURE DRAWFIRSTRIGHT}

{*******************************************************************}

PROCEDURE DRAWFIRSTRIGHTDOOR;

BEGIN
     LINE (XR-(PX+PXD), Y+PY+PYD, XR-(PX+PXD), YB-ROUND((PX+PXD)*0.225)); {1ST LEFT DOOR LEFT}
     LINE (XR-(PX+PXD), Y+PY+PYD, XR-(PX+PXD+CHXD), Y+PY+CHY+ROUND(PYD*0.55)); {1ST LEFT DOOR TOP}
     LINE (XR-(PX+PXD+CHXD), Y+PY+CHY+ROUND(PYD*0.55), XR-(PX+PXD+CHXD), YB-ROUND((PX+PXD+CHXD)*0.225)); {RIGHT SIDE}

END; {OF PROCEDURE DRAWFIRSTRIGHTDOOR}

{*******************************************************************}
         {************************************************}

PROCEDURE LEF;

BEGIN
     LINE (X, Y+10, X+43, Y+10); {TOP}
     LINE (X, Y+10, X, YB-10); {LEFT}
     LINE (X+43, Y+10, X+43, YB-10); {RIGHT}
     LINE (X, YB-10, X+43, YB-10); {BOTTOM}

END; {OF PROCEDURE LEF}

{*******************************************************************}

PROCEDURE LEFDOOR;

BEGIN
     LINE (X, Y+25, X+20, Y+25); {TOP}
     LINE (X+20, Y+25, X+20, YB-10); {RIGHT}

END; {OF PROCEDURE LEFDOOR}

{*******************************************************************}

PROCEDURE RIGH;

BEGIN
     LINE (XR, Y+10, XR-43, Y+10); {TOP}
     LINE (XR, Y+10, XR, YB-10); {LEFT}
     LINE (XR-43, Y+10, XR-43, YB-10); {RIGHT}
     LINE (XR, YB-10, XR-43, YB-10); {BOTTOM}

END; {OF PROCEDURE RIGH}

{*******************************************************************}

PROCEDURE RIGHDOOR;

BEGIN
     LINE (XR, Y+25, XR-20, Y+25); {TOP}
     LINE (XR-20, Y+25, XR-20, YB-10); {RIGHT}
     LINE (XR, YB-10, XR-20, YB-10); {BOTTOM}

END; {OF PROCEDURE RIGHDOOR}

{*******************************************************************}
         {************************************************}

PROCEDURE FIRSTLEF;

BEGIN
     LINE (X+PX, Y+PY+CHY, X+PX+CHX, Y+PY+CHY); {TOP}
     LINE (X+PX, Y+PY+CHY, X+PX, YB-(PY+CHY)); {LEFT}
     LINE (X+PX+CHX, Y+PY+CHY, X+PX+CHX, YB-(PY+CHY)); {RIGHT}
     LINE (X+PX, YB-(PY+CHY), X+PX+CHX, YB-(PY+CHY)); {BOTTOM}

END; {OF PROCEDURE FIRSTLEF}

{*******************************************************************}

PROCEDURE FIRSTLEFDOOR;

BEGIN
     LINE (X+PX, Y+PY+PYD+CHY, X+PX+CHX-PXD, Y+PY+PYD+CHY); {TOP}
     LINE (X+PX+CHX-PXD, Y+PY+PYD+CHY, X+PX+CHX-PXD, YB-(PY+CHY)); {RIGHT}

END; {OF PROCEDURE FIRSTLEFDOOR}

{*******************************************************************}

PROCEDURE FIRSTRIGH;

BEGIN
     LINE (XR-PX, Y+PY+CHY, XR-(PX+CHX), Y+PY+CHY); {TOP}
     LINE (XR-PX, Y+PY+CHY, XR-PX, YB-(PY+CHY)); {LEFT}
     LINE (XR-(PX+CHX), Y+PY+CHY, XR-(PX+CHX), YB-(PY+CHY)); {RIGHT}
     LINE (XR-PX, YB-(PY+CHY), XR-(PX+CHX), YB-(PY+CHY)); {BOTTOM}

END; {OF PROCEDURE FIRSTRIGH}

{*******************************************************************}

PROCEDURE FIRSTRIGHDOOR;

BEGIN
     LINE (XR-PX, Y+PY+PYD+CHY, XR-(PX+CHX-PXD), Y+PY+PYD+CHY); {TOP}
     LINE (XR-(PX+CHX-PXD), Y+PY+PYD+CHY, XR-(PX+CHX-PXD), YB-(PY+CHY)); {RIGHT}

END; {OF PROCEDURE FIRSTRIGHDOOR}

{*******************************************************************}
         {************************************************}

PROCEDURE FIRSTLEFFULL;

BEGIN
     IF ROOMAHEAD = 1 THEN
       BEGIN
         LINE (X, Y+PY+CHY, X+PX+CHX, Y+PY+CHY); {TOP}
         LINE (X, YB-(PY+CHY), X+PX+CHX, YB-(PY+CHY)); {BOTTOM}
         LINE (X, Y+PY+CHY, X, YB-(PY+CHY)); {LEFT}
         LINE (X+PX+CHX, Y+PY+CHY, X+PX+CHX, YB-(PY+CHY)); {RIGHT}
       END
     ELSE
       BEGIN
         LINE (X+SX, Y+PY+CHY, X+PX+CHX, Y+PY+CHY); {TOP}
         LINE (X+SX, YB-(PY+CHY), X+PX+CHX, YB-(PY+CHY)); {BOTTOM}
         LINE (X+SX, Y+PY+CHY, X+SX, YB-(PY+CHY)); {LEFT}
         LINE (X+PX+CHX, Y+PY+CHY, X+PX+CHX, YB-(PY+CHY)); {RIGHT}
       END;

END; {OF PROCEDURE FIRSTLEFFULL}

{*******************************************************************}

PROCEDURE FIRSTLEFFULLDOOR;

BEGIN
     IF ROOMAHEAD = 1 THEN
       BEGIN
         LINE (X, Y+PY+CHY+PYD, X+PX+CHX-PXD, Y+PY+CHY+PYD); {TOP}
         LINE (X+PX+CHX-PXD, Y+PY+CHY+PYD, X+PX+CHX-PXD, YB-(PY+CHY)); {SIDE}
       END
     ELSE
       BEGIN
         LINE (X+SX+2*PXD, Y+PY+CHY+PYD, X+PX+CHX-2*PXD, Y+PY+CHY+PYD); {TOP}
         LINE (X+PX+CHX-2*PXD, Y+PY+CHY+PYD, X+PX+CHX-2*PXD, YB-(PY+CHY)); {SIDE}
         LINE (X+SX+2*PXD, Y+PY+CHY+PYD, X+SX+2*PXD, YB-(PY+CHY)); {RIGHT}
       END;

END;

{*******************************************************************}

PROCEDURE FIRSTRIGHFULL;

BEGIN
     IF ROOMAHEAD = 1 THEN
       BEGIN
         LINE (XR, Y+PY+CHY, XR-(PX+CHX), Y+PY+CHY); {TOP}
         LINE (XR, YB-(PY+CHY), XR-(PX+CHX), YB-(PY+CHY)); {BOTTOM}
         LINE (XR, Y+PY+CHY, XR, YB-(PY+CHY)); {LEFT}
         LINE (XR-(PX+CHX), Y+PY+CHY, XR-(PX+CHX), YB-(PY+CHY)); {RIGHT}
       END
     ELSE
       BEGIN
         LINE (XR-SX, Y+PY+CHY, XR-(PX+CHX), Y+PY+CHY); {TOP}
         LINE (XR-SX, YB-(PY+CHY), XR-(PX+CHX), YB-(PY+CHY)); {BOTTOM}
         LINE (XR-SX, Y+PY+CHY, XR-SX, YB-(PY+CHY)); {LEFT}
         LINE (XR-(PX+CHX), Y+PY+CHY, XR-(PX+CHX), YB-(PY+CHY)); {RIGHT}
       END;

END; {OF PROCEDURE FIRSTRIGHFULL}

{*******************************************************************}

PROCEDURE FIRSTRIGHFULLDOOR;

BEGIN
     IF ROOMAHEAD = 1 THEN
       BEGIN
         LINE (XR, Y+PY+CHY+PYD, XR-(PX+CHX-PXD), Y+PY+CHY+PYD); {TOP}
         LINE (XR-(PX+CHX-PXD), Y+PY+CHY+PYD, XR-(PX+CHX-PXD), YB-(PY+CHY)); {SIDE}
       END
     ELSE
       BEGIN
         LINE (XR-SX-2*PXD, Y+PY+CHY+PYD, XR-(PX+CHX-2*PXD), Y+PY+CHY+PYD); {TOP}
         LINE (XR-(PX+CHX-2*PXD), Y+PY+CHY+PYD, XR-(PX+CHX-2*PXD), YB-(PY+CHY)); {SIDE}
         LINE (XR-(SX+2*PXD), Y+PY+CHY+PYD, XR-(SX+2*PXD), YB-(PY+CHY)); {RIGHT}
       END;

END; {OF FIRSTRIGHTFULLDOOR}

{*******************************************************************}
{*******************************************************************}
{*******************************************************************}

FUNCTION CHECKWALL (N, E : BYTE) : BOOLEAN;

BEGIN
     CHECKWALL := FALSE;
     IF NOT PASS THEN
       ROOM := DATA[N,E];
     CASE DIRECTION OF
       'N' : IF ROOM[2] = '1' THEN
               CHECKWALL := TRUE;
       'S' : IF ROOM[4] = '1' THEN
               CHECKWALL := TRUE;
       'E' : IF ROOM[3] = '1' THEN
               CHECKWALL := TRUE;
       'W' : IF ROOM[1] = '1' THEN
               CHECKWALL := TRUE;
     END; {OF CASE}
     IF (FILENAME1[10] = '4') AND (LEV = 3) THEN
       CHECKWALL := TRUE;

END; {OF FUNCTION CHECKWALL}

{*******************************************************************}

FUNCTION CHECKLEFT (N, E : BYTE) : BOOLEAN;

BEGIN
     CHECKLEFT := FALSE;
     ROOM := DATA[N,E];
     CASE DIRECTION OF
       'N' : IF ROOM[1] = '1' THEN
               CHECKLEFT := TRUE;
       'S' : IF ROOM[3] = '1' THEN
               CHECKLEFT := TRUE;
       'E' : IF ROOM[2] = '1' THEN
               CHECKLEFT := TRUE;
       'W' : IF ROOM[4] = '1' THEN
               CHECKLEFT := TRUE;
     END; {OF CASE}
     IF (FILENAME1[10] = '4') AND (LEV = 3) THEN
       CHECKLEFT := TRUE;

END; {OF PROCEDURE CHECKLEFT}

{*******************************************************************}

FUNCTION CHECKRIGHT (N, E : BYTE) : BOOLEAN;

BEGIN
     CHECKRIGHT := FALSE;
     ROOM := DATA[N,E];
     CASE DIRECTION OF
       'N' : IF ROOM[3] = '1' THEN
               CHECKRIGHT := TRUE;
       'S' : IF ROOM[1] = '1' THEN
               CHECKRIGHT := TRUE;
       'E' : IF ROOM[4] = '1' THEN
               CHECKRIGHT := TRUE;
       'W' : IF ROOM[2] = '1' THEN
               CHECKRIGHT := TRUE;
     END; {OF CASE}
     IF (FILENAME1[10] = '4') AND (LEV = 3) THEN
       CHECKRIGHT := TRUE;

END; {OF PROCEDURE CHECKRIGHT}

{*******************************************************************}

PROCEDURE DRAWLEFTWALL;

BEGIN
     CASE LEFT OF
       '1' :; {DO NOTHING}
       '2' : DRAWLEFT;
       '3' : BEGIN
               DRAWLEFT;
               DRAWLEFTDOOR;
             END;
     END; {OF CASE}


END; {OF PROCEDURE DRAWLEFTWALL}

{********************************************************************}

PROCEDURE DRAWFRONTWALL;

BEGIN {PROCEDURE DRAWFRONTWALL}
     CASE CENTER OF
       '1' :; {DO NOTHING}
       '2' : DRAWFRONT;
       '3' : BEGIN
               DRAWFRONT;
               DRAWFRONTDOOR;
             END;
     END; {OF CASE}

END; {OF PROCEDURE DRAWFRONTWALL}

{*******************************************************************}

PROCEDURE DRAWRIGHTWALL;

BEGIN {PROCEDURE DRAWRIGHTWALL}
     CASE RIGHT OF
       '1' :; {DO NOTHING}
       '2' : DRAWRIGHT;
       '3' : BEGIN
               DRAWRIGHT;
               DRAWRIGHTDOOR;
             END;
     END; {OF CASE}

END; {OF PROCEDURE DRAWRIGHTWALL}

{*******************************************************************}

PROCEDURE DRAWFIRSTLEFTWALL;

BEGIN
     CASE LEFT OF
       '1' :; {DO NOTHING}
       '2' : DRAWFIRSTLEFT;
       '3' : BEGIN
               DRAWFIRSTLEFT;
               DRAWFIRSTLEFTDOOR;
             END;
     END; {OF CASE}

END; {OF PROCEDURE DRAWFIRSTLEFTWALL}

{********************************************************************}

PROCEDURE DRAWFIRSTFRONTWALL;

BEGIN {PROCEDURE DRAWFIRSTFRONTWALL}
     CASE CENTER OF
       '1' :; {DO NOTHING}
       '2' : DRAWFIRSTFRONT;
       '3' : BEGIN
               DRAWFIRSTFRONT;
               DRAWFIRSTFRONTDOOR;
             END;
     END; {OF CASE}

END; {OF PROCEDURE DRAWFIRSTFRONTWALL}

{********************************************************************}

PROCEDURE DRAWFIRSTRIGHTWALL;

BEGIN {PROCEDURE DRAWFIRSTRIGHTWALL}
     CASE RIGHT OF
       '1' :; {DO NOTHING}
       '2' : DRAWFIRSTRIGHT;
       '3' : BEGIN
               DRAWFIRSTRIGHT;
               DRAWFIRSTRIGHTDOOR;
             END;
     END; {OF CASE}

END; {OF PROCEDURE DRAWFIRSTRIGHTWALL}

{*******************************************************************}

PROCEDURE SECRETDOORS (VAR WALL : CHAR);

BEGIN
     IF WALL = '4' THEN
       IF FDOOR THEN
         WALL := '3'
       ELSE
         WALL := '2';

END; {OF PROCEDURE SECRETDOORS}

{*******************************************************************}

PROCEDURE DRAWFIRST;

BEGIN
     SECRETDOORS (LEFT);
     DRAWFIRSTLEFTWALL;
     SECRETDOORS (CENTER);
     DRAWFIRSTFRONTWALL;
     SECRETDOORS (RIGHT);
     DRAWFIRSTRIGHTWALL;

END; {OF PROCEDURE DRAWFIRST}

{*******************************************************************}

PROCEDURE DRAWFIRSTLEFTSIDE;

BEGIN
     SECRETDOORS (CENTER);
     CASE CENTER OF
       '1' :; {DO NOTHING}
       '2' : IF FULL THEN FIRSTLEFFULL
             ELSE FIRSTLEF;
       '3' : IF FULL THEN
               BEGIN
                 FIRSTLEFFULL;
                 FIRSTLEFFULLDOOR;
               END
             ELSE
               BEGIN
                 FIRSTLEF;
                 FIRSTLEFDOOR;
               END;
     END; {OF CASE}

END; {OF PROCEDURE DRAWFIRSTLEFTSIDE}

{*******************************************************************}

PROCEDURE DRAWFIRSTRIGHTSIDE;

BEGIN
     SECRETDOORS (CENTER);
     CASE CENTER OF
       '1' :; {DO NOTHING}
       '2' : IF FULL THEN FIRSTRIGHFULL
             ELSE FIRSTRIGH;
       '3' : IF FULL THEN
               BEGIN
                 FIRSTRIGHFULL;
                 FIRSTRIGHFULLDOOR;
               END
             ELSE
               BEGIN
                 FIRSTRIGH;
                 FIRSTRIGHDOOR;
               END;
     END; {OF CASE}

END; {OF PROCEDURE DRAWFIRSTRIGHTSIDE}

{*******************************************************************}

PROCEDURE WRAPAROUND (VAR INDEX : BYTE);

BEGIN
     IF INDEX < 1 THEN
       INDEX := 21;
     IF INDEX > 21 THEN
       INDEX := 1;

END; {OF PROCEDURE WRAPAROUND}

{*******************************************************************}

PROCEDURE LIMITS (A, B, N, E, C : BYTE);

BEGIN
     WRAPAROUND (N);
     WRAPAROUND (E);
     WRAPAROUND (TEMP);
     WRAPAROUND (TEMP2);
     ROOM := DATA[TEMP,TEMP2];
     IF (ROOM[A] = '1') AND (ROOM[B] = '1') THEN
       FULL := TRUE
     ELSE
       FULL := FALSE;
     ROOM := DATA[N,E];
     CENTER := ROOM[C];

END; {OF PROCEDURE LIMITS}

{*******************************************************************}

PROCEDURE FIRSTLEFTSIDE (N, E : BYTE);

BEGIN
     CASE DIRECTION OF
       'N' : BEGIN
               TEMP := N+1;
               TEMP2 := E-1;
               DEC (E);
               LIMITS (2, 3, N, E, 2);
             END;
       'S' : BEGIN
               TEMP := N-1;
               TEMP2 := E+1;
               INC (E);
               LIMITS (4, 1, N, E, 4);
             END;
       'E' : BEGIN
               TEMP := N-1;
               TEMP2 := E-1;
               DEC (N);
               LIMITS (3, 4, N, E, 3);
             END;
       'W' : BEGIN
               TEMP := N+1;
               TEMP2 := E+1;
               INC (N);
               LIMITS (1, 2, N, E, 1);
             END;
     END; {OF CASE}
     DRAWFIRSTLEFTSIDE;

END; {OF PROCEDURE FIRSTLEFTSIDE}

{*******************************************************************}

PROCEDURE FIRSTRIGHTSIDE (N, E : BYTE);

BEGIN
     CASE DIRECTION OF
       'N' : BEGIN
               TEMP := N+1;
               TEMP2 := E+1;
               INC (E);
               LIMITS (1, 2, N, E, 2);
             END;
       'S' : BEGIN
               TEMP := N-1;
               TEMP2 := E-1;
               DEC (E);
               LIMITS (4, 3, N, E, 4);
             END;
       'E' : BEGIN
               TEMP := N+1;
               TEMP2 := E-1;
               INC (N);
               LIMITS (2, 3, N, E, 3);
             END;
       'W' : BEGIN
               TEMP := N-1;
               TEMP2 := E+1;
               DEC (N);
               LIMITS (1, 4, N, E, 1);
             END;
     END; {OF CASE}
     DRAWFIRSTRIGHTSIDE;

END; {OF PROCEDURE FIRSTRIGHTSIDE}

{*******************************************************************}

PROCEDURE GETWALLS (A, B, C, N, E : BYTE);

BEGIN
     ROOM := DATA[N,E];
     LEFT := ROOM[A];
     CENTER := ROOM[B];
     RIGHT := ROOM[C];

END; {OF PROCEDURE GETWALLS}

{*******************************************************************}

PROCEDURE FIRSTROOMFRONT (N, E : BYTE);

BEGIN
     INC (ROOMAHEAD);
     CASE DIRECTION OF
       'N' : BEGIN
               DEC (N);
               WRAPAROUND (N);
               GETWALLS (1, 2, 3, N, E)
             END;
       'S' : BEGIN
               INC (N);
               WRAPAROUND (N);
               GETWALLS (3, 4, 1, N, E);
             END;
       'E' : BEGIN
               INC (E);
               WRAPAROUND (E);
               GETWALLS (2, 3, 4, N, E);
             END;
       'W' : BEGIN
               DEC (E);
               WRAPAROUND (E);
               GETWALLS (4, 1, 2, N, E);
             END;
     END; {OF CASE}
     DRAWFIRST;
     IF CHECKLEFT (N, E) THEN
        FIRSTLEFTSIDE (N, E);
     IF CHECKRIGHT (N, E) THEN
        FIRSTRIGHTSIDE (N, E);
     IF (CHECKWALL (N, E)) AND (ROOMAHEAD <= 3) THEN
       BEGIN
         SX := PX;
         INC (PX, CHX);
         INC (PY, CHY);
         CHX := ROUND(CHX*0.65);
         CHY := ROUND(CHY*0.65);
         CHXD := ROUND(CHXD*0.65);
         PXD := ROUND(PXD*0.65);
         PYD := ROUND(PYD*0.6570);
         FIRSTROOMFRONT (N, E);
       END;

END; {OF PROCEDURE FIRSTROOMFRONT}

{*******************************************************************}

PROCEDURE DRAWLEFTSIDE;

BEGIN
     CASE CENTER OF
       '1' :; {DO NOTHING}
       '2' : LEF;
       '3' : BEGIN
               LEF;
               LEFDOOR;
             END;
       '4' : IF FDOOR THEN
               BEGIN
                 LEF;
                 LEFDOOR;
               END
             ELSE
               LEF;
     END; {OF CASE}

END; {OF PROCEDURE DRAWLEFTSIDE}

{*******************************************************************}

PROCEDURE DRAWRIGHTSIDE;

BEGIN
     CASE CENTER OF
       '1' :; {DO NOTHING}
       '2' : RIGH;
       '3' : BEGIN
               RIGH;
               RIGHDOOR;
             END;
       '4' : IF FDOOR THEN
               BEGIN
                 RIGH;
                 RIGHDOOR;
               END
             ELSE
               RIGH;
     END; {OF CASE}

END; {OF PROCEDURE DRAWRIGHTSIDE}

{*******************************************************************}

PROCEDURE LEFTSIDE (N, E : BYTE);

BEGIN
     CASE DIRECTION OF
       'N' : BEGIN
               DEC (E);
               WRAPAROUND (E);
               GETWALLS (1, 2, 1, N, E);
             END;
       'S' : BEGIN
               INC (E);
               WRAPAROUND (E);
               GETWALLS (1, 4, 1, N, E);
             END;
       'E' : BEGIN
               DEC (N);
               WRAPAROUND (N);
               GETWALLS (1, 3, 1, N, E);
             END;
       'W' : BEGIN
               INC (N);
               WRAPAROUND (N);
               GETWALLS (1, 1, 1, N, E);
             END;
     END; {OF CASE}
     DRAWLEFTSIDE;

END; {OF PROCEDURE LEFTSIDE}

{*******************************************************************}

PROCEDURE RIGHTSIDE (N, E : BYTE);

BEGIN
     CASE DIRECTION OF
       'N' : BEGIN
               INC (E);
               WRAPAROUND (E);
               GETWALLS (1, 2, 1, N, E);
             END;
       'S' : BEGIN
               DEC (E);
               WRAPAROUND (E);
               GETWALLS (1, 4, 1, N, E);
             END;
       'E' : BEGIN
               INC (N);
               WRAPAROUND (N);
               GETWALLS (1, 3, 1, N, E);
             END;
       'W' : BEGIN
               DEC (N);
               WRAPAROUND (N);
               GETWALLS (1, 1, 1, N, E);
             END;
     END; {OF CASE}
     DRAWRIGHTSIDE;

END; {OF PROCEDURE RIGHTSIDE}

{*******************************************************************}

PROCEDURE DRAWROOM;

BEGIN
     CLEAR;
     SETLINESTYLE (SOLIDLN, 0, NORMWIDTH);
     IF LEFT = '4' THEN
       IF FDOOR THEN
         LEFT := '3'
       ELSE
         LEFT := '2';
     DRAWLEFTWALL;
     IF CENTER = '4' THEN
       IF FDOOR THEN
         CENTER := '3'
       ELSE
         CENTER := '2';
     DRAWFRONTWALL;
     IF RIGHT = '4' THEN
       IF FDOOR THEN
         RIGHT := '3'
       ELSE
         RIGHT := '2';
     DRAWRIGHTWALL;

END; {OF PROCEDURE DRAWROOM}

{*******************************************************************}

PROCEDURE FRONTVIEW;

BEGIN
     IF ROOM[6] <> '4' THEN
       BEGIN
         IF NOT PASS THEN
           ROOM := DATA[N,E];
         CASE DIRECTION OF
           'N' : BEGIN
                   LEFT := ROOM[1];
                   CENTER := ROOM[2];
                   RIGHT := ROOM[3];
                 END;
           'S' : BEGIN
                   LEFT := ROOM[3];
                   CENTER := ROOM[4];
                   RIGHT := ROOM[1];
                 END;
           'E' : BEGIN
                   LEFT := ROOM[2];
                   CENTER := ROOM[3];
                   RIGHT := ROOM[4];
                 END;
           'W' : BEGIN
                   LEFT := ROOM[4];
                   CENTER := ROOM[1];
                   RIGHT := ROOM[2];
                 END
         END; {OF CASE}
         DRAWROOM;
       END {IF THEN}
     ELSE
       BEGIN
         CLEAR;
         LIGHTSP := FALSE;
         LGLIGHTSP := FALSE;
         LIGHTICON (FALSE);
       END;

END; {OF PROCEDURE FRONTVIEW}

{*******************************************************************}

PROCEDURE VIEWAHEAD;

BEGIN
     SETCOLOR (DKYELLOW);
     IF NOT PASS THEN
       ROOM := DATA[N,E];
     FRONTVIEW;
     ROOMAHEAD := 0;
     PX := 43;      {43}                      {************}
     PY := 10;      {10}
     PXD := 13;     {13}                      {************}
     PYD := 12;     {12}
     CHXD := 44;    {44}                      {************}
     CHX := 70;     {70}
     CHY := 15;     {15}
     IF CHECKWALL (N, E) THEN
        FIRSTROOMFRONT (N, E);
     IF CHECKLEFT (N, E) THEN
        LEFTSIDE (N, E);
     IF CHECKRIGHT (N, E) THEN
        RIGHTSIDE (N, E);

END; {OF PROCEDURE VIEWAHEAD}

{*******************************************************************}
{*******************************************************************}

PROCEDURE SHOWCHAR (CHARACTER : PERSON);

BEGIN
     CLEAR;
     WITH CHARACTER DO
       BEGIN
         OUTTEXTXY (250, 5, NAME);
         SETCOLOR (LTBLUE);
         OUTTEXTXY (150, 15, 'STR :');
         OUTTEXTXY (150, 25, 'INT :');
         OUTTEXTXY (150, 35, 'WIS :');
         OUTTEXTXY (150, 45, 'DEX :');
         OUTTEXTXY (150, 55, 'CON :');
         OUTTEXTXY (150, 65, 'CHA :');
         OUTTEXTXY (150, 75, 'LUK :');
         FOR J := 1 TO 7 DO
           BEGIN
             STR(ABILITIES[J], NUMSTR);
             OUTTEXTXY (200, 5+J*10, NUMSTR);
           END; {FOR LOOP-J}
         SETCOLOR (LTYELLOW);
         OUTTEXTXY (250, 15, 'RACE : '+RACE);
         OUTTEXTXY (250, 25, 'CLASS : '+CLASS);
         STR (LEVEL, NUMSTR);
         OUTTEXTXY (250, 35, 'LEVEL : '+NUMSTR);
         STR (AC, NUMSTR);
         OUTTEXTXY (250, 45, 'AC : '+NUMSTR);
         STR(HPLEFT,NUMSTR);
         STR(HPTOT,NUMSTR2);
         OUTTEXTXY (250, 55, 'HIT POINTS : '+NUMSTR+' / '+NUMSTR2);
         STR (SPELLPTLEFT, NUMSTR);
         STR (SPELLPTSTOT, NUMSTR2);
         OUTTEXTXY (250, 65, 'SPELL POINTS : '+NUMSTR+' / '+NUMSTR2);
         STR (SPELLLEVEL, NUMSTR);
         OUTTEXTXY (250, 75, 'SPELL LEVEL : '+NUMSTR);
         STR(EXP,NUMSTR);
         OUTTEXTXY (200, 84, 'EXPERIENCE : '+NUMSTR);
         STR(MONEY,NUMSTR);
         OUTTEXTXY (200, 93, 'GOLD : '+NUMSTR);
       END; {OF WITH ROSTER}

END; {OF SHOWCHAR}

{*******************************************************************}

PROCEDURE SHOWCHAROPT;

BEGIN
     SETCOLOR (DKYELLOW);
     OUTTEXTXY (440, 15, '<P>OOL MONEY');
     OUTTEXTXY (440, 25, '<D>IVY MONEY');
     OUTTEXTXY (440, 35, '<T>RADE MONEY');
     OUTTEXTXY (440, 45, '<C>ONTINUE');

END; {OF PROCEDURE SHOWCHAROPT}

{*******************************************************************}

PROCEDURE SHOWEQUIP (CHARACTER : PERSON);

BEGIN
     SETTEXTSTYLE (DEFAULTFONT, 0, 1);
     SETCOLOR (LTCYAN);
     FOR J := 1 TO 8 DO
       WITH CHARACTER.EQUIPMENT[J] DO
         BEGIN
           STR (J, NUMSTR);
           IF EQUIPED THEN
             BEGIN
               SETCOLOR (LTRED);
               OUTTEXTXY (105, 20+J*8,  '*');
               SETCOLOR (LTCYAN);
             END;
           OUTTEXTXY (120, 20+J*8, NUMSTR+') '+ITEM);
         END;

END; {OF PROCEDURE SHOWEQUIP}

{*******************************************************************}

PROCEDURE SHOWEQUIPOPT;

BEGIN
     SETCOLOR (DKYELLOW);
     OUTTEXTXY (440, 25, '# - EQUIP');
     OUTTEXTXY (440, 35, '<D>ROP ITEM');
     OUTTEXTXY (440, 45, '<T>RADE ITEM');
     OUTTEXTXY (440, 55, '<C>ONTINUE');

END;

{*******************************************************************}

PROCEDURE VIEWCHAR;

BEGIN
     VAL (RESPONCE, INT, CODE);
     REPEAT
       SHOWCHAR (ROSTER[INT]);
       SHOWCHAROPT;
       RESPONCE := UREADKEY;
       CASE RESPONCE OF
         'P' : POOL;
         'D' : DIVY;
         'T' : TRADEMONEY;
         'C' :; {DO NOTHING}
       END; {OF CASE}
     UNTIL RESPONCE = 'C';
     REPEAT
       CLEAR;
       SETTEXTSTYLE (TRIPLEXFONT, 0, 1);
       SETCOLOR (LTBLUE);
       OUTTEXTXY (160, 3, 'Equipment');
       SETCOLOR (DKYELLOW);
       SHOWEQUIP (ROSTER[INT]);
       SHOWEQUIPOPT;
       RESPONCE := UREADKEY;
       CASE RESPONCE OF
         'C'      :; {DO NOTHING}
         'T'      : TRADEITEM;
         'D'      : DROPITEM;
         '1'..'8' : BEGIN
                      EQUIP (RESPONCE);
                      WRITECHARACTER (INT, FALSE);
                    END;
       END; {OF CASE}
     UNTIL RESPONCE = 'C';

END; {OF VIEWCHAR}

{*******************************************************************}

PROCEDURE WRITECHARACTER (INT : INTEGER; INFIGHT : BOOLEAN);

BEGIN
     CLEARBOTTOM (INT);
     SETCOLOR (DKMAGENTA);
     WITH ROSTER[INT] DO
       IF (INT > 0) OR ((INT = 0) AND (ROSTER[0].SPECIAL <> DEAD)) THEN
         BEGIN
           IF (HPLEFT < ROUND(0.07 * HPTOT)) THEN
              SETCOLOR (LTBLUE);
           STR (INT, NUMSTR);
           OUTTEXTXY (105, 136+(INT+1)*8, NUMSTR+')');
           OUTTEXTXY (130, 136+(INT+1)*8, NAME);
           STR (AC, NUMSTR);
           OUTTEXTXY (310, 136+(INT+1)*8, NUMSTR);
           STR (HPLEFT, NUMSTR);
           IF SPECIAL = POISON THEN
             NUMSTR := NUMSTR+'-';
           OUTTEXTXY (360, 136+(INT+1)*8, NUMSTR);
           STR (SPELLPTLEFT, NUMSTR);
           OUTTEXTXY (410, 136+(INT+1)*8, NUMSTR);
           IF (NOT INFIGHT) OR ((INFIGHT) AND (NOT (SPECIAL IN [POISON, OK]))) THEN
             GETSTATUS (INT);
           OUTTEXTXY (460, 136+(INT+1)*8, STATUS);
         END; {OF WITH DO}

END; {OF PROCEDURE WRITECHARACTER}

{*******************************************************************}

PROCEDURE GETSTATUS (INT : INTEGER);

BEGIN
   WITH ROSTER[INT] DO
     CASE SPECIAL OF
       OK      : STATUS := 'OK';
       DEAD    : STATUS := 'DEAD';
       STONE   : STATUS := 'STONE';
       PARALYS : STATUS := 'PARALYS';
       POISON  : STATUS := 'POISON';
       ASLEEP  : STATUS := 'ASLEEP';
     END; {OF CASE}

END; {OF GETSTATUS}

{*******************************************************************}

PROCEDURE SORTROSTER;

BEGIN
     CHARACTER := ROSTER[INT];
     FOR K := INT-1 DOWNTO J DO
       ROSTER[K+1] := ROSTER[K];
     ROSTER[J] := CHARACTER;
     FOR INT := 1 TO PEOPLE DO
       WRITECHARACTER (INT, FALSE);

END; {OF SORTROSTER}

{*******************************************************************}

PROCEDURE SORTROSTERTOO;

BEGIN
     CHARACTER := ROSTER[INT];
     FOR K := INT+1 TO J DO
       ROSTER[K-1] := ROSTER[K];
     ROSTER[J] := CHARACTER;
     FOR INT := 1 TO PEOPLE DO
       WRITECHARACTER (INT, FALSE);

END; {OF SORTROSTERTOO}

{********************************************************************}

PROCEDURE REORDER;

BEGIN
     CLEAR;
     OUTTEXTXY (200, 55, 'MOVE WHICH CHARACTER?');
     INT := GETPERSON (0, PEOPLE + 1);
     IF INT > 0 THEN
       IF (ROSTER[INT].SPECIAL = OK) OR (ROSTER[INT].SPECIAL = POISON) THEN
         BEGIN
           OUTTEXTXY (200, 65, 'MOVE HIM TO WHERE?');
           J := GETPERSON (0, PEOPLE + 1);
           IF J > 0 THEN
             IF INT > J THEN
               SORTROSTER
             ELSE
               SORTROSTERTOO;
         END;

END; {OF PROCEDURE REORDER}

{****************************************************************}

PROCEDURE CONDENSEEQUIPMENT (VAR CHARACTER : PERSON);

BEGIN
     FOR I := 2 TO 8 DO
       WITH CHARACTER DO
         IF EQUIPMENT[I-1].ITEM = '' THEN
           BEGIN
             EQUIPMENT[I-1] := EQUIPMENT[I];
             EQUIPMENT[I] := SCUM;
           END;

END; {OF CONDENSEEQUIPMENT}

{*******************************************************************}

END. {OF UNIT DRAW}