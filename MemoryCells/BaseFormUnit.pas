unit BaseFormUnit;

interface

uses
    System.Classes
  , System.UITypes
  , FMX.Forms

  , ThreadRegistryUnit
  ;

type
  TBaseForm = class(FMX.Forms.TForm)
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  strict private
    FCanClose: Boolean;
    FThreadRegistry: TThreadRegistry<Pointer>;
  private
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Repaint;

    property CanClose: Boolean read FCanClose write FCanClose;
    property ThreadRegistry: TThreadRegistry<Pointer> read FThreadRegistry;
  end;

implementation

uses
    System.SysUtils

  , CloseFormThreadUnit
  ;

constructor TBaseForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FCanClose := false;
  OnCloseQuery := FormCloseQuery;
  OnClose := FormClose;

  FThreadRegistry := TThreadRegistry<Pointer>.Create;
end;

destructor TBaseForm.Destroy;
begin
  FreeAndNil(FThreadRegistry);

  inherited;
end;

procedure TBaseForm.Repaint;
begin
  Self.PaintRects([Self.ClientRect]);
end;

procedure TBaseForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  OnCloseQuery := nil;
  CanClose := false;

  TCloseFormThread.Create(Self);
end;

procedure TBaseForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
end;

end.
