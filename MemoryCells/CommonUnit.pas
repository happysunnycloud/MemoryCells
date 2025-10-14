unit CommonUnit;

interface

uses
    System.Classes
  , System.SysUtils
  , System.Generics.Collections
  , System.SyncObjs
  , Winapi.Windows

  , FMX.Controls
  , FMX.Layouts
  , FMX.Memo
  , FMX.Forms
  , FMX.Platform.Win
  , FMX.ThemeUnit

  , CellUnit
  , CellUnitFrameUnit
  , MCParamsUnit
  , DBAccessUnit
  , ThreadRegistryUnit
  , BaseThreadUnit
  ;

const
  VERSION = '0.2';
  ROOT_FOLDER_ID = 1;
  EVENT_ONCLICK = 'OnClick';
  SETTINGS_FILE_NAME = 'Settings.mcs';
  DB_PATH = 'DataBase\';
  DB_DEBUG_PATH = '..\..\..\MemoryCellsDataBase\';
  DB_FILE_NAME = 'CAT.db';
  DB_BACKUP_PATH = 'DataBaseBackup\';
  SQL_TEMPLATES_PATH = 'SQLTemplates\';
  SQL_TEMPLATES_DEBUG_PATH = '..\..\..\MemoryCellsCommon\SQLTemplates';
  KEY_HOOK_FILE_NAME = 'KeyHook.dll';
  APP_NAME = 'MemoryCells';

type
  TParamIdFuncRef = function(const AId: Int64): TDBAResultCode of object;
  TParamsFuncRef = function(const AParams: TParamsExt): TDBAResultCode of object;
  TInOutParamsFuncRef = function(const AInParams: TParamsExt; const AOutParams: TParamsExt): TDBAResultCode of object;

  TActionType = (atMove = 0, atCopy = 1);

  TCallbackControlProcRef = reference to procedure(const AControl: TControl);

//  TParamsProcRef = reference to procedure(const AParams: TParamsExt);
//  TParamIdProcRef = reference to procedure(const AId: Int64);
  TParamCellProcRef = reference to procedure(const ACell: TCell);
  TParamCellListProcRef = reference to procedure(const ACellList: TCellList);

  TEventRecord = record
    Control: TControl;
    Event: TNotifyEvent;
    EventIdent: String;
  end;

  TEventRecordList = class(TList<TEventRecord>)
  public
    procedure Add(const AControl: TControl; const AEvent: TNotifyEvent; const AEventIdent: String);
    function GetByIdent(const AControl: TControl; const AEventIdent: String): TNotifyEvent;
    procedure DeleteByControl(const AControl: TControl);
    function ContainsControl(const AControl: TControl): Boolean;
  end;

  THelpmate = class
  strict private
    class var
      FTheme: TTheme;
  public
    class constructor Create;
    class destructor Destroy;

    class procedure ScrollBoxControls(
      const AScrollBox: TScrollBox;
      const ACallbackControl: TCallbackControlProcRef);

    class function DateTimeToFileNameString(const ADateTimeSplitter: String = ''): String;

    class function GetCellUnitFrameByCellId(const AScrollBox: TScrollBox; const ACellId: Int64): TCellUnitFrame;

    class procedure SetMemoCellDefaultSettings(const AMemoCell: TMemo);

    class procedure CellUnitCheckBoxVisible(
      const AControl: TControl;
      const AVisible: Boolean;
      const ACellUnitCheckBoxOnChangeHandler: TNotifyEvent);

    class procedure SelectAllCells(const AScrollBox: TScrollBox);
    class procedure UnSelectAllCells(const AScrollBox: TScrollBox);
    class procedure CollectSelectedCellIdList(const AScrollBox: TScrollBox; const ACellIdList: TCellIdList);

    class procedure RaiseException(const AMethod: String; const AE: Exception);

    class procedure IfDirNotExists(const ADirName: String; const AProc: TProc);
    class procedure IfFileNotExists(const AFileName: String; const AProc: TProc);

    class procedure ShowFormIfHidden(const AForm: TForm);
    class procedure HideFormIfShowing(const AForm: TForm);

    class procedure ShowAppIfHidden;
    class procedure HideAppIfShowing;

