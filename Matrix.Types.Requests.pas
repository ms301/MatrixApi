unit Matrix.Types.Requests;

interface

uses
  System.JSON,
  System.JSON.Serializers;

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

  TmtxCreateRoomRequest = class
  private type
{$SCOPEDENUMS ON}
    TVisibility = (public, private);
    TPreset = (PrivateChat, PublicChat, TrustedPrivateChat);
{$SCOPEDENUMS OFF}
  private
    FJson: TJSONObject;
  public
    constructor Create;
    destructor Destroy; override;
    function JsonAsString: string;
    function SetMembers(AMembers: TArray<string>): TmtxCreateRoomRequest;
    /// <remarks>
    /// If this is included, an m.room.name event will be sent into the room to
    /// indicate the name of the room. See Room Events for more information on m.room.
    /// name.
    /// </remarks>
    function SetName(const AName: string): TmtxCreateRoomRequest;
    function SetPreset(const APreset: TPreset): TmtxCreateRoomRequest;
    /// <remarks>
    /// This flag makes the server set the is_direct flag on the m.room.member events
    /// sent to the users in invite and invite_3pid. See Direct Messaging for more
    /// information.
    /// </remarks>
    function SetIsDirect(const AIsDirect: Boolean): TmtxCreateRoomRequest;
    /// <remarks>
    /// The desired room alias local part. If this is included, a room alias will be
    /// created and mapped to the newly created room. The alias will belong on the same
    /// homeserver which created the room. For example, if this was set to "foo" and
    /// sent to the homeserver "example.com" the complete room alias would be #foo:
    /// example.com.
    /// The complete room alias will become the canonical alias for the room and an m.
    /// room.canonical_alias event will be sent into the room.
    /// </remarks>
    function SetRoomAliasName(const ARoomAliasName: string): TmtxCreateRoomRequest;
    /// <remarks>
    /// The room version to set for the room. If not provided, the homeserver is to use
    /// its configured
    /// </remarks>
    function SetRoomVersion(const ARoomVersion: string): TmtxCreateRoomRequest;
    function SetTopic(const ATopic: string): TmtxCreateRoomRequest;
    function SetVisibility(const AVisibility: TVisibility): TmtxCreateRoomRequest;
  end;

implementation

uses
  System.SysUtils;

constructor TmtxLoginRequest.TmtxlIdentifier.Create(

  const AType, AUser: string);
begin
  inherited Create;
  FType := AType;
  FUser := AUser;
end;

constructor TmtxLoginRequest.Create(

  const AUser, APassword: string);
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

constructor TmtxCreateRoomRequest.Create;
begin
  inherited Create;
  FJson := TJSONObject.Create();
end;

destructor TmtxCreateRoomRequest.Destroy;
begin
  FJson.Free;
  inherited Destroy;
end;

function TmtxCreateRoomRequest.JsonAsString: string;
begin
  Result := FJson.ToJSON;
end;

function TmtxCreateRoomRequest.SetIsDirect(const AIsDirect: Boolean): TmtxCreateRoomRequest;
begin
  FJson.AddPair('is_direct', TJSONBool.Create(AIsDirect));
  Result := Self;
end;

function TmtxCreateRoomRequest.SetMembers(AMembers: TArray<string>): TmtxCreateRoomRequest;
begin
  FJson.AddPair('invite', '[' + string.Join(',', AMembers) + ']');
  Result := Self;
end;

function TmtxCreateRoomRequest.SetName(const AName: string): TmtxCreateRoomRequest;
begin
  FJson.AddPair('name', AName);
  Result := Self;
end;

function TmtxCreateRoomRequest.SetPreset(const APreset: TPreset): TmtxCreateRoomRequest;
var
  lPreset: string;
begin
  case APreset of
    TPreset.PrivateChat:
      lPreset := 'private_chat';
    TPreset.PublicChat:
      lPreset := 'public_chat';
    TPreset.TrustedPrivateChat:
      lPreset := 'trusted_private_chat';
  end;
  FJson.AddPair('preset', lPreset);
  Result := Self;
end;

function TmtxCreateRoomRequest.SetRoomAliasName(const ARoomAliasName: string): TmtxCreateRoomRequest;
begin
  FJson.AddPair('room_alias_name', ARoomAliasName);
  Result := Self;
end;

function TmtxCreateRoomRequest.SetRoomVersion(const ARoomVersion: string): TmtxCreateRoomRequest;
begin
  FJson.AddPair('room_version', ARoomVersion);
  Result := Self;
end;

function TmtxCreateRoomRequest.SetTopic(const ATopic: string): TmtxCreateRoomRequest;
begin
  FJson.AddPair('topic', ATopic);
  Result := Self;
end;

function TmtxCreateRoomRequest.SetVisibility(const AVisibility: TVisibility): TmtxCreateRoomRequest;
var
  LVisibility: string;
begin
  case AVisibility of
    TVisibility.public:
      LVisibility := 'public';
    TVisibility.private:
      LVisibility := 'private';
  end;
  FJson.AddPair('visibility', LVisibility);
  Result := Self;
end;

end.
