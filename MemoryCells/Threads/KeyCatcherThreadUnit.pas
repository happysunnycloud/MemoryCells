unit KeyCatcherThreadUnit;

interface

uses
  System.Classes,
  System.SysUtils,
  MemoryFileUnit,
  FMX.FormExtUnit,
  MCParamsUnit,
  BaseThreadUnit,
  ThreadFactoryUnit
  ;

type
  TKeyCatcherThread = class (TBaseThread)
  protected
    procedure Execute(const AThread: TThreadExt); reintroduce;
  public
    constructor Create(
      const AForm: TFormExt; const AParams: TParamsExt); reintroduce;
  end;

var
  KeyCatcherThread: TKeyCatcherThread;

implementation

uses
  FMX.Dialogs,
  KeyHandlerUnit,
  CommonUnit
  ;

constructor TKeyCatcherThread.Create(
  const AForm: TFormExt; const AParams: TParamsExt);
begin
  inherited Create(AForm, Execute);

  InParams.CopyFrom(AParams);
end;

procedure TKeyCatcherThread.Execute;
const
  METHOD = 'TKeyCatcherThread.Execute';

  procedure _GetValues(const AReadedString: String; var ADateTime: TDateTime; var AKeyCode: Word);
  var
    i: Word;
    DateTimeStr: String;
    KeyCodeStr: String;
  begin
    i := Pos(';', AReadedString);
    if i = 0 then
      raise Exception.Create('TKeyCatcherThread.Execute: Wrong key catcher string format');

    DateTimeStr := Copy(AReadedString, 1, Pred(i));
    KeyCodeStr := Copy(AReadedString, i + 1, AReadedString.Length);

    try
      ADateTime := StrToDateTime(DateTimeStr);
    except
      raise Exception.Create(METHOD + ': Wrong key catcher string format for StrToDateTime');
    end;

    try
      AKeyCode := Word(KeyCodeStr.ToInteger);
    except
      raise Exception.Create(METHOD + ': Wrong key catcher string format for StrToDateTime');
    end;
  end;
var
  ReadedString: String;
  KeyCode: Word;
  LastKeyCode: Word;
  CurrentDateTime: TDateTime;
  LastDateTime: TDateTime;
  MemoryFile: TMemoryFile;
  MemoryFileName: String;
begin
  try
    Params.Clear;
    Params.CopyFrom(InParams);

    MemoryFileName := Params.AsString[0];

    MemoryFile := TMemoryFile.Create(MemoryFileName);
    try
      if not MemoryFile.ExistsMemoryFile then
        MemoryFile.CreateMemoryFile;

      MemoryFile.OpenMemoryFile;

      CurrentDateTime := Now;
      LastDateTime := CurrentDateTime;
      KeyCode := 0;
      LastKeyCode := KeyCode;
      while not Terminated do
      begin
        Sleep(10);

        ReadedString := MemoryFile.ReadFromMemoryFile;

        if ReadedString.Length = 0 then
          Continue;

        _GetValues(ReadedString, CurrentDateTime, KeyCode);

        if (LastDateTime <> CurrentDateTime) and
           (LastKeyCode <> KeyCode)
        then
        begin
          LastDateTime := CurrentDateTime;
          LastKeyCode := KeyCode;

          if not THelpmate.IsFormActive(Form) then
            Continue;

          Queue(nil,
          //Synchronize(
            procedure
            begin
              KeyHandler(KeyCode);
            end);
        end;
      end;
    finally
      MemoryFile.FreeMemoryFile;
      MemoryFile.Free;
    end;
  except
    on e: Exception do
      ExceptionMessage := Format('%s: %s', [METHOD, e.Message]);
  end;
end;

end.
