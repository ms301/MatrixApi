unit MatrixaPi.Types.Response;

interface

uses
  Citrus.Json.Converters,
  System.Json.Converters,
  System.Json.Serializers,
  System.Generics.Collections,
  System.Json;

type
  TmtrError = class
  private
    [JsonName('errcode')]
    FErrorCode: string;
    [JsonName('error')]
    FError: string;
    [JsonName('retry_after_ms')]
    FRetryAfterMs: Integer;
  public
    /// <summary>
    /// An error code.
    /// </summary>
    property ErrorCode: string read FErrorCode write FErrorCode;
    /// <summary>
    /// A human-readable error message.
    /// </summary>
    property Error: string read FError write FError;
    /// <summary>
    /// The amount of time in milliseconds the client should wait before trying the
    /// request again.
    /// </summary>
    property RetryAfterMs: Integer read FRetryAfterMs write FRetryAfterMs;
  end;

  TmtrLoginWellKnowItem = class
  private
    [JsonName('base_url')]
    FBaseUrl: string;
  public
    property BaseUrl: string read FBaseUrl write FBaseUrl;
  end;

  TJsonWellKnowConverter = class(TJsonStringDictionaryConverter<TmtrLoginWellKnowItem>);

  TmtrWelKnown = TObjectDictionary<string, TmtrLoginWellKnowItem>;

  TmtrVersions = class(TmtrError)
  private type
    TJsonUnstableFuturesConverter = class(TJsonStringDictionaryConverter<Boolean>);
  private
    [JsonName('unstable_features')]
    [JsonConverter(TJsonUnstableFuturesConverter)]
    FUnstableFutures: TDictionary<string, Boolean>;
    [JsonName('versions')]
    FVersions: TArray<string>;
  public
    constructor Create;
    destructor Destroy; override;
    property UnstableFutures: TDictionary<string, Boolean> read FUnstableFutures;
    property Versions: TArray<string> read FVersions write FVersions;
  end;

  TmtrLogin = class(TmtrError)
  private
    [JsonName('access_token')]
    FAccessToken: string;
    [JsonName('device_id')]
    FDeviceId: string;
    [JsonName('expires_in_ms')]
    FExpiresInMs: Integer;
    [JsonName('home_server')]
    FHomeServer: string;
    [JsonName('refresh_token')]
    FRefreshToken: string;
    [JsonName('user_id')]
    FUserId: string;
    [JsonName('well_known')]
    [JsonConverter(TJsonWellKnowConverter)]
    FWellKnow: TmtrWelKnown;
  public
    constructor Create;
    destructor Destroy; override;
    property AccessToken: string read FAccessToken write FAccessToken;
    property DeviceId: string read FDeviceId write FDeviceId;
    property ExpiresInMs: Integer read FExpiresInMs write FExpiresInMs;
    property HomeServer: string read FHomeServer write FHomeServer;
    property RefreshToken: string read FRefreshToken write FRefreshToken;
    property UserId: string read FUserId write FUserId;
    property WellKnow: TmtrWelKnown read FWellKnow;
  end;




  TmtrPublicRooms = class(TmtrError)
  type
    TRoom = class
    private
      [JsonName('avatar_url')]
      FAvatarUrl: string;
      [JsonName('canonical_alias')]
      FCanonicalAlias: string;
      [JsonName('guest_can_join')]
      FGuestCanJoin: Boolean;
      [JsonName('join_rule')]
      FJoinRule: string;
      [JsonName('name')]
      FName: string;
      [JsonName('num_joined_members')]
      FNumJoinedMembers: Integer;
      [JsonName('room_id')]
      FRoomId: string;
      [JsonName('room_type')]
      FRoomType: string;
      [JsonName('topic')]
      FTopic: string;
      [JsonName('world_readable')]
      FWorldReadable: Boolean;
    public
      /// <summary>
      /// The URL for the room’s avatar, if one is set.
      /// </summary>
      property AvatarUrl: string read FAvatarUrl write FAvatarUrl;
      /// <summary>
      /// The canonical alias of the room, if any.
      /// </summary>
      property CanonicalAlias: string read FCanonicalAlias write FCanonicalAlias;
      /// <summary>
      /// Required: Whether guest users may join the room and participate in it. If they
      /// can, they will be subject to ordinary power level rules like any other user.
      /// </summary>
      property GuestCanJoin: Boolean read FGuestCanJoin write FGuestCanJoin;
      /// <summary>
      /// The room’s join rule. When not present, the room is assumed to be public. Note
      /// that rooms with invite join rules are not expected here, but rooms with knock
      /// rules are given their near-public nature.
      /// </summary>
      property JoinRule: string read FJoinRule write FJoinRule;
      /// <summary>
      /// The name of the room, if any.
      /// </summary>
      property Name: string read FName write FName;
      /// <summary>
      /// Required: The number of members joined to the room.
      /// </summary>
      property NumJoinedMembers: Integer read FNumJoinedMembers write FNumJoinedMembers;
      /// <summary>
      /// Required: The ID of the room.
      /// </summary>
      property RoomId: string read FRoomId write FRoomId;
      /// <summary>
      /// The type of room (from m.room.create), if any.
      /// </summary>
      /// <remarks>
      /// Added in v1.4
      /// </remarks>
      property RoomType: string read FRoomType write FRoomType;
      /// <summary>
      /// The topic of the room, if any.
      /// </summary>
      property Topic: string read FTopic write FTopic;
      /// <summary>
      /// Required: Whether the room may be viewed by guest users without joining.
      /// </summary>
      property WorldReadable: Boolean read FWorldReadable write FWorldReadable;
    end;

    TChunkConverter = class(TJsonListConverter<TmtrPublicRooms.TRoom>);
  private
    [JsonName('next_batch')]
    FNextBatch: string;
    [JsonName('total_room_count_estimate')]
    FTotalRoomCountEstimate: Integer;
    [JsonName('chunk')]
    [JsonConverter(TChunkConverter)]
    FChunk: TObjectList<TmtrPublicRooms.TRoom>;
    [JsonName('prev_batch')]
    FPrevBatch: string;
  public
    constructor Create;
    destructor Destroy; override;
    /// <summary>
    /// A pagination token for the response. The absence of this token means there are
    /// no more results to fetch and the client should stop paginating.
    /// </summary>
    property NextBatch: string read FNextBatch write FNextBatch;
    /// <summary>
    /// A pagination token that allows fetching previous results. The absence of this
    /// token means there are no results before this batch, i.e. this is the first
    /// batch.
    /// </summary>
    property PrevBatch: string read FPrevBatch write FPrevBatch;
    /// <summary>
    /// An estimate on the total number of public rooms, if the server has an estimate.
    /// </summary>
    property TotalRoomCountEstimate: Integer read FTotalRoomCountEstimate write FTotalRoomCountEstimate;
    property Chunk: TObjectList<TmtrPublicRooms.TRoom> read FChunk write FChunk;
  end;

  /// <summary>
  /// Gets the homeserver’s supported login types to authenticate users. Clients
  /// should pick one of these and supply it as the type when logging in.
  /// </summary>
  TmtrLoginFlows = class(TmtrError)
  type
    TIdentityProviders = class
    private
      [JsonName('brand')]
      FBrand: string;
      [JsonName('icon')]
      FIcon: string;
      [JsonName('id')]
      FID: string;
      [JsonName('name')]
      FName: string;
    public
      property Brand: string read FBrand write FBrand;
      property Icon: string read FIcon write FIcon;
      property ID: string read FID write FID;
      property Name: string read FName write FName;
    end;

    TLoginFlow = class
    private
      [JsonName('type')]
      FType: string;
      [JsonName('identity_providers')]
      FIdentityProviders: TArray<TIdentityProviders>;
    public

      constructor Create;
      destructor Destroy; override;
      /// <summary>
      /// The login type. This is supplied as the type when logging in.
      /// </summary>
      property &Type: string read FType write FType;
      property IdentityProviders: TArray<TIdentityProviders> read FIdentityProviders write FIdentityProviders;
    end;
  private
    [JsonName('flows')]
    FFlows: TArray<TLoginFlow>;
  public

    constructor Create;
    destructor Destroy; override;

    /// <summary>
    /// The homeserver’s supported login types
    /// </summary>
    property Flows: TArray<TLoginFlow> read FFlows write FFlows;
  end;

