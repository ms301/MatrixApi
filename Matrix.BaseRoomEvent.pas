unit Matrix.BaseRoomEvent;

interface

type
  TBaseRoomEvent = class
  private
    FRoomId: string;
    FSenderUserId: string;
  public
    property RoomId: string read FRoomId write FRoomId;
    property SenderUserId: string read FSenderUserId write FSenderUserId;
  end;

implementation

end.
