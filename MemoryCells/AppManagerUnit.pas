unit AppManagerUnit;

interface

uses
    System.SyncObjs

  , LoadCatalogThreadUnit
  , LoadCellThreadUnit
  , UpdateCellThreadUnit
  , InsertCellThreadUnit
  , DeleteCellThreadUnit
  , UpdateFolderThreadUnit
  , InsertFolderThreadUnit
  , DeleteFolderThreadUnit
  , SearchThreadUnit
  , LoadCellsByIdListThreadUnit
  , BackupThreadUnit
  , BackupStarterThreadUnit
  , UpdateCellAttributesThreadUnit
  , LoadDestinationCatalogThreadUnit
  , MoveCellsThreadUnit
  , LoadCellReminderThreadUnit
  , KeyCatcherThreadUnit
  , CellReminderThreadUnit
  , UpdateCellReminderThreadUnit
  , LoadRemindCellsThreadUnit
  , BaseThreadUnit
  , FMX.FormExtUnit
  , DBAccessUnit
  , CommonUnit
  , CellUnit
  , MCParamsUnit
  , UTClientManagerUnit
  , VCL.Graphics
  ;

type
  // Потенциально объект этого класса может быть использован несколькими потоками
  TAppManager = class
  strict private
    FAppIcon: TIcon;
    FAppDir: String;
    FAppPath: String;
    FSettings: TApplicationSettings;
    FCurrentState: TApplicationCurrentState;
  public
    constructor Create;
    destructor Destroy; override;

    property AppIcon: TIcon read FAppIcon write FAppIcon;
    property AppDir: String read FAppDir;
    property AppPath: String read FAppPath;
    property Settings: TApplicationSettings read FSettings write FSettings;
    property CurrentState: TApplicationCurrentState read FCurrentState write FCurrentState;

    procedure InitDBAccessByPath(
      const ADBFileName: String;
      const ATemplatesDir: String);
    procedure InitDBAccessByPack(
      const ADBFileName: String;
      const ATemplatesPack: String);

