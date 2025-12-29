unit DBAccessUnit;

interface

uses
    System.SysUtils
  , BaseDBAccessUnit
  , ParamsExtUnit;

type
  TQueryProc = reference to
    procedure (const AInParams: TParamsExt; const AOutParams: TParamsExt);

  TDBAccess = class (TBaseDBAccess)
  strict private
    procedure ShowExceptionMessage(
      const AMethod: String;
      const AE: Exception);
  public
    procedure CreateTable;
    procedure SelectFromTable(const APath: String);
    function CheckPath(const APath: String): Boolean;
  end;

implementation

uses
    Data.DB
  , FMX.Dialogs
  , DBToolsUnit
  , DBExceptionContainerUnit
  ;

{ TDBAccess }

procedure TDBAccess.ShowExceptionMessage(
  const AMethod: String;
  const AE: Exception);
begin
  // Райзим эксепшн для вывода окна с сообщением, так универсальней
  raise Exception.Create(Concat(AMethod, ' -> ', AE.Message));
end;

procedure TDBAccess.CreateTable;
const
  METHOD = 'TDBAccess.CreateTable';
var
  Proc: TParamsProcRef;
begin
  Proc := (
    procedure(const AInParams: TParamsExt; const AOutParams: TParamsExt)
    var
      DBTools: TDBTools;
      SQLTemplateIdent: String;
      SQLTemplate: String;
    begin
      try
        SQLTemplateIdent := 'create_table';
        SQLTemplate := SQLTemplates.GetTemplate(SQLTemplateIdent);

        DBTools := TDBTools.Create(DBFileName);
        try
          DBTools.CreateQuery;
          DBTools.Query.ClearQuery;
          DBTools.Query.AddQuery(SQLTemplate);

          DBTools.StartTransaction;
          try
            DBTools.ExecuteQuery;
            DBTools.Commit;
          except
            DBTools.Rollback;
            raise;
          end;
        finally
          DBTools.FreeQuery;
          FreeAndNil(DBTools);
        end;

        AOutParams.Clear;
      except
        on e: Exception do
        begin
          raise TDBExceptionContainer.CreateExceptionContainer(e, METHOD);
        end;
      end;
    end
  );

  try
    DBAParamsFunc(Proc, nil, nil);
  except
    on e: Exception do
      ShowExceptionMessage(METHOD, e);
  end;
end;

procedure TDBAccess.SelectFromTable(const APath: String);
const
  METHOD = 'TDBAccess.SelectFromTable';
var
  Proc: TParamsProcRef;
  DBTools: TDBTools;
  SQLTemplateIdent: String;
  SQLTemplate: String;
  QueryResult: TDBQuery;
  InParams: TParamsExt;
  OutParams: TParamsExt;
begin
  Proc := (
    procedure(const AInParams: TParamsExt; const AOutParams: TParamsExt)
    begin
      try
        SQLTemplateIdent := 'select_from_table';
        SQLTemplate := SQLTemplates.GetTemplate(SQLTemplateIdent);
        if Length(Trim(SQLTemplate)) = 0 then
          raise Exception.
            Create(Format('SQL template "%s" not found or empty', [SQLTemplateIdent]));

        DBTools := TDBTools.Create(DBFileName);

        try
          DBTools.CreateQuery;
          DBTools.Query.ClearQuery;
          DBTools.Query.AddQuery(SQLTemplate);

          QueryResult := DBTools.OpenQuery;
          while not QueryResult.Eof do
          begin
            QueryResult.Next;
          end;
          DBTools.CloseQuery;
        finally
          DBTools.FreeQuery;
          FreeAndNil(DBTools);
        end;

        AOutParams.Clear;
      except
        on e: Exception do
        begin
          raise TDBExceptionContainer.CreateExceptionContainer(e, METHOD);
        end;
      end;
    end);

  try
    InParams := TParamsExt.Create;
    OutParams := TParamsExt.Create;
    try
      InParams.Add(APath, 'Path');

      DBAParamsFunc(Proc, InParams, OutParams);

      //Result := OutParams.AsBooleanByIdent['CheckResult'];
    finally
      FreeAndNil(OutParams);
      FreeAndNil(InParams);
    end;
  except
    on e: Exception do
      ShowExceptionMessage(METHOD, e);
  end;
end;

function TDBAccess.CheckPath(const APath: String): Boolean;
const
  METHOD = 'TDBAccess.CheckPath';
var
  Proc: TParamsProcRef;
  InParams: TParamsExt;
  OutParams: TParamsExt;
begin
  Result := false;

  Proc := (
    procedure(const AInParams: TParamsExt; const AOutParams: TParamsExt)
    var
      DBTools: TDBTools;
      SQLTemplateIdent: String;
      SQLTemplate: String;
      QueryResult: TDBQuery;
      CheckResult: Boolean;
      Path: String;
    begin
      try
        Path := InParams.AsStringByIdent['Path'];

        SQLTemplateIdent := 'check_path';
        SQLTemplate := SQLTemplates.GetTemplate(SQLTemplateIdent);

        DBTools := TDBTools.Create(DBFileName);

        try
          DBTools.CreateQuery;
          DBTools.Query.ClearQuery;
          DBTools.Query.AddQuery(SQLTemplate);
          DBTools.Query.AddParameterAsString(':path', Path);

          QueryResult := DBTools.OpenQuery;
          CheckResult := not QueryResult.IsEmpty;

          DBTools.CloseQuery;
        finally
          DBTools.FreeQuery;
          FreeAndNil(DBTools);
        end;

        AOutParams.Clear;
        AOutParams.Add(CheckResult, 'CheckResult');
      except
        on e: Exception do
        begin
          raise TDBExceptionContainer.CreateExceptionContainer(e, METHOD);
        end;
      end;
    end
  );

  try
    InParams := TParamsExt.Create;
    OutParams := TParamsExt.Create;
    try
      InParams.Add(APath, 'Path');

      DBAParamsFunc(Proc, InParams, OutParams);

      Result := OutParams.AsBooleanByIdent['CheckResult'];
    finally
      FreeAndNil(OutParams);
      FreeAndNil(InParams);
    end;
  except
    on e: Exception do
      ShowExceptionMessage(METHOD, e);
  end;
end;

end.
