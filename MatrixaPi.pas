unit MatrixaPi;

interface

uses
  Citrus.Mandarin,
  Citrus.Authenticator.JWT,
  FMX.Types,
  MatrixaPi.Types.Response,
  System.SysUtils,
  System.Generics.Collections,
  MatrixaPi.Core.Infrastructure.Services,
  MatrixaPi.Core.Domain.Services,
  MatrixaPi.Core.Domain,
  MatrixaPi.Core.Domain.RoomEvent,
  MatrixaPi.Core.Domain.MatrixRoom,
  MatrixaPi.Core.Infrastructure.Dto.Room.Create,
  MatrixaPi.Core.Infrastructure.Dto.Sync,
  MatrixaPi.Core.Infrastructure.Dto.Login;

type
  IHTTPResponse = Citrus.Mandarin.IHTTPResponse;

  IMatrixaPi = interface
    ['{EB9D8D9C-0C22-4A5A-8501-E31B2E160DAF}']
    //private
    function GetUserId: string;
    function GetBaseAddress: string;
    function GetIsLoggedIn: Boolean;
    function GetIsSyncing: Boolean;
    function GetInvitedRooms: TArray<TMatrixRoom>;
    function GetJoinedRooms: TArray<TMatrixRoom>;
    function GetLeftRooms: TArray<TMatrixRoom>;
    function GetOnMatrixRoomEventsReceived: TProc<TList<TBaseRoomEvent>, string>;
    procedure SetOnMatrixRoomEventsReceived(const Value: TProc<TList<TBaseRoomEvent>, string>);
    procedure SetAuthenticator(const Value: TJwtAuthenticator);
    function GetAuthenticator: TJwtAuthenticator;
    procedure SetBaseAddress(const Value: string);
    //public
    /// <summary>
    /// Authenticates the user.
    /// </summary>
    /// <remarks>
    /// Authenticates the user, and issues an access token they can use to authorize
    /// themself in subsequent requests.
    /// </remarks>
    procedure LoginWithPassword(ALoginCallback: TProc<TmtrLogin, IHTTPResponse>;
      const ABaseAddress, AUser, APassword, ADeviceId: string);
    procedure Start(const ANextBatch: string = '');
    procedure Stop;
    /// <summary>
    /// Create a new room
    /// </summary>
    /// <remarks>
    /// Create a new room with various configuration options.
    /// </remarks>
    procedure CreatePublicRoom(ARoomCallback: TProc<TCreateRoomResponse, IHTTPResponse>;
      AMembers: TArray<string> = nil);
    /// <summary> Gets the homeserver’s supported login types to authenticate users.
    /// Clients should pick one of these and supply it as the type when logging in.
    /// </summary>
    procedure LoginFlows(AFlowsCallback: TProc<TmtrLoginFlows, IHTTPResponse>; const ABaseAddress: string);
    /// <summary>
    /// Lists the public rooms on the server, with optional filter.
    /// </summary>
    /// <remarks>
    /// This API returns paginated responses. The rooms are ordered by the number of
    /// joined members, with the largest rooms first.
    /// </remarks>
    procedure PublicRooms(APublicRoomsCallback: TProc<TmtrPublicRooms, IHTTPResponse>;
      APublicRoomBuilder: IMandarinBuider); overload;
    procedure PublicRooms(APublicRoomsCallback: TProc<TmtrPublicRooms, IHTTPResponse>; const ALimit: Integer = 25;
      const ASince: string = ''; const AServer: string = ''); overload;
    procedure Download(ADownloadCallback: TProc<IHTTPResponse>; const AMxcUrl: string);
    property UserId: string read GetUserId;
    property BaseAddress: string read GetBaseAddress write SetBaseAddress;
    property IsLoggedIn: Boolean read GetIsLoggedIn;
    property IsSyncing: Boolean read GetIsSyncing;
    property InvitedRooms: TArray<TMatrixRoom> read GetInvitedRooms;
    property JoinedRooms: TArray<TMatrixRoom> read GetJoinedRooms;
    property LeftRooms: TArray<TMatrixRoom> read GetLeftRooms;
    property OnMatrixRoomEventsReceived: TProc<TList<TBaseRoomEvent>, string> read GetOnMatrixRoomEventsReceived
      write SetOnMatrixRoomEventsReceived;
    property Authenticator: TJwtAuthenticator read GetAuthenticator write SetAuthenticator;
  end;

  TMatrixaPi = class(TInterfacedObject, IMatrixaPi)
  private const
    API_ENDPOINT_BASE = '{server}/_matrix/client/';
    API_ENDPOINT_V_3 = '{server}/_matrix/client/v3/{method}';

  private
    FPollingService: IPollingService;
    FUserService: TUserService;
    FRoomService: TRoomService;
    FEventService: TEventService;
    FModulesService: TModulesService;
    FUserId: string;
    FBaseAddress: string;
    FIsSyncMode: Boolean;
    FAuthenticator: TJwtAuthenticator;
    FIsSyncing: Boolean;
    FIsLogedIn: Boolean;
    FOnMatrixRoomEventsReceived: TProc<TList<TBaseRoomEvent>, string>;
    function GetAuthenticator: TJwtAuthenticator;
    function GetBaseAddress: string;
    function GetUserId: string;
    function GetIsLoggedIn: Boolean;
    function GetIsSyncing: Boolean;
    function GetInvitedRooms: TArray<TMatrixRoom>;
    function GetOnMatrixRoomEventsReceived: TProc<TList<TBaseRoomEvent>, string>;
    procedure SetOnMatrixRoomEventsReceived(const Value: TProc<TList<TBaseRoomEvent>, string>);
    function GetJoinedRooms: TArray<TMatrixRoom>;
    function GetLeftRooms: TArray<TMatrixRoom>;
    procedure SetAuthenticator(const Value: TJwtAuthenticator);
    procedure SetBaseAddress(const Value: string);
  protected
    procedure DoOnSyncBatchReceived(AObject: TObject; ASyncBatchEvent: TSyncBatch);
    procedure DoCheckError(AHttpResp: IHTTPResponse);
  public
    /// <summary>
    /// Authenticates the user.
    /// </summary>
    /// <remarks>
    /// Authenticates the user, and issues an access token they can use to authorize
    /// themself in subsequent requests.
    /// </remarks>
    procedure LoginWithPassword(ALoginCallback: TProc<TmtrLogin, IHTTPResponse>;
      const ABaseAddress, AUser, APassword, ADeviceId: string);
    /// <summary> Gets the homeserver’s supported login types to authenticate users.
    /// Clients should pick one of these and supply it as the type when logging in.
    /// </summary>
    procedure LoginFlows(AFlowsCallback: TProc<TmtrLoginFlows, IHTTPResponse>; const ABaseAddress: string);
    procedure Download(ADownloadCallback: TProc<IHTTPResponse>; const AMxcUrl: string);
    procedure Start(const ANextBatch: string = '');
    procedure Stop;
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
    /// Create a new room
    /// </summary>
    /// <remarks>
    /// Create a new room with various configuration options.
    /// </remarks>
    procedure CreatePublicRoom(ARoomCallback: TProc<TCreateRoomResponse, IHTTPResponse>;
      AMembers: TArray<string> = nil);
    constructor Create(APollingService: IPollingService; AUserService: TUserService; ARoomService: TRoomService;
      AEventService: TEventService; AModulesService: TModulesService);
    destructor Destroy; override;
    property IsSyncMode: Boolean read FIsSyncMode write FIsSyncMode;
    property IsSyncing: Boolean read GetIsSyncing;
    property BaseAddress: string read GetBaseAddress write SetBaseAddress;
    property IsLoggedIn: Boolean read GetIsLoggedIn;
    property Authenticator: TJwtAuthenticator read GetAuthenticator write SetAuthenticator;
    property UserId: string read GetUserId;
    property InvitedRooms: TArray<TMatrixRoom> read GetInvitedRooms;
    property JoinedRooms: TArray<TMatrixRoom> read GetJoinedRooms;
    property LeftRooms: TArray<TMatrixRoom> read GetLeftRooms;
    property OnMatrixRoomEventsReceived: TProc<TList<TBaseRoomEvent>, string> read GetOnMatrixRoomEventsReceived
      write SetOnMatrixRoomEventsReceived;
  end;

  TMatrixClientFactory = class
  private
    FClient: TMatrixaPi;
    FMandarin: TMandarinClientJson;
    //
    FEventService: TEventService;
    FUserService: TUserService;
    FRoomService: TRoomService;
    FPollingService: TPollingService;
    FModulesService: TModulesService;
  public
    constructor Create;
    destructor Destroy; override;
    function CreateASyncClient: IMatrixaPi;
    function CreateSyncClient: IMatrixaPi;
    function GetMandarinClient: TMandarinClientJson;
  end;

