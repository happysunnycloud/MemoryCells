// У формы могут быть привязанные к ней потоки
// При закрытии, форма ждет пока все они завершатся
unit BaseThreadUnit;

interface

uses
    System.Classes
  , MCParamsUnit
  , DBAccessUnit
  , ThreadFactoryUnit
  , FMX.FormExtUnit
  ;

type
  TProcRef = reference to procedure;
  TParamsProcRef = reference to procedure(const AParams: TParamsExt);
  TParamIdProcRef = reference to procedure(const AId: Int64);

  TBaseThread = class(TThreadExt)
  strict private
    FStrictedParams: TParamsExt;
  private
    FForm: TFormExt;
    FExceptionMessage: String;
    // Входные параметры, манипуляций с ними не производим,
    // нужны для отслеживания, того что пришло на в ход
    FInParams: TParamsExt;
    // Выходные параметры
    FOutParams: TParamsExt;
  protected
    property Form: TFormExt read FForm;
    property ExceptionMessage: String read FExceptionMessage write FExceptionMessage;
    property InParams: TParamsExt read FInParams write FInParams;
    property OutParams: TParamsExt read FOutParams write FOutParams;

    // Специально не перегружаем Execute,
    // чтобы выполнился на стороне родительского класса
    // В родителе ловятся исключения
    //procedure Execute(const AThread: TThreadExt); reintroduce; // override;

    procedure ControlParamsProc(
      const AParamsProcRef: TParamsProcRef;
      const AParams: TParamsExt);
  public
    constructor Create(
      const AForm: TFormExt); overload; virtual;
    destructor Destroy; override;
  end;

implementation

uses
    System.SysUtils
  , FMX.Dialogs
  , FireDAC.Stan.Error
  , FireDAC.Phys.SQLiteWrapper
  , ExceptionContainerUnit
  , CellUnit
  , AddLogUnit
  ;

{ TBaseThread }

constructor TBaseThread.Create(
  const AForm: TFormExt);
begin
  FExceptionMessage := '';

  FForm := AForm;

  FreeOnTerminate := true;

  FInParams := TParamsExt.Create;
  FOutParams := TParamsExt.Create;

  inherited Create(
    FForm.ThreadFactory,
    '');
end;

destructor TBaseThread.Destroy;
var
  ExceptionMessage: String;
begin
  ExceptionMessage := FExceptionMessage;

  if Length(Trim(ExceptionMessage)) > 0 then
  begin
    TLogger.AddLog('TBaseThread.Destroy: ' + ExceptionMessage, ER);
    TThread.ForceQueue(nil,
      procedure
      begin
        ShowMessage('TBaseThread.Destroy: ' + ExceptionMessage);
      end);
  end;

  FreeAndNil(FInParams);
  FreeAndNil(FOutParams);

  inherited Destroy;
end;

procedure TBaseThread.ControlParamsProc(
  const AParamsProcRef: TParamsProcRef;
  const AParams: TParamsExt);
const
  METHOD = 'TBaseThread.ControlParamsProc';
var
  ParamsProcRef: TParamsProcRef absolute AParamsProcRef;
begin
  if not Assigned(ParamsProcRef) then
    Exit;

  FStrictedParams := TParamsExt.Create;
  try
    if Assigned(AParams) then
      FStrictedParams.CopyFrom(AParams);
    try
      Synchronize(procedure
        begin
          ParamsProcRef(FStrictedParams);
        end);
    except
      on e: Exception do
      begin
        raise Exception.CreateFmt('%s: %s', [METHOD, e.Message]);
      end;
    end;
  finally
    FreeAndNil(FStrictedParams);
  end;
end;

end.
