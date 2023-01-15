unit MatrixaPi.Core.Infrastructure.Dto.Sync.Event;

interface

uses
  Citrus.Json.Converters,
  System.Json,
  System.Json.Serializers,
  System.Json.Converters;

type
{$SCOPEDENUMS ON}
  TEventType = (Unknown, Create, Member, Message);
{$SCOPEDENUMS OFF}

  TBaseEvent = class
  private
    [JsonName('content')]
    [JsonConverter(TJsonToJsonObjectConverter)]
    FContent: TJSONObject;
    [JsonName('type')]
    [JsonConverter(TJsonEnumNameConverter)]
    FEventType: TEventType;
  public
    /// <summary>
    /// Required: The body of this event, as created by the client which sent it.
    /// </summary>
    property Content: TJSONObject read FContent write FContent;
    /// <summary>
    /// Required: The type of the event.
    /// </summary>
    property EventType: TEventType read FEventType write FEventType;
  end;

implementation

end.
