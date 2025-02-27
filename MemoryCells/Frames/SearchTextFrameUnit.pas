unit SearchTextFrameUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, BaseCellFrameUnit, FMX.Edit, FMX.Layouts,
  FMX.Controls.Presentation;

type
  TSearchTextFrame = class(TBaseCellFrame)
    Panel: TPanel;
    CancelButtonLayout: TLayout;
    SearchTextOkButton: TButton;
    OkButtonLayout: TLayout;
    SearchTextCancelButton: TButton;
    TextLayout: TLayout;
    SearchTextEdit: TEdit;
    HightlightLayout: TLayout;
    PrevHightlightButton: TButton;
    Layout2: TLayout;
    Layout3: TLayout;
    NextHightlightButton: TButton;
  private
    { Private declarations }
  public
    constructor Create(AOwner: TComponent); reintroduce;
    destructor Destroy; override;
  end;

var
  SearchTextFrame: TSearchTextFrame;

implementation

{$R *.fmx}

uses
    AppManagerUnit
  , CommonUnit
  ;

constructor TSearchTextFrame.Create(AOwner: TComponent);
begin
  if Assigned(AppManager) then
    AppManager.CurrentState.Mode := TCurrentMode.cmSearch;

  inherited;
end;

destructor TSearchTextFrame.Destroy;
begin
  if Assigned(AppManager) then
    AppManager.CurrentState.Mode := TCurrentMode.cmCommon;

  inherited;
end;

end.
