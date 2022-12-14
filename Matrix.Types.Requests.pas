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

  TmtxCreateRoomRequest = class
  private type
    TVisibility = (public, private);
    TPreset = (PrivateChat, PublicChat, TrustedPrivateChat);
  private
    [JsonName('invite')]
    FMembers: TArray<string>;
    [JsonName('visibility')]
    FVisibility: TVisibility;
    [JsonName('room_alias_name')]
    FRoomAliasName: string;
    [JsonName('name')]
    FName: string;
    [JsonName('is_direct')]
    FIsDirect: Boolean;
    [JsonName('preset')]
    FPreset: TPreset;
    [JsonName('room_version')]
    FRoomVersion: string;
    [JsonName('topic')]
    FTopic: string;
  public
    property Members: TArray<string> read FMembers write FMembers;
    /// <remarks>
    /// If this is included, an m.room.name event will be sent into the room to
    /// indicate the name of the room. See Room Events for more information on m.room.
    /// name.
    /// </remarks>
    property Name: string read FName write FName;
    property Preset: TPreset read FPreset write FPreset;
    /// <remarks>
    /// This flag makes the server set the is_direct flag on the m.room.member events
    /// sent to the users in invite and invite_3pid. See Direct Messaging for more
    /// information.
    /// </remarks>
    property IsDirect: Boolean read FIsDirect write FIsDirect;
    /// <remarks>
    /// The desired room alias local part. If this is included, a room alias will be
    /// created and mapped to the newly created room. The alias will belong on the same
    /// homeserver which created the room. For example, if this was set to "foo" and
    /// sent to the homeserver "example.com" the complete room alias would be #foo:
    /// example.com.
    /// The complete room alias will become the canonical alias for the room and an m.
    /// room.canonical_alias event will be sent into the room.
    /// </remarks>
    property RoomAliasName: string read FRoomAliasName write FRoomAliasName;
    /// <remarks>
    /// The room version to set for the room. If not provided, the homeserver is to use
    /// its configured
    /// </remarks>
    property RoomVersion: string read FRoomVersion write FRoomVersion;
    /// <remarks>
    /// If this is included, an m.room.topic event will be sent into the room to
    /// indicate the topic for the room. See Room Events for more information on m.room.
    /// topic.
    /// </remarks>
    property Topic: string read FTopic write FTopic;
    property Visibility: TVisibility read FVisibility write FVisibility;
  end;

implementation

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

end.
