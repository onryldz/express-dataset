 (*
  *                       Express - DataSet Tools
  *
  * The MIT License (MIT)
  * Copyright (c) 2016 Onur YILDIZ
  *
  *
  * Permission is hereby granted, free of charge, to any person
  * obtaining a copy of this software and associated documentation
  * files (the "Software"), to deal in the Software without restriction,
  * including without limitation the rights to use, copy, modify,
  * merge, publish, distribute, sublicense, and/or sell copies of the Software,
  * and to permit persons to whom the Software is furnished to do so,
  * subject to the following conditions:
  *
  * The above copyright notice and this permission notice shall
  * be included in all copies or substantial portions of the Software.
  *
  * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
  * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
  * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
  * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
  * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
  * THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  *
  *)

unit Express.CrudDataSet;

interface

uses SysUtils, Classes, Variants, DB, DBConsts, Forms, idHTTP, XSuperObject, XSuperJSON, TypInfo, Generics.Collections,
     IdCookieManager, IdCompressorZLib;

{$IF CompilerVersion >= 24.0}
  {$DEFINE DXE3}
{$ENDIF}

{$IF CompilerVersion >= 25.0}
  {$DEFINE DXE4}
{$ENDIF}

{$IF CompilerVersion >= 26.0}
  {$DEFINE DXE5}
{$ENDIF}

{$IF CompilerVersion >= 27.0}
  {$DEFINE DXE6}
{$ENDIF}

{$IF CompilerVersion >= 28.0}
  {$DEFINE DXE7}
{$ENDIF}

{$IF CompilerVersion >= 29.0}
  {$DEFINE DXE8}
{$ENDIF}

{$IF CompilerVersion >= 30.0}
  {$DEFINE D10}
{$ENDIF}

type
  TCRUDDataSet = class;
  TExpressConnection = class;
  TCRUDAPIInfo = class;

  TExpressHttpProtocol = (ehpHttp, ehpHttps);

  TExConBeforeRequest = procedure(Owner: TExpressConnection; DataSet: TCRUDDataSet; Http: TidHttp; const URI: String) of object;
  TExConAfterRequest = procedure(Owner: TExpressConnection; DataSet: TCRUDDataSet; Http: TidHttp; const URI: String; Response: ISuperObject) of object;
  TExpressConnection = class(TComponent)
  private
    FActive: Boolean;
    FServer: String;
    FOnBeforeRequest: TExConBeforeRequest;
    FOnAfterRequest: TExConAfterRequest;
    FProtocol: TExpressHttpProtocol;
    FCookieManager: TidCookieManager;
    FGZip: Boolean;
    procedure DoBeforeRequest(DataSet: TCRUDDataSet; idHttp: TIdHTTP; const URI: String);
    procedure DoAfterRequest(DataSet: TCRUDDataSet; idHttp: TIdHttp; const URI: String; Response: ISuperObject);
    procedure PrepareConnection(CallBack: TProc<TidHttp, TMemoryStream>); overload;
    procedure PrepareConnection(CallBack: TProc<TidHttp, TMemoryStream, TMemoryStream>); overload;
    procedure SetServer(const Value: String);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function URL: String;
    function Get(DataSet: TCRUDDataSet; const URI: String): ISuperObject; overload; virtual;
    function Post(DataSet: TCRUDDataSet; const URI: String; Content: ISuperObject): ISuperObject; overload; virtual;
    function Put(DataSet: TCRUDDataSet; const URI: String; Content: ISuperObject): ISuperObject; overload; virtual;
    function Delete(DataSet: TCRUDDataSet; const URI: String): ISuperObject; overload; virtual;
    function Get<T>(const URI: String): T; overload;
    function Put<Req, Res>(const URI: String; Request: Req): Res; overload;
    function Post<Req, Res>(const URI: String; Request: Req): Res; overload;
    function Delete(const URI: String): ISuperObject; overload;
  published
    property Active: Boolean read FActive write FActive;
    property Server: String read FServer write SetServer;
    property GZip: Boolean read FGZip write FGZip default True;
    property Protocol: TExpressHttpProtocol read FProtocol write FProtocol;
    property OnBeforeRequest: TExConBeforeRequest read FOnBeforeRequest write FOnBeforeRequest;
    property OnAfterRequest: TExConAfterRequest read FOnAfterRequest write FOnAfterRequest;
  end;

  TRecData = packed record
    Data: ISuperObject;
    Temp: ISuperObject;
  end;

  PRecInfo = ^TRecInfo;
  TRecInfo = packed record
    Info: TRecData;
    Bookmark: Integer;
    BookmarkFlag: TBookmarkFlag;
  end;

