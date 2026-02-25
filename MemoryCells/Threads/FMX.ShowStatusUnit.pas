unit FMX.ShowStatusUnit;

interface

uses
  System.Classes,
  System.SysUtils,
  FMX.Controls,
  FMX.StdCtrls,
  BaseThreadUnit,
  FMX.FormExtUnit,
  ThreadFactoryUnit
  ;

const
  THREAD_NAME = 'CountdownTimer';

type
  TCountdownTimer = class(TBaseThread)
  strict private
    FTextControl: TControl;
    FText: String;
    FTimeout: Word;
  protected
    procedure Execute(const AThread: TThreadExt); reintroduce;
//    procedure InnerExecute; reintroduce;
  public
    constructor Create(
      const AForm: TFormExt;
      const ATextControl: TControl;
      const AText: String;
      const ATimeout: Word); reintroduce;
  end;

  TShowStatus = class
  strict private
    class var FForm: TFormExt;
  private
    class procedure StopTimer;
  public
    class procedure ShowStatus(
      const ATextControl: TControl;
      const AText: String;
      const ATimeout: Word);

    class procedure Stop;
    class property Form: TFormExt write FForm;
  end;

implementation

uses
  FMX.ControlToolsUnit;

{ TCountdownTimer }

constructor TCountdownTimer.Create(
  const AForm: TFormExt;
  const ATextControl: TControl;
  const AText: String;
  const ATimeout: Word);
begin
  TControlTools.CheckHasProperty(ATextControl, TProperties.Text);

  inherited Create(AForm, Execute);

  FTextControl := ATextControl;
  FText := AText;
  FTimeout := ATimeout;
end;

procedure TCountdownTimer.Execute;
//procedure TCountdownTimer.InnerExecute;
var
  i: Word;
begin
  TThread.Queue(nil,
    procedure
    begin
      FTextControl.Visible := true;
      TControlTools.SetPropertyAsString(FTextControl, TProperties.Text, FText);
    end);

  i := FTimeout div 100;
  while (i > 0) and (not Terminated) do
  begin
    Dec(i);

    Sleep(100);
  end;

  TThread.Queue(nil,
    procedure
    begin
      TLabel(FTextControl).Text := '';
      FTextControl.Visible := false;
    end);
end;

{ TShowStatus }

class procedure TShowStatus.StopTimer;
begin
  FForm.ThreadFactory.TerminateThread(THREAD_NAME);
end;

class procedure TShowStatus.ShowStatus(
  const ATextControl: TControl;
  const AText: String;
  const ATimeout: Word);
var
  Thread: TCountdownTimer;
begin
  StopTimer;

  Thread :=
    TCountdownTimer.Create(
      FForm,
      ATextControl,
      AText,
      ATimeout);

  Thread.Name := THREAD_NAME;
end;

class procedure TShowStatus.Stop;
begin
  StopTimer;
end;

end.
