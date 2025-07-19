unit LoadCellThreadUnit;

interface

uses
    System.Classes

  , BaseThreadUnit
  , BaseFormUnit
  , DataManagerUnit
//  , CommonUnit
  , MCParamsUnit
  ;

type
  TLoadCellThread = class(TBaseThread)
  strict private
    FProcRef: TParamsProcRef;
  protected
    procedure Execute; override;
  public
    constructor Create(
      const AForm: TBaseForm;
      const AParams: TParamsExt;
      const AProcRef: TParamsProcRef); reintroduce;
  end;

implementation

uses
    System.SysUtils
  , DBAccessUnit
  , CellUnit
  ;

{ TLoadCellThread }

constructor TLoadCellThread.Create(
  const AForm: TBaseForm;
  const AParams: TParamsExt;
  const AProcRef: TParamsProcRef);
begin
  inherited Create(AForm);

  InParams.CopyFrom(AParams);
  FProcRef := AProcRef;
end;

procedure TLoadCellThread.Execute;
const
  METHOD = 'TLoadCellThread.Execute';
begin
  try
    Params.Clear;
    Params.CopyFrom(InParams);

    OutParams.Clear;

    TDBAccess.DBAParamsFunc(TDBAccess.LoadCell, Params, OutParams);

    Params.Clear;
    Params.CopyFrom(OutParams);
    Params.Add(false, 'OpenCellReminderPanel');

    ControlParamsProc(FProcRef, Params);
  except
    on e: Exception do
    begin
      ExceptionMessage := Format('%s: %s', [METHOD, e.Message]);
    end;
  end;
end;

end.
