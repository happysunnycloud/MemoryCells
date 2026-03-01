unit LoadCatalogThreadUnit;

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
  TLoadCatalogThread = class(TBaseThread)
  protected
    procedure Execute(const AThread: TThreadExt); reintroduce;
  public
    constructor Create(
      const AForm: TFormExt;
      const AParams: TParamsExt); reintroduce;
  end;

implementation

uses
    System.SysUtils
  , FireDAC.Stan.Error
  , DBAccessUnit
  , CellUnit
  , MemoryCellsUnit
  ;

{ TLoadCatalogThread }

constructor TLoadCatalogThread.Create(
  const AForm: TFormExt;
  const AParams: TParamsExt);
begin
  inherited Create(AForm, Execute);

  InParams.CopyFrom(AParams);
end;

procedure TLoadCatalogThread.Execute(const AThread: TThreadExt);
const
  METHOD = 'TLoadCatalogThread.Execute';
var
  Params: TParamsExt;
begin
  try
    Params := TParamsExt.Create;
    try
      Params.Clear;
      Params.CopyFrom(InParams);

      LoadCatalog(
        Params,
        TMainForm(Form).BuildFolderCatalog,
        TMainForm(Form).OpenCell,
        TMainForm(Form).RestartReminder);
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
