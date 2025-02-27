unit LaunchSettingFrameUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  BaseSettingUnit, FMX.Controls.Presentation, FMX.Layouts,
  CommonUnit;

const
  APP_NAME = 'MemoryCells';

type
  TLaunchSettingFrame = class(TBaseSettingFrame)
    Switch: TSwitch;
    RunAtStartupLabel: TLabel;
    LeftControlsLayout: TLayout;
    procedure SwitchClick(Sender: TObject);
  private
    { Private declarations }
  public
    constructor Create(AOwner: TComponent); override;

    procedure WriteValues(const AApplicationSettings: TApplicationSettings); override;
    procedure ReadValues(const AApplicationSettings: TApplicationSettings); override;
  end;

var
  LaunchSettingFrame: TLaunchSettingFrame;

implementation

{$R *.fmx}

uses
    ToolsUnit
  ;

constructor TLaunchSettingFrame.Create(AOwner: TComponent);
begin
  inherited;

  Caption := 'Launch';
end;

procedure TLaunchSettingFrame.WriteValues(const AApplicationSettings: TApplicationSettings);
var
  NotifyEvent: TNotifyEvent;
begin
  NotifyEvent := Switch.OnClick;
  Switch.OnClick := nil;
  Switch.IsChecked := TRegistryTools.KeyExists(APP_NAME);
  Switch.OnClick := NotifyEvent;
end;

procedure TLaunchSettingFrame.ReadValues(const AApplicationSettings: TApplicationSettings);
begin
  // void
end;

procedure TLaunchSettingFrame.SwitchClick(Sender: TObject);
begin
  if Switch.IsChecked then
    TRegistryTools.AddAppAutoRun(APP_NAME, ParamStr(0))
  else
    TRegistryTools.DeleteAppAutoRun(APP_NAME);
end;

end.
