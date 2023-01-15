unit MatrixaPi.Core.Infrastructure.Services;

interface

uses
  Citrus.Mandarin,
  System.SysUtils,
  MatrixaPi.Types.Response,
  MatrixaPi.Core.Infrastructure.Dto.Room.Create,
  MatrixaPi.Core.Infrastructure.Dto.Sync,
  MatrixaPi.Core.Infrastructure.Dto.Room.Join,
  MatrixaPi.Core.Infrastructure.Dto.Room.Joined;

type
  TBaseApiService = class
  private
    FClient: TMandarinClientJson;
    FBaseAdress: string;
    FIsSyncMode: Boolean;
  public
    constructor Create(AClient: TMandarinClientJson); virtual;
    property Client: TMandarinClientJson read FClient write FClient;
    property BaseAdress: string read FBaseAdress write FBaseAdress;
    property IsSyncMode: Boolean read FIsSyncMode write FIsSyncMode;
  end;

  TClientService = class(TBaseApiService)
  private const
    API_ENDPOINT_BASE = '{server}/_matrix/client/{method}';
  public
    procedure GetMatrixClientVersions(AVersionsCallback: TProc<TmtrVersions, IHTTPResponse>);
    constructor Create(AClient: TMandarinClientJson); override;
  end;

  TUserService = class(TBaseApiService)
  private const
    API_ENDPOINT_V_3 = '{server}/_matrix/client/v3/{method}';
  public
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
    procedure LoginWithPassword(ALoginCallback: TProc<TmtrLogin, IHTTPResponse>;
      const AUser, APassword, ADeviceId: string);
    /// <summary> Gets the homeserver’s supported login types to authenticate users.
    /// Clients should pick one of these and supply it as the type when logging in.
    /// </summary>
    procedure LoginFlows(AFlowsCallback: TProc<TmtrLoginFlows, IHTTPResponse>);
  end;

  TEventService = class(TBaseApiService)
  private const
    API_ENDPOINT_V_3 = '{server}/_matrix/client/v3/{method}';
  public
    procedure Sync(ARoomCallback: TProc<TSyncResponse, IHTTPResponse>; ATimeOut: UInt64; const ANextBath: string = '');
  end;

  TRoomService = class(TBaseApiService)
  private const
    API_ENDPOINT_V_3 = '{server}/_matrix/client/v3/{method}';
  public
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
    procedure CreatePublicRoom(ACreateRoomCallback: TProc<TCreateRoomResponse, IHTTPResponse>;
      AMembers: TArray<string> = nil);
    procedure JoinRoom(AJoinRoomCallback: TProc<TJoinRoomResponse, IHTTPResponse>; const ARoomId: string);
    procedure GetJoinedRooms(AJoinedRoomsCallback: TProc<TJoinedRoomsResponse, IHTTPResponse>; const ARoomId: string);
    procedure LeaveRoom(ALeaveRoomCallback: TProc<IHTTPResponse>; const ARoomId: string);
  end;

  TModulesService = class(TBaseApiService)
  private const
    API_ENDPOINT_V_3_MEDIA = '{server}/_matrix/media/v3/{method}';
  public
    procedure Download(ADownloadCallback: TProc<IHTTPResponse>; const AMxcUrl: string);
  end;

implementation

uses
  System.Net.HttpClient,
  MatrixaPi.Types.Requests,
  System.Net.URLClient;

{TClientService}
constructor TBaseApiService.Create(AClient: TMandarinClientJson);
begin
  inherited Create();
  FClient := AClient;
end;

constructor TClientService.Create(AClient: TMandarinClientJson);
begin
  inherited Create(AClient);
end;

procedure TClientService.GetMatrixClientVersions(AVersionsCallback: TProc<TmtrVersions, IHTTPResponse>);
begin
  FClient.NewMandarin<TmtrVersions>(API_ENDPOINT_BASE) //
    .AddUrlSegment('server', BaseAdress) //
    .AddUrlSegment('method', 'versions') //
    .SetRequestMethod(sHTTPMethodGet) //
    .Execute(AVersionsCallback, FIsSyncMode);
end;

{TUserService}
procedure TUserService.Login<T>(ALoginCallback: TProc<TmtrLogin, IHTTPResponse>; ALoginData: T);
begin
  FClient.NewMandarin<TmtrLogin>(API_ENDPOINT_V_3) //
    .AddUrlSegment('server', BaseAdress) //
    .AddUrlSegment('method', 'login') //
    .SetRequestMethod(sHTTPMethodPost) //
    .SetBody(ALoginData) //
    .Execute(ALoginCallback, FIsSyncMode);
end;

procedure TUserService.LoginFlows(AFlowsCallback: TProc<TmtrLoginFlows, IHTTPResponse>);
begin
  FClient.NewMandarin<TmtrLoginFlows>(API_ENDPOINT_V_3) //
    .SetRequestMethod(sHTTPMethodGet) //
    .AddUrlSegment('server', BaseAdress) //
    .AddUrlSegment('method', 'login') //
    .Execute(AFlowsCallback, FIsSyncMode);
end;

procedure TUserService.LoginWithPassword(ALoginCallback: TProc<TmtrLogin, IHTTPResponse>;
  const AUser, APassword, ADeviceId: string);
var
  LIdent: TmtxlIdentifierLoginPassword;
  LLogin: TmtxLoginRequest<TmtxlIdentifierLoginPassword>;
begin
  LIdent := TmtxlIdentifierLoginPassword.Create(AUser);
  LLogin := TmtxLoginRequest<TmtxlIdentifierLoginPassword>.Create(LIdent, APassword);
  try
    LLogin.InitialDeviceDisplayName := ADeviceId;
    Login < TmtxLoginRequest < TmtxlIdentifierLoginPassword >> (ALoginCallback, LLogin);
  finally
    LIdent.Free;
    LLogin.Free;
  end;
