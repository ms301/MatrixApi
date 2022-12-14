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
    [Test(true)]
    procedure CreateRoom;
  end;

implementation

procedure TMatrixaPiTest.CheckUniversal(AError: TmtrError; AHttpResponse: IHTTPResponse);
begin
  if Assigned(AError) then
    Assert.IsEmpty(AError.ErrorCode, AError.Error);
  Assert.AreEqual(200, AHttpResponse.StatusCode, AHttpResponse.StatusText);
end;

procedure TMatrixaPiTest.CreateRoom;
begin
  FCli.Authenticator.AccessToken := FAccessToken;
  FCli.CreateRoom([],
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
