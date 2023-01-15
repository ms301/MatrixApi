unit MatrixaPi.Core.Domain.RoomEvent;

interface

uses
  MatrixaPi.Types.Response,
  MatrixaPi.Core.Infrastructure.Dto.Sync.Event.Room;

type
  TBaseRoomEvent = class
  private
    FRoomId: string;
    FSenderUserId: string;
  public
    constructor Create(const ARoomId, ASenderUserId: string); virtual;
    property RoomId: string read FRoomId write FRoomId;
    property SenderUserId: string read FSenderUserId write FSenderUserId;
  end;

  TJoinRoomEvent = class(TBaseRoomEvent)
  public type
    Factory = class
      class function TryCreateFrom(ARoomEvent: TRoomEvent; const ARoomId: string;
        var AJoinRoomEvent: TJoinRoomEvent): Boolean;
    end;
  public
    constructor Create(const ARoomId, ASenderUserId: string); override;
    property RoomId;
    property SenderUserId;
  end;

implementation

uses
  System.JSON.Serializers,
  MatrixaPi.RoomEvent.RoomMemberContent,
  MatrixaPi.Core.Infrastructure.Dto.Sync.Event;

{TBaseRoomEvent}
constructor TBaseRoomEvent.Create(const ARoomId, ASenderUserId: string);
begin
  inherited Create;
  FRoomId := ARoomId;
  FSenderUserId := ASenderUserId;
end;

{TJoinRoomEvent}
class function TJoinRoomEvent.Factory.TryCreateFrom(ARoomEvent: TRoomEvent; const ARoomId: string;
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
        AJoinRoomEvent := nil{TJoinRoomEvent.Create(string.Empty, string.Empty)};
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
