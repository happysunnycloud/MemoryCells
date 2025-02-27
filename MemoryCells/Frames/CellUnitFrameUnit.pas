unit CellUnitFrameUnit;

interface

uses
    System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
    FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, BaseCellFrameUnit, FMX.Layouts,
    FMX.Objects, FMX.Controls.Presentation
  , CellUnit
  ;

type
  TCellUnitFrame = class(TBaseCellFrame)
    CellUnitPanel: TPanel;
    CellUnitNameText: TText;
    RightLayout: TLayout;
    Layout1: TLayout;
    UpdateDateText: TText;
    Layout2: TLayout;
    CellUnitButton: TButton;
    FavoriteCellButton: TButton;
    CellUnitCheckBox: TCheckBox;
  private
    procedure OnContentChangeHandler(Sender: TObject);
    procedure OnDescChangeHandler(Sender: TObject);
    procedure OnIsDoneChangeHandler(Sender: TObject);
  public
    constructor Create(AOwner: TComponent; const ACell: TCell); reintroduce;
  end;

//var
//  CellUnitFrame: TCellUnitFrame;

implementation

{$R *.fmx}

//uses
//    CellUnit
//  ;

constructor TCellUnitFrame.Create(AOwner: TComponent; const ACell: TCell);
begin
  inherited Create(AOwner, ACell);

  Cell.OnContentChanged := OnContentChangeHandler;
  Cell.OnDescChanged := OnDescChangeHandler;

  Cell.OnIsDoneChanged := OnIsDoneChangeHandler;

  OnIsDoneChangeHandler(nil);
end;

procedure TCellUnitFrame.OnContentChangeHandler(Sender: TObject);
begin
  CellUnitNameText.Text := TCell(Sender).Desc;
end;

procedure TCellUnitFrame.OnDescChangeHandler(Sender: TObject);
begin
  CellUnitNameText.Text := TCell(Sender).Desc;
end;

procedure TCellUnitFrame.OnIsDoneChangeHandler(Sender: TObject);
var
  Font: TFont;
begin
  Font := CellUnitNameText.TextSettings.Font;
  if Cell.IsDone then
    Font.Style := Font.Style + [TFontStyle.fsStrikeOut]
  else
    Font.Style := Font.Style - [TFontStyle.fsStrikeOut]
end;

end.
