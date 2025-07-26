unit BackupSettingFrameUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  BaseSettingUnit, FMX.Controls.Presentation, FMX.Layouts, FMX.Edit,
  FMX.DateTimeCtrls,
  CommonUnit;

type
  TBackupSettingFrame = class(TBaseSettingFrame)
    PathEdit: TEdit;
    SelectFolderButton: TButton;
    PathLabel: TLabel;
    TimeLabel: TLabel;
    TimeEdit: TTimeEdit;
    ControlsCaptionsLayout: TLayout;
    ControlsControlsLayout: TLayout;
    procedure SelectFolderButtonClick(Sender: TObject);
  private
    FLastBackupDateTime: TDateTime;
  public
    constructor Create(AOwner: TComponent); override;

    procedure WriteValues(const AApplicationSettings: TApplicationSettings); override;
    procedure ReadValues(const AApplicationSettings: TApplicationSettings); override;
  end;

var
  BackupSettingFrame: TBackupSettingFrame;

implementation

{$R *.fmx}

uses
    DateTimeToolsUnit
  , FMX.ControlToolsUnit;

constructor TBackupSettingFrame.Create(AOwner: TComponent);
begin
  inherited;

  Caption := 'Backup';
end;

procedure TBackupSettingFrame.SelectFolderButtonClick(Sender: TObject);
var
  SelectedFolder: string;
begin
  inherited;

  SelectDirectory('Выберите директорию', '', SelectedFolder);

  PathEdit.Text := Trim(SelectedFolder);
end;

procedure TBackupSettingFrame.WriteValues(const AApplicationSettings: TApplicationSettings);
begin
  PathEdit.Text := AApplicationSettings.BackupsPath;
  FLastBackupDateTime := AApplicationSettings.LastBackupDateTime;
  TimeEdit.Time := FLastBackupDateTime;
end;

procedure TBackupSettingFrame.ReadValues(const AApplicationSettings: TApplicationSettings);
//var
//  a: String;
begin
  AApplicationSettings.BackupsPath := PathEdit.Text;
  TDateTimeTools.ChangeTime(FLastBackupDateTime, TimeEdit.Time);
  AApplicationSettings.LastBackupDateTime := FLastBackupDateTime;

//  a := DateTimeToStr(AApplicationSettings.LastBackupDateTime);
end;

end.
