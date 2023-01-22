unit MatrixaPi.Core.Infrastructure.Dto.Sync.Event.Room.State;

interface

uses
  System.JSON.Serializers;

type
  TPreviousRoom = class
  private
    [JsonName('event_id')]
    FEventId: string;
    [JsonName('room_id')]
    FRoomId: string;
  public
    property EventId: string read FEventId write FEventId;
    property RoomId: string read FRoomId write FRoomId;
  end;

  /// <remarks>
  ///     m.room.create
  /// </remarks>
  TRoomCreateContent = class
  private
    [JsonName('creator')]
    FCreator: string;
    [JsonName('m.federate')]
    FFederate: Boolean;
    [JsonName('m.room_version')]
    FRoomVersion: string;
    [JsonName('predecessor')]
    FPredecessor: TPreviousRoom;
    [JsonName('type')]
    FRoomType: string;
  public
    constructor Create;
    destructor Destroy; override;
    property Creator: string read FCreator write FCreator;
    property Federate: Boolean read FFederate write FFederate;
    property Predecessor: TPreviousRoom read FPredecessor write FPredecessor;
    property RoomVersion: string read FRoomVersion write FRoomVersion;
    property RoomType: string read FRoomType write FRoomType;
  end;

implementation

constructor TRoomCreateContent.Create;
begin
  inherited Create;
  FPredecessor := TPreviousRoom.Create();
end;

destructor TRoomCreateContent.Destroy;
begin
  FPredecessor.Free;
  inherited Destroy;
end;

end.
