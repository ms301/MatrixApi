﻿unit Matrix.Types.Response;

interface

uses
  System.Json.Converters,
  System.Json.Serializers, System.Generics.Collections;

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

  TmtrRoom = class(TmtrError)
  private
    [JsonName('room_id')]
    FRoomId: string;
  public
    property RoomId: string read FRoomId write FRoomId;
  end;

  TmtrSyncAccountData = class

  end;

  TmtrSyncRoomsJoinedRoom = class

  end;

  TmtrSyncRoomsInvitedRoom = class

  end;

  TmtrSyncRoomsKnockedRoom = class

  end;

  TmtrSyncRoomsLeftRoom = class

  end;

  TmtrSyncRooms = class
  private
    [JsonName('join')]
    FJoin: TObjectDictionary<string, TmtrSyncRoomsJoinedRoom>;
    [JsonName('invite')]
    FInvite: TObjectDictionary<string, TmtrSyncRoomsInvitedRoom>;
    [JsonName('knock')]
    FKnock: TObjectDictionary<string, TmtrSyncRoomsKnockedRoom>;
    [JsonName('leave')]
    FLeave: TObjectDictionary<string, TmtrSyncRoomsLeftRoom>;
  public
    constructor Create;
    destructor Destroy; override;
    /// <summary>
    /// The rooms that the user has been invited to, mapped as room ID to room
    /// information.
    /// </summary>
    property Invite: TObjectDictionary<string, TmtrSyncRoomsInvitedRoom> read FInvite write FInvite;
    /// <remarks>
    /// The rooms that the user has joined, mapped as room ID to room information.
    /// </remarks>
    property Join: TObjectDictionary<string, TmtrSyncRoomsJoinedRoom> read FJoin write FJoin;
    /// <summary>
    /// The rooms that the user has knocked upon, mapped as room ID to room information.
    /// </summary>
    property Knock: TObjectDictionary<string, TmtrSyncRoomsKnockedRoom> read FKnock write FKnock;
    /// <summary>
    /// The rooms that the user has left or been banned from, mapped as room ID to room
    /// information.
    /// </summary>
    property Leave: TObjectDictionary<string, TmtrSyncRoomsLeftRoom> read FLeave write FLeave;
  end;

  TmtrSync = class(TmtrError)
  private
    [JsonName('next_batch')]
    FNextBatch: string;
    [JsonName('rooms')]
    FRooms: TmtrSyncRooms;
  public
    constructor Create;
    destructor Destroy; override;
    /// <summary>
    /// Required: The batch token to supply in the since param of the next /sync
    /// request.
    /// </summary>
    property NextBatch: string read FNextBatch write FNextBatch;
    /// <summary>
    /// Updates to rooms.
    /// </summary>
    property Rooms: TmtrSyncRooms read FRooms write FRooms;
  end;

implementation

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

constructor TmtrSync.Create;
begin
  inherited Create;
  FRooms := TmtrSyncRooms.Create();
end;

destructor TmtrSync.Destroy;
begin
  FRooms.Free;
  inherited Destroy;
end;

constructor TmtrSyncRooms.Create;
begin
  inherited Create;
  FJoin := TObjectDictionary<string, TmtrSyncRoomsJoinedRoom>.Create([doOwnsValues]);
  FInvite := TObjectDictionary<string, TmtrSyncRoomsInvitedRoom>.Create([doOwnsValues]);
  FKnock := TObjectDictionary<string, TmtrSyncRoomsKnockedRoom>.Create([doOwnsValues]);
  FLeave := TObjectDictionary<string, TmtrSyncRoomsLeftRoom>.Create([doOwnsValues]);
end;

destructor TmtrSyncRooms.Destroy;
begin
  FLeave.Free;
  FKnock.Free;
  FInvite.Free;
  FJoin.Free;
  inherited Destroy;
end;

end.
