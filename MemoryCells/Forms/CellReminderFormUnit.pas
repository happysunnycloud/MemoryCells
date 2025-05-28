unit CellReminderFormUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Memo.Types, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo,
  CellUnit, FMX.StdCtrls, FMX.Objects

  , BaseFormUnit
  , CellReminderDateTimeFrameUnit
  , FMX.ThemeUnit
  ;

type
  TCellReminderForm = class(TForm)
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
  private
    FTheme: TTheme;

    property Theme: TTheme read FTheme write FTheme;
  public
    constructor Create(
      AOwner: TComponent;
      const ACell: TCell); reintroduce; overload;
    destructor Destroy; override;

    class function Show(
      const ACell: TCell;
      const ATheme: TTheme = nil): TModalResult;
  end;

var
  CellReminderForm: TCellReminderForm;

implementation

{$R *.fmx}

uses
    Winapi.Windows
  , BorderFrameUnit
  , DBAccessUnit
  , FMX.OnClickReplacerUnit
  , FMX.ShowNoteFormUnit
  , FMX.Platform.Win
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
    CellRemindButton.StyleLookup := 'RemindButtonPressedStyle';

    FCellReminderDateTimeFrame :=
      TCellReminderDateTimeFrame.ShowCellReminderFrame(CellMemoLayout, FCell);

    FCellReminderDateTimeFrame.OkButton.OnClick := CellReminderOkButtonClickHandler;
  end
  else
  begin
    FCellReminderDateTimeFrame.HideCellReminderFrame(FCellReminderDateTimeFrame);
  end;

  Repaint;
end;

constructor TCellReminderForm.Create(
  AOwner: TComponent;
  const ACell: TCell);
const
  SCALE_VALUE = 1;
//var
//  BorderFrame: TBorderFrame;
begin
  FTheme := TTheme.Create;

  if not Assigned(ACell) then
    raise Exception.Create('The cell cannot be nil');

  inherited Create(AOwner);

//  FTheme.LoadStyleBook(Self.StyleBook);

  FCell := ACell;

  CellMemo.Text := FCell.Content;

//  BorderFrame :=
  TBorderFrame.Create(
    Self,
    loContent,
    Application.Title,
    Trunc(loScreen.Width * SCALE_VALUE) + 50,
    Trunc(loScreen.Height * SCALE_VALUE) + 10,
    //Round(loScreen.Width * SCALE_VALUE) + 50,
    //Round(loScreen.Height * SCALE_VALUE) + 10,
    $FF2A001A,
    $FF2A001A,
    $FF4C002F,
    $FF9B0060);

  Self.Fill.Kind := TBrushKind.Solid;
  Self.Fill.Color := FTheme.LightBackgroundColor;
  //DarkBackgroundColor;

  Self.CellMemo.TextSettings.FontColor := FTheme.TextColor;
  Self.CellMemo.TextSettings.Font.Size := FTheme.TextFontSize;
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

  Action := TCloseAction.caFree;
end;

procedure TCellReminderForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := true;

  Self.OnCloseQuery := nil;
end;

procedure TCellReminderForm.GotoButtonClick(Sender: TObject);
begin
  ModalResult := mrContinue;
end;

class function TCellReminderForm.Show(
  const ACell: TCell;
  const ATheme: TTheme = nil): TModalResult;
var
  CellReminderForm: TCellReminderForm;
  VisibleState: Boolean;
begin
  CellReminderForm := TCellReminderForm.Create(nil, ACell);

  if Assigned(ATheme) then
    ATheme.CopyTo(CellReminderForm.Theme);

  try
    // Если приложение было свернуто в трэй, тогда необходимо его показать
    VisibleState := IsWindowVisible(ApplicationHwnd);
    if not VisibleState then
      ShowWindow(ApplicationHwnd, SW_SHOW);

    Result := CellReminderForm.ShowModal;

    // После принудительного показа, возвращаем приложение в исходное состояние
    if not VisibleState then
      ShowWindow(ApplicationHwnd, SW_HIDE);
  finally
    CellReminderForm.ReleaseForm;
  end;
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

end.


