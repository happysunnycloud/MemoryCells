unit LoadCellReminderThreadUnit;

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
  TLoadCellReminderThread = class(TBaseThread)
  strict private
    FProcRef: TParamsProcRef;
  protected
    procedure InnerExecute; override;
  public
    constructor Create(
      const AForm: TFormExt;
      const AParams: TParamsExt;
      const AProcRef: TParamsProcRef); reintroduce;
    destructor Destroy; override;
  end;

implementation

uses
    System.SysUtils
  , DBAccessUnit
  ;

{ TLoadCellReminderThread }

constructor TLoadCellReminderThread.Create(
  const AForm: TFormExt;
  const AParams: TParamsExt;
  const AProcRef: TParamsProcRef);
begin
  inherited Create(AForm);

  InParams.CopyFrom(AParams);
  FProcRef := AProcRef;
end;

destructor TLoadCellReminderThread.Destroy;
begin
  inherited;
end;

procedure TLoadCellReminderThread.InnerExecute;
const
  METHOD = 'TLoadCellReminderThread.InnerExecute';
var
  Params: TParamsExt;
begin
  try
    Params := TParamsExt.Create;
    try
      Params.Clear;
      Params.CopyFrom(InParams);

      OutParams.Clear;

      TDBAccess.DBAParamsFunc(TDBAccess.LoadCellReminder, Params, OutParams);

      if Terminated then
        Exit;

      Params.Clear;
      Params.CopyFrom(OutParams);

      ControlParamsProc(FProcRef, Params);
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
