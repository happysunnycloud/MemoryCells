unit BackupThreadUnit;

interface

uses
    System.Classes
  , BaseThreadUnit
  , FMX.FormExtUnit
  , DataManagerUnit
  , MCParamsUnit
  , ThreadFactoryUnit
  ;

type
  TBackupThread = class(TBaseThread)
  strict private
    FProcRef: TParamsProcRef;
  protected
    procedure InnerExecute; override;
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
  ;

{ TBackupThread }

constructor TBackupThread.Create(
  const AForm: TFormExt;
  const AParams: TParamsExt;
  const AProcRef: TParamsProcRef);
begin
  inherited Create(AForm);

  InParams.CopyFrom(AParams);
  FProcRef := AProcRef;
end;

procedure TBackupThread.InnerExecute;
const
  METHOD = 'TBackupThread.InnerExecute';
var
  BackupFileName: String;
  Params: TParamsExt;
begin
  try
    Params := TParamsExt.Create;
    try
      Params.Clear;
      Params.CopyFrom(InParams);

      BackupFileName := Params.AsString[0];

      TDBAccess.DBAParamsFunc(TDBAccess.Backup, Params, nil);

      ControlParamsProc(FProcRef, nil);
    finally
      FreeAndNil(Params);
    end;
  except
    on e: Exception do
    begin
      ExceptionMessage := Format('%s: %s', [METHOD, e.Message]);
    end;
  end;
end;

end.
