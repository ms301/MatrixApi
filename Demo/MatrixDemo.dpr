program MatrixDemo;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  MatrixaPi,
  System.SysUtils;

procedure Test;
var
  LMatrix: TMatrixaPi;
begin
  LMatrix := TMatrixaPi.Create;
  try

  finally
    LMatrix.Free;
  end;
end;

begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
    Test;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
