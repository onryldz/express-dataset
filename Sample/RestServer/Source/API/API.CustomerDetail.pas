unit API.CustomerDetail;

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
  [Location('api/v1/customerdetails')]
  TCustomerDetails = class(TProvider)
  public
    [GET] [DEFAULT]
    function Detail(const CustomerId: Integer): TArray<TCustomerDetail>;

    [PUT]
    procedure Update(CustomerId, Id: Integer; Content: TCustomerDetail);

    [POST]
    function Insert(CustomerId, Id: Integer; Content: TCustomerDetail): TResponse<Integer>;

    [DELETE]
    procedure Delete(CustomerId, Id: Integer);
  end;

implementation

{ TCustomers }

procedure TCustomerDetails.Delete(CustomerId, Id: Integer);
var
  Customer: PCustomer;
begin
  Customer := CustomerData.Search(CustomerId);
  if not Assigned(Customer) then Exit;
  Customer.RemoveDetail(Id);
end;

function TCustomerDetails.Detail(const CustomerId: Integer): TArray<TCustomerDetail>;
var
  Customer: PCustomer;
begin
  Customer := CustomerData.Search(CustomerId);
  if not Assigned(Customer) then Exit;
  Result := Customer.Detail;
end;

function TCustomerDetails.Insert(CustomerId, Id: Integer; Content: TCustomerDetail): TResponse<Integer>;
var
  Customer: PCustomer;
begin
  Customer := CustomerData.Search(CustomerId);
  if not Assigned(Customer) then Exit;
  SetLength(Customer.Detail, Length(Customer.Detail) + 1);
  Content.Id := GetTickCount;
  Customer.Detail[High(Customer.Detail)] := Content;
  Result.Success := True;
  Result.Data := Content.Id;
end;

procedure TCustomerDetails.Update(CustomerId, Id: Integer; Content: TCustomerDetail);
var
  Customer: PCustomer;
  DetailIndex: Integer;
begin
  Customer := CustomerData.Search(CustomerId);
  if not Assigned(Customer) then Exit;
  DetailIndex := Customer.DetailIndexOf(Id);
  if DetailIndex > -1 then
     Customer.Detail[DetailIndex] := Content;
end;

initialization
  TClassManager.Register(TCustomerDetails);

end.
