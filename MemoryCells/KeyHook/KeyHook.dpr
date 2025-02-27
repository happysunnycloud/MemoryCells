library KeyHook;

uses
  System.SysUtils,
  System.Classes,
  Windows,
  Messages,
  MemoryFileUnit in 'C:\Desktop\DevelopmentsCollection\MemoryFileUnit.pas',
  AddLogUnit in 'C:\Desktop\DevelopmentsCollection\AddLogUnit.pas'
  ;

var
  {handle для ловушки}
  HookHandle: hHook;
  MemoryFile: TMemoryFile;

  {собственно ловушка}
function KeyHookProc(Code: Integer; wParam: Word; lParam: Longint): Longint; stdcall; export;
  procedure _WriteKey(const AKey: Word);
  begin
    MemoryFile.WireToMemoryFile(DateTimeToStr(Now) + '; ' + IntToStr(AKey));

//    TLogger.AddLog('Got the key = ' + IntToStr(AKey), MG);
  end;
  procedure _GetKey;
  const
    KeysArray: array [0..3] of Byte = (
      VK_F7   {118},
      {enter} 13,
      {esc}   27,
      {home}  36
      );
  var
    i: Integer;
    Key: Byte;
  begin
    for i := 0 to Pred(Length(KeysArray)) do
    begin
      Key := KeysArray[i];
      if (GetAsyncKeyState(Key) shr 8 <> 0) then
        _WriteKey(Key);
    end;
  end;
begin
  Result := 0;
  {если Code >= 0, то ловушка может обработать событие}
  if (Code >= 0) then //and (lParam and $40000000 = 0) then
  begin
//    TLogger.AddLog('wParam = ' + IntToStr(wParam), MG);
//    TLogger.AddLog('lParam = ' + IntToStr(lParam), MG);

    if Code = HC_ACTION then
    begin
      if Byte(LParam shr 24) < $80 then  //нажание клавиши
      begin
        _GetKey;

        //        if (GetAsyncKeyState(VK_F7)     shr 8 <> 0) then
        //          _WriteKey(VK_F7)
        //        else
        //        if (GetAsyncKeyState(13{enter}) shr 8 <> 0) then
        //          _WriteKey(13)
        //        else
        //        if (GetAsyncKeyState(27{esc})   shr 8 <> 0) then
        //          _WriteKey(27)
        //        else
        //        if (GetAsyncKeyState(36{home})  shr 8 <> 0) then
        //          _WriteKey(36);

        {если 0, то система должна дальше обработать это событие}
        {если 1 - нет}
        Result := 0;
      end;
    end;
  end
  else
  {если Code < 0, то нужно вызвать следующую ловушку}
  if Code < 0 then
    Result := CallNextHookEx(HookHandle, Code, wParam, lParam);
end;
//begin
//  if Code < 0 then
//  begin
//    Result:= CallNextHookEx(HookHandle, Code, wParam, lParam);
//    Exit;
//  end
//  else
//  if Code = HC_ACTION then
//  begin
//    if Byte(LParam shr 24) < $80 then  //нажание клавиши
//    begin
//      if GetAsyncKeyState(VK_F7) shr 8 <> 0 then
//      begin
//        MemoryFile.WireToMemoryFile(DateTimeToStr(Now) + '; ' + IntToStr(VK_F7));
//      end
//      else
//      if GetAsyncKeyState(36) shr 8 <> 0 then
//      begin
//        MemoryFile.WireToMemoryFile(DateTimeToStr(Now) + '; ' + IntToStr(36));
//      end;
//    end;
//  end;
//  Result := CallNextHookEx(HookHandle, Code, wParam, lParam);
//end;
procedure Hook(ASwitch: Boolean) export; stdcall;
var
  pwc: PWideChar;
begin
  if ASwitch then
  begin
//    TLogger.Init('C:\Desktop\MemoryCells\MemoryCells\Win32\Debug\KeyHookLog', 1000, true);

    MemoryFile := TMemoryFile.Create('MemoryCellsMemoryFile');
    if not MemoryFile.ExistsMemoryFile then
    begin
      MemoryFile.CreateMemoryFile;
    end;

    MemoryFile.OpenMemoryFile;

    HookHandle:= SetWindowsHookEx(WH_KEYBOARD_LL, @KeyHookProc, HInstance, 0);
//    HookHandle := SetWindowsHookEx(WH_KEYBOARD, @KeyHookProc, HInstance, 0);

    if HookHandle = 0 then
      MessageBox(0, 'Hook not loaded in memory', 'Error', MB_OK + MB_ICONERROR);
  end
  else
  begin
    if not UnhookWindowsHookEx(HookHandle) then
    begin
      pwc :=
        PWideChar('Hook not unload from memory: ' + SysErrorMessage(GetLastError) + ' Hook handle: ' + IntToStr(HookHandle));
      MessageBox(0, pwc, 'KeyHook error', MB_OK + MB_ICONERROR);
    end;

    MemoryFile.FreeMemoryFile;
    FreeAndNil(MemoryFile);

//    TLogger.UnInit;
  end;
end;

exports Hook;

end.
