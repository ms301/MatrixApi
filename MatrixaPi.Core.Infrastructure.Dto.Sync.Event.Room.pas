unit MatrixaPi.Core.Infrastructure.Dto.Sync.Event.Room;

interface

uses
  System.JSON,
  System.JSON.Serializers,
  MatrixaPi.Core.Infrastructure.Dto.Sync.Event;

type
  TRoomStrippedState = class(TBaseEvent)
  private
    [JsonName('sender')]
    FSender: string;
  public
    property Sender: string read FSender write FSender;
  end;

  TRoomEvent = class(TBaseEvent)
  private
    [JsonName('event_id')]
    FEventId: string;
    [JsonName('sender')]
    FSender: string;
    [JsonName('origin_server_ts')]
    FOriginServerTimestamp: Int64;
  public
    /// <summary>
    /// Required: The globally unique identifier for this event.
    /// </summary>
    property EventId: string read FEventId write FEventId;
    /// <summary>
    /// Required: Timestamp (in milliseconds since the unix epoch) on originating
    /// homeserver when this event was sent.
    /// </summary>
    property OriginServerTimestamp: Int64 read FOriginServerTimestamp write FOriginServerTimestamp;
    /// <summary>
    /// Required: Contains the fully-qualified ID of the user who sent this event.
    /// </summary>
    property Sender: string read FSender write FSender;
  end;

implementation

end.
