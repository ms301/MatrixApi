unit MatrixaPi.Core.Infrastructure.Dto.Room.Joined;

interface

uses
  System.JSON.Serializers;

type
  TJoinedRoomsResponse = class
  private
    [JsonName('joined_rooms')]
    FJoinedRooms: TArray<string>;
  public
    /// <summary>
    ///     <b>Required.</b> The ID of each room in which the user has joined membership.
    /// </summary>
    property JoinedRooms: TArray<string> read FJoinedRooms write FJoinedRooms;
  end;

implementation

end.
