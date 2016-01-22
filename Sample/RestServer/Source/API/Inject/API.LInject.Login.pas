unit API.LInject.Login;

interface

uses
  SysUtils,
  Express;

type
  [Location('api')]
  TLoginInject = class(TInject)
  public
    [GET][PUT][POST][DELETE]
    procedure V1;
  end;

implementation

{ TLoginInject }

procedure TLoginInject.V1;
begin
  if not Request.HasSession then begin
     Response.WebResponse.StatusCode := 403;
     Next := False;
  end else Next := True;
end;

initialization
  TClassManager.Register(TLoginInject);

end.