{ TJSONDataSet }

  TCustomJSONDataSet = class(TDataSet)
  private
    FDataArr: ISuperArray;
    FDataRef: TSuperArray;
    FDataJDef: TJSONArray;
    FRecBufSize: Integer;
    FCurRec: Integer;
    FConnection: TExpressConnection;
    FLastBookmark: Integer;
    FSaveChanges: Boolean;
    FKeyField: String;
  protected
    function AllocRecordBuffer: TRecordBuffer; override;
    procedure FreeRecordBuffer(var Buffer: TRecordBuffer); override;
    procedure GetBookmarkData(Buffer: TRecordBuffer; Data: {$IFDEF DXE3} TBookmark {$ELSE}Pointer{$ENDIF}); override;
    function GetBookmarkFlag(Buffer: TRecordBuffer): TBookmarkFlag; override;
    function GetRecord(Buffer: TRecordBuffer; GetMode: TGetMode; DoCheck: Boolean): TGetResult; override;
    function GetRecordSize: Word; override;
    procedure InternalAddRecord(Buffer: Pointer; Append: Boolean); override;
    procedure InternalClose; override;
    procedure InternalDelete; override;
    procedure InternalFirst; override;
    procedure InternalGotoBookmark(Bookmark: Pointer); override;
    procedure InternalHandleException; override;
    procedure InternalInitFieldDefs; override;
    procedure InternalInitRecord(Buffer: TRecordBuffer); override;
    procedure InternalLast; override;
    procedure InternalOpen; override;
    procedure InternalPost; override;
    procedure InternalInsert; override;
    procedure InternalCancel; override;
    procedure InternalEdit; override;
    procedure InternalSetToRecord(Buffer: TRecordBuffer); override;
    function IsCursorOpen: Boolean; override;
    procedure SetBookmarkFlag(Buffer: TRecordBuffer; Value: TBookmarkFlag); override;
    procedure SetBookmarkData(Buffer: TRecordBuffer; Data: {$IFDEF DXE3} TBookmark {$ELSE}Pointer{$ENDIF}); override;
    procedure SetFieldData(Field: TField; Buffer: {$IFDEF DXE3} TValueBuffer {$ELSE} Pointer {$ENDIF}); override;
  protected
    function GetData: ISuperObject; virtual; abstract;
    function DoLocate(const KeyFields: string; const KeyValues: Variant; Options: TLocateOptions): Integer;
    function GetRecordCount: Integer; override;
    function GetRecNo: Integer; override;
    procedure SetRecNo(Value: Integer); override;
    procedure EnumerateData(CallBack: TProc<ISuperObject>);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function BookmarkValid(Bookmark: TBookmark): Boolean; override;
    function CompareBookmarks(Bookmark1, Bookmark2: TBookmark):Integer; override;
    function GetFieldData(Field: TField; {$IFDEF DXE4} var {$ENDIF} Buffer: {$IFDEF DXE3} TValueBuffer {$ELSE} Pointer {$ENDIF}): Boolean; override;
    function Locate(const KeyFields: string; const KeyValues: Variant; Options: TLocateOptions): Boolean; override;
  published
    property Active;
    property Data: ISuperArray read FDataArr;
    property BeforeOpen;
    property AfterOpen;
    property BeforeClose;
    property AfterClose;
    property BeforeInsert;
    property AfterInsert;
    property BeforeEdit;
    property AfterEdit;
    property BeforePost;
    property AfterPost;
    property BeforeCancel;
    property AfterCancel;
    property BeforeDelete;
    property AfterDelete;
    property BeforeScroll;
    property AfterScroll;
    property BeforeRefresh;
    property AfterRefresh;
    property OnDeleteError;
    property OnEditError;
    property OnFilterRecord;
    property OnNewRecord;
    property OnPostError;
  end;

  TJSONDataSet = class(TCustomJSONDataSet)
  private
    FJSONContent: String;
    FJSONFile: TFileName;
  protected
    function GetData: ISuperObject; override;
  published
    property JSONContent: String read FJSONContent write FJSONContent;
    property JSONFile: TFileName read FJSONFile write FJSONFile;
  end;

  PURIPath = ^TURIPath;
  TURIPath = record
    Name: String;
    IsParam: Boolean;
  end;

  TCRUDUriParams = class(TParams)
  protected
    function ParseURI(const Value: String): TArray<TURIPath>;
  end;

  TCRUDUriType = (utGet, utPut, utPost, utDelete);

  TCRUDUri = class(TPersistent)
  private
    FParams: TCRUDUriParams;
    FURI: String;
    FURIPaths: TArray<TURIPath>;
    FOwner: TCRUDAPIInfo;
    FUriType: TCRUDUriType;
    procedure SetURI(const Value: String);
    procedure SetParams(const Value: TCRUDUriParams);

  protected
    function URL: String; inline;
    function GenerateURI: string; virtual;
    function KeyValue: String; inline;
    procedure AssignTo(Dest: TPersistent); override;

  public
    constructor Create(AOwner: TCRUDAPIInfo; AUriType: TCRUDUriType);
    destructor Destroy; override;
    function Generate: String;

  published
    property URI: String read FURI write SetURI;
    property Params: TCRUDUriParams read FParams write SetParams;
    property Method: TCRUDUriType read FUriType;
  end;

  TCRUDAPIInfo = class(TPersistent)
  private
    FOwner: TCRUDDataSet;
    FPost: TCRUDUri;
    FPut: TCRUDUri;
    FGet: TCRUDUri;
    FDelete: TCRUDUri;

    procedure SetDelete(const Value: TCRUDUri);
    procedure SetGet(const Value: TCRUDUri);
    procedure SetPost(const Value: TCRUDUri);
    procedure SetPut(const Value: TCRUDUri);

  public
    constructor Create(AOwner: TCRUDDataSet);
    destructor Destroy; override;
    procedure AssignTo(Source: TPersistent); override;

  published
    property Get: TCRUDUri read FGet write SetGet;
    property Put: TCRUDUri read FPut write SetPut;
    property Post: TCRUDUri read FPost write SetPost;
    property Delete: TCRUDUri read FDelete write SetDelete;

  end;

  TCRUDDataSetHTTPBeforeNotif = procedure(DataSet: TCRUDDataSet; var Request: ISuperObject) of object;
  TCRUDDataSetHTTPAfterNotif = procedure(DataSet: TCRUDDataSet; var Request, Response: ISuperObject) of object;

  TCRUDDataSet = class(TCustomJSONDataSet)
  private
    FAsync: Boolean;
    FConnection: TExpressConnection;
    FAPIInfo: TCRUDAPIInfo;
    FOnCrudAfterPost: TCRUDDataSetHTTPAfterNotif;
    FOnCrudBeforePost: TCRUDDataSetHTTPBeforeNotif;
    FOnCrudBeforePut: TCRUDDataSetHTTPBeforeNotif;
    FOnCrudAfterPut: TCRUDDataSetHTTPAfterNotif;
    FMaster: TDataSource;
    FMasterLink: TMasterDataLink;
    procedure SetAPI(const Value: TCRUDAPIInfo);
    procedure SetMaster(const Value: TDataSource);
    procedure MasterChanged(Sender: TObject);
  protected
    procedure UpdateMasterFields;
    function GetData: ISuperObject; override;
    procedure UpdateData; virtual;
    function  InsertData(Data: ISuperObject = Nil): ISuperObject; virtual;
    procedure DeleteData; virtual;

    procedure InternalOpen; override;
    procedure InternalPost; override;
    procedure InternalDelete; override;
    procedure InternalRefresh; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Async: Boolean read FAsync write FAsync;
    property API: TCRUDAPIInfo read FAPIInfo write SetAPI;
    property Connection: TExpressConnection read FConnection write FConnection;
    property KeyField: String read FKeyField write FKeyField;
    property Master: TDataSource read FMaster write SetMaster;
    property OnCrudAfterPost: TCRUDDataSetHTTPAfterNotif read FOnCrudAfterPost write FOnCrudAfterPost;
    property OnCrudBeforePost: TCRUDDataSetHTTPBeforeNotif read FOnCrudBeforePost write FOnCrudBeforePost;
    property OnCrudAfterPut: TCRUDDataSetHTTPAfterNotif read FOnCrudAfterPut write FOnCrudAfterPut;
    property OnCrudBeforePut: TCRUDDataSetHTTPBeforeNotif read FOnCrudBeforePut write FOnCrudBeforePut;
  end;

