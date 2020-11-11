
{ Copyright (c) 1985, 1990 by Borland International, Inc. }

unit DSDriv;
{ Sample unit to accompany BGILINK.PAS. This unit links the BGI graphics
  driver into a single TPU file. This makes it easy to link the driver files
  directly into an .EXE file. See BGILINK.PAS for more information.
}
interface

procedure CgaDriverProc;
procedure EgaVgaDriverProc;
procedure HercDriverProc;

implementation

procedure CgaDriverProc; external;
{$L CGA.OBJ }

procedure EgaVgaDriverProc; external;
{$L EGAVGA.OBJ }

procedure HercDriverProc; external;
{$L HERC.OBJ }

end.
