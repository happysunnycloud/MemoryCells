unit BackupStarterThreadUnit;

interface

uses
    System.Classes

  , BaseThreadUnit
  , BaseFormUnit
//  , CommonUnit
  , MCParamsUnit
  ;

type
  TBackupStarterThread = class(TBaseThread)
  strict private
    FProcRef: TParamsProcRef;
  protected
    procedure Execute; override;
  public
    constructor Create(
      const AForm: TBaseForm;
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
  const AForm: TBaseForm;
  const AParams: TParamsExt;
  const AProcRef: TParamsProcRef);
begin
  inherited Create(AForm);

  InParams.CopyFrom(AParams);
  FProcRef := AProcRef;
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
