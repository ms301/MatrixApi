unit Matrix.Client;

interface

uses
  Citrus.Mandarin,
  Citrus.Authenticator.JWT,
  FMX.Types,
  Matrix.Types,
  Matrix.Types.Response,
  System.SysUtils,
  System.Generics.Collections;

type
  IHTTPResponse = Citrus.Mandarin.IHTTPResponse;

  IMatrixaPI = interface
    ['{EB9D8D9C-0C22-4A5A-8501-E31B2E160DAF}']
    //private
    function GetUserId: string;
    function GetBaseAddress: string;
    function GetIsLoggedIn: Boolean;
    function GetIsSyncing: Boolean;
    function GetInvitedRooms: TObjectList<TMatrixRoom>;
    //public
    property UserId: string read GetUserId;
    property BaseAddress: string read GetBaseAddress;
    property IsLoggedIn: Boolean read GetIsLoggedIn;
    property IsSyncing: Boolean read GetIsSyncing;
    property InvitedRooms: TObjectList<TMatrixRoom> read GetInvitedRooms;
  end;

  TMatrixaPi = class(TInterfacedObject, IMatrixaPI)
  private const
    API_ENDPOINT_SERVER = '{server}';
    API_ENDPOINT_BASE = API_ENDPOINT_SERVER + '/_matrix/client/';
    API_ENDPOINT_NO_VER = API_ENDPOINT_BASE + '{method}';
    API_ENDPOINT_V_3 = API_ENDPOINT_SERVER + '/_matrix/client/v3/{method}';
    API_ENDPOINT_V_3_MEDIA = API_ENDPOINT_SERVER + '/_matrix/media/v3/{method}';
  private
    FCli: TMandarinClientJson;
    FUserId: string;
    FBaseAddress: string;
    FIsSyncMode: Boolean;
    FAuthenticator: TJwtAuthenticator;
    FInvitedRooms: TObjectList<TMatrixRoom>;
    FNextBatchSync: string;
    FIsPoolingOn: Boolean;
    FIsSyncing: Boolean;
    function GetBaseAddress: string;
    procedure SetIsPoolingOn(const Value: Boolean);
    function GetUserId: string;
    function GetIsLoggedIn: Boolean;
    function GetIsSyncing: Boolean;
    function GetInvitedRooms: TObjectList<TMatrixRoom>;
  protected
    procedure DoCheckError(AHttpResp: IHTTPResponse);
    procedure RunSync(const ANext: string);
  public
    /// <summary> Gets the homeserver’s supported login types to authenticate users.
    /// Clients should pick one of these and supply it as the type when logging in.
    /// </summary>
    procedure LoginFlows(AFlowsCallback: TProc<TmtrLoginFlows, IHTTPResponse>);
    /// <summary>
    /// Authenticates the user.
    /// </summary>
    /// <remarks>
    /// Authenticates the user, and issues an access token they can use to authorize
    /// themself in subsequent requests.
    /// </remarks>
    procedure Login<T: class>(ALoginCallback: TProc<TmtrLogin, IHTTPResponse>; ALoginData: T);

    /// <summary>
    /// Authenticates the user.
    /// </summary>
    /// <remarks>
    /// Authenticates the user, and issues an access token they can use to authorize
    /// themself in subsequent requests.
    /// </remarks>
    procedure LoginWithPassword(ALoginCallback: TProc<TmtrLogin, IHTTPResponse>; const AUser, APassword: string);
    procedure Download(ADownloadCallback: TProc<IHTTPResponse>; const AMxcUrl: string);
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
    property IsSyncing: Boolean read GetIsSyncing;
    property BaseAddress: string read GetBaseAddress write FBaseAddress;
    property IsLoggedIn: Boolean read GetIsLoggedIn;
    property Authenticator: TJwtAuthenticator read FAuthenticator write FAuthenticator;
    property UserId: string read GetUserId;
    property IsPoolingOn: Boolean read FIsPoolingOn write SetIsPoolingOn;
    property InvitedRooms: TObjectList<TMatrixRoom> read GetInvitedRooms;
  end;

implementation

