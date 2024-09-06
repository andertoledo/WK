object frmProdutos: TfrmProdutos
  Left = 0
  Top = 0
  Caption = 'Produtos'
  ClientHeight = 431
  ClientWidth = 423
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poMainFormCenter
  OnKeyDown = FormKeyDown
  TextHeight = 15
  object grdProdutos: TDBGrid
    Left = 0
    Top = 0
    Width = 423
    Height = 431
    Align = alClient
    DataSource = dsProdutos
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
    OnDblClick = grdProdutosDblClick
    OnKeyDown = FormKeyDown
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
        FieldName = 'descricao'
        Title.Caption = 'Descri'#231#227'o'
        Width = 250
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'precovenda'
        Title.Caption = 'Pre'#231'o Venda'
        Visible = True
      end>
  end
  object qryProdutos: TFDQuery
    Connection = DMConnMySQL.FDConnection
    SQL.Strings = (
      'select * from produtos'
      'order by codigo')
    Left = 312
    Top = 160
    object qryProdutoscodigo: TIntegerField
      FieldName = 'codigo'
      Origin = 'codigo'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object qryProdutosdescricao: TStringField
      AutoGenerateValue = arDefault
      FieldName = 'descricao'
      Origin = 'descricao'
      Size = 100
    end
    object qryProdutosprecovenda: TBCDField
      AutoGenerateValue = arDefault
      FieldName = 'precovenda'
      Origin = 'precovenda'
      DisplayFormat = '0.,00'
      Precision = 10
      Size = 2
    end
  end
  object dsProdutos: TDataSource
    DataSet = qryProdutos
    Left = 312
    Top = 96
  end
end
