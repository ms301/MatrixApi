unit MatrixaPi.Core.Domain;

interface

uses
  MatrixaPi.Core.Domain.MatrixRoom,
  MatrixaPi.Types.Response,
  MatrixaPi.Types,
  System.Generics.Collections,
  MatrixaPi.Core.Domain.RoomEvent,
  MatrixaPi.Core.Infrastructure.Dto.Sync;

type
  TSyncBatch = class
  public type
    TFactory = class
    strict private
      class var FMatrixRoomFactory: TMatrixRoomFactory;
      class constructor Create;
      class destructor Destroy;

    public
      class function CreateFromSync(const ANextBatch: string; ARooms: TRooms): TSyncBatch;
      class function GetMatrixEventsFromSync(ARooms: TRooms): TObjectList<TBaseRoomEvent>;
      class function GetMatrixRoomsFromSync(ARooms: TRooms): TObjectList<TMatrixRoom>;
      class property MatrixRoomFactory: TMatrixRoomFactory read FMatrixRoomFactory;
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

class constructor TSyncBatch.TFactory.Create;
begin
  FMatrixRoomFactory := TMatrixRoomFactory.Create();
end;

class destructor TSyncBatch.TFactory.Destroy;
begin
  FMatrixRoomFactory.Free;
end;

class function TSyncBatch.TFactory.CreateFromSync(const ANextBatch: string; ARooms: TRooms): TSyncBatch;
var
  LMatrixRooms: TObjectList<TMatrixRoom>;
  LMatrixRoomEvents: TObjectList<TBaseRoomEvent>;
begin
  LMatrixRooms := GetMatrixRoomsFromSync(ARooms);
  LMatrixRoomEvents := GetMatrixEventsFromSync(ARooms);
  Result := TSyncBatch.Create(ANextBatch, LMatrixRooms, LMatrixRoomEvents);
end;

class function TSyncBatch.TFactory.GetMatrixEventsFromSync(ARooms: TRooms): TObjectList<TBaseRoomEvent>;
begin
  Result := nil;
  // TODO -cMM: TSyncBatch.TFactory.GetMatrixEventsFromSync default body inserted
end;

class function TSyncBatch.TFactory.GetMatrixRoomsFromSync(ARooms: TRooms): TObjectList<TMatrixRoom>;
begin
  Result := nil;
  // var
  //  joinedMatrixRooms =
  for var LItem in ARooms.Join do
  begin
    MatrixRoomFactory.CreateJoined(LItem.Key, LItem.Value);
  end;
  // .ToList();
  // var invitedMatrixRooms = rooms.Invite
  // .Select(pair => MatrixRoomFactory.CreateInvite(pair.Key, pair.Value)).ToList();
  // var leftMatrixRooms = rooms.Leave.Select(pair => MatrixRoomFactory.CreateLeft(pair.Key, pair.Value))
  // .ToList();
  //
  // return joinedMatrixRooms.Concat(invitedMatrixRooms).Concat(leftMatrixRooms).ToList();
end;

end.
