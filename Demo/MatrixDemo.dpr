program MatrixDemo;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  MatrixaPi,
  MatrixaPi.Responses,
  System.SysUtils, System.Generics.Collections, MatrixaPi.Request;

procedure Test;
var
  LMatrix: TMatrixaPi;
begin
  LMatrix := TMatrixaPi.Create;
  try
    LMatrix.Versions(
      procedure(AOnResponse: TVersionResponse)
      var
        LFuture: TPair<string, Boolean>;
      begin
        Writeln(string.Join(', ', AOnResponse.Versions));
        for LFuture in AOnResponse.UnstableFeatures do
          Writeln(LFuture.Key + ' = ' + LFuture.Value.ToString(TUseBoolStrs.True));
      end);

    LMatrix.Register(TMatrixRegister.Create('rareMax', 'rareMax@limon.team', 'StayWithUkraine'),
      procedure(AOnResponse: TMatrixResponse)
      begin
           Writeln(AOnResponse.Error)
      end);
    Readln;
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