const
  EHTTP_PROTOCOL_STRING: array [TExpressHttpProtocol] of String = ('http://', 'https://');
  URI_TYPE_STRING: array [TCRUDUriType] of string = ('Get', 'Put', 'Post', 'Delete');

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Express', [TJSONDataSet, TCRUDDataSet, TExpressConnection]);
end;

type
  TidHttpHelper = class helper for TidHttp
  public
    procedure Delete(const AURL: String; Response: TStream); overload;
  end;

{ TidHttpHelper }

procedure TidHttpHelper.Delete(const AURL: String; Response: TStream);
begin
  DoRequest(Id_HTTPMethodDelete, AURL, nil, Response, []);
end;

{ TCustomJSONDataSet }

function TCustomJSONDataSet.BookmarkValid(Bookmark: TBookmark): Boolean;
begin
  Result := (Bookmark <> Nil) and (FDataJDef.Count >= PInteger(Bookmark)^);
end;

function TCustomJSONDataSet.CompareBookmarks(Bookmark1, Bookmark2: TBookmark): Integer;
var
  I, X: Integer;
begin
  if Bookmark1 = Nil then I := -1 else I := PInteger(Bookmark1)^;
  if Bookmark2 = Nil then X := -1 else X := PInteger(Bookmark2)^;

  if I <  X then
     Result := -1
  else if I > X then
     Result := 1
  else Result := 0
end;

constructor TCustomJSONDataSet.Create(AOwner: TComponent);
begin
  inherited;
end;

destructor TCustomJSONDataSet.Destroy;
begin
  inherited;
end;

function TCustomJSONDataSet.DoLocate(const KeyFields: string; const KeyValues: Variant; Options: TLocateOptions): Integer;
var
  I, N, J, Z: Integer;
  S, W: String;
  Field: TField;
  Fields: TList<TField>;
  Member: IJSONAncestor;
  pCaseInsensivity, pContains: Boolean;
  Values: Variant;
  JValue: IJSONPair;
begin
  Result := -1;
  I := VarArrayDimCount(KeyValues);
  if I = 0 then begin
     Values := VarArrayCreate([0,0], varVariant);
     Values[0] := KeyValues;
  end else begin
     Values := KeyValues;
  end;


  CheckBrowseMode;
  CursorPosChanged;

  Fields := TList<TField>.Create;
  try
    for S in KeyFields.Split([';']) do
        Fields.Add(FieldByName(S));

    if Fields.Count = 0 then Exit(-1);
    Z := Fields.Count;
    pCaseInsensivity := loCaseInsensitive in Options;
    pContains := loPartialKey in Options;

    for J := 0 to FDataJDef.Count - 1 do
        if FDataJDef.Index[J].DataType = dtObject then begin
           N := 0;
           for I := 0 to Fields.Count - 1 do begin
               JValue := TJSONObject(FDataJDef.Index[J]).Get(Fields.List[I].FieldName);
               if JValue = Nil then Continue;
               S := VarToStr(JValue.JSONValue.AsVariant);
               W := VarToStr(Values[I]);
               if pCaseInsensivity then
                  if CompareText(W, S) = 0 then begin
                     Inc(N);
                     Continue;
                  end;

               if pContains then
                  if W.Contains(S) then begin
                     Inc(N);
                     Continue;
                  end;

               if W = S then
                  Inc(N);
           end;
           if N = Z then
              Exit(J);
        end;
  finally
    Fields.Free;
  end;
end;

procedure TCustomJSONDataSet.InternalOpen;
var
  FData: ISuperObject;
  FDataType: TDataType;
begin
  FData := GetData;
  FDataType := FData.DataType;
  if FDataType = dtArray then begin
     FDataArr := FData.AsArray;
     FLastBookmark := FDataArr.Length;

  end else if FDataType = dtObject then begin
     FLastBookmark := 1;
     FDataArr := SA();
     FDataArr.Add(FData);

  end else
     DataBaseError('Unsupported json data type.');

  FDataRef := TSuperArray(FDataArr);
  FDataJDef := TJSONArray(FDataRef.Self);

  FCurRec := -1;

  FRecBufSize := SizeOf(TRecInfo);
  BookmarkSize :=SizeOf(TRecInfo) - SizeOf(TRecData);
  InternalInitFieldDefs;

  if DefaultFields then CreateFields;

  BindFields(True);
end;

procedure TCustomJSONDataSet.InternalCancel;
var
  Rec: PRecInfo;
begin
  Rec := PRecInfo(ActiveBuffer);
  if Rec.BookmarkFlag = bfInserted then begin
     Dec(FLastBookmark);
     FCurRec := FLastBookmark;
     FDataArr.Delete(FCurRec);
     Rec.Info.Data := Nil;
     Rec.Info.Temp := Nil;
     if FCurRec >= FDataArr.Length then
        Dec(FCurRec);
  end;
end;

