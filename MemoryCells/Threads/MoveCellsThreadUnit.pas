unit MoveCellsThreadUnit;

interface

uses
    System.Classes

  , BaseThreadUnit
  , BaseFormUnit
  , DataManagerUnit
  , CommonUnit
  , CellUnit
  , MCParamsUnit
  ;

type
  TMoveCellsThread = class(TBaseThread)
  protected
    procedure Execute; override;
  public
    constructor Create(
      const AForm: TBaseForm;
      const AParams: TParamsExt); reintroduce;
    destructor Destroy; override;
  end;

implementation

uses
    System.SysUtils
  , DBAccessUnit
  , MemoryCellsUnit
  ;

{ TMoveCellsThread }

constructor TMoveCellsThread.Create(
  const AForm: TBaseForm;
  const AParams: TParamsExt);

begin
  inherited Create(AForm);

  InParams.CopyFrom(AParams);
end;

destructor TMoveCellsThread.Destroy;
begin
  inherited;
end;

procedure TMoveCellsThread.Execute;
const
  METHOD = 'TMoveCellsThread.Execute';
var
  FolderId: Int64;
  CellId: Int64;
  SourceFolderId: Int64;
  DestinationFolderId: Int64;
  CellIdList: TCellIdList;
  ActionType: TActionType;
begin
  try
    SourceFolderId := InParams.AsInt64[0];
    DestinationFolderId := InParams.AsInt64[1];
    CellIdList := TCellIdList(InParams.AsPointer[2]);
    ActionType := TActionType(InParams.AsByte[3]);

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

    FolderId := SourceFolderId;
    CellId := NULL_ID;

    Params.Clear;
    Params.Add(FolderId);
    Params.Add(CellId);

    LoadCatalog(Params, TMainForm(Form).BuildFolderCatalog, nil);
  except
    on e: Exception do
    begin
      ExceptionMessage := Format('%s: %s', [METHOD, e.Message]);
    end;
  end;
end;

end.
