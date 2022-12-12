unit Matrix.Types.Requests;

interface

uses
  System.Json.Serializers;

type
  TmtxLoginRequest = class
  private type
    TmtxlIdentifier = class
    private
      [JsonName('type')]
      FType: string;
      [JsonName('user')]
      FUser: string;
    public
      constructor Create(const AType, AUser: string);
      property &Type: string read FType write FType;
      property User: string read FUser write FUser;
    end;
  private
    [JsonName('initial_device_display_name')]
    FInitialDeviceDisplayName: string;
    [JsonName('identifier')]
    FIdentifier: TmtxlIdentifier;
    [JsonName('password')]
    FPassword: string;
    [JsonName('type')]
    FType: string;
  public
    constructor Create(const AUser, APassword: string);
    destructor Destroy; override;
    property Identifier: TmtxlIdentifier read FIdentifier write FIdentifier;
    property InitialDeviceDisplayName: string read FInitialDeviceDisplayName write FInitialDeviceDisplayName;
    property Password: string read FPassword write FPassword;
    property &Type: string read FType write FType;
  end;

implementation

constructor TmtxLoginRequest.TmtxlIdentifier.Create(const AType, AUser: string);
begin
  inherited Create;
  FType := AType;
  FUser := AUser;
end;

constructor TmtxLoginRequest.Create(const AUser, APassword: string);
begin
  inherited Create;
  FIdentifier := TmtxlIdentifier.Create('m.id.user', AUser);
  FPassword := APassword;
  FType := 'm.login.password';
end;

destructor TmtxLoginRequest.Destroy;
begin
  FIdentifier.Free;
  inherited Destroy;
end;

end.
