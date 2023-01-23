unit MatrixaPi.Core.Infrastructure.Dto.Sync;

interface

uses
  MatrixaPi.Core.Infrastructure.Dto.Sync.Event,
  System.JSON.Converters,
  System.Generics.Collections,
  System.JSON.Serializers,
  MatrixaPi.Core.Infrastructure.Dto.Sync.Event.Room;

type

  TTimeline = class
  private type
    TJsonEventsConverter = class(TJsonListConverter<TRoomEvent>);
  private
    [JsonName('events')]
    [JsonConverter(TJsonEventsConverter)]
    FEvents: TObjectList<TRoomEvent>;
  public
    constructor Create;
    destructor Destroy; override;
    property Events: TObjectList<TRoomEvent> read FEvents write FEvents;
  end;

  TmtrSyncAccountData = class

  end;

  TJoinedRoom = class
  private
    [JsonName('timeline')]
    FTimeLine: TTimeline;
  public
    constructor Create;
    destructor Destroy; override;
    property TimeLine: TTimeline read FTimeLine write FTimeLine;
  end;

  TLeftRoom = class
  private
    [JsonName('timeline')]
    FTimeLine: TTimeline;
  public
    constructor Create;
    destructor Destroy; override;
    property TimeLine: TTimeline read FTimeLine write FTimeLine;
  end;

  TInviteState = class
  private type
    TJsonEventsConverter = class(TJsonListConverter<TRoomStrippedState>);
  private
    [JsonName('events')]
    [JsonConverter(TJsonEventsConverter)]
    FEvents: TObjectList<TRoomStrippedState>;
  public
    constructor Create;
    destructor Destroy; override;
    property Events: TObjectList<TRoomStrippedState> read FEvents write FEvents;
  end;

  TInvitedRoom = class
  private
    [JsonName('invite_state')]
    FInviteState: TInviteState;
  public
    constructor Create;
    destructor Destroy; override;
    property InviteState: TInviteState read FInviteState write FInviteState;
  end;

  TmtrSyncRoomsKnockedRoom = class

  end;

  TRooms = class
  private type
    TJsonSyncRoomsJoined = class(TJsonStringDictionaryConverter<TJoinedRoom>);
    TJsonSyncRoomsInvited = class(TJsonStringDictionaryConverter<TInvitedRoom>);
    TJsonSyncRoomsKnocked = class(TJsonStringDictionaryConverter<TmtrSyncRoomsKnockedRoom>);
    TJsonSyncRoomsLeft = class(TJsonStringDictionaryConverter<TLeftRoom>);
  private
    [JsonName('join')]
    [JsonConverter(TJsonSyncRoomsJoined)]
    FJoin: TObjectDictionary<string, TJoinedRoom>;
    [JsonName('invite')]
    [JsonConverter(TJsonSyncRoomsInvited)]
    FInvite: TObjectDictionary<string, TInvitedRoom>;
    [JsonName('knock')]
    [JsonConverter(TJsonSyncRoomsKnocked)]
    FKnock: TObjectDictionary<string, TmtrSyncRoomsKnockedRoom>;
    [JsonName('leave')]
    [JsonConverter(TJsonSyncRoomsLeft)]
    FLeave: TObjectDictionary<string, TLeftRoom>;
  public
    constructor Create;
    destructor Destroy; override;
    /// <summary>
    /// The rooms that the user has been invited to, mapped as room ID to room
    /// information.
    /// </summary>
    property Invite: TObjectDictionary<string, TInvitedRoom> read FInvite write FInvite;
    /// <remarks>
    /// The rooms that the user has joined, mapped as room ID to room information.
    /// </remarks>
    property Join: TObjectDictionary<string, TJoinedRoom> read FJoin write FJoin;
    /// <summary>
    /// The rooms that the user has knocked upon, mapped as room ID to room information.
    /// </summary>
    property Knock: TObjectDictionary<string, TmtrSyncRoomsKnockedRoom> read FKnock write FKnock;
    /// <summary>
    /// The rooms that the user has left or been banned from, mapped as room ID to room
    /// information.
    /// </summary>
    property Leave: TObjectDictionary<string, TLeftRoom> read FLeave write FLeave;
  end;

  /// <summary>
  /// Synchronization response.
  /// </summary>
  TSyncResponse = class
  private
    [JsonName('next_batch')]
    FNextBatch: string;
    [JsonName('rooms')]
    FRooms: TRooms;
  public
    constructor Create;
    destructor Destroy; override;
    /// <summary>
    /// Required: The batch token to supply in the since param of the next /sync
    /// request.
    /// </summary>
    property NextBatch: string read FNextBatch write FNextBatch;
    /// <summary>
    /// Updates to rooms.
    /// </summary>
    property Rooms: TRooms read FRooms write FRooms;
  end;

implementation

uses
  System.SysUtils;

{ TSyncResponse }
constructor TSyncResponse.Create;
begin
  inherited Create;
  FRooms := TRooms.Create();
end;

destructor TSyncResponse.Destroy;
begin
  FreeAndNil(FRooms);
  inherited Destroy;
end;

{ TRooms }
constructor TRooms.Create;
begin
  inherited Create;
  FJoin := TObjectDictionary<string, TJoinedRoom>.Create([doOwnsValues]);
  FInvite := TObjectDictionary<string, TInvitedRoom>.Create([doOwnsValues]);
  FKnock := TObjectDictionary<string, TmtrSyncRoomsKnockedRoom>.Create([doOwnsValues]);
  FLeave := TObjectDictionary<string, TLeftRoom>.Create([doOwnsValues]);
end;

destructor TRooms.Destroy;
begin
  FLeave.Free;
  FKnock.Free;
  FInvite.Free;
  FJoin.Free;
  inherited Destroy;
end;

{ TTimeline }
constructor TTimeline.Create;
begin
  inherited Create;
  FEvents := TObjectList<TRoomEvent>.Create();
end;

destructor TTimeline.Destroy;
begin
  FEvents.Free;
  inherited Destroy;
end;

{ TJoinedRoom }
constructor TJoinedRoom.Create;
begin
  inherited Create;
  FTimeLine := TTimeline.Create();
end;

destructor TJoinedRoom.Destroy;
begin
  FTimeLine.Free;
  inherited Destroy;
end;

{ TLeftRoom }

constructor TLeftRoom.Create;
begin
  inherited Create;
  FTimeLine := TTimeline.Create();
end;

destructor TLeftRoom.Destroy;
begin
  FTimeLine.Free;
  inherited Destroy;
end;

constructor TInvitedRoom.Create;
begin
  inherited Create;
  FInviteState := TInviteState.Create();
end;

destructor TInvitedRoom.Destroy;
begin
  FInviteState.Free;
  inherited Destroy;
end;

{ TInviteState }

constructor TInviteState.Create;
begin
  FEvents := TObjectList<TRoomStrippedState>.Create();
end;

destructor TInviteState.Destroy;
begin
  FEvents.Free;
  inherited;
end;

end.
