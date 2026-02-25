unit CellReminderFormUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Memo.Types, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo,
  CellUnit, FMX.StdCtrls, FMX.Objects
  , CellReminderDateTimeFrameUnit
  , FMX.FormExtUnit
  , FMX.Theme
  ;

type
  TCellReminderForm = class(TFormExt)
    CellMemoLayout: TLayout;
    CellMemo: TMemo;
    ControlButtonsLayout: TLayout;
    CancelButton: TButton;
    GotoButton: TButton;
    DeleteButton: TButton;
    loContent: TLayout;
    loScreen: TLayout;
    StyleBook: TStyleBook;
    CellRemindButton: TButton;
    ControlButtonsBackgroundRectangle: TRectangle;
    procedure CellMemoApplyStyleLookup(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure DeleteButtonClick(Sender: TObject);
    procedure GotoButtonClick(Sender: TObject);
    procedure CellRemindButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);  strict private
    FCell: TCell;
    FCellReminderDateTimeFrame: TCellReminderDateTimeFrame;

    procedure CellReminderOkButtonClickHandler(Sender: TObject);
    procedure Cancel;
    procedure Repaint;
  strict private
    FTheme: TTheme;

    class var FThemeOfClass: TTheme;

//    property Theme: TTheme read FTheme write FTheme;

    procedure OnDateTimeChangedHandler(Sender: TObject);
    procedure OnRemindChangedHandler(Sender: TObject);
  private
    class property ThemeOfClass: TTheme read FThemeOfClass write FThemeOfClass;
    property CellReminderDateTimeFrame: TCellReminderDateTimeFrame read FCellReminderDateTimeFrame;
  public
    constructor Create(
      AOwner: TComponent;
      const ACell: TCell;
      const ATheme: TTheme = nil); reintroduce; overload;
    destructor Destroy; override;

    class function Show(
      const ACell: TCell;
      var AOpenCellReminderPanel: Boolean): TModalResult;

    class procedure Init(const ATheme: TTheme);
    class procedure UnInit;
  end;

var
  CellReminderForm: TCellReminderForm;

implementation

{$R *.fmx}

uses
    System.DateUtils
  , Winapi.Windows
  , BorderFrameUnit
  , DBAccessUnit
  , FMX.OnClickReplacerUnit
  , FMX.ShowNoteFormUnit
  , FMX.Platform.Win
  , CommonUnit
  ;

{ TCellReminderForm }

procedure TCellReminderForm.DeleteButtonClick(Sender: TObject);
begin
  ModalResult := mrAbort;
end;

procedure TCellReminderForm.CancelButtonClick(Sender: TObject);
begin
  Cancel;
end;

procedure TCellReminderForm.CellMemoApplyStyleLookup(Sender: TObject);
var
  FmxObject: TFmxObject;
  Rectangle: TRectangle;
begin
  FmxObject := CellMemo.FindStyleResource('CellMemoBackground');
  if Assigned(FmxObject) then
  begin
    if FmxObject is TRectangle then
    begin
      Rectangle := TRectangle(FmxObject);
      Rectangle.Fill.Color := FTheme.MemoColor;
    end;
  end;
end;

procedure TCellReminderForm.CellRemindButtonClick(Sender: TObject);
begin
  if not Assigned(FCellReminderDateTimeFrame) then
  begin
    CellRemindButton.StyleLookup := 'BellOnButtonStyle';

    FCellReminderDateTimeFrame :=
      TCellReminderDateTimeFrame.ShowCellReminderFrame(
        CellMemoLayout,
        FCell);

    FCellReminderDateTimeFrame.OnDateTimeChanged := OnDateTimeChangedHandler;
    FCellReminderDateTimeFrame.OnRemindChanged := OnRemindChangedHandler;

    FCellReminderDateTimeFrame.OkButton.OnClick := CellReminderOkButtonClickHandler;
  end
  else
  begin
    CellRemindButton.StyleLookup := 'BellOffButtonStyle';

    FCellReminderDateTimeFrame.HideCellReminderFrame(FCellReminderDateTimeFrame);
  end;

  Repaint;
end;

procedure TCellReminderForm.OnDateTimeChangedHandler(Sender: TObject);
var
  DD, MM, YY: Word;
  Hour, Min: Word;
  DateTime: TDateTime;
begin
  DD := FCellReminderDateTimeFrame.DayEdit.Text.ToInteger;
  MM := FCellReminderDateTimeFrame.MonthEdit.Text.ToInteger;
  YY := FCellReminderDateTimeFrame.YearEdit.Text.ToInteger;
  Hour := FCellReminderDateTimeFrame.HourEdit.Text.ToInteger;
  Min  := FCellReminderDateTimeFrame.MinuteEdit.Text.ToInteger;

  DateTime := EncodeDateTime(YY, MM, DD, Hour, Min, 00, 00);
  FCell.RemindDateTime := DateTime;