end;

procedure TEventService.Sync(ARoomCallback: TProc<TSyncResponse, IHTTPResponse>; ATimeOut: UInt64;
  const ANextBath: string = '');
var
  LMandarin: IMandarin;
begin
  LMandarin := FClient.NewMandarin(API_ENDPOINT_V_3);
  if ATimeOut > -1 then
    LMandarin.AddQueryParameter('timeout', ATimeOut.ToString);
  if not ANextBath.IsEmpty then
    LMandarin.AddQueryParameter('since', ANextBath);
  LMandarin.AddUrlSegment('server', BaseAdress);
  LMandarin.AddUrlSegment('method', 'sync');
  LMandarin.RequestMethod := sHTTPMethodGet;
  FClient.Execute<TSyncResponse>(LMandarin, ARoomCallback, FIsSyncMode);
end;

procedure TRoomService.CreatePublicRoom(ACreateRoomCallback: TProc<TCreateRoomResponse, IHTTPResponse>;
  AMembers: TArray<string> = nil);
var
  LModel: TCreateRoomRequest;
begin
  LModel := TCreateRoomRequest.Create;
  try
    if Assigned(AMembers) then
      LModel.SetMembers(AMembers);
    LModel.SetPreset(TCreateRoomRequest.TPreset.PublicChat);
    //LModel.SetIsDirect(True);
    FClient.NewMandarin<TCreateRoomResponse>(API_ENDPOINT_V_3) //
      .AddUrlSegment('server', BaseAdress)//
      .AddUrlSegment('method', 'CreatePublicRoom') //
      .SetRequestMethod(sHTTPMethodPost) //
      .SetBodyRaw(LModel.BuildBody) //
      .Execute(ACreateRoomCallback, FIsSyncMode);
  finally
    LModel.Free;
  end;
end;

procedure TRoomService.GetJoinedRooms(AJoinedRoomsCallback: TProc<TJoinedRoomsResponse, IHTTPResponse>;
  const ARoomId: string);
begin
  FClient.NewMandarin<TJoinedRoomsResponse>(API_ENDPOINT_V_3) //
    .AddUrlSegment('server', BaseAdress)//
    .AddUrlSegment('method', 'joined_rooms') //
    .SetRequestMethod(sHTTPMethodPost) //
    .Execute(AJoinedRoomsCallback, FIsSyncMode);
end;

procedure TRoomService.JoinRoom(AJoinRoomCallback: TProc<TJoinRoomResponse, IHTTPResponse>; const ARoomId: string);
begin
  FClient.NewMandarin<TJoinRoomResponse>(API_ENDPOINT_V_3 + '/{roomId}/join') //
    .AddUrlSegment('server', BaseAdress)//
    .AddUrlSegment('method', 'rooms') //
    .AddUrlSegment('roomId', ARoomId) //
    .SetRequestMethod(sHTTPMethodPost) //
    .Execute(AJoinRoomCallback, FIsSyncMode);
end;

procedure TRoomService.LeaveRoom(ALeaveRoomCallback: TProc<IHTTPResponse>; const ARoomId: string);
begin
  FClient.NewMandarin(API_ENDPOINT_V_3 + '/{roomId}/leave') //
    .AddUrlSegment('server', BaseAdress)//
    .AddUrlSegment('method', 'rooms') //
    .AddUrlSegment('roomId', ARoomId) //
    .SetRequestMethod(sHTTPMethodPost) //
    .Execute(ALeaveRoomCallback, FIsSyncMode);
end;

procedure TRoomService.PublicRooms(APublicRoomsCallback: TProc<TmtrPublicRooms, IHTTPResponse>;
  APublicRoomBuilder: IMandarinBuider);
var
  LMandarin: IMandarin;
begin
  LMandarin := APublicRoomBuilder.Build;
  LMandarin.Url := API_ENDPOINT_V_3;
  LMandarin.AddUrlSegment('method', 'publicRooms');
  LMandarin.RequestMethod := 'POST';
  FClient.Execute<TmtrPublicRooms>(LMandarin, APublicRoomsCallback, FIsSyncMode);
end;

procedure TRoomService.PublicRooms(APublicRoomsCallback: TProc<TmtrPublicRooms, IHTTPResponse>; const ALimit: Integer;
  const ASince, AServer: string);
var
  LMandarin: IMandarin;
begin
  LMandarin := FClient.NewMandarin(API_ENDPOINT_V_3);
  LMandarin.AddUrlSegment('method', 'publicRooms');
  LMandarin.RequestMethod := sHTTPMethodGet;
  if ALimit > 0 then
    LMandarin.AddQueryParameter('limit', ALimit.ToString);
  if not ASince.IsEmpty then
    LMandarin.AddQueryParameter('server', ASince);
  if not AServer.IsEmpty then
    LMandarin.AddQueryParameter('since', AServer);
  FClient.Execute<TmtrPublicRooms>(LMandarin, APublicRoomsCallback, FIsSyncMode);
end;

procedure TModulesService.Download(ADownloadCallback: TProc<IHTTPResponse>; const AMxcUrl: string);
var
  LMxcUrl: TURI;
begin
  LMxcUrl := TURI.Create(AMxcUrl);
  FClient.NewMandarin(API_ENDPOINT_V_3_MEDIA + '/{serverName}/{mediaId}') //
    .AddUrlSegment('method', 'download')//
    .AddUrlSegment('serverName', LMxcUrl.Host)//
    .AddUrlSegment('mediaId', LMxcUrl.Path.Substring(1))//
    .SetRequestMethod(sHTTPMethodGet)//
    .Execute(ADownloadCallback, FIsSyncMode);
end;

end.
