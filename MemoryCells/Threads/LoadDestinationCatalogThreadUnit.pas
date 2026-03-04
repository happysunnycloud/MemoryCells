unit LoadDestinationCatalogThreadUnit;

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
  TLoadDestinationCatalogThread = class(TBaseThread)
  strict private
    FBuildDestinationCatalogProcRef: TParamsProcRef;
  protected
    procedure Execute(const AThread: TThreadExt); reintroduce;
  public
    constructor Create(
      const AForm: TFormExt;
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
  const AForm: TFormExt;
  const AParams: TParamsExt;
  const ABuildDestinationCatalogProcRef: TParamsProcRef);
begin
  inherited Create(AForm, Execute);

//  Name := 'TLoadDestinationCatalogThread';

  InParams.CopyFrom(AParams);
  FBuildDestinationCatalogProcRef := ABuildDestinationCatalogProcRef;
end;

procedure TLoadDestinationCatalogThread.Execute;
const
  METHOD = 'TLoadDestinationCatalogThread.Execute';
var
  FolderId: Int64;
  CellList: TCellList;
  Params: TParamsExt;
begin
  try
    Params := TParamsExt.Create;
    try
      Params.Clear;
      Params.CopyFrom(InParams);

      FolderId := Params.AsInt64ByIdent['FolderId'];

      Params.Clear;
      Params.Add(FolderId);

      OutParams.Clear;

      TDBAccess.DBAParamsFunc(TDBAccess.LoadDestinationCatalog, Params, OutParams);

      CellList := OutParams.AsPointerByIdent['CellList'];

      Params.Clear;
      Params.Add(FolderId);
      Params.Add(CellList);

      ControlParamsProc(FBuildDestinationCatalogProcRef, Params);
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