//    class procedure StyleAssign(
//      const AStyleTo: TStyleBook;
//      const AStyleFrom: TStyleBook);

    class function FindThreadByName(
      const AThreadRegistry: TThreadRegistry<Pointer>;
      const AThreadName: String): TBaseThread;

    class function IsFormActive(const AForm: TForm): Boolean;

    class property Theme: TTheme read FTheme write FTheme;
  end;

  TCurrentMode = (cmCommon, cmSearch);
  TSelectMode = (smFalse, smTrue);
  TOnlineMode = (omFalse, omTrue);
  TRunAppAtStartup = (raFalse, raTrue);
  TCollapseAppAtStartup = (caFalse, caTrue);

  TSelectModeHelper = record helper for TSelectMode
  public
    function ToBoolean: Boolean;
  end;

  TOnlineModeHelper = record helper for TOnlineMode
  public
    function ToBoolean: Boolean;
    procedure FromBoolean(const ABoolean: Boolean);
  end;

  TRunAppAtStartupHelper = record helper for TRunAppAtStartup
  public
    function ToBoolean: Boolean;
    procedure FromBoolean(const ABoolean: Boolean);
  end;

  TCollapseAppAtStartupHelper = record helper for TCollapseAppAtStartup
  public
    function ToBoolean: Boolean;
    procedure FromBoolean(const ABoolean: Boolean);
  end;

  TApplicationCurrentState = record
  strict private
    FFieldAccess: TCriticalSection;
    FMode: TCurrentMode;
    FSelectMode: TSelectMode;

    procedure SetMode(const AMode: TCurrentMode);
    function GetMode: TCurrentMode;

    procedure SetSelectMode(const ASelectMode: TSelectMode);
    function GeSelecttMode: TSelectMode;
  public
    class operator Initialize(out Dest: TApplicationCurrentState);
    class operator Finalize(var Dest: TApplicationCurrentState);

    property Mode: TCurrentMode read GetMode write SetMode;
    property SelectMode: TSelectMode read GeSelecttMode write SetSelectMode;
  end;

  TApplicationSettings = record
  strict private
    FMainFormHeight: Integer;
    FMainFormWidth: Integer;
    FMainFormTop: Integer;
    FMainFormLeft: Integer;
    FCellLayoutWidth: Integer;
    FCellsLayoutWidth: Integer;
    FIsFoldersLayoutShowing: Byte;
    FIsFavoriteCellsShowing: Byte;
    FBackupsPath: String;
    FLastBackupDateTime: TDateTime;
    FFavoriteCellIdList: TCellIdList;
    FCurrentFolderId: Int64;
    FCurrentCellId: Int64;
    FSelectedCellIdList: TCellIdList;
    FOnlineMode: TOnlineMode;
    FRunAppAtStartup: TRunAppAtStartup;
    FCollapseAppAtStartup: TCollapseAppAtStartup;

    procedure SetMainFormHeight(const AMainFormHeight: Integer);
    procedure SetMainFormWidth(const AMainFormWidth: Integer);
    procedure SetMainFormTop(const AMainFormTop: Integer);
    procedure SetMainFormLeft(const AMainFormLeft: Integer);

    procedure SetCellLayoutWidth(const ACellLayoutWidth: Integer);
    procedure SetCellsLayoutWidth(const ACellsLayoutWidth: Integer);

    procedure SetIsFoldersLayoutShowing(const AIsFoldersLayoutShowing: Byte);
    procedure SetIsFavoriteCellsShowing(const AIsFavoriteCellsShowing: Byte);

    procedure SetBackupsPath(const ABackupsPath: String);
    procedure SetLastBackupDateTime(const ALastBackupDateTime: TDateTime);

    procedure SetCurrentFolderId(const ACurrentFolderId: Int64);
    procedure SetCurrentCellId(const ACurrentCellId: Int64);

    procedure SetOnlineMode(const AOnlineMode: TOnlineMode);
    function  GeOnlineMode: TOnlineMode;

    procedure SetCollapseAppAtStartup(
      const ACollapseAppAtStartup: TCollapseAppAtStartup);
    function GetCollapseAppAtStartup: TCollapseAppAtStartup;

    procedure SetRunAppAtStartup(
      const ARunAppAtStartup: TRunAppAtStartup);
    function GetRunAppAtStartup: TRunAppAtStartup;
  public
    property MainFormHeight: Integer read FMainFormHeight write SetMainFormHeight;
    property MainFormWidth: Integer read FMainFormWidth write SetMainFormWidth;
    property MainFormTop: Integer read FMainFormTop write SetMainFormTop;
    property MainFormLeft: Integer read FMainFormLeft write SetMainFormLeft;

    property CellLayoutWidth: Integer read FCellLayoutWidth write SetCellLayoutWidth;
    property CellsLayoutWidth: Integer read FCellsLayoutWidth write SetCellsLayoutWidth;

    property IsFoldersLayoutShowing: Byte read FIsFoldersLayoutShowing write SetIsFoldersLayoutShowing;
    property IsFavoriteCellsShowing: Byte read FIsFavoriteCellsShowing write SetIsFavoriteCellsShowing;

    property BackupsPath: String read FBackupsPath write SetBackupsPath;
    property LastBackupDateTime: TDateTime read FLastBackupDateTime write SetLastBackupDateTime;

    property FavoriteCellIdList: TCellIdList read FFavoriteCellIdList;
