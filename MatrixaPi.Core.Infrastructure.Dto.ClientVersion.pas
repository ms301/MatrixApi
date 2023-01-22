unit MatrixaPi.Core.Infrastructure.Dto.ClientVersion;

interface

uses
  System.Generics.Collections,
  System.JSON.Serializers,
  System.JSON.Converters;

type
  TmtrVersions = class
  private type
    TJsonUnstableFuturesConverter = class(TJsonStringDictionaryConverter<Boolean>);
  private
    [JsonName('unstable_features')]
    [JsonConverter(TJsonUnstableFuturesConverter)]
    FUnstableFutures: TDictionary<string, Boolean>;
    [JsonName('versions')]
    FVersions: TArray<string>;
  public
    constructor Create;
    destructor Destroy; override;
    property UnstableFutures: TDictionary<string, Boolean> read FUnstableFutures;
    property Versions: TArray<string> read FVersions write FVersions;
  end;

implementation

{ TmtrVersions }
constructor TmtrVersions.Create;
begin
  inherited Create;
  FUnstableFutures := TDictionary<string, Boolean>.Create();
end;

destructor TmtrVersions.Destroy;
begin
  FUnstableFutures.Free;
  inherited Destroy;
end;

end.
