unit API.CustomerDetail;

interface

uses
  SysUtils,
  API.Utils,
  Express,
  XSuperObject,
  Windows,
  Generics.Collections,
  API.Customer.Model;

type
  [Location('api/v1/customerdetails')]
  TCustomers = class(TProvider)
  public
    [GET] [DEFAULT]
    function Detail(const CustomerId: Integer): TArray<TCustomerDetail>;

    [PUT]
    procedure Update(DetailId: Integer; Content: TCustomer);

    [POST]
    function Insert(CustomerId, Id: Integer; Content: TCustomer): TResponse<Integer>;

    [DELETE]
    procedure Delete(CustomerId, Id: Integer);
  end;

implementation

{ TCustomers }

procedure TCustomers.Delete(CustomerId, Id: Integer);
var
  Customer: PCustomer;
begin
  Customer := CustomerData.Search(CustomerId);
  if not Assigned(Customer) then Exit;
  Customer.RemoveDetail(Id);
end;

function TCustomers.Detail(const CustomerId: Integer): TArray<TCustomerDetail>;
begin

end;

function TCustomers.Insert(CustomerId, Id: Integer; Content: TCustomer): TResponse<Integer>;
var
  Customer: PCustomer;
begin
  Customer := CustomerData.Search(CustomerId);
  if not Assigned(Customer) then Exit;
  Customer.New

end;

procedure TCustomers.Update(DetailId: Integer; Content: TCustomer);
begin

end;

end.
