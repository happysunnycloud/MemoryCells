unit SettingsFrameUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Controls.Presentation, BaseSettingUnit,
  BackupSettingFrameUnit, LaunchSettingFrameUnit, FMX.Edit, FMX.Objects;

type
  TCallbackProc = reference to procedure (const ABaseSettingFrame: TBaseSettingFrame);

  TSettingsFrame = class(TFrame)
    Layout: TLayout;
    SearchPanel: TPanel;
    ScrollBox: TScrollBox;
    BackupSettingFrame: TBackupSettingFrame;
    LaunchSettingFrame: TLaunchSettingFrame;
    SearchButton: TButton;
    SearchEdit: TEdit;
    ServiceControlsLayout: TLayout;
    SaveButton: TButton;
    StyleBook: TStyleBook;
    CancelButton: TButton;
    Panel: TPanel;
    procedure SearchButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    constructor Create(
      AOwner: TComponent); reintroduce;
    procedure FrameEnumerator(const ACallbackProc: TCallbackProc);
  end;

var
  SettingsFrame: TSettingsFrame;

implementation

{$R *.fmx}

uses
    FMX.ThemeUnit
  , SupportUnit;

constructor TSettingsFrame.Create(
  AOwner: TComponent);
begin
  inherited Create(AOwner);

//  TTheme.LoadStyleBook(Self.StyleBook);
end;

procedure TSettingsFrame.FrameEnumerator(const ACallbackProc: TCallbackProc);
var
  i: Integer;
  FrameControl: TControl;
  BaseSettingFrame: TBaseSettingFrame;
begin
  for i := 0 to Pred(ScrollBox.Content.ControlsCount) do
  begin
    FrameControl := ScrollBox.Content.Controls[i];
    if FrameControl is TBaseSettingFrame then
    begin
      BaseSettingFrame := TBaseSettingFrame(FrameControl);
      ACallbackProc(BaseSettingFrame);
    end;
  end;
end;

procedure TSettingsFrame.SearchButtonClick(Sender: TObject);
var
  i: Integer;
  FrameControl: TControl;
  BaseSettingFrame: TBaseSettingFrame;
  Key: String;
  ContainsKey: Boolean;
  TextValue: String;
begin
  ScrollBox.BeginUpdate;

  FrameEnumerator(
    procedure (const ABaseSettingFrame: TBaseSettingFrame)
    begin
      ABaseSettingFrame.Visible := true;
    end
  );

  Key := UpperCase(Trim(SearchEdit.Text));

  if Key.Length > 0 then
  begin
    for i := 0 to Pred(ScrollBox.Content.ControlsCount) do
    begin
      FrameControl := ScrollBox.Content.Controls[i];
      if FrameControl is TBaseSettingFrame then
      begin
        ContainsKey := false;

        BaseSettingFrame := TBaseSettingFrame(FrameControl);
        BaseSettingFrame.ControlEnumerator(
          procedure (const AControl: TControl)
          var
            _Control: TControl absolute AControl;
          begin
            if not TComponentFunctions.
              IsDesiredComponent(_Control, TProperties.Text)
            then
              Exit;

            TextValue := TComponentFunctions.GetTextProperty(_Control);
            if UpperCase(TextValue).Contains(Key) then
              ContainsKey := true;
          end
        );
        BaseSettingFrame.Visible := ContainsKey;
      end;
    end;
  end;

  ScrollBox.EndUpdate;
end;

end.
