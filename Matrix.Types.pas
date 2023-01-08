unit Matrix.Types;

interface

uses
  System.Generics.Collections,
  System.SysUtils;

type
  EMatrixError = class(Exception)

  end;
{$SCOPEDENUMS ON}

  TMatrixRoomStatus = (Joined, Invited, Left, Unknown);
{$SCOPEDENUMS OFF}

  TMatrixRoom = class
  private
    FId: string;
    FStatus: TMatrixRoomStatus;
    FJoinedUserIds: TList<string>;
  public
    constructor Create(const AId: string; const AStatus: TMatrixRoomStatus; AJoinedUserIds: TArray<string>); overload;
    constructor Create(const AId: string; const AStatus: TMatrixRoomStatus); overload;
    destructor Destroy; override;

    property Id: string read FId write FId;
    property Status: TMatrixRoomStatus read FStatus write FStatus;
    property JoinedUserIds: TList<string> read FJoinedUserIds write FJoinedUserIds;
  end;

implementation

constructor TMatrixRoom.Create(const AId: string; const AStatus: TMatrixRoomStatus; AJoinedUserIds: TArray<string>);
begin
  inherited Create;
  FJoinedUserIds := TList<string>.Create();
  FId := AId;
  FStatus := AStatus;
  FJoinedUserIds.AddRange(AJoinedUserIds);
end;

constructor TMatrixRoom.Create(const AId: string; const AStatus: TMatrixRoomStatus);
begin
  Create(AId, AStatus, nil);
end;

destructor TMatrixRoom.Destroy;
begin
  FJoinedUserIds.Free;
  inherited Destroy;
end;

end.
