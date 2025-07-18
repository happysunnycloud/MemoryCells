unit LoadCellReminderThreadUnit;

interface

uses
    System.Classes

  , BaseThreadUnit
  , BaseFormUnit
  , DataManagerUnit
//  , CommonUnit
  , CellUnit
  , MCParamsUnit
  ;

type
  TLoadCellReminderThread = class(TBaseThread)
  strict private
    FProcRef: TParamsProcRef;
  protected
    procedure Execute; override;
  public
    constructor Create(
      const AForm: TBaseForm;
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
  const AForm: TBaseForm;
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

procedure TLoadCellReminderThread.Execute;
const
  METHOD = 'TLoadCellReminderThread.Execute';
begin
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
  except
    on e: Exception do
    begin
      ExceptionMessage := Format('%s: %s', [METHOD, e.Message]);
    end;
  end;
end;

end.
