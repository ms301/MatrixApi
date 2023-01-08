unit Matrix.Client;

interface

uses
  Citrus.Mandarin,
  Citrus.Authenticator.JWT,
  FMX.Types,
  Matrix.Types.Response,
  System.SysUtils;

type
  IHTTPResponse = Citrus.Mandarin.IHTTPResponse;

  TMatrixaPi = class
  private
    FCli: TMandarinClientJson;
    FUrl: string;
    FIsSyncMode: Boolean;
    FAuthenticator: TJwtAuthenticator;
    FNextBatchSync: string;
    FIsPoolingOn: Boolean;
    procedure SetIsPoolingOn(const Value: Boolean);
  protected
    procedure DoCheckError(AHttpResp: IHTTPResponse);
    procedure RunSync(const ANext: string);
  public
    /// <summary> Gets the homeserver’s supported login types to authenticate users.
    /// Clients should pick one of these and supply it as the type when logging in.
    /// </summary>
    procedure LoginFlows(AFlowsCallback: TProc<TmtrLoginFlows, IHTTPResponse>);
    procedure Start;
    procedure Stop;
    procedure ServerDiscoveryInformation(AWelKnownCallback: TProc<TmtrWelKnown, IHTTPResponse>);
    procedure PublicRooms(APublicRoomsCallback: TProc<TmtrPublicRooms, IHTTPResponse>; const ALimit: Integer = 25;
      const ASince: string = ''; const AServer: string = ''); overload;
    /// <summary>
    /// Lists the public rooms on the server, with optional filter.
    /// </summary>
    /// <remarks>
    /// This API returns paginated responses. The rooms are ordered by the number of
    /// joined members, with the largest rooms first.
    /// </remarks>
    procedure PublicRooms(APublicRoomsCallback: TProc<TmtrPublicRooms, IHTTPResponse>;
      APublicRoomBuilder: IMandarinBuider); overload;

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
    procedure CreateRoom(const AMandarinBuilder: IMandarinBodyBuider; ARoomCallback: TProc<string, IHTTPResponse>);
    procedure Sync(ASyncBuilder: IMandarinBuider; ARoomCallback: TProc<TmtrSync, IHTTPResponse>);
    constructor Create(const AUrl: string = 'https://matrix-client.matrix.org');
    destructor Destroy; override;
    property IsSyncMode: Boolean read FIsSyncMode write FIsSyncMode;
    property Url: string read FUrl write FUrl;
    property Authenticator: TJwtAuthenticator read FAuthenticator write FAuthenticator;
    property IsPoolingOn: Boolean read FIsPoolingOn write SetIsPoolingOn;
  end;

implementation

uses
  Matrix.Types.Requests,
  System.Net.HttpClient, System.Classes;

const
  API_ENDPOINT_SERVER = '{server}';
  API_ENDPOINT_BASE = API_ENDPOINT_SERVER + '/_matrix/client/';
  API_ENDPOINT_NO_VER = API_ENDPOINT_BASE + '{method}';
  API_ENDPOINT_V_3 = API_ENDPOINT_SERVER + '/_matrix/client/v3/{method}';

constructor TMatrixaPi.Create(const AUrl: string = 'https://matrix-client.matrix.org');
begin
  inherited Create;
  FAuthenticator := TJwtAuthenticator.Create;
  FCli := TMandarinClientJson.Create();
  FCli.Authenticator := FAuthenticator;
  FCli.OnBeforeExcecute := procedure(AMandarin: IMandarin)
    begin
      AMandarin.AddUrlSegment('server', FUrl);
      AMandarin.AddHeader('Content-Type', 'application/json');
    end;
  FUrl := AUrl;
  FIsSyncMode := True;
end;

procedure TMatrixaPi.CreateRoom(const AMandarinBuilder: IMandarinBodyBuider;
  ARoomCallback: TProc<string, IHTTPResponse>);
begin
  FCli.NewMandarin<TmtrRoom>(API_ENDPOINT_V_3) //
    .AddUrlSegment('method', 'createRoom') //
    .SetRequestMethod(sHTTPMethodPost) //
    .SetBodyRaw(AMandarinBuilder.BuildBody) //
    .Execute(
    procedure(ARoom: TmtrRoom; AResponse: IHTTPResponse)
    begin
      if Assigned(ARoomCallback) then
        ARoomCallback(ARoom.RoomId, AResponse);
      ARoom.Free;
    end, FIsSyncMode);
end;

destructor TMatrixaPi.Destroy;
begin
  FAuthenticator := nil;
  FCli.Free;
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

