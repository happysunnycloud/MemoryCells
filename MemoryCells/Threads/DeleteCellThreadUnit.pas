unit DeleteCellThreadUnit;

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
  TDeleteCellThread = class(TBaseThread)
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

{ InsertCellThread }

constructor TDeleteCellThread.Create(
  const AForm: TBaseForm;
  const AParams: TParamsExt;
  const AProcRef: TParamsProcRef);
begin
  inherited Create(AForm);

  InParams.CopyFrom(AParams);
  FProcRef := AProcRef;
end;

procedure TDeleteCellThread.Execute;
const
  METHOD = 'TDeleteCellThread.Execute';
var
  CellId: Int64;
begin
  try
    Params.Clear;
    Params.CopyFrom(InParams);

    CellId := Params.AsInt64[0];

    TDBAccess.DBAParamsFunc(TDBAccess.DeleteCell, Params, nil);

    OutParams.Clear;
    OutParams.Add(CellId);

    ControlParamsProc(FProcRef, OutParams);
  except
    on e: Exception do
    begin
      ExceptionMessage := Format('%s: %s', [METHOD, e.Message]);
    end;
  end;
end;

end.
