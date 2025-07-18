unit UpdateCellAttributesThreadUnit;

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
  TUpdateCellAttributesThread = class(TBaseThread)
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
  ;

{ TUpdateCellAttributesThread }

constructor TUpdateCellAttributesThread.Create(
  const AForm: TBaseForm;
  const AParams: TParamsExt;
  const AProcRef: TParamsProcRef);
begin
  inherited Create(AForm);

  InParams.CopyFrom(AParams);
  FProcRef := AProcRef;
end;

procedure TUpdateCellAttributesThread.Execute;
const
  METHOD = 'TUpdateCellAttributesThread.Execute';
begin
  try
    Params.Clear;
    Params.CopyFrom(InParams);

    TDBAccess.DBAParamsFunc(TDBAccess.UpdateCellAttributes, Params, nil);

    ControlParamsProc(FProcRef, Params);
  except
    on e: Exception do
    begin
      ExceptionMessage := Format('%s: %s', [METHOD, e.Message]);
    end;
  end;
end;

end.
