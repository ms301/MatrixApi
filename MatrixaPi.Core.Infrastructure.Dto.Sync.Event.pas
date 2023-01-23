unit MatrixaPi.Core.Infrastructure.Dto.Sync.Event;

interface

uses
  Citrus.JObject,
  Citrus.Json.Converters,
  System.Json,
  System.Json.Serializers,
  System.Json.Converters;

type
{$SCOPEDENUMS ON}
  TEventType = (Unknown, //
    CanonicalAlias, //
    Create, //
    JoinRules, //
    Member, //
    PowerLevels, //
    Message, //
    Name//
    );
{$SCOPEDENUMS OFF}

  TBaseEvent = class
  private
    [JsonName('content')]
    [JsonConverter(TJObjectConverter)]
    FContent: TJObject;
    [JsonName('type')]
    FType: string;
    function GetEventType: TEventType;
  public
    constructor Create;
    destructor Destroy; override;
    /// <summary>
    /// Required: The body of this event, as created by the client which sent it.
    /// </summary>
    property Content: TJObject read FContent write FContent;
    /// <summary>
    /// Required: The type of the event.
    /// </summary>
    property EventType: TEventType read GetEventType;
  end;

implementation

constructor TBaseEvent.Create;
begin
  inherited Create;
  FContent := TJObject.Create();
end;

destructor TBaseEvent.Destroy;
begin
  FContent.Free;
  inherited Destroy;
end;

function TBaseEvent.GetEventType: TEventType;
begin
  if FType = 'm.room.canonical_alias' then
    Result := TEventType.CanonicalAlias
  else if FType = 'm.room.create' then
    Result := TEventType.Create
  else if FType = 'm.room.join_rules' then
    Result := TEventType.JoinRules
  else if FType = 'm.room.member' then
    Result := TEventType.Member
  else if FType = 'm.room.power_levels' then
    Result := TEventType.PowerLevels
  else if FType = 'm.room.message' then
    Result := TEventType.Message
  else
    Result := TEventType.Unknown;
end;

end.
