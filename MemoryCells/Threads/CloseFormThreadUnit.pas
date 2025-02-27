unit CloseFormThreadUnit;

interface

uses
    System.Classes

  , BaseFormUnit
  ;

type
  TCloseFormThread = class(TThread)
  private
    FForm: TBaseForm;
    // Выполняется в основном потоке, не требует синхронизации
    procedure OnTerminateHandler(Sender: TObject);
  protected
    procedure Execute; override;
  public
    constructor Create(const AForm: TBaseForm);
  end;

implementation

uses
    AddLogUnit
  ;

{ TCloseFormThread }

procedure TCloseFormThread.OnTerminateHandler(Sender: TObject);
begin
  FForm.CanClose := true;
  FForm.Close;
end;

constructor TCloseFormThread.Create(const AForm: TBaseForm);
begin
  inherited Create(false);

  FForm := AForm;

  FreeOnTerminate := true;

  Self.OnTerminate := OnTerminateHandler;
end;

procedure TCloseFormThread.Execute;
var
  i: Word;
begin
  TLogger.AddLog('TCloseFormThread.Execute.Enter',MG);
  if not Assigned(FForm) then
    TLogger.AddLog('FForm not assigned',MG)
  else
    TLogger.AddLog('FForm assigned',MG);
  if not Assigned(FForm.ThreadRegistry) then
    TLogger.AddLog('FForm.ThreadRegistry not assigned',MG)
  else
    TLogger.AddLog('FForm.ThreadRegistry assigned',MG);

//  TLogger.AddLog('TCloseFormThread.Execute.Point 1',MG);

  i := FForm.ThreadRegistry.Count;
  while i > 0 do
  begin
    Dec(i);

    TThread(FForm.ThreadRegistry.ThreadByIndex(i)).Terminate;
  end;

//  TLogger.AddLog('TCloseFormThread.Execute.Point 2',MG);

  while FForm.ThreadRegistry.Count > 0 do
    Sleep(300);

//  TLogger.AddLog('TCloseFormThread.Execute.Point 3',MG);

  TLogger.AddLog('TCloseFormThread.Execute.Leave',MG);
end;

end.
