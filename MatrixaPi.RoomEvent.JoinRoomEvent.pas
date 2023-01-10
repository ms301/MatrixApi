unit MatrixaPi.RoomEvent.JoinRoomEvent;

interface

uses
  Matrix.RoomEvent.BaseRoomEvent,
  Matrix.Types.Response;

type
  TJoinRoomEvent = class(TBaseRoomEvent)
  public type
    Factory = class
      class function TryCreateFrom(ARoomEvent: TmtrRoomEvent; const ARoomId: string;
        var AJoinRoomEvent: TJoinRoomEvent): Boolean;
    end;
  public
    constructor Create(const ARoomId, ASenderUserId: string);
    property RoomId;
    property SenderUserId;
  end;

implementation

uses
  System.JSON.Serializers,
  Matrix.RoomEvent.RoomMemberContent, System.SysUtils;

class function TJoinRoomEvent.Factory.TryCreateFrom(ARoomEvent: TmtrRoomEvent; const ARoomId: string;
  var AJoinRoomEvent: TJoinRoomEvent): Boolean;
var
  LSerializer: TJsonSerializer;
  LContent: TRoomMemberContent;
begin
  Result := False;
  LSerializer := TJsonSerializer.Create;
  try
    LContent := LSerializer.DeSerialize<TRoomMemberContent>(ARoomEvent.Content.ToJSON);
    try
      Result := Result and (ARoomEvent.EventType = TEventType.Member) and
        (LContent.Membership = TUserMembershipState.Join);
      if Result then
        AJoinRoomEvent := TJoinRoomEvent.Create(ARoomId, ARoomEvent.Sender)
      else
        AJoinRoomEvent := TJoinRoomEvent.Create(string.Empty, string.Empty);
    finally
      LContent.Free;
    end;
    Result := Assigned(LContent);
  finally
    LSerializer.Free;
  end;
end;

constructor TJoinRoomEvent.Create(const ARoomId, ASenderUserId: string);
begin
  inherited Create(ARoomId, ASenderUserId);
end;

end.