//    function CreateLoadCatalogThread(
//      const AForm: TFormExt;
//      const AFolderId: Int64;
//      const ACellId: Int64): TLoadCatalogThread; overload;
    function CreateLoadCatalogThread(
      const AForm: TFormExt;
      const AFolderId: Int64;
      const ACellId: Int64;
      const ACellRemindDateTime: TDateTime;
      const ACellRemind: Boolean;
      const AOpenCellReminderPanel: Boolean): TLoadCatalogThread; overload;

    function CreateLoadDestinationCatalogThread(
      const AForm: TFormExt;
      const AFolderId: Int64;
      const ABuildDestinationCatalogProcRef: TParamsProcRef): TLoadDestinationCatalogThread;

    function CreateLoadCellThread(
      const AForm: TFormExt;
      const ACell: TCell;
      const AProcRef: TParamsProcRef): TLoadCellThread;

    function CreateUpdateCellThread(
      const AForm: TFormExt;
      const ACell: TCell;
      const AProcRef: TParamsProcRef): TUpdateCellThread;

    function CreateInsertCellThread(
      const AForm: TFormExt;
      const AFolderId: Int64;
      const AProcRef: TParamsProcRef): TInsertCellThread;

    function CreateDeleteCellThread(
      const AForm: TFormExt;
      const ACellId: Int64;
      const AProcRef: TParamsProcRef): TDeleteCellThread;

    function CreateUpdateFolderThread(
      const AForm: TFormExt;
      const AFolderId: Int64;
      const AFolderName: String;
      const AProcRef: TParamsProcRef): TUpdateFolderThread;

    function CreateInsertFolderThread(
      const AForm: TFormExt;
      const AParentFolderId: Int64;
      const AFolderName: String;
      const AProcRef: TParamsProcRef): TInsertFolderThread;

    function CreateDeleteFolderThread(
      const AForm: TFormExt;
      const AFolderId: Int64;
      const AParentFolderId: Int64;
      const AProcRef: TParamsProcRef;
      const ADeleteFolderError: TParamsProcRef): TDeleteFolderThread;

    function CreateSearchThread(
      const AForm: TFormExt;
      const ASearchText: String;
      const AProcRef: TParamsProcRef): TSearchThread;

    function CreateLoadCellsByIdListThread(
      const AForm: TFormExt;
      const ACellIdList: TCellIdList;
      const AProcRef: TParamsProcRef): TLoadCellsByIdListThread;

    function CreateLoadRemindCellsThread(
      const AForm: TFormExt;
      const AProcRef: TParamsProcRef): TLoadRemindCellsThread;

    function CreateBackupThread(
      const AForm: TFormExt;
      const ABackupFileName: String;
      const AProcRef: TParamsProcRef): TBackupThread;

    function CreateBackupStarterThread(
      const AForm: TFormExt;
      const ALastBackupDateTime: TDateTime;
      const AProcRef: TParamsProcRef): TBackupStarterThread;

    function CreateUpdateCellAttributesThread(
      const AForm: TFormExt;
      const ACellId: Int64;
      const AIsDone: Boolean;
      const AProcRef: TParamsProcRef): TUpdateCellAttributesThread;

    function CreateMoveCellsThread(
      const AForm: TFormExt;
      const ASourceFolderId: Int64;
      const ADestinationFolderId: Int64;
      const ACellIdList: TCellIdList;
      const AActionType: TActionType): TMoveCellsThread;

    function CreateLoadCellReminderThread(
      const AForm: TFormExt;
      const AProcRef: TParamsProcRef): TLoadCellReminderThread;

    function CreateKeyCatcherThread(
      const AForm: TFormExt;
      const AMemoryFileName: String): TKeyCatcherThread;

    function CreateCellReminderThread(
      const AForm: TFormExt;
      const ACell: TCell;
      const AProcRef: TParamsProcRef): TCellReminderThread;
    { TODO:  Разделить сохранение ячейки и ее ремайндера }
    function CreateUpdateCellReminderThread(
      const AForm: TFormExt;
      const ACell: TCell;
      const AProcRef: TParamsProcRef): TUpdateCellReminderThread;
  end;

var
  AppManager: TAppManager;
  UTClientManager: TUTClientManager;

implementation

uses
    System.SysUtils
  , System.Classes
  , AddLogUnit
  ;

constructor TAppManager.Create;
begin
  FAppDir := ExtractFileDir(ParamStr(0));
  FApppath := ExtractFilePath(ParamStr(0));
end;

destructor TAppManager.Destroy;
begin
  TDBAccess.UnInit;

  inherited;
end;

procedure TAppManager.InitDBAccessByPath(
  const ADBFileName: String;
  const ATemplatesDir: String);
begin
  TDBAccess.InitByPath(ADBFileName, ATemplatesDir);
end;

procedure TAppManager.InitDBAccessByPack(
  const ADBFileName: String;
  const ATemplatesPack: String);
begin
  TDBAccess.InitByPack(ADBFileName, ATemplatesPack);
end;

//function TAppManager.CreateLoadCatalogThread(
//  const AForm: TFormExt;
//  const AFolderId: Int64;
//  const ACellId: Int64): TLoadCatalogThread;
//var
//  ParamsObj: TParamsExt;
//begin
//  ParamsObj := TParamsExt.Create([
//    AFolderId,
//    ACellId
//  ]);
//  try
//    Result := TLoadCatalogThread.Create(AForm, ParamsObj);
//  finally
//    FreeAndNil(ParamsObj);
//  end;
//end;

function TAppManager.CreateLoadCatalogThread(
  const AForm: TFormExt;
  const AFolderId: Int64;
  const ACellId: Int64;
  const ACellRemindDateTime: TDateTime;
  const ACellRemind: Boolean;
  const AOpenCellReminderPanel: Boolean): TLoadCatalogThread;
