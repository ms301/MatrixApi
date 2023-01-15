unit MatrixaPi.Core.Infrastructure.Dto.Room.Create;

interface

uses
  Citrus.Mandarin,
  System.JSON,
  System.JSON.Serializers;

type
  TCreateRoomResponse = class
  private
    [JsonName('room_id')]
    FRoomId: string;
  public
    property RoomId: string read FRoomId write FRoomId;
  end;

  TCreateRoomRequest = class(TInterfacedObject, IMandarinBodyBuider)
  public type
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
    function SetMembers(AMembers: TArray<string>): TCreateRoomRequest;
    /// <remarks>
    /// If this is included, an m.room.name event will be sent into the room to
    /// indicate the name of the room. See Room Events for more information on m.room.
    /// name.
    /// </remarks>
    function SetName(const AName: string): TCreateRoomRequest;
    function SetPreset(const APreset: TPreset): TCreateRoomRequest;
    /// <remarks>
    /// This flag makes the server set the is_direct flag on the m.room.member events
    /// sent to the users in invite and invite_3pid. See Direct Messaging for more
    /// information.
    /// </remarks>
    function SetIsDirect(const AIsDirect: Boolean): TCreateRoomRequest;
    /// <remarks>
    /// The desired room alias local part. If this is included, a room alias will be
    /// created and mapped to the newly created room. The alias will belong on the same
    /// homeserver which created the room. For example, if this was set to "foo" and
    /// sent to the homeserver "example.com" the complete room alias would be #foo:
    /// example.com.
    /// The complete room alias will become the canonical alias for the room and an m.
    /// room.canonical_alias event will be sent into the room.
    /// </remarks>
    function SetRoomAliasName(const ARoomAliasName: string): TCreateRoomRequest;
    /// <remarks>
    /// The room version to set for the room. If not provided, the homeserver is to use
    /// its configured
    /// </remarks>
    function SetRoomVersion(const ARoomVersion: string): TCreateRoomRequest;
    function SetTopic(const ATopic: string): TCreateRoomRequest;
    function SetVisibility(const AVisibility: TVisibility): TCreateRoomRequest;
    function BuildBody: string;
  end;

implementation

uses
  System.SysUtils;

{TCreateRoomRequest}
function TCreateRoomRequest.BuildBody: string;
begin
  Result := FJson.ToJSON;
end;

constructor TCreateRoomRequest.Create;
begin
  inherited Create;
  FJson := TJSONObject.Create();
end;

destructor TCreateRoomRequest.Destroy;
begin
  FJson.Free;
  inherited Destroy;
end;

function TCreateRoomRequest.JsonAsString: string;
begin
  Result := FJson.ToJSON;
end;

function TCreateRoomRequest.SetIsDirect(const AIsDirect: Boolean): TCreateRoomRequest;
begin
  FJson.AddPair('is_direct', TJSONBool.Create(AIsDirect));
  Result := Self;
end;

function TCreateRoomRequest.SetMembers(AMembers: TArray<string>): TCreateRoomRequest;
begin
  FJson.AddPair('invite', '[' + string.Join(',', AMembers) + ']');
  Result := Self;
end;

function TCreateRoomRequest.SetName(const AName: string): TCreateRoomRequest;
begin
  FJson.AddPair('name', AName);
  Result := Self;
end;

function TCreateRoomRequest.SetPreset(const APreset: TPreset): TCreateRoomRequest;
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

function TCreateRoomRequest.SetRoomAliasName(const ARoomAliasName: string): TCreateRoomRequest;
begin
  FJson.AddPair('room_alias_name', ARoomAliasName);
  Result := Self;
end;

function TCreateRoomRequest.SetRoomVersion(const ARoomVersion: string): TCreateRoomRequest;
begin
  FJson.AddPair('room_version', ARoomVersion);
  Result := Self;
end;

function TCreateRoomRequest.SetTopic(const ATopic: string): TCreateRoomRequest;
begin
  FJson.AddPair('topic', ATopic);
  Result := Self;
end;

function TCreateRoomRequest.SetVisibility(const AVisibility: TVisibility): TCreateRoomRequest;
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
