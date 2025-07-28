unit LaunchSettingFrameUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  BaseSettingUnit, FMX.Controls.Presentation, FMX.Layouts,
  CommonUnit;

type
  TLaunchSettingFrame = class(TBaseSettingFrame)
    RunAppAtStartupSwitch: TSwitch;
    RunAppAtStartupLabel: TLabel;
    LeftControlsLayout: TLayout;
    RightControlsLayout: TLayout;
    CollapsAppAtStartupLabel: TLabel;
    CollapsAppAtStartupSwitch: TSwitch;
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

constructor TLaunchSettingFrame.Create(AOwner: TComponent);
begin
  inherited;

  Caption := 'Launch';
end;

procedure TLaunchSettingFrame.WriteValues(const AApplicationSettings: TApplicationSettings);
begin
  RunAppAtStartupSwitch.IsChecked :=
    AApplicationSettings.RunAppAtStartup.ToBoolean;

  CollapsAppAtStartupSwitch.IsChecked :=
    AApplicationSettings.CollapseAppAtStartup.ToBoolean;
end;

procedure TLaunchSettingFrame.ReadValues(const AApplicationSettings: TApplicationSettings);
begin
  AApplicationSettings.RunAppAtStartup := raFalse;
  if RunAppAtStartupSwitch.IsChecked then
    AApplicationSettings.RunAppAtStartup := raTrue;

  AApplicationSettings.CollapseAppAtStartup := caFalse;
  if CollapsAppAtStartupSwitch.IsChecked then
    AApplicationSettings.CollapseAppAtStartup := caTrue
end;

end.
