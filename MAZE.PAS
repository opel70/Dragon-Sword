PROGRAM MAZE;

USES
    VARIABLE, CITY, MAIN, GENERAL, DRAW, GRAPH, DOS, CRT;

{*******************************************************************}

PROCEDURE CBREAK (FLAGS, CS, IP, AX, BX, CX, DX, SI, DI, DS, ES, BP : WORD);
INTERRUPT;

BEGIN

END; {OF INTERRUPT CBREAK}

{*******************************************************************}

PROCEDURE EXITPROCEDURE;

VAR
   FSAVE  : FILE;
   BUF    : POINTER;
   SIZE1  : LONGINT;
   WASTE  : INTEGER;
   CH     : CHAR;
   STRG   : STRING[8];

BEGIN
     EXITPROC := EXITSAVE;
     SETINTVEC ($23, INT1BSAVE);
     IF (NOT NOSONG) THEN
       SETINTVEC ($1C, INT1CSAVE);

     IF NOT (GRDRIVER IN [CGA, HERCMONO]) THEN
       BEGIN
         SIZE1 := IMAGESIZE (120, 10, 600, 184);
         GETMEM (BUF, SIZE1);

         ASSIGN (FSAVE, 'DSDATA.F13');
         RESET (FSAVE, SIZE1);
         BLOCKREAD (FSAVE, BUF^, 1, WASTE);
         CLOSE (FSAVE);

         SETFILLSTYLE (SOLIDFILL, LIGHTBLUE);
         BAR (0,0,639,199);
         SETTEXTSTYLE (TRIPLEXFONT, VERTDIR, 9);
         SETUSERCHARSIZE (2,3,3,1);
         SETCOLOR (LIGHTRED);
         OUTTEXTXY (-10, 0, 'BoTToM enterprise');
         SETCOLOR (RED);
         SETTEXTSTYLE (SMALLFONT, HORIZDIR, 3);
         OUTTEXTXY (608, 191, '(c) 1990');

         PUTIMAGE (120, 10, BUF^, COPYPUT);

         REPEAT
           FOR WASTE := 0 TO 15 DO
             SETPALETTE (14, WASTE);
         UNTIL KEYPRESSED;
         CH := READKEY;
       END;

     CLOSEGRAPH;
     WRITELN ('BYE!');

     HALT (0);

END; {OF PROCEDURE EXITPROCEDURE}

{*******************************************************************}

BEGIN {MAIN PROGRAM}
     EXITSAVE := EXITPROC;
     EXITPROC := @EXITPROCEDURE;

     NEW1BINT := @CBREAK;
     GETINTVEC ($23, INT1BSAVE);
     SETINTVEC ($23, NEW1BINT);

     FIRSTINIT;
     GUILDSTUFF;
     MOVE;

     HALT (0);

END.