unit FolderUnitFrameUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, BaseCellFrameUnit, FMX.Objects,
  FMX.Controls.Presentation;

type
  TFolderUnitFrame = class(TBaseCellFrame)
    Panel: TPanel;
    FolderUnitNameText: TText;
    FolderUnitButton: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FolderUnitFrame: TFolderUnitFrame;

implementation

{$R *.fmx}

end.
