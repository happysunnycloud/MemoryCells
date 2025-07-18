unit UpdateCellThreadUnit;

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
  TUpdateCellThread = class(TBaseThread)
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

{ TUpdateCellThread }

constructor TUpdateCellThread.Create(
  const AForm: TBaseForm;
  const AParams: TParamsExt;
  const AProcRef: TParamsProcRef);
begin
  inherited Create(AForm);

  InParams.CopyFrom(AParams);
  FProcRef := AProcRef;
end;

procedure TUpdateCellThread.Execute;
const
  METHOD = 'TUpdateCellThread.Execute';
begin
  try
    Params.Clear;
    Params.CopyFrom(InParams);

    TDBAccess.DBAParamsFunc(TDBAccess.UpdateCell, Params, nil);

    ControlParamsProc(FProcRef, Params);
  except
    on e: Exception do
    begin
      ExceptionMessage := Format('%s: %s', [METHOD, e.Message]);
    end;
  end;
end;

end.
