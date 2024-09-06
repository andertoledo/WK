unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.UI.Intf,
  FireDAC.Stan.Def, FireDAC.Phys, FireDAC.Stan.Pool, FireDAC.Phys.MySQL,
  FireDAC.Phys.MySQLDef, FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client,
  FireDAC.Comp.DataSet, Vcl.Grids, Vcl.DBGrids, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons,

  System.Generics.Collections,
  uDMConnMySQL,
  uPedidosClass, Vcl.AppEvnts;

type
  TfrmMain = class(TForm)
    qryTemp: TFDQuery;
    pnl_Top: TPanel;
    pnl_Bottom: TPanel;
    pnl_Client: TPanel;
    Splitter: TSplitter;
    grdPedidos: TStringGrid;
    grdProdutosPed: TStringGrid;
    btSair: TBitBtn;
    pnlHeaderItens: TPanel;
    lbValorTotal: TLabel;
    edtValorTotal: TEdit;
    btGravaPedido: TBitBtn;
    btNovoPedido: TBitBtn;
    btNovoItem: TBitBtn;
    FDTransaction: TFDTransaction;
    AppEvents: TApplicationEvents;
    procedure FormShow(Sender: TObject);
    procedure grdPedidosKeyPress(Sender: TObject; var Key: Char);
    procedure grdPedidosSelectCell(Sender: TObject; ACol, ARow: LongInt;
      var CanSelect: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btNovoPedidoClick(Sender: TObject);
    procedure btNovoItemClick(Sender: TObject);
    procedure grdPedidosKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure grdProdutosPedKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure grdProdutosPedKeyPress(Sender: TObject; var Key: Char);
    procedure btGravaPedidoClick(Sender: TObject);
    procedure grdPedidosSetEditText(Sender: TObject; ACol, ARow: LongInt;
      const Value: string);
    procedure grdPedidosKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure grdProdutosPedKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure grdProdutosPedSelectCell(Sender: TObject; ACol, ARow: LongInt;
      var CanSelect: Boolean);
    procedure AppEventsIdle(Sender: TObject; var Done: Boolean);
    procedure grdPedidosMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure grdProdutosPedClick(Sender: TObject);
  private
    PedidoRowIndex  : Integer;
    ProdutoRowIndex : Integer;
    lstCacheUpdates : TStringList;
    RowPedInUpdate  : Integer;

    procedure AjustarColunas(Grid: TStringGrid);
    procedure CarregaPedidosFromDB;
    procedure CarregaGridPedidos;
    procedure CarregaPedidosProdutosFromDB( pPedido: tPedidos; pCarregaGrid : Boolean = True );
    procedure CarregaGridPedidosProdutos( pPedido: tPedidos );
    procedure GravaPedidoDB;
    function ExistePedidoDB(pPedido: Integer): boolean;
    procedure InserirPedidoLista(pPedido, pCliente: String);
    procedure InserirProdutoLista(pPedido: tPedidos; pProduto: String; pValorProduto: Double);
    function ApagarPedidoDB(pPedido: tPedidos): Boolean;
    function ApagarProdutoDB(pId: Integer): Boolean;
    function GetNewCodPedido : Integer;
    procedure ClearLists;
    procedure ClearGrids(pPedidos: boolean = True; pPedProdutos: boolean = False);
    procedure UpdatePedList(pPedido: Integer);
    function Str2FloatDef(pStr : String; Default: Double): Double;
  public
    { Public declarations }
  end;

const
  cSQLInsertPedidos = ' insert into pedidos values (:numeropedido,  :dataemissao,  :codigocliente,  :valortotal)';
  cSQLUpdatePedidos = ' update pedidos set dataemissao = :dataemissao, codigocliente = :codigocliente, valortotal = :valortotal where numeropedido = :numeropedido';
  cSQLDeletePedidos = ' delete from pedidos where numeropedido = :numeropedido';

  cSQLInsertPedidosProd    = 'insert into pedidos_produtos values (null, :numeropedido, :codigoproduto, :quantidade, :valorunitario, :valortotal)';
  cSQLUpdatePedidosProd    = 'update pedidos_produtos set numeropedido = :numeropedido, codigoproduto = :codigoproduto, quantidade = :quantidade, valorunitario = :valorunitario, valortotal = :valortotal where autoincrem = :autoincrem';
  cSQLDeleteAllPedidosProd = 'delete from pedidos_produtos where numeropedido = :numeropedido';
  cSQLDeleteOnePedidosProd = 'delete from pedidos_produtos where autoincrem = :autoincrem';

var
  frmMain: TfrmMain;
  PedidosList: TObjectList<tPedidos>;
  function GetPedidoByCodigo(pNumeroPedido: String): tPedidos;

implementation
  uses uProdutos, uClientes;

{$R *.dfm}

{ TfrmMain }

function GetPedidoByCodigo(pNumeroPedido: String): tPedidos;
begin
  result := nil;
  
  for var vPedido in PedidosList do
  begin
    if Assigned(vPedido) then
    begin
      if vPedido.Pedido = StrToIntDef(pNumeroPedido,0) then
      begin
        result := vPedido;
        exit;
      end;
    end;
  end;
end;

procedure TfrmMain.AjustarColunas(Grid: TStringGrid);
var
  i, j, Largura: Integer;
begin
  for i := 0 to Grid.ColCount - 1 do
  begin
    Largura := 0;
    for j := 0 to Grid.RowCount - 1 do
    begin
      if Grid.Canvas.TextWidth(Grid.Cells[i, j]) > Largura then
        Largura := Grid.Canvas.TextWidth(Grid.Cells[i, j]);
    end;
    Grid.ColWidths[i] := Largura + 10;
  end;
end;

function TfrmMain.ApagarPedidoDB(pPedido: tPedidos): boolean;
begin
  result := False;

  try try
    FDTransaction.StartTransaction;

    qryTemp.Close;

    qryTemp.SQL.Text := cSQLDeleteAllPedidosProd;
    qryTemp.ParamByName('NumeroPedido').AsInteger := pPedido.Pedido;
    qryTemp.ExecSQL;

    qryTemp.SQL.Text := cSQLDeletePedidos;
    qryTemp.ParamByName('NumeroPedido').AsInteger := pPedido.Pedido;
    qryTemp.ExecSQL;

    FDTransaction.Commit;

    result := True;
  except
    on E: Exception do
    begin
      MessageDlg('Erro ao apagar dados de Pedidos, detalhe: '+ E.Message, mtError, [mbOk], 0);
      FDTransaction.Rollback;
    end;
  end;
  finally
    qryTemp.SQL.Clear;
  end;
end;

function TfrmMain.ApagarProdutoDB(pId: Integer): Boolean;
begin
  result := False;

  try try
    FDTransaction.StartTransaction;

    qryTemp.Close;

    qryTemp.SQL.Text := cSQLDeleteOnePedidosProd;
    qryTemp.ParamByName('autoincrem').AsInteger := pId;
    qryTemp.ExecSQL;

    FDTransaction.Commit;

    result := True;
  except
    on E: Exception do
    begin
      MessageDlg('Erro ao apagar dados de Produtos, detalhe: '+ E.Message, mtError, [mbOk], 0);
      FDTransaction.Rollback;
    end;
  end;
  finally
    qryTemp.SQL.Clear;
  end;
end;

procedure TfrmMain.AppEventsIdle(Sender: TObject; var Done: Boolean);
var 
  vTotalPed : Double;
begin

  vTotalPed := 0;

  for var iRow := 1 to grdPedidos.RowCount-1 do
  begin
    vTotalPed := vTotalPed + Str2FloatDef(grdPedidos.Cells[3, iRow], 0);
  end;

  edtValorTotal.Text := FormatFloat('0.,00',vTotalPed);
end;

procedure TfrmMain.btGravaPedidoClick(Sender: TObject);
begin
  GravaPedidoDB;
  CarregaPedidosProdutosFromDB( GetPedidoByCodigo(grdProdutosPed.Cells[1,1]) );
                                   
  btNovoPedido.Enabled  := True;
  btGravaPedido.Enabled := False;
  
  RowPedInUpdate        := 0;
end;

procedure TfrmMain.btNovoItemClick(Sender: TObject);
var
  vValorProduto : Double;
begin
  if StrToIntDef(grdPedidos.Cells[0, grdPedidos.Row],0) = 0 then
  begin
    MessageDlg('Selecione um pedido para inclusão de produtos!', mtWarning, [mbOk], 0);
    exit;
  end;

  var pProduto := TfrmProdutos.BuscaProduto(vValorProduto);

  if pProduto > 0 then
  begin
    var iRow := grdProdutosPed.RowCount;
    grdProdutosPed.RowCount       := iRow + 1;
    grdProdutosPed.Cells[0, iRow] := '';
    grdProdutosPed.Cells[1, iRow] := grdPedidos.Cells[0, grdPedidos.Row];
    grdProdutosPed.Cells[2, iRow] := pProduto.ToString;
    grdProdutosPed.Cells[3, iRow] := '0';
    grdProdutosPed.Cells[4, iRow] := FormatFloat('0.,00', vValorProduto);
    grdProdutosPed.Cells[5, iRow] := '0';
  end;                               

  InserirProdutoLista( PedidosList[ grdPedidos.Row-1 ], pProduto.ToString, vValorProduto);
  
  btNovoPedido.Enabled  := False;
  btGravaPedido.Enabled := True;

  ProdutoRowIndex       := grdProdutosPed.RowCount-1; 
  grdProdutosPed.Row    := grdProdutosPed.RowCount-1;
  grdProdutosPed.SetFocus;
end;

procedure TfrmMain.btNovoPedidoClick(Sender: TObject);
var
  Key : Word;
begin
  var pCliente := TfrmClientes.BuscaCliente;

  if pCliente > 0 then
  begin
    var iRow := grdPedidos.RowCount;
    var vNewPedido := GetNewCodPedido.ToString;
    grdPedidos.RowCount       := iRow + 1;
    grdPedidos.Cells[0, iRow] := vNewPedido;
    grdPedidos.Cells[1, iRow] := FormatDateTime('dd/mm/yyyy hh:nn:ss', Now);
    grdPedidos.Cells[2, iRow] := pCliente.ToString;
    grdPedidos.Cells[3, iRow] := '0';

    InserirPedidoLista( vNewPedido, pCliente.ToString);

    ClearGrids(False, True);

    btNovoPedido.Enabled  := False;
    btGravaPedido.Enabled := True;

    RowPedInUpdate        := grdPedidos.RowCount -1;
    PedidoRowIndex        := RowPedInUpdate;
    grdPedidos.Row        := RowPedInUpdate;
    grdPedidos.SetFocus;
    grdPedidosKeyUp(grdPedidos, Key, []);
  end;
end;

procedure TfrmMain.CarregaGridPedidos;
var
  iCount  : Integer;
  Key     : Word;
begin

  try

    for iCount := 1 to grdPedidos.RowCount - 1 do
    begin
      grdPedidos.Rows[iCount].Clear;
    end;
    grdPedidos.RowCount := 1 ;

    iCount := 1;
    for var vPedido in PedidosList do
    begin
      grdPedidos.RowCount := grdPedidos.RowCount + 1;

      grdPedidos.Cells[0,iCount] := vPedido.Pedido.ToString;
      grdPedidos.Cells[1,iCount] := FormatDateTime('dd/mm/yyyy hh:nn:ss', vPedido.Emissao );
      grdPedidos.Cells[2,iCount] := vPedido.Cliente.ToString;
      grdPedidos.Cells[3,iCount] := FormatFloat('0.,00', vPedido.ValorTotal);

      Inc(iCount);
    end;

    if grdPedidos.RowCount > 1 then
    begin
      grdPedidos.Row := 1;
      grdPedidosKeyUp(grdPedidos, Key, []);
    end;
  except
    on E: Exception do
    begin
      MessageDlg('Erro carregando grid de Pedidos, informe ao suporte: ' + E.Message, mtError, [mbOk],0);
    end;
  end;

end;

procedure TfrmMain.CarregaGridPedidosProdutos( pPedido: tPedidos );
var
  iCount  : Integer;
  Key     : Word;
begin

  try

    ClearGrids(False, True);

    if pPedido = nil then exit;

    pPedido.ValorTotal := 0;

    iCount := 1;
    for var vProdPedidos in pPedido.PedProdutosList do
    begin
      grdProdutosPed.RowCount := grdProdutosPed.RowCount + 1;

      grdProdutosPed.Cells[0,iCount] := vProdPedidos.Id.ToString;
      grdProdutosPed.Cells[1,iCount] := vProdPedidos.Pedido.ToString;
      grdProdutosPed.Cells[2,iCount] := vProdPedidos.Produto.ToString;
      grdProdutosPed.Cells[3,iCount] := vProdPedidos.Quantidade.ToString;
      grdProdutosPed.Cells[4,iCount] := FormatFloat('0.,00', vProdPedidos.ValorUnitario);
      grdProdutosPed.Cells[5,iCount] := FormatFloat('0.,00', vProdPedidos.ValorTotal);

      pPedido.ValorTotal := pPedido.ValorTotal + vProdPedidos.ValorTotal;

      Inc(iCount);
    end;

    if grdProdutosPed.RowCount > 1 then
    begin
      grdProdutosPed.Row := 1;
      grdProdutosPedKeyUp(grdProdutosPed, Key, []);
    end;
  except
    on E: Exception do
    begin
      MessageDlg('Erro carregando grid de Produtos, informe ao suporte: ' + E.Message, mtError, [mbOk],0);
    end;
  end;
end;

procedure TfrmMain.CarregaPedidosFromDB;
begin
  try
    with qryTemp do
    begin
      PedidosList.Clear;

      Close;
      SQL.Clear;
      SQL.Add('select * from pedidos');
      SQL.Add('order by numeropedido');
      Open;

      while not eof do
      begin

        var vPedido := tPedidos.Create;

        with vPedido do
        begin
          pedido      := qryTemp.FieldByName('numeropedido').AsInteger;
          Emissao     := qryTemp.FieldByName('dataemissao').AsDateTime;
          Cliente     := qryTemp.FieldByName('codigocliente').AsInteger;
          ValorTotal  := qryTemp.FieldByName('valortotal').AsFloat;
        end;
        PedidosList.Add(vPedido);

        CarregaPedidosProdutosFromDB( vPedido, False );
        
      Next;
      end;
    end;
  finally
    qryTemp.Close;
  end;

  CarregaGridPedidos;

  CarregaPedidosProdutosFromDB( GetPedidoByCodigo(grdPedidos.Cells[0,1]) );

  AjustarColunas(grdPedidos);
  AjustarColunas(grdProdutosPed);
end;

procedure TfrmMain.CarregaPedidosProdutosFromDB(pPedido: tPedidos; pCarregaGrid : Boolean = True );
var
  qryTmp : TFDQuery;
begin
  if pPedido = nil then exit;

  try

    qryTmp := TFDQuery.Create(nil);
    qryTmp.Connection := DMConnMySQL.FDConnection;
    
    with qryTmp do
    begin
      pPedido.PedProdutosList.Clear;

      Close;
      SQL.Clear;
      SQL.Add('select * from pedidos_produtos');
      SQL.Add(' where numeropedido = :NumPed ');
      SQL.Add(' order by autoincrem');
      ParamByName('NumPed').AsInteger := pPedido.Pedido;
      Open;

      while not eof do
      begin

        var vPedProdutos := tPedidosProdutos.Create;

        with vPedProdutos do
        begin
          Id             := qryTmp.FieldByName('autoincrem').AsInteger;
          Pedido         := qryTmp.FieldByName('numeropedido').AsInteger;
          Produto        := qryTmp.FieldByName('codigoproduto').AsInteger;
          Quantidade     := qryTmp.FieldByName('quantidade').AsInteger;
          ValorUnitario  := qryTmp.FieldByName('valorunitario').AsFloat;
          ValorTotal     := qryTmp.FieldByName('valortotal').AsFloat;
        end;
        pPedido.PedProdutosList.Add(vPedProdutos);

        Next;
      end;
    end;

    if pCarregaGrid then
    begin
      CarregaGridPedidosProdutos( pPedido );
    end;

  finally
    qryTmp.Close;
    FreeAndNil(qryTmp);
  end;
end;

procedure TfrmMain.ClearGrids(pPedidos, pPedProdutos: boolean);
begin
  if pPedidos then
  begin
    with grdPedidos do
    begin
      for var iRow := 1 to RowCount-1 do
      begin
        for var iCol := 0 to ColCount-1 do
        begin
          Cells[iCol, iRow] := EmptyStr;
        end;        
      end;
    end;
  end;

  if pPedProdutos then
  begin
    with grdProdutosPed do
    begin
      for var iRow := 1 to RowCount-1 do
      begin
        for var iCol := 0 to ColCount-1 do
        begin
          Cells[iCol, iRow] := EmptyStr;
        end;        
      end;
      RowCount := 1;
    end;
  end;
end;

procedure TfrmMain.ClearLists;
begin
  try
    if PedidosList.Count > 0 then
    begin

      ClearGrids(True, True);

      for var vPedidoList in PedidosList do
      begin

        while vPedidoList.PedProdutosList.Count > 0 do
        begin
          vPedidoList.PedProdutosList.Delete(0);
        end;

      end;
    end;

    FreeAndNil(PedidosList);
  finally
    PedidosList := TObjectList<tPedidos>.Create;
  end;
end;

function TfrmMain.ExistePedidoDB(pPedido: Integer): boolean;
var
  qryTmp : TFDQuery;
begin
  
  try

    qryTmp := TFDQuery.Create(nil);
    qryTmp.Connection := DMConnMySQL.FDConnection;
  
    with qryTmp do
    begin
      try
        Close;
        SQL.Clear;
        SQL.Add('select count(1) from pedidos where numeropedido = :numeropedido');
        ParamByName('numeropedido').AsInteger := pPedido;
        Open;

        Result := StrToIntDef(qryTmp.Fields[0].AsString, 0) > 0;
      finally
        Close;
      end;
    end;
    
  finally
    FreeAndNil( qryTmp );
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FormatSettings.DecimalSeparator  := ',';
  FormatSettings.ThousandSeparator := '.';
  PedidosList     := TObjectList<tPedidos>.Create;
  lstCacheUpdates := TStringList.Create;
  RowPedInUpdate  := 0;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  PedidosList.Clear;
  FreeAndNil(PedidosList);
  FreeAndNil(lstCacheUpdates);
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  grdPedidos.RowCount := 1;
  grdPedidos.ColCount := 4;

  grdPedidos.Cells[0,0] := 'Pedido';
  grdPedidos.Cells[1,0] := 'Emissão';
  grdPedidos.Cells[2,0] := 'Cód. Cliente';
  grdPedidos.Cells[3,0] := 'Valor Total';

  AjustarColunas(grdPedidos);

  grdProdutosPed.RowCount := 1;
  grdProdutosPed.ColCount := 6;

  grdProdutosPed.Cells[0,0] := 'Id';
  grdProdutosPed.Cells[1,0] := 'Pedido';
  grdProdutosPed.Cells[2,0] := 'Cód. Produto';
  grdProdutosPed.Cells[3,0] := 'Quantidade';
  grdProdutosPed.Cells[4,0] := 'Unitário';
  grdProdutosPed.Cells[5,0] := 'Total';

  CarregaPedidosFromDB;

  grdPedidos.SetFocus;
end;

function TfrmMain.GetNewCodPedido: Integer;
begin
  Result := StrToIntDef( grdPedidos.Cells[0, grdPedidos.RowCount-1], 0) + 1;
end;

procedure TfrmMain.GravaPedidoDB;
begin
  for var vPedido in PedidosList do
  begin

    try try

      FDTransaction.StartTransaction;

      if vPedido.Pedido > 0 then
      begin
        qryTemp.SQL.Clear;

        if ExistePedidoDB(vPedido.Pedido) then
        begin
          qryTemp.SQL.Add(cSQLUpdatePedidos);
        end else
        begin
          qryTemp.SQL.Add(cSQLInsertPedidos);
        end;

        qryTemp.ParamByName('numeropedido').AsInteger  := vPedido.Pedido;
        qryTemp.ParamByName('dataemissao').AsDateTime  := vPedido.Emissao;
        qryTemp.ParamByName('codigocliente').AsInteger := vPedido.Cliente;
        qryTemp.ParamByName('valortotal').AsFloat      := vPedido.ValorTotal;
        qryTemp.ExecSQL;

        for var vPedProdutos in vPedido.PedProdutosList do
        begin
          qryTemp.SQL.Clear;

          if vPedProdutos.Id > 0 then
          begin
            qryTemp.SQL.Add(cSQLUpdatePedidosProd);
            qryTemp.ParamByName('autoincrem').AsInteger    := vPedProdutos.Id;
          end else
          begin
            qryTemp.SQL.Add(cSQLInsertPedidosProd);
          end;

          qryTemp.ParamByName('numeropedido').AsInteger    := vPedProdutos.Pedido;
          qryTemp.ParamByName('codigoproduto').AsInteger   := vPedProdutos.Produto;
          qryTemp.ParamByName('quantidade').AsInteger      := vPedProdutos.Quantidade;
          qryTemp.ParamByName('valorunitario').AsFloat     := vPedProdutos.ValorUnitario;
          qryTemp.ParamByName('valortotal').AsFloat        := vPedProdutos.ValorTotal;
          qryTemp.ExecSQL;

        end;
          
      end;
    
      FDTransaction.Commit;
    except
      on E: Exception do
      begin
        MessageDlg('Erro ao gravar na base de dados, detalhe: '+ E.Message, mtError, [mbOk], 0);
        FDTransaction.Rollback;
      end;
    end;
    finally
      qryTemp.sql.Clear;
    end;
  end;
end;

procedure TfrmMain.grdPedidosKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

  if (grdPedidos.Row = 0) or (grdPedidos.RowCount = 1) then exit;

  if Key = vk_Delete then
  begin
    if MessageDlg('Confirma apagar Pedido '+grdPedidos.Cells[0,grdPedidos.Row]+'?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      if ApagarPedidoDB(GetPedidoByCodigo(grdPedidos.Cells[0,grdPedidos.Row])) then
      begin
        ClearLists;
        CarregaPedidosFromDB;

        btNovoPedido.Enabled  := True;
        btGravaPedido.Enabled := False;
      end;
    end;
  end;

  if key = vk_Return then
  begin
    UpdatePedList(grdPedidos.Cells[0,grdPedidos.Row].ToInteger);
    grdPedidos.Cells[3,grdPedidos.Row] := FormatFloat('0.,00', GetPedidoByCodigo(grdPedidos.Cells[0,grdPedidos.Row]).ValorTotal);
    btNovoPedido.Enabled  := False;
    btGravaPedido.Enabled := True;
  end;  
end;

procedure TfrmMain.grdPedidosKeyPress(Sender: TObject; var Key: Char);
begin
  AjustarColunas(grdPedidos);
end;

procedure TfrmMain.grdPedidosKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  PedidoRowIndex := grdPedidos.Row;

  if (PedidoRowIndex > 0) and
     (grdProdutosPed.RowCount >= 1) and
     (grdPedidos.Cells[0, PedidoRowIndex] <> grdProdutosPed.Cells[1, 1]) then
  begin
    CarregaGridPedidosProdutos(PedidosList[PedidoRowIndex-1]);
  end;
end;

procedure TfrmMain.grdPedidosMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Key : Word;
begin
  grdPedidosKeyUp(grdPedidos, Key, []);
end;

procedure TfrmMain.grdPedidosSelectCell(Sender: TObject; ACol, ARow: LongInt;
  var CanSelect: Boolean);
begin
  try
    grdPedidos.OnSelectCell := nil;

    if (RowPedInUpdate > 0) and (RowPedInUpdate <> ARow) then
    begin
      MessageDlg('Necessário gravar pedido em aberto, verifique!', mtWarning, [mbOk], 0);
      CanSelect := False;
      grdPedidos.Row := RowPedInUpdate;
      grdPedidos.SetFocus;
      exit;
    end;
  finally
    grdPedidos.OnSelectCell := grdPedidosSelectCell;
  end;
 
end;

procedure TfrmMain.grdPedidosSetEditText(Sender: TObject; ACol, ARow: LongInt;
  const Value: string);
begin
  if grdPedidos.RowCount = 1 then exit;

  RowPedInUpdate        := grdProdutosPed.Row;
  btGravaPedido.Enabled := True;
end;

procedure TfrmMain.grdProdutosPedClick(Sender: TObject);
var
  Key : Word;
begin
  grdProdutosPedKeyUp(grdProdutosPed, Key, []);
end;

procedure TfrmMain.grdProdutosPedKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

  if (ProdutoRowIndex = 0) or (grdProdutosPed.RowCount = 1) then exit;

  if Key = vk_Delete then
  begin
    if (grdProdutosPed.Row > 0) and
       (MessageDlg('Confirma apagar Produto '+grdProdutosPed.Cells[0,grdProdutosPed.Row]+'?', mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
    begin
      var vPedido := GetPedidoByCodigo(grdProdutosPed.Cells[1,grdProdutosPed.Row]);

      if vPedido <> nil then
      begin
        vPedido.PedProdutosList.Delete(ProdutoRowIndex-1);
      end;
      
      if grdProdutosPed.Cells[0,grdProdutosPed.Row] <> '' then
      begin
        ApagarProdutoDB(StrToIntDef(grdProdutosPed.Cells[0,ProdutoRowIndex],0));
      end;

      CarregaGridPedidosProdutos(vPedido);
      grdPedidos.Cells[3,grdPedidos.Row] := FormatFloat('0.,00', GetPedidoByCodigo(grdPedidos.Cells[0,grdPedidos.Row]).ValorTotal);
    end;
  end;

  if key in [vk_Return, vk_Up, vk_down] then
  begin
    UpdatePedList(grdProdutosPed.Cells[1,grdProdutosPed.Row].ToInteger);
    grdPedidos.Cells[3,grdPedidos.Row] := FormatFloat('0.,00', GetPedidoByCodigo(grdPedidos.Cells[0,grdPedidos.Row]).ValorTotal);
    btNovoPedido.Enabled  := False;
    btGravaPedido.Enabled := True;
  end;  
  
end;

procedure TfrmMain.grdProdutosPedKeyPress(Sender: TObject; var Key: Char);
begin
  AjustarColunas(grdProdutosPed);
end;

procedure TfrmMain.grdProdutosPedKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (grdProdutosPed.Row = 0) or (grdProdutosPed.RowCount = 1) then exit;

  ProdutoRowIndex := grdProdutosPed.Row;

  var iQtd  := Str2FloatDef( grdProdutosPed.Cells[3,ProdutoRowIndex], 0);
  var vUnit := Str2FloatDef( grdProdutosPed.Cells[4,ProdutoRowIndex], 0);

  grdProdutosPed.Cells[5,ProdutoRowIndex] := FormatFloat('0.,00', iQtd * vUnit);
end;

procedure TfrmMain.grdProdutosPedSelectCell(Sender: TObject; ACol,
  ARow: LongInt; var CanSelect: Boolean);
begin
  CanSelect := ARow > 0;
end;

procedure TfrmMain.InserirPedidoLista(pPedido, pCliente: String);
begin
  var vPedido := TPedidos.Create;

  with vPedido do
  begin
    pedido      := pPedido.ToInteger;
    Emissao     := Now;
    Cliente     := pCliente.ToInteger;
    ValorTotal  := 0;
  end;
  PedidosList.Add(vPedido)

end;

procedure TfrmMain.InserirProdutoLista(pPedido: tPedidos; pProduto: String; pValorProduto: Double);
begin
  var vProduto := TPedidosProdutos.Create;

  with vProduto do
  begin
    Pedido         := pPedido.Pedido;
    Produto        := pProduto.ToInteger;
    Quantidade     := 0;
    ValorUnitario  := pValorProduto;
    ValorTotal     := 0;
  end;
  pPedido.PedProdutosList.Add(vProduto);

end;

function TfrmMain.Str2FloatDef(pStr: String; Default: Double): Double;
begin
  try
    Result := StrToFloat(StringReplace(pStr, '.', '', [rfReplaceAll]));
  except
    Result := Default;
  end;
end;

procedure TfrmMain.UpdatePedList(pPedido: Integer);
begin
  var vPedido := GetPedidoByCodigo(pPedido.ToString);

  if vPedido <> nil then
  begin
    vPedido.Cliente    := StrToIntDef( grdPedidos.Cells[2,PedidoRowIndex], 0);
    vPedido.ValorTotal := 0;

    for var vPedProdutos in vPedido.PedProdutosList do
    begin
      for var iRow := 1 to grdProdutosPed.RowCount -1 do
      begin
        if  (vPedProdutos.Pedido.ToString = grdProdutosPed.Cells[1, iRow]) and
            (vPedProdutos.Produto.ToString = grdProdutosPed.Cells[2, iRow]) then
        begin
          vPedProdutos.Quantidade    := StrToIntDef( grdProdutosPed.Cells[3, iRow], 0);
          vPedProdutos.ValorUnitario := Str2FloatDef( grdProdutosPed.Cells[4, iRow],0);
          vPedProdutos.ValorTotal    := vPedProdutos.Quantidade * vPedProdutos.ValorUnitario;

          vPedido.ValorTotal := vPedido.ValorTotal + vPedProdutos.ValorTotal;
        end;
      end;
    end;

  end;
   
end;

end.
