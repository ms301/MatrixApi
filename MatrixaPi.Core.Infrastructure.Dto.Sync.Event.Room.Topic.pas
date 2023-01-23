unit MatrixaPi.Core.Infrastructure.Dto.Sync.Event.Room.Topic;

interface

uses
  System.JSON.Serializers;

type
  TTopicContent = class
  private
    [JsonName('topic')]
    FTopic: string;
  public
    property Topic: string read FTopic write FTopic;
  end;

implementation

end.
