unit MatrixaPi.Core.Domain;

interface

uses
  MatrixaPi.Core.Domain.MatrixRoom,
  MatrixaPi.Types.Response,
  System.Generics.Collections,
  MatrixaPi.Core.Domain.RoomEvent,
  MatrixaPi.Core.Infrastructure.Dto.Sync;

type
  TSyncBatch = class
  public type
    TFactory = class
    strict private
      class var FMatrixRoomFactory: TMatrixRoomFactory;
      class var FMatrixRoomEventFactory: TMatrixRoomEventFactory;
      class constructor Create;
      class destructor Destroy;

    public
      class function CreateFromSync(const ANextBatch: string; ARooms: TRooms): TSyncBatch;
      class function GetMatrixEventsFromSync(ARooms: TRooms): TObjectList<TBaseRoomEvent>;
      class function GetMatrixRoomsFromSync(ARooms: TRooms): TObjectList<TMatrixRoom>;
      class property MatrixRoomFactory: TMatrixRoomFactory read FMatrixRoomFactory;
      class property MatrixRoomEventFactory: TMatrixRoomEventFactory read FMatrixRoomEventFactory;
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
  FMatrixRoomEventFactory := TMatrixRoomEventFactory.Create();
end;

class destructor TSyncBatch.TFactory.Destroy;
begin
  FMatrixRoomFactory.Free;
  FMatrixRoomEventFactory.Free;
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
  Result := TObjectList<TBaseRoomEvent>.Create;
  for var LPair in ARooms.Join do
  begin
    Result.AddRange(MatrixRoomEventFactory.CreateFromJoined(LPair.Key, LPair.Value));
  end;
  for var LPair in ARooms.Invite do
  begin
    Result.AddRange(MatrixRoomEventFactory.CreateFromInvited(LPair.Key, LPair.Value));
  end;
  for var LPair in ARooms.Leave do
  begin
    Result.AddRange(MatrixRoomEventFactory.CreateFromLeft(LPair.Key, LPair.Value));
  end;
end;

class function TSyncBatch.TFactory.GetMatrixRoomsFromSync(ARooms: TRooms): TObjectList<TMatrixRoom>;
begin
  Result := TObjectList<TMatrixRoom>.Create;
  for var LPair in ARooms.Join do
  begin
    Result.AddRange(MatrixRoomFactory.CreateJoined(LPair.Key, LPair.Value));
  end;
  for var LPair in ARooms.Invite do
  begin
    Result.AddRange(MatrixRoomFactory.CreateInvite(LPair.Key, LPair.Value));
  end;
  for var LPair in ARooms.Leave do
  begin
    Result.AddRange(MatrixRoomFactory.CreateLeft(LPair.Key, LPair.Value));
  end;
end;

end.
