unit MatrixaPi.Core.Domain.MatrixRoom;

interface

uses
  System.Generics.Collections,
  MatrixaPi.Types.Response,
  MatrixaPi.Core.Domain.RoomEvent,
  MatrixaPi.Core.Infrastructure.Dto.Room.Joined,
  MatrixaPi.Core.Infrastructure.Dto.Sync, System.SysUtils;

type
{$SCOPEDENUMS ON}
  TMatrixRoomStatus = (Joined, Invited, Left, Unknown);
{$SCOPEDENUMS OFF}

  TMatrixRoom = class
  private
    FId: string;
    FStatus: TMatrixRoomStatus;
    FJoinedUserIds: TList<string>;
    FName: string;
  public
    constructor Create(const AId: string; const AStatus: TMatrixRoomStatus; AJoinedUserIds: TArray<string>); overload;
    constructor Create(const AId: string; const AStatus: TMatrixRoomStatus); overload;
    constructor Create; overload;
    destructor Destroy; override;

    property Id: string read FId write FId;
    property Name: string read FName write FName;
    property Status: TMatrixRoomStatus read FStatus write FStatus;
    property JoinedUserIds: TList<string> read FJoinedUserIds write FJoinedUserIds;
  end;

  TMatrixRoomEventFactory = class
  public
    function CreateFromJoined(const ARoomId: string; AJoinedRoom: TJoinedRoom): TObjectList<TBaseRoomEvent>;
    function CreateFromInvited(const ARoomId: string; AInvitedRoom: TInvitedRoom): TObjectList<TBaseRoomEvent>;
    function CreateFromLeft(const ARoomId: string; ALeftRoom: TLeftRoom): TObjectList<TBaseRoomEvent>;
  end;

  TMatrixRoomFactory = class
    function CreateJoined(const ARoomId: string; AJoinedRoom: TJoinedRoom): TMatrixRoom;
    function CreateInvite(const ARoomId: string; AInvitedRoom: TInvitedRoom): TMatrixRoom;
    function CreateLeft(const ARoomId: string; ALeftRoom: TLeftRoom): TMatrixRoom;

  end;

implementation

{TMatrixRoomEventFactory}
function TMatrixRoomEventFactory.CreateFromInvited(const ARoomId: string; AInvitedRoom: TInvitedRoom)
  : TObjectList<TBaseRoomEvent>;
var
  LJoinRoomEvent: TJoinRoomEvent;
  LCreateRoomEvent: TCreateRoomEvent;
  LInviteToRoomEvent: TInviteToRoomEvent;
  LTextMessageEvent: TTextMessageEvent;
begin
  Result := TObjectList<TBaseRoomEvent>.Create;
  for var LInviteStateEvent in AInvitedRoom.InviteState.Events do
  begin
    if TJoinRoomEvent.Factory.TryCreateFromStrippedState(LInviteStateEvent, ARoomId, LJoinRoomEvent) then
      Result.Add(LJoinRoomEvent)
    else if TCreateRoomEvent.Factory.TryCreateFromStrippedState(LInviteStateEvent, ARoomId, LCreateRoomEvent) then
      Result.Add(LCreateRoomEvent)
    else if TInviteToRoomEvent.Factory.TryCreateFromStrippedState(LInviteStateEvent, ARoomId, LInviteToRoomEvent) then
      Result.Add(LInviteToRoomEvent)
    else if TTextMessageEvent.Factory.TryCreateFromStrippedState(LInviteStateEvent, ARoomId, LTextMessageEvent) then
      Result.Add(LTextMessageEvent);
  end;
end;

function TMatrixRoomEventFactory.CreateFromJoined(const ARoomId: string; AJoinedRoom: TJoinedRoom)
  : TObjectList<TBaseRoomEvent>;
var
  LJoinRoomEvent: TJoinRoomEvent;
  LCreateRoomEvent: TCreateRoomEvent;
  LInviteToRoomEvent: TInviteToRoomEvent;
  LTextMessageEvent: TTextMessageEvent;
  LNameRoomEvent: TNameRoomEvent;
begin
  Result := TObjectList<TBaseRoomEvent>.Create;
  for var LTimelineEvent in AJoinedRoom.TimeLine.Events do
  begin
    if TJoinRoomEvent.Factory.TryCreateFrom(LTimelineEvent, ARoomId, LJoinRoomEvent) then
      Result.Add(LJoinRoomEvent)
    else if TCreateRoomEvent.Factory.TryCreateFrom(LTimelineEvent, ARoomId, LCreateRoomEvent) then
      Result.Add(LCreateRoomEvent)
    else if TInviteToRoomEvent.Factory.TryCreateFrom(LTimelineEvent, ARoomId, LInviteToRoomEvent) then
      Result.Add(LInviteToRoomEvent)
    else if TTextMessageEvent.Factory.TryCreateFrom(LTimelineEvent, ARoomId, LTextMessageEvent) then
      Result.Add(LTextMessageEvent)
    else if TNameRoomEvent.Factory.TryCreateFrom(LTimelineEvent, ARoomId, LNameRoomEvent) then
      Result.Add(LNameRoomEvent);
  end;
