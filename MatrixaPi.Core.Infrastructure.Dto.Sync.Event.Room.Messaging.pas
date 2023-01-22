unit MatrixaPi.Core.Infrastructure.Dto.Sync.Event.Room.Messaging;

interface

type
  TMessageType = (Text, Unknown);

  TMessageContent = class
  private
    FBody: string;
    FMsgType: string;
  public
    property Body: string read FBody write FBody;
    property MsgType: string read FMsgType write FMsgType;
    function &Type: TMessageType;
  end;

implementation

{ TMessageContent }

function TMessageContent.&Type: TMessageType;
begin
  if MsgType = 'm.text' then
    Result := TMessageType.Text
  else
    Result := TMessageType.Unknown;
end;

end.
