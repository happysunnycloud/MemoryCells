unit CellReminderThreadUnit;

interface

uses
    System.Classes

  , BaseThreadUnit
  , FMX.FormExtUnit
  , CellUnit
  , MCParamsUnit
  , ThreadFactoryUnit
  ;

type
  TCellReminderThread = class(TBaseThread)
  strict private
    FCell: TCell;
    FProcRef: TParamsProcRef;
  protected
    procedure Execute(const AThread: TThreadExt); reintroduce;
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
  , AddLogUnit
  ;

{ TCellReminderThread }

constructor TCellReminderThread.Create(
  const AForm: TFormExt;
  const AParams: TParamsExt;
  const AProcRef: TParamsProcRef);
begin
  inherited Create(AForm, Execute);

  FCell := TCell.Create;
  InParams.CopyFrom(AParams);
  FCell.CopyFrom(InParams.AsPointer[0]);
  FProcRef := AProcRef;
end;

destructor TCellReminderThread.Destroy;
begin
  FreeAndNil(FCell);

  inherited;
end;

procedure TCellReminderThread.Execute;
const
  METHOD = 'TCellReminderThread.Execute';
var
  RemindDateTime: TDateTime;
  Params: TParamsExt;
begin
  try
    Params := TParamsExt.Create;
    try
      RemindDateTime := FCell.RemindDateTime;

      while (RemindDateTime > Now) and (not Terminated) do
      begin
        Sleep(100);
      end;

      if Terminated then
        Exit;

      Params.Clear;
      Params.Add(FCell);

      TLogger.AddLog('TCellReminderThread.Execute -> Таймер сработал', MG);
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
