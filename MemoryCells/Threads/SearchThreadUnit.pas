unit SearchThreadUnit;

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
  TSearchThread = class(TBaseThread)
  strict private
    FProcRef: TParamsProcRef;
  protected
    procedure InnerExecute; override;
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

{ TSearchThread }

constructor TSearchThread.Create(
  const AForm: TFormExt;
  const AParams: TParamsExt;
  const AProcRef: TParamsProcRef);
begin
  inherited Create(AForm);

  InParams.CopyFrom(AParams);
  FProcRef := AProcRef;
end;

procedure TSearchThread.InnerExecute;
const
  METHOD = 'TSearchThread.InnerExecute';
var
  Params: TParamsExt;
begin
  try
    Params := TParamsExt.Create;
    try
      Params.Clear;
      Params.CopyFrom(InParams);

      OutParams.Clear;

      TDBAccess.DBAParamsFunc(TDBAccess.Search, Params, OutParams);

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
