unit MatrixaPi.RoomEvent.RoomMemberContent;

interface

uses
  System.JSON.Converters,
  System.JSON.Serializers;

type

  TUserMembershipState = (Invite, Join, Knock, Leave, Ban);

  /// <remarks>
  ///     m.room.member
  /// </remarks>
  TRoomMemberContent = class
  private
    [JsonName('avatar_url')]
    FAvatarUrl: string;
    [JsonName('displayname')]
    FDisplayname: string;
    [JsonName('is_direct')]
    FIsDirect: Boolean;
    [JsonName('join_authorised_via_users_server')]
    FJoinAuthorisedViaUsersServer: string;
    [JsonName('membership')]
    [JsonConverter(TJsonEnumNameConverter)]
    FMembership: TUserMembershipState;
    [JsonName('reason')]
    FReason: string;
  public
    property AvatarUrl: string read FAvatarUrl write FAvatarUrl;
    property Displayname: string read FDisplayname write FDisplayname;
    property IsDirect: Boolean read FIsDirect write FIsDirect;
    property JoinAuthorisedViaUsersServer: string read FJoinAuthorisedViaUsersServer
      write FJoinAuthorisedViaUsersServer;
    property Membership: TUserMembershipState read FMembership write FMembership;
    property Reason: string read FReason write FReason;
  end;

implementation

end.