procedure TCustomJSONDataSet.InternalClose;
begin
  FDataArr := Nil;
  FDataRef := Nil;
  if DefaultFields then
     DestroyFields;
  FLastBookmark := 0;
  FCurRec := -1;
end;

function TCustomJSONDataSet.IsCursorOpen: Boolean;
begin
  Result := Assigned(FDataRef);
end;

function TCustomJSONDataSet.Locate(const KeyFields: string; const KeyValues: Variant; Options: TLocateOptions): Boolean;
var
  I: Integer;
begin
  DoBeforeScroll;
  I := DoLocate(KeyFields, KeyValues, Options);
  Result := I > -1;
  SetFound(Result);
  if I > -1 then begin
     FCurRec := I;
     Resync([rmExact, rmCenter]);
     DoAfterScroll;
  end;
end;

procedure TCustomJSONDataSet.EnumerateData(CallBack: TProc<ISuperObject>);
var
  Member: IMember;
begin
  if not Assigned(FDataRef) then Exit;
  for Member in FDataRef do
      if Member.DataType = dtObject then
         CallBack(Member.AsObject);
end;

procedure TCustomJSONDataSet.InternalInitFieldDefs;
var
  Field: TField;
begin
  FieldDefs.Clear;
  if Fields.Count > 0 then begin
     for Field in Fields do
         FieldDefs.Add(Field.FieldName, Field.DataType, Field.Size, Field.Required);
     Exit;
  end;

  EnumerateData(procedure(Data: ISuperObject)
  var
     FType: TFieldType;
     Field: TFieldDef;
     Value: String;
  begin
     Data.First;
     while not Data.EoF do
       try
           case Data.CurrentValue.DataType of
             dtString: FType := ftWideString ;
             dtInteger: FType := ftLargeint ;
             dtFloat: FType := ftFloat;
             dtBoolean: FType := ftBoolean;
             dtDateTime: FType := ftDateTime ;
             dtDate: FType := ftDate;
             dtTime: FType := ftTime ;
             else
               FType := ftUnknown;
           end;

           if FType = ftUnknown then
              Continue;

           Field := TFieldDef((FieldDefs as TDefCollection).Find(Data.CurrentKey));
           if not Assigned(Field) then begin
              if FType = ftWideString then begin
                 Value := Data.CurrentValue.AsVariant;
                 FieldDefs.Add(Data.CurrentKey, FType, Length(Value));
              end else FieldDefs.Add(Data.CurrentKey, FType);

           end else begin
              if Field.DataType = ftWideString then begin
                 Value := Data.CurrentValue.AsVariant;
                 if Field.Size < Length(Value) then
                    Field.Size := Length(Value);

              end else if (Field.DataType = ftInteger) and (FType = ftFloat) then
                 Field.DataType := FType

              else if (Field.DataType = ftTime) and (FType = ftDateTime) then
                 Field.DataType := FType

              else if (Field.DataType = ftDate) and (FType = ftDateTime) then
                 Field.DataType := FType;
           end;

       finally
         Data.Next;
       end;
  end);
end;

procedure TCustomJSONDataSet.InternalHandleException;
begin
  Application.HandleException(Self);
end;

procedure TCustomJSONDataSet.InternalGotoBookmark(Bookmark: Pointer);
var
  I, Index: Integer;
begin
  Index := -1;
  if FLastBookmark >= PInteger(Bookmark)^ then
     Index := PInteger(Bookmark)^ - 1
  else
     DataBaseError('Bookmark not found');
  FCurRec := Index;
end;

procedure TCustomJSONDataSet.InternalSetToRecord(Buffer: TRecordBuffer);
begin
  InternalGotoBookmark(@PRecInfo(Buffer).Bookmark);
end;

function TCustomJSONDataSet.GetBookmarkFlag(Buffer: TRecordBuffer): TBookmarkFlag;
begin
  Result := PRecInfo(Buffer).BookmarkFlag;
end;

procedure TCustomJSONDataSet.SetBookmarkFlag(Buffer: TRecordBuffer; Value: TBookmarkFlag);
begin
  PRecInfo(Buffer)^.BookmarkFlag := Value;
end;

procedure TCustomJSONDataSet.GetBookmarkData(Buffer: TRecordBuffer; Data: {$IFDEF DXE3} TBookmark {$ELSE}Pointer{$ENDIF});
begin
  PInteger(Data)^ := PRecInfo(Buffer)^.Bookmark;
end;

procedure TCustomJSONDataSet.SetBookmarkData(Buffer: TRecordBuffer; Data: {$IFDEF DXE3} TBookmark {$ELSE}Pointer{$ENDIF});
begin
  PRecInfo(Buffer)^.Bookmark := PInteger(Data)^;
end;

function TCustomJSONDataSet.GetRecordSize: Word;
begin
  Result := SizeOf(TRecData);
end;

function TCustomJSONDataSet.AllocRecordBuffer: TRecordBuffer;
begin
  GetMem(Result, FRecBufSize);
  FillChar(Result^, FRecBufSize, 0);
end;

procedure TCustomJSONDataSet.FreeRecordBuffer(var Buffer: TRecordBuffer);
begin
  FreeMem(Buffer, FRecBufSize);
end;

function TCustomJSONDataSet.GetRecord(Buffer: TRecordBuffer; GetMode: TGetMode; DoCheck: Boolean): TGetResult;
var
  RInfo: PRecInfo;
begin
  if FDataArr.Length < 1 then
    Result := grEOF else
  begin
    Result := grOK;
    case GetMode of
      gmNext:
        if FCurRec >= RecordCount - 1  then
          Result := grEOF else
          Inc(FCurRec);
      gmPrior:
        if FCurRec <= 0 then
          Result := grBOF else
          Dec(FCurRec);
      gmCurrent:
        if (FCurRec < 0) or (FCurRec >= RecordCount) then
          Result := grError;
    end;
    if Result = grOK then
    begin
      RInfo := PRecInfo(Buffer);
      RInfo.Info.Data := FDataRef.O[FCurRec];
      RInfo.Info.Temp := Nil;
      RInfo.BookmarkFlag := bfCurrent;
      RInfo.Bookmark := FCurRec + 1;
    end else
      if (GetMode = gmCurrent) then Result:=grError;
  end;
