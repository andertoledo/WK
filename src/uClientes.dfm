object frmClientes: TfrmClientes
  Left = 0
  Top = 0
  Caption = 'Clientes'
  ClientHeight = 432
  ClientWidth = 534
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poMainFormCenter
  OnKeyDown = grdClientesKeyDown
  TextHeight = 15
  object grdClientes: TDBGrid
    Left = 0
    Top = 0
    Width = 534
    Height = 432
    Align = alClient
    DataSource = dsClientes
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
    OnDblClick = grdClientesDblClick
    OnKeyDown = grdClientesKeyDown
    Columns = <
      item
        Alignment = taCenter
        Expanded = False
        FieldName = 'codigo'
        Title.Alignment = taCenter
        Title.Caption = 'C'#243'digo'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'nome'
        Title.Caption = 'Nome'
        Width = 200
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'cidade'
        Title.Caption = 'Cidade'
        Width = 200
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'uf'
        Title.Caption = 'UF'
        Visible = True
      end>
  end
  object qryClientes: TFDQuery
    Connection = DMConnMySQL.FDConnection
    SQL.Strings = (
      'select * from clientes')
    Left = 344
    Top = 112
    object qryClientescodigo: TFDAutoIncField
      FieldName = 'codigo'
      ReadOnly = False
    end
    object qryClientesnome: TStringField
      FieldName = 'nome'
      Size = 100
    end
    object qryClientescidade: TStringField
      FieldName = 'cidade'
      Size = 50
    end
    object qryClientesuf: TStringField
      FieldName = 'uf'
      FixedChar = True
      Size = 2
    end
  end
  object dsClientes: TDataSource
    DataSet = qryClientes
    Left = 344
    Top = 48
  end
end
