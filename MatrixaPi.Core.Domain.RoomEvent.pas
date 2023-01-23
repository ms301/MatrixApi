unit MatrixaPi.Core.Domain.RoomEvent;

interface

uses
  MatrixaPi.Types.Response,
  MatrixaPi.Core.Infrastructure.Dto.Sync.Event.Room;

type
  TBaseRoomEvent = class
  private
    FRoomId: string;
    FSenderUserId: string;
  public
    constructor Create(const ARoomId, ASenderUserId: string); virtual;
    property RoomId: string read FRoomId write FRoomId;
    property SenderUserId: string read FSenderUserId write FSenderUserId;
  end;

  TJoinRoomEvent = class(TBaseRoomEvent)
  public type
    Factory = class
      class function TryCreateFrom(ARoomEvent: TRoomEvent; const ARoomId: string;
        var AJoinRoomEvent: TJoinRoomEvent): Boolean;
      class function TryCreateFromStrippedState(ARoomStrippedState: TRoomStrippedState; ARoomId: string;
        out AJoinRoomEvent: TJoinRoomEvent): Boolean;
    end;
  public
    constructor Create(const ARoomId, ASenderUserId: string); override;
    property RoomId;
    property SenderUserId;
  end;

  TCreateRoomEvent = class(TBaseRoomEvent)
  private
    FRoomCreatorUserId: string;
  public type
    Factory = class
      class function TryCreateFrom(ARoomEvent: TRoomEvent; ARoomId: string;
        out ACreateRoomEvent: TCreateRoomEvent): Boolean;
      class function TryCreateFromStrippedState(ARoomStrippedState: TRoomStrippedState; ARoomId: string;
        out ACreateRoomEvent: TCreateRoomEvent): Boolean;
    end;
  public
    constructor Create(const ARoomId, ASenderUserId, ARoomCreatorUserId: string); reintroduce;
    property RoomId;
    property SenderUserId;
    property RoomCreatorUserId: string read FRoomCreatorUserId write FRoomCreatorUserId;
  end;

  TInviteToRoomEvent = class(TBaseRoomEvent)
  public type
    Factory = class
      class function TryCreateFrom(ARoomEvent: TRoomEvent; ARoomId: string;
        out AInviteToRoomEvent: TInviteToRoomEvent): Boolean;
      class function TryCreateFromStrippedState(ARoomStrippedState: TRoomStrippedState; ARoomId: string;
        out AInviteToRoomEvent: TInviteToRoomEvent): Boolean;
    end;
  public
    constructor Create(const ARoomId: string; const ASenderUserId: string); override;
  end;

  TNameRoomEvent = class(TBaseRoomEvent)
  public type
    Factory = class
      class function TryCreateFrom(ARoomEvent: TRoomEvent; ARoomId: string; out ANameRoomEvent: TNameRoomEvent)
        : Boolean;
    end;
  private
    FName: string;
  public
    constructor Create(const ARoomId, ASenderUserId, AName: string); reintroduce;
    property Name: string read FName write FName;
  end;

  TTopicRoomEvent = class(TBaseRoomEvent)
  public type
    Factory = class
      class function TryCreateFrom(ARoomEvent: TRoomEvent; ARoomId: string;
        out ATopicRoomEvent: TTopicRoomEvent): Boolean;
    end;
  private
    FTopic: string;
  public
    constructor Create(const ARoomId, ASenderUserId, ATopic: string); reintroduce;
    property Topic: string read FTopic write FTopic;
  end;

  TTextMessageEvent = class(TBaseRoomEvent)
  private
    FMessage: string;
  public type
    Factory = class
      class function TryCreateFrom(ARoomEvent: TRoomEvent; ARoomId: string;
        out ATextMessageEvent: TTextMessageEvent): Boolean;
      class function TryCreateFromStrippedState(ARoomStrippedState: TRoomStrippedState; ARoomId: string;
        out ATextMessageEvent: TTextMessageEvent): Boolean;
    end;
  public
    constructor Create(const ARoomId, ASenderUserId, AMessage: string); reintroduce;
    property Message: string read FMessage write FMessage;
  end;

implementation

uses
  System.JSON.Serializers,
  MatrixaPi.RoomEvent.RoomMemberContent,
  MatrixaPi.Core.Infrastructure.Dto.Sync.Event,
  MatrixaPi.Core.Infrastructure.Dto.Sync.Event.Room.State,
  MatrixaPi.Core.Infrastructure.Dto.Sync.Event.Room.Messaging,
  MatrixaPi.Core.Infrastructure.Dto.Sync.Event.Room.Topic;

