// У формы могут быть привязанные к ней потоки
// При закрытии, форма ждет пока все они завершатся
unit BaseThreadUnit;

interface

uses
    System.Classes
  , BaseFormUnit
  , MCParamsUnit
  , DBAccessUnit
  ;

const
  TIME_OUT_SECONDS = 4;

type
  TProcRef = reference to procedure;
  TParamsProcRef = reference to procedure(const AParams: TParamsExt);
  TParamIdProcRef = reference to procedure(const AId: Int64);

  TBaseThread = class;

  TBaseThread = class(TThread)
  private
    FForm: TBaseForm;
    FExceptionMessage: String;
    // Параметры для использования внутри Execute в качестве локальной переменной
    FParams: TParamsExt;
    // Входные параметры, манипуляций с ними не производим, нужны для отслеживания, того что пришло на в ход
    FInParams: TParamsExt;
    // Выходные параметры
    FOutParams: TParamsExt;

    FName: String;
  protected
    property Form: TBaseForm read FForm;
    property ExceptionMessage: String read FExceptionMessage write FExceptionMessage;
    property Params: TParamsExt read FParams write FParams;
    property InParams: TParamsExt read FInParams write FInParams;
    property OutParams: TParamsExt read FOutParams write FOutParams;

    procedure Execute; override;

    procedure ControlParamsProc(
      const AParamsProcRef: TParamsProcRef;
      const AParams: TParamsExt);

    procedure LoadCatalog(
      const AInParams: TParamsExt;
      const ABuildCatalogProcRef: TParamsProcRef;
      const AOpenCellProcRef: TParamsProcRef);
  public
    constructor Create(const AForm: TBaseForm); virtual;
    destructor Destroy; override;

    property Name: String read FName write FName;
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

constructor TBaseThread.Create(const AForm: TBaseForm);
begin
  FExceptionMessage := '';

  FForm := AForm;

  FForm.ThreadRegistry.RegisterThread(Self);

  FreeOnTerminate := true;

  FParams := TParamsExt.Create;
  FInParams := TParamsExt.Create;
  FOutParams := TParamsExt.Create;

  inherited Create(false);
end;

destructor TBaseThread.Destroy;
var
  ExceptionMessage: String;
begin
  ExceptionMessage := FExceptionMessage;
  FForm.ThreadRegistry.UnRegisterThread(Self);
  if Length(Trim(ExceptionMessage)) > 0 then
  begin
    TLogger.AddLog('TBaseThread.OnTerminateHandler: ' + ExceptionMessage, ER);
    TThread.ForceQueue(nil,
      procedure
      begin
        ShowMessage('TBaseThread.OnTerminateHandler: ' + ExceptionMessage);
      end);
  end;

  FreeAndNil(FParams);
  FreeAndNil(FInParams);
  FreeAndNil(FOutParams);

  inherited;
end;

procedure TBaseThread.Execute;
begin
  { Place thread code here }
end;

procedure TBaseThread.ControlParamsProc(
  const AParamsProcRef: TParamsProcRef;
  const AParams: TParamsExt);
const
  METHOD = 'TBaseThread.ControlParamsProc';
var
  ParamsProcRef: TParamsProcRef absolute AParamsProcRef;
  Params: TParamsExt;
begin
  if not Assigned(ParamsProcRef) then
    Exit;

  Params := TParamsExt.Create;
  try
    if Assigned(AParams) then
      Params.CopyFrom(AParams);
    try
      Synchronize(procedure
        begin
          ParamsProcRef(Params);
        end);
    except
      on e: Exception do
      begin
        raise Exception.CreateFmt('%s: %s', [METHOD, e.Message]);
      end;
    end;
  finally
    FreeAndNil(Params);
  end;
end;

procedure TBaseThread.LoadCatalog(
  const AInParams: TParamsExt;
  const ABuildCatalogProcRef: TParamsProcRef;
  const AOpenCellProcRef: TParamsProcRef);
const
  METHOD = 'TBaseThread.LoadCatalog';
var
  CellList: TCellList;
  OutParams: TParamsExt;
  FolderId: Int64;
  CellId: Int64;
  InnerParams: TParamsExt;
  MustRestartReminder: Boolean;
begin
  FolderId := AInParams.AsInt64[0];
  CellId := AInParams.AsInt64[1];
  MustRestartReminder :=
    AInParams.IfAsBooleanByIdent(PARAM_IDENT_RestartReminder, true);

  OutParams := TParamsExt.Create;
  try
    InnerParams := TParamsExt.Create;
    try
      InnerParams.Add(FolderId);

      TDBAccess.DBAParamsFunc(TDBAccess.LoadCatalog, InnerParams, OutParams);

      CellList := OutParams.AsPointer[0];

      InnerParams.Clear;
      InnerParams.Add(FolderId);
      InnerParams.Add(CellList);
      // Если CellId <= 0, тогда после прорисовки каталога папок, будет перезапущен ремайндер
      // Если CellId > 0, тогда ремайндер перезапуститься после прорисовки ячейки
      // После прорисовки ячейки ремайндер всегда перезапускается
      if MustRestartReminder then
      begin
        if CellId <= 0 then
          InnerParams.Add(true, PARAM_IDENT_RestartReminder)
        else
          InnerParams.Add(false, PARAM_IDENT_RestartReminder);
      end
      else
        InnerParams.Add(false, PARAM_IDENT_RestartReminder);

      ControlParamsProc(ABuildCatalogProcRef, InnerParams);

      if Assigned(AOpenCellProcRef) then
      begin
        if CellId > 0 then
        begin
          InnerParams.Clear;
          InnerParams.Add(CellId);

          TDBAccess.DBAParamsFunc(TDBAccess.LoadCell, InnerParams, OutParams);

          InnerParams.Clear;
          InnerParams.CopyFrom(OutParams);
          InnerParams.AddFrom(AInParams);

          InnerParams.Add(MustRestartReminder, PARAM_IDENT_RestartReminder);

          ControlParamsProc(AOpenCellProcRef, InnerParams);
        end;
      end;
    finally
      FreeAndNil(InnerParams);
    end;
  finally
    FreeAndNil(OutParams);
  end;
end;

end.