end;

procedure TCustomJSONDataSet.InternalInitRecord(Buffer: TRecordBuffer);
begin
  FillChar(Buffer^, RecordSize, 0);
end;

procedure TCustomJSONDataSet.InternalInsert;
var
  R: Integer;
begin
  Inc(FLastBookmark);
  R := RecordCount;
  with PRecInfo(ActiveBuffer)^ do begin
       Info.Data := FDataRef.O[R];
       Info.Temp := Nil;
       Bookmark := FLastBookmark;
       BookmarkFlag := bfInserted;
  end;
end;

type PTime = ^TTime;
function TCustomJSONDataSet.GetFieldData(Field: TField; {$IFDEF DXE4} var {$ENDIF} Buffer: {$IFDEF DXE3} TValueBuffer {$ELSE} Pointer {$ENDIF}): Boolean;
var
  RecData: PRecInfo;
  WStr: WideString;
  Str: AnsiString;
  JSONData: ISuperObject;
begin
  RecData := PRecInfo(ActiveBuffer);
  if not Assigned(RecData.Info.Data) then
     Exit(False);

  if State = dsEdit then
     JSONData := RecData.Info.Temp
  else JSONData := RecData.Info.Data;

  if JSONData = Nil then
     Exit(False);

  Result := True;
  case Field.DataType of
    ftWideString: begin
      WStr := WideString(JSONData.S[Field.FieldName]);
      if Buffer = Nil then
         SetLength(Buffer, Length(WStr) * SizeOf(WideChar));
      Move(WStr[1], Buffer[0], Length(WStr) * SizeOf(WideChar));
    end;

    ftString: begin
      Str := JSONData.S[Field.FieldName];
      if Buffer = Nil then
         SetLength(Buffer, Length(Str) * SizeOf(AnsiChar));
      Move(Str[1], Buffer[0], Length(Str) * SizeOf(AnsiChar));
    end;

    ftInteger: begin
      SetLength(Buffer, SizeOf(Integer));
      PInteger(Buffer)^ := Integer(JSONData.I[Field.FieldName]);
    end;

    ftLargeint: begin
       if Buffer = Nil then
          SetLength(Buffer, SizeOf(Int64));
       PInt64(Buffer)^ := JSONData.I[Field.FieldName];
    end;

    ftFloat: begin
      if Buffer = Nil then
         SetLength(Buffer, SizeOf(Double));
      PDouble(Buffer)^ := JSONData.F[Field.FieldName];
    end;

    ftBoolean: begin
      if Buffer = Nil then
         SetLength(Buffer, SizeOf(Boolean));
      PBoolean(Buffer)^ := JSONData.B[Field.FieldName];
    end;

    ftDateTime: begin
      if Buffer = Nil then
         SetLength(Buffer, SizeOf(TDateTime));
      PDateTime(Buffer)^ := JSONData.D[Field.FieldName];
    end;

    ftDate: begin
      if Buffer = Nil then
         SetLength(Buffer, SizeOf(TDate));
      PDate(Buffer)^ := JSONData.Date[Field.FieldName];
    end;

    ftTime: begin
      if Buffer = Nil then
         SetLength(Buffer, SizeOf(TTime));
      PTime(Buffer)^ := JSONData.Time[Field.FieldName];
    end

    else
      Assert(false, 'Unsupported field type.');
  end;

end;

procedure TCustomJSONDataSet.SetFieldData(Field: TField; Buffer: {$IFDEF DXE3} TValueBuffer {$ELSE} Pointer {$ENDIF});
var
  RecData: PRecInfo;
  ReadData: Pointer;
  WStr: WideString;
  Str: AnsiString;
  JSonData: ISuperObject;
begin
  RecData := PRecInfo(ActiveBuffer);
  ReadData := Pointer(Buffer);

  if State = dsEdit then
     JSONData := RecData.Info.Temp
  else JSONData := RecData.Info.Data;

  case Field.DataType of
    ftWideString: begin
      SetLength(WStr, Field.Size);
      Move(PByteArray(ReadData)[0], WStr[1], SizeOf(WideChar) * Field.Size);
      JSONData.S[Field.FieldName] := WStr;
    end;

    ftString: begin
      SetLength(Str, Field.Size);
      Move(PByteArray(ReadData)[0], Str[1], SizeOf(AnsiChar) * Field.Size);
      JSONData.S[Field.FieldName] := Str;
    end;

    ftInteger:
      JSONData.I[Field.FieldName] := PInteger(ReadData)^;

    ftLargeint:
      JSONData.I[Field.FieldName] := PInt64(ReadData)^;

    ftFloat:
      JSONData.F[Field.FieldName] := PDouble(ReadData)^;

    ftBoolean:
      JSONData.B[Field.FieldName] := PBoolean(ReadData)^;

    ftDateTime:
      JSONData.D[Field.FieldName] := PDateTime(ReadData)^;

    ftDate:
      JSONData.Date[Field.FieldName] := PDate(ReadData)^;

    ftTime:
      JSONData.Time[Field.FieldName] := PTime(ReadData)^;

    else
      Assert(false, 'Unsupported field type.');
  end;
  DataEvent(deFieldChange, Longint(Field));
end;

procedure TCustomJSONDataSet.InternalFirst;
begin
  FCurRec := -1;
end;

procedure TCustomJSONDataSet.InternalLast;
begin
  FCurRec := FDataRef.Length;
end;

procedure TCustomJSONDataSet.InternalPost;
begin
  if State = dsEdit then begin
     FDataRef.O[FCurRec] := PRecInfo(ActiveBuffer).Info.Temp;
     PRecInfo(ActiveBuffer).Info.Temp := Nil;
  end;
end;

