unit Test.Main;

interface

uses
  Matrix.Client,
  Matrix.Types.Response,
  DUnitX.TestFramework;

type

  [TestFixture]
  TMatrixaPiTest = class
  strict private
    FCli: TMatrixaPi;
    FAccessToken: string;
  protected
    procedure CheckUniversal(AError: TmtrError; AHttpResponse: IHTTPResponse);
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestVersions;
    [Test()]
    procedure TestLogin;
    [Test(False)] {    // UNSUPPORTED}
    procedure ServerDiscoveryInformation;
    [Test(False)]
    procedure CreateRoom;
    [Test(true)]
    procedure Sync;
  end;

implementation

uses
  Matrix.Types.Requests;

procedure TMatrixaPiTest.CheckUniversal(AError: TmtrError; AHttpResponse: IHTTPResponse);
begin
  if Assigned(AError) then
    Assert.IsEmpty(AError.ErrorCode, AError.Error);
  Assert.AreEqual(200, AHttpResponse.StatusCode, AHttpResponse.StatusText);
end;

procedure TMatrixaPiTest.CreateRoom;
var
  LRoomBuilder: TmtxCreateRoomRequest;
  LData: string;
begin
  LRoomBuilder := TmtxCreateRoomRequest.Create;
  try
    LRoomBuilder.SetName('Limon room');
    LData := LRoomBuilder.JsonAsString;
  finally
    LRoomBuilder.Free;
  end;
  FCli.CreateRoom(LData,
    procedure(ARoomId: string; AHttp: IHTTPResponse)
    begin
      CheckUniversal(nil, AHttp);
    end);
end;

procedure TMatrixaPiTest.ServerDiscoveryInformation;
begin
  FCli.ServerDiscoveryInformation(
    procedure(AWelKnown: TmtrWelKnown; AHttpResp: IHTTPResponse)
    begin
      // CheckUniversal(AWelKnown, AHttpResp);
      // Assert.AreNotEqual(0, AVersion.UnstableFutures.Count);
      // Assert.AreNotEqual(0, Length(AVersion.Versions));
      AWelKnown.Free;
    end);
end;

procedure TMatrixaPiTest.Setup;
begin
  FCli := TMatrixaPi.Create('https://matrix-client.matrix.org');
  FCli.Authenticator.AccessToken := FAccessToken;
end;

procedure TMatrixaPiTest.Sync;
begin
  FCli.Sync(
    procedure(ASync: TmtrSync; AHttpResp: IHTTPResponse)
    begin
      CheckUniversal(ASync, AHttpResp);
    end);
end;

procedure TMatrixaPiTest.TearDown;
begin
  FCli.Free;
  FCli := nil;
end;

procedure TMatrixaPiTest.TestLogin;
begin
  FCli.LoginWithPassword('badbadlimon', 'badbadlimon1',
    procedure(ALogin: TmtrLogin; AHttpResp: IHTTPResponse)
    begin
      CheckUniversal(ALogin, AHttpResp);
      Assert.IsNotEmpty(ALogin.AccessToken);
      FAccessToken := ALogin.AccessToken;
      ALogin.Free;
    end);
end;

procedure TMatrixaPiTest.TestVersions;
begin
  FCli.ClientVersions(
    procedure(AVersion: TmtrVersions; AHttpResp: IHTTPResponse)
    begin
      CheckUniversal(AVersion, AHttpResp);
      Assert.AreNotEqual(0, AVersion.UnstableFutures.Count);
      Assert.AreNotEqual(0, Length(AVersion.Versions));
      AVersion.Free;
    end);
end;

initialization

TDUnitX.RegisterTestFixture(TMatrixaPiTest);

//finalization
//
//IsConsole := False;

end.