implementation

uses
  MatrixaPi.Types.Requests,
  System.Net.HttpClient,
  System.Classes,
  System.Net.URLClient;

constructor TMatrixaPi.Create(APollingService: IPollingService; AUserService: TUserService; ARoomService: TRoomService;
  AEventService: TEventService; AModulesService: TModulesService);
begin
  inherited Create;
  FPollingService := APollingService;
  FUserService := AUserService;
  FRoomService := ARoomService;
  FEventService := AEventService;
  FModulesService := AModulesService;
  FUserService := AUserService;
  FAuthenticator := TJwtAuthenticator.Create;
  FIsSyncMode := True;
end;

procedure TMatrixaPi.CreatePublicRoom(ARoomCallback: TProc<TCreateRoomResponse, IHTTPResponse>;
  AMembers: TArray<string> = nil);
begin
  FRoomService.CreatePublicRoom(ARoomCallback, AMembers);
end;

destructor TMatrixaPi.Destroy;
begin
  FAuthenticator := nil;
  inherited Destroy;
end;

procedure TMatrixaPi.DoCheckError(AHttpResp: IHTTPResponse);
begin
  if AHttpResp.StatusCode = 200 then
    Exit;
end;

procedure TMatrixaPi.Download(ADownloadCallback: TProc<IHTTPResponse>; const AMxcUrl: string);
begin
  FModulesService.Download(ADownloadCallback, AMxcUrl);