var
  ParamsObj: TParamsExt;
begin
  ParamsObj := TParamsExt.Create;
  ParamsObj.Add(AFolderId, 'FolderId');
  ParamsObj.Add(ACellId, 'CellId');
  ParamsObj.Add(ACellRemindDateTime, PARAM_IDENT_CellReminderFormRemindDateTime);
  ParamsObj.Add(ACellRemind, PARAM_IDENT_CellReminderFormRemind);
  ParamsObj.Add(AOpenCellReminderPanel, PARAM_IDENT_CellReminderFormOpenReminderPanel);
  ParamsObj.Add(false, PARAM_IDENT_RestartReminder);
  try
    Result := TLoadCatalogThread.Create(AForm, ParamsObj);
  finally
    FreeAndNil(ParamsObj);
  end;
end;

function TAppManager.CreateLoadDestinationCatalogThread(
  const AForm: TFormExt;
  const AFolderId: Int64;
  const ABuildDestinationCatalogProcRef: TParamsProcRef): TLoadDestinationCatalogThread;
var
  ParamsObj: TParamsExt;
begin
  ParamsObj := TParamsExt.Create([
    AFolderId
  ]);
  try
    Result := TLoadDestinationCatalogThread.Create(AForm, ParamsObj, ABuildDestinationCatalogProcRef);
  finally
    FreeAndNil(ParamsObj);
  end;
end;

function TAppManager.CreateLoadCellThread(
  const AForm: TFormExt;
  const ACell: TCell;
  const AProcRef: TParamsProcRef): TLoadCellThread;
var
  ParamsObj: TParamsExt;
begin
  ParamsObj := TParamsExt.Create;
  try
    ParamsObj.Add(ACell.Id);
    Result := TLoadCellThread.Create(AForm, ParamsObj, AProcRef);
  finally
    FreeAndNil(ParamsObj);
  end;
end;

function TAppManager.CreateUpdateCellThread(
  const AForm: TFormExt;
  const ACell: TCell;
  const AProcRef: TParamsProcRef): TUpdateCellThread;
var
  ParamsObj: TParamsExt;
begin
  ParamsObj := TParamsExt.Create;
  try
    ParamsObj.Add(ACell.Id, 'CellId');
    ParamsObj.Add(ACell.Content, 'Content');
    ParamsObj.Add(ACell.Desc, 'Desc');
    ParamsObj.Add(ACell.RemindDateTime, 'RemindDateTime');
    ParamsObj.Add(ACell.Remind, 'Remind');
    // Обновление (Update) ячейки идет через событие TCell.OnContentChanged
    Result := TUpdateCellThread.Create(AForm, ParamsObj, AProcRef);
  finally
    FreeAndNil(ParamsObj);
  end;
end;

function TAppManager.CreateInsertCellThread(
  const AForm: TFormExt;
  const AFolderId: Int64;
  const AProcRef: TParamsProcRef): TInsertCellThread;
var
  ParamsObj: TParamsExt;
begin
  ParamsObj := TParamsExt.Create;
  try
    ParamsObj.Add(AFolderId);
    Result := TInsertCellThread.Create(AForm, ParamsObj, AProcRef);
  finally
    FreeAndNil(ParamsObj);
  end;
end;

function TAppManager.CreateDeleteCellThread(
  const AForm: TFormExt;
  const ACellId: Int64;
  const AProcRef: TParamsProcRef): TDeleteCellThread;
var
  ParamsObj: TParamsExt;
begin
  ParamsObj := TParamsExt.Create;
  try
    ParamsObj.Add(ACellId);
    Result := TDeleteCellThread.Create(AForm, ParamsObj, AProcRef);
  finally
    FreeAndNil(ParamsObj);
  end;
end;

