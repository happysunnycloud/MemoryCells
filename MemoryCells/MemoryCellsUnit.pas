unit MemoryCellsUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.Objects, FMX.Edit, FMX.Menus
  , Windows
  , BaseFormUnit
  , DataManagerUnit
  , CellUnit
  , BorderFrameUnit
  , CurrentFolderFrameUnit
  , CellMemoFrameUnit
  , CellUnitFrameUnit
  , FolderUnitFrameUnit
  , CommonUnit
  , ParamsExtUnit
  , UTClientUnit
  , TransportContainerUnit
  , CellReminderDateTimeFrameUnit
  , FMX.Craft.PopupMenu.Win, FMX.DateTimeCtrls
  , BaseThreadUnit
  ;

const
  TEXT_FONT_SIZE = 16;

type
  TEventsManager = class;

  TMainForm = class(TBaseForm)
    FoldersScrollBox: TScrollBox;
    CellsScrollBox: TScrollBox;
    CellLayout: TLayout;
    ControlsLayout: TLayout;
    HomeButton: TButton;
    InfoLayout: TLayout;
    StyleBook: TStyleBook;
    ControlsRectangle: TRectangle;
    CellControlLayout: TLayout;
    CellMemoLayout: TLayout;
    loContent: TLayout;
    loScreen: TLayout;
    UpdateCellButton: TButton;
    InsertCellButton: TButton;
    DeleteCellButton: TButton;
    FoldersLayout: TLayout;
    FoldersControlLayout: TLayout;
    FolderNameLayout: TLayout;
    InsertFolderButton: TButton;
    DeleteFolderButton: TButton;
    RenameFolderButton: TButton;
    CellsLayout: TLayout;
    CellsControlLayout: TLayout;
    FoldersSplitter: TSplitter;
    CellsSplitter: TSplitter;
    ControlLayout: TLayout;
    HideFoldersButton: TButton;
    SearchButton: TButton;
    ContentLayout: TLayout;
    TextLayout: TLayout;
    InfoRectangle: TRectangle;
    ShowFavoriteCellsButton: TButton;
    CellPopupMenu: TPopupMenu;
    SetDoneMenuItem: TMenuItem;
    SetDestinationMenuItem: TMenuItem;
    VersionLabel: TLabel;
    SetSelectModeOnMenuItem: TMenuItem;
    SetSelectAllMenuItem: TMenuItem;
    SetSelectModeOffMenuItem: TMenuItem;
    SetUnselectAllMenuItem: TMenuItem;
    SetSelectModeOffSplitterMenuItem: TMenuItem;
    SetSelectModeOnSplitterMenuItem: TMenuItem;
    OnlineModeCheckBox: TCheckBox;
    OnlineStateCircle: TCircle;
    LoadCatalogButton: TButton;
    OnlineLayout: TLayout;
    StatusLabel: TLabel;
    CellRemindButton: TButton;
    FoldersControlRectangle: TRectangle;
    CellsControlRectangle: TRectangle;
    CellControlRectangle: TRectangle;
    SettingsButton: TButton;
    procedure UpdateCellButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure HomeButtonClick(Sender: TObject);
    procedure InsertCellButtonClick(Sender: TObject);
    procedure DeleteCellButtonClick(Sender: TObject);
    procedure RenameFolderButton0Click(Sender: TObject);
    procedure InsertFolderButtonClick(Sender: TObject);
    procedure DeleteFolderButtonClick(Sender: TObject);
    procedure RenameFolderButtonClick(Sender: TObject);
    procedure FoldersSplitterMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure FoldersLayoutResize(Sender: TObject);
    procedure CellsLayoutResize(Sender: TObject);
    procedure CellLayoutResize(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure HideFoldersButtonClick(Sender: TObject);
    procedure SearchButtonClick(Sender: TObject);
    procedure ShowFavoriteCellsButtonClick(Sender: TObject);
    procedure SetDoneMenuItemClick(Sender: TObject);
    procedure SetDestinationMenuItemClick(Sender: TObject);
    procedure SetSelectModeOnMenuItemClick(Sender: TObject);
    procedure SetSelectAllMenuItemClick(Sender: TObject);
    procedure SetSelectModeOffMenuItemClick(Sender: TObject);
    procedure SetUnselectAllMenuItemClick(Sender: TObject);
    procedure OnlineModeCheckBoxChange(Sender: TObject);
    procedure LoadCatalogButtonClick(Sender: TObject);
    procedure CellRemindButtonClick(Sender: TObject);
    procedure SettingsButtonClick(Sender: TObject);
  strict private
    FBorderFrame: TBorderFrame;

    FFoldersMinWidth: Single;
    FFoldersMaxWidth: Single;

    FCellsMinWidth: Single;
    FCellsMaxWidth: Single;

    FCellMinWidth: Single;
    FCellMaxWidth: Single;

    FTrayPopupMenu: TCraftPopupMenu;
    FCellReminderDateTimeFrame: TCellReminderDateTimeFrame;

    procedure CreateFolderUnitFrame(
      const ACell: TCell;
      const AParentScrollBox: TScrollBox;
      const AFolderUnitButtonOnClickHandler: TNotifyEvent);
    function  CreateCellUnitFrame(const ACell: TCell): TCellUnitFrame;

    procedure MoveCells(const AActionType: TActionType);
    // Тихая вставка текста, с обходом события CellMemoFrame.OnCellMemoChangeTracking
    // Хук позволяет не блокировать кнопку вставки ячейки, если изменений в CellMemo не производили
    procedure SilentTextInsertIntoCellMemo(const AText: String);
    procedure SetCellMemoFrameNullId;

    procedure StartOnline;
    procedure StopOnline;

    procedure RaiseAppException(const AMethod: String; const AE: Exception);
  protected
    procedure CreateHandle; override;
    procedure DestroyHandle; override;
  private
    //FEventRecordList: TEventRecordList;
    FEventsManager: TEventsManager;

    FCurrentFolderFrame: TCurrentFolderFrame;
    FCellMemoFrame: TCellMemoFrame;

    function GetCellMemo: TMemo;

    procedure ClearScrollBox(const AScrollBox: TScrollBox);

    procedure BuildDestinationFolderCatalog(const AParams: TParamsExt);
    procedure UpdateCell(const AParams: TParamsExt);
    procedure UpdateCellIsDone(const AParams: TParamsExt);
    procedure InsertCell(const AParams: TParamsExt);
    procedure DeleteCell(const AParams: TParamsExt);
    procedure UpdateFolder(const AParams: TParamsExt);
    procedure InsertFolder(const AParams: TParamsExt);
    procedure DeleteFolderError(const AParams: TParamsExt);

    procedure SearchResult(const AParams: TParamsExt);
    procedure CellsSearchResult(const AParams: TParamsExt);

    procedure ShowCellReminderForm(const AParams: TParamsExt);

    procedure BackupDone(const AParams: TParamsExt);
    procedure StartBackup(const AParams: TParamsExt);
    procedure RunBackupStarter;

    procedure DoDeleteCell(
      const ACellId: Int64;
      const ALockInterface: Boolean);

    // Обновление (Update) ячейки идет через событие TCell.OnContentChanged

    procedure ShowFoldersLayout(const AShow: Boolean);
    procedure ShowFavoriteCells(const AShow: Boolean);

    // Handlers.Begin
    procedure TrayIconMouseRightButtonDown(
      Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);

    procedure UTClientOnExceptionHandler(const AErrorCode: TUTCErrorCode; const AExceptionMessage: String);

    procedure PingUTClientOnConnectedHandler(Sender: TObject);
    procedure PingUTClientOnDisconnectedHandler(Sender: TObject);
    procedure PingUTClientOnAuthorizedHandler(Sender: TObject);
    procedure PingUTClientOnPingTimeoutHandler(const AObject: Pointer);

    procedure ClientOnReadHandler(const ATransportContainer: TTransportContainer);
    // Handlers.End
  public
    // Handlers.Begin
    procedure EditFolderNameOkHandler(Sender: TObject);
    procedure EditFolderNameCancelHandler(Sender: TObject);
    procedure InsertFolderNameOkHandler(Sender: TObject);
    procedure CellMemoChangeTrackingHandler(Sender: TObject);
    //procedure CellMemoExitHandler(Sender: TObject);

    procedure SearchTextOkHandler(Sender: TObject);
    procedure SearchTextCancelHandler(Sender: TObject);
    procedure SearchTextEditChangeHandler(Sender: TObject);
    procedure SearchResultFolderUnitFrameClickHandler(Sender: TObject);
    procedure NextHightlightButtonHandler(Sender: TObject);
    procedure PrevHightlightButtonHandler(Sender: TObject);

    procedure DestinationFolderNavigatorCancelHandler(Sender: TObject);
    procedure DestinationFolderNavigatorMoveCellsHandler(Sender: TObject);
    procedure DestinationFolderNavigatorCopyCellsHandler(Sender: TObject);

    procedure CellUnitCheckBoxOnChangeHandler(Sender: TObject);

    procedure CurrentFolderUnitFrameClickHandler(Sender: TObject);

    procedure DestinationCurrentFolderUnitFrameClickHandler(Sender: TObject);
    procedure FolderUnitFrameClickHandler(Sender: TObject);
    procedure DestinationFolderUnitFrameClickHandler(Sender: TObject);
    procedure FavoriteCellButtonClickHandler(Sender: TObject);
    procedure CellUnitFrameClickHandler(Sender: TObject);
    procedure CellReminderOkButtonClickHandler(Sender: TObject);
    procedure CellReminderOnChangedHandler(Sender: TObject);

    procedure SettingsFrameCancelButtonClickHandler(Sender: TObject);

    procedure ShowCellReminderFrame;
    procedure HideCellReminderFrame;

    // Handlers.End

    procedure BuildFolderCatalog(const AParams: TParamsExt);
    procedure OpenCell(const AParams: TParamsExt);
    procedure StartCellReminder(const AParams: TParamsExt);

    procedure GotoFolder(const AFolderId: Int64; const ACellId: Int64);
    procedure GotoDestinationFolder(const AFolderId: Int64);
    procedure GotoCell(const ACell: TCell);
    procedure GotoSearchResultFolder(const ACellIdList: TCellIdList);
    //procedure GetReminder;
    procedure RestartReminder;

    procedure DoUpdateCell(const AProcRef: TParamsProcRef);

    procedure UpdateCellReminder(const ACell: TCell);
    procedure CellReminderUpdated(const AParams: TParamsExt);

    procedure CheckControls;
//    procedure StoreEvents;
//    procedure ReStoreEvents;

    property BorderFrame: TBorderFrame read FBorderFrame;

    property  CurrentFolderFrame: TCurrentFolderFrame read FCurrentFolderFrame;
    property  CellMemo: TMemo read GetCellMemo;
    property  CellMemoFrame: TCellMemoFrame read FCellMemoFrame;
  end;

  TEventsManager = class
  strict private
    FMainForm: TMainForm;
    FEventRecordList: TEventRecordList;
  public
    constructor Create(const AMainForm: TMainForm); overload;
    destructor Destroy; override;

    procedure StoreEvents;
    procedure ReStoreEvents;
    procedure DeleteByControl(const AControl: TControl);
  end;

var
  MainForm: TMainForm;
  KeyHookHandle: THandle;
  HookSwitchProc: procedure (ASwitch: Boolean) stdcall;

implementation

{$R *.fmx}

uses
    System.Generics.Collections
  , System.Generics.Defaults
  , ToolsUnit
  , FileToolsUnit
  , AppManagerUnit
  , LoadCatalogThreadUnit
  , EditFolderNameFrameUnit
  , SearchTextFrameUnit
  , DestinationFolderNavigatorFrameUnit
  , KeyCatcherThreadUnit
  , UTClientManagerUnit
  , UTClientRequestUnit
  , PingTimeoutThreadUnit
  , DBAccessUnit
  , ServerRepliesParserUnit
  , UTServerReplyUnit
  , FMX.MemoTextHighlighterUnit
  , FMX.ShowNoteFormUnit
  , FMX.OnClickReplacerUnit
  , FMX.ShowStatusUnit
  , FMX.Craft.PopupMenu.Structures
  , FMX.Platform.Win
  , VCL.Graphics
  , Winapi.Messages
  , SupportUnit
  , AddLogUnit
  , CellReminderFormUnit
  , FMX.ThemeUnit
  , SettingsFrameUnit
  ;

type
  TShowStatusExt = class(TShowStatus)
  strict private
    class var
      FTextControl: TControl;
      FTimeout: Word;
  public
    class procedure Init(const ATextControl: TControl; const ATimeout: Word);
    class procedure ShowCellUpdated(const AParams: TParamsExt);
    class procedure ShowCellReminderUpdated;
  end;

//function KeyHook(Code: Integer; wParam: Word; lParam: Longint): Longint;
  //stdcall; external 'KeyHook' name 'KeyHookProc';

procedure CloseApp;
begin
  if Assigned(MainForm) then
    MainForm.BorderFrame.CloseButtonRectangle.OnClick(MainForm.BorderFrame.CloseButtonRectangle);
end;

class procedure TShowStatusExt.Init(const ATextControl: TControl; const ATimeout: Word);
begin
  TComponentFunctions.CheckHasComponentProperty(ATextControl, 'Text');

  FTextControl := ATextControl;
  FTimeout := ATimeout;
end;

class procedure TShowStatusExt.ShowCellUpdated(const AParams: TParamsExt);
begin
  TShowStatus.ShowStatus(FTextControl, 'Cell saved', FTimeout);
end;

class procedure TShowStatusExt.ShowCellReminderUpdated;
begin
  TShowStatus.ShowStatus(FTextControl, 'Cell reminder updated', FTimeout);
end;

procedure TMainForm.DeleteCellButtonClick(Sender: TObject);
var
  CellId: Int64;
begin
  CellId := CellMemoFrame.Cell.Id;
  DoDeleteCell(CellId, true);
end;

procedure TMainForm.CurrentFolderUnitFrameClickHandler(Sender: TObject);
const
  Method = 'CurrentFolderUnitFrameClickHandler';
var
  FolderId: Int64;
begin
  if Sender is TPanel then
  begin
    FolderId := TCurrentFolderFrame(TPanel(Sender).Owner).Cell.FolderId;
    GotoFolder(FolderId, NULL_ID);
  end
  else
    raise Exception.CreateFmt('%s: Sender is not a TPanel', [Method]);
end;

procedure TMainForm.DestinationCurrentFolderUnitFrameClickHandler(Sender: TObject);
const
  Method = 'DestinationCurrentFolderUnitFrameClickHandler';
var
  FolderId: Int64;
begin
  if Sender is TPanel then
  begin
    FolderId := TCurrentFolderFrame(TPanel(Sender).Owner).Cell.FolderId;
    GotoDestinationFolder(FolderId);
  end
  else
    raise Exception.CreateFmt('%s: Sender is not a TPanel', [Method]);
end;

procedure TMainForm.FolderUnitFrameClickHandler(Sender: TObject);
var
  Button: TButton;
  FolderId: Int64;
  FolderUnitFrame: TFolderUnitFrame;
begin
  if Sender is TButton then
  begin
    Button := TButton(Sender);
    FolderUnitFrame := TFolderUnitFrame(Button.Owner);
    FolderId := FolderUnitFrame.Cell.Id;
    GotoFolder(FolderId, NULL_ID);
  end
  else
    raise Exception.Create('FolderUnitFrameClick: Sender is not a TButton');
end;

procedure TMainForm.DestinationFolderUnitFrameClickHandler(Sender: TObject);
var
  Button: TButton;
  FolderId: Int64;
  FolderUnitFrame: TFolderUnitFrame;
begin
  if Sender is TButton then
  begin
    Button := TButton(Sender);
    FolderUnitFrame := TFolderUnitFrame(Button.Owner);
    FolderId := FolderUnitFrame.Cell.Id;
    GotoDestinationFolder(FolderId);
  end
  else
    raise Exception.Create('FolderUnitFrameClick: Sender is not a TButton');
end;

procedure TMainForm.SearchResultFolderUnitFrameClickHandler(Sender: TObject);
var
  Button: TButton;
  FolderUnitFrame: TFolderUnitFrame;
  Folder: TCell;
  CellIdList: TCellIdList;
begin
  if Sender is TButton then
  begin
    Button := TButton(Sender);
    FolderUnitFrame := TFolderUnitFrame(Button.Owner);

    Folder := FolderUnitFrame.Cell;
    CellIdList := Folder.LinkedCellIdList;

    GotoSearchResultFolder(CellIdList);
  end
  else
    raise Exception.Create('FolderUnitFrameClick: Sender is not a TButton');
end;

procedure TMainForm.NextHightlightButtonHandler(Sender: TObject);
begin
  if TMemoTextHighlighter.IsClear then
  begin
    TMemoTextHighlighter.CalculatePositions(SearchTextFrame.SearchTextEdit.Text, CellMemo);
    TMemoTextHighlighter.Highlight(TMemoTextHighlighter.FirstPosition);
  end
  else
    TMemoTextHighlighter.Highlight(true);
end;

procedure TMainForm.PrevHightlightButtonHandler(Sender: TObject);
begin
  if TMemoTextHighlighter.IsClear then
  begin
    TMemoTextHighlighter.CalculatePositions(SearchTextFrame.SearchTextEdit.Text, CellMemo);
    TMemoTextHighlighter.Highlight(TMemoTextHighlighter.LastPosition);
  end
  else
    TMemoTextHighlighter.Highlight(false);
end;

procedure TMainForm.FavoriteCellButtonClickHandler(Sender: TObject);
var
  Cell: TCell;
  Button: TButton;
  CellUnitFrame: TCellUnitFrame;
begin
  if Sender is TButton then
  begin
    Button := TButton(Sender);
    CellUnitFrame := TCellUnitFrame(Button.Owner);
    Cell := CellUnitFrame.Cell;

    CellUnitFrame.FavoriteCellButton.StyleLookup := 'PinOnButtonstyle';
    if AppManager.Settings.FavoriteCellIdList.Contains(Cell.Id) then
    begin
      CellUnitFrame.FavoriteCellButton.StyleLookup := 'PinOffButtonstyle';
      AppManager.Settings.FavoriteCellIdList.Remove(Cell.Id)
    end
    else
    begin
      AppManager.Settings.FavoriteCellIdList.Add(Cell.Id)
    end;
  end
  else
    raise Exception.Create('FavoriteCellButtonClick: Sender is not a TButton');
end;

procedure TMainForm.CellUnitFrameClickHandler(Sender: TObject);
var
  Cell: TCell;
  Button: TButton;
  CellUnitFrame: TCellUnitFrame;
begin
  if Sender is TButton then
  begin
    Button := TButton(Sender);
    CellUnitFrame := TCellUnitFrame(Button.Owner);
    Cell := CellUnitFrame.Cell;

    GotoCell(Cell);
  end
  else
    raise Exception.Create('CellUnitFrameClick: Sender is not a TButton');
end;

procedure TMainForm.CellReminderOkButtonClickHandler(Sender: TObject);
begin
  CellReminderOnChangedHandler(Sender);

  UpdateCellReminder(CellMemoFrame.Cell);

  HideCellReminderFrame;
end;

procedure TMainForm.CellReminderOnChangedHandler(Sender: TObject);
begin
  CellMemoFrame.SetCellReminder(
    FCellReminderDateTimeFrame.Cell.RemindDateTime,
    FCellReminderDateTimeFrame.Cell.Remind);
end;

procedure TMainForm.SettingsFrameCancelButtonClickHandler(Sender: TObject);
begin
  FreeAndNil(SettingsFrame);
end;

procedure TMainForm.ShowCellReminderFrame;
begin
  if not Assigned(CellMemoFrame) then
    Exit;

  if not Assigned(FCellReminderDateTimeFrame) then
  begin
    CellRemindButton.StyleLookup := 'RemindButtonPressedStyle';

    FCellReminderDateTimeFrame :=
      TCellReminderDateTimeFrame.ShowCellReminderFrame(CellMemoLayout, CellMemoFrame.Cell);
    FCellReminderDateTimeFrame.OkButton.OnClick := CellReminderOkButtonClickHandler;

    FCellReminderDateTimeFrame.OnDateTimeChanged := CellReminderOnChangedHandler;
    FCellReminderDateTimeFrame.OnRemindChanged := CellReminderOnChangedHandler;

    Self.Repaint;
  end
end;

procedure TMainForm.HideCellReminderFrame;
begin
  CellRemindButton.StyleLookup := 'RemindButtonNormalStyle';

  TCellReminderDateTimeFrame.HideCellReminderFrame(FCellReminderDateTimeFrame);
end;

procedure TMainForm.ShowFoldersLayout(const AShow: Boolean);
begin
  if AShow then
  begin
    HideFoldersButton.StyleLookup := 'HideFoldersButtonStyle';

    FoldersLayout.Visible := true;
    FoldersSplitter.Visible := true;

    AppManager.Settings.IsFoldersLayoutShowing := 1;

    MainForm.Resize;
  end
  else
  begin
    HideFoldersButton.StyleLookup := 'ShowFoldersButtonStyle';

    FoldersLayout.Visible := false;
    FoldersSplitter.Visible := false;

    AppManager.Settings.IsFoldersLayoutShowing := 0;

    MainForm.Resize;
  end;
end;

procedure TMainForm.ShowFavoriteCells(const AShow: Boolean);
begin
  SetCellMemoFrameNullId;
  //CellMemoFrame.CellUnitFrame := nil;

  if AShow then
  begin
    ShowFavoriteCellsButton.StyleLookup := 'PinOnButtonstyle';

    ShowFoldersLayout(false);
    FolderNameLayout.Visible := false;

    TFMXControlTools.EnableControls([
      HideFoldersButton,
      SearchButton,
      HomeButton,
      InsertCellButton
    ], false);

    AppManager.Settings.IsFavoriteCellsShowing := 1;

    AppManager.CreateLoadCellsByIdListThread(Self, AppManager.Settings.FavoriteCellIdList, CellsSearchResult);
  end
  else
  begin
    ShowFavoriteCellsButton.StyleLookup := 'PinOffButtonstyle';

    ShowFoldersLayout(true);
    FolderNameLayout.Visible := true;

    TFMXControlTools.EnableControls([
      HideFoldersButton,
      SearchButton,
      HomeButton,
      InsertCellButton
    ], true);

    AppManager.Settings.IsFavoriteCellsShowing := 0;

    GotoFolder(ROOT_FOLDER_ID, NULL_ID);
  end;
end;

procedure TMainForm.GotoFolder(const AFolderId: Int64; const ACellId: Int64);
begin
  TFMXControlTools.EnableControls([
    InsertFolderButton,
    RenameFolderButton,
    DeleteFolderButton,
    InsertCellButton,
    SearchButton,
    HomeButton
  ], false);

  SetCellMemoFrameNullId;
  //CellMemoFrame.CellUnitFrame := nil;
  AppManager.CreateLoadCatalogThread(Self, AFolderId, ACellId);
end;

procedure TMainForm.GotoDestinationFolder(const AFolderId: Int64);
begin
//  TFMXControlTools.EnableControls([
//    InsertCellButton,
//    UpdateCellButton,
//    DeleteCellButton,
//    SearchButton,
//    HomeButton,
//    UpdateCellButton
//  ], false);

  AppManager.CreateLoadDestinationCatalogThread(Self, AFolderId, BuildDestinationFolderCatalog);
end;

procedure TMainForm.GotoCell(const ACell: TCell);
begin
  TFMXControlTools.EnableControls([
    UpdateCellButton,
    CellRemindButton
  ], false);

  AppManager.CreateLoadCellThread(Self, ACell, OpenCell);
end;

procedure TMainForm.GotoSearchResultFolder(const ACellIdList: TCellIdList);
begin
  SetCellMemoFrameNullId;

  AppManager.CreateLoadCellsByIdListThread(Self, ACellIdList, CellsSearchResult);
end;

//procedure TMainForm.GetReminder;
//begin
//  AppManager.CreateLoadCellReminderThread(Self, StartCellReminder);
//end;

procedure TMainForm.RestartReminder;
var
  ThreadName: String;
  Thread: TThread;
begin
  ThreadName := 'TCellReminderThread';
  Thread := THelpmate.FindThreadByName(Self.ThreadRegistry, ThreadName);
  if Assigned(Thread) then
    Thread.Terminate;

  ThreadName := 'TLoadCellReminderThread';
  Thread := THelpmate.FindThreadByName(Self.ThreadRegistry, ThreadName);
  if Assigned(Thread) then
    Thread.Terminate;

  AppManager.CreateLoadCellReminderThread(Self, StartCellReminder);
end;

procedure TMainForm.DoUpdateCell(const AProcRef: TParamsProcRef);
var
  Cell: TCell;
begin
  // Передаем параметры именно через ячейку, что бы отработало Content -> Desc, где происходит урезание текста
  Cell := TCell.Create;
  try
    Cell.CopyFrom(CellMemoFrame.Cell);
    Cell.Content := CellMemo.Text;
    AppManager.CreateUpdateCellThread(Self, Cell, AProcRef);
  finally
    FreeAndNil(Cell);
  end;
end;

procedure TMainForm.UpdateCellReminder(const ACell: TCell);
begin
  AppManager.CreateUpdateCellThread(Self, ACell, CellReminderUpdated);
end;

procedure TMainForm.CellReminderUpdated(const AParams: TParamsExt);
begin
  TShowStatusExt.ShowCellReminderUpdated;

  RestartReminder;
end;

procedure TMainForm.HideFoldersButtonClick(Sender: TObject);
begin
  if AppManager.Settings.IsFoldersLayoutShowing = 1 then
    ShowFoldersLayout(false)
  else
    ShowFoldersLayout(true);
end;

procedure TMainForm.HomeButtonClick(Sender: TObject);
begin
  GotoFolder(ROOT_FOLDER_ID, NULL_ID);
end;

procedure TMainForm.InsertCellButtonClick(Sender: TObject);
begin
  TFMXControlTools.EnableControls([
    DeleteCellButton,
    InsertCellButton,
    UpdateCellButton,
    CellRemindButton,
    DeleteCellButton,
    SearchButton,
    HomeButton
  ], false);

  AppManager.CreateInsertCellThread(Self, CurrentFolderFrame.Cell.Id, InsertCell);
end;

procedure TMainForm.CreateFolderUnitFrame(
  const ACell: TCell;
  const AParentScrollBox: TScrollBox;
  const AFolderUnitButtonOnClickHandler: TNotifyEvent);
var
  FolderUnitFrame: TFolderUnitFrame;
  Cell: TCell absolute ACell;
begin
  FolderUnitFrame := TFolderUnitFrame.Create(AParentScrollBox, Cell);
  FolderUnitFrame.Name := Format('FolderUnitFrame%d', [Cell.Id]);
  FolderUnitFrame.Parent := AParentScrollBox;
  FolderUnitFrame.Align := TAlignLayout.Bottom;
  FolderUnitFrame.Repaint;
  FolderUnitFrame.Align := TAlignLayout.Top;
  FolderUnitFrame.Repaint;
  FolderUnitFrame.FolderUnitNameText.Text := Cell.Name;
  FolderUnitFrame.FolderUnitButton.StyleLookup := 'FolderUnitButtonStyle';
  FolderUnitFrame.FolderUnitButton.Text := '';
  FolderUnitFrame.FolderUnitNameText.TextSettings.FontColor := $FFBCBCBC;
  FolderUnitFrame.FolderUnitNameText.TextSettings.Font.Size := TEXT_FONT_SIZE;
  FolderUnitFrame.FolderUnitButton.OnClick := AFolderUnitButtonOnClickHandler;
end;

function TMainForm.CreateCellUnitFrame(const ACell: TCell): TCellUnitFrame;
var
  CellUnitFrame: TCellUnitFrame;
  Cell: TCell absolute ACell;
begin
  CellUnitFrame := TCellUnitFrame.Create(CellsScrollBox, Cell);
  CellUnitFrame.Name := Format('CellUnitFrame%d', [Cell.Id]);
  CellUnitFrame.Parent := CellsScrollBox;
  CellUnitFrame.Align := TAlignLayout.Bottom;
  CellUnitFrame.Repaint;
  CellUnitFrame.Align := TAlignLayout.Top;
  CellUnitFrame.Repaint;
  CellUnitFrame.CellUnitNameText.Text := Cell.Desc;
  CellUnitFrame.UpdateDateText.Text := DateTimeToStr(Cell.UpdateDateTime);
  CellUnitFrame.UpdateDateText.Hint := CellUnitFrame.UpdateDateText.Text;
  CellUnitFrame.CellUnitButton.StyleLookup := 'CellUnitButtonStyle';
  CellUnitFrame.CellUnitButton.Text := '';
  CellUnitFrame.CellUnitNameText.TextSettings.FontColor := $FFBCBCBC;
  CellUnitFrame.CellUnitNameText.TextSettings.Font.Size := TEXT_FONT_SIZE;
  CellUnitFrame.Padding.Left := 10;
  CellUnitFrame.UpdateDateText.TextSettings.FontColor := $FFBCBCBC;
  CellUnitFrame.UpdateDateText.TextSettings.Font.Size := 10;
  CellUnitFrame.FavoriteCellButton.StyleLookup := 'PinOffButtonstyle';
  if AppManager.Settings.FavoriteCellIdList.Contains(CellUnitFrame.Cell.Id) then
    CellUnitFrame.FavoriteCellButton.StyleLookup := 'PinOnButtonstyle';
  CellUnitFrame.FavoriteCellButton.OnClick := FavoriteCellButtonClickHandler;
//  CellUnitFrame.CreateDateText.TextSettings.FontColor := $FFBCBCBC;
//  CellUnitFrame.CreateDateText.TextSettings.Font.Size := 14;
  CellUnitFrame.CellUnitButton.OnClick := CellUnitFrameClickHandler;
  CellUnitFrame.CellUnitButton.PopupMenu := CellPopupMenu;

  Result := CellUnitFrame;
end;

procedure TMainForm.EditFolderNameOkHandler(Sender: TObject);
var
  Frame: TFrame;
  EditFolderNameFrame: TEditFolderNameFrame;
  FolderId: Int64;
  FolderName: String;
begin
  Frame := TFMXControlTools.FindParentFrame(TControl(Sender));
  EditFolderNameFrame := TEditFolderNameFrame(Frame);

  FolderId := EditFolderNameFrame.Params.AsInt64[0];
  FolderName := EditFolderNameFrame.FolderNameEdit.Text;

  EditFolderNameCancelHandler(EditFolderNameFrame.EditFolderNameCancelButton);

  AppManager.CreateUpdateFolderThread(
    Self,
    FolderId,
    FolderName,
    UpdateFolder);
end;

procedure TMainForm.EditFolderNameCancelHandler(Sender: TObject);
begin
  FreeAndNil(EditFolderNameFrame);

  TFMXControlTools.EnableControls([
    InsertFolderButton,
    RenameFolderButton,
    DeleteFolderButton,
    SearchButton,
    HomeButton
  ], true);

//  CheckControls;
end;

procedure TMainForm.InsertFolderNameOkHandler(Sender: TObject);
var
  Frame: TFrame;
  EditFolderNameFrame: TEditFolderNameFrame;
  FolderId: Int64;
  FolderName: String;
begin
  Frame := TFMXControlTools.FindParentFrame(TControl(Sender));
  EditFolderNameFrame := TEditFolderNameFrame(Frame);

  FolderName := EditFolderNameFrame.FolderNameEdit.Text;
  if Length(FolderName) = 0 then
    raise Exception.Create('Folder name is empty');

  FolderId := EditFolderNameFrame.Params.AsInt64[0];

  EditFolderNameCancelHandler(EditFolderNameFrame.EditFolderNameCancelButton);

  AppManager.CreateInsertFolderThread(
    Self,
    FolderId,
    FolderName,
    InsertFolder);
end;

procedure TMainForm.LoadCatalogButtonClick(Sender: TObject);
var
  TC: TTransportContainer;
begin
  if not Assigned(UTClientManager.DataClient) then
    Exit;

  if not UTClientManager.DataClient.IsConnected then
    Exit;

//  SetCellMemoFrameNullId;

  TC := TTransportContainer.Create;
  try
    TC.WriteAsInteger(TUTClientRequest.crLoadCatalog.ToInteger);
    TC.WriteAsInt64(AppManager.Settings.CurrentFolderId);
    TC.WriteAsInt64(AppManager.Settings.CurrentCellId);

    UTClientManager.DataClient.AddToStack(TC);
  finally
    FreeAndNil(TC);
  end;
end;

procedure TMainForm.SearchButtonClick(Sender: TObject);
begin
  TFMXControlTools.EnableControls([
    InsertFolderButton,
    RenameFolderButton,
    DeleteFolderButton,
    SearchButton,
    HomeButton
  ], false);

  SearchTextFrame := TSearchTextFrame.Create(Self);
  SearchTextFrame.Parent := FolderNameLayout;
  SearchTextFrame.Align := TAlignLayout.Left;
  SearchTextFrame.SearchTextEdit.Text := '';
  SearchTextFrame.SearchTextEdit.TextSettings.Assign(CurrentFolderFrame.FolderNameText.TextSettings);
  SearchTextFrame.SearchTextOkButton.OnClick := SearchTextOkHandler;
  SearchTextFrame.SearchTextCancelButton.OnClick := SearchTextCancelHandler;
  SearchTextFrame.SearchTextEdit.SetFocus;
end;

procedure TMainForm.CellLayoutResize(Sender: TObject);
begin
  if FCellMinWidth = 0 then
    Exit;

  if FCellMaxWidth = 0 then
    Exit;

  if CellLayout.Width < FCellMinWidth then
    CellLayout.Width := FCellMinWidth
  else
  if CellLayout.Width > FCellMaxWidth then
    CellLayout.Width := FCellMaxWidth;
end;

procedure TMainForm.CellMemoChangeTrackingHandler(Sender: TObject);
begin
  TFMXControlTools.EnableControls([
    DeleteFolderButton,
    InsertCellButton
  ], false);

  TFMXControlTools.EnableControls([
    UpdateCellButton,
    CellRemindButton
  ], true);

  if CellMemoFrame.CellMemoTextIsChanged then
  begin
    if TOnClickReplacer.HasReplaced then
      Exit;

    TOnClickReplacer.Replace(Self,
      [UpdateCellButton,
       DeleteCellButton,
       CellRemindButton,
       HideFoldersButton,
       FBorderFrame.RolldownButtonRectangle],
      procedure
      var
        ParamsProcRef: TParamsProcRef;
      begin
        TOnClickReplacer.Restore;

        if mrYes = TNoteForm.Show(TNoteIdentConst.SaveCell) then
        begin
          ParamsProcRef := TShowStatusExt.ShowCellUpdated;
          DoUpdateCell(ParamsProcRef);
        end
        else
        begin
          CellMemoFrame.RestoreContent;
        end;
      end
    );
  end
  else
  begin
    if TOnClickReplacer.HasReplaced then
      TOnClickReplacer.Restore;
  end;
end;

procedure TMainForm.SearchTextOkHandler(Sender: TObject);
var
  SearchText: String;
begin
  SearchText := SearchTextFrame.SearchTextEdit.Text;

  AppManager.CreateSearchThread(Self, SearchText, SearchResult);
end;

procedure TMainForm.SetDestinationMenuItemClick(Sender: TObject);
var
  FolderId: Int64;
  Cell: TCell;
  SelectedCellIdList: TCellIdList;
begin
//  TFMXControlTools.EnableControls([
//    InsertCellButton,
//    UpdateCellButton,
//    DeleteCellButton,
//    SearchButton,
//    HomeButton,
//    UpdateCellButton
//  ], false);

  SelectedCellIdList := TCellIdList.Create;
  try
    if AppManager.CurrentState.SelectMode = smFalse then
      SetSelectModeOnMenuItemClick(nil);

    THelpmate.CollectSelectedCellIdList(CellsScrollBox, SelectedCellIdList);

    DestinationFolderNavigatorFrame :=
      TDestinationFolderNavigatorFrame.GetOrCreate(Self, FCurrentFolderFrame.FolderNameText.TextSettings);

    DestinationFolderNavigatorFrame.SelectedCellIdList.CopyFrom(SelectedCellIdList);

    SetSelectModeOffMenuItemClick(nil);

    Cell := TCellUnitFrame(CellPopupMenu.PopupComponent.Owner).Cell;
    FolderId := Cell.FolderId;

    GotoDestinationFolder(FolderId);
  finally
    FreeAndNil(SelectedCellIdList);
  end;
end;

procedure TMainForm.SetDoneMenuItemClick(Sender: TObject);
var
  Cell: TCell;
begin
//  TFMXControlTools.EnableControls([
//    InsertCellButton,
//    UpdateCellButton,
//    DeleteCellButton,
//    SearchButton,
//    HomeButton
//  ], false);

  Cell := TCellUnitFrame(CellPopupMenu.PopupComponent.Owner).Cell;
  if Cell.IsDone then
    AppManager.CreateUpdateCellAttributesThread(Self, Cell.Id, false, UpdateCellIsDone)
  else
    AppManager.CreateUpdateCellAttributesThread(Self, Cell.Id, true, UpdateCellIsDone);
end;

procedure TMainForm.SetSelectAllMenuItemClick(Sender: TObject);
begin
  if AppManager.CurrentState.SelectMode = smFalse then
    SetSelectModeOnMenuItemClick(nil);

  THelpmate.ScrollBoxControls(CellsScrollBox,
    procedure (const AControl: TControl)
    var
      CellUnitCheckBox: TCheckBox;
    begin
      CellUnitCheckBox := TCellUnitFrame(AControl).CellUnitCheckBox;
      CellUnitCheckBox.IsChecked := true;
    end
  );
end;

procedure TMainForm.SetSelectModeOffMenuItemClick(Sender: TObject);
var
  VisibleFlag: Boolean;
begin
  AppManager.Settings.SelectedCellIdList.Clear;

  if AppManager.CurrentState.SelectMode = smTrue then
  begin
    SetSelectModeOffMenuItem.Visible := false;
    SetSelectModeOffMenuItem.Enabled := SetSelectModeOffMenuItem.Visible;
    SetUnselectAllMenuItem.Visible := false;
    SetUnselectAllMenuItem.Enabled := SetUnselectAllMenuItem.Visible;

    SetSelectModeOnMenuItem.Visible := true;
    SetSelectModeOnMenuItem.Enabled := SetSelectModeOnMenuItem.Visible;
    SetSelectAllMenuItem.Visible := true;
    SetSelectAllMenuItem.Enabled := SetSelectAllMenuItem.Visible;

    SetSelectModeOffSplitterMenuItem.Visible := false;
    SetSelectModeOffSplitterMenuItem.Enabled := SetSelectModeOffSplitterMenuItem.Visible;

    AppManager.CurrentState.SelectMode := smFalse;
    VisibleFlag := AppManager.CurrentState.SelectMode.ToBoolean;

    THelpmate.UnSelectAllCells(CellsScrollBox);
    THelpmate.ScrollBoxControls(CellsScrollBox,
      procedure (const AControl: TControl)
      begin
        THelpmate.CellUnitCheckBoxVisible(AControl, VisibleFlag, nil);
      end
    );
  end;
end;

procedure TMainForm.SetSelectModeOnMenuItemClick(Sender: TObject);
var
  CellUnitCheckBox: TCheckBox;
  VisibleFlag: Boolean;
  CellUnitFrame: TCellUnitFrame;
begin
  AppManager.Settings.SelectedCellIdList.Clear;

  if AppManager.CurrentState.SelectMode = smFalse then
  begin
    SetSelectModeOffMenuItem.Visible := true;
    SetSelectModeOffMenuItem.Enabled := SetSelectModeOffMenuItem.Visible;
    SetUnselectAllMenuItem.Visible := true;
    SetUnselectAllMenuItem.Enabled := SetUnselectAllMenuItem.Visible;

    SetSelectModeOnMenuItem.Visible := false;
    SetSelectModeOnMenuItem.Enabled := SetSelectModeOnMenuItem.Visible;
    SetSelectAllMenuItem.Visible := true;
    SetSelectAllMenuItem.Enabled := SetSelectAllMenuItem.Visible;

    SetSelectModeOffSplitterMenuItem.Visible := true;
    SetSelectModeOffSplitterMenuItem.Enabled := SetSelectModeOffSplitterMenuItem.Visible;

    AppManager.CurrentState.SelectMode := smTrue;
    VisibleFlag := AppManager.CurrentState.SelectMode.ToBoolean;

    THelpmate.ScrollBoxControls(CellsScrollBox,
      procedure (const AControl: TControl)
      begin
        THelpmate.CellUnitCheckBoxVisible(AControl, VisibleFlag, CellUnitCheckBoxOnChangeHandler);
      end
    );

    CellUnitFrame := TCellUnitFrame(CellPopupMenu.PopupComponent.Owner);
    CellUnitCheckBox := CellUnitFrame.CellUnitCheckBox;
    CellUnitCheckBox.IsChecked := true;
  end;
end;

procedure TMainForm.SettingsButtonClick(Sender: TObject);
begin
  //test repo
  if Assigned(SettingsFrame) then
    Exit;

  SettingsFrame := TSettingsFrame.Create(Self);
  SettingsFrame.Parent := Self.loScreen;
  SettingsFrame.Align := TAlignLayout.Contents;
  SettingsFrame.BringToFront;
  SettingsFrame.CancelButton.OnClick := SettingsFrameCancelButtonClickHandler;
end;

procedure TMainForm.SetUnselectAllMenuItemClick(Sender: TObject);
begin
  THelpmate.ScrollBoxControls(CellsScrollBox,
    procedure (const AControl: TControl)
    var
      CellUnitCheckBox: TCheckBox;
    begin
      CellUnitCheckBox := TCellUnitFrame(AControl).CellUnitCheckBox;
      CellUnitCheckBox.IsChecked := false;
    end
  );
end;

procedure TMainForm.SearchTextCancelHandler(Sender: TObject);
begin
  SearchTextFrame.HightlightLayout.Visible := false;

  FreeAndNil(SearchTextFrame);

  TFMXControlTools.EnableControls([
    InsertFolderButton,
    RenameFolderButton,
    DeleteFolderButton,
    SearchButton,
    HomeButton
  ], true);

  GotoFolder(AppManager.Settings.CurrentFolderId, NULL_ID);
end;

procedure TMainForm.SearchTextEditChangeHandler(Sender: TObject);
begin
  TMemoTextHighlighter.Clear;
end;

procedure TMainForm.DestinationFolderNavigatorCancelHandler(Sender: TObject);
begin
  FreeAndNil(DestinationFolderNavigatorFrame);
end;

procedure TMainForm.DestinationFolderNavigatorMoveCellsHandler(Sender: TObject);
begin
  MoveCells(atMove);
end;

procedure TMainForm.DestinationFolderNavigatorCopyCellsHandler(Sender: TObject);
begin
  MoveCells(atCopy);
end;

procedure TMainForm.MoveCells(const AActionType: TActionType);
var
  CellIdList: TCellIdList;
  DestinationFolderId: Int64;
begin
  CellIdList := TCellIdList.Create;
  try
    DestinationFolderId := DestinationFolderNavigatorFrame.CurrentFolderFrame.Cell.Id;

    CellIdList.CopyFrom(DestinationFolderNavigatorFrame.SelectedCellIdList);

    FreeAndNil(DestinationFolderNavigatorFrame);

    SetCellMemoFrameNullId;

    AppManager.CreateMoveCellsThread(
      Self,
      AppManager.Settings.CurrentFolderId,
      DestinationFolderId,
      CellIdList,
      AActionType);
  finally
    FreeAndNil(CellIdList);
  end;
end;

procedure TMainForm.CellUnitCheckBoxOnChangeHandler(Sender: TObject);
var
  Frame: FMX.Forms.TFrame;
  Cell: TCell;
  CellId: Int64;
begin
  Frame := TFMXControlTools.FindParentFrame(TControl(Sender));
  Cell := TCellUnitFrame(Frame).Cell;
  CellId := Cell.Id;

  if TCheckBox(Sender).IsChecked then
  begin
    if not AppManager.Settings.SelectedCellIdList.Contains(CellId) then
    begin
      AppManager.Settings.SelectedCellIdList.Add(CellId);
    end;
  end
  else
  begin
    if AppManager.Settings.SelectedCellIdList.Contains(CellId) then
    begin
      AppManager.Settings.SelectedCellIdList.Remove(CellId);
    end;
  end;
end;

procedure TMainForm.CellsLayoutResize(Sender: TObject);
begin
  if FCellsMinWidth = 0 then
    Exit;

  if FCellsMaxWidth = 0 then
    Exit;

//  if CellsLayout.Width < FCellsMinWidth then
//    CellsLayout.Width := FCellsMinWidth

//  else
//  if CellsLayout.Width > FCellsMaxWidth then
//    CellsLayout.Width := FCellsMaxWidth;
end;

procedure TMainForm.SilentTextInsertIntoCellMemo(const AText: String);
begin
  CellMemoFrame.DisableCellMemoChangeTracking;
  CellMemoFrame.InsertText(AText);
  CellMemoFrame.EnableCellMemoChangeTracking;
end;

procedure TMainForm.SetCellMemoFrameNullId;
begin
  //  if Assigned(FCellReminderDateTimeFrame) then
  //    FCellReminderDateTimeFrame.CancelButton.OnClick(nil);

  HideCellReminderFrame;

  SilentTextInsertIntoCellMemo('');

  CellMemoFrame.CellUnitFrame := nil;
  AppManager.Settings.CurrentCellId := NULL_ID;
end;

procedure TMainForm.FoldersLayoutResize(Sender: TObject);
begin
  if FFoldersMinWidth = 0 then
    Exit;

  if FFoldersMaxWidth = 0 then
    Exit;

  if FoldersLayout.Width < FFoldersMinWidth then
    FoldersLayout.Width := FFoldersMinWidth
  else
  if FoldersLayout.Width > FFoldersMaxWidth then
    FoldersLayout.Width := FFoldersMaxWidth;
end;

procedure TMainForm.FoldersSplitterMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
begin
  if FoldersLayout.Width <= 100 then
    FoldersLayout.Width := 100;
end;

function TMainForm.GetCellMemo: TMemo;
begin
  if not Assigned(FCellMemoFrame) then
    raise Exception.Create('TMainForm.GetCellMemo: FCellMemoUnitFrame is nil');

  Result := FCellMemoFrame.CellMemo;
end;

procedure TMainForm.ClearScrollBox(const AScrollBox: TScrollBox);
var
  Control: TControl;
  i: Integer;
begin
  i := AScrollBox.Content.ControlsCount;
  while i > 0 do
  begin
    Dec(i);

    Control := AScrollBox.Content.Controls[i];
    AScrollBox.Content.Controls.Delete(i);
    FreeAndNil(Control);
  end;
end;

procedure TMainForm.BuildFolderCatalog(const AParams: TParamsExt);
const
  METHOD = 'TMainForm.BuidFolderCatalog';
var
  OuterCellList: TCellList;
  CellList: TCellList;
  List: TInnerCellList;
  Cell: TCell;
  ParamsObj: TParamsExt;
  FolderId: Int64;
begin
  SetCellMemoFrameNullId;

  try
    CellList := TCellList.Create;
    try
      ParamsObj := TParamsExt.Create;
      try
        ParamsObj.CopyFrom(AParams);

        FolderId := ParamsObj.AsInt64[0];
        OuterCellList := ParamsObj.AsPointer[1];
        CellList.CopyFrom(OuterCellList);
        CellList.FolderParentId := FolderId;
      finally
        FreeAndNil(ParamsObj);
      end;

      ClearScrollBox(FoldersScrollBox);
      ClearScrollBox(CellsScrollBox);

      List := CellList.LockList;
      try
        for Cell in List do
        begin
          if Cell.CellTypeId = TCellType.ctFolder then
          begin
            if Cell.Id = CellList.FolderParentId then
            begin
              CurrentFolderFrame.Cell.CopyFrom(Cell);
    //          CurrentFolderFrame.Name := 'CurrentFolderFrame';
//              CurrentFolderFrame.Parent := FolderNameLayout;
//              CurrentFolderFrame.Align := TAlignLayout.Contents;
              CurrentFolderFrame.FolderNameText.Text := Cell.Content;//Cell.Name;
//              CurrentFolderFrame.Panel.StyleLookup := 'CurrentFolderPanelstyle';
//              CurrentFolderFrame.FolderNameText.TextSettings.FontColor := $FFBCBCBC;
//              CurrentFolderFrame.FolderNameText.TextSettings.Font.Size := 18;
//              CurrentFolderFrame.Panel.OnClick := CurrentFolderUnitFrameClick;

              AppManager.Settings.CurrentFolderId := CurrentFolderFrame.Cell.Id;
            end
            else
            begin
              CreateFolderUnitFrame(Cell, FoldersScrollBox, FolderUnitFrameClickHandler);
            end;
          end
          else
          if Cell.CellTypeId = TCellType.ctCell then
          begin
            CreateCellUnitFrame(Cell);
          end;
        end;
      finally
        CellList.UnlockList;
      end;
    finally
      FreeAndNil(CellList);
    end;

    TFMXControlTools.EnableControls([
      CellMemo,
      UpdateCellButton,
      DeleteCellButton,
      CellRemindButton
    ], false);

    TFMXControlTools.EnableControls([
      InsertFolderButton,
      RenameFolderButton,
      DeleteFolderButton,
      InsertCellButton,
      SearchButton,
      HomeButton
    ], true);

    DeleteFolderButton.Enabled := true;
    if CurrentFolderFrame.Cell.Id = ROOT_FOLDER_ID then
      DeleteFolderButton.Enabled := false;
  except
    on e: Exception do
    begin
      raise Exception.Create(Format('%s: %s', [METHOD, e.Message]));
    end;
  end;
end;

procedure TMainForm.CellRemindButtonClick(Sender: TObject);
begin
  if not Assigned(CellMemoFrame) then
    Exit;

  if not Assigned(FCellReminderDateTimeFrame) then
  begin
    ShowCellReminderFrame;
  end
  else
  begin
    HideCellReminderFrame;
  end;
end;

procedure TMainForm.BuildDestinationFolderCatalog(const AParams: TParamsExt);
const
  METHOD = 'TMainForm.BuidDestinationFolderCatalog';
var
  OuterCellList: TCellList;
  CellList: TCellList;
  List: TInnerCellList;
  Cell: TCell;
  ParamsObj: TParamsExt;
  FolderId: Int64;
  DestFoldersScrollBox: TScrollBox;
  DesCurrentFolderFrame: TCurrentFolderFrame;
begin
  DestinationFolderNavigatorFrame :=
    TDestinationFolderNavigatorFrame.GetOrCreate(Self, FCurrentFolderFrame.FolderNameText.TextSettings);
  DestinationFolderNavigatorFrame.Parent := loScreen;

  DestinationFolderNavigatorFrame.CancelButton.OnClick := DestinationFolderNavigatorCancelHandler;
  DestinationFolderNavigatorFrame.CancelButton.StyleLookup := 'CancelButtonStyle';

  DestinationFolderNavigatorFrame.MoveCellsButton.OnClick := DestinationFolderNavigatorMoveCellsHandler;
  DestinationFolderNavigatorFrame.MoveCellsButton.StyleLookup := 'MoveCellButtonStyle';

  DestinationFolderNavigatorFrame.CopyCellsButton.OnClick := DestinationFolderNavigatorCopyCellsHandler;
  DestinationFolderNavigatorFrame.CopyCellsButton.StyleLookup := 'CopyCellButtonStyle';

  DestinationFolderNavigatorFrame.Align := TAlignLayout.Contents;
  DestinationFolderNavigatorFrame.Visible := true;
  DestinationFolderNavigatorFrame.BringToFront;

  if not Assigned(DestinationFolderNavigatorFrame) then
    raise Exception.Create(Format('%s: %s', [METHOD, 'DestinationFolderNavigatorFrame not assigned']));

  DestFoldersScrollBox := DestinationFolderNavigatorFrame.FoldersScrollBox;

  try
    CellList := TCellList.Create;
    try
      ParamsObj := TParamsExt.Create;
      try
        ParamsObj.CopyFrom(AParams);

        FolderId := ParamsObj.AsInt64[0];
        OuterCellList := ParamsObj.AsPointer[1];
        CellList.CopyFrom(OuterCellList);
        CellList.FolderParentId := FolderId;
      finally
        FreeAndNil(ParamsObj);
      end;

      ClearScrollBox(DestFoldersScrollBox);

      List := CellList.LockList;
      try
        for Cell in List do
        begin
          if Cell.CellTypeId = TCellType.ctFolder then
          begin
            if Cell.Id = CellList.FolderParentId then
            begin
              DesCurrentFolderFrame := DestinationFolderNavigatorFrame.CurrentFolderFrame;
              DesCurrentFolderFrame.Cell.CopyFrom(Cell);

//              CurrentFolderFrame.Parent := FolderNameLayout;
//              CurrentFolderFrame.Align := TAlignLayout.Contents;
              DesCurrentFolderFrame.FolderNameText.Text := Cell.Content;//Cell.Name;
              DesCurrentFolderFrame.Panel.StyleLookup := 'CurrentFolderPanelstyle';
              DesCurrentFolderFrame.FolderNameText.TextSettings.FontColor := $FFBCBCBC;
              DesCurrentFolderFrame.FolderNameText.TextSettings.Font.Size := 18;
              DesCurrentFolderFrame.Panel.OnClick := DestinationCurrentFolderUnitFrameClickHandler;

//              AppManager.Settings.CurrentFolderId := CurrentFolderFrame.Cell.Id;
            end
            else
            begin
              CreateFolderUnitFrame(
                Cell,
                DestFoldersScrollBox,
                DestinationFolderUnitFrameClickHandler);
            end;
          end;
        end;
      finally
        CellList.UnlockList;
      end;
    finally
      FreeAndNil(CellList);
    end;

    TFMXControlTools.EnableControls([
      CellMemo,
      UpdateCellButton,
      DeleteCellButton,
      CellRemindButton
    ], false);

    TFMXControlTools.EnableControls([
      InsertFolderButton,
      RenameFolderButton,
      DeleteFolderButton,
      InsertCellButton,
      SearchButton,
      HomeButton
    ], true);

    DeleteFolderButton.Enabled := true;
    if CurrentFolderFrame.Cell.Id = ROOT_FOLDER_ID then
      DeleteFolderButton.Enabled := false;
  except
    on e: Exception do
    begin
      raise Exception.Create(Format('%s: %s', [METHOD, e.Message]));
    end;
  end;
end;

procedure TMainForm.ShowFavoriteCellsButtonClick(Sender: TObject);
var
  DoShowFavoriteCells: Boolean;
begin
  DoShowFavoriteCells := AppManager.Settings.IsFavoriteCellsShowing = 1;
  ShowFavoriteCells(not DoShowFavoriteCells);
end;

procedure TMainForm.InsertFolderButtonClick(Sender: TObject);
var
  Cell: TCell;
begin
  TFMXControlTools.EnableControls([
    InsertFolderButton,
    RenameFolderButton,
    DeleteFolderButton,
    SearchButton,
    HomeButton
  ], false);

  Cell := CurrentFolderFrame.Cell;
  EditFolderNameFrame := TEditFolderNameFrame.Create(Self);
  EditFolderNameFrame.Parent := FolderNameLayout;
  EditFolderNameFrame.Align := TAlignLayout.Left;
  EditFolderNameFrame.FolderNameEdit.Text := '';
  EditFolderNameFrame.FolderNameEdit.TextSettings.Assign(CurrentFolderFrame.FolderNameText.TextSettings);
  EditFolderNameFrame.Params.Add(Cell.Id);
  EditFolderNameFrame.EditFolderNameOkButton.OnClick := InsertFolderNameOkHandler;
  EditFolderNameFrame.EditFolderNameCancelButton.OnClick := EditFolderNameCancelHandler;
  EditFolderNameFrame.FolderNameEdit.SetFocus;
end;

procedure TMainForm.OnlineModeCheckBoxChange(Sender: TObject);
begin
  if OnlineModeCheckBox.IsChecked then
  begin
    StartOnline;
  end
  else
  begin
    StopOnline;
  end;
end;

procedure TMainForm.OpenCell(const AParams: TParamsExt);
const
  METHOD = 'TMainForm.OpenCell';
var
  ParamsObj: TParamsExt;
  CellId: Int64;
  FolderId: Int64;
  Content: String;
  CellTypeId: Integer;
  CellIsDone: Boolean;
  CellRemindDateTime: TDateTime;
  CellRemind: Boolean;
  Cell: TCell;
begin
  try
    SetCellMemoFrameNullId;

    ParamsObj := TParamsExt.Create;
    try
      ParamsObj.CopyFrom(AParams);
      CellId := ParamsObj.AsInt64[0];
      FolderId := ParamsObj.AsInt64[1];
      Content := ParamsObj.AsString[2];
      CellTypeId := ParamsObj.AsInteger[3];
      CellIsDone := ParamsObj.AsBoolean[4];
      //CellUpdateDateTime{5} - здесь не используем
      CellRemindDateTime := ParamsObj.AsDateTime[6];
      CellRemind := ParamsObj.AsBoolean[7];
    finally
      FreeAndNil(ParamsObj);
    end;

    Cell := TCell.Create;
    try
      Cell.Id := CellId;
      Cell.FolderId := FolderId;
      Cell.CellTypeId := CellTypeId;
      Cell.Content := Content;
      Cell.IsDone := CellIsDone;
      Cell.RemindDateTime := CellRemindDateTime;
      Cell.Remind := CellRemind;

      CellMemoFrame.SetCell(Cell);
    finally
      FreeAndNil(Cell);
    end;

    CellMemoFrame.CellUnitFrame := THelpmate.GetCellUnitFrameByCellId(CellsScrollBox, CellId);
    //    SilentTextInsertIntoCellMemo(CellMemoFrame.Cell.Content);
    THelpmate.SetMemoCellDefaultSettings(CellMemo);

    TFMXControlTools.EnableControls([
      CellMemo,
      DeleteCellButton,
      CellRemindButton
    ], true);

    CellMemo.SetFocus;
    case AppManager.CurrentState.Mode of
      TCurrentMode.cmCommon:
        AppManager.Settings.CurrentCellId := CellId;
      TCurrentMode.cmSearch:
      begin
        if Assigned(SearchTextFrame) then
        begin
          TMemoTextHighlighter.CalculatePositions(SearchTextFrame.SearchTextEdit.Text, CellMemo);
          TMemoTextHighlighter.Highlight(TMemoTextHighlighter.FirstPosition);
          SearchTextFrame.SearchTextEdit.OnChange := SearchTextEditChangeHandler;
          SearchTextFrame.HightlightLayout.Visible := true;
          SearchTextFrame.NextHightlightButton.OnClick := NextHightlightButtonHandler;
          SearchTextFrame.PrevHightlightButton.OnClick := PrevHightlightButtonHandler;
        end;
      end;
    end;
  except
    on e: Exception do
    begin
      raise Exception.Create(Format('%s: %s', [METHOD, e.Message]));
    end;
  end;
end;

procedure TMainForm.StartCellReminder(const AParams: TParamsExt);
const
  METHOD = 'TMainForm.StartCellReminder';
var
  ParamsObj: TParamsExt;
var
  Cell: TCell;
  CellId: Int64;
  FolderId: Int64;
  Content: String;
  CellTypeId: Integer;
  CellIsDone: Boolean;
  CellUpdateDateTime: TDateTime;
  CellRemindDateTime: TDateTime;
  CellRemind: Boolean;
begin
  try
    ParamsObj := TParamsExt.Create;
    try
      ParamsObj.CopyFrom(AParams);
      Cell := TCell.Create;
      try
        CellId := ParamsObj.AsInt64[0];
        FolderId := ParamsObj.AsInt64[1];
        Content := ParamsObj.AsString[2];
        CellTypeId := ParamsObj.AsInteger[3];
        CellIsDone := ParamsObj.AsBoolean[4];
        CellUpdateDateTime := ParamsObj.AsDateTime[5];
        CellRemindDateTime := ParamsObj.AsDateTime[6];
        CellRemind := ParamsObj.AsBoolean[7];

        Cell.Id := CellId;
        Cell.FolderId := FolderId;
        Cell.Content := Content;
        Cell.CellTypeId := CellTypeId;
        Cell.IsDone := CellIsDone;
        Cell.UpdateDateTime := CellUpdateDateTime;
        Cell.RemindDateTime := CellRemindDateTime;
        Cell.Remind := CellRemind;

        if CellId = 0 then
          Exit;

        AppManager.CreateCellReminderThread(Self, Cell, ShowCellReminderForm);
      finally
        FreeAndNil(Cell);
      end;
    finally
      FreeAndNil(ParamsObj);
    end;
  except
    on e: Exception do
    begin
      raise Exception.Create(Format('%s: %s', [METHOD, e.Message]));
    end;
  end;
end;

procedure TMainForm.RenameFolderButton0Click(Sender: TObject);
var
  EditFolderNameFrame: TEditFolderNameFrame;
  Cell: TCell;
begin
  Cell := CurrentFolderFrame.Cell;
  EditFolderNameFrame := TEditFolderNameFrame.Create(Self);
  EditFolderNameFrame.Parent := FolderNameLayout;
  EditFolderNameFrame.Align := TAlignLayout.Left;
  EditFolderNameFrame.FolderNameEdit.Text := CurrentFolderFrame.FolderNameText.Text;
  EditFolderNameFrame.FolderNameEdit.TextSettings.Assign(CurrentFolderFrame.FolderNameText.TextSettings);
  EditFolderNameFrame.Params.Add(Cell.Id);
  EditFolderNameFrame.EditFolderNameOkButton.OnClick := EditFolderNameOkHandler;
  EditFolderNameFrame.EditFolderNameCancelButton.OnClick := EditFolderNameCancelHandler;
end;

procedure TMainForm.RenameFolderButtonClick(Sender: TObject);
var
  Cell: TCell;
begin
  TFMXControlTools.EnableControls([
    InsertFolderButton,
    RenameFolderButton,
    DeleteFolderButton,
    SearchButton,
    HomeButton
  ], false);

  Cell := CurrentFolderFrame.Cell;
  EditFolderNameFrame := TEditFolderNameFrame.Create(Self);
  EditFolderNameFrame.Parent := FolderNameLayout;
  EditFolderNameFrame.Align := TAlignLayout.Left;
  EditFolderNameFrame.FolderNameEdit.Text := Cell.Name;//CurrentFolderFrame.FolderNameText.Text;
  EditFolderNameFrame.FolderNameEdit.TextSettings.Assign(CurrentFolderFrame.FolderNameText.TextSettings);
  EditFolderNameFrame.Params.Add(Cell.Id);
  EditFolderNameFrame.EditFolderNameOkButton.OnClick := EditFolderNameOkHandler;
  EditFolderNameFrame.EditFolderNameCancelButton.OnClick := EditFolderNameCancelHandler;
  EditFolderNameFrame.FolderNameEdit.SetFocus;
end;

procedure TMainForm.UpdateCell(const AParams: TParamsExt);
const
  METHOD = 'TMainForm.UpdateCell';
var
  ParamsObj: TParamsExt;
  CellContent: String;
  CellDesc: String;
begin
  try
    ParamsObj := TParamsExt.Create;
    try
      ParamsObj.CopyFrom(AParams);
      CellContent := ParamsObj.AsString[1];
      CellDesc := ParamsObj.AsString[2];
    finally
      FreeAndNil(ParamsObj);
    end;

    CellMemoFrame.Cell.Content := CellContent;
    CellMemo.Text := CellMemoFrame.Cell.Content;
    CellMemoFrame.CellUnitFrame.Cell.Desc := CellMemoFrame.Cell.Desc;
    CellMemo.SetFocus;

    TFMXControlTools.EnableControls([
      DeleteFolderButton,
      CellMemo,
      CellRemindButton,
      InsertCellButton,
      DeleteCellButton,
      SearchButton,
      HomeButton
    ], true);

    TOnClickReplacer.Restore;
    //FEventsManager.ReStoreEvents;

    TShowStatusExt.ShowCellUpdated(nil);
  except
    on e: Exception do
    begin
      raise Exception.Create(Format('%s: %s', [METHOD, e.Message]));
    end;
  end;
end;

procedure TMainForm.UpdateCellIsDone(const AParams: TParamsExt);
const
  METHOD = 'TMainForm.UpdateCellIsDone';
var
  ParamsObj: TParamsExt;
  CellId: Int64;
  CellIsDone: Boolean;
  CellUnitFrame: TCellUnitFrame;
begin
  try
    ParamsObj := TParamsExt.Create;
    try
      ParamsObj.CopyFrom(AParams);
      CellId := ParamsObj.AsInt64[0];
      CellIsDone := ParamsObj.AsBoolean[1];
    finally
      FreeAndNil(ParamsObj);
    end;

    CellUnitFrame := THelpmate.GetCellUnitFrameByCellId(CellsScrollBox, CellId);

    CellUnitFrame.Cell.IsDone := CellIsDone;
    if CellMemoFrame.Cell.Id = CellId then
      CellMemoFrame.Cell.IsDone := CellUnitFrame.Cell.IsDone;

//    TFMXControlTools.EnableControls([
//      DeleteFolderButton,
//      CellMemo,
//      InsertCellButton,
//      UpdateCellButton,
//      DeleteCellButton,
//      SearchButton,
//      HomeButton
//    ], true);
  except
    on e: Exception do
    begin
      raise Exception.Create(Format('%s: %s', [METHOD, e.Message]));
    end;
  end;
end;

procedure TMainForm.InsertCell(const AParams: TParamsExt);
const
  METHOD = 'TMainForm.InsertCell';
var
  ParamsObj: TParamsExt;
  CellId: Int64;
  FolderId: Int64;
  CellTypeId: Integer;
  Cell: TCell;
begin
  try
    ParamsObj := TParamsExt.Create;
    try
      ParamsObj.CopyFrom(AParams);
      CellId := ParamsObj.AsInt64[0];
      FolderId := ParamsObj.AsInt64[1];
      CellTypeId := ParamsObj.AsInteger[2];
    finally
      FreeAndNil(ParamsObj);
    end;

    Cell := TCell.Create(CellId, FolderId, CellTypeId);
    try
      CreateCellUnitFrame(Cell);
    finally
      FreeAndNil(Cell);
    end;

    SetCellMemoFrameNullId;

    CellMemoFrame.Cell.Id := CellId;
    CellMemoFrame.CellUnitFrame := THelpmate.GetCellUnitFrameByCellId(CellsScrollBox, CellId);

    THelpmate.SetMemoCellDefaultSettings(CellMemo);

    TFMXControlTools.EnableControls([
      CellMemo,
      InsertCellButton,
      UpdateCellButton,
      DeleteCellButton,
      CellRemindButton,
      SearchButton,
      HomeButton
    ], true);

    CellMemo.SetFocus;

//    FEventsManager.StoreEvents;
  except
    on e: Exception do
    begin
      raise Exception.Create(Format('%s: %s', [METHOD, e.Message]));
    end;
  end;
end;

procedure TMainForm.DeleteCell(const AParams: TParamsExt);
const
  METHOD = 'TMainForm.DeleteCell';
var
  ParamsObj: TParamsExt;
  CellId: Int64;
  Control: TControl;
  CellUnitFrame: TCellUnitFrame;
begin
  try
    ParamsObj := TParamsExt.Create;
    try
      ParamsObj.CopyFrom(AParams);
      CellId := ParamsObj.AsInt64[0];
    finally
      FreeAndNil(ParamsObj);
    end;

    SetCellMemoFrameNullId;

    for Control in CellsScrollBox.Content.Controls do
    begin
      if Control is TCellUnitFrame then
      begin
        CellUnitFrame := TCellUnitFrame(Control);
        if CellUnitFrame.Cell.Id = CellId then
        begin
          FEventsManager.DeleteByControl(CellUnitFrame.CellUnitButton);

          CellsScrollBox.Content.RemoveObject(CellUnitFrame);
          FreeAndNil(CellUnitFrame);

          Break;
        end;
      end;
    end;

    TFMXControlTools.EnableControls([
      InsertCellButton,
      SearchButton,
      HomeButton
    ], true);

    TOnClickReplacer.Restore;
    // Сисок эвентов после удаления через окно ремайнреда будет пуст
    FEventsManager.ReStoreEvents;

    RestartReminder;
  except
    on e: Exception do
    begin
      raise Exception.Create(Format('%s: %s', [METHOD, e.Message]));
    end;
  end;
end;

procedure TMainForm.UpdateFolder(const AParams: TParamsExt);
const
  METHOD = 'TMainForm.UpdateFolder';
var
  ParamsObj: TParamsExt;
  FolderId: Int64;
  FolderName: String;
  FolderPath: String;
begin
  try
    ParamsObj := TParamsExt.Create;
    try
      ParamsObj.CopyFrom(AParams);
      FolderId := ParamsObj.AsInt64[0];
      FolderName := ParamsObj.AsString[1];
      FolderPath := ParamsObj.AsString[2];
    finally
      FreeAndNil(ParamsObj);
    end;

    if CurrentFolderFrame.Cell.Id = FolderId then
    begin
      CurrentFolderFrame.Cell.Name := FolderName;
      CurrentFolderFrame.FolderNameText.Text := FolderPath;
    end;

    TFMXControlTools.EnableControls([
      InsertFolderButton,
      RenameFolderButton,
      DeleteFolderButton
    ], true);
  except
    on e: Exception do
    begin
      raise Exception.Create(Format('%s: %s', [METHOD, e.Message]));
    end;
  end;
end;

procedure TMainForm.InsertFolder(const AParams: TParamsExt);
const
  METHOD = 'TMainForm.InsertFolder';
var
  ParamsObj: TParamsExt;
  Cell: TCell;
  CellId: Int64;
  CellFolderId: Int64;
  CellCellTypeId: Integer;
  CellName: String;
begin
  try
    ParamsObj := TParamsExt.Create;
    try
      ParamsObj.CopyFrom(AParams);

      CellId := ParamsObj.AsInt64[0];
      CellFolderId := ParamsObj.AsInt64[1];
      CellCellTypeId := ParamsObj.AsInteger[2];
      CellName := ParamsObj.AsString[3];
    finally
      FreeAndNil(ParamsObj);
    end;

    Cell := TCell.Create;
    try
      Cell.Id := CellId;
      Cell.FolderId := CellFolderId;
      Cell.CellTypeId := CellCellTypeId;
      Cell.Name := CellName;

      CreateFolderUnitFrame(Cell, FoldersScrollBox, FolderUnitFrameClickHandler);
    finally
      FreeAndNil(Cell);
    end;

    TFMXControlTools.EnableControls([
      InsertFolderButton,
      RenameFolderButton,
      DeleteFolderButton
    ], true);
  except
    on e: Exception do
    begin
      raise Exception.Create(Format('%s: %s', [METHOD, e.Message]));
    end;
  end;
end;

procedure TMainForm.DeleteFolderError(const AParams: TParamsExt);
const
  METHOD = 'TMainForm.DeleteFolderError';
var
  ResultCode: TDBAResultCode;
  ParamsObj: TParamsExt;
begin
  try
    ParamsObj := TParamsExt.Create;
    try
      ParamsObj.CopyFrom(AParams);
      ResultCode := TDBAResultCode(ParamsObj.AsByte[0]);
    finally
      FreeAndNil(ParamsObj);
    end;

    if ResultCode = TDBAResultCode.rcFolderIsNotEmpty then
    begin
      raise Exception.Create('The folder is not empty');
    end;

    TFMXControlTools.EnableControls([
      InsertFolderButton,
      RenameFolderButton,
      DeleteFolderButton,
      SearchButton,
      HomeButton
    ], true);
  except
    on e: Exception do
    begin
      raise Exception.Create(Format('%s: %s', [METHOD, e.Message]));
    end;
  end;
end;

procedure TMainForm.SearchResult(const AParams: TParamsExt);
const
  METHOD = 'TMainForm.SearchResult';
var
  OuterCellList: TCellList;
  FolderList: TCellList;
  List: TInnerCellList;
  Cell: TCell;
  ParamsObj: TParamsExt;
begin
  SetCellMemoFrameNullId;

  try
    FolderList := TCellList.Create;
    try
      ParamsObj := TParamsExt.Create;
      try
        ParamsObj.CopyFrom(AParams);

        OuterCellList := ParamsObj.AsPointer[0];
        FolderList.CopyFrom(OuterCellList);
      finally
        FreeAndNil(ParamsObj);
      end;

      ClearScrollBox(FoldersScrollBox);
      ClearScrollBox(CellsScrollBox);

      List := FolderList.LockList;
      try
        for Cell in List do
        begin
          if Cell.CellTypeId = TCellType.ctFolder then
          begin
            CreateFolderUnitFrame(Cell, FoldersScrollBox, SearchResultFolderUnitFrameClickHandler);
          end
        end;
      finally
        FolderList.UnlockList;
      end;
    finally
      FreeAndNil(FolderList);
    end;

    TFMXControlTools.EnableControls([
      CellMemo,
      UpdateCellButton,
      DeleteCellButton,
      CellRemindButton
    ], false);

    TFMXControlTools.EnableControls([
      InsertFolderButton,
      RenameFolderButton,
      DeleteFolderButton
//      InsertCellButton
//      SearchButton,
//      HomeButton
    ], true);

    DeleteFolderButton.Enabled := true;
    if CurrentFolderFrame.Cell.Id = ROOT_FOLDER_ID then
      DeleteFolderButton.Enabled := false;
  except
    on e: Exception do
    begin
      raise Exception.Create(Format('%s: %s', [METHOD, e.Message]));
    end;
  end;
end;

procedure TMainForm.CellsSearchResult(const AParams: TParamsExt);
const
  METHOD = 'TMainForm.CellsSearchResult';
var
  OuterCellList: TCellList;
  CellList: TCellList;
  List: TInnerCellList;
  Cell: TCell;
  ParamsObj: TParamsExt;
begin
  SetCellMemoFrameNullId;

  try
    CellList := TCellList.Create;
    try
      ParamsObj := TParamsExt.Create;
      try
        ParamsObj.CopyFrom(AParams);

        OuterCellList := ParamsObj.AsPointer[0];
        CellList.CopyFrom(OuterCellList);
      finally
        FreeAndNil(ParamsObj);
      end;

      ClearScrollBox(CellsScrollBox);

      List := CellList.LockList;
      try
        for Cell in List do
        begin
          if Cell.CellTypeId = TCellType.ctCell then
          begin
            CreateCellUnitFrame(Cell);
          end;
        end;
      finally
        CellList.UnlockList;
      end;
    finally
      FreeAndNil(CellList);
    end;

    TFMXControlTools.EnableControls([
      CellMemo,
      UpdateCellButton,
      DeleteCellButton,
      CellRemindButton
    ], false);

    TFMXControlTools.EnableControls([
      InsertFolderButton,
      RenameFolderButton,
      DeleteFolderButton
//      InsertCellButton
    ], true);

    DeleteFolderButton.Enabled := true;
    if CurrentFolderFrame.Cell.Id = ROOT_FOLDER_ID then
      DeleteFolderButton.Enabled := false;
  except
    on e: Exception do
    begin
      raise Exception.Create(Format('%s: %s', [METHOD, e.Message]));
    end;
  end;
end;

procedure TMainForm.ShowCellReminderForm(const AParams: TParamsExt);
var
  Cell: TCell;
  CellTemp: TCell;
  ModalResult: TModalResult;
begin
  Cell := TCell.Create;
  try
    CellTemp := TCell(AParams.AsPointer[0]);
    //    if CellMemoFrame.Cell.Id = CellTemp.Id then
    //      Exit;

    Cell.CopyFrom(CellTemp);
    ModalResult := TCellReminderForm.Show(Cell);
    if CellMemoFrame.Cell.Id = Cell.Id then
    begin
      CellMemoFrame.Cell.RemindDateTime := Cell.RemindDateTime;
      CellMemoFrame.Cell.Remind := Cell.Remind;
    end;
    case ModalResult of
      mrContinue{Goto}:
      begin
        Cell.Remind := false;
        UpdateCellReminder(Cell);

        if CellMemoFrame.CellMemoTextIsChanged then
        begin
          if mrYes = TNoteForm.Show(TNoteIdentConst.SaveCell) then
          begin
            DoUpdateCell(TShowStatusExt.ShowCellUpdated);
          end;
        end;

        GotoFolder(Cell.FolderId, Cell.Id);
      end;
      mrRetry{Ok(Reschedule)}:
      begin
        UpdateCellReminder(Cell);
      end;
      mrAbort{Delete}:
      begin
        if Cell.Id = AppManager.Settings.CurrentCellId then
        begin
          DoDeleteCell(Cell.Id, True);
        end
        else
        begin
          DoDeleteCell(Cell.Id, False);
        end;
      end;
      mrCancel{Cancel, Close}:
      begin
        UpdateCellReminder(Cell);
      end;
    end;
  finally
    FreeAndNil(Cell);
  end;
end;

procedure TMainForm.BackupDone(const AParams: TParamsExt);
var
  SearchRecList: TSearchRecList;
  BackupsPath: String;
  DBFileName: String;
begin
  // Находим самый ранний файл резервной копии и удаляем его
  // Храним в бэкапе не более 5 файлов
  SearchRecList := TSearchRecList.Create;
  try
    BackupsPath := AppManager.Settings.BackupsPath;
    TFileTools.GetFileSearchRecListByDir(BackupsPath, SearchRecList);
    SearchRecList.Sort(
      TComparer<TSearchRec>.Construct(
        function(const Left, Right: TSearchRec): Integer
        begin
          if Left.TimeStamp < Right.TimeStamp then
            Result := -1
          else
          if Left.TimeStamp > Right.TimeStamp then
            Result := 1
          else
            Result := 0;
        end
      )
    );

    if SearchRecList.Count > 5 then
    begin
      DBFileName := BackupsPath + '\' + SearchRecList[0].Name;
      if Pos(DB_FILE_NAME, DBFileName) > 0 then
        System.SysUtils.DeleteFile(DBFileName);
    end;
  finally
    FreeAndNil(SearchRecList);
  end;

  AppManager.Settings.LastBackupDateTime := Now;
  AppManager.Settings.SaveApplicationSettings;
  RunBackupStarter;

  TFMXControlTools.EnableControls([
    DeleteCellButton,
    InsertCellButton,
    UpdateCellButton,
    DeleteCellButton,
    CellRemindButton,
    SearchButton,
    HomeButton
  ], false);
end;

procedure TMainForm.StartBackup(const AParams: TParamsExt);
var
  DBFullName: String;
begin
  TFMXControlTools.EnableControls([
    DeleteCellButton,
    InsertCellButton,
    UpdateCellButton,
    DeleteCellButton,
    CellRemindButton,
    SearchButton,
    HomeButton
  ], false);

  DBFullName := AppManager.Settings.BackupsPath + '\' + THelpmate.DateTimeToFileNameString('_') + '_' + DB_FILE_NAME;

  AppManager.CreateBackupThread(Self, DBFullName, BackupDone);
end;

procedure TMainForm.RunBackupStarter;
begin
  AppManager.CreateBackupStarterThread(
    Self,
    AppManager.Settings.LastBackupDateTime,
    StartBackup);
end;

procedure TMainForm.DoDeleteCell(
  const ACellId: Int64;
  const ALockInterface: Boolean);
var
  CellId: Int64 absolute ACellId;
begin
  if TNoteForm.Show(TNoteIdentConst.DeleteCell) <> mrYes then
    Exit;

//  SetCellMemoFrameNullId;

  if ALockInterface then
  begin
    FEventsManager.StoreEvents;

    TFMXControlTools.EnableControls([
      CellMemo,
      InsertCellButton,
      UpdateCellButton,
      CellRemindButton,
      DeleteCellButton,
      SearchButton,
      HomeButton
    ], false);
  end;

  AppManager.CreateDeleteCellThread(Self, CellId, DeleteCell);
end;

procedure TMainForm.DeleteFolderButtonClick(Sender: TObject);
var
  FolderId: Int64;
  ParentFolderId: Int64;
begin
  TFMXControlTools.EnableControls([
    InsertFolderButton,
    RenameFolderButton,
    DeleteFolderButton,
    SearchButton,
    HomeButton
  ], false);

  FolderId := CurrentFolderFrame.Cell.Id;
  ParentFolderId := CurrentFolderFrame.Cell.FolderId;

  if FolderId = 1 then
    raise Exception.Create('Can''t delete root folder');

  AppManager.CreateDeleteFolderThread(
    Self,
    FolderId,
    ParentFolderId,
    BuildFolderCatalog,
    DeleteFolderError);
end;

procedure TMainForm.UpdateCellButtonClick(Sender: TObject);
begin
  TFMXControlTools.EnableControls([
    InsertCellButton,
    UpdateCellButton,
    DeleteCellButton,
    CellRemindButton,
    SearchButton,
    HomeButton
  ], false);

  DoUpdateCell(UpdateCell);
end;

procedure TMainForm.FormCreate(Sender: TObject);
const
  METHOD = 'TMainForm.FormCreate';
var
  SCALE_VALUE: Byte;
  NoteIdentsFileName: String;
  DBFileName: String;
  DBDirName: String;
  DBBackupDirName: String;
  SQLTemplatesDirName: String;
begin
  ReportMemoryLeaksOnShutdown := true;

  try
    TLogger.Init('AppLog', 1000, true, true);
    TLogger.AddLog('Start app', MG);

    SettingsFrame := nil;

    StatusLabel.Text := '';
    StatusLabel.Visible := false;
    TShowStatusExt.Init(StatusLabel, 2000);

    AppPath := ExtractFilePath(ParamStr(0));

    VersionLabel.Text := Concat(VersionLabel.Text, ' ', VERSION);

    FFoldersMinWidth := 150;
    FFoldersMaxWidth := 250;

    FCellsMinWidth := CellsSplitter.MinSize;
    FCellsMaxWidth := 500;

    FCellMinWidth := CellsSplitter.MinSize;
  //  FCellMaxWidth := Round(Width * 0.6);  // Задается в MainForm.OnResize

    SCALE_VALUE := 1;
    FBorderFrame :=
      TBorderFrame.Create(
        Self,
        loContent,
        'Memory cells',
        Round(loScreen.Width * SCALE_VALUE) + 50,
        Round(loScreen.Height * SCALE_VALUE) + 10,
        $FF2A001A,
        $FF2A001A,
        $FF4C002F,
        $FF9B0060);
    FBorderFrame.TrayIconMouseRightButtonDown := TrayIconMouseRightButtonDown;

    FTrayPopupMenu := TCraftPopupMenu.Create('>>', 1000);
    FTrayPopupMenu.MenuItems.AddItem('Close', 'Close', true, CloseApp);
    FTrayPopupMenu.BuildMenu;

    FEventsManager := TEventsManager.Create(Self);

    FCurrentFolderFrame := TCurrentFolderFrame.Create(Self);
    FCurrentFolderFrame.Parent := FolderNameLayout;
    FCurrentFolderFrame.Align := TAlignLayout.Contents;
    FCurrentFolderFrame.Panel.StyleLookup := 'CurrentFolderPanelstyle';
    FCurrentFolderFrame.FolderNameText.TextSettings.FontColor := $FFBCBCBC;
    FCurrentFolderFrame.FolderNameText.TextSettings.Font.Size := 18;
    FCurrentFolderFrame.Panel.OnClick := CurrentFolderUnitFrameClickHandler;

    FCellMemoFrame := TCellMemoFrame.Create(Self);
    FCellMemoFrame.Parent := CellMemoLayout;
    FCellMemoFrame.Align := TAlignLayout.Client;
    FCellMemoFrame.CellMemo.StyleLookup := 'Memostyle';
    FCellMemoFrame.OnCellMemoChangeTracking := CellMemoChangeTrackingHandler;

    NoteIdentsFileName := AppPath + 'Langs\ru\NoteIdents.xml';
    if not FileExists(NoteIdentsFileName) then
      raise Exception.CreateFmt('File "%s" not found', [NoteIdentsFileName]);

    TTheme.BackgroundColor := InfoRectangle.Fill.Color;
    TTheme.DarkBackgroundColor := InfoRectangle.Fill.Color;
    TTheme.LightBackgroundColor := Self.Fill.Color;
    TTheme.MemoColor := Self.Fill.Color;
    TTheme.TextColor := FCurrentFolderFrame.FolderNameText.TextSettings.FontColor;
    TTheme.TextFontSize := FCurrentFolderFrame.FolderNameText.TextSettings.Font.Size;
    TTheme.SaveStyleBook(StyleBook);
//    LoadStyleBook(StyleBook);

    TNoteForm.Init(NoteIdentsFileName);
//    TNoteForm.Theme.BackgroundColor := InfoRectangle.Fill.Color;
//    TNoteForm.Theme.MemoColor := Self.Fill.Color;
//    TNoteForm.Theme.TextColor := FCurrentFolderFrame.FolderNameText.TextSettings.FontColor;
//    TNoteForm.Theme.TextFontSize := FCurrentFolderFrame.FolderNameText.TextSettings.Font.Size;

    //C:\Desktop\MemoryCells\MemoryCellsCommon\SQLTemplates\

    SQLTemplatesDirName := SQL_TEMPLATES_DEBUG_PATH;
    if not DirectoryExists(SQLTemplatesDirName) then
    begin
      SQLTemplatesDirName := AppManager.AppPath + SQL_TEMPLATES_PATH;
      if not DirectoryExists(SQLTemplatesDirName) then
        raise Exception.CreateFmt('Directory "%s" not found', [SQLTemplatesDirName]);
    end;

    DBDirName := DB_DEBUG_PATH;
    if not DirectoryExists(DBDirName) then
    begin
      DBDirName := AppManager.AppPath + DB_PATH;
      if not DirectoryExists(DBDirName) then
        raise Exception.CreateFmt('Directory "%s" not found', [DBDirName]);
    end;
    DBFileName := DBDirName + DB_FILE_NAME;
    if not FileExists(DBFileName) then
      raise Exception.CreateFmt('File "%s" not found', [DBFileName]);

    DBBackupDirName := AppManager.Settings.BackupsPath;
    if not DirectoryExists(DBBackupDirName) then
      raise Exception.CreateFmt('Directory "%s" not found', [DBBackupDirName]);

    AppManager.InitDBAccess(DBFileName, SQLTemplatesDirName);
    UTClientManager := TUTClientManager.Create;

  //  AppManager.Settings.LoadApplicationSettings;
    Height := AppManager.Settings.MainFormHeight;
    Width := AppManager.Settings.MainFormWidth;
    Top := AppManager.Settings.MainFormTop;
    Left := AppManager.Settings.MainFormLeft;

    CellLayout.Width := AppManager.Settings.CellLayoutWidth;
    CellsLayout.Width := AppManager.Settings.CellsLayoutWidth;

    OnlineModeCheckBox.IsChecked := AppManager.Settings.OnlineMode.ToBoolean;

    // Установка клавишного хука
    if not FileExists(KEY_HOOK_FILE_NAME) then
      raise Exception.CreateFmt('File "%s" not found', [KEY_HOOK_FILE_NAME]);

    HookSwitchProc := nil;
    KeyHookHandle := 0;

    @HookSwitchProc := nil;
    KeyHookHandle  := LoadLibrary(PChar(KEY_HOOK_FILE_NAME));
    @HookSwitchProc := GetProcAddress(KeyHookHandle, 'Hook');
    if @HookSwitchProc <> nil then
      HookSwitchProc(true)
    else
      raise Exception.Create('Fatal error. Can`t load keydoard hook dll');

    AppManager.CreateKeyCatcherThread(Self, 'MemoryCellsMemoryFile');

    RunBackupStarter;

    if AppManager.Settings.IsFavoriteCellsShowing = 0 then
    begin
      ShowFoldersLayout(AppManager.Settings.IsFoldersLayoutShowing = 1);

      GotoFolder(AppManager.Settings.CurrentFolderId, AppManager.Settings.CurrentCellId);
    end
    else
    if AppManager.Settings.IsFavoriteCellsShowing = 1 then
    begin
      ShowFavoriteCells(true);
    end;

    RestartReminder;
  except
    on e: Exception do
      RaiseAppException(METHOD, e);
  end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  if Assigned(@HookSwitchProc) then
    HookSwitchProc(false);
  if KeyHookHandle > 0 then
    FreeLibrary(KeyHookHandle);

  if Assigned(FTrayPopupMenu) then
    FreeAndNil(FTrayPopupMenu);

  AppManager.Settings.MainFormHeight := Height;
  AppManager.Settings.MainFormWidth := Width;
  AppManager.Settings.MainFormTop := Top;
  AppManager.Settings.MainFormLeft := Left;

  AppManager.Settings.CellLayoutWidth := Round(CellLayout.Width);
  AppManager.Settings.CellsLayoutWidth := Round(CellsLayout.Width);

  AppManager.Settings.SaveApplicationSettings;

  FreeAndNil(FEventsManager);
  FreeAndNil(UTClientManager);

  TNoteForm.UnInit;

  TLogger.AddLog('Finish app', MG);
  TLogger.UnInit;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  if FoldersLayout.Visible then
    FCellMaxWidth := Round(Width * 0.6)
  else
    FCellMaxWidth := Round(Width * 0.9);

  CellLayout.RecalcSize;
end;

procedure TMainForm.CheckControls;
begin
  if Assigned(EditFolderNameFrame) then
    RenameFolderButton.Enabled := false
  else
    RenameFolderButton.Enabled := true
end;

procedure TMainForm.PingUTClientOnConnectedHandler(Sender: TObject);
var
  DataClient: TUTClient;
begin
  OnlineStateCircle.Fill.Color := ONLINE_STATE_COLOR;

  DataClient := UTClientManager.CreateDataClient('', '192.168.0.190', 1081);
  DataClient.OnRead := ClientOnReadHandler;
  DataClient.Connect;
end;

procedure TMainForm.PingUTClientOnDisconnectedHandler(Sender: TObject);
begin
  OnlineStateCircle.Fill.Color := OFFLINE_STATE_COLOR;
end;

procedure TMainForm.PingUTClientOnAuthorizedHandler(Sender: TObject);
begin
end;

procedure TMainForm.PingUTClientOnPingTimeoutHandler(const AObject: Pointer);
begin
  raise Exception.Create('Ping timeout');
end;

procedure TMainForm.ClientOnReadHandler(const ATransportContainer: TTransportContainer);
const
  METHOD = 'TMainForm.ClientOnReadHandler';
var
  TC: TTransportContainer absolute ATransportContainer;
  CatalogParams: TParamsExt;
  CellParams: TParamsExt;
  ServerReply: TUTServerReply;
  CellId: Int64;
begin
  try
    CatalogParams := TParamsExt.Create;
    CellParams := TParamsExt.Create;
    try
      TC.SetZeroPosition;
      ServerReply := TUTServerReply(TC.ReadAsInteger);
      case ServerReply of
        TUTServerReply.srLoadCatalog:
        begin
          TServerRepliesParser.LoadCatalog(TC, CatalogParams, CellParams);
          BuildFolderCatalog(CatalogParams);
          CellId := CellParams.AsInt64[0];
          if CellId > 0 then
            OpenCell(CellParams);
        end;
      end;
    finally
      FreeAndNil(CatalogParams);
      FreeAndNil(CellParams);
    end;
  except
    on e: Exception do
      RaiseAppException(METHOD, e);
  end;
end;

procedure TMainForm.TrayIconMouseRightButtonDown(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  MousePoint: TPoint;
begin
  GetCursorPos(MousePoint);
  if FTrayPopupMenu <> nil then
    FTrayPopupMenu.Open(MousePoint.X, MousePoint.Y);
end;

procedure TMainForm.UTClientOnExceptionHandler(const AErrorCode: TUTCErrorCode; const AExceptionMessage: String);
begin
  OnlineStateCircle.Fill.Color := OFFLINE_STATE_COLOR;

  raise Exception.Create(AExceptionMessage);
end;

procedure TMainForm.StartOnline;
var
  PingClient: TUTClient;
begin
  AppManager.Settings.OnlineMode := omTrue;
  PingClient := UTClientManager.CreatePingClient('', '192.168.0.190', 1081);
  PingClient.OnConnected := PingUTClientOnConnectedHandler;
  PingClient.OnDisconnected := PingUTClientOnDisconnectedHandler;
  PingClient.OnAuthorized := PingUTClientOnAuthorizedHandler;
  PingClient.OnPingTimeout := PingUTClientOnPingTimeoutHandler;
  PingClient.OnException := UTClientOnExceptionHandler;
  PingClient.Connect;
end;

procedure TMainForm.StopOnline;
begin
  AppManager.Settings.OnlineMode := omFalse;
  UTClientManager.FreeAllClients;
end;

procedure TMainForm.RaiseAppException(const AMethod: String; const AE: Exception);
var
  ExceptionMessage: String;
begin
  ExceptionMessage := AE.Message;

  TLogger.AddLog(ExceptionMessage, ER);

  TThread.ForceQueue(nil,
    procedure
    begin
      TNoteForm.ShowOk('Error', ExceptionMessage);
      // ShowMessage(ExceptionMessage);
    end);
end;

//procedure TMainForm.StoreEvents;
//begin
//  if FEventRecordList.Count = 0 then
//  begin
//    THelpmate.ScrollBoxControls(CellsScrollBox,
//      procedure (const AControl: TControl)
//      var
//        CellUnitButton: TButton;
//      begin
//        CellUnitButton := TCellUnitFrame(AControl).CellUnitButton;
//        FEventRecordList.Add(CellUnitButton, CellUnitButton.OnClick, EVENT_ONCLICK);
//        CellUnitButton.OnClick := nil;
//      end);
//
//    THelpmate.ScrollBoxControls(FoldersScrollBox,
//      procedure (const AControl: TControl)
//      var
//        FolderUnitButton: TButton;
//      begin
//        FolderUnitButton := TFolderUnitFrame(AControl).FolderUnitButton;
//        FEventRecordList.Add(FolderUnitButton, FolderUnitButton.OnClick, EVENT_ONCLICK);
//        FolderUnitButton.OnClick := nil;
//      end);
//
//    FEventRecordList.Add(CurrentFolderFrame.Panel, CurrentFolderFrame.Panel.OnClick, EVENT_ONCLICK);
//    CurrentFolderFrame.Panel.OnClick := nil;
//  end;
//end;

//procedure TMainForm.ReStoreEvents;
//begin
//  THelpmate.ScrollBoxControls(CellsScrollBox,
//    procedure (const AControl: TControl)
//    var
//      CellUnitButton: TButton;
//    begin
//      CellUnitButton := TCellUnitFrame(AControl).CellUnitButton;
//      CellUnitButton.OnClick := FEventRecordList.GetByIdent(CellUnitButton, EVENT_ONCLICK);
//    end);
//
//  THelpmate.ScrollBoxControls(FoldersScrollBox,
//    procedure (const AControl: TControl)
//    var
//      FolderUnitButton: TButton;
//    begin
//      FolderUnitButton := TFolderUnitFrame(AControl).FolderUnitButton;
//      FolderUnitButton.OnClick := FEventRecordList.GetByIdent(FolderUnitButton, EVENT_ONCLICK);
//    end);
//
//  CurrentFolderFrame.Panel.OnClick := FEventRecordList.GetByIdent(CurrentFolderFrame.Panel, EVENT_ONCLICK);
//end;

procedure TMainForm.CreateHandle;
var
  AppIcon: TIcon;
begin
  inherited;

  AppIcon := TIcon.Create;
  AppManager.AppIcon := AppIcon;
  { TODO : Грузить иконку из файла с ресурсами }
  AppIcon.LoadFromFile('C:\Desktop\MemoryCellsPerository\MemoryCells\Styles\Logo32.ico');

  SendMessage(ApplicationHWND, WM_SETICON, 1, AppIcon.Handle);
  SendMessage(WindowHandleToPlatform(Handle).Wnd, WM_SETICON, 1, AppIcon.Handle);
end;

procedure TMainForm.DestroyHandle;
begin
  if Assigned(AppManager.AppIcon) then
    FreeAndNil(AppManager.AppIcon);

  inherited;
end;

constructor TEventsManager.Create(const AMainForm: TMainForm);
begin
  FMainForm := AMainForm;
  FEventRecordList := TEventRecordList.Create;
end;

destructor TEventsManager.Destroy;
begin
  FreeAndNil(FEventRecordList);

  inherited;
end;

procedure TEventsManager.StoreEvents;
begin
  if FEventRecordList.Count = 0 then
  begin
    THelpmate.ScrollBoxControls(FMainForm.CellsScrollBox,
      procedure (const AControl: TControl)
      var
        CellUnitButton: TButton;
      begin
        CellUnitButton := TCellUnitFrame(AControl).CellUnitButton;
        FEventRecordList.Add(CellUnitButton, CellUnitButton.OnClick, EVENT_ONCLICK);
        CellUnitButton.OnClick := nil;
      end);

    THelpmate.ScrollBoxControls(FMainForm.FoldersScrollBox,
      procedure (const AControl: TControl)
      var
        FolderUnitButton: TButton;
      begin
        FolderUnitButton := TFolderUnitFrame(AControl).FolderUnitButton;
        FEventRecordList.Add(FolderUnitButton, FolderUnitButton.OnClick, EVENT_ONCLICK);
        FolderUnitButton.OnClick := nil;
      end);

    FEventRecordList.Add(
      FMainForm.CurrentFolderFrame.Panel, FMainForm.CurrentFolderFrame.Panel.OnClick, EVENT_ONCLICK);
    FMainForm.CurrentFolderFrame.Panel.OnClick := nil;
  end;
end;

procedure TEventsManager.ReStoreEvents;
var
  EventRecord: TEventRecord;
  i: Integer;
begin
  if FEventRecordList.ContainsControl(FMainForm.CurrentFolderFrame.Panel) then
    FMainForm.CurrentFolderFrame.Panel.OnClick :=
      FEventRecordList.GetByIdent(FMainForm.CurrentFolderFrame.Panel, EVENT_ONCLICK);

  i := FEventRecordList.Count;
  while i > 0 do
  begin
    Dec(i);

    EventRecord := FEventRecordList[i];

    EventRecord.Control.OnClick := EventRecord.Event;

    FEventRecordList.Delete(i);
  end;

//  THelpmate.ScrollBoxControls(FMainForm.CellsScrollBox,
//    procedure (const AControl: TControl)
//    var
//      CellUnitButton: TButton;
//    begin
//      CellUnitButton := TCellUnitFrame(AControl).CellUnitButton;
//      CellUnitButton.OnClick := FEventRecordList.GetByIdent(CellUnitButton, EVENT_ONCLICK);
//    end);
//
//  THelpmate.ScrollBoxControls(FMainForm.FoldersScrollBox,
//    procedure (const AControl: TControl)
//    var
//      FolderUnitButton: TButton;
//    begin
//      FolderUnitButton := TFolderUnitFrame(AControl).FolderUnitButton;
//      FolderUnitButton.OnClick := FEventRecordList.GetByIdent(FolderUnitButton, EVENT_ONCLICK);
//    end);
end;

procedure TEventsManager.DeleteByControl(const AControl: TControl);
begin
  FEventRecordList.DeleteByControl(AControl);
end;

initialization
  AppManager := TAppManager.Create;

finalization
  FreeAndNil(AppManager);

end.
