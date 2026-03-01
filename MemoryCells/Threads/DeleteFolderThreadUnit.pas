unit DeleteFolderThreadUnit;

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
  TDeleteFolderThread = class(TBaseThread)
  strict private
    FProcRef: TParamsProcRef;
    FDeleteFolderError: TParamsProcRef;
  protected
    procedure Execute(const AThread: TThreadExt); reintroduce;
  public
    constructor Create(
      const AForm: TFormExt;
      const AParams: TParamsExt;
      const AProcRef: TParamsProcRef;
      const ADeleteFolderError: TParamsProcRef); reintroduce;
  end;

implementation

uses
    System.SysUtils
  , DBAccessUnit
  , CellUnit
  ;

{ TDeleteFolderThread }

constructor TDeleteFolderThread.Create(
  const AForm: TFormExt;
  const AParams: TParamsExt;
  const AProcRef: TParamsProcRef;
  const ADeleteFolderError: TParamsProcRef);
begin
  inherited Create(AForm, Execute);

  InParams.CopyFrom(AParams);
  FProcRef := AProcRef;
  FDeleteFolderError := ADeleteFolderError;
end;

procedure TDeleteFolderThread.Execute;
const
  METHOD = 'TDeleteFolderThread.Execute';
var
  FolderId: Int64;
  ParentFolderId: Int64;
  ResultCode: TDBAResultCode;
  CellList: TCellList;
  Params: TParamsExt;
begin
  try
    Params := TParamsExt.Create;
    try
      Params.Clear;
      Params.CopyFrom(InParams);

      FolderId := Params.AsInt64[0];
      ParentFolderId := Params.AsInt64[1];

      Params.Clear;
      Params.Add(FolderId);
      ResultCode := TDBAccess.DBAParamsFunc(TDBAccess.DeleteFolder, Params, nil);

      if ResultCode <> TDBAResultCode.rcFolderIsNotEmpty then
      begin
        Params.Clear;
        Params.Add(ParentFolderId);
        Params.Add(CellList);

        TDBAccess.DBAParamsFunc(TDBAccess.LoadCatalog, Params, OutParams);

        CellList := OutParams.AsPointer[0];

        Params.Clear;
        Params.Add(ParentFolderId);
        Params.Add(CellList);

        ControlParamsProc(FProcRef, Params);
      end
      else
      begin
        CellList := TCellList.Create;
        try
          Params.Clear;
          Params.Add(ResultCode);

          ControlParamsProc(FDeleteFolderError, Params);
        finally
          FreeAndNil(CellList);
        end;
      end;
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
