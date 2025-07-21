unit CellReminderDateTimeFrameUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  BaseCellFrameUnit, FMX.Layouts, FMX.DateTimeCtrls, FMX.Controls.Presentation,
  FMX.Edit,
  FMX.DateTimeControlsTuningUnit,
  CellUnit;

type
  TCellReminderDateTimeFrame = class(TBaseCellFrame)
    ContentsLayout: TLayout;
    RemindDateEdit: TDateEdit;
    RemindTimeEdit: TTimeEdit;
    DateTimeLayout: TLayout;
    ButtonsLayout: TLayout;
    OkButton: TButton;
    _CancelButton: TButton;
    Panel: TPanel;
    TuningLayout: TLayout;
    TuningPanel: TPanel;
    MonthEdit: TEdit;
    DayEdit: TEdit;
    DayLabel: TLabel;
    TuningCaptionPanel: TPanel;
    YearEdit: TEdit;
    MonthLabel: TLabel;
    YearLabel: TLabel;
    HourLabel: TLabel;
    MinuteLabel: TLabel;
    HourEdit: TEdit;
    MinuteEdit: TEdit;
    RemindCheckBox: TCheckBox;
  private
    { Private declarations }

    FDateTuning: TDateTuning;
    FTimeTuning: TTimeTuning;

    FExternallOkButtonOnClickHandler: TNotifyEvent;

    FExternalOnDateTimeChangedHandler: TNotifyEvent;
    FExternalOnRemindChangedHandler: TNotifyEvent;

    procedure FillReminderFields;
    //procedure InternalOkButtonOnClickHandler(Sender: TObject);
    procedure InternalOnDateTimeChangedHandler(Sender: TObject);
    procedure InternalOnRemindChangedHandler(Sender: TObject);
  public
    { Public declarations }
    constructor Create(
      AOwner: TComponent;
      const ACell: TCell); reintroduce; overload;
    destructor Destroy; override;

    class function ShowCellReminderFrame(
      const AParent: TFmxObject;
      const ACell: TCell): TCellReminderDateTimeFrame;
    class procedure HideCellReminderFrame(var ACellReminderDateTimeFrame: TCellReminderDateTimeFrame);

    //procedure SetOkButtonOnClick(ANotifyEvent: TNotifyEvent);

    property OnDateTimeChanged: TNotifyEvent
      read FExternalOnDateTimeChangedHandler
      write FExternalOnDateTimeChangedHandler;
    property OnRemindChanged: TNotifyEvent
      read FExternalOnRemindChangedHandler
      write FExternalOnRemindChangedHandler;
  end;

//var
//  CellReminderDateTimeFrame: TCellReminderDateTimeFrame;

implementation

{$R *.fmx}

uses
    DBAccessUnit
  , FMX.ShowNoteFormUnit
  ;

constructor TCellReminderDateTimeFrame.Create(
  AOwner: TComponent;
  const ACell: TCell);
begin
  inherited Create(AOwner, ACell);

  FDateTuning := TDateTuning.Create;
  FDateTuning.Init(RemindDateEdit, DayEdit, MonthEdit, YearEdit);
  FDateTuning.OnChanged := InternalOnDateTimeChangedHandler;

  FTimeTuning := TTimeTuning.Create;
  FTimeTuning.Init(RemindTimeEdit, HourEdit, MinuteEdit);
  FTimeTuning.OnChanged := InternalOnDateTimeChangedHandler;

  RemindCheckBox.OnChange := InternalOnRemindChangedHandler;

  FExternalOnDateTimeChangedHandler := nil;
  FExternalOnRemindChangedHandler := nil;

  FillReminderFields;

  FExternallOkButtonOnClickHandler := nil;
end;

destructor TCellReminderDateTimeFrame.Destroy;
begin
  FreeAndNil(FDateTuning);
  FreeAndNil(FTimeTuning);

  inherited;
end;

class function TCellReminderDateTimeFrame.ShowCellReminderFrame(
  const AParent: TFmxObject;
  const ACell: TCell): TCellReminderDateTimeFrame;
