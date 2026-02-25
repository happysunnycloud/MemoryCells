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
//var
//  RestartReminderProcRef: TProcRef;
begin
  try
    Params.Clear;
    Params.CopyFrom(InParams);

//    RestartReminderProcRef := nil;
//    if Params.IfAsBooleanByIdent('RestartReminder', true) then
//      RestartReminderProcRef := TMainForm(Form).RestartReminder;

    LoadCatalog(
      Params,
      TMainForm(Form).BuildFolderCatalog,
      TMainForm(Form).OpenCell);
  except
    on e: Exception do
    begin
      ExceptionMessage := Format('%s: %s', [METHOD, e.Message]);
    end;
  end;
end;

end.
