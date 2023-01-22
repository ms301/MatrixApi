unit MatrixaPi.Core.Infrastructure.Dto.Login;

interface

uses
  System.Generics.Collections,
  System.JSON.Serializers,
  System.JSON.Converters;

type
  TmtrLoginWellKnowItem = class
  private
    [JsonName('base_url')]
    FBaseUrl: string;
  public
    property BaseUrl: string read FBaseUrl write FBaseUrl;
  end;

  TmtrWelKnown = TObjectDictionary<string, TmtrLoginWellKnowItem>;
  TJsonWellKnowConverter = class(TJsonStringDictionaryConverter<TmtrLoginWellKnowItem>);

  TmtrLogin = class
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

  /// <summary>
  /// Gets the homeserver’s supported login types to authenticate users. Clients
  /// should pick one of these and supply it as the type when logging in.
  /// </summary>
  TmtrLoginFlows = class
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

  TmtxlIdentifierLoginPassword = class
  private
    [JsonName('type')]
    FType: string;
    [JsonName('user')]
    FUser: string;
  public
    constructor Create(const AUser: string);
    property &Type: string read FType write FType;
    property User: string read FUser write FUser;
  end;

  TmtxlIdentifierLoginEMail = class
  private
    [JsonName('type')]
    FType: string;
    [JsonName('address')]
    FAddress: string;
    [JsonName('medium')]
    FMedium: string;
  public
    constructor Create;
    property &Type: string read FType write FType;
    property Address: string read FAddress write FAddress;
    property Medium: string read FMedium write FMedium;
  end;

  TmtxlIdentifierLoginPhone = class
  private
    [JsonName('type')]
    FType: string;
    [JsonName('country')]
    FCountry: string;
    [JsonName('number')]
    FNumber: string;
    [JsonName('phone')]
    FPhone: string;
  public
    constructor Create;
    property &Type: string read FType write FType;
    property Country: string read FCountry write FCountry;
    property Number: string read FNumber write FNumber;
    property Phone: string read FPhone write FPhone;
  end;

  TmtxLoginRequest<T: class> = class
  private
    [JsonName('initial_device_display_name')]
    FInitialDeviceDisplayName: string;
    [JsonName('identifier')]
    FIdentifier: T;
    [JsonName('password')]
    FPassword: string;
    [JsonName('type')]
    FType: string;
  public
    constructor Create(AIdentifier: T; const APassword: string);
    property Identifier: T read FIdentifier write FIdentifier;
    property InitialDeviceDisplayName: string read FInitialDeviceDisplayName write FInitialDeviceDisplayName;
    property Password: string read FPassword write FPassword;
    property &Type: string read FType write FType;
  end;

implementation

{TmtxLoginRequest<T>}
constructor TmtxLoginRequest<T>.Create(AIdentifier: T; const APassword: string);
begin
  inherited Create;
  FIdentifier := AIdentifier;
  FPassword := APassword;
  FType := 'm.login.password';
  FInitialDeviceDisplayName := 'Matrix for Delphi';
end;

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

{TmtrLoginFlows}
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

{TmtxlIdentifierLoginPassword}
constructor TmtxlIdentifierLoginPassword.Create(const AUser: string);
begin
  inherited Create;
  FType := 'm.id.user';
  FUser := AUser;
end;

{ TmtxlIdentifierLoginEMail }
constructor TmtxlIdentifierLoginEMail.Create;
begin
  FType := 'm.id.thirdparty';
end;

{ TmtxlIdentifierLoginPhone }
constructor TmtxlIdentifierLoginPhone.Create;
begin
  FType := 'm.id.phone';
end;

end.