implementation

{ TmtrLogin }
constructor TmtrLogin.Create;
begin
  inherited Create;
  FWellKnow := TmtrWelKnown.Create([doOwnsValues]);
end;

destructor TmtrLogin.Destroy;
begin
  FWellKnow.Free;
  inherited Destroy;
end;

{ TmtrVersions }
constructor TmtrVersions.Create;
begin
  inherited Create;
  FUnstableFutures := TDictionary<string, Boolean>.Create();
end;

destructor TmtrVersions.Destroy;
begin
  FUnstableFutures.Free;
  inherited Destroy;
end;



{ TmtrPublicRooms }
constructor TmtrPublicRooms.Create;
begin
  inherited Create;
  FChunk := TObjectList<TmtrPublicRooms.TRoom>.Create();
end;

destructor TmtrPublicRooms.Destroy;
begin
  FChunk.Free;
  inherited Destroy;
end;

constructor TmtrLoginFlows.Create;
begin
  inherited;
  FFlows := nil;
end;

destructor TmtrLoginFlows.Destroy;
begin
  for var I := Low(FFlows) to High(FFlows) do
    FFlows[I].Free;
  FFlows := nil;
  inherited;
end;

constructor TmtrLoginFlows.TLoginFlow.Create;
begin
  inherited;
  FIdentityProviders := nil;
end;

destructor TmtrLoginFlows.TLoginFlow.Destroy;
begin
  for var I := Low(FIdentityProviders) to High(FIdentityProviders) do
    FIdentityProviders[I].Free;
  FIdentityProviders := nil;
  inherited;
end;

end.
