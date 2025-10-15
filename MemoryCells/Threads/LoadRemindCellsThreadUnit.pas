unit LoadRemindCellsThreadUnit;

interface

uses
    System.Classes

  , BaseThreadUnit
  , BaseFormUnit
  , DataManagerUnit
  , MCParamsUnit
  ;

type
  TLoadRemindCellsThread = class(TBaseThread)
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
  , FireDAC.Stan.Error
  , DBAccessUnit
  , CellUnit
  ;

{ TLoadRemindCellsThread }

constructor TLoadRemindCellsThread.Create(
  const AForm: TBaseForm;
  const AParams: TParamsExt;
  const AProcRef: TParamsProcRef);
begin
  inherited Create(AForm);

  InParams.CopyFrom(AParams);
  FProcRef := AProcRef;
end;

procedure TLoadRemindCellsThread.Execute;
const
  METHOD = 'TLoadRemindCellsThread.Execute';
begin
  try
    Params.Clear;
    Params.CopyFrom(InParams);

    OutParams.Clear;

    TDBAccess.DBAParamsFunc(TDBAccess.RemindCells, Params, OutParams);

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
