unit MatrixaPi.Core.Domain.Services;

interface

uses
  Citrus.ThreadTimer,
  MatrixaPi.Core.Domain,
  MatrixaPi.Core.Domain.MatrixRoom,
  System.SysUtils,
  MatrixaPi.Core.Infrastructure.Services,
  System.Generics.Collections;

type
  TSyncBatchEventArgs = class

  end;

  IPollingService = interface
    ['{8653CC6B-D055-4A9E-8324-A56A5837D431}']
    //  private
    function GetOnSyncBatchReceived: TProc<TObject, TSyncBatch>;
    procedure SetOnSyncBatchReceived(const Value: TProc<TObject, TSyncBatch>);
    function GetInvitedRooms: TArray<TMatrixRoom>;
    function GetJoinedRooms: TArray<TMatrixRoom>;
    function GetLeftRooms: TArray<TMatrixRoom>;
    function GetIsSyncing: Boolean;
    // public
    property InvitedRooms: TArray<TMatrixRoom> read GetInvitedRooms;
    property JoinedRooms: TArray<TMatrixRoom> read GetJoinedRooms;
    property LeftRooms: TArray<TMatrixRoom> read GetLeftRooms;
    property IsSyncing: Boolean read GetIsSyncing;
    property OnSyncBatchReceived: TProc<TObject, TSyncBatch> read GetOnSyncBatchReceived write SetOnSyncBatchReceived;
    procedure Init(const ANodeAddress, AAccessToken: string);
    procedure Start(const ANextBath: string = '');
    procedure Stop;
    function GetMatrixRoom(const ARoomId: string): TMatrixRoom;
  end;

  TPollingService = class(TInterfacedObject, IPollingService)
  private
    FEventService: TEventService;
    FTimer: TThreadTimer;
    FAccessToken: string;
    FOnSyncBatchReceived: TProc<TObject, TSyncBatch>;
    FNextBath: string;
    FIsSyncing: Boolean;
    FTimeOut: Cardinal;
    FMatrixRooms: TObjectDictionary<string, TMatrixRoom>;
    function GetIsSyncing: Boolean;
    function GetOnSyncBatchReceived: TProc<TObject, TSyncBatch>;
    procedure SetOnSyncBatchReceived(const Value: TProc<TObject, TSyncBatch>);
    function GetInvitedRooms: TArray<TMatrixRoom>;
    function GetJoinedRooms: TArray<TMatrixRoom>;
    function GetLeftRooms: TArray<TMatrixRoom>;
  protected
    procedure DoTimer;
    procedure RefreshRooms(AMatrixRooms: TObjectList<TMatrixRoom>);
    function GetRoomsByStatus(const ARoomStatus: TMatrixRoomStatus): TArray<TMatrixRoom>;
  public
    constructor Create(AEventService: TEventService);

    function GetMatrixRoom(const ARoomId: string): TMatrixRoom;
    procedure Start(const ANextBath: string = '');
    procedure Stop;
    procedure Init(const ANodeAddress, AAccessToken: string);
    destructor Destroy; override;
    property IsSyncing: Boolean read GetIsSyncing write FIsSyncing;
    property OnSyncBatchReceived: TProc<TObject, TSyncBatch> read GetOnSyncBatchReceived write SetOnSyncBatchReceived;
    property InvitedRooms: TArray<TMatrixRoom> read GetInvitedRooms;
    property JoinedRooms: TArray<TMatrixRoom> read GetJoinedRooms;
    property LeftRooms: TArray<TMatrixRoom> read GetLeftRooms;
    property MatrixRooms: TObjectDictionary<string, TMatrixRoom> read FMatrixRooms;
  end;

implementation

uses
  System.Classes,
  MatrixaPi.Types.Response,
  Citrus.Mandarin,
  MatrixaPi.Core.Infrastructure.Dto.Sync;

constructor TPollingService.Create(AEventService: TEventService);
begin
  inherited Create;
  FEventService := AEventService;
  FTimer := TThreadTimer.Create(DoTimer);
  FMatrixRooms := TObjectDictionary<string, TMatrixRoom>.Create();
