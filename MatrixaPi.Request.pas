unit MatrixaPi.Request;

interface

uses
  CloudApi.Attributes,
  CloudApi.Types;

type

  [caName('_matrix/client/versions')]
  [caParameterType(TcaParameterType.QueryString)]
  TVersionRequest = record
  public
    class function Default: TVersionRequest; static;
  end;

  [caName('_matrix/client/r0/register')]
  [caParameterType(TcaParameterType.RequestBody)]
  TMatrixRegister = record
  private
    [caName('username')]
    FUsername: string;
    [caName('bind_email')]
    FBindEmail: string;
    [caName('password')]
    FPassword: string;
  public
    class function Create(const AUserName, ABindEMail, APassword: string): TMatrixRegister; static;
  public
    property Username: string read FUsername write FUsername;
    property BindEmail: string read FBindEmail write FBindEmail;
    property Password: string read FPassword write FPassword;
  end;

implementation

class function TVersionRequest.Default: TVersionRequest;
begin
  // TODO -cMM: TVersionRequest.Default default body inserted
end;

{ TMatrixRegister }

class function TMatrixRegister.Create(const AUserName, ABindEMail, APassword: string): TMatrixRegister;
begin
  Result.FUsername := AUserName;
  Result.FBindEmail := ABindEMail;
  Result.FPassword := APassword;
end;

end.