procedure TCustomJSONDataSet.InternalAddRecord(Buffer: Pointer; Append: Boolean);
begin
  FSaveChanges := True;
  Inc(FLastBookmark);
  if Append then InternalLast;
  FDataRef.O[FCurRec];
end;

procedure TCustomJSONDataSet.InternalDelete;
begin
  FDataRef.Delete(FCurRec);
  Dec(FLastBookmark);
  with PRecInfo(ActiveBuffer)^.Info do begin
       Data := Nil;
       Temp := Nil;
  end;
  if FCurRec >= FDataRef.Length then
     Dec(FCurRec);
end;

procedure TCustomJSONDataSet.InternalEdit;
var
  RecInfo: PRecInfo;
begin
  RecInfo := PRecInfo(ActiveBuffer);
  RecInfo.Info.Temp := Nil;
  if RecInfo.Info.Data <> Nil then
     RecInfo.Info.Temp := RecInfo.Info.Data.Clone
  else RecInfo.Info.Temp := SO;
end;

function TCustomJSONDataSet.GetRecordCount: Longint;
begin
  Result := FDataRef.Length;
end;

function TCustomJSONDataSet.GetRecNo: Longint;
begin
  UpdateCursorPos;
  if (FCurRec = -1) and (RecordCount > 0) then
    Result := 1 else
    Result := FCurRec + 1;
end;

procedure TCustomJSONDataSet.SetRecNo(Value: Integer);
begin
  if (Value >= 0) and (Value < FDataRef.Length) then
  begin
    FCurRec := Value - 1;
    Resync([]);
  end;
end;

{ TJSONDataSet }

function TJSONDataSet.GetData: ISuperObject;
begin
  if Trim(FJSONContent) <> '' then
     Result := SO(FJSONContent)
  else if Trim(FJSONFile) <> '' then
     Result := TSuperObject.ParseFile(FJSONFile)
  else DatabaseError('Empty json data.');
end;

{ TCrudServer }

constructor TExpressConnection.Create(AOwner: TComponent);
begin
  inherited;
  FCookieManager := TIdCookieManager.Create(Nil);
end;

function TExpressConnection.Delete(DataSet: TCRUDDataSet; const URI: String): ISuperObject;
var
  Return: ISuperObject;
begin
  PrepareConnection(procedure(idHttp: TidHttp; Request, Response: TMemoryStream) begin
    DoBeforeRequest(DataSet, idHttp, URI);
    idHttp.Delete(URI, Response);
    if Response.Size > 0 then
       Return := TSuperObject.ParseStream(Response)
    else Return := Nil;
  end);
  Exit(Return);
end;

function TExpressConnection.Delete(const URI: String): ISuperObject;
var
  Return: ISuperObject;
begin
  PrepareConnection(procedure(idHttp: TidHttp; Request, Response: TMemoryStream) begin
    idHttp.Delete(URI, Response);
    if Response.Size > 0 then
       Return := TSuperObject.ParseStream(Response)
    else Return := Nil;
  end);
  Exit(Return);
end;

destructor TExpressConnection.Destroy;
begin
  FCookieManager.Free;
  inherited;
end;

procedure TExpressConnection.DoAfterRequest(DataSet: TCRUDDataSet; idHttp: TIdHttp; const URI: String; Response: ISuperObject);
begin
  if Assigned(FOnAfterRequest) then
     FOnAfterRequest(Self, DataSet, idHttp, URI, Response);
end;

procedure TExpressConnection.DoBeforeRequest(DataSet: TCRUDDataSet; idHttp: TIdHTTP; const URI: String);
begin
  if Assigned(FOnBeforeRequest) then
     FOnBeforeRequest(Self, DataSet, idHttp, URI);
end;

function TExpressConnection.Get(DataSet: TCRUDDataSet; const URI: String): ISuperObject;
var
  Return: ISuperObject;
begin
  PrepareConnection(procedure(idHttp: TidHttp; Response: TMemoryStream) begin
    DoBeforeRequest(DataSet, idHttp, URI);
    idHttp.Get(URI, Response);
    if Response.Size > 0 then
       Return := TSuperObject.ParseStream(Response);
  end);
  Exit(Return);
end;

function TExpressConnection.Get<T>(const URI: String): T;
var
  Return: T;
begin
  PrepareConnection(procedure(idHttp: TidHttp; Response: TMemoryStream)begin
    idHttp.Get(URL + '/' + URI, Response);
    if Response.Size > 0 then
       Return := TJSON.Parse<T>(TSuperObject.ParseStream(Response))
    else Return := Default(T);
  end);
  Result := Return;
end;

function TExpressConnection.Post(DataSet: TCRUDDataSet; const URI: String; Content: ISuperObject): ISuperObject;
var
  Return: ISuperObject;
begin
  PrepareConnection(procedure(idHttp: TidHttp; Request, Response: TMemoryStream) begin
    DoBeforeRequest(DataSet, idHttp, URI);
    Content.SaveTo(Request, False, True);
    idHttp.Post(URI, Request, Response);
    if Response.Size > 0 then
       Return := TSuperObject.ParseStream(Response)
    else Return := Nil;
  end);
  Result := Return;
end;

function TExpressConnection.Post<Req, Res>(const URI: String; Request: Req): Res;
var
  Return: ISuperObject;
begin
  PrepareConnection(procedure(idHttp: TidHttp; ARequest, AResponse: TMemoryStream) begin
    TJSON.SuperObject<Req>(Request).SaveTo(ARequest, False, True);
    idHttp.Post(URI, ARequest, AResponse);
    if AResponse.Size > 0 then
       Return := TSuperObject.ParseStream(AResponse)
    else Return := Nil;
  end);
  if Assigned(Return) then
     Result := TJSON.Parse<Res>(Return)
  else Result := Default(Res);
end;

procedure TExpressConnection.PrepareConnection(CallBack: TProc<TidHttp, TMemoryStream, TMemoryStream>);
var
  idHttp: TIdHTTP;
  Response,
  Request: TMemoryStream;
