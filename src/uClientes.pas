unit uClientes;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  uDMConnMySQL, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, Vcl.Grids, Vcl.DBGrids,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TfrmClientes = class(TForm)
    qryClientes: TFDQuery;
    dsClientes: TDataSource;
    grdClientes: TDBGrid;
    qryClientescodigo: TFDAutoIncField;
    qryClientesnome: TStringField;
    qryClientescidade: TStringField;
    qryClientesuf: TStringField;
    procedure grdClientesDblClick(Sender: TObject);
    procedure grdClientesKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    class function BuscaCliente : Integer;
  end;

var
  frmClientes: TfrmClientes;
  vClienteSelecao : Integer;

implementation

{$R *.dfm}


{ TfrmClientes }

class function TfrmClientes.BuscaCliente: Integer;
begin
  Result := 0;

  try
    frmClientes := TfrmClientes.Create(nil);
    frmClientes.qryClientes.Open;
    vClienteSelecao := 0;
    FrmClientes.ShowModal;
    Result := vClienteSelecao;
  finally
    FreeAndNil(frmClientes);
  end;
end;

procedure TfrmClientes.grdClientesDblClick(Sender: TObject);
begin
  vClienteSelecao := qryClientesCodigo.AsInteger;
  Close;
end;

procedure TfrmClientes.grdClientesKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = vk_Escape then
  begin
    Close;
  end;
end;

end.