//    property DestinationCellIdList: TCellIdList read FFavoriteCellIdList;

    property CurrentFolderId: Int64 read FCurrentFolderId write SetCurrentFolderId;
    property CurrentCellId: Int64 read FCurrentCellId write SetCurrentCellId;

    property SelectedCellIdList: TCellIdList read FSelectedCellIdList write FSelectedCellIdList;

    property OnlineMode: TOnlineMode read GeOnlineMode write SetOnlineMode;

    property CollapseAppAtStartup: TCollapseAppAtStartup
      read GetCollapseAppAtStartup
      write SetCollapseAppAtStartup;
    property RunAppAtStartup: TRunAppAtStartup
      read GetRunAppAtStartup
      write SetRunAppAtStartup;

    procedure SaveApplicationSettings;
    procedure LoadApplicationSettings;

    class operator Initialize(out Dest: TApplicationSettings);
    class operator Finalize(var Dest: TApplicationSettings);
  end;

  TNoteIdentConst = class
  const
    SaveCell          = 'SaveCell';
    DeleteCell        = 'DeleteCell';
  end;

var
  AppPath: String;

implementation

uses
    System.Variants
  , Xml.XMLDoc
  , Xml.XMLIntf
  , FMX.StdCtrls
  , FMX.Styles
  , ToolsUnit
  ;

function TSelectModeHelper.ToBoolean: Boolean;
begin
  Result := false;

  if Self = smFalse then
    Result := false
  else
  if Self = smTrue then
    Result := true;
end;

function TOnlineModeHelper.ToBoolean: Boolean;
begin
  Result := false;

  if Self = omFalse then
    Result := false
  else
  if Self = omTrue then
    Result := true;
end;

procedure TOnlineModeHelper.FromBoolean(const ABoolean: Boolean);
begin
  Self := omFalse;
  if ABoolean then
    Self := omTrue;
end;

function TRunAppAtStartupHelper.ToBoolean: Boolean;
begin
  Result := false;

  if Self = raFalse then
    Result := false
  else
  if Self = raTrue then
    Result := true;
end;

procedure TRunAppAtStartupHelper.FromBoolean(const ABoolean: Boolean);
begin
  Self := raFalse;
  if ABoolean then
    Self := raTrue;
end;

function TCollapseAppAtStartupHelper.ToBoolean: Boolean;
begin
  Result := false;

  if Self = caFalse then
    Result := false
  else
  if Self = caTrue then
    Result := true;
end;

procedure TCollapseAppAtStartupHelper.FromBoolean(const ABoolean: Boolean);
begin
  Self := caFalse;
  if ABoolean then
    Self := caTrue;
end;

{ TEventRecordList. Begin }

procedure TEventRecordList.Add(const AControl: TControl; const AEvent: TNotifyEvent; const AEventIdent: String);
var
  EventRecord: TEventRecord;
begin
  EventRecord.Control := AControl;
  EventRecord.Event := AEvent;
  EventRecord.EventIdent := AEventIdent;

  inherited Add(EventRecord);
end;

function TEventRecordList.GetByIdent(const AControl: TControl; const AEventIdent: String): TNotifyEvent;
var
  Control: TControl;
  EventRecord: TEventRecord;
  i: Word;
begin
  Result := nil;

  Control := nil;

  i := Count;
  while i > 0 do
  begin
    Dec(i);

    EventRecord := Items[i];

    if EventRecord.Control = AControl then
    begin
      Control := EventRecord.Control;
      if EventRecord.EventIdent = AEventIdent then
      begin
        Result := EventRecord.Event;
        Delete(i);

        Break;
      end;
    end;
  end;

  if not Assigned(Control) then
    raise Exception.CreateFmt('TEventRecordList.GetByIdent: Control "%s" not found', [AControl.Name]);
end;

procedure TEventRecordList.DeleteByControl(const AControl: TControl);
var
  EventRecord: TEventRecord;
  i: Word;
begin
  i := Count;
  while i > 0 do
  begin
    Dec(i);

    EventRecord := Items[i];

    if EventRecord.Control = AControl then
      Delete(i);
  end;
end;

function TEventRecordList.ContainsControl(const AControl: TControl): Boolean;
var
  EventRecord: TEventRecord;
  i: Word;
begin
  Result := false;

  i := Count;
  while i > 0 do
  begin
    Dec(i);

    EventRecord := Items[i];

    if EventRecord.Control = AControl then
      Exit(true);
  end;
end;

{ TEventRecordList. End }

{ THelpmate.Begin }

class constructor THelpmate.Create;
begin
  FTheme := TTheme.Create;
end;

class destructor THelpmate.Destroy;
begin
  FreeAndNil(FTheme);
end;

class procedure THelpmate.ScrollBoxControls(
  const AScrollBox: TScrollBox;
  const ACallbackControl: TCallbackControlProcRef);
var
  Control: TControl;
  i: Integer;
begin
  i := AScrollBox.Content.ControlsCount;
  while i > 0 do
  begin
    Dec(i);

    Control := AScrollBox.Content.Controls[i];
    ACallbackControl(Control);
  end;
