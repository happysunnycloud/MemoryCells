unit CellReminderThreadUnit;

interface

uses
    System.Classes

  , BaseThreadUnit
  , BaseFormUnit
  , CellUnit
//  , CommonUnit
  , ParamsExtUnit
  ;

type
  TCellReminderThread = class(TBaseThread)
  strict private
    FCell: TCell;
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
  ;

{ TCellReminderThread }

constructor TCellReminderThread.Create(
  const AForm: TBaseForm;
  const AParams: TParamsExt;
  const AProcRef: TParamsProcRef);
begin
  inherited Create(AForm);

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
begin
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

    ControlParamsProc(FProcRef, Params);
  except
    on e: Exception do
    begin
      ExceptionMessage := Format('%s: %s', [METHOD, e.Message]);
    end;
  end;
end;

end.
