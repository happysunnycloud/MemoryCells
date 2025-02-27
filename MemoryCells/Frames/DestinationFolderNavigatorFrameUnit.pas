unit DestinationFolderNavigatorFrameUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FMX.Layouts, FMX.Objects,
  FMX.Controls.Presentation

  , CurrentFolderFrameUnit
  , CellUnit
  ;

type
  TDestinationFolderNavigatorFrame = class(TFrame)
    CurrentFolderLayout: TLayout;
    CurrentFolderContentsLayout: TLayout;
    FoldersScrollBox: TScrollBox;
    ControlsLayout: TLayout;
    Rectangle1: TRectangle;
    ControlsPanel: TPanel;
    CancelButton: TButton;
    CurrentFolderContentsPanel: TPanel;
    CurrentFolderPanel: TPanel;
    BackgroundRectangle: TRectangle;
    MoveCellsButton: TButton;
    CopyCellsButton: TButton;
    procedure CurrentFolderPanelClick(Sender: TObject);
  private
    FCurrentFolderFrame: TCurrentFolderFrame;
    FSelectedCellIdList: TCellIdList;
  public
    constructor Create(AOwner: TComponent; const ATextSettings: TTextSettings); reintroduce;
    destructor Destroy; override;

    class function GetOrCreate(
      AOwner: TComponent;
      const ATextSettings: TTextSettings): TDestinationFolderNavigatorFrame;

    property CurrentFolderFrame: TCurrentFolderFrame read FCurrentFolderFrame;
    property SelectedCellIdList: TCellIdList read FSelectedCellIdList write FSelectedCellIdList;
  end;

var
  DestinationFolderNavigatorFrame: TDestinationFolderNavigatorFrame;

implementation

{$R *.fmx}

constructor TDestinationFolderNavigatorFrame.Create(AOwner: TComponent; const ATextSettings: TTextSettings);
begin
  inherited Create(AOwner);

  FCurrentFolderFrame := TCurrentFolderFrame.Create(Self);
  FCurrentFolderFrame.Parent := CurrentFolderPanel;
  FCurrentFolderFrame.Align := TAlignLayout.Contents;
  FCurrentFolderFrame.FolderNameText.Text := 'Current';
  FCurrentFolderFrame.FolderNameText.TextSettings.Assign(ATextSettings);
  FCurrentFolderFrame.FolderNameText.HitTest := false;
  FCurrentFolderFrame.FolderNameText.Margins.Left := 15;

  FSelectedCellIdList := TCellIdList.Create;
end;

destructor TDestinationFolderNavigatorFrame.Destroy;
begin
  FreeAndNil(FSelectedCellIdList);

  inherited;
end;

procedure TDestinationFolderNavigatorFrame.CurrentFolderPanelClick(Sender: TObject);
begin
  ShowMessage('aaaaaa');
end;

class function TDestinationFolderNavigatorFrame.GetOrCreate(
  AOwner: TComponent;
  const ATextSettings: TTextSettings): TDestinationFolderNavigatorFrame;
begin
  if Assigned(DestinationFolderNavigatorFrame) then
    Result := DestinationFolderNavigatorFrame
  else
    Result := TDestinationFolderNavigatorFrame.Create(AOwner, ATextSettings);
end;

end.
