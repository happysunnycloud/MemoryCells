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

type
  TCountdownTimer = class(TBaseThread)
  strict private
    FTextControl: TControl;
    FText: String;
    FTimeout: Word;
  protected
    procedure InnerExecute; override;
  public
    constructor Create(
      const AForm: TFormExt;
      const ATextControl: TControl;
      const AText: String;
      const ATimeout: Word); reintroduce;
  end;

  TShowStatus = class
  strict private
    class var FThread: TThreadExt;
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

    class procedure Init;
  end;

implementation

uses
    System.SyncObjs
  , FMX.ControlToolsUnit
  ;

{ TShowStatus }

class procedure TShowStatus.Init;
begin
  FThread := nil;
  FForm := nil;
end;

class procedure TShowStatus.StopTimer;
begin
  FForm.ThreadFactory.TerminateThread(FThread);
end;

class procedure TShowStatus.ShowStatus(
  const ATextControl: TControl;
  const AText: String;
  const ATimeout: Word);
begin
  StopTimer;

  FThread := TCountdownTimer.Create(
    FForm,
    ATextControl,
    AText,
    ATimeout);
end;

class procedure TShowStatus.Stop;
begin
  StopTimer;
end;

{ TCountdownTimer }

constructor TCountdownTimer.Create(
  const AForm: TFormExt;
  const ATextControl: TControl;
  const AText: String;
  const ATimeout: Word);
begin
  TControlTools.CheckHasProperty(ATextControl, TProperties.Text);

  FTextControl := ATextControl;
  FText := AText;
  FTimeout := ATimeout;

  inherited Create(AForm);
end;

procedure TCountdownTimer.InnerExecute;
const
  METHOD = 'TCountdownTimer.InnerExecute';
var
  i: Word;
begin
  try
    HoldThread;
    TThread.Queue(nil,
      procedure
      begin
        FTextControl.Visible := true;
        TControlTools.SetPropertyAsString(FTextControl, TProperties.Text, FText);
        UnHoldThread;
      end);
    ExecHold;

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
  except
    on e: Exception do
    begin
      ExceptionMessage := Format('%s: %s', [METHOD, e.Message]);
    end;
  end;
end;

initialization
  TShowStatus.Init;

end.