uses
  Matrix.Types.Requests,
  System.Net.HttpClient, System.Classes, System.Net.URLClient;

constructor TMatrixaPi.Create(const AUrl: string = 'https://matrix-client.matrix.org');
begin
  inherited Create;
  FAuthenticator := TJwtAuthenticator.Create;
  FCli := TMandarinClientJson.Create();
  FCli.Authenticator := FAuthenticator;
  FCli.OnBeforeExcecute := procedure(AMandarin: IMandarin)
    begin
      AMandarin.AddUrlSegment('server', FBaseAddress);
      AMandarin.AddHeader('Content-Type', 'application/json');
    end;
  FBaseAddress := AUrl;
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

procedure TMatrixaPi.Download(ADownloadCallback: TProc<IHTTPResponse>; const AMxcUrl: string);
var
  LMxcUrl: TURI;
begin
  LMxcUrl := TURI.Create(AMxcUrl);
  FCli.NewMandarin(API_ENDPOINT_V_3_MEDIA + '/{serverName}/{mediaId}') //
    .AddUrlSegment('method', 'download')//
    .AddUrlSegment('serverName', LMxcUrl.Host)//
    .AddUrlSegment('mediaId', LMxcUrl.Path.Substring(1))//
    .SetRequestMethod(sHTTPMethodGet)//
    .Execute(ADownloadCallback, FIsSyncMode);
end;

function TMatrixaPi.GetBaseAddress: string;
begin
  Result := FBaseAddress;
end;

function TMatrixaPi.GetInvitedRooms: TObjectList<TMatrixRoom>;
begin
  Result := FInvitedRooms;
end;

function TMatrixaPi.GetIsLoggedIn: Boolean;
begin
  Result := not FUserId.IsEmpty;
end;

function TMatrixaPi.GetIsSyncing: Boolean;
begin
  Result := FIsSyncing;
end;

function TMatrixaPi.GetUserId: string;
begin
  Result := FUserId;
end;

procedure TMatrixaPi.Login<T>(ALoginCallback: TProc<TmtrLogin, IHTTPResponse>; ALoginData: T);
begin
  FCli.NewMandarin<TmtrLogin>(API_ENDPOINT_V_3) //
    .SetRequestMethod(sHTTPMethodPost) //
    .AddUrlSegment('method', 'login') //
    .SetBody(ALoginData) //
    .Execute(
    procedure(ALogin: TmtrLogin; AHttpResp: IHTTPResponse)
    begin
      FUserId := ALogin.UserId;
      ALoginCallback(ALogin, AHttpResp);
    end, FIsSyncMode);
end;

procedure TMatrixaPi.LoginFlows(AFlowsCallback: TProc<TmtrLoginFlows, IHTTPResponse>);
begin
  FCli.NewMandarin<TmtrLoginFlows>(API_ENDPOINT_V_3) //
    .SetRequestMethod(sHTTPMethodGet) //
    .AddUrlSegment('method', 'login') //
    .Execute(AFlowsCallback, FIsSyncMode);
end;

procedure TMatrixaPi.LoginWithPassword(ALoginCallback: TProc<TmtrLogin, IHTTPResponse>; const AUser, APassword: string);
var
  LIdent: TmtxlIdentifierLoginPassword;
  LLogin: TmtxLoginRequest<TmtxlIdentifierLoginPassword>;
begin
  LIdent := TmtxlIdentifierLoginPassword.Create(AUser);
  LLogin := TmtxLoginRequest<TmtxlIdentifierLoginPassword>.Create(LIdent, APassword);
  try
    LLogin.InitialDeviceDisplayName := 'Matrix for Delphi';
    Login < TmtxLoginRequest < TmtxlIdentifierLoginPassword >> (ALoginCallback, LLogin);
  finally
    LIdent.Free;
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
        var
        x := ASync.Rooms.Join.ToArray[0].Value.TimeLine.Events.First;
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
  FCli.Execute<TmtrSync>(LMandarin,
    procedure(ASync: TmtrSync; AHttpResp: IHTTPResponse)
    begin
      ARoomCallback(ASync, AHttpResp);

    end, FIsSyncMode);
end;

end.
