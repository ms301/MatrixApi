unit MatrixaPi.Core.Domain.MatrixRoom;

interface

uses
  System.Generics.Collections,
  MatrixaPi.Types.Response,
  MatrixaPi.Core.Domain.RoomEvent,
  MatrixaPi.Core.Infrastructure.Dto.Room.Joined,
  MatrixaPi.Core.Infrastructure.Dto.Sync;

type
{$SCOPEDENUMS ON}
  TMatrixRoomStatus = (Joined, Invited, Left, Unknown);
{$SCOPEDENUMS OFF}

  TMatrixRoom = class
  private
    FId: string;
    FStatus: TMatrixRoomStatus;
    FJoinedUserIds: TList<string>;
  public
    constructor Create(const AId: string; const AStatus: TMatrixRoomStatus; AJoinedUserIds: TArray<string>); overload;
    constructor Create(const AId: string; const AStatus: TMatrixRoomStatus); overload;
    destructor Destroy; override;

    property Id: string read FId write FId;
    property Status: TMatrixRoomStatus read FStatus write FStatus;
    property JoinedUserIds: TList<string> read FJoinedUserIds write FJoinedUserIds;
  end;

  TMatrixRoomEventFactory = class
  public
    function CreateFromJoined(const ARoomId: string; AJoinedRoom: TJoinedRoom): TObjectList<TBaseRoomEvent>;
  end;

  TMatrixRoomFactory = class
    function CreateJoined(const ARoomId: string; AJoinedRoom: TJoinedRoom): TObjectList<TBaseRoomEvent>;
  end;

implementation

{TMatrixRoomEventFactory}
function TMatrixRoomEventFactory.CreateFromJoined(const ARoomId: string; AJoinedRoom: TJoinedRoom)
  : TObjectList<TBaseRoomEvent>;
var
  LJoinRoomEvent: TJoinRoomEvent;
begin
  Result := TObjectList<TBaseRoomEvent>.Create;
  for var LTimelineEvent in AJoinedRoom.TimeLine.Events do
    if TJoinRoomEvent.Factory.TryCreateFrom(LTimelineEvent, ARoomId, LJoinRoomEvent) then
      Result.Add(LJoinRoomEvent);
end;

{TMatrixRoomFactory}
function TMatrixRoomFactory.CreateJoined(const ARoomId: string; AJoinedRoom: TJoinedRoom): TObjectList<TBaseRoomEvent>;
var
  LJoinRoomEvent: TJoinRoomEvent;
begin
  Result := TObjectList<TBaseRoomEvent>.Create;
  for var LTimelineEvent in AJoinedRoom.TimeLine.Events do
  begin
    if TJoinRoomEvent.Factory.TryCreateFrom(LTimelineEvent, ARoomId, LJoinRoomEvent) then
      Result.Add(LJoinRoomEvent)
  end;
end;

{TMatrixRoom}
constructor TMatrixRoom.Create(const AId: string; const AStatus: TMatrixRoomStatus; AJoinedUserIds: TArray<string>);
begin
  inherited Create;
  FJoinedUserIds := TList<string>.Create();
  FId := AId;
  FStatus := AStatus;
  FJoinedUserIds.AddRange(AJoinedUserIds);
end;

constructor TMatrixRoom.Create(const AId: string; const AStatus: TMatrixRoomStatus);
begin
  Create(AId, AStatus, nil);
end;

destructor TMatrixRoom.Destroy;
begin
  FJoinedUserIds.Free;
  inherited Destroy;
end;

end.
