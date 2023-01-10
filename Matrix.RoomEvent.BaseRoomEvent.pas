unit Matrix.RoomEvent.BaseRoomEvent;

interface

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

implementation

constructor TBaseRoomEvent.Create(const ARoomId, ASenderUserId: string);
begin
  inherited Create;
  FRoomId := ARoomId;
  FSenderUserId := ASenderUserId;
end;

end.