end;

function TMatrixaPi.GetBaseAddress: string;
begin
  Result := FBaseAddress;
end;

function TMatrixaPi.GetInvitedRooms: TArray<TMatrixRoom>;
begin
  Result := FPollingService.InvitedRooms;
end;

function TMatrixaPi.GetIsLoggedIn: Boolean;
begin
  Result := FIsLogedIn;
end;

function TMatrixaPi.GetIsSyncing: Boolean;
begin
  Result := FIsSyncing;
end;

function TMatrixaPi.GetJoinedRooms: TArray<TMatrixRoom>;
begin
  Result := FPollingService.JoinedRooms;
end;

function TMatrixaPi.GetLeftRooms: TArray<TMatrixRoom>;
begin
  Result := FPollingService.LeftRooms;
end;

function TMatrixaPi.GetOnMatrixRoomEventsReceived: TProc<TList<TBaseRoomEvent>, string>;
begin
  Result := FOnMatrixRoomEventsReceived;
end;

function TMatrixaPi.GetUserId: string;
begin
  Result := FUserId;
end;

procedure TMatrixaPi.LoginFlows(AFlowsCallback: TProc<TmtrLoginFlows, IHTTPResponse>; const ABaseAddress: string);
begin
  FUserService.LoginFlows(AFlowsCallback, ABaseAddress);
end;

procedure TMatrixaPi.LoginWithPassword(ALoginCallback: TProc<TmtrLogin, IHTTPResponse>;
  const ABaseAddress, AUser, APassword, ADeviceId: string);
begin
  BaseAddress := ABaseAddress;
  FUserService.LoginWithPassword(
    procedure(ALogin: TmtrLogin; AHttpResp: IHTTPResponse)
    begin
      FUserId := ALogin.UserId;
      FAuthenticator.AccessToken := ALogin.AccessToken;
      FPollingService.Init(ABaseAddress, FAuthenticator.AccessToken);
      FIsLogedIn := True;
      ALoginCallback(ALogin, AHttpResp);
    end, AUser, APassword, ADeviceId);
end;

