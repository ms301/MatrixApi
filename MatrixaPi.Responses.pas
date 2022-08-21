unit MatrixaPi.Responses;

interface

uses
  System.Generics.Collections,
  System.Json.Converters,
  System.Json.Serializers;

type
  IMatrixResponse = interface
    ['{D0A931E2-356F-4703-B6DA-E6CA6C5A6EF9}']
    //  private
    function GetError: string;
    function GetErrorCode: string;
    //  public
    property ErrorCode: string read GetErrorCode;
    property Error: string read GetError;
  end;

  TMatrixResponse = class(TInterfacedObject, IMatrixResponse)
  private
    [JsonName('error')]
    FError: string;
    [JsonName('errcode')]
    FErrorCode: string;
    function GetError: string;
    function GetErrorCode: string;
  public
    property ErrorCode: string read GetErrorCode;
    property Error: string read GetError;
  end;

  TVersionResponse = class(TMatrixResponse)
  private type
    TJsonStringBooleanDictionaryConverter = class(TJsonStringDictionaryConverter<Boolean>);
  private
    [JsonName('versions')]
    FVersions: TArray<string>;
    [JsonName('unstable_features')]
    [JsonConverter(TJsonStringBooleanDictionaryConverter)]
    FUnstableFeatures: TDictionary<string, Boolean>;
  public
    constructor Create;
    destructor Destroy; override;
    property Versions: TArray<string> read FVersions write FVersions;
    property UnstableFeatures: TDictionary<string, Boolean> read FUnstableFeatures;
  end;

implementation

{ TVersionResponse }

constructor TVersionResponse.Create;
begin
  FUnstableFeatures := TDictionary<string, Boolean>.Create;
end;

destructor TVersionResponse.Destroy;
begin
  FUnstableFeatures.Free;
  inherited;
end;

{ TMatrixResponse }

function TMatrixResponse.GetError: string;
begin
  Result := FError;
end;

function TMatrixResponse.GetErrorCode: string;
begin
  Result := FErrorCode;
end;

end.
