unit BaseCellFrameUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls
  , CellUnit
  , ParamsExtUnit
  ;

type
  TBaseCellFrame = class(TFrame)
  private
    FParams: TParamsExt;
    FCell: TCell;

    procedure SetCell(const ACell: TCell);

    procedure Init(AOwner: TComponent; const ACell: TCell);
  public
    constructor Create(AOwner: TComponent; const ACell: TCell); reintroduce; overload;
    constructor Create(AOwner: TComponent); reintroduce; overload;
    destructor Destroy; override;

    property Cell: TCell read FCell write SetCell;
    property Params: TParamsExt read FParams write FParams;
  end;

implementation

{$R *.fmx}

procedure TBaseCellFrame.Init(AOwner: TComponent; const ACell: TCell);
begin
  FCell := TCell.Create;
  FParams := TParamsExt.Create;
  if Assigned(ACell) then
    FCell.CopyFrom(ACell);
end;

constructor TBaseCellFrame.Create(AOwner: TComponent; const ACell: TCell);
begin
  inherited Create(AOwner);

  Init(AOwner, ACell);
end;

constructor TBaseCellFrame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Init(AOwner, nil);
end;

destructor TBaseCellFrame.Destroy;
begin
  FreeAndNil(FCell);
  FreeAndNil(FParams);

  inherited;
end;

procedure TBaseCellFrame.SetCell(const ACell: TCell);
begin
  FCell := ACell;
end;

end.