procedure TMatrixaPi.LoginFlows(AFlowsCallback: TProc<TmtrLoginFlows, IHTTPResponse>);
begin
  FCli.NewMandarin<TmtrLoginFlows>(API_ENDPOINT_V_3) //
    .SetRequestMethod(sHTTPMethodGet) //
    .AddUrlSegment('method', 'login') //
    .Execute(AFlowsCallback, FIsSyncMode);
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

procedure TMatrixaPi.PublicRooms(APublicRoomsCallback: TProc<TmtrPublicRooms, IHTTPResponse>;
const ALimit: Integer = 25; const ASince: string = ''; const AServer: string = '');
var
  LMandarin: IMandarin;
begin
  LMandarin := FCli.NewMandarin(API_ENDPOINT_V_3);
  LMandarin.AddUrlSegment('method', 'publicRooms');
  LMandarin.RequestMethod := sHTTPMethodGet;
  if ALimit > 0 then
    LMandarin.AddQueryParameter('limit', ALimit.ToString);
  if not ASince.IsEmpty then
    LMandarin.AddQueryParameter('server', ASince);
  if not AServer.IsEmpty then
    LMandarin.AddQueryParameter('since', AServer);
  FCli.Execute<TmtrPublicRooms>(LMandarin, APublicRoomsCallback, FIsSyncMode);
end;

procedure TMatrixaPi.PublicRooms(APublicRoomsCallback: TProc<TmtrPublicRooms, IHTTPResponse>;
APublicRoomBuilder: IMandarinBuider);
var
  LMandarin: IMandarin;
begin
  LMandarin := APublicRoomBuilder.Build;
  LMandarin.Url := API_ENDPOINT_V_3;
  LMandarin.AddUrlSegment('method', 'publicRooms');
  LMandarin.RequestMethod := 'POST';
  FCli.Execute<TmtrPublicRooms>(LMandarin, APublicRoomsCallback, FIsSyncMode);
end;

procedure TMatrixaPi.RunSync(const ANext: string);
var
  LSyncReq: TmtxSyncRequest;
begin
  LSyncReq := TmtxSyncRequest.Create;

  LSyncReq.SetTimeout(20 * 1000);
  if not ANext.IsEmpty then
  begin
    LSyncReq.SetSince(FNextBatchSync);
  end
  else
    LSyncReq.SetFilter('{"room":{"timeline":{"limit":100,"lazy_load_members":true,"types":' +
      '["m.room.third_party_invite","m.room.redaction","m.room.message","m.room.member",' +
      '"m.room.name","m.room.avatar","m.room.canonical_alias","m.room.join_rules",' +
      '"m.room.power_levels","m.room.topic","m.room.encrypted","m.room.create"]},' +
      '"state":{"lazy_load_members":true,"types":["m.room.member","m.room.name",' +
      '"m.room.avatar","m.room.canonical_alias","m.room.join_rules","m.room.power_levels",' +
      '"m.room.topic","m.room.create"]},"ephemeral":{"lazy_load_members":true,' +
      '"types":["m.receipt"]},"include_leave":true,"account_data":{"limit":0,"types":[]}},' +
      '"account_data":{"types":["m.direct"]},"presence":{"types":["m.presence"]}}');
  try
    Sync(LSyncReq,
      procedure(ASync: TmtrSync; AHttpResp: IHTTPResponse)
      begin
        FNextBatchSync := ASync.NextBatch;
        ASync.Free;
        RunSync(ASync.NextBatch);
      end);

  finally
    // LSyncReq.Free;
  end;

end;

procedure TMatrixaPi.ServerDiscoveryInformation(AWelKnownCallback: TProc<TmtrWelKnown, IHTTPResponse>);
begin
  raise ENotSupportedException.Create('Unsupported method');
  FCli.NewMandarin<TmtrWelKnown>(API_ENDPOINT_SERVER + '/.well-known/matrix/client') //
    .SetRequestMethod(sHTTPMethodGet) //
    .Execute(AWelKnownCallback, FIsSyncMode);
end;

procedure TMatrixaPi.SetIsPoolingOn(const Value: Boolean);
begin
  FIsPoolingOn := Value;
  RunSync(FNextBatchSync);
end;

procedure TMatrixaPi.Start;
begin
  IsPoolingOn := True;
end;

procedure TMatrixaPi.Stop;
begin

end;

procedure TMatrixaPi.Sync(ASyncBuilder: IMandarinBuider; ARoomCallback: TProc<TmtrSync, IHTTPResponse>);
var
  LMandarin: IMandarin;
begin
  LMandarin := ASyncBuilder.Build;
  LMandarin.Url := API_ENDPOINT_V_3;
  LMandarin.AddUrlSegment('method', 'sync');
  LMandarin.RequestMethod := sHTTPMethodGet;
  FCli.Execute<TmtrSync>(LMandarin, ARoomCallback, FIsSyncMode);
end;

end.
