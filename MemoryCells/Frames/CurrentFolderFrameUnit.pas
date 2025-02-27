unit CurrentFolderFrameUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, BaseCellFrameUnit, FMX.Objects,
  FMX.Controls.Presentation;

type
  TCurrentFolderFrame = class(TBaseCellFrame)
    Panel: TPanel;
    FolderNameText: TText;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CurrentFolderFrame: TCurrentFolderFrame;

implementation

{$R *.fmx}

end.
