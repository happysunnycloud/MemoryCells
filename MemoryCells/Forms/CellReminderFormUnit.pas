unit CellReminderFormUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Memo.Types, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo,
  CellUnit, FMX.StdCtrls, FMX.Objects

  , CellReminderDateTimeFrameUnit
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
    CellMemoBackgroundRectangle: TRectangle;
    CellRemindButton: TButton;
    procedure CellMemoApplyStyleLookup(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure DeleteButtonClick(Sender: TObject);
    procedure GotoButtonClick(Sender: TObject);
    procedure CellRemindButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  strict private
    FCell: TCell;
    FCellReminderDateTimeFrame: TCellReminderDateTimeFrame;

    procedure CellReminderOkButtonClickHandler(Sender: TObject);

    procedure Cancel;
  private
    { Private declarations }
  public
    { Public declarations }
    constructor Create(
      AOwner: TComponent;
      const ACell: TCell); reintroduce; overload;
    destructor Destroy; override;

    class function Show(
      const ACell: TCell;
      const AStyleBook: TStyleBook): TModalResult;
  end;

var
  CellReminderForm: TCellReminderForm;

implementation

{$R *.fmx}

uses
    BorderFrameUnit
  , FMX.ThemeUnit
  , DBAccessUnit
  , FMX.OnClickReplacerUnit
  , FMX.ShowNoteFormUnit
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
      Rectangle.Fill.Color := TTheme.MemoColor;
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
end;

constructor TCellReminderForm.Create(
  AOwner: TComponent;
  const ACell: TCell);
const
  SCALE_VALUE = 1;
//var
//  BorderFrame: TBorderFrame;
begin
  if not Assigned(ACell) then
    raise Exception.Create('The cell cannot be nil');

  inherited Create(AOwner);

  TTheme.LoadStyleBook(Self.StyleBook);

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
  Self.Fill.Color := TTheme.DarkBackgroundColor;

  Self.CellMemo.TextSettings.FontColor := TTheme.TextColor;
  Self.CellMemo.TextSettings.Font.Size := TTheme.TextFontSize;
//  Self.NoteMemo.TextSettings.Font.Family := 'MS Reference Sans Serif';
  Self.CellMemo.StyledSettings := [];

  Self.CellMemoBackgroundRectangle.Fill.Color := TTheme.LightBackgroundColor;

//  Self.CancelButton.StyleLookup := 'CancelButtonStyle';

  ModalResult := mrCancel;
end;

destructor TCellReminderForm.Destroy;
begin
  inherited;
end;

procedure TCellReminderForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if ModalResult = mrCancel then
    FCell.Remind := false;

  Action := TCloseAction.caFree;
end;

procedure TCellReminderForm.GotoButtonClick(Sender: TObject);
begin
  ModalResult := mrContinue;
end;

class function TCellReminderForm.Show(
  const ACell: TCell;
  const AStyleBook: TStyleBook): TModalResult;
var
  CellReminderForm: TCellReminderForm;
begin
  CellReminderForm := TCellReminderForm.Create(nil, ACell);
  try
    Result := CellReminderForm.ShowModal;
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

end.


