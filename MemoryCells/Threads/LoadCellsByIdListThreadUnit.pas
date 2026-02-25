unit LoadCellsByIdListThreadUnit;

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
  TLoadCellsByIdListThread = class(TBaseThread)
  strict private
    FProcRef: TParamsProcRef;
  protected
    procedure Execute(const AThread: TThreadExt); reintroduce;
  public
    constructor Create(
      const AForm: TFormExt;
      const AParams: TParamsExt;
      const AProcRef: TParamsProcRef); reintroduce;
  end;

implementation

uses
    System.SysUtils
  , FireDAC.Stan.Error
  , DBAccessUnit
  , CellUnit
  ;

{ TLoadCellsByIdListThread }

constructor TLoadCellsByIdListThread.Create(
  const AForm: TFormExt;
  const AParams: TParamsExt;
  const AProcRef: TParamsProcRef);
begin
  inherited Create(AForm, Execute);

  InParams.CopyFrom(AParams);
  FProcRef := AProcRef;
end;

procedure TLoadCellsByIdListThread.Execute;
const
  METHOD = 'TLoadCellsByIdListThread.Execute';
begin
  try
    Params.Clear;
    Params.CopyFrom(InParams);

    OutParams.Clear;

    TDBAccess.DBAParamsFunc(TDBAccess.CellsByIdList, Params, OutParams);

    Params.Clear;
    Params.Add(OutParams);

    ControlParamsProc(FProcRef, OutParams);
  except
    on e: Exception do
    begin
      ExceptionMessage := Format('%s: %s', [METHOD, e.Message]);
    end;
  end;
end;

end.