{TBaseRoomEvent}
constructor TBaseRoomEvent.Create(const ARoomId, ASenderUserId: string);
begin
  inherited Create;
  FRoomId := ARoomId;
  FSenderUserId := ASenderUserId;
end;

{TJoinRoomEvent}
class function TJoinRoomEvent.Factory.TryCreateFrom(ARoomEvent: TRoomEvent; const ARoomId: string;
  var AJoinRoomEvent: TJoinRoomEvent): Boolean;
var
  LContent: TRoomMemberContent;
begin
  LContent := ARoomEvent.Content.ToObject<TRoomMemberContent>;
  try
    Result := (ARoomEvent.EventType = TEventType.Member) and (LContent.Membership = TUserMembershipState.Join);
    if Result then
      AJoinRoomEvent := TJoinRoomEvent.Create(ARoomId, ARoomEvent.Sender)
    else
      AJoinRoomEvent := nil{TJoinRoomEvent.Create(string.Empty, string.Empty)};
  finally
    LContent.Free;
  end;
end;

constructor TJoinRoomEvent.Create(const ARoomId, ASenderUserId: string);
begin
  inherited Create(ARoomId, ASenderUserId);
end;

{TCreateRoomEvent}
constructor TCreateRoomEvent.Create(const ARoomId, ASenderUserId, ARoomCreatorUserId: string);
begin
  inherited Create(ARoomId, ASenderUserId);
  FRoomCreatorUserId := ARoomCreatorUserId;
end;

{ TCreateRoomEvent.Factory }

class function TCreateRoomEvent.Factory.TryCreateFrom(ARoomEvent: TRoomEvent; ARoomId: string;
  out ACreateRoomEvent: TCreateRoomEvent): Boolean;
var
  LContent: TRoomCreateContent;
begin
  LContent := ARoomEvent.Content.ToObject<TRoomCreateContent>;
  try
    Result := (ARoomEvent.EventType = TEventType.Create) and Assigned(LContent);
    if Result then
      ACreateRoomEvent := TCreateRoomEvent.Create(ARoomId, ARoomEvent.Sender, LContent.Creator);
  finally
    LContent.Free;
  end;
end;

class function TCreateRoomEvent.Factory.TryCreateFromStrippedState(ARoomStrippedState: TRoomStrippedState;
  ARoomId: string; out ACreateRoomEvent: TCreateRoomEvent): Boolean;
var
  LContent: TRoomCreateContent;
begin
  LContent := ARoomStrippedState.Content.ToObject<TRoomCreateContent>;
  try
    Result := (ARoomStrippedState.EventType = TEventType.Create) and Assigned(LContent);
    if Result then
      ACreateRoomEvent := TCreateRoomEvent.Create(ARoomId, ARoomStrippedState.Sender, LContent.Creator);
  finally
    LContent.Free;
  end;
end;

{ TInviteToRoomEvent }

constructor TInviteToRoomEvent.Create(const ARoomId, ASenderUserId: string);
begin
  inherited Create(ARoomId, ASenderUserId);
end;

{ TInviteToRoomEvent.Factory }

class function TInviteToRoomEvent.Factory.TryCreateFrom(ARoomEvent: TRoomEvent; ARoomId: string;
  out AInviteToRoomEvent: TInviteToRoomEvent): Boolean;
var
  LContent: TRoomMemberContent;
begin
  LContent := ARoomEvent.Content.ToObject<TRoomMemberContent>;
  try
    if (ARoomEvent.EventType = TEventType.Member) and (LContent.Membership = TUserMembershipState.Invite) then
    begin
      AInviteToRoomEvent := TInviteToRoomEvent.Create(ARoomId, ARoomEvent.Sender);
      Result := True;
    end
    else
    begin
      AInviteToRoomEvent := nil;
      Result := False;
    end;
  finally
    LContent.Free;
  end;
end;

class function TInviteToRoomEvent.Factory.TryCreateFromStrippedState(ARoomStrippedState: TRoomStrippedState;
  ARoomId: string; out AInviteToRoomEvent: TInviteToRoomEvent): Boolean;
var
  LContent: TRoomMemberContent;
