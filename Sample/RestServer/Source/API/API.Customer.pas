unit API.Customer;

interface

uses
  SysUtils,
  API.Utils,
  Express,
  XSuperObject,
  Windows,
  Generics.Collections,
  Model.Customer;

type
  [Location('api/v1/customers')]
  TCustomers = class(TProvider)
  public
    [GET] [DEFAULT]
    function Customers: TArray<TCustomer>;

    [PUT]
    procedure Update(CustomerId: Integer; Content: TCustomer);

    [POST]
    function Insert(CustomerId: Integer; Content: TCustomer): TResponse<Integer>;

    [DELETE]
    procedure Delete(CustomerId: Integer);
  end;

implementation

{ TCustomers }

function TCustomers.Customers: TArray<TCustomer>;
var
  I: Integer;
begin
  SetLength(Result, CustomerData.Count);
  for I := 0 to CustomerData.Count - 1 do
      Result[I] := CustomerData.List[I]^;
end;


procedure TCustomers.Delete(CustomerId: Integer);
begin
  CustomerData.DeleteCustomer(CustomerId);
end;

function TCustomers.Insert(CustomerId: Integer; Content: TCustomer): TResponse<Integer>;
var
  Customer: PCustomer;
begin
  Customer := CustomerData.New;
  Customer.Id := GetTickCount;
  Customer.Name := Content.Name;
  Result.Success := True;
  Result.Data := Customer.Id;
end;

procedure TCustomers.Update(CustomerId: Integer; Content: TCustomer);
var
  Customer: PCustomer;
begin
  Customer := CustomerData.Search(CustomerId);
  if not Assigned(Customer) then Exit;
  EnterCriticalSection(CriticalSection);
  try
    Customer.Id := Content.Id;
    Customer.Name := Content.Name;
  finally
    LeaveCriticalSection(CriticalSection);
  end;
end;

initialization
  TClassManager.Register(TCustomers);

end.
