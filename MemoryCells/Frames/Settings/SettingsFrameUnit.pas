unit SettingsFrameUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Controls.Presentation, BaseSettingUnit,
  FMX.Edit, FMX.Objects
  , FMX.Theme, BackupSettingFrameUnit, LaunchSettingFrameUnit;

type
  TCallbackProc = reference to procedure (const ABaseSettingFrame: TBaseSettingFrame);

  TSettingsFrame = class(TFrame)
    Layout: TLayout;
    SearchPanel: TPanel;
    ScrollBox: TScrollBox;
    SearchButton: TButton;
    SearchEdit: TEdit;
    ServiceControlsLayout: TLayout;
    SaveButton: TButton;
    StyleBook: TStyleBook;
    CancelButton: TButton;
    Panel: TPanel;
    FindParameterLabel: TLabel;
    BackgroundRectangle: TRectangle;
    ServiceControlsPanel: TPanel;
    StatusLabel: TLabel;
    BackupSettingEmbeddedFrame: TBackupSettingFrame;
    LaunchSettingEmbeddedFrame: TLaunchSettingFrame;
    procedure SearchButtonClick(Sender: TObject);
  private
    FTheme: TTheme;

//    FBackupPath: String;
//    FBackupTime: TTime;
//    FRunOnStartup: Boolean;
  public
    constructor Create(
      AOwner: TComponent;
      const ATheme: TTheme = nil); reintroduce;
    destructor Destroy; override;

    procedure FrameEnumerator(const ACallbackProc: TCallbackProc);

    procedure Save;

//    property BackupPath: String read FBackupPath write FBackupPath;
//    property BackupTime: TTime read FBackupTime write FBackupTime;
//    property RunOnStartup: Boolean read FRunOnStartup write FRunOnStartup;
  end;

var
  SettingsFrame: TSettingsFrame;

implementation

{$R *.fmx}

uses
    ToolsUnit
  , AppManagerUnit
  , CommonUnit
  , FMX.ControlToolsUnit;

constructor TSettingsFrame.Create(
  AOwner: TComponent;
  const ATheme: TTheme = nil);
var
  TextSettingsFontColorControlsArray: TArray<TControl>;
  _Control: TControl;
  _TextSettings: TTextSettings;
begin
  inherited Create(AOwner);

  StatusLabel.Text := '';
  StatusLabel.Visible := false;

  FTheme := TTheme.Create;

  if Assigned(ATheme) then
    FTheme.CopyFrom(ATheme);

//  FTheme.CommonTextProps.Align := TAlignLayout.Left;

  FTheme.SaveStyleBookTo(Self.StyleBook);

  TControlTools.ControlEnumerator(ScrollBox,
    procedure (const AControl: TControl)
    begin
      if TControlTools.HasProperty(AControl, TProperties.TextSettings) then
      begin
        TControlTools.SetPropertyAsSet(
          AControl,
          TProperties.StyledSettings,
          '[Family, Size, Style]'
          );
      end;
    end);

  TextSettingsFontColorControlsArray :=
    [ SearchEdit,
      FindParameterLabel,
      StatusLabel,

      BackupSettingEmbeddedFrame.CaptionLabel,
      BackupSettingEmbeddedFrame.PathLabel,
      BackupSettingEmbeddedFrame.PathEdit,
      BackupSettingEmbeddedFrame.DateLabel,
      BackupSettingEmbeddedFrame.DateEdit,
      BackupSettingEmbeddedFrame.TimeLabel,
      BackupSettingEmbeddedFrame.TimeEdit,
      BackupSettingEmbeddedFrame.SelectFolderButton,

      LaunchSettingEmbeddedFrame.CaptionLabel,
      LaunchSettingEmbeddedFrame.RunAppAtStartupLabel,
      LaunchSettingEmbeddedFrame.CollapsAppAtStartupLabel
    ];

  for _Control in TextSettingsFontColorControlsArray do
  begin
    _TextSettings := TTextSettings(
      TControlTools.GetPropertyAsObject(_Control, TProperties.TextSettings));

    _TextSettings.FontColor := FTheme.CommonSettings.CustomTextSettings.FontColor;
//    _TextSettings.FontColor := FTheme.TextSettings.FontColor;
  end;

  BackupSettingEmbeddedFrame.CaptionLabel.TextSettings.Font.Style :=
    BackupSettingEmbeddedFrame.CaptionLabel.TextSettings.Font.Style +
    [TFontStyle.fsBold];

  LaunchSettingEmbeddedFrame.CaptionLabel.TextSettings.Font.Style :=
    LaunchSettingEmbeddedFrame.CaptionLabel.TextSettings.Font.Style +
    [TFontStyle.fsBold];

  BackgroundRectangle.Fill.Color := FTheme.LightBackgroundColor;

  // Убрать комменты, если хотим автозапуск запускать под правами админа
  //  LaunchSettingFrame.RunAppAtStartupSwitch.Enabled :=
  //    TPrivilegeTools.HasPrivilege('SeDebugPrivilege');

  FrameEnumerator(
    procedure (const ABaseSettingFrame: TBaseSettingFrame)
    begin
      ABaseSettingFrame.WriteValues(AppManager.Settings);
    end
  );
end;

destructor TSettingsFrame.Destroy;
begin
  FreeAndNil(FTheme);

  inherited;
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

procedure TSettingsFrame.Save;
begin
  FrameEnumerator(
    procedure (const ABaseSettingFrame: TBaseSettingFrame)
    begin
      ABaseSettingFrame.ReadValues(AppManager.Settings);
    end
  );

  AppManager.Settings.SaveApplicationSettings;
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
        TControlTools.ControlEnumerator(
          BaseSettingFrame,
          procedure (const AControl: TControl)
          var
            _Control: TControl absolute AControl;
          begin
            if not TControlTools.HasProperty(_Control, TProperties.Text)
            then
              Exit;

            TextValue :=
              TControlTools.GetPropertyAsString(_Control, TProperties.Text);
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