begin
  Result := TCellReminderDateTimeFrame.Create(AParent, ACell);

  Result.Parent := AParent;
  Result.Align := TAlignLayout.Bottom;
end;

class procedure TCellReminderDateTimeFrame.HideCellReminderFrame(
  var ACellReminderDateTimeFrame: TCellReminderDateTimeFrame);
begin
  if Assigned(ACellReminderDateTimeFrame) then
    FreeAndNil(ACellReminderDateTimeFrame);
end;

procedure TCellReminderDateTimeFrame.FillReminderFields;
var
  RemindDate: TDate;
  RemindTime: TTime;
  Remind: Boolean;
  RemindDateString: String;
  RemindTimeString: String;
begin
  RemindDate := Cell.RemindDateTime;
  RemindTime := Cell.RemindDateTime;
  Remind := Cell.Remind;

  if RemindDate = NULL_DATETIME then
  begin
    RemindDate := TDate(Now);
    RemindTime := TTime(Now);
  end;

  RemindDateString := DateToStr(RemindDate);
  RemindTimeString := TimeToStr(RemindTime);

  RemindDateEdit.Text := RemindDateString;
  RemindTimeEdit.Text := RemindTimeString;
  RemindCheckBox.IsChecked := Remind;
end;

//procedure TCellReminderDateTimeFrame.InternalOkButtonOnClickHandler(Sender: TObject);
//var
//  CellRemindDateString: String;
//  CellRemindTimeString: String;
//  CellRemind: Boolean;
//begin
//  CellRemindDateString := RemindDateEdit.Text;
//  if CellRemindDateString.Length  = 0 then
//  begin
//    TNoteForm.ShowOk('Value is not defined', 'The date field cannot be empty');
//
//    Exit;
//  end;
//
//  CellRemindTimeString := RemindTimeEdit.Text;
//  if CellRemindTimeString.Length  = 0 then
//  begin
//    TNoteForm.ShowOk('Value is not defined', 'The time field cannot be empty');
//
//    Exit;
//  end;
//
//  CellRemind := RemindCheckBox.IsChecked;
//
//  Cell.RemindDateTime := StrToDateTime(CellRemindDateString + ' ' + CellRemindTimeString);
//  Cell.Remind := CellRemind;
//
//  if Assigned(FExternallOkButtonOnClickHandler) then
//    FExternallOkButtonOnClickHandler(nil);
//end;

//procedure TCellReminderDateTimeFrame.SetOkButtonOnClick(ANotifyEvent: TNotifyEvent);
//begin
//  FExternallOkButtonOnClickHandler := ANotifyEvent;
//  OkButton.OnClick := InternalOkButtonOnClickHandler;
//end;

procedure TCellReminderDateTimeFrame.InternalOnDateTimeChangedHandler(Sender: TObject);
var
  CellRemindDateString: String;
  CellRemindTimeString: String;
begin
  CellRemindDateString := RemindDateEdit.Text;
  if CellRemindDateString.Length  = 0 then
  begin
    TNoteForm.ShowOk('Value is not defined', 'The date field cannot be empty');

    Exit;
  end;

  CellRemindTimeString := RemindTimeEdit.Text;
  if CellRemindTimeString.Length  = 0 then
  begin
    TNoteForm.ShowOk('Value is not defined', 'The time field cannot be empty');

    Exit;
  end;

  Cell.RemindDateTime := StrToDateTime(CellRemindDateString + ' ' + CellRemindTimeString);

  if Assigned(FExternalOnDateTimeChangedHandler) then
    FExternalOnDateTimeChangedHandler(Sender);
end;

procedure TCellReminderDateTimeFrame.InternalOnRemindChangedHandler(Sender: TObject);
var
  CellRemind: Boolean;
begin
  CellRemind := RemindCheckBox.IsChecked;
  Cell.Remind := CellRemind;

  if Assigned(FExternalOnRemindChangedHandler) then
    FExternalOnRemindChangedHandler(Sender);
end;

end.
