unit API.Login;

interface

uses
  SysUtils,
  API.Utils,
  Express;

type

  [Location('api')]
  TLogin = class(TProvider)
  public
    [GET]
    function login(const UserName, Password: String): TResponse<String>;

    [GET]
    procedure logOut;
  end;

implementation

{ TLogin }

function TLogin.login(const UserName, Password: String): TResponse<String>;
begin
  if (UserName = 'test') and (Password = 'test') then begin
     StartSession;
     Result.Success := True;

  end else begin
     Response.WebResponse.StatusCode := 403;
     Result.Success := False;
     Result.Data := 'Incorrect username or password';
  end;
end;

procedure TLogin.logOut;
begin
  if Request.HasSession then
     EndSession;
end;

initialization
  TClassManager.Register(TLogin);

end.
