unit LoadDestinationCatalogThreadUnit;

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
  TLoadDestinationCatalogThread = class(TBaseThread)
  strict private
    FBuildDestinationCatalogProcRef: TParamsProcRef;
  protected
    procedure Execute; override;
  public
    constructor Create(
      const AForm: TBaseForm;
      const AParams: TParamsExt;
      const ABuildDestinationCatalogProcRef: TParamsProcRef);  reintroduce;
  end;

implementation

uses
    System.SysUtils
  , FireDAC.Stan.Error
  , DBAccessUnit
  , CellUnit
  ;

{ TLoadDestinationCatalogThread }

constructor TLoadDestinationCatalogThread.Create(
  const AForm: TBaseForm;
  const AParams: TParamsExt;
  const ABuildDestinationCatalogProcRef: TParamsProcRef);
begin
  inherited Create(AForm);

  Name := 'TLoadDestinationCatalogThread';

  InParams.CopyFrom(AParams);
  FBuildDestinationCatalogProcRef := ABuildDestinationCatalogProcRef;
end;

procedure TLoadDestinationCatalogThread.Execute;
const
  METHOD = 'TLoadDestinationCatalogThread.Execute';
var
  FolderId: Int64;
begin
  try
    Params.Clear;
    Params.CopyFrom(InParams);

    FolderId := Params.AsInt64[0];

    Params.Clear;
    Params.Add(FolderId);

    OutParams.Clear;

    TDBAccess.DBAParamsFunc(TDBAccess.LoadDestinationCatalog, Params, OutParams);

    Params.Clear;
    Params.Add(FolderId);
    Params.Add(OutParams.AsPointer[0]);

    ControlParamsProc(FBuildDestinationCatalogProcRef, Params);
  except
    on e: Exception do
    begin
      ExceptionMessage := Format('%s: %s', [METHOD, e.Message]);
    end;
  end;
end;

end.
