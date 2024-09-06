unit uProdutos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  uDMConnMySQL, Data.DB, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.Grids, Vcl.DBGrids;

type
  TfrmProdutos = class(TForm)
    grdProdutos: TDBGrid;
    qryProdutos: TFDQuery;
    dsProdutos: TDataSource;
    qryProdutoscodigo: TIntegerField;
    qryProdutosdescricao: TStringField;
    qryProdutosprecovenda: TBCDField;
    procedure grdProdutosDblClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    class function BuscaProduto(var vValorUnit: Double) : Integer;
  end;

var
  frmProdutos: TfrmProdutos;
  vProdutoSelecao : Integer;

implementation

{$R *.dfm}

{ TfrmProdutos }


{ TfrmProdutos }

class function TfrmProdutos.BuscaProduto(var vValorUnit: Double) : Integer;
begin
  Result := 0;

  try
    frmProdutos := TfrmProdutos.Create(nil);
    frmProdutos.qryProdutos.Open;
    vProdutoSelecao := 0;
    frmProdutos.ShowModal;
    Result := vProdutoSelecao;
    vValorUnit := frmProdutos.qryProdutosprecovenda.AsFloat;
  finally
    FreeAndNil(frmProdutos);
  end;

end;

procedure TfrmProdutos.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = vk_Escape then
  begin
    Close;
  end;
end;

procedure TfrmProdutos.grdProdutosDblClick(Sender: TObject);
begin
  vProdutoSelecao := qryProdutosCodigo.AsInteger;
  Close;
end;


end.
