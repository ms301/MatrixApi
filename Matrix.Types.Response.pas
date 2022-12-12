unit Matrix.Types.Response;

interface

uses
  System.Generics.Collections,
  System.Json.Converters,
  System.Json.Serializers;

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
    FUnstableFutures: TObjectDictionary<string, Boolean>;
    [JsonName('versions')]
    FVersions: TArray<string>;
  public
    property UnstableFutures: TObjectDictionary<string, Boolean> read FUnstableFutures;
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
    property AccessToken: string read FAccessToken write FAccessToken;
    property DeviceId: string read FDeviceId write FDeviceId;
    property ExpiresInMs: Integer read FExpiresInMs write FExpiresInMs;
    property HomeServer: string read FHomeServer write FHomeServer;
    property RefreshToken: string read FRefreshToken write FRefreshToken;
    property UserId: string read FUserId write FUserId;
    property WellKnow: TmtrWelKnown read FWellKnow;
  end;

  TmtrRoom = class
  private
    [JsonName('room_id')]
    FRoomId: string;
  public
    property RoomId: string read FRoomId write FRoomId;
  end;

implementation

end.