function TAppManager.CreateUpdateFolderThread(
  const AForm: TFormExt;
  const AFolderId: Int64;
  const AFolderName: String;
  const AProcRef: TParamsProcRef): TUpdateFolderThread;
var
  ParamsObj: TParamsExt;
begin
  ParamsObj := TParamsExt.Create;
  try
    ParamsObj.Add(AFolderId);
    ParamsObj.Add(AFolderName);

    Result := TUpdateFolderThread.Create(AForm, ParamsObj, AProcRef);
  finally
    FreeAndNil(ParamsObj);
  end;
end;

function TAppManager.CreateInsertFolderThread(
  const AForm: TFormExt;
  const AParentFolderId: Int64;
  const AFolderName: String;
  const AProcRef: TParamsProcRef): TInsertFolderThread;
var
  ParamsObj: TParamsExt;
begin
  ParamsObj := TParamsExt.Create;
  try
    ParamsObj.Add(AParentFolderId);
    ParamsObj.Add(AFolderName);

    Result := TInsertFolderThread.Create(AForm, ParamsObj, AProcRef);
  finally
    FreeAndNil(ParamsObj);
  end;
end;

function TAppManager.CreateDeleteFolderThread(
  const AForm: TFormExt;
  const AFolderId: Int64;
  const AParentFolderId: Int64;
  const AProcRef: TParamsProcRef;
  const ADeleteFolderError: TParamsProcRef): TDeleteFolderThread;
var
  ParamsObj: TParamsExt;
begin
  ParamsObj := TParamsExt.Create;
  try
    ParamsObj.Add(AFolderId);
    ParamsObj.Add(AParentFolderId);
    Result := TDeleteFolderThread.Create(AForm, ParamsObj, AProcRef, ADeleteFolderError);
  finally
    FreeAndNil(ParamsObj);
  end;
end;

function TAppManager.CreateSearchThread(
  const AForm: TFormExt;
  const ASearchText: String;
  const AProcRef: TParamsProcRef): TSearchThread;
var
  ParamsObj: TParamsExt;
begin
  ParamsObj := TParamsExt.Create([ASearchText]);
  try
    Result := TSearchThread.Create(AForm, ParamsObj, AProcRef);
  finally
    FreeAndNil(ParamsObj);
  end;
end;

function TAppManager.CreateLoadCellsByIdListThread(
  const AForm: TFormExt;
  const ACellIdList: TCellIdList;
  const AProcRef: TParamsProcRef): TLoadCellsByIdListThread;
var
  ParamsObj: TParamsExt;
begin
  ParamsObj := TParamsExt.Create;
  try
    ParamsObj.Add(ACellIdList);

    Result := TLoadCellsByIdListThread.Create(AForm, ParamsObj, AProcRef);
  finally
    FreeAndNil(ParamsObj);
  end;
end;

function TAppManager.CreateLoadRemindCellsThread(
  const AForm: TFormExt;
  const AProcRef: TParamsProcRef): TLoadRemindCellsThread;
var
  ParamsObj: TParamsExt;
begin
  ParamsObj := TParamsExt.Create;
  try
    Result := TLoadRemindCellsThread.Create(AForm, ParamsObj, AProcRef);
  finally
    FreeAndNil(ParamsObj);
  end;
end;

function TAppManager.CreateBackupThread(
  const AForm: TFormExt;
  const ABackupFileName: String;
  const AProcRef: TParamsProcRef): TBackupThread;
var
  ParamsObj: TParamsExt;
begin
  ParamsObj := TParamsExt.Create;
  try
    ParamsObj.Add(ABackupFileName);
    Result := TBackupThread.Create(AForm, ParamsObj, AProcRef);
//    Result.Name := 'TBackupThread';
  finally
    FreeAndNil(ParamsObj);
  end;
end;

function TAppManager.CreateBackupStarterThread(
  const AForm: TFormExt;
  const ALastBackupDateTime: TDateTime;
  const AProcRef: TParamsProcRef): TBackupStarterThread;