begin
  idHttp := TIdHTTP.Create(Nil);
  Response := TMemoryStream.Create;
  Request := TMemoryStream.Create;
  try
    idHttp.AllowCookies := True;
    idHttp.CookieManager := FCookieManager;
    idHttp.Request.Accept := 'application/json';
    idHttp.Request.ContentType := 'application/json';
    if FGZip then
       idHttp.Compressor := TIdCompressorZLib.Create(idHttp);

    CallBack(idHttp, Request, Response);

  finally
    idHttp.Compressor.Free;
    idHttp.Compressor := Nil;
    idHttp.Free;
    Response.Free;
    Request.Free;
  end;
end;

procedure TExpressConnection.PrepareConnection(CallBack: TProc<TidHttp, TMemoryStream>);
var
  idHttp: TIdHTTP;
  Response: TMemoryStream;
begin
  idHttp := TIdHTTP.Create(Nil);
  Response := TMemoryStream.Create;
  try
    idHttp.AllowCookies := True;
    idHttp.CookieManager := FCookieManager;
    idHttp.Request.Accept := 'application/json';
    idHttp.Request.ContentType := 'application/json';
    if FGZip then
       idHttp.Compressor := TIdCompressorZLib.Create(idHttp);

    CallBack(idHttp, Response);
  finally
    idHttp.Compressor.Free;
    idHttp.Compressor := Nil;
    idHttp.Free;
    Response.Free;
  end;
end;

function TExpressConnection.Put(DataSet: TCRUDDataSet; const URI: String; Content: ISuperObject): ISuperObject;
var
  Return: ISuperObject;
begin
  PrepareConnection(procedure(idHttp: TidHttp; Request, Response: TMemoryStream) begin
    DoBeforeRequest(DataSet, idHttp, URI);
    Content.SaveTo(Request, False, True);
    idHttp.Put(URI, Request, Response);
    if Response.Size > 0 then
       Return := TSuperObject.ParseStream(Response)
    else Return := Nil;
  end);
  Exit(Return);
end;

function TExpressConnection.Put<Req, Res>(const URI: String; Request: Req): Res;
var
  Return: ISuperObject;
begin
  PrepareConnection(procedure(idHttp: TidHttp; ARequest, AResponse: TMemoryStream) begin
    TJSON.SuperObject<Req>(Request).SaveTo(ARequest, False, True);
    idHttp.Put(URI, ARequest, AResponse);
    if AResponse.Size > 0 then
       Return := TSuperObject.ParseStream(AResponse)
    else Return := Nil;
  end);
  if Assigned(Return) then
     Result := TJSON.Parse<Res>(Return)
  else Result := Default(Res);
end;

procedure TExpressConnection.SetServer(const Value: String);
begin
  if FServer = Value then Exit;
  FServer := Value;
  if FServer.Substring(FServer.Length-1) = '/' then
     FServer := FServer.Substring(0, FServer.Length - 1);
end;

function TExpressConnection.URL: String;
begin
  Result := EHTTP_PROTOCOL_STRING[Protocol] + Server;
end;

{ TCRUDDataSet }

constructor TCRUDDataSet.Create(AOwner: TComponent);
begin
  inherited;
  FAPIInfo := TCRUDAPIInfo.Create(Self);
  FMasterLink := TMasterDataLink.Create(Self);
  FMasterLink.OnMasterChange := MasterChanged;
//  FMasterLink.OnMasterDisable := MasterDisabled;
end;

procedure TCRUDDataSet.DeleteData;
begin
  FConnection.Delete(Self, FAPIInfo.Delete.Generate);
end;

destructor TCRUDDataSet.Destroy;
begin
  FAPIInfo.Free;
  FMasterLink.Free;
  inherited;
end;

function TCRUDDataSet.GetData: ISuperObject;
begin
  Result := FConnection.Get(Self, FAPIInfo.Get.Generate);
end;

function TCRUDDataSet.InsertData(Data: ISuperObject = Nil): ISuperObject;
begin
  if Data = Nil then
     Data := PRecInfo(ActiveBuffer)^.Info.Data;
  Result := FConnection.Post(Self, FAPIInfo.Post.Generate, Data);
end;

procedure TCRUDDataSet.InternalDelete;
begin
  FConnection.Delete(Self, FAPIInfo.Delete.Generate);
  inherited;
end;

procedure TCRUDDataSet.InternalOpen;
var
  oldLink: TDataSource;
begin
  if not Assigned(FConnection) then
     DatabaseError('Connection is not assigned.')
  else if not FConnection.Active then
     DatabaseError('Connection is not activated.');
  inherited;
end;

procedure TCRUDDataSet.InternalPost;
var
  Request, Response: ISuperObject;
begin
  if State = dsEdit then
     UpdateData
  else begin
     Request := PRecInfo(ActiveBuffer)^.Info.Data.Clone;
     if Assigned(FOnCrudBeforePost) then
        FOnCrudBeforePost(Self, Request);
     Response := InsertData(Request);
     if Assigned(FOnCrudAfterPost) then
        FOnCrudAfterPost(Self, Request, Response);
  end;
  inherited;
end;

procedure TCRUDDataSet.InternalRefresh;
begin
  InternalOpen;
end;

procedure TCRUDDataSet.MasterChanged(Sender: TObject);
begin
  if FMasterLink.Fields.Count <= 0 then begin

     Exit;
  end;
  Refresh;
  First;
end;

procedure TCRUDDataSet.SetAPI(const Value: TCRUDAPIInfo);
begin
  FAPIInfo.Assign(Value);
end;

procedure TCRUDDataSet.SetMaster(const Value: TDataSource);
begin
  if FMaster = Value then Exit;
  if IsLinkedTo(Value) then DatabaseError(SCircularDataLink, Self);
  FMaster := Value;
  FMasterLink.DataSource := FMaster;
end;

procedure TCRUDDataSet.UpdateData;
var
  Rec: PRecInfo;
  Request, Response: ISuperObject;
