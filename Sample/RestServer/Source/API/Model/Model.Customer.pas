unit Model.Customer;

interface

uses
  SysUtils,
  Windows,
  Generics.Collections;

type
  PCustomerDetail = ^TCustomerDetail;
  TCustomerDetail = record
    Id: Integer;
    CustomerId: Integer;
    Address: String;
    EMail: String;
    Phone: String;
  end;

  PCustomer = ^TCustomer;
  TCustomer = record
    Id: Integer;
    Name: String;
    [DISABLE] Detail: TArray<TCustomerDetail>;
    function DetailIndexOf(const Id: Integer): Integer;
    function SearchDetail(const Id: Integer): PCustomerDetail;
    procedure RemoveDetail(const Id: Integer);
  end;

  TCustomerData = class(TList<PCustomer>)
  public
    function CustomerIndexOf(const Id: Integer): Integer;
    function Search(const Id: Integer): PCustomer;
    function New: PCustomer;
    procedure DeleteCustomer(const Id: Integer);
  end;

var
  CustomerData: TCustomerData;
  CriticalSection: TRTLCriticalSection;

implementation

procedure FinalizeCustomerList;
var
  I: Integer;
begin
  for I := 0 to CustomerData.Count - 1 do
      Dispose(CustomerData.List[I]);
  CustomerData.Free;
end;

procedure InitCustomerList;
var
  I: Integer;
  Customer: PCustomer;
begin
  CustomerData := TCustomerData.Create;
  for I := 1 to 3 do begin
      Customer := CustomerData.New;
      Customer.Id := I;
      Customer.Name := 'Customer ' + I.ToString;

      SetLength(Customer.Detail, 1);
      with Customer.Detail[0] do begin
           Id := 1;
           CustomerId := I;
           Address := 'Address of Customer ' + I.ToString;
           EMail := 'Email of Customer ' + I.ToString;
           Phone := 'Phone of Customer ' + I.ToString;
      end;
  end;
end;

{ TCustomerList }

function TCustomerData.CustomerIndexOf(const Id: Integer): Integer;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
      if List[I].Id = Id   then
         Exit(I);
  Result := -1;
end;

procedure TCustomerData.DeleteCustomer(const Id: Integer);
var
  I: Integer;
begin
  EnterCriticalSection(CriticalSection);
  try
    I := CustomerIndexOf(Id);
    if I > -1 then
       Delete(I);
  finally
    LeaveCriticalSection(CriticalSection);
  end;
end;

function TCustomerData.New: PCustomer;
var
  Customer: PCustomer;
begin
  System.New(Customer);
  EnterCriticalSection(CriticalSection);
  try
    Add(Customer);
  finally
    LeaveCriticalSection(CriticalSection);
  end;
  Result := Customer;
end;

function TCustomerData.Search(const Id: Integer): PCustomer;
var
  I: Integer;
begin
  I := CustomerIndexOf(Id);
  if I < 0 then
     Result := Nil
  else Result := List[I];
end;

{ TCustomer }
function TCustomer.DetailIndexOf(const Id: Integer): Integer;
var
  I: Integer;
begin
  for I := 0 to High(Detail) do
      if Detail[I].Id = Id then
         Exit(I);
  Result := -1;
end;

procedure TCustomer.RemoveDetail(const Id: Integer);
var
  Index: Integer;
  ALength: Cardinal;
  TailElements: Cardinal;
begin
  Index := DetailIndexOf(Id);
  if Index = -1 then Exit;
  ALength := Length(Detail);
  Finalize(Detail[Index]);
  TailElements := ALength - Index;
  if TailElements > 0 then
    Move(Detail[Index + 1], Detail[Index], SizeOf(TCustomerDetail) * TailElements);
  Initialize(Detail[ALength - 1]);
  SetLength(Detail, ALength - 1);
end;

function TCustomer.SearchDetail(const Id: Integer): PCustomerDetail;
var
  I: Integer;
begin
  I := DetailIndexOf(Id);
  if I > -1 then
     Result := @Detail[I]
  else Result := Nil;
end;

initialization
  InitializeCriticalSection(CriticalSection);
  InitCustomerList;

finalization
  DeleteCriticalSection(CriticalSection);
  FinalizeCustomerList;


end.
