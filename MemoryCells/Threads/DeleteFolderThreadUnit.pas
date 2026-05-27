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
    procedure InnerExecute; override;
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
  inherited Create(AForm);

  InParams.CopyFrom(AParams);
  FProcRef := AProcRef;
  FDeleteFolderError := ADeleteFolderError;
end;

procedure TDeleteFolderThread.InnerExecute;
const
  METHOD = 'TDeleteFolderThread.InnerExecute';
var
  FolderId: Int64;
  ResultCode: TDBAResultCode;
  Params: TParamsExt;
begin
  try
    Params := TParamsExt.Create;
    try
      Params.Clear;
      Params.CopyFrom(InParams);

      FolderId := Params.AsInt64ByIdent['FolderId'];

      Params.Clear;
      Params.Add(FolderId);
      ResultCode := TDBAccess.DBAParamsFunc(TDBAccess.DeleteFolder, Params, nil);

      if ResultCode <> TDBAResultCode.rcFolderIsNotEmpty then
      begin
        ControlParamsProc(FProcRef, Params);
      end
      else
      begin
        Params.Clear;
        Params.Add(ResultCode);

        ControlParamsProc(FDeleteFolderError, Params);
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
