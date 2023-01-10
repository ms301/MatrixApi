unit Matrix.SyncBath;

interface

uses
  Matrix.BaseRoomEvent,
  Matrix.Types,
  System.Generics.Collections,
  Matrix.Types.Response;

type
  TSyncBatch = class
  private type
    TFactory = class

    public
      class function CreateFromSync(const ANextBatch: string; ARooms: TmtrSyncRooms): TSyncBatch;
      class function GetMatrixEventsFromSync(ARooms: TmtrSyncRooms): TObjectList<TBaseRoomEvent>;
      class function GetMatrixRoomsFromSync(ARooms: TmtrSyncRooms): TObjectList<TMatrixRoom>;

    end;
  private
    FNextBatch: string;
    FMatrixRooms: TObjectList<TMatrixRoom>;
    FMatrixRoomEvents: TObjectList<TBaseRoomEvent>;
  protected
    constructor Create(const ANextBatch: string; AMatrixRooms: TObjectList<TMatrixRoom>;
      AMatrixRoomEvents: TObjectList<TBaseRoomEvent>);
  public
    property NextBatch: string read FNextBatch write FNextBatch;
    property MatrixRooms: TObjectList<TMatrixRoom> read FMatrixRooms write FMatrixRooms;
    property MatrixRoomEvents: TObjectList<TBaseRoomEvent> read FMatrixRoomEvents write FMatrixRoomEvents;
  end;

implementation

constructor TSyncBatch.Create(const ANextBatch: string; AMatrixRooms: TObjectList<TMatrixRoom>;
  AMatrixRoomEvents: TObjectList<TBaseRoomEvent>);
begin
  inherited Create;
  FNextBatch := ANextBatch;
  FMatrixRooms := AMatrixRooms;
  FMatrixRoomEvents := AMatrixRoomEvents;
end;

class function TSyncBatch.TFactory.CreateFromSync(const ANextBatch: string; ARooms: TmtrSyncRooms): TSyncBatch;
var
  LMatrixRooms: TObjectList<TMatrixRoom>;
  LMatrixRoomEvents: TObjectList<TBaseRoomEvent>;
begin
  LMatrixRooms := GetMatrixRoomsFromSync(ARooms);
  LMatrixRoomEvents := GetMatrixEventsFromSync(ARooms);
  Result := TSyncBatch.Create(ANextBatch, LMatrixRooms, LMatrixRoomEvents);
end;

class function TSyncBatch.TFactory.GetMatrixEventsFromSync(ARooms: TmtrSyncRooms): TObjectList<TBaseRoomEvent>;
begin
  Result := nil;
  // TODO -cMM: TSyncBatch.TFactory.GetMatrixEventsFromSync default body inserted
end;

class function TSyncBatch.TFactory.GetMatrixRoomsFromSync(ARooms: TmtrSyncRooms): TObjectList<TMatrixRoom>;
begin
  Result := nil;
  // var joinedMatrixRooms = rooms.Join.Select(pair => MatrixRoomFactory.CreateJoined(pair.Key, pair.Value))
  // .ToList();
  // var invitedMatrixRooms = rooms.Invite
  // .Select(pair => MatrixRoomFactory.CreateInvite(pair.Key, pair.Value)).ToList();
  // var leftMatrixRooms = rooms.Leave.Select(pair => MatrixRoomFactory.CreateLeft(pair.Key, pair.Value))
  // .ToList();
  //
  // return joinedMatrixRooms.Concat(invitedMatrixRooms).Concat(leftMatrixRooms).ToList();
end;

end.
