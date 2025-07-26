unit FMX.ShowStatusUnit;

interface

uses
  System.Classes,
  System.SysUtils,

  FMX.Controls,
  FMX.StdCtrls
  ;

type
  TCountdownTimer = class(TThread)
  strict private
    FTextControl: TControl;
    FText: String;
    FTimeout: Word;
  protected
    procedure Execute; override;
  public
    constructor Create(
      const ATextControl: TControl;
      const AText: String;
      const ATimeout: Word);
  end;

  TShowStatus = class
  strict private
    class var FCountdownTimer: TThread;
  private
    class procedure StopTimer;
  public
    class procedure ShowStatus(
      const ATextControl: TControl;
      const AText: String;
      const ATimeout: Word);
  end;

implementation

uses
  FMX.ControlToolsUnit;

{ TCountdownTimer }

constructor TCountdownTimer.Create(
  const ATextControl: TControl;
  const AText: String;
  const ATimeout: Word);
begin
  TControlTools.CheckHasProperty(ATextControl, TProperties.Text);

  FTextControl := ATextControl;
  FText := AText;
  FTimeout := ATimeout;

  inherited Create(false);
end;

procedure TCountdownTimer.Execute;
var
  i: Word;
begin
  TThread.Queue(nil,
    procedure
    begin
      FTextControl.Visible := true;
      TControlTools.SetTextProperty(FTextControl, FText);
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
  if Assigned(FCountdownTimer) then
  begin
    FCountdownTimer.Terminate;
    FCountdownTimer.WaitFor;
    FreeAndNil(FCountdownTimer);
  end;
end;

class procedure TShowStatus.ShowStatus(
  const ATextControl: TControl;
  const AText: String;
  const ATimeout: Word);
begin
  StopTimer;

  FCountdownTimer :=
    TCountdownTimer.Create(
      ATextControl,
      AText,
      ATimeout);
end;

initialization

finalization
  TShowStatus.StopTimer;

end.
