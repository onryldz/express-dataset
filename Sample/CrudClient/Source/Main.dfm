object MainFrm: TMainFrm
  Left = 0
  Top = 0
  Caption = 'Express DataSet - Demo'
  ClientHeight = 514
  ClientWidth = 1054
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 257
    Top = 0
    Height = 514
    ExplicitLeft = 320
    ExplicitTop = 328
    ExplicitHeight = 100
  end
  object DBGrid1: TDBGrid
    Left = 0
    Top = 0
    Width = 257
    Height = 514
    Align = alLeft
    DataSource = CustomerDSrc
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'Name'
        Visible = True
      end>
  end
  object DBGrid2: TDBGrid
    Left = 260
    Top = 0
    Width = 794
    Height = 514
    Align = alClient
    DataSource = CustomerDetailsDSrc
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'Address'
        Width = 278
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'EMail'
        Width = 176
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Phone'
        Width = 207
        Visible = True
      end>
  end
  object ExpressConnection1: TExpressConnection
    Active = True
    Server = 'localhost:8080'
    GZip = False
    Protocol = ehpHttp
    Left = 56
    Top = 56
  end
  object CustomerDSet: TCRUDDataSet
    Async = False
    API.Get.URI = 'api/v1/customers'
    API.Get.Params = <>
    API.Put.URI = 'api/v1/customers/update'
    API.Put.Params = <>
    API.Post.URI = 'api/v1/customers/insert'
    API.Post.Params = <>
    API.Delete.URI = 'api/v1/customers/delete'
    API.Delete.Params = <>
    Connection = ExpressConnection1
    KeyField = 'id'
    OnCrudAfterPost = CustomerDSetCrudAfterPost
    Left = 56
    Top = 136
    object CustomerDSetId: TLargeintField
      FieldName = 'Id'
    end
    object CustomerDSetName: TWideStringField
      FieldName = 'Name'
      Size = 50
    end
  end
  object CustomerDSrc: TDataSource
    DataSet = CustomerDSet
    Left = 176
    Top = 136
  end
  object CustomerDetailsDSet: TCRUDDataSet
    Async = False
    API.Get.URI = 'api/v1/customerdetails/:id'
    API.Get.Params = <
      item
        DataType = ftWideString
        Name = 'id'
        ParamType = ptUnknown
      end>
    API.Put.URI = 'api/v1/customerdetails/update/:id'
    API.Put.Params = <
      item
        DataType = ftWideString
        Name = 'id'
        ParamType = ptUnknown
      end>
    API.Post.URI = 'api/v1/customerdetails/insert/:id'
    API.Post.Params = <
      item
        DataType = ftWideString
        Name = 'id'
        ParamType = ptUnknown
      end>
    API.Delete.URI = 'api/v1/customerdetails/delete/:id'
    API.Delete.Params = <
      item
        DataType = ftWideString
        Name = 'id'
        ParamType = ptUnknown
      end>
    Connection = ExpressConnection1
    KeyField = 'id'
    Master = CustomerDSrc
    OnCrudAfterPost = CustomerDetailsDSetCrudAfterPost
    Left = 368
    Top = 136
    object CustomerDetailsDSetId: TLargeintField
      FieldName = 'Id'
    end
    object CustomerDetailsDSetCustomerId: TLargeintField
      FieldName = 'CustomerId'
    end
    object CustomerDetailsDSetAddress: TWideStringField
      FieldName = 'Address'
      Size = 100
    end
    object CustomerDetailsDSetEMail: TWideStringField
      FieldName = 'EMail'
      Size = 50
    end
    object CustomerDetailsDSetPhone: TWideStringField
      FieldName = 'Phone'
      Size = 50
    end
  end
  object CustomerDetailsDSrc: TDataSource
    DataSet = CustomerDetailsDSet
    Left = 488
    Top = 128
  end
end