end;

class function THelpmate.DateTimeToFileNameString(const ADateTimeSplitter: String = ''): String;
begin
  Result := DateToStr(Now);
  Result := Result + ADateTimeSplitter + TimeToStr(Now);

  Result := StringReplace(Result, '.', '', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, ':', '', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, ' ', '', [rfReplaceAll, rfIgnoreCase]);
end;

class function THelpmate.GetCellUnitFrameByCellId(const AScrollBox: TScrollBox; const ACellId: Int64): TCellUnitFrame;
var
  Control: TControl;
  i: Integer;
begin
//  Result := nil;

  i := AScrollBox.Content.ControlsCount;
  while i > 0 do
  begin
    Dec(i);

    Control := AScrollBox.Content.Controls[i];
    if Control is TCellUnitFrame then
      if TCellUnitFrame(Control).Cell.Id = ACellId then
      begin
        Result := TCellUnitFrame(Control);

        Exit;
      end;
  end;

  raise Exception.CreateFmt('GetCellUnitFrameByCellId: CellUnitFrame with id = %d not found', [ACellId]);
end;

class procedure THelpmate.SetMemoCellDefaultSettings(const AMemoCell: TMemo);
var
  CellMemo: TMemo absolute AMemoCell;
begin
  CellMemo.TextSettings.FontColor := $FFBCBCBC;
  CellMemo.TextSettings.Font.Size := 16;
  CellMemo.TextSettings.Font.Family := 'MS Reference Sans Serif';
  CellMemo.StyledSettings := [];
end;

class procedure THelpmate.CellUnitCheckBoxVisible(
  const AControl: TControl;
  const AVisible: Boolean;
  const ACellUnitCheckBoxOnChangeHandler: TNotifyEvent);
var
  CellUnitCheckBox: TCheckBox;
  FavoriteCellButton: TButton;
begin
  CellUnitCheckBox := TCellUnitFrame(AControl).CellUnitCheckBox;
  CellUnitCheckBox.Visible := AVisible;
  CellUnitCheckBox.OnChange := ACellUnitCheckBoxOnChangeHandler;
  FavoriteCellButton := TCellUnitFrame(AControl).FavoriteCellButton;
  FavoriteCellButton.Visible := not AVisible;
end;

class procedure THelpmate.SelectAllCells(const AScrollBox: TScrollBox);
begin
  ScrollBoxControls(AScrollBox,
    procedure (const AControl: TControl)
    var
      CellUnitCheckBox: TCheckBox;
    begin
      CellUnitCheckBox := TCellUnitFrame(AControl).CellUnitCheckBox;
      CellUnitCheckBox.IsChecked := true;
    end
  );
end;

class procedure THelpmate.UnSelectAllCells(const AScrollBox: TScrollBox);
begin
  ScrollBoxControls(AScrollBox,
    procedure (const AControl: TControl)
    var
      CellUnitCheckBox: TCheckBox;
    begin
      CellUnitCheckBox := TCellUnitFrame(AControl).CellUnitCheckBox;
      CellUnitCheckBox.IsChecked := false;
    end
  );
end;

class procedure THelpmate.CollectSelectedCellIdList(const AScrollBox: TScrollBox; const ACellIdList: TCellIdList);
var
  CellUnitFrame: TCellUnitFrame;
begin
  ACellIdList.Clear;

  ScrollBoxControls(AScrollBox,
    procedure (const AControl: TControl)
    var
      CellUnitCheckBox: TCheckBox;
    begin
      CellUnitFrame := TCellUnitFrame(AControl);
      CellUnitCheckBox := CellUnitFrame.CellUnitCheckBox;
      if CellUnitCheckBox.IsChecked then
      begin
        ACellIdList.Add(CellUnitFrame.Cell.Id);
      end;
    end
  );
end;

class procedure THelpmate.RaiseException(const AMethod: String; const AE: Exception);
var
  ExceptionMessage: String;
begin
  ExceptionMessage := AMethod + ' -> ' + AE.Message;

  raise Exception.Create(ExceptionMessage);
end;

class procedure THelpmate.IfDirNotExists(const ADirName: String; const AProc: TProc);
begin
  if not DirectoryExists(ADirName) then
    AProc;
end;

class procedure THelpmate.IfFileNotExists(const AFileName: String; const AProc: TProc);
begin
  if not FileExists(AFileName) then
    AProc;
end;

class procedure THelpmate.ShowFormIfHidden(const AForm: TForm);
var
  VisibleState: Boolean;
begin
  VisibleState := IsWindowVisible(ApplicationHwnd);
  if not VisibleState then
  begin
    AForm.Show;
    ShowWindow(ApplicationHwnd, SW_SHOW);
  end;
end;

class procedure THelpmate.HideFormIfShowing(const AForm: TForm);
var
  VisibleState: Boolean;
