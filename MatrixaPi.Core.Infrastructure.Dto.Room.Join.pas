unit MatrixaPi.Core.Infrastructure.Dto.Room.Join;

interface

type
  TJoinRoomResponse = class
  private
    FRoomId: string;
  public
    /// <summary>
    ///     <b>Required.</b> The joined room ID.
    /// </summary>
    property RoomId: string read FRoomId write FRoomId;
  end;

implementation

end.