end;

procedure TCellReminderForm.OnRemindChangedHandler(Sender: TObject);
begin
  FCell.Remind := FCellReminderDateTimeFrame.RemindCheckBox.IsChecked;
end;

constructor TCellReminderForm.Create(
  AOwner: TComponent;
  const ACell: TCell;
  const ATheme: TTheme = nil);
const
  SCALE_VALUE = 1;
begin
  if not Assigned(ACell) then
    raise Exception.Create('The cell cannot be nil');

  inherited Create(AOwner);

  FTheme := TTheme.Create;

  if Assigned(ATheme) then
    FTheme.CopyFrom(ATheme);

  FTheme.SaveStyleBookTo(Self.StyleBook);

  FCell := ACell;
  FCellReminderDateTimeFrame := nil;

  CellMemo.Text := FCell.Content;

//  TBorderFrame.Create(
//    Self,
//    loContent,
//    'Reminder',
//    Trunc(loScreen.Width * SCALE_VALUE) + 50,
//    Trunc(loScreen.Height * SCALE_VALUE) + 10,
//    TAlphaColorRec.White,
//    $FF2A001A,
//    $FF4C002F,
//    $FF9B0060);

  BorderFrame.Kind := TBorderFrameKind.bfkNormal;
  BorderFrame.CaptionColor := $FFFFFFFF;
  BorderFrame.Color := $FF2A001A;
  BorderFrame.ToolButtonColor := BorderFrame.CaptionColor;
  BorderFrame.ToolButtonMouseOverColor := $FF9B0060;

  Self.Fill.Kind := TBrushKind.Solid;
  Self.Fill.Color := FTheme.LightBackgroundColor;

  Self.CellMemo.TextSettings.FontColor := FTheme.TextSettings.FontColor;
  Self.CellMemo.TextSettings.Font.Size := FTheme.TextSettings.Font.Size;
//  FTheme.TextFontSize;
//  Self.NoteMemo.TextSettings.Font.Family := 'MS Reference Sans Serif';
  Self.CellMemo.StyledSettings := [];

  Self.ControlButtonsBackgroundRectangle.Fill.Color := FTheme.DarkBackgroundColor;

  //  Self.CancelButton.StyleLookup := 'CancelButtonStyle';

  ModalResult := mrCancel;
end;

destructor TCellReminderForm.Destroy;
begin
  FreeAndNil(FTheme);

  inherited;
end;

procedure TCellReminderForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if ModalResult = mrCancel then
    FCell.Remind := false;

//  Action := TCloseAction.caFree;
end;

procedure TCellReminderForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
//  CanClose := true;
//
//  Self.OnCloseQuery := nil;
end;

procedure TCellReminderForm.GotoButtonClick(Sender: TObject);
begin
  ModalResult := mrContinue;
end;

procedure TCellReminderForm.CellReminderOkButtonClickHandler(Sender: TObject);
begin
  FCell.CopyFrom(FCellReminderDateTimeFrame.Cell);

  ModalResult := mrRetry;
end;

procedure TCellReminderForm.Cancel;
begin
  ModalResult := mrCancel;
end;

procedure TCellReminderForm.Repaint;
begin
  Self.PaintRects([Self.ClientRect]);
end;

class function TCellReminderForm.Show(
  const ACell: TCell;
  var AOpenCellReminderPanel: Boolean): TModalResult;
var
  CellReminderForm: TCellReminderForm;
  VisibleState: Boolean;
  OpenCellReminderPanel: Boolean;
begin
  CellReminderForm := TCellReminderForm.Create(nil, ACell, ThemeOfClass);

  try
    // Если приложение было свернуто в трэй, тогда необходимо его показать
    VisibleState := IsWindowVisible(ApplicationHwnd);
    if not VisibleState then
      ShowWindow(ApplicationHwnd, SW_SHOW);

    Result := CellReminderForm.ShowModal;

    OpenCellReminderPanel := Assigned(CellReminderForm.CellReminderDateTimeFrame);
    AOpenCellReminderPanel := OpenCellReminderPanel;

    // После принудительного показа, возвращаем приложение в исходное состояние
    if not VisibleState then
      ShowWindow(ApplicationHwnd, SW_HIDE);
  finally
    CellReminderForm.ReleaseForm;
  end;
end;

class procedure TCellReminderForm.Init(const ATheme: TTheme);
begin
  FThemeOfClass := TTheme.Create;

  FThemeOfClass.CopyFrom(ATheme);
end;

class procedure TCellReminderForm.UnInit;
begin
  if Assigned(FThemeOfClass) then
    FreeAndNil(FThemeOfClass);
end;

initialization
  TCellReminderForm.ThemeOfClass := nil;

end.