begin
  Rec := PRecInfo(ActiveBuffer);
  if Rec.Info.Temp <> Nil then
     Request := Rec.Info.Temp.Clone
  else Request := Rec.Info.Data.Clone;

  if Assigned(FOnCrudBeforePut) then
     FOnCrudBeforePut(Self, Request);

  Response := FConnection.Put(Self, FAPIInfo.Put.Generate , Request);

  if Assigned(FOnCrudAfterPut) then
     FOnCrudAfterPut(Self, Request, Response);
end;

procedure TCRUDDataSet.UpdateMasterFields;
var
  Path: PURIPath;
  Fields: String;
  procedure Resolve(Paths: TArray<TURIPath>);
  var
    I: Integer;
  begin
    for I := 0 to High(Paths) do begin
        Path := @Paths[I];
        if Path.IsParam then
           Fields := ';' + Fields + Path.Name
    end;
  end;
begin
  Fields := '';
  Resolve(FAPIInfo.FGet.FURIPaths);
  Resolve(FAPIInfo.FPost.FURIPaths);
  Resolve(FAPIInfo.FPut.FURIPaths);
  Resolve(FAPIInfo.FDelete.FURIPaths);
  FMasterLink.FieldNames := Fields.Substring(1);
end;

{ TCRUDDataSetAPI }

procedure TCRUDAPIInfo.AssignTo(Source: TPersistent);
begin
  if Source.ClassType <> TCRUDAPIInfo then inherited;
  with TCRUDAPIInfo(Source) do begin
    Self.FGet.Assign(Get);
    Self.FPut.Assign(Put);
    Self.FPost.Assign(Post);
    Self.FDelete.Assign(Delete);
  end;
end;

constructor TCRUDAPIInfo.Create(AOwner: TCRUDDataSet);
begin
  FOwner := AOwner;
  FPost := TCRUDUri.Create(Self, utPost);
  FPut := TCRUDUri.Create(Self, utPut);
  FGet := TCRUDUri.Create(Self, utGet);
  FDelete := TCRUDUri.Create(Self, utDelete);
end;

destructor TCRUDAPIInfo.Destroy;
begin
  FPost.Free;
  FPut.Free;
  FGet.Free;
  FDelete.Free;
  inherited;
end;

procedure TCRUDAPIInfo.SetDelete(const Value: TCRUDUri);
begin
  FDelete.Assign(Value);
end;

procedure TCRUDAPIInfo.SetGet(const Value: TCRUDUri);
begin
  FGet.Assign(Value);
end;

procedure TCRUDAPIInfo.SetPost(const Value: TCRUDUri);
begin
  FPost.Assign(Value);
end;

procedure TCRUDAPIInfo.SetPut(const Value: TCRUDUri);
begin
  FPut.Assign(Value);
end;

{ TCRUDUri }

procedure TCRUDUri.AssignTo(Dest: TPersistent);
begin
  if Dest.ClassType <> TCRUDUri then inherited;
  FURI := TCRUDUri(Dest).URI;
  FParams.Assign(TCRUDUri(Dest).Params);
end;

constructor TCRUDUri.Create(AOwner: TCRUDAPIInfo; AUriType: TCRUDUriType);
begin
  inherited Create;
  FParams := TCRUDUriParams.Create(Self);
  FOwner := AOwner;
  FUriType := AURIType;
end;

destructor TCRUDUri.Destroy;
begin
  FParams.Free;
  inherited;
end;

function TCRUDUri.Generate: String;
begin
  case FUriType of
    utGet:
      if FURI = '' then
         DataBaseError('Get method address is empty.', FOwner.FOwner)
      else
         Result := URL + GenerateURI;

    utPut, utPost, utDelete : begin
      if FURI = '' then
         Result := FOwner.FGet.GenerateURI
      else Result := GenerateURI;

      if Result = '' then
         DataBaseError(URI_TYPE_STRING[Method] + ' method address is empty.', FOwner.FOwner);

      Result := URL + Result + '/' + KeyValue
    end;
  end;
end;

function TCRUDUri.GenerateURI: string;
var
  I: Integer;
  Path: PURIPath;
  Field: TField;
begin
  Result := '';
  for I := 0 to High(FURIPaths) do begin
      Path := @FURIPaths[I];
      if Path.IsParam then begin
         if Assigned(FOwner.FOwner.FMaster) then begin
            Field := FOwner.FOwner.FMaster.DataSet.Fields.FindField(Path.Name);
            if Assigned(Field) then begin
               Result := Result + '/' + Field.AsString;
               Continue;
            end;
         end;
         Result := Result + '/' + FParams.ParamByName(Path.Name).AsString
      end else Result := Result + '/' + Path.Name
  end;
end;

function TCRUDUri.KeyValue: String;
begin
  Result := FOwner.FOwner.FieldByName(FOwner.FOwner.KeyField).AsString;
end;

procedure TCRUDUri.SetParams(const Value: TCRUDUriParams);
begin
  FParams.Assign(Value);
end;

procedure TCRUDUri.SetURI(const Value: String);
begin
  if FURI = Value then Exit;
  FURI := Trim(Value);
  if FURI.Substring(0, 1) = '/' then
     FURI := FURI.Substring(1);
  FURIPaths := FParams.ParseURI(FURI);
  FOwner.FOwner.UpdateMasterFields;
end;

function TCRUDUri.URL: String;
begin
  Result := FOwner.FOwner.Connection.URL;
end;

{ TCRUDUriParams }

function TCRUDUriParams.ParseURI(const Value: String): TArray<TURIPath>;
var
  I: Integer;
  Values: TArray<String>;
begin
  Clear;
  Values := Value.Split(['/']);
  SetLength(Result, Length(Values));
  for I := 0 to High(Values) do begin
      Result[I].Name := Values[I];
      if Result[I].Name.Chars[0] = ':' then begin
         Result[I].Name := Result[I].Name.Substring(1);
         with AddParameter do begin
              Name := Result[I].Name;
              DataType := ftWideString;
         end;
         Result[I].IsParam := True;
      end else
         Result[I].IsParam := False;
  end;
end;

end.
