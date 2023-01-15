unit MatrixaPi.Core.Infrastructure.Dto.Sync;

interface

uses
  MatrixaPi.Core.Infrastructure.Dto.Sync.Event,
  System.JSON.Converters,
  System.Generics.Collections,
  System.JSON.Serializers,
  MatrixaPi.Core.Infrastructure.Dto.Sync.Event.Room;

type

  TmtrTimeline = class
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
    FTimeLine: TmtrTimeline;
  public
    constructor Create;
    destructor Destroy; override;
    property TimeLine: TmtrTimeline read FTimeLine write FTimeLine;
  end;

  TmtrSyncRoomsInvitedRoom = class

  end;

  TmtrSyncRoomsKnockedRoom = class

  end;

  TmtrSyncRoomsLeftRoom = class

  end;

  TRooms = class
  private type
    TJsonSyncRoomsJoined = class(TJsonStringDictionaryConverter<TJoinedRoom>);
    TJsonSyncRoomsInvited = class(TJsonStringDictionaryConverter<TmtrSyncRoomsInvitedRoom>);
    TJsonSyncRoomsKnocked = class(TJsonStringDictionaryConverter<TmtrSyncRoomsKnockedRoom>);
    TJsonSyncRoomsLeft = class(TJsonStringDictionaryConverter<TmtrSyncRoomsLeftRoom>);
  private
    [JsonName('join')]
    [JsonConverter(TJsonSyncRoomsJoined)]
    FJoin: TObjectDictionary<string, TJoinedRoom>;
    [JsonName('invite')]
    [JsonConverter(TJsonSyncRoomsInvited)]
    FInvite: TObjectDictionary<string, TmtrSyncRoomsInvitedRoom>;
    [JsonName('knock')]
    [JsonConverter(TJsonSyncRoomsKnocked)]
    FKnock: TObjectDictionary<string, TmtrSyncRoomsKnockedRoom>;
    [JsonName('leave')]
    [JsonConverter(TJsonSyncRoomsLeft)]
    FLeave: TObjectDictionary<string, TmtrSyncRoomsLeftRoom>;
  public
    constructor Create;
    destructor Destroy; override;
    /// <summary>
    /// The rooms that the user has been invited to, mapped as room ID to room
    /// information.
    /// </summary>
    property Invite: TObjectDictionary<string, TmtrSyncRoomsInvitedRoom> read FInvite write FInvite;
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
    property Leave: TObjectDictionary<string, TmtrSyncRoomsLeftRoom> read FLeave write FLeave;
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

{ TSyncResponse }
constructor TSyncResponse.Create;
begin
  inherited Create;
  FRooms := TRooms.Create();
end;

destructor TSyncResponse.Destroy;
begin
  FRooms.Free;
  inherited Destroy;
end;

{ TRooms }
constructor TRooms.Create;
begin
  inherited Create;
  FJoin := TObjectDictionary<string, TJoinedRoom>.Create([doOwnsValues]);
  FInvite := TObjectDictionary<string, TmtrSyncRoomsInvitedRoom>.Create([doOwnsValues]);
  FKnock := TObjectDictionary<string, TmtrSyncRoomsKnockedRoom>.Create([doOwnsValues]);
  FLeave := TObjectDictionary<string, TmtrSyncRoomsLeftRoom>.Create([doOwnsValues]);
end;

destructor TRooms.Destroy;
begin
  FLeave.Free;
  FKnock.Free;
  FInvite.Free;
  FJoin.Free;
  inherited Destroy;
end;

{ TmtrTimeline }
constructor TmtrTimeline.Create;
begin
  inherited Create;
  FEvents := TObjectList<TRoomEvent>.Create();
end;

destructor TmtrTimeline.Destroy;
begin
  FEvents.Free;
  inherited Destroy;
end;

{ TJoinedRoom }
constructor TJoinedRoom.Create;
begin
  inherited Create;
  FTimeLine := TmtrTimeline.Create();
end;

destructor TJoinedRoom.Destroy;
begin
  FTimeLine.Free;
  inherited Destroy;
end;

end.
