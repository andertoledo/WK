unit uPedidosClass;

interface

uses System.Generics.Collections, System.SysUtils;

type

  tPedidosProdutos = class
    Id            : Integer;
    Pedido        : Integer;
    Produto       : Integer;
    Quantidade    : Integer;
    ValorUnitario : Double;
    ValorTotal    : Double;
  end;

  tPedidos = class
    Pedido     : Integer;
    Emissao    : TDateTime;
    Cliente    : Integer;
    ValorTotal : Double;
    PedProdutosList : TObjectList<tPedidosProdutos>;
  public
    constructor Create;
    destructor Destroy;
  end;

implementation

{ tPedidos }

constructor tPedidos.Create;
begin
  PedProdutosList := TObjectList<tPedidosProdutos>.Create;
end;

destructor tPedidos.Destroy;
begin
  FreeAndNil( PedProdutosList );
end;

end.
