// JCL_DEBUG_EXPERT_GENERATEJDBG OFF
// JCL_DEBUG_EXPERT_INSERTJDBG OFF
program RestServer;
{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Winapi.Windows,
  IdHTTPWebBrokerBridge,
  Web.WebReq,
  Web.WebBroker,
  WebModuleUnit1 in 'Source\WebModuleUnit1.pas' {WebModule1: TWebModule},
  API.Login in 'Source\API\API.Login.pas',
  API.Customer in 'Source\API\API.Customer.pas',
  API.Utils in 'Source\API.Utils.pas',
  Model.Customer in 'Source\API\Model\Model.Customer.pas',
  API.LInject.Login in 'Source\API\Inject\API.LInject.Login.pas',
  API.CustomerDetail in 'Source\API\API.CustomerDetail.pas';

{$R *.res}

procedure RunServer(APort: Integer);
var
  LInputRecord: TInputRecord;
  LEvent: DWord;
  LHandle: THandle;
  LServer: TIdHTTPWebBrokerBridge;
begin
  Writeln(Format('Starting HTTP Server or port %d', [APort]));
  LServer := TIdHTTPWebBrokerBridge.Create(nil);
  try
    LServer.DefaultPort := APort;
    LServer.Active := True;
    Writeln('Press ESC to stop the server');
    LHandle := GetStdHandle(STD_INPUT_HANDLE);
    while True do
    begin
      Win32Check(ReadConsoleInput(LHandle, LInputRecord, 1, LEvent));
      if (LInputRecord.EventType = KEY_EVENT) and
      LInputRecord.Event.KeyEvent.bKeyDown and
      (LInputRecord.Event.KeyEvent.wVirtualKeyCode = VK_ESCAPE) then
        break;
    end;
  finally
    LServer.Free;
  end;
end;

begin
  try
  if WebRequestHandler <> nil then
    WebRequestHandler.WebModuleClass := WebModuleClass;
    RunServer(8080);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end
end.
