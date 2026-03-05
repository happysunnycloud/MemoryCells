unit LoadCatalogThreadUnit;

interface

uses
    System.Classes
  , BaseThreadUnit
  , FMX.FormExtUnit
  , DataManagerUnit
  , MCParamsUnit
  , ThreadFactoryUnit
  ;

type
  TLoadCatalogThread = class(TBaseThread)
  protected
    procedure InnerExecute; override;
  public
    constructor Create(
      const AForm: TFormExt;
      const AParams: TParamsExt); reintroduce;
  end;

implementation

uses
    System.SysUtils
  , FireDAC.Stan.Error
  , DBAccessUnit
  , CellUnit
  , MemoryCellsUnit
  ;

{ TLoadCatalogThread }

constructor TLoadCatalogThread.Create(
  const AForm: TFormExt;
  const AParams: TParamsExt);
begin
  inherited Create(AForm);

  InParams.CopyFrom(AParams);
end;

procedure TLoadCatalogThread.InnerExecute;
const
  METHOD = 'TLoadCatalogThread.InnerExecute';
var
  CellList: TCellList;
  FolderId: Int64;
  Params: TParamsExt;
begin
  try
    FolderId := InParams.AsInt64ByIdent['FolderId'];

    Params := TParamsExt.Create;
    try
      Params.Clear;
      Params.Add(FolderId, 'FolderId');

      TDBAccess.DBAParamsFunc(TDBAccess.LoadCatalog, Params, OutParams);

      CellList := OutParams.AsPointerByIdent['CellList'];

      Params.Clear;
      Params.Add(FolderId, 'FolderId');
      Params.Add(CellList, 'CellList');

      ControlParamsProc(TMainForm(Form).BuildFolderCatalog, Params);
    finally
      FreeAndNil(Params);
    end;
  except
    on e: Exception do
    begin
      ExceptionMessage := Format('%s: %s', [METHOD, e.Message]);
    end;
  end;
end;

end.
