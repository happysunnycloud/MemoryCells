unit MoveCellsThreadUnit;

interface

uses
    System.Classes
  , BaseThreadUnit
  , FMX.FormExtUnit
  , DataManagerUnit
  , CellUnit
  , MCParamsUnit
  , ThreadFactoryUnit
  ;

type
  TMoveCellsThread = class(TBaseThread)
  protected
    procedure InnerExecute; override;
  public
    constructor Create(
      const AForm: TFormExt;
      const AParams: TParamsExt); reintroduce;
    destructor Destroy; override;
  end;

implementation

uses
    System.SysUtils
  , DBAccessUnit
  , MemoryCellsUnit
  , CommonUnit
  ;

{ TMoveCellsThread }

constructor TMoveCellsThread.Create(
  const AForm: TFormExt;
  const AParams: TParamsExt);
begin
  inherited Create(AForm);

  InParams.CopyFrom(AParams);
end;

destructor TMoveCellsThread.Destroy;
begin
  inherited;
end;

procedure TMoveCellsThread.InnerExecute;
const
  METHOD = 'TMoveCellsThread.InnerExecute';
var
//  FolderId: Int64;
//  CellId: Int64;
//  SourceFolderId: Int64;
  DestinationFolderId: Int64;
  CellIdList: TCellIdList;
  ActionType: TActionType;
  Params: TParamsExt;
begin
  try
    Params := TParamsExt.Create;
    try
//      SourceFolderId := InParams.AsInt64ByIdent['SourceFolderId'];
      DestinationFolderId := InParams.AsInt64ByIdent['DestinationFolderId'];
      CellIdList := TCellIdList(InParams.AsPointerByIdent['CellIdList']);
      ActionType := TActionType(InParams.AsByteByIdent['ActionType']);

      Params.Clear;
      Params.Add(DestinationFolderId);
      Params.Add(CellIdList);

      if ActionType = atMove then
        TDBAccess.DBAParamsFunc(TDBAccess.UpdateCellDestinationFolder, Params, nil)
      else
      if ActionType = atCopy then
        TDBAccess.DBAParamsFunc(TDBAccess.InsertDestinationCell, Params, nil)
      else
        raise Exception.Create('Unidentified variable value of TActionType');
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
