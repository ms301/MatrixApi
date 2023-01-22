unit MatrixaPi.Types.Response;

interface

uses
  Citrus.Json.Converters,
  System.Json.Converters,
  System.Json.Serializers,
  System.Generics.Collections,
  System.Json;

type
  TmtrError = class
  private
    [JsonName('errcode')]
    FErrorCode: string;
    [JsonName('error')]
    FError: string;
    [JsonName('retry_after_ms')]
    FRetryAfterMs: Integer;
  public
    /// <summary>
    /// An error code.
    /// </summary>
    property ErrorCode: string read FErrorCode write FErrorCode;
    /// <summary>
    /// A human-readable error message.
    /// </summary>
    property Error: string read FError write FError;
    /// <summary>
    /// The amount of time in milliseconds the client should wait before trying the
    /// request again.
    /// </summary>
    property RetryAfterMs: Integer read FRetryAfterMs write FRetryAfterMs;
  end;

  TmtrPublicRooms = class(TmtrError)
  type
    TRoom = class
    private
      [JsonName('avatar_url')]
      FAvatarUrl: string;
      [JsonName('canonical_alias')]
      FCanonicalAlias: string;
      [JsonName('guest_can_join')]
      FGuestCanJoin: Boolean;
      [JsonName('join_rule')]
      FJoinRule: string;
      [JsonName('name')]
      FName: string;
      [JsonName('num_joined_members')]
      FNumJoinedMembers: Integer;
      [JsonName('room_id')]
      FRoomId: string;
      [JsonName('room_type')]
      FRoomType: string;
      [JsonName('topic')]
      FTopic: string;
      [JsonName('world_readable')]
      FWorldReadable: Boolean;
    public
      /// <summary>
      /// The URL for the room’s avatar, if one is set.
      /// </summary>
      property AvatarUrl: string read FAvatarUrl write FAvatarUrl;
      /// <summary>
      /// The canonical alias of the room, if any.
      /// </summary>
      property CanonicalAlias: string read FCanonicalAlias write FCanonicalAlias;
      /// <summary>
      /// Required: Whether guest users may join the room and participate in it. If they
      /// can, they will be subject to ordinary power level rules like any other user.
      /// </summary>
      property GuestCanJoin: Boolean read FGuestCanJoin write FGuestCanJoin;
      /// <summary>
      /// The room’s join rule. When not present, the room is assumed to be public. Note
      /// that rooms with invite join rules are not expected here, but rooms with knock
      /// rules are given their near-public nature.
      /// </summary>
      property JoinRule: string read FJoinRule write FJoinRule;
      /// <summary>
      /// The name of the room, if any.
      /// </summary>
      property Name: string read FName write FName;
      /// <summary>
      /// Required: The number of members joined to the room.
      /// </summary>
      property NumJoinedMembers: Integer read FNumJoinedMembers write FNumJoinedMembers;
      /// <summary>
      /// Required: The ID of the room.
      /// </summary>
      property RoomId: string read FRoomId write FRoomId;
      /// <summary>
      /// The type of room (from m.room.create), if any.
      /// </summary>
      /// <remarks>
      /// Added in v1.4
      /// </remarks>
      property RoomType: string read FRoomType write FRoomType;
      /// <summary>
      /// The topic of the room, if any.
      /// </summary>
      property Topic: string read FTopic write FTopic;
      /// <summary>
      /// Required: Whether the room may be viewed by guest users without joining.
      /// </summary>
      property WorldReadable: Boolean read FWorldReadable write FWorldReadable;
    end;

    TChunkConverter = class(TJsonListConverter<TmtrPublicRooms.TRoom>);
  private
    [JsonName('next_batch')]
    FNextBatch: string;
    [JsonName('total_room_count_estimate')]
    FTotalRoomCountEstimate: Integer;
    [JsonName('chunk')]
    [JsonConverter(TChunkConverter)]
    FChunk: TObjectList<TmtrPublicRooms.TRoom>;
    [JsonName('prev_batch')]
    FPrevBatch: string;
  public
    constructor Create;
    destructor Destroy; override;
    /// <summary>
    /// A pagination token for the response. The absence of this token means there are
    /// no more results to fetch and the client should stop paginating.
    /// </summary>
    property NextBatch: string read FNextBatch write FNextBatch;
    /// <summary>
    /// A pagination token that allows fetching previous results. The absence of this
    /// token means there are no results before this batch, i.e. this is the first
    /// batch.
    /// </summary>
    property PrevBatch: string read FPrevBatch write FPrevBatch;
    /// <summary>
    /// An estimate on the total number of public rooms, if the server has an estimate.
    /// </summary>
    property TotalRoomCountEstimate: Integer read FTotalRoomCountEstimate write FTotalRoomCountEstimate;
    property Chunk: TObjectList<TmtrPublicRooms.TRoom> read FChunk write FChunk;
  end;

implementation

{ TmtrPublicRooms }
constructor TmtrPublicRooms.Create;
begin
  inherited Create;
  FChunk := TObjectList<TmtrPublicRooms.TRoom>.Create();
end;

destructor TmtrPublicRooms.Destroy;
begin
  FChunk.Free;
  inherited Destroy;
end;

end.
