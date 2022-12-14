unit Matrix.Client;

interface

uses
  Citrus.Mandarin,
  Matrix.Types.Response,
  System.SysUtils;

type
  IHTTPResponse = Citrus.Mandarin.IHTTPResponse;

  TMatrixaPi = class
  private
    FCli: TMandarinClientJson;
    FPooling: TMandarinLongPooling;
    FUrl: string;
    FIsSyncMode: Boolean;
    FAccessToken: string;
  protected
    procedure DoCheckError(AHttpResp: IHTTPResponse);

  public
    procedure ServerDiscoveryInformation(AWelKnownCallback: TProc<TmtrWelKnown, IHTTPResponse>);
    /// <summary>
    /// Authenticates the user.
    /// </summary>
    /// <remarks>
    /// Authenticates the user, and issues an access token they can use to authorize
    /// themself in subsequent requests.
    /// </remarks>
    procedure LoginWithPassword(const AUser, APassword: string; ALoginCallback: TProc<TmtrLogin, IHTTPResponse>);
    procedure ClientVersions(AVersionsCallback: TProc<TmtrVersions, IHTTPResponse>);
    /// <summary>
    /// Create a new room
    /// </summary>
    /// <remarks>
    /// Create a new room with various configuration options.
    /// </remarks>
    procedure CreateRoom(const AInvitedUserIds: TArray<string>; ARoomCallback: TProc<string, IHTTPResponse>);
    constructor Create(const AUrl: string = 'https://matrix-client.matrix.org');
    destructor Destroy; override;
    property IsSyncMode: Boolean read FIsSyncMode write FIsSyncMode;
    property Url: string read FUrl write FUrl;
    property AccessToken: string read FAccessToken write FAccessToken;
  end;

implementation

uses
  Matrix.Types.Requests,
  System.Net.HttpClient;

const
  API_ENDPOINT_SERVER = '{server}';
  API_ENDPOINT_BASE = API_ENDPOINT_SERVER + '/_matrix/client/';
  API_ENDPOINT_NO_VER = API_ENDPOINT_BASE + '{method}';
  API_ENDPOINT_V_3 = API_ENDPOINT_SERVER + '/_matrix/client/v3/{method}';

constructor TMatrixaPi.Create(const AUrl: string = 'https://matrix-client.matrix.org');
begin
  inherited Create;
  FCli := TMandarinClientJson.Create();
  FCli.OnBeforeExcecute := procedure(AMandarin: IMandarin)
    begin
      AMandarin.AddUrlSegment('server', FUrl);
      AMandarin.AddHeader('Content-Type', 'application/json');
    end;
  FPooling := TMandarinLongPooling.Create(FCli);
  FPooling.OnGetMandarinCallback := function(): IMandarin
    begin

    end;
  FUrl := AUrl;
  FIsSyncMode := True;
end;

type
  TSimpleCreateRoom = class
  private
    [JsonName('invite')]
    FMembers: TArray<string>;
  public
    property Members: TArray<string> read FMembers write FMembers;
  end;

procedure TMatrixaPi.CreateRoom(const AInvitedUserIds: TArray<string>; ARoomCallback: TProc<string, IHTTPResponse>);
var
  LRoom: TSimpleCreateRoom;
begin
  LRoom := TSimpleCreateRoom.Create;
  try
    FCli.NewMandarin<TmtrRoom>(API_ENDPOINT_V_3) //
      .AddUrlSegment('method', 'createRoom') //
      .SetRequestMethod(sHTTPMethodPost) //
      .SetBody(LRoom) //
      .Execute(
      procedure(ARoom: TmtrRoom; AResponse: IHTTPResponse)
      begin
        if Assigned(ARoomCallback) then
          ARoomCallback(ARoom.RoomId, AResponse);
        ARoom.Free;
      end, FIsSyncMode);
  finally
    LRoom.Free;
  end;
end;

destructor TMatrixaPi.Destroy;
begin
  FCli.Free;
  FPooling.Free;
  inherited Destroy;
end;

procedure TMatrixaPi.ClientVersions(AVersionsCallback: TProc<TmtrVersions, IHTTPResponse>);
begin
  FCli.NewMandarin<TmtrVersions>(API_ENDPOINT_NO_VER) //
    .AddUrlSegment('method', 'versions') //
    .SetRequestMethod(sHTTPMethodGet) //
    .Execute(AVersionsCallback, FIsSyncMode);
end;

procedure TMatrixaPi.DoCheckError(AHttpResp: IHTTPResponse);
begin
  if AHttpResp.StatusCode = 200 then
    Exit;
end;

procedure TMatrixaPi.LoginWithPassword(const AUser, APassword: string; ALoginCallback: TProc<TmtrLogin, IHTTPResponse>);
var
  LLogin: TmtxLoginRequest;
begin
  LLogin := TmtxLoginRequest.Create(AUser, APassword);
  LLogin.InitialDeviceDisplayName := 'Jungle Phone';
  try
    FCli.NewMandarin<TmtrLogin>(API_ENDPOINT_V_3) //
      .SetRequestMethod(sHTTPMethodPost) //
      .AddUrlSegment('method', 'login') //
      .SetBody(LLogin) //
      .Execute(ALoginCallback, FIsSyncMode);
  finally
    LLogin.Free;
  end;
end;

procedure TMatrixaPi.ServerDiscoveryInformation(AWelKnownCallback: TProc<TmtrWelKnown, IHTTPResponse>);
begin
  raise ENotSupportedException.Create('Unsupported method');
  FCli.NewMandarin<TmtrWelKnown>(API_ENDPOINT_SERVER + '/.well-known/matrix/client') //
    .SetRequestMethod(sHTTPMethodGet) //
    .Execute(AWelKnownCallback, FIsSyncMode);
end;

end.
