unit CellMemoFrameUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, BaseCellFrameUnit, FMX.Memo.Types,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo
  , CellUnit
  , CellUnitFrameUnit
  ;

type
  TCellMemoFrame = class(TBaseCellFrame)
    CellMemo: TMemo;
  private
    // Ссылка на текущий фрейм из списка ячеек
    // Нужна для передачи Описания из Memo в ячейку из списка
    // Так же для трекинга подсветки текущей ячейки
    FCellUnitFrame: TCellUnitFrame;
    FOnCellMemoChangeTracking: TNotifyEvent;
    //FOnCellMemoExit: TNotifyEvent;

    //FBackupText: String;  что-то одно из двух точно лишнее
    FBackupCell: TCell;

    procedure SetCellUnitFrame(const ACellUnitFrame: TCellUnitFrame);

    procedure OnCellMemoChangeTrackingHandler(Sender: TObject);
    procedure OnIsDoneChangeHandler(Sender: TObject);
    //    procedure OnOnCellMemoHandler(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); reintroduce;
    destructor Destroy; override;

    procedure DisableCellMemoChangeTracking;
    procedure EnableCellMemoChangeTracking;

    procedure InsertText(const AText: String);

    property CellUnitFrame: TCellUnitFrame read FCellUnitFrame write SetCellUnitFrame;
    property OnCellMemoChangeTracking: TNotifyEvent read FOnCellMemoChangeTracking write FOnCellMemoChangeTracking;
    //    property OnCellMemoExit: TNotifyEvent read FOnCellMemoExit write FOnCellMemoExit;

    function CellMemoTextIsChanged: Boolean;
    procedure RestoreContent;

    // Присвыеваем текущее значение ремайндера к значению в бэкапе,
    // Нужно выполнить после сохранения значений ремайндера по кнопке Ок,
    // отдельно без сохранения всей ячейки
    // Таким образом CellMemoTextIsChanged будет решать, что ячейка не изменилась
    // и не будет предлагать сохранить ее заново
    procedure ResetBackupReminder;

    procedure SetCell(const ACell: TCell);
    procedure SetCellReminder(
      const ACellRemindDateTime: TDateTime;
      const ACellRemind: Boolean);
  end;

var
  CellMemoFrame: TCellMemoFrame;

implementation

{$R *.fmx}

constructor TCellMemoFrame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FCellUnitFrame := nil;

  FBackupCell := TCell.Create;

  CellMemo.OnChangeTracking := OnCellMemoChangeTrackingHandler;
  //  CellMemo.OnExit := OnOnCellMemoHandler;
end;

destructor TCellMemoFrame.Destroy;
begin
  FreeAndNil(FBackupCell);

  inherited;
end;

procedure TCellMemoFrame.OnCellMemoChangeTrackingHandler(Sender: TObject);
begin
  Cell.Content := CellMemo.Text;

  if Assigned(CellUnitFrame) then
    CellUnitFrame.Cell.Content := Cell.Content;

  if Assigned(FOnCellMemoChangeTracking) then
    FOnCellMemoChangeTracking(CellMemo);
end;

procedure TCellMemoFrame.SetCellUnitFrame(const ACellUnitFrame: TCellUnitFrame);
var
  PredCellUnitFrame: TCellUnitFrame;
begin
  PredCellUnitFrame := FCellUnitFrame;
  if Assigned(PredCellUnitFrame) then
  begin
    PredCellUnitFrame.CellUnitButton.StyleLookup := 'CellUnitButtonStyle';
  end;

  FCellUnitFrame := ACellUnitFrame;
  if Assigned(FCellUnitFrame) then
  begin
    FCellUnitFrame.CellUnitButton.StyleLookup := 'CellUnitButtonBacklightStyle';
  end;
end;

procedure TCellMemoFrame.OnIsDoneChangeHandler(Sender: TObject);
var
  Font: TFont;
begin
  Font := CellMemo.TextSettings.Font;
  if Cell.IsDone then
    Font.Style := Font.Style + [TFontStyle.fsStrikeOut]
  else
    Font.Style := Font.Style - [TFontStyle.fsStrikeOut]
end;

//procedure TCellMemoFrame.OnOnCellMemoHandler(Sender: TObject);
//begin
//  if Assigned(FOnCellMemoExit) then
//    FOnCellMemoExit(CellMemo);
//end;

procedure TCellMemoFrame.DisableCellMemoChangeTracking;
begin
  CellMemo.OnChangeTracking := nil;
end;

procedure TCellMemoFrame.EnableCellMemoChangeTracking;
begin
  CellMemo.OnChangeTracking := OnCellMemoChangeTrackingHandler;
end;

procedure TCellMemoFrame.InsertText(const AText: String);
begin
  // Сбрасываем отображение скроллера
  CellMemo.Lines.Clear;

  Cell.Content := AText;
  if Cell.Content = '' then
    Cell.RemindDateTime := 0;

  FBackupCell.CopyFrom(Cell);
  CellMemo.Text := Cell.Content;
end;

function TCellMemoFrame.CellMemoTextIsChanged: Boolean;
begin
  Result := false;

  if String.Compare(CellMemo.Text, FBackupCell.Content) <> 0 then
    Exit(true);

  if Cell.RemindDateTime <> FBackupCell.RemindDateTime then
    Exit(true);

  if Cell.Remind <> FBackupCell.Remind then
    Exit(true);
end;

procedure TCellMemoFrame.RestoreContent;
begin
  InsertText(FBackupCell.Content);
end;

procedure TCellMemoFrame.ResetBackupReminder;
begin
  FBackupCell.RemindDateTime := Cell.RemindDateTime;
  FBackupCell.Remind := Cell.Remind;
end;

procedure TCellMemoFrame.SetCell(const ACell: TCell);
begin
  Cell.Clear;
  Cell.CopyFrom(ACell);

  DisableCellMemoChangeTracking;
  OnIsDoneChangeHandler(nil);
  InsertText(Cell.Content);
  Cell.OnIsDoneChanged := OnIsDoneChangeHandler;
  EnableCellMemoChangeTracking;
end;

procedure TCellMemoFrame.SetCellReminder(
  const ACellRemindDateTime: TDateTime;
  const ACellRemind: Boolean);
begin
  Cell.RemindDateTime := ACellRemindDateTime;
  Cell.Remind := ACellRemind;

  OnCellMemoChangeTrackingHandler(nil);
end;

end.