procedure TMatrixaPi.DoOnSyncBatchReceived(AObject: TObject; ASyncBatchEvent: TSyncBatch);
begin
  if not(AObject is TPollingService) then
    raise EArgumentException.Create('sender is not polling service');
  if Assigned(OnMatrixRoomEventsReceived) then
    OnMatrixRoomEventsReceived(ASyncBatchEvent.MatrixRoomEvents, ASyncBatchEvent.NextBatch);
end;

function TMatrixaPi.GetAuthenticator: TJwtAuthenticator;
begin
  Result := FAuthenticator;
end;

procedure TMatrixaPi.PublicRooms(APublicRoomsCallback: TProc<TmtrPublicRooms, IHTTPResponse>;
const ALimit: Integer = 25; const ASince: string = ''; const AServer: string = '');
begin
  FRoomService.PublicRooms(APublicRoomsCallback, ALimit, ASince, AServer);
end;

procedure TMatrixaPi.PublicRooms(APublicRoomsCallback: TProc<TmtrPublicRooms, IHTTPResponse>;
APublicRoomBuilder: IMandarinBuider);
begin
  FRoomService.PublicRooms(APublicRoomsCallback, APublicRoomBuilder);
end;

procedure TMatrixaPi.SetAuthenticator(const Value: TJwtAuthenticator);
begin
  FAuthenticator := Value;
end;

procedure TMatrixaPi.SetBaseAddress(const Value: string);
begin
  FBaseAddress := Value;
  FUserService.BaseAdress := FBaseAddress;
  FRoomService.BaseAdress := FBaseAddress;
  FEventService.BaseAdress := FBaseAddress;
  FModulesService.BaseAdress := FBaseAddress;
end;

procedure TMatrixaPi.SetOnMatrixRoomEventsReceived(const Value: TProc<TList<TBaseRoomEvent>, string>);
begin
  FOnMatrixRoomEventsReceived := Value;
end;

procedure TMatrixaPi.Start(const ANextBatch: string = '');
begin
  if not IsLoggedIn then
    raise Exception.Create('Call LoginWithPassword first');
  FPollingService.OnSyncBatchReceived := DoOnSyncBatchReceived;
  FPollingService.Start(ANextBatch);
  FIsSyncing := FPollingService.IsSyncing;
end;

procedure TMatrixaPi.Stop;
begin
  FPollingService.Stop;
  FPollingService.OnSyncBatchReceived := nil;
  FIsSyncing := FPollingService.IsSyncing;
end;

constructor TMatrixClientFactory.Create;
begin
  inherited Create;
  FMandarin := TMandarinClientJson.Create;
  FMandarin.Http.ConnectionTimeout := 120 * 1000; //120 sec
  FMandarin.OnBeforeExcecute := procedure(AMandarin: IMandarin)
    begin
      AMandarin.AddHeader('Content-Type', 'application/json');
      FMandarin.Authenticator := FClient.Authenticator;
    end;
  FClient := nil;
  FEventService := TEventService.Create(FMandarin);
  FUserService := TUserService.Create(FMandarin);
  FRoomService := TRoomService.Create(FMandarin);
  FPollingService := TPollingService.Create(FEventService);
  FModulesService := TModulesService.Create(FMandarin);
end;

function TMatrixClientFactory.CreateASyncClient: IMatrixaPi;
begin
  if not Assigned(FClient) then
    FClient := TMatrixaPi.Create(FPollingService, FUserService, FRoomService, FEventService, FModulesService);
  FClient.IsSyncMode := False;
  Result := FClient;
end;

function TMatrixClientFactory.CreateSyncClient: IMatrixaPi;
begin
  if not Assigned(FClient) then
    FClient := TMatrixaPi.Create(FPollingService, FUserService, FRoomService, FEventService, FModulesService);
  FClient.IsSyncMode := True;
  Result := FClient;
end;

destructor TMatrixClientFactory.Destroy;
begin
  FEventService.Free;
  FUserService.Free;
  FRoomService.Free;
 // FPollingService.Free;
  FModulesService.Free;
  FMandarin.Free;
  inherited Destroy;
end;

function TMatrixClientFactory.GetMandarinClient: TMandarinClientJson;
begin
  Result := FMandarin;
end;

end.