begin
  VisibleState := IsWindowVisible(ApplicationHwnd);
  if not VisibleState then
  begin
    AForm.Hide;
    ShowWindow(ApplicationHwnd, SW_HIDE);
  end;
end;

class procedure THelpmate.ShowAppIfHidden;
var
  VisibleState: Boolean;
begin
  VisibleState := IsWindowVisible(ApplicationHwnd);
  if not VisibleState then
  begin
    ShowWindow(ApplicationHwnd, SW_SHOW);
  end;
end;

class procedure THelpmate.HideAppIfShowing;
var
  VisibleState: Boolean;
begin
  VisibleState := IsWindowVisible(ApplicationHwnd);
  if not VisibleState then
  begin
    ShowWindow(ApplicationHwnd, SW_HIDE);
  end;
end;


//class procedure THelpmate.StyleAssign(
//  const AStyleTo: TStyleBook;
//  const AStyleFrom: TStyleBook);
//const
//  METHOD = 'THelpmate.StyleAssign';
//var
//  Stream: TMemoryStream;
//begin
//  try
//    Stream := TMemoryStream.Create;
//    try
//      TStyleStreaming.SaveToStream(AStyleFrom.Style, Stream);
//      Stream.Position := 0;
//      AStyleTo.LoadFromStream(Stream);
//    finally
//      FreeAndNil(Stream);
//    end;
//  except
//    on e: Exception do
//      THelpmate.RaiseException(METHOD, e);
//  end;
//end;

class function THelpmate.FindThreadByName(
  const AThreadRegistry: TThreadRegistry<Pointer>;
  const AThreadName: String): TBaseThread;
const
  METHOD = 'THelpmate.FindThreadByName';
var
  Thread: TBaseThread;
begin
  Thread := nil;

  AThreadRegistry.Enumerator(
    procedure (const AThread: Pointer)
    begin
      if TBaseThread(AThread).Name = AThreadName then
        Thread := TBaseThread(AThread);
    end);

  Result := Thread;
end;

class function THelpmate.IsFormActive(const AForm: TForm): Boolean;
var
  FormHandle: Cardinal;
  ActiveHandle: Cardinal;
begin
  FormHandle := FormToHWND(AForm);
  ActiveHandle := GetForegroundWindow;

  Result := FormHandle = ActiveHandle;
end;

{ THelpmate.End }

{ TApplicationCurrentState.Begin }

class operator TApplicationCurrentState.Initialize(out Dest: TApplicationCurrentState);
begin
  Dest.FFieldAccess := TCriticalSection.Create;
  Dest.FMode := cmCommon;
  Dest.FSelectMode := smFalse;
end;

class operator TApplicationCurrentState.Finalize(var Dest: TApplicationCurrentState);
begin
  FreeAndNil(Dest.FFieldAccess);
end;

procedure TApplicationCurrentState.SetMode(const AMode: TCurrentMode);
begin
  FFieldAccess.Enter;
  try
    FMode := AMode;
  finally
    FFieldAccess.Leave;
  end;
end;

function TApplicationCurrentState.GetMode: TCurrentMode;
begin
  FFieldAccess.Enter;
  try
    Result := FMode;
  finally
    FFieldAccess.Leave;
  end;
end;

procedure TApplicationCurrentState.SetSelectMode(const ASelectMode: TSelectMode);
begin
  FFieldAccess.Enter;
  try
    FSelectMode := ASelectMode;
  finally
    FFieldAccess.Leave;
  end;
end;

function TApplicationCurrentState.GeSelecttMode: TSelectMode;
begin
  FFieldAccess.Enter;
  try
    Result := FSelectMode;
  finally
    FFieldAccess.Leave;
  end;
end;

{ TApplicationCurrentState.End }

{ TApplicationSettings.Begin }

class operator TApplicationSettings.Initialize(out Dest: TApplicationSettings);
begin
  Dest.FMainFormHeight := 720;
  Dest.FMainFormWidth := 1400;

  Dest.FMainFormTop := 10;
  Dest.FMainFormLeft  := 10;
  Dest.FCellLayoutWidth := 300;
  Dest.FCellsLayoutWidth :=  300;
  Dest.FIsFoldersLayoutShowing := 1;

  Dest.FFavoriteCellIdList := TCellIdList.Create;
  Dest.FCurrentFolderId := 1;
  Dest.FCurrentCellId := 0;

  Dest.FSelectedCellIdList := TCellIdList.Create;

  Dest.FOnlineMode := omFalse;

  Dest.FRunAppAtStartup := raTrue;
  Dest.FCollapseAppAtStartup := caFalse;

  Dest.FBackupsPath := ExtractFilePath(ParamStr(0)) + DB_BACKUP_PATH;

  try
    Dest.LoadApplicationSettings;
  except
    raise;
  end;
end;

class operator TApplicationSettings.Finalize(var Dest: TApplicationSettings);
begin
  FreeAndNil(Dest.FFavoriteCellIdList);
  FreeAndNil(Dest.FSelectedCellIdList);