begin
  LContent := ARoomStrippedState.Content.ToObject<TRoomMemberContent>;
  try
    if (ARoomStrippedState.EventType = TEventType.Member) and (LContent.Membership = TUserMembershipState.Invite) then
    begin
      AInviteToRoomEvent := TInviteToRoomEvent.Create(ARoomId, ARoomStrippedState.Sender);
      Result := True;
    end
    else
    begin
      AInviteToRoomEvent := nil;
      Result := False;
    end;
  finally
    LContent.Free;
  end;
end;

constructor TTextMessageEvent.Create(const ARoomId, ASenderUserId, AMessage: string);
begin
  inherited Create(ARoomId, ASenderUserId);
  FMessage := AMessage;
end;

{ TTextMessageEvent.Factory }

class function TTextMessageEvent.Factory.TryCreateFrom(ARoomEvent: TRoomEvent; ARoomId: string;
  out ATextMessageEvent: TTextMessageEvent): Boolean;
var
  LContent: TMessageContent;
begin
  LContent := ARoomEvent.Content.ToObject<TMessageContent>;
  if (ARoomEvent.EventType = TEventType.Message) and (LContent.&Type = TMessageType.Text) then
  begin
    ATextMessageEvent := TTextMessageEvent.Create(ARoomId, ARoomEvent.Sender, LContent.Body);
    Result := True;
  end
  else
  begin
    ATextMessageEvent := nil;
    Result := False;
  end;
end;

class function TJoinRoomEvent.Factory.TryCreateFromStrippedState(ARoomStrippedState: TRoomStrippedState;
  ARoomId: string; out AJoinRoomEvent: TJoinRoomEvent): Boolean;
var
  LContent: TRoomMemberContent;
begin
  LContent := ARoomStrippedState.Content.ToObject<TRoomMemberContent>;
  if (ARoomStrippedState.EventType = TEventType.Member) and (LContent.Membership = TUserMembershipState.Join) then
  begin
    AJoinRoomEvent := TJoinRoomEvent.Create(ARoomId, ARoomStrippedState.Sender);
    Result := True;
  end
  else
  begin
    AJoinRoomEvent := nil;
    Result := False;
  end;

end;

class function TTextMessageEvent.Factory.TryCreateFromStrippedState(ARoomStrippedState: TRoomStrippedState;
  ARoomId: string; out ATextMessageEvent: TTextMessageEvent): Boolean;
var
  LContent: TMessageContent;
begin
  LContent := ARoomStrippedState.Content.ToObject<TMessageContent>;
  try
    Result := (ARoomStrippedState.EventType = TEventType.Message) and (LContent.&Type = TMessageType.Text);
    if Result then
      ATextMessageEvent := TTextMessageEvent.Create(ARoomId, ARoomStrippedState.Sender, LContent.Body);
  finally
    LContent.Free;
  end;
end;

{ TNameRoomEvent.Factory }

class function TNameRoomEvent.Factory.TryCreateFrom(ARoomEvent: TRoomEvent; ARoomId: string;
  out ANameRoomEvent: TNameRoomEvent): Boolean;
var
  LContent: TRoomNameContent;
begin
  LContent := ARoomEvent.Content.ToObject<TRoomNameContent>;
  try
    Result := (ARoomEvent.EventType = TEventType.Name) and Assigned(LContent);
    if Result then
      ANameRoomEvent := TNameRoomEvent.Create(ARoomId, ARoomEvent.Sender, LContent.Name);
  finally
    LContent.Free;
  end;
end;

constructor TNameRoomEvent.Create(const ARoomId, ASenderUserId, AName: string);
begin
  inherited Create(ARoomId, ASenderUserId);
  FName := AName;
end;

{ TTopicRoomEvent }

constructor TTopicRoomEvent.Create(const ARoomId, ASenderUserId, ATopic: string);
begin
  inherited Create(ARoomId, ASenderUserId);
  FTopic := ATopic;
end;

{ TTopicRoomEvent.Factory }

class function TTopicRoomEvent.Factory.TryCreateFrom(ARoomEvent: TRoomEvent; ARoomId: string;
  out ATopicRoomEvent: TTopicRoomEvent): Boolean;
var
  LContent: TTopicContent;
begin
  LContent := ARoomEvent.Content.ToObject<TTopicContent>;
  try
    Result := (ARoomEvent.EventType = TEventType.Topic) and Assigned(LContent);
    if Result then
      ATopicRoomEvent := TTopicRoomEvent.Create(ARoomId, ARoomEvent.Sender, LContent.Topic);
  finally
    LContent.Free;
  end;
end;

end.
