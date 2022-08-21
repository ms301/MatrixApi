unit MatrixaPi;

interface

uses
  CloudAPI.Client,
  CloudAPI.Request,
  MatrixaPi.Responses,
  System.SysUtils, MatrixaPi.Request;

type
  TMatrixaPi = class
  private
    FCloudApi: TCloudApiClient;
    FApiServer: string;
    procedure SetApiServer(const Value: string);
    procedure TryInternalExecuteAsync<TArgument, TResult>(AArgument: TArgument; AResponse: TProc<TResult>); overload;
    procedure TryInternalExecuteAsync<TResult>(ARequest: IcaRequest; AResp: TProc<TResult>); overload;
  public
    constructor Create;
    destructor Destroy; override;
  public
    procedure Versions(AOnResult: TProc<TVersionResponse>);
    procedure Register(ARegInfo: TMatrixRegister; AOnResult: TProc<TMatrixResponse>);
    property ApiServer: string read FApiServer write SetApiServer;
  end;

implementation

uses

  CloudAPI.RequestArgument,
  CloudAPI.Response,
  CloudAPI.Types;

{ TMatrixaPi }

procedure TMatrixaPi.TryInternalExecuteAsync<TResult>(ARequest: IcaRequest; AResp: TProc<TResult>);
begin
  FCloudApi.TryExecuteAsync<TResult>(ARequest,
    procedure(ACloudResp: IcaResponse<TResult>)
    begin
      if Assigned(AResp) then
        AResp(ACloudResp.Data);
    end);
end;

procedure TMatrixaPi.Register(ARegInfo: TMatrixRegister; AOnResult: TProc<TMatrixResponse>);
begin
  TryInternalExecuteAsync<TMatrixRegister, TMatrixResponse>(ARegInfo, AOnResult);
end;

procedure TMatrixaPi.TryInternalExecuteAsync<TArgument, TResult>(AArgument: TArgument; AResponse: TProc<TResult>);
var
  LReq: IcaRequest;
begin
  LReq := TcaRequestArgument.Current.ObjToRequest<TArgument>(AArgument);
  LReq.AddUrlSegment('ApiServer', FApiServer);
  TryInternalExecuteAsync<TResult>(LReq, AResponse);
end;

constructor TMatrixaPi.Create;
begin
  inherited Create();
  FCloudApi := TCloudApiClient.Create;
  FCloudApi.HttpClient.ContentType := 'application/json';
  FCloudApi.HttpClient.AcceptEncoding := 'utf-8';
  FCloudApi.BaseUrl := '{ApiServer}';
  //
  FApiServer := 'https://matrix-client.matrix.org';
end;

destructor TMatrixaPi.Destroy;
begin
  FCloudApi.Free;
  inherited;
end;

procedure TMatrixaPi.SetApiServer(const Value: string);
begin
  FApiServer := Value;
end;

procedure TMatrixaPi.Versions(AOnResult: TProc<TVersionResponse>);
begin
  TryInternalExecuteAsync<TVersionRequest, TVersionResponse>(TVersionRequest.Default, AOnResult);
end;

end.