end;

procedure TApplicationSettings.SetMainFormHeight(const AMainFormHeight: Integer);
begin
  FMainFormHeight := AMainFormHeight;
end;

procedure TApplicationSettings.SetMainFormWidth(const AMainFormWidth: Integer);
begin
  FMainFormWidth := AMainFormWidth;
end;

procedure TApplicationSettings.SetMainFormTop(const AMainFormTop: Integer);
begin
  FMainFormTop := AMainFormTop;
end;

procedure TApplicationSettings.SetMainFormLeft(const AMainFormLeft: Integer);
begin
  FMainFormLeft := AMainFormLeft;
end;

procedure TApplicationSettings.SetCellLayoutWidth(const ACellLayoutWidth: Integer);
begin
  FCellLayoutWidth := ACellLayoutWidth;
end;

procedure TApplicationSettings.SetCellsLayoutWidth(const ACellsLayoutWidth: Integer);
begin
  FCellsLayoutWidth := ACellsLayoutWidth;
end;

procedure TApplicationSettings.SetIsFoldersLayoutShowing(const AIsFoldersLayoutShowing: Byte);
begin
  FIsFoldersLayoutShowing := AIsFoldersLayoutShowing;
end;

procedure TApplicationSettings.SetIsFavoriteCellsShowing(const AIsFavoriteCellsShowing: Byte);
begin
  FIsFavoriteCellsShowing := AIsFavoriteCellsShowing;
end;

procedure TApplicationSettings.SetBackupsPath(const ABackupsPath: String);
begin
  FBackupsPath := ABackupsPath;
end;

procedure TApplicationSettings.SetLastBackupDateTime(const ALastBackupDateTime: TDateTime);
begin
  FLastBackupDateTime := ALastBackupDateTime;
end;

procedure TApplicationSettings.SetCurrentFolderId(const ACurrentFolderId: Int64);
begin
  FCurrentFolderId := ACurrentFolderId;
end;

procedure TApplicationSettings.SetCurrentCellId(const ACurrentCellId: Int64);
begin
  FCurrentCellId := ACurrentCellId;
end;

procedure TApplicationSettings.SaveApplicationSettings;
var
  ApplicationSettingsFileName: String;

  XMLDoc: TXMLDocument;
  RootNode: IXMLNode;
  ApplicationSettingsNode: IXMLNode;
  MainFormNode: IXMLNode;
  LayoutsWidthNode: IXMLNode;
  BackupsNode: IXMLNode;
  FavoriteCellIdListNode: IXMLNode;
  CurrentValuesNode: IXMLNode;
//  OnlineModeNode: IXMLNode;

  IdList: TList<Int64>;

  i: Word;
begin
  ApplicationSettingsFileName := ExtractFilePath(ParamStr(0)) + SETTINGS_FILE_NAME;

  XMLDoc          := TXMLDocument.Create(Application);
  XMLDoc.Active   := true;
  XMLDoc.Options  := XMLDoc.Options + [doNodeAutoIndent] - [doAutoSave];
  RootNode := XMLDoc.AddChild('Data');
  ApplicationSettingsNode := RootNode.AddChild('ApplicationSettings');
  ApplicationSettingsNode.SetAttribute('OnlineMode', FOnlineMode.ToBoolean);
  // Сохраняем в реестре
  if FRunAppAtStartup.ToBoolean then
    TRegistryTools.AddAppAutoRun(APP_NAME, ParamStr(0))
  else
    TRegistryTools.DeleteAppAutoRun(APP_NAME);
//    TRegistryTools.AutoRunKeyExists(APP_NAME);

  ApplicationSettingsNode.SetAttribute(
    'CollapseAppAtStartup', FCollapseAppAtStartup.ToBoolean);

  MainFormNode := ApplicationSettingsNode.AddChild('MainForm');

  MainFormNode.AddChild('Height').Text := IntToStr(FMainFormHeight);
  MainFormNode.AddChild('Width').Text := IntToStr(FMainFormWidth);
  MainFormNode.AddChild('Top').Text := IntToStr(FMainFormTop);
  MainFormNode.AddChild('Left').Text := IntToStr(FMainFormLeft);
  MainFormNode.AddChild('IsFoldersLayoutShowing').Text := IntToStr(FIsFoldersLayoutShowing);
  MainFormNode.AddChild('IsFavoriteCellsShowing').Text := IntToStr(FIsFavoriteCellsShowing);

  LayoutsWidthNode := ApplicationSettingsNode.AddChild('LayoutsWidth');
  LayoutsWidthNode.AddChild('CellLayoutWidth').Text := IntToStr(FCellLayoutWidth);
  LayoutsWidthNode.AddChild('CellsLayoutWidth').Text := IntToStr(FCellsLayoutWidth);

  BackupsNode := ApplicationSettingsNode.AddChild('Backups');
  BackupsNode.AddChild('Path').Text := FBackupsPath;
  BackupsNode.AddChild('LastDateTime').Text := DateTimeToStr(FLastBackupDateTime);

  FavoriteCellIdListNode := ApplicationSettingsNode.AddChild('FavoriteCellIdList');
  IdList := FFavoriteCellIdList.LockList;
  try
    if IdList.Count > 0 then
      for i := 0 to Pred(IdList.Count) do
        FavoriteCellIdListNode.AddChild('Id' + i.ToString).Text := IdList[i].ToString;
  finally
    FFavoriteCellIdList.UnLockList;
  end;

  CurrentValuesNode := ApplicationSettingsNode.AddChild('CurrentValues');
  CurrentValuesNode.AddChild('CurrentFolderId').Text := FCurrentFolderId.ToString;
  CurrentValuesNode.AddChild('CurrentCellId').Text := FCurrentCellId.ToString;

