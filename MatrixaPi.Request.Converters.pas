unit MatrixaPi.Request.Converters;

interface

type
  TMatrixRequestConverters = class
  protected
  public
    class procedure Initialize;
  end;

implementation

uses
  MatrixaPi.Request,
  CloudAPI.RequestArgument;

{ TMatrixRequestConverters }

class procedure TMatrixRequestConverters.Initialize;
begin
  TcaRequestArgument.Current.RegisterToJson<TMatrixRegister>;
end;

end.
