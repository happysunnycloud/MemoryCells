unit BackupStarterThreadUnit;

interface

uses
    System.Classes
  , BaseThreadUnit
  , FMX.FormExtUnit
  , MCParamsUnit
  , ThreadFactoryUnit
  ;

type
  TBackupStarterThread = class(TBaseThread)
  strict private
    FProcRef: TParamsProcRef;
  protected
    procedure Execute(const AThread: TThreadExt); reintroduce;
  public
    constructor Create(
      const AForm: TFormExt;
      const AParams: TParamsExt;
      const AProcRef: TParamsProcRef); reintroduce;
  end;

implementation

uses
    System.SysUtils
  , FireDAC.Stan.Error
  , DBAccessUnit
  , DateUtils
  ;

{ TBackupStarterThread }

constructor TBackupStarterThread.Create(
  const AForm: TFormExt;
  const AParams: TParamsExt;
  const AProcRef: TParamsProcRef);
begin
  InParams.CopyFrom(AParams);
  FProcRef := AProcRef;

  inherited Create(AForm, Execute);
end;

procedure TBackupStarterThread.Execute;
const
  METHOD = 'TBackupStarterThread.Execute';
var
//  OutParams: TParamsExt;
  LastBackupDateTime: TDateTime;
  _HoursBetween: Int64;
  i: Word;
begin
  try
    Params.Clear;
    Params.CopyFrom(InParams);

    LastBackupDateTime := Params.AsDateTime[0];

    while not Terminated do
    begin
      i := 0;
      while (i < 10) and (not Terminated) do
      begin
        Sleep(1000);

        Inc(i);
      end;

      if Terminated then
        Exit;

      _HoursBetween := HoursBetween(Now, LastBackupDateTime);

      if _HoursBetween >= 24 then
      begin
        ControlParamsProc(FProcRef, nil{OutParams});

        Terminate;
      end;
    end;
  except
    on e: Exception do
    begin
      ExceptionMessage := Format('%s: %s', [METHOD, e.Message]);
    end;
  end;
end;

end.