//  OnlineModeNode := ApplicationSettingsNode.AddChild('OnlineMode');
//  CurrentValuesNode.AddChild('CurrentFolderId').Text := FCurrentFolderId.ToString;

  try
    XMLDoc.SaveToFile(ApplicationSettingsFileName);
  except
    raise Exception.CreateFmt('Can`t save %s', [SETTINGS_FILE_NAME]);
  end;
end;

procedure TApplicationSettings.LoadApplicationSettings;
  function IfEmpty(
    const AParentNode: IXMLNode; const AChildNodeName: String; const ADefaultVal: Int64): Int64; overload;
  var
    ChildNode: IXMLNode;
    Text: String;
  begin
    if not Assigned(AParentNode) then
      Exit(ADefaultVal);

    ChildNode := AParentNode.ChildNodes[AChildNodeName];
    if not Assigned(ChildNode) then
      Exit(ADefaultVal);

    Text := ChildNode.Text;
    if Text.IsEmpty then
      Result := ADefaultVal
    else
      Result := StrToUInt64(Text);
  end;

  function IfEmpty(
    const AParentNode: IXMLNode; const AChildNodeName: String; const ADefaultVal: String): String; overload;
  var
    ChildNode: IXMLNode;
    Text: String;
  begin
    if not Assigned(AParentNode) then
      Exit(ADefaultVal);

    ChildNode := AParentNode.ChildNodes[AChildNodeName];
    if not Assigned(ChildNode) then
      Exit(ADefaultVal);

    Text := ChildNode.Text;
    if Text.IsEmpty then
      Result := ADefaultVal
    else
      Result := Text;
  end;

  function IfEmpty(
    const AParentNode: IXMLNode; const AChildNodeName: String; const ADefaultVal: TDateTime): TDateTime; overload;
  var
    ChildNode: IXMLNode;
    Text: String;
  begin
    if not Assigned(AParentNode) then
      Exit(ADefaultVal);

    ChildNode := AParentNode.ChildNodes[AChildNodeName];
    if not Assigned(ChildNode) then
      Exit(ADefaultVal);

    Text := ChildNode.Text;
    if Text.IsEmpty then
      Result := ADefaultVal
    else
      Result := StrToDateTime(Text);
  end;

  function IfNullAttribute(
    const AParentNode: IXMLNode; const AAttributeName: String; const ADefaultVal: Boolean): Boolean;
  var
    _Variant: Variant;
  begin
    _Variant := AParentNode.Attributes[AAttributeName];
    if VarIsNull(_Variant) then
      Result := ADefaultVal
    else
      Result := Boolean(_Variant);
  end;
var
  ApplicationSettingsFileName: String;

  XMLDoc: IXMLDocument;
  RootNode: IXMLNode;
  ApplicationSettingsNode: IXMLNode;
  MainFormNode: IXMLNode;
  LayoutsWidthNode: IXMLNode;
  BackupsNode: IXMLNode;
  FavoriteCellIdListNode: IXMLNode;
  FavoriteCellIdNode: IXMLNode;

  CurrentValuesNode: IXMLNode;

  OnlineModeBoolean: Boolean;
  CollapseAppAtStartupBoolean: Boolean;
