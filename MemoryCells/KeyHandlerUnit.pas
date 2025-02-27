unit KeyHandlerUnit;

interface

procedure KeyHandler(const AKey: Word);

implementation

uses
    MemoryCellsUnit
  , SearchTextFrameUnit
  , DestinationFolderNavigatorFrameUnit
  , FMX.OnClickReplacerUnit
  , FMX.Controls
  ;

procedure EscapeHandler;
begin
  if not Assigned(MainForm) then
    Exit;

  if Assigned(SearchTextFrame) then
  begin
    MainForm.SearchTextCancelHandler(nil);
  end
  else
  if Assigned(DestinationFolderNavigatorFrame) then
  begin
    MainForm.DestinationFolderNavigatorCancelHandler(nil);
  end;
end;

procedure EnterHandler;
begin
  if not Assigned(MainForm) then
    Exit;

  if Assigned(SearchTextFrame) then
  begin
    MainForm.SearchTextOkHandler(nil);
  end;
end;

procedure F7Handler;
begin
  if not Assigned(MainForm) then
    Exit;

  if not Assigned(SearchTextFrame) then
  begin
    MainForm.SearchButtonClick(nil);
  end;
end;

procedure HomeHandler;
var
  Result: Boolean;
  Control: TControl;
begin
  if not Assigned(MainForm) then
    Exit;

  if Assigned(SearchTextFrame) then
    Exit;

  if MainForm.CellMemo.IsFocused then
    Exit;

  Control := MainForm.HomeButton;

  Result := TOnClickReplacer.IsContainsControl(Control);
  if Result then
    TOnClickReplacer.DoOnClickHandler(Control)
  else
    MainForm.HomeButtonClick(Control);
end;

procedure KeyHandler(const AKey: Word);
begin
  case AKey of
    27{Esc}:
      EscapeHandler;
    118{F7}:
      F7Handler;
    13{Enter}:
      EnterHandler;
    36{Home}:
      HomeHandler;
  end;
end;

end.