end;

destructor TPollingService.Destroy;
begin
  FMatrixRooms.Free;
  Stop;
  FTimer.Free;
  inherited;
end;

procedure TPollingService.DoTimer;
begin
  FTimer.Interval := Int64.MaxValue;
  FIsSyncing := True;
  FEventService.Sync(
    procedure(ASync: TSyncResponse; AHttpResp: IHTTPResponse)
    var
      LSyncBath: TSyncBatch;
    begin
      LSyncBath := TSyncBatch.TFactory.CreateFromSync(ASync.NextBatch, ASync.Rooms);
      try
        FNextBath := LSyncBath.NextBatch;
        FTimeOut := 30000;

        RefreshRooms(LSyncBath.MatrixRooms);
        if Assigned(FOnSyncBatchReceived) then
          FOnSyncBatchReceived(Self, LSyncBath);
        FTimer.Start;
      finally
        LSyncBath.Free;
        ASync.Free;
      end;
    end, 0, FNextBath);

end;

function TPollingService.GetIsSyncing: Boolean;
begin
  Result := FIsSyncing;
end;

function TPollingService.GetRoomsByStatus(const ARoomStatus: TMatrixRoomStatus): TArray<TMatrixRoom>;
var
  LRooms: TList<TMatrixRoom>;
begin
  LRooms := TList<TMatrixRoom>.Create;
  try
    for var LRoom in FMatrixRooms.Values do
      if LRoom.Status = ARoomStatus then
        LRooms.Add(LRoom);
    Result := LRooms.ToArray;
  finally
    LRooms.Free;
  end;
end;

function TPollingService.GetInvitedRooms: TArray<TMatrixRoom>;
begin
  Result := GetRoomsByStatus(TMatrixRoomStatus.Invited);
end;

function TPollingService.GetJoinedRooms: TArray<TMatrixRoom>;
begin
  Result := GetRoomsByStatus(TMatrixRoomStatus.Joined);
end;

function TPollingService.GetLeftRooms: TArray<TMatrixRoom>;
begin
  Result := GetRoomsByStatus(TMatrixRoomStatus.Left);
end;

function TPollingService.GetMatrixRoom(const ARoomId: string): TMatrixRoom;
begin
  if not FMatrixRooms.TryGetValue(ARoomId, Result) then
    Result := nil;
end;

function TPollingService.GetOnSyncBatchReceived: TProc<TObject, TSyncBatch>;
begin
  Result := FOnSyncBatchReceived;
end;

procedure TPollingService.Init(const ANodeAddress, AAccessToken: string);
begin
  FAccessToken := AAccessToken;
  FEventService.BaseAdress := ANodeAddress;
end;

procedure TPollingService.RefreshRooms(AMatrixRooms: TObjectList<TMatrixRoom>);
var
  LRetrivedRoom: TMatrixRoom;
begin
  for var LRoom in AMatrixRooms do
  begin
    if not FMatrixRooms.TryGetValue(LRoom.Id, LRetrivedRoom) then
    begin
      if not FMatrixRooms.TryAdd(LRoom.Id, LRoom) then
        raise Exception.Create('Can not add matrix room');
    end
    else
    begin
      LRetrivedRoom.JoinedUserIds.AddRange(LRoom.JoinedUserIds);
      LRetrivedRoom.Status := LRoom.Status;
    end;
  end;
end;

procedure TPollingService.SetOnSyncBatchReceived(const Value: TProc<TObject, TSyncBatch>);
begin
  FOnSyncBatchReceived := Value;
end;

procedure TPollingService.Start(const ANextBath: string);
begin
  if not Assigned(FTimer) then
    raise EArgumentNilException.Create('Call Init first.');
  if not ANextBath.IsEmpty then
    FNextBath := ANextBath;
  FTimer.Start;
end;

procedure TPollingService.Stop;
begin
  FTimer.Stop;
  FIsSyncing := False;
end;

end.
