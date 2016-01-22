unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Express.CrudDataSet, Vcl.Grids, Vcl.DBGrids, Vcl.ExtCtrls,
  XSuperObject;

type
  TMainFrm = class(TForm)
    ExpressConnection1: TExpressConnection;
    DBGrid1: TDBGrid;
    CustomerDSet: TCRUDDataSet;
    CustomerDSrc: TDataSource;
    CustomerDSetId: TLargeintField;
    CustomerDSetName: TWideStringField;
    CustomerDetailsDSet: TCRUDDataSet;
    CustomerDetailsDSrc: TDataSource;
    CustomerDetailsDSetId: TLargeintField;
    CustomerDetailsDSetCustomerId: TLargeintField;
    CustomerDetailsDSetAddress: TWideStringField;
    CustomerDetailsDSetEMail: TWideStringField;
    CustomerDetailsDSetPhone: TWideStringField;
    DBGrid2: TDBGrid;
    Splitter1: TSplitter;
    procedure FormCreate(Sender: TObject);
    procedure CustomerDetailsDSetCrudAfterPost(DataSet: TCRUDDataSet; var Request, Response: ISuperObject);
    procedure CustomerDSetCrudAfterPost(DataSet: TCRUDDataSet; var Request, Response: ISuperObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Login;
  end;

  TResponse<T> = record
    Success: Boolean;
    Data: T;
  end;

var
  MainFrm: TMainFrm;

implementation

{$R *.dfm}

procedure TMainFrm.CustomerDetailsDSetCrudAfterPost(DataSet: TCRUDDataSet; var Request, Response: ISuperObject);
begin
  DataSet.FieldByName('id').AsInteger := Response.I['Data'];
end;

procedure TMainFrm.CustomerDSetCrudAfterPost(DataSet: TCRUDDataSet; var Request, Response: ISuperObject);
begin
  DataSet.FieldByName('id').AsInteger := Response.I['Data'];
end;

procedure TMainFrm.FormCreate(Sender: TObject);
begin
  Login;
end;

procedure TMainFrm.Login;
var
  Response: TResponse<String>;
begin
  Response := ExpressConnection1.Get<TResponse<String>>('api/login/test/test');
  if not Response.Success then
     ShowMessage(Response.Data)
  else begin
     CustomerDSet.Open;
     CustomerDetailsDSet.Open;
  end;
end;

end.
