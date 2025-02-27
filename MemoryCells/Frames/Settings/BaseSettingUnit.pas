unit BaseSettingUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts,
  CommonUnit;

type
  TCallbackProc = reference to procedure (const AControl: TControl);

  TBaseSettingFrame = class(TFrame)
    Layout: TLayout;
    Panel: TPanel;
    CaptionLabel: TLabel;
    CaptionLayout: TLayout;
    ControlsLayout: TLayout;
  private
    FCaption: String;

    procedure SetCaption(const ACaption: String);
    function GetCaption: String;
  public
    property Caption: String read GetCaption write SetCaption;

    procedure ControlEnumerator(const ACallbackProc: TCallbackProc);

    procedure WriteValues(const AApplicationSettings: TApplicationSettings); virtual;
    procedure ReadValues(const AApplicationSettings: TApplicationSettings); virtual;
  end;

implementation

{$R *.fmx}

procedure TBaseSettingFrame.SetCaption(const ACaption: String);
begin
  FCaption := ACaption;

  CaptionLabel.Text := FCaption;
end;

function TBaseSettingFrame.GetCaption: String;
begin
  Result := FCaption;
end;

procedure TBaseSettingFrame.ControlEnumerator(const ACallbackProc: TCallbackProc);
var
  i: Integer;
  Control: TControl;
begin
  for i := 0 to Pred(Panel.ControlsCount) do
  begin
    Control := Panel.Controls[i];
    ACallbackProc(Control);
  end;
end;

procedure TBaseSettingFrame.WriteValues(const AApplicationSettings: TApplicationSettings);
begin
  raise Exception.
    CreateFmt('The method "%s" must be overridden', ['TBaseSettingFrame.WriteValues']);
end;

procedure TBaseSettingFrame.ReadValues(const AApplicationSettings: TApplicationSettings);
begin
  raise Exception.
    CreateFmt('The method "%s" must be overridden', ['TBaseSettingFrame.ReadValues']);
end;

end.