end;

function TMatrixRoomEventFactory.CreateFromLeft(const ARoomId: string; ALeftRoom: TLeftRoom)
  : TObjectList<TBaseRoomEvent>;
var
  LJoinRoomEvent: TJoinRoomEvent;
  LCreateRoomEvent: TCreateRoomEvent;
  LInviteToRoomEvent: TInviteToRoomEvent;
  LTextMessageEvent: TTextMessageEvent;
begin
  Result := TObjectList<TBaseRoomEvent>.Create;
  for var LTimelineEvent in ALeftRoom.TimeLine.Events do
  begin
    if TJoinRoomEvent.Factory.TryCreateFrom(LTimelineEvent, ARoomId, LJoinRoomEvent) then
      Result.Add(LJoinRoomEvent)
    else if TCreateRoomEvent.Factory.TryCreateFrom(LTimelineEvent, ARoomId, LCreateRoomEvent) then
      Result.Add(LCreateRoomEvent)
    else if TInviteToRoomEvent.Factory.TryCreateFrom(LTimelineEvent, ARoomId, LInviteToRoomEvent) then
      Result.Add(LInviteToRoomEvent)
    else if TTextMessageEvent.Factory.TryCreateFrom(LTimelineEvent, ARoomId, LTextMessageEvent) then
      Result.Add(LTextMessageEvent);
  end;
end;

{TMatrixRoomFactory}
function TMatrixRoomFactory.CreateInvite(const ARoomId: string; AInvitedRoom: TInvitedRoom): TMatrixRoom;
var
  LJoinRoomEvent: TJoinRoomEvent;
  LJoinedUserIds: TList<string>;
begin
  LJoinedUserIds := TList<string>.Create;
  try
    for var LTimelineEvent in AInvitedRoom.InviteState.Events do
    begin
      if TJoinRoomEvent.Factory.TryCreateFromStrippedState(LTimelineEvent, ARoomId, LJoinRoomEvent) then
        LJoinedUserIds.Add(LJoinRoomEvent.SenderUserId);
    end;
    Result := TMatrixRoom.Create(ARoomId, TMatrixRoomStatus.Invited, LJoinedUserIds.ToArray);
  finally
    LJoinedUserIds.Free;
  end;
end;

function TMatrixRoomFactory.CreateJoined(const ARoomId: string; AJoinedRoom: TJoinedRoom): TMatrixRoom;
var
  LJoinRoomEvent: TJoinRoomEvent;
  LNameRoomEvent: TNameRoomEvent;
begin
  Result := TMatrixRoom.Create;
  for var LTimelineEvent in AJoinedRoom.TimeLine.Events do
  begin
    if TJoinRoomEvent.Factory.TryCreateFrom(LTimelineEvent, ARoomId, LJoinRoomEvent) then
    begin
      Result.JoinedUserIds.Add(LJoinRoomEvent.SenderUserId);
      LJoinRoomEvent.Free;
    end
    else if TNameRoomEvent.Factory.TryCreateFrom(LTimelineEvent, ARoomId, LNameRoomEvent) then
    begin
      Result.Name := LNameRoomEvent.Name;
      LNameRoomEvent.Free;
    end;
  end;
end;

function TMatrixRoomFactory.CreateLeft(const ARoomId: string; ALeftRoom: TLeftRoom): TMatrixRoom;
var
  LJoinRoomEvent: TJoinRoomEvent;
  LJoinedUserIds: TList<string>;
begin
  LJoinedUserIds := TList<string>.Create;
  try
    for var LTimelineEvent in ALeftRoom.TimeLine.Events do
    begin
      if TJoinRoomEvent.Factory.TryCreateFrom(LTimelineEvent, ARoomId, LJoinRoomEvent) then
        LJoinedUserIds.Add(LJoinRoomEvent.SenderUserId);
    end;
    Result := TMatrixRoom.Create(ARoomId, TMatrixRoomStatus.Left, LJoinedUserIds.ToArray);
  finally
    LJoinedUserIds.Free;
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

constructor TMatrixRoom.Create;
begin
  Create(string.empty, TMatrixRoomStatus.Unknown);
end;

destructor TMatrixRoom.Destroy;
begin
  FJoinedUserIds.Free;
  inherited Destroy;
end;

end.