var
  ParamsObj: TParamsExt;
begin
  ParamsObj := TParamsExt.Create;
  try
    ParamsObj.Add(ALastBackupDateTime);
    Result := TBackupStarterThread.Create(AForm, ParamsObj, AProcRef);
//    Result.Name := 'TBackupStarterThread';
  finally
    FreeAndNil(ParamsObj);
  end;
end;

function TAppManager.CreateUpdateCellAttributesThread(
  const AForm: TFormExt;
  const ACellId: Int64;
  const AIsDone: Boolean;
  const AProcRef: TParamsProcRef): TUpdateCellAttributesThread;
var
  ParamsObj: TParamsExt;
begin
  ParamsObj := TParamsExt.Create([
    ACellId,
    AIsDone
    ]);
  try
    Result := TUpdateCellAttributesThread.Create(AForm, ParamsObj, AProcRef);
  finally
    FreeAndNil(ParamsObj);
  end;
end;

function TAppManager.CreateMoveCellsThread(
  const AForm: TFormExt;
  const ASourceFolderId: Int64;
  const ADestinationFolderId: Int64;
  const ACellIdList: TCellIdList;
  const AActionType: TActionType): TMoveCellsThread;
var
  ParamsObj: TParamsExt;
begin
  ParamsObj := TParamsExt.Create;
  ParamsObj.Add(ASourceFolderId);
  ParamsObj.Add(ADestinationFolderId);
  ParamsObj.Add(ACellIdList);
  ParamsObj.Add(AActionType);
  try
    Result := TMoveCellsThread.Create(AForm, ParamsObj);
  finally
    FreeAndNil(ParamsObj);
  end;
end;

function TAppManager.CreateLoadCellReminderThread(
  const AForm: TFormExt;
  const AProcRef: TParamsProcRef): TLoadCellReminderThread;
var
  ParamsObj: TParamsExt;
begin
  ParamsObj := TParamsExt.Create;
  try
    Result := TLoadCellReminderThread.Create(AForm, ParamsObj, AProcRef);
//    Result.Name := 'TLoadCellReminderThread';
  finally
    FreeAndNil(ParamsObj);
  end;
end;

function TAppManager.CreateKeyCatcherThread(
  const AForm: TFormExt;
  const AMemoryFileName: String): TKeyCatcherThread;
var
  ParamsObj: TParamsExt;
begin
  ParamsObj := TParamsExt.Create;
  ParamsObj.Add(AMemoryFileName);
  try
    Result := TKeyCatcherThread.Create(AForm, ParamsObj);
//    Result.Name := 'TKeyCatcherThread';
  finally
    FreeAndNil(ParamsObj);
  end;
end;

function TAppManager.CreateCellReminderThread(
  const AForm: TFormExt;
  const ACell: TCell;
  const AProcRef: TParamsProcRef): TCellReminderThread;
var
  ParamsObj: TParamsExt;
begin
  TLogger.AddLog('TAppManager.CreateCellReminderThread -> Создаем поток обратного отсчета', MG);

  ParamsObj := TParamsExt.Create;
  ParamsObj.Add(ACell);
  try
    Result := TCellReminderThread.Create(AForm, ParamsObj, AProcRef);
//    Result.Name := 'TCellReminderThread';
  finally
    FreeAndNil(ParamsObj);
  end;
end;

function TAppManager.CreateUpdateCellReminderThread(
  const AForm: TFormExt;
  const ACell: TCell;
  const AProcRef: TParamsProcRef): TUpdateCellReminderThread;
var
  ParamsObj: TParamsExt;
begin
  ParamsObj := TParamsExt.Create;
  try
    ParamsObj.Add(ACell.Id);
    ParamsObj.Add(ACell.RemindDateTime);
    Result := TUpdateCellReminderThread.Create(AForm, ParamsObj, AProcRef);
  finally
    FreeAndNil(ParamsObj);
  end;
end;


end.
