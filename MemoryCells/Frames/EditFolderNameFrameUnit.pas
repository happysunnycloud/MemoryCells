unit EditFolderNameFrameUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, BaseCellFrameUnit, FMX.Edit, FMX.Layouts,
  FMX.Controls.Presentation;

type
  TEditFolderNameFrame = class(TBaseCellFrame)
    Panel: TPanel;
    CancelButtonLayout: TLayout;
    EditFolderNameOkButton: TButton;
    OkButtonLayout: TLayout;
    EditFolderNameCancelButton: TButton;
    TextLayout: TLayout;
    FolderNameEdit: TEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  EditFolderNameFrame: TEditFolderNameFrame;

implementation

{$R *.fmx}

end.
