unit LoadCatalogThreadUnit;

interface

uses
    System.Classes

  , BaseThreadUnit
  , BaseFormUnit
  , DataManagerUnit
  , MCParamsUnit
  ;

type
  TLoadCatalogThread = class(TBaseThread)
  protected
    procedure Execute; override;
  public
    constructor Create(
      const AForm: TBaseForm;
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
  const AForm: TBaseForm;
  const AParams: TParamsExt);
begin
  inherited Create(AForm);

  InParams.CopyFrom(AParams);
end;

procedure TLoadCatalogThread.Execute;
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
