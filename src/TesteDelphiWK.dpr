program TesteDelphiWK;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {frmMain},
  uProdutos in 'uProdutos.pas' {frmProdutos},
  uClientes in 'uClientes.pas' {frmClientes},
  uDMConnMySQL in 'uDMConnMySQL.pas' {DMConnMySQL: TDataModule},
  uPedidosClass in 'uPedidosClass.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDMConnMySQL, DMConnMySQL);
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
