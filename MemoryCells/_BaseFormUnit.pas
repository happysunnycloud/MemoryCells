unit BaseFormUnit;

interface

uses
    System.Classes
  , System.UITypes
  , FMX.FormExtUnit
  , ThreadRegistryUnit
  ;

type
  TBaseForm = class(TFormExt)
  strict private
  private
  public
    procedure Repaint;
  end;

implementation

uses
    System.SysUtils
  ;

procedure TBaseForm.Repaint;
begin
  Self.PaintRects([Self.ClientRect]);
end;

end.
