unit BackupThreadUnit;

interface

uses
    System.Classes

  , BaseThreadUnit
  , BaseFormUnit
  , DataManagerUnit
  , MCParamsUnit
  ;

type
  TBackupThread = class(TBaseThread)
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
  ;

{ TBackupThread }

constructor TBackupThread.Create(
  const AForm: TBaseForm;
  const AParams: TParamsExt;
  const AProcRef: TParamsProcRef);
begin
  inherited Create(AForm);

  InParams.CopyFrom(AParams);
  FProcRef := AProcRef;
end;

procedure TBackupThread.Execute;
const
  METHOD = 'TBackupThread.Execute';
var
  BackupFileName: String;
begin
  try
    Params.Clear;
    Params.CopyFrom(InParams);

    BackupFileName := Params.AsString[0];

    TDBAccess.DBAParamsFunc(TDBAccess.Backup, Params, nil);

    ControlParamsProc(FProcRef, nil);
  except
    on e: Exception do
    begin
      ExceptionMessage := Format('%s: %s', [METHOD, e.Message]);
    end;
  end;
end;

end.