begin
  ApplicationSettingsFileName := ExtractFilePath(ParamStr(0)) + SETTINGS_FILE_NAME;

  if not FileExists(ApplicationSettingsFileName) then
  begin
    //при самом первом запуске приложения файл может не существовать
    //это совершенно нормальная ситуация

    Exit;
  end;

  try
    XMLDoc := LoadXMLDocument(ApplicationSettingsFileName);
  except
    raise Exception.CreateFmt('Can`t load %s', [SETTINGS_FILE_NAME]);
  end;

  if XMLDoc = nil then
  begin
    raise Exception.CreateFmt('Error reading %s', [SETTINGS_FILE_NAME]);
  end;

  RootNode := XMLDoc.ChildNodes.FindNode('Data');
  if RootNode = nil then
  begin
    raise Exception.CreateFmt('Root node is nil in %s', [SETTINGS_FILE_NAME]);
  end;

  ApplicationSettingsNode := RootNode.ChildNodes.FindNode('ApplicationSettings');
  if ApplicationSettingsNode = nil then
  begin
    raise Exception.CreateFmt('ApplicationSettings node is nil in %s', [SETTINGS_FILE_NAME]);
  end;

  // Читаем из реестра
  FRunAppAtStartup.FromBoolean(TRegistryTools.AutoRunKeyExists(APP_NAME));

  OnlineModeBoolean := IfNullAttribute(ApplicationSettingsNode, 'OnlineMode', false);
  FOnlineMode.FromBoolean(OnlineModeBoolean);

  CollapseAppAtStartupBoolean :=
    IfNullAttribute(ApplicationSettingsNode, 'CollapseAppAtStartup', false);
  FCollapseAppAtStartup.FromBoolean(CollapseAppAtStartupBoolean);

  MainFormNode := ApplicationSettingsNode.ChildNodes.FindNode('MainForm');
  if ApplicationSettingsNode = nil then
  begin
    raise Exception.CreateFmt('MainForm node is nil in %s', [SETTINGS_FILE_NAME]);
  end;

  FMainFormHeight := IfEmpty(MainFormNode, 'Height', 0);
  FMainFormWidth := IfEmpty(MainFormNode, 'Width', 0);
  FMainFormTop := IfEmpty(MainFormNode, 'Top', 0);
  FMainFormLeft := IfEmpty(MainFormNode, 'Left', 0);
  FIsFoldersLayoutShowing := IfEmpty(MainFormNode, 'IsFoldersLayoutShowing', 0);
  FIsFavoriteCellsShowing := IfEmpty(MainFormNode, 'IsFavoriteCellsShowing', 0);

  LayoutsWidthNode := ApplicationSettingsNode.ChildNodes.FindNode('LayoutsWidth');
  if ApplicationSettingsNode = nil then
  begin
    raise Exception.CreateFmt('LayoutsWidth node is nil in %s', [SETTINGS_FILE_NAME]);
  end;

  FCellLayoutWidth := IfEmpty(LayoutsWidthNode, 'CellLayoutWidth', 0);
  FCellsLayoutWidth := IfEmpty(LayoutsWidthNode, 'CellsLayoutWidth', 0);

  BackupsNode := ApplicationSettingsNode.ChildNodes.FindNode('Backups');
//  if BackupsNode = nil then
//  begin
//    raise Exception.CreateFmt('Backups node is nil in %s', [SETTINGS_FILE_NAME]);
//  end;

  FBackupsPath := IfEmpty(BackupsNode, 'Path', ExtractFilePath(ParamStr(0)) + DB_BACKUP_PATH);
  FLastBackupDateTime := IfEmpty(BackupsNode, 'LastDateTime', Now - 1);

  // FavoriteCellIdListNode - может отсутствовать, это допустимо
  FavoriteCellIdListNode := ApplicationSettingsNode.ChildNodes.FindNode('FavoriteCellIdList');
  if Assigned(FavoriteCellIdListNode) then
  begin
    FavoriteCellIdNode := FavoriteCellIdListNode.ChildNodes.First;
    while Assigned(FavoriteCellIdNode) do
    begin
      FFavoriteCellIdList.Add(FavoriteCellIdNode.Text.ToInt64);
      FavoriteCellIdNode := FavoriteCellIdNode.NextSibling;
    end;
  end;

  CurrentValuesNode := ApplicationSettingsNode.ChildNodes.FindNode('CurrentValues');
  FCurrentFolderId := IfEmpty(CurrentValuesNode, 'CurrentFolderId', 1);
  FCurrentCellId := IfEmpty(CurrentValuesNode, 'CurrentCellId', 0);
end;

procedure TApplicationSettings.SetOnlineMode(const AOnlineMode: TOnlineMode);
begin
  FOnlineMode := AOnlineMode;
end;

function TApplicationSettings.GeOnlineMode: TOnlineMode;
begin
  Result := FOnlineMode;
end;

procedure TApplicationSettings.SetRunAppAtStartup(
  const ARunAppAtStartup: TRunAppAtStartup);
begin
  FRunAppAtStartup := ARunAppAtStartup;
end;

function TApplicationSettings.GetRunAppAtStartup: TRunAppAtStartup;
begin
  Result := FRunAppAtStartup;
end;

procedure TApplicationSettings.SetCollapseAppAtStartup(
  const ACollapseAppAtStartup: TCollapseAppAtStartup);
begin
  FCollapseAppAtStartup := ACollapseAppAtStartup;
end;

function TApplicationSettings.GetCollapseAppAtStartup: TCollapseAppAtStartup;
begin
  Result := FCollapseAppAtStartup;
end;

{ TApplicationSettings.End }

end.
