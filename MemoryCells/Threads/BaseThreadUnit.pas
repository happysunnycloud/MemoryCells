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

//const
//  TIME_OUT_SECONDS = 4;

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
    // Параметры для использования внутри Execute в качестве локальной переменной
//    FParams: TParamsExt;
    // Входные параметры, манипуляций с ними не производим, нужны для отслеживания, того что пришло на в ход
    FInParams: TParamsExt;
    // Выходные параметры
    FOutParams: TParamsExt;
  protected
    property Form: TFormExt read FForm;
    property ExceptionMessage: String read FExceptionMessage write FExceptionMessage;
//    property Params: TParamsExt read FParams write FParams;
    property InParams: TParamsExt read FInParams write FInParams;
    property OutParams: TParamsExt read FOutParams write FOutParams;

    // Специально не перегружаем Execute,
    // чтобы выполнился на стороне родительского класса
    // В родителе ловятся исключения
    //procedure Execute(const AThread: TThreadExt); reintroduce; // override;

    procedure ControlParamsProc(
      const AParamsProcRef: TParamsProcRef;
      const AParams: TParamsExt);

//    procedure LoadCatalog(
//      const AInParams: TParamsExt;
//      const ABuildCatalogProcRef: TParamsProcRef;
//      const AOpenCellProcRef: TParamsProcRef);
  public
    constructor Create(
      const AForm: TFormExt;
      const AExecProc: TExecProc); virtual;
    destructor Destroy; override;
  end;

implementation

uses
    System.SysUtils
  , FMX.Dialogs
  , FireDAC.Stan.Error
  , FireDAC.Phys.SQLiteWrapper
  , ExceptionContainerUnit
//  , DBAccessUnit
  , CellUnit
  , AddLogUnit
  ;

{ TBaseThread }

constructor TBaseThread.Create(
  const AForm: TFormExt;
  const AExecProc: TExecProc);
begin
  FExceptionMessage := '';

  FForm := AForm;

  FreeOnTerminate := true;

  FInParams := TParamsExt.Create;
  FOutParams := TParamsExt.Create;

  inherited Create(
    FForm.ThreadFactory,
    '',
    AExecProc);
end;

//constructor TBaseThread.Create(
//  const AForm: TFormExt;
//  const AThreadName: String;
//  const AExecProc: TExecProc);
//begin
//  FExceptionMessage := '';
//
//  FForm := AForm;
//
//  FreeOnTerminate := true;
//
//  FInParams := TParamsExt.Create;
//  FOutParams := TParamsExt.Create;
//
//  inherited Create(
//    FForm.ThreadFactory,
//    AThreadName,
//    AExecProc);
//end;

destructor TBaseThread.Destroy;
var
  ExceptionMessage: String;
begin
  ExceptionMessage := FExceptionMessage;

//  FForm.ThreadFactory.UnRegisterThread(Self);

  if Length(Trim(ExceptionMessage)) > 0 then
  begin
    TLogger.AddLog('TBaseThread.Destroy: ' + ExceptionMessage, ER);
    TThread.ForceQueue(nil,
      procedure
      begin
        ShowMessage('TBaseThread.Destroy: ' + ExceptionMessage);
      end);
  end;

//  FreeAndNil(FParams);
  FreeAndNil(FInParams);
  FreeAndNil(FOutParams);

  inherited Destroy;
end;

//procedure TBaseThread.Execute;
//begin
//  { Place thread code here }
//end;

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

//procedure TBaseThread.LoadCatalog(
//  const AInParams: TParamsExt;
//  const ABuildCatalogProcRef: TParamsProcRef;
//  const AOpenCellProcRef: TParamsProcRef);
//const
//  METHOD = 'TBaseThread.LoadCatalog';
//var
//  CellList: TCellList;
//  OutParams: TParamsExt;
//  FolderId: Int64;
//  CellId: Int64;
//  InnerParams: TParamsExt;
//begin
//  FolderId := AInParams.AsInt64ByIdent['FolderId'];
//  CellId := AInParams.AsInt64ByIdent['CellId'];
//
//  OutParams := TParamsExt.Create;
//  try
//    InnerParams := TParamsExt.Create;
//    try
//      InnerParams.Add(FolderId, 'FolderId');
//
//      TDBAccess.DBAParamsFunc(TDBAccess.LoadCatalog, InnerParams, OutParams);
//
//      CellList := OutParams.AsPointerByIdent['CellList'];
//
//      InnerParams.Clear;
//      InnerParams.Add(FolderId, 'FolderId');
//      InnerParams.Add(CellList, 'CellList');
//
//      ControlParamsProc(ABuildCatalogProcRef, InnerParams);
//    finally
//      FreeAndNil(InnerParams);
//    end;
//  finally
//    FreeAndNil(OutParams);
//  end;
//end;

end.
