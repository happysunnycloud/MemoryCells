unit DBAccessUnit;

interface

uses
    CellUnit
  , DBToolsUnit
  , SQLTemplatesUnit
  , MCParamsUnit
//  , CommonUnit
  ;

const
  NULL_ID = 0;
  TIME_OUT_SECONDS = 40;
  NULL_DATETIME = 0;

type
  TDBAResultCode = (rcFault = -1, rcOk = 0, rcFolderIsNotEmpty = 1); //DBA = D - data, B - base,  A - access
  TInOutParamsFuncRef = function(const AInParams: TParamsExt; const AOutParams: TParamsExt): TDBAResultCode of object;

  TCellType = class
  const
    ctFolder = 1;
    ctCell = 2;
  end;

  TDBAccess = class
  strict private
    class var FDBFileName: String;

    class var FSQLTemplates: TSQLTemplates;

    class function IntToBool(const AValue: Integer): Boolean;
  public
    class function DBAParamsFunc(
      const AParamsFuncRef: TInOutParamsFuncRef;
      const AInParams: TParamsExt;
      const AOutParams: TParamsExt): TDBAResultCode;

    class procedure Init(const ADBFileName: String; const ATemplatesDir: String);
    class procedure UnInit;

    class function Backup(const AInParams: TParamsExt; const AOutParams: TParamsExt): TDBAResultCode;

    class function LoadCatalog(const AInParams: TParamsExt; const AOutParams: TParamsExt): TDBAResultCode;
    class function LoadDestinationCatalog(const AInParams: TParamsExt; const AOutParams: TParamsExt): TDBAResultCode;
    class function LoadCell(const AInParams: TParamsExt; const AOutParams: TParamsExt): TDBAResultCode;
    class function LoadCellReminder(const AInParams: TParamsExt; const AOutParams: TParamsExt): TDBAResultCode;

    class function UpdateCell(const AInParams: TParamsExt; const AOutParams: TParamsExt): TDBAResultCode;
    class function InsertCell(const AInParams: TParamsExt; const AOutParams: TParamsExt): TDBAResultCode; //returning Cell.Id
    class function DeleteCell(const AInParams: TParamsExt; const AOutParams: TParamsExt): TDBAResultCode;

    class function UpdateFolder(const AInParams: TParamsExt; const AOutParams: TParamsExt): TDBAResultCode;
    class function InsertFolder(const AInParams: TParamsExt; const AOutParams: TParamsExt): TDBAResultCode;

    class function DeleteFolder(const AInParams: TParamsExt; const AOutParams: TParamsExt): TDBAResultCode;

    class function Search(const AInParams: TParamsExt; const AOutParams: TParamsExt): TDBAResultCode;
    class function CellsByIdList(const AInParams: TParamsExt; const AOutParams: TParamsExt): TDBAResultCode;

    class function UpdateCellAttributes(const AInParams: TParamsExt; const AOutParams: TParamsExt): TDBAResultCode;

    class function UpdateCellDestinationFolder(const AInParams: TParamsExt; const AOutParams: TParamsExt): TDBAResultCode;
    class function InsertDestinationCell(const AInParams: TParamsExt; const AOutParams: TParamsExt): TDBAResultCode;

    class function UpdateCellReminder(const AInParams: TParamsExt; const AOutParams: TParamsExt): TDBAResultCode;
  end;

  TSQLiteHelpmate = class
  public
    class function StrToDateTime(const AStr: String): TDateTime;
    class function DateTimeToStr(const ADateTime: TDateTime): String;
  end;

implementation

uses
    System.SysUtils
  , System.Generics.Collections
  , FireDAC.Stan.Error
  , FireDAC.Phys.SQLiteWrapper
  , ExceptionContainerUnit
  ;


class function TSQLiteHelpmate.StrToDateTime(const AStr: String): TDateTime;
var
  FormatSettings: TFormatSettings;
begin
  FormatSettings := TFormatSettings.Create;
  FormatSettings.DateSeparator := '-';
  FormatSettings.TimeSeparator := ':';
  FormatSettings.ShortDateFormat := 'YYYY-MM-DD';
  FormatSettings.ShortTimeFormat := 'HH:MM:SS';

  Result := System.SysUtils.StrToDateTime(AStr, FormatSettings);
end;

class function TSQLiteHelpmate.DateTimeToStr(const ADateTime: TDateTime): String;
  function _DigitAlign(const ADigit: Word): String;
  begin
    Result := ADigit.ToString;
    if Result.Length < 2 then
      Result := '0' + Result;
  end;
var
  //FormatSettings: TFormatSettings;
  Year, Month, Day: Word;
  Hour, Min, Sec, MSec: Word;
begin
  DecodeDate(ADateTime, Year, Month, Day);
  DecodeTime(ADateTime, Hour, Min, Sec, MSec);

  Result := Format('%s-%s-%s %s:%s:%s',
    [
      _DigitAlign(Year),
      _DigitAlign(Month),
      _DigitAlign(Day),
      _DigitAlign(Hour),
      _DigitAlign(Min),
      _DigitAlign(Sec)
      ])
end;

class function TDBAccess.IntToBool(const AValue: Integer): Boolean;
begin
  Result := false;

  if AValue > 0 then
    Result := true;
end;

class function TDBAccess.DBAParamsFunc(
  const AParamsFuncRef: TInOutParamsFuncRef;
  const AInParams: TParamsExt;
  const AOutParams: TParamsExt): TDBAResultCode;
const
  METHOD = 'TDBAccess.DBAParamsFunc';
var
  ParamsFuncRef: TInOutParamsFuncRef absolute AParamsFuncRef;
  InParams: TParamsExt;
  OutParams: TParamsExt;

  FDCommandExceptionKind: TFDCommandExceptionKind;
  DoExit: Boolean;
  TimeOutCount: Byte;
  MessageString: String;
begin
  Result := rcFault;

  InParams := TParamsExt.Create;
  OutParams := TParamsExt.Create;
  try
    InParams.CopyFrom(AInParams);

    TimeOutCount := TIME_OUT_SECONDS;

    DoExit := false;
    while not DoExit do
    begin
      try
        Result := ParamsFuncRef(InParams, OutParams);

        if Assigned(AOutParams) then
        begin
          AOutParams.Clear;
          AOutParams.CopyFrom(OutParams);
        end;

        DoExit := true;
      except
        on e: TExceptionContainer do
        begin
          MessageString :=
            Concat(METHOD, ': ', e._MethodName, ': ', e.ExceptionClass.ClassName, ': ', e._Message);
          if e.ExceptionClass = ESQLiteNativeException then
          begin
            FDCommandExceptionKind := e.Kind;
            MessageString := Concat(MessageString, ': ', FDCommandExceptionKind.ToString);
            if FDCommandExceptionKind = ekRecordLocked then
            begin
              Dec(TimeOutCount);

              if TimeOutCount = 0 then
              begin
                raise Exception.Create(MessageString);
              end;

              Sleep(1000);
            end;
          end;
          raise Exception.Create(MessageString);
        end;
        on e: Exception do
        begin
          MessageString := Concat(METHOD, ': ', e.ClassName, ': ', e.Message);
          raise Exception.Create(MessageString);
        end
        else
        begin
          MessageString := Concat(METHOD, ': ', 'Unknown exception');
          raise Exception.Create(MessageString);
        end;
      end;
    end;
  finally
    FreeAndNil(InParams);
    FreeAndNil(OutParams);
  end;
end;

class procedure TDBAccess.Init(const ADBFileName: String; const ATemplatesDir: String);
begin
  FDBFileName := ADBFileName;

  FSQLTemplates := TSQLTemplates.Create(ATemplatesDir);
end;

class procedure TDBAccess.UnInit;
begin
  FreeAndNil(FSQLTemplates);
end;

class function TDBAccess.Backup(const AInParams: TParamsExt; const AOutParams: TParamsExt): TDBAResultCode;
const
  METHOD = 'TDBAccess.Backup';
var
  DBTools: TDBTools;
  SQLTemplateIdent: String;
  SQLTemplate: String;
  BackupFileName: String;
begin
  try
    SQLTemplateIdent := 'backup';
    SQLTemplate := FSQLTemplates.GetTemplate(SQLTemplateIdent);
    if Length(Trim(SQLTemplate)) = 0 then
      raise Exception.Create(Format('SQL template "%s" not found or empty', [SQLTemplateIdent]));

    try
      DBTools := TDBTools.Create(FDBFileName);
    except
      raise;
    end;

    try
      BackupFileName := AInParams.AsString[0];

      DBTools.CreateQuery;

      DBTools.Query.AddQuery(SQLTemplate);
      DBTools.Query.AddParameterAsString(':backup_file_name', BackupFileName);

      DBTools.ExecuteQuery;

      // Коммит идет в конце скрипта
    finally
      DBTools.FreeQuery;
      FreeAndNil(DBTools);
    end;
  except
    on e: Exception do
    begin
      raise TExceptionContainer.CreateExceptionContainer(e, METHOD);
    end;
  end;

  Result := rcOk;
end;

class function TDBAccess.LoadCatalog(const AInParams: TParamsExt; const AOutParams: TParamsExt): TDBAResultCode;
const
  METHOD = 'TDBAccess.LoadCatalog';
var
  DBTools: TDBTools;
  CellList: TCellList;
  Cell: TCell;
  List: TInnerCellList;
  SQLTemplateIdent: String;
  SQLTemplate: String;
  QueryResult: TDBQuery;
  FolderId: Int64;
  Id: Int64;
begin
  try
    SQLTemplateIdent := 'get_catalog';
    SQLTemplate := FSQLTemplates.GetTemplate(SQLTemplateIdent);
    if Length(Trim(SQLTemplate)) = 0 then
      raise Exception.Create(Format('SQL template "%s" not found or empty', [SQLTemplateIdent]));

    try
      DBTools := TDBTools.Create(FDBFileName);
    except
      raise;
    end;

    CellList := TCellList.Create;
    try
      List := CellList.LockList;
      try
        FolderId := AInParams.AsInt64[0];

        DBTools.CreateQuery;

        DBTools.Query.AddQuery(SQLTemplate);
        DBTools.Query.AddParameterAsLargeInt(':folder_id', FolderId);

        QueryResult := DBTools.OpenQuery;

        while not QueryResult.Eof do
        begin
          Id := QueryResult.FindField('id').AsLargeInt;
          Cell := TCell.Create(
            Id,
            QueryResult.FindField('folder_id').AsLargeInt,
            QueryResult.FindField('cell_type_id').AsInteger);
          Cell.Name := QueryResult.FindField('name').AsString;
          Cell.Desc := QueryResult.FindField('description').AsString;
          Cell.IsDone := IntToBool(QueryResult.FindField('is_done').AsInteger);

          Cell.UpdateDateTime :=
            TSQLiteHelpmate.StrToDateTime(QueryResult.FindField('update_datetime').AsString);

          if Id = FolderId then
            Cell.Content := QueryResult.FindField('path').AsString;
  //          Cell.Name := QueryResult.FindField('path').AsString;

          List.Add(Cell);

          QueryResult.Next;
        end;
        DBTools.CloseQuery;
      finally
        CellList.UnLockList;
        DBTools.FreeQuery;
        FreeAndNil(DBTools);
      end;
      AOutParams.Clear;
      AOutParams.Add(CellList);
    finally
      FreeAndNil(CellList);
    end;
  except
    on e: Exception do
    begin
      raise TExceptionContainer.CreateExceptionContainer(e, METHOD);
    end;
  end;

  Result := rcOk;
end;

class function TDBAccess.LoadDestinationCatalog(const AInParams: TParamsExt; const AOutParams: TParamsExt): TDBAResultCode;
const
  METHOD = 'TDBAccess.LoadDestinationCatalog';
var
  DBTools: TDBTools;
  CellList: TCellList;
  Cell: TCell;
  List: TInnerCellList;
  SQLTemplateIdent: String;
  SQLTemplate: String;
  QueryResult: TDBQuery;
  FolderId: Int64;
  Id: Int64;
begin
  try
    SQLTemplateIdent := 'get_destination_catalog';
    SQLTemplate := FSQLTemplates.GetTemplate(SQLTemplateIdent);
    if Length(Trim(SQLTemplate)) = 0 then
      raise Exception.Create(Format('SQL template "%s" not found or empty', [SQLTemplateIdent]));

    try
      DBTools := TDBTools.Create(FDBFileName);
    except
      raise;
    end;

    CellList := TCellList.Create;
    try
      List := CellList.LockList;
      try
        FolderId := AInParams.AsInt64[0];

        DBTools.CreateQuery;

        DBTools.Query.AddQuery(SQLTemplate);
        DBTools.Query.AddParameterAsLargeInt(':folder_id', FolderId);

        QueryResult := DBTools.OpenQuery;

        while not QueryResult.Eof do
        begin
          Id := QueryResult.FindField('id').AsLargeInt;
          Cell := TCell.Create(
            Id,
            QueryResult.FindField('folder_id').AsLargeInt,
            QueryResult.FindField('cell_type_id').AsInteger);
          Cell.Name := QueryResult.FindField('name').AsString;
          Cell.Desc := QueryResult.FindField('description').AsString;
          Cell.IsDone := IntToBool(QueryResult.FindField('is_done').AsInteger);

          if Id = FolderId then
            Cell.Content := QueryResult.FindField('path').AsString;
  //          Cell.Name := QueryResult.FindField('path').AsString;

          List.Add(Cell);

          QueryResult.Next;
        end;
        DBTools.CloseQuery;
      finally
        CellList.UnLockList;
        DBTools.FreeQuery;
        FreeAndNil(DBTools);
      end;
      AOutParams.Clear;
      AOutParams.Add(CellList);
    finally
      FreeAndNil(CellList);
    end;
  except
    on e: Exception do
    begin
      raise TExceptionContainer.CreateExceptionContainer(e, METHOD);
    end;
  end;

  Result := rcOk;
end;

class function TDBAccess.LoadCell(const AInParams: TParamsExt; const AOutParams: TParamsExt): TDBAResultCode;
const
  METHOD = 'TDBAccess.LoadCell';
var
  DBTools: TDBTools;
  SQLTemplateIdent: String;
  SQLTemplate: String;
  QueryResult: TDBQuery;
  ReturnedRecordsCount: Byte;
  OutParams: TParamsExt;
  CellId: Int64;
  FolderId: Int64;
  Content: String;
  CellTypeId: Integer;
  CellIsDone: Boolean;
  CellUpdateDateTime: TDateTime;
  CellRemindDateTime: TDateTime;
  CellRemind: Boolean;
begin
  try
    SQLTemplateIdent := 'get_cell';
    SQLTemplate := FSQLTemplates.GetTemplate(SQLTemplateIdent);
    if Length(Trim(SQLTemplate)) = 0 then
      raise Exception.Create(Format('SQL template "%s" not found or empty', [SQLTemplateIdent]));

    try
      DBTools := TDBTools.Create(FDBFileName);
    except
      raise;
    end;

    try
      CellId := AInParams.AsInt64[0];

      DBTools.CreateQuery;

      DBTools.Query.AddQuery(SQLTemplate);
      DBTools.Query.AddParameterAsLargeInt(':id', CellId);

      QueryResult := DBTools.OpenQuery;

      if not Assigned(QueryResult) then
        raise Exception.Create('QueryResult is nil');

      CellId := NULL_ID;
      FolderId := NULL_ID;
      CellTypeId := NULL_ID;
      CellIsDone := false;
      CellUpdateDateTime := Now();
      CellRemindDateTime := 0;
      CellRemind := false;
      ReturnedRecordsCount := 0;
      while not QueryResult.Eof do
      begin
        CellId := QueryResult.FindField('id').AsLargeInt;
        FolderId := QueryResult.FindField('folder_id').AsLargeInt;
        Content := QueryResult.FindField('content').AsString;
        CellTypeId := QueryResult.FindField('cell_type_id').AsInteger;
        CellIsDone := QueryResult.FindField('is_done').AsBoolean;
        CellUpdateDateTime :=
          TSQLiteHelpmate.StrToDateTime(QueryResult.FindField('update_datetime').AsString);
        CellRemindDateTime :=
          TSQLiteHelpmate.StrToDateTime(QueryResult.FindField('remind_datetime').AsString);
        CellRemind := QueryResult.FindField('remind').AsBoolean;

        Inc(ReturnedRecordsCount);

        QueryResult.Next;
      end;
      DBTools.CloseQuery;
    finally
      DBTools.FreeQuery;
      FreeAndNil(DBTools);
    end;

    if ReturnedRecordsCount > 1 then
      raise Exception.Create('More than one record returned');

    OutParams := TParamsExt.Create;
    try
      OutParams.Clear;
      OutParams.Add(CellId);              {0}
      OutParams.Add(FolderId);            {1}
      OutParams.Add(Content);             {2}
      OutParams.Add(CellTypeId);          {3}
      OutParams.Add(CellIsDone);          {4}
      OutParams.Add(CellUpdateDateTime);  {5}
      OutParams.Add(CellRemindDateTime);  {6}
      OutParams.Add(CellRemind);          {7}

      AOutParams.Clear;
      AOutParams.CopyFrom(OutParams);
    finally
      FreeAndNil(OutParams);
    end;
  except
    on e: Exception do
    begin
      raise TExceptionContainer.CreateExceptionContainer(e, METHOD);
    end;
  end;

  Result := rcOk;
end;

class function TDBAccess.LoadCellReminder(const AInParams: TParamsExt; const AOutParams: TParamsExt): TDBAResultCode;
const
  METHOD = 'TDBAccess.LoadCellReminder';
var
  DBTools: TDBTools;
  SQLTemplateIdent: String;
  SQLTemplate: String;
  QueryResult: TDBQuery;
  ReturnedRecordsCount: Byte;
  OutParams: TParamsExt;
  CellId: Int64;
  FolderId: Int64;
  Content: String;
  CellTypeId: Integer;
  CellIsDone: Boolean;
  CellUpdateDateTime: TDateTime;
  CellRemindDateTime: TDateTime;
  CellRemind: Boolean;
begin
  try
    SQLTemplateIdent := 'get_cell_reminder';
    SQLTemplate := FSQLTemplates.GetTemplate(SQLTemplateIdent);
    if Length(Trim(SQLTemplate)) = 0 then
      raise Exception.Create(Format('SQL template "%s" not found or empty', [SQLTemplateIdent]));

    try
      DBTools := TDBTools.Create(FDBFileName);
    except
      raise;
    end;

    try
      DBTools.CreateQuery;

      DBTools.Query.AddQuery(SQLTemplate);

      QueryResult := DBTools.OpenQuery;

      if not Assigned(QueryResult) then
        raise Exception.Create('QueryResult is nil');

      CellId := NULL_ID;
      FolderId := NULL_ID;
      CellTypeId := NULL_ID;
      CellIsDone := false;
      CellUpdateDateTime := Now();
      CellRemindDateTime := 0;
      CellRemind := false;
      ReturnedRecordsCount := 0;
      while not QueryResult.Eof do
      begin
        CellId := QueryResult.FindField('id').AsLargeInt;
        FolderId := QueryResult.FindField('folder_id').AsLargeInt;
        Content := QueryResult.FindField('content').AsString;
        CellTypeId := QueryResult.FindField('cell_type_id').AsInteger;
        CellIsDone := QueryResult.FindField('is_done').AsBoolean;
        CellUpdateDateTime :=
          TSQLiteHelpmate.StrToDateTime(QueryResult.FindField('update_datetime').AsString);
        CellRemindDateTime :=
          TSQLiteHelpmate.StrToDateTime(QueryResult.FindField('remind_datetime').AsString);
        CellRemind := QueryResult.FindField('remind').AsBoolean;

        Inc(ReturnedRecordsCount);

        QueryResult.Next;
      end;
      DBTools.CloseQuery;
    finally
      DBTools.FreeQuery;
      FreeAndNil(DBTools);
    end;

    if ReturnedRecordsCount > 1 then
      raise Exception.Create('More than one record returned');

    OutParams := TParamsExt.Create;
    try
      OutParams.Clear;
      OutParams.Add(CellId);              {0}
      OutParams.Add(FolderId);            {1}
      OutParams.Add(Content);             {2}
      OutParams.Add(CellTypeId);          {3}
      OutParams.Add(CellIsDone);          {4}
      OutParams.Add(CellUpdateDateTime);  {5}
      OutParams.Add(CellRemindDateTime);  {6}
      OutParams.Add(CellRemind);          {7}

      AOutParams.Clear;
      AOutParams.CopyFrom(OutParams);
    finally
      FreeAndNil(OutParams);
    end;
  except
    on e: Exception do
    begin
      raise TExceptionContainer.CreateExceptionContainer(e, METHOD);
    end;
  end;

  Result := rcOk;
end;

class function TDBAccess.UpdateCell(const AInParams: TParamsExt; const AOutParams: TParamsExt): TDBAResultCode;
const
  METHOD = 'TDBAccess.UpdateCell';
var
  DBTools: TDBTools;
  SQLTemplateIdent: String;
  SQLTemplate: String;

  CellId: Int64;
  CellContent: String;
  CellDesc: String;
  CellRemindDateTime: TDateTime;
  CellRemind: Boolean;
begin
  try
    SQLTemplateIdent := 'update_cell';
    SQLTemplate := FSQLTemplates.GetTemplate(SQLTemplateIdent);
    if Length(Trim(SQLTemplate)) = 0 then
      raise Exception.Create(Format('SQL template "%s" not found or empty', [SQLTemplateIdent]));

    try
      DBTools := TDBTools.Create(FDBFileName);
    except
      raise;
    end;

    try
      CellId := AInParams.AsInt64[0];
      CellContent := AInParams.AsString[1];
      CellDesc := AInParams.AsString[2];
      CellRemindDateTime := AInParams.AsDateTime[3];
      CellRemind := AInParams.AsBoolean[4];

      DBTools.CreateQuery;

      DBTools.Query.ClearQuery;
      DBTools.Query.AddQuery(SQLTemplate);

      DBTools.Query.AddParameterAsLargeInt(':id', CellId);
      DBTools.Query.AddParameterAsString(':content', CellContent);
      DBTools.Query.AddParameterAsString(':description', CellDesc);
      DBTools.Query.AddParameterAsString(':remind_datetime',
        TSQLiteHelpmate.DateTimeToStr(CellRemindDateTime));
      DBTools.Query.AddParameterAsBoolean(':remind', CellRemind);

      DBTools.FDConnection.StartTransaction;
      try
        DBTools.ExecuteQuery;
        DBTools.FDConnection.Commit;
      except
        DBTools.FDConnection.Rollback;
        raise;
      end;
    finally
      DBTools.FreeQuery;
      FreeAndNil(DBTools);
    end;
  except
    on e: Exception do
    begin
      raise TExceptionContainer.CreateExceptionContainer(e, METHOD);
    end;
  end;

  Result := rcOk;
end;

class function TDBAccess.InsertCell(const AInParams: TParamsExt; const AOutParams: TParamsExt): TDBAResultCode;
const
  METHOD = 'TDBAccess.InsertCell';
var
  DBTools: TDBTools;
  SQLTemplateIdent: String;
  SQLTemplate: String;
  QueryResult: TDBQuery;
  ReturnedRecordsCount: Byte;
  OutParams: TParamsExt;
  FolderId: Int64;
  CellId: Int64;
  CellTypeId: Integer;
begin
  try
    SQLTemplateIdent := 'insert_cell';
    SQLTemplate := FSQLTemplates.GetTemplate(SQLTemplateIdent);
    if Length(Trim(SQLTemplate)) = 0 then
      raise Exception.Create(Format('SQL template "%s" not found or empty', [SQLTemplateIdent]));

    try
      DBTools := TDBTools.Create(FDBFileName);
    except
      raise;
    end;

    try
      FolderId := AInParams.AsInt64[0];

      try
        DBTools.CreateQuery;

        DBTools.Query.ClearQuery;
        DBTools.Query.AddQuery(SQLTemplate);
        DBTools.Query.AddParameterAsLargeInt(':folder_id', FolderId);

        DBTools.FDConnection.StartTransaction;
        DBTools.ExecuteQuery;

        DBTools.Query.ClearQuery;
        DBTools.Query.AddQuery('select LAST_INSERT_ROWID() as id');

        QueryResult := DBTools.OpenQuery;

        if not Assigned(QueryResult) then
          raise Exception.Create('QueryResult is nil');

        CellId := NULL_ID;
        ReturnedRecordsCount := 0;
        while not QueryResult.Eof do
        begin
          CellId := QueryResult.FindField('id').AsLargeInt;

          Inc(ReturnedRecordsCount);

          QueryResult.Next;
        end;
        DBTools.CloseQuery;

        if ReturnedRecordsCount > 1 then
          raise Exception.Create('More than one record returned');

        DBTools.FDConnection.Commit;
      except
        DBTools.FDConnection.Rollback;

        raise;
      end;
    finally
      DBTools.FreeQuery;
      FreeAndNil(DBTools);
    end;

    CellTypeId := TCellType.ctCell;

    OutParams := TParamsExt.Create;
    try
      OutParams.Clear;
      OutParams.Add(CellId);
      OutParams.Add(FolderId);
      OutParams.Add(CellTypeId);

      AOutParams.Clear;
      AOutParams.CopyFrom(OutParams);
    finally
      FreeAndNil(OutParams);
    end;
  except
    on e: Exception do
    begin
      raise TExceptionContainer.CreateExceptionContainer(e, METHOD);
    end;
  end;

  Result := rcOk;
end;

class function TDBAccess.DeleteCell(const AInParams: TParamsExt; const AOutParams: TParamsExt): TDBAResultCode;
const
  METHOD = 'TDBAccess.DeleteCell';
var
  CellId: Int64;
  DBTools: TDBTools;
  SQLTemplateIdent: String;
  SQLTemplate: String;
begin
  try
    SQLTemplateIdent := 'delete_cell';
    SQLTemplate := FSQLTemplates.GetTemplate(SQLTemplateIdent);
    if Length(Trim(SQLTemplate)) = 0 then
      raise Exception.Create(Format('SQL template "%s" not found or empty', [SQLTemplateIdent]));

    try
      DBTools := TDBTools.Create(FDBFileName);
    except
      raise;
    end;

    try
      CellId := AInParams.AsInt64[0];

      DBTools.CreateQuery;

      DBTools.Query.ClearQuery;
      DBTools.Query.AddQuery(SQLTemplate);

      DBTools.Query.AddParameterAsLargeInt(':id', CellId);

      DBTools.FDConnection.StartTransaction;
      try
        DBTools.ExecuteQuery;
        DBTools.FDConnection.Commit;
      except
        DBTools.FDConnection.Rollback;

        raise;
      end;
    finally
      DBTools.FreeQuery;
      FreeAndNil(DBTools);
    end;
  except
    on e: Exception do
    begin
      raise TExceptionContainer.CreateExceptionContainer(e, METHOD);
    end;
  end;

  Result := rcOk;
end;

class function TDBAccess.UpdateFolder(const AInParams: TParamsExt; const AOutParams: TParamsExt): TDBAResultCode;
const
  METHOD = 'TDBAccess.UpdateFolder';
var
  DBTools: TDBTools;
  SQLTemplateIdent: String;
  SQLTemplate: String;
  SQLFolderPathTemplate: String;
  FolderPath: String;
  ReturnedRecordsCount: Word;
  QueryResult: TDBQuery;
  FolderId: Int64;
  FolderName: String;
begin
  try
    SQLTemplateIdent := 'update_folder';
    SQLTemplate := FSQLTemplates.GetTemplate(SQLTemplateIdent);
    if Length(Trim(SQLTemplate)) = 0 then
      raise Exception.Create(Format('SQL template "%s" not found or empty', [SQLTemplateIdent]));

    SQLTemplateIdent := 'get_folder_path';
    SQLFolderPathTemplate := FSQLTemplates.GetTemplate(SQLTemplateIdent);
    if Length(Trim(SQLFolderPathTemplate)) = 0 then
      raise Exception.Create(Format('SQL template "%s" not found or empty', [SQLTemplateIdent]));

    try
      DBTools := TDBTools.Create(FDBFileName);
    except
      raise;
    end;

    try
      FolderId := AInParams.AsInt64[0];
      FolderName := AInParams.AsString[1];

      DBTools.CreateQuery;

      DBTools.Query.ClearQuery;
      DBTools.Query.AddQuery(SQLTemplate);

      DBTools.Query.AddParameterAsLargeInt(':id', FolderId);
      DBTools.Query.AddParameterAsString(':name', FolderName);

      DBTools.FDConnection.StartTransaction;
      try
        DBTools.ExecuteQuery;
        DBTools.FDConnection.Commit;
      except
        DBTools.FDConnection.Rollback;

        raise;
      end;

      DBTools.Query.ClearQuery;
      DBTools.Query.AddQuery(SQLFolderPathTemplate);

      DBTools.Query.AddParameterAsLargeInt(':id', FolderId);

      QueryResult := DBTools.OpenQuery;

      if not Assigned(QueryResult) then
        raise Exception.Create('QueryResult is nil');

      FolderPath := '';
      ReturnedRecordsCount := 0;
      while not QueryResult.Eof do
      begin
        FolderName := QueryResult.FindField('name').AsString;
        FolderPath := QueryResult.FindField('path').AsString;

        Inc(ReturnedRecordsCount);

        QueryResult.Next;
      end;
      DBTools.CloseQuery;

      if ReturnedRecordsCount > 1 then
        raise Exception.Create('More than one record returned');

      AOutParams.Clear;
      AOutParams.Add(FolderId);
      AOutParams.Add(FolderName);
      AOutParams.Add(FolderPath);
    finally
      DBTools.FreeQuery;
      FreeAndNil(DBTools);
    end;
  except
    on e: Exception do
    begin
      raise TExceptionContainer.CreateExceptionContainer(e, METHOD);
    end;
  end;

  Result := rcOk;
end;

class function TDBAccess.InsertFolder(const AInParams: TParamsExt; const AOutParams: TParamsExt): TDBAResultCode;
const
  METHOD = 'TDBAccess.InsertFolder';
var
  DBTools: TDBTools;
  SQLTemplateIdent: String;
  SQLTemplate: String;
  QueryResult: TDBQuery;
  ReturnedRecordsCount: Word;
  OutParams: TParamsExt;
  ParentFolderId: Int64;
  FolderName: String;
  FolderId: Int64;
  CellTypeId: Integer;
begin
  try
    SQLTemplateIdent := 'insert_folder';
    SQLTemplate := FSQLTemplates.GetTemplate(SQLTemplateIdent);
    if Length(Trim(SQLTemplate)) = 0 then
      raise Exception.Create(Format('SQL template "%s" not found or empty', [SQLTemplateIdent]));

    try
      DBTools := TDBTools.Create(FDBFileName);
    except
      raise;
    end;

    try
      ParentFolderId := AInParams.AsInt64[0];
      FolderName := AInParams.AsString[1];

      DBTools.CreateQuery;

      DBTools.Query.ClearQuery;
      DBTools.Query.AddQuery(SQLTemplate);
      DBTools.Query.AddParameterAsLargeInt(':folder_id', ParentFolderId);
      DBTools.Query.AddParameterAsString(':name', FolderName);

      DBTools.FDConnection.StartTransaction;
      try
        DBTools.ExecuteQuery;

        DBTools.Query.ClearQuery;
        DBTools.Query.AddQuery('select LAST_INSERT_ROWID() as id');

        QueryResult := DBTools.OpenQuery;

        if not Assigned(QueryResult) then
          raise Exception.Create('QueryResult is nil');

        FolderId := NULL_ID;
        ReturnedRecordsCount := 0;
        while not QueryResult.Eof do
        begin
          FolderId := QueryResult.FindField('id').AsLargeInt;

          Inc(ReturnedRecordsCount);

          QueryResult.Next;
        end;
        DBTools.CloseQuery;

        if ReturnedRecordsCount > 1 then
          raise Exception.Create('More than one record returned');

        DBTools.FDConnection.Commit;
      except
        DBTools.FDConnection.Rollback;

        raise;
      end;
    finally
      DBTools.FreeQuery;
      FreeAndNil(DBTools);
    end;

    CellTypeId := TCellType.ctFolder;

    OutParams := TParamsExt.Create;
    try
      OutParams.Clear;
      OutParams.Add(FolderId);
      OutParams.Add(ParentFolderId);
      OutParams.Add(CellTypeId);
      OutParams.Add(FolderName);

      AOutParams.Clear;
      AOutParams.CopyFrom(OutParams);
    finally
      FreeAndNil(OutParams);
    end;
  except
    on e: Exception do
    begin
      raise TExceptionContainer.CreateExceptionContainer(e, METHOD);
    end;
  end;

  Result := rcOk;
end;

class function TDBAccess.DeleteFolder(const AInParams: TParamsExt; const AOutParams: TParamsExt): TDBAResultCode;
const
  METHOD = 'TDBAccess.DeleteFolder';
var
  FolderId: Int64;
  DBTools: TDBTools;
  SQLTemplateIdent: String;
  SQLGetFolderContentsCountTemplate: String;
  SQLDeleteFolderTemplate: String;
  ReturnedRecordsCount: Word;
  QueryResult: TDBQuery;
  FolderContentsCount: Word;
begin
  try
    SQLTemplateIdent := 'get_folder_contents_count';
    SQLGetFolderContentsCountTemplate := FSQLTemplates.GetTemplate(SQLTemplateIdent);
    if Length(Trim(SQLGetFolderContentsCountTemplate)) = 0 then
      raise Exception.Create(Format('SQL template "%s" not found or empty', [SQLTemplateIdent]));

    SQLTemplateIdent := 'delete_folder';
    SQLDeleteFolderTemplate := FSQLTemplates.GetTemplate(SQLTemplateIdent);
    if Length(Trim(SQLGetFolderContentsCountTemplate)) = 0 then
      raise Exception.Create(Format('SQL template "%s" not found or empty', [SQLTemplateIdent]));

    try
      DBTools := TDBTools.Create(FDBFileName);
    except
      raise;
    end;

    try
      FolderId := AInParams.AsInt64[0];

      DBTools.CreateQuery;

      DBTools.Query.ClearQuery;
      DBTools.Query.AddQuery(SQLGetFolderContentsCountTemplate);

      DBTools.Query.AddParameterAsLargeInt(':folder_id', FolderId);

      QueryResult := DBTools.OpenQuery;

      if not Assigned(QueryResult) then
        raise Exception.Create('QueryResult is nil');

      FolderContentsCount := 0;
      ReturnedRecordsCount := 0;
      while not QueryResult.Eof do
      begin
        FolderContentsCount := QueryResult.FindField('folder_contents_count').AsLargeInt;

        Inc(ReturnedRecordsCount);

        QueryResult.Next;
      end;
      DBTools.CloseQuery;

      if ReturnedRecordsCount > 1 then
        raise Exception.Create('More than one record returned');

      if FolderContentsCount > 0 then
        Exit(rcFolderIsNotEmpty);

      DBTools.Query.ClearQuery;
      DBTools.Query.AddQuery(SQLDeleteFolderTemplate);

      DBTools.Query.AddParameterAsLargeInt(':id', FolderId);

      DBTools.FDConnection.StartTransaction;
      try
        DBTools.ExecuteQuery;
        DBTools.FDConnection.Commit;
      except
        DBTools.FDConnection.Rollback;

        raise;
      end;
    finally
      DBTools.FreeQuery;
      FreeAndNil(DBTools);
    end;
  except
    on e: Exception do
    begin
      raise TExceptionContainer.CreateExceptionContainer(e, METHOD);
    end;
  end;

  Result := rcOk;
end;

class function TDBAccess.Search(const AInParams: TParamsExt; const AOutParams: TParamsExt): TDBAResultCode;
const
  METHOD = 'TDBAccess.Search';
var
  DBTools: TDBTools;
  CellList: TCellList;
  List: TInnerCellList;
  SQLTemplateIdent: String;
  SQLTemplate: String;
  QueryResult: TDBQuery;
  FolderId: Int64;
  CellId: Int64;
  Folder: TCell;
  SearchText: String;
begin
  try
    SQLTemplateIdent := 'search';
    SQLTemplate := FSQLTemplates.GetTemplate(SQLTemplateIdent);
    if Length(Trim(SQLTemplate)) = 0 then
      raise Exception.Create(Format('SQL template "%s" not found or empty', [SQLTemplateIdent]));

    try
      DBTools := TDBTools.Create(FDBFileName);
    except
      raise;
    end;

    CellList := TCellList.Create;
    try
      List := CellList.LockList;
      try
        SearchText := AInParams.AsString[0];

        DBTools.CreateQuery;

        DBTools.Query.AddQuery(SQLTemplate);
        DBTools.Query.AddParameterAsString(':search_text', '%' + SearchText.ToUpper + '%');

        QueryResult := DBTools.OpenQuery;

        while not QueryResult.Eof do
        begin
          FolderId := QueryResult.FindField('id').AsLargeInt;
          Folder := List.GetByCellId(FolderId);
          if not Assigned(Folder) then
          begin
            Folder := TCell.Create(
              FolderId,
              QueryResult.FindField('folder_id').AsLargeInt,
              QueryResult.FindField('cell_type_id').AsInteger);
            Folder.Name := QueryResult.FindField('name').AsString;
            List.Add(Folder);
          end;

          CellId := QueryResult.FindField('cell_id').AsLargeInt;
          Folder.LinkedCellIdList.Add(CellId);

          QueryResult.Next;
        end;
        DBTools.CloseQuery;
      finally
        CellList.UnLockList;
        DBTools.FreeQuery;
        FreeAndNil(DBTools);
      end;
      AOutParams.Clear;
      AOutParams.Add(CellList);
    finally
      FreeAndNil(CellList);
    end;
  except
    on e: Exception do
    begin
      raise TExceptionContainer.CreateExceptionContainer(e, METHOD);
    end;
  end;

  Result := rcOk;
end;

class function TDBAccess.CellsByIdList(const AInParams: TParamsExt; const AOutParams: TParamsExt): TDBAResultCode;
const
  METHOD = 'TDBAccess.CellsByIdList';
var
  DBTools: TDBTools;
  CellList: TCellList;
  Cell: TCell;
  List: TInnerCellList;
  SQLTemplateIdent: String;
  SQLTemplate: String;
  QueryResult: TDBQuery;
  CellIdListString: String;
begin
  try
    SQLTemplateIdent := 'get_cells_by_id_list';
    SQLTemplate := FSQLTemplates.GetTemplate(SQLTemplateIdent);
    if Length(Trim(SQLTemplate)) = 0 then
      raise Exception.Create(Format('SQL template "%s" not found or empty', [SQLTemplateIdent]));

    try
      DBTools := TDBTools.Create(FDBFileName);
    except
      raise;
    end;

    CellList := TCellList.Create;
    try
      List := CellList.LockList;
      try
        CellIdListString := TCellIdList(AInParams.AsPointer[0]).ToString;

        DBTools.CreateQuery;

        DBTools.Query.AddQuery(SQLTemplate);
        DBTools.Query.AddParameterAsString(':cell_id_list', CellIdListString, false);

        QueryResult := DBTools.OpenQuery;

        while not QueryResult.Eof do
        begin
          Cell := TCell.Create(
            QueryResult.FindField('id').AsLargeInt,
            QueryResult.FindField('folder_id').AsLargeInt,
            QueryResult.FindField('cell_type_id').AsInteger);
          Cell.Name := QueryResult.FindField('name').AsString;
          Cell.Desc := QueryResult.FindField('description').AsString;
          Cell.IsDone := QueryResult.FindField('is_done').AsBoolean;
          List.Add(Cell);

          QueryResult.Next;
        end;
        DBTools.CloseQuery;
      finally
        CellList.UnLockList;
        DBTools.FreeQuery;
        FreeAndNil(DBTools);
      end;
      AOutParams.Clear;
      AOutParams.Add(CellList);
    finally
      FreeAndNil(CellList);
    end;
  except
    on e: Exception do
    begin
      raise TExceptionContainer.CreateExceptionContainer(e, METHOD);
    end;
  end;

  Result := rcOk;
end;

class function TDBAccess.UpdateCellAttributes(const AInParams: TParamsExt; const AOutParams: TParamsExt): TDBAResultCode;
const
  METHOD = 'TDBAccess.UpdateCellAttributes';
var
  DBTools: TDBTools;
  SQLTemplateIdent: String;
  SQLTemplate: String;

  CellId: Int64;
  CellIsDone: Boolean;
begin
  try
    SQLTemplateIdent := 'update_cell_attributes';
    SQLTemplate := FSQLTemplates.GetTemplate(SQLTemplateIdent);
    if Length(Trim(SQLTemplate)) = 0 then
      raise Exception.Create(Format('SQL template "%s" not found or empty', [SQLTemplateIdent]));

    try
      DBTools := TDBTools.Create(FDBFileName);
    except
      raise;
    end;

    try
      CellId := AInParams.AsInt64[0];
      CellIsDone := AInParams.AsBoolean[1];

      DBTools.CreateQuery;

      DBTools.Query.ClearQuery;
      DBTools.Query.AddQuery(SQLTemplate);

      DBTools.Query.AddParameterAsLargeInt(':id', CellId);
      DBTools.Query.AddParameterAsBoolean(':is_done', CellIsDone);

      DBTools.FDConnection.StartTransaction;
      try
        DBTools.ExecuteQuery;
        DBTools.FDConnection.Commit;
      except
        DBTools.FDConnection.Rollback;

        raise;
      end;
    finally
      DBTools.FreeQuery;
      FreeAndNil(DBTools);
    end;
  except
    on e: Exception do
    begin
      raise TExceptionContainer.CreateExceptionContainer(e, METHOD);
    end;
  end;

  Result := rcOk;
end;

class function TDBAccess.UpdateCellDestinationFolder(const AInParams: TParamsExt; const AOutParams: TParamsExt): TDBAResultCode;
const
  METHOD = 'TDBAccess.UpdateCellDestinationFolder';
var
  DBTools: TDBTools;
  SQLTemplateIdent: String;
  SQLTemplate: String;
  CellIdList: TCellIdList;
  IdList: TList<Int64>;
  CellId: Int64;
  FolderId: Int64;
begin
  try
    SQLTemplateIdent := 'update_cell_destination_folder';
    SQLTemplate := FSQLTemplates.GetTemplate(SQLTemplateIdent);
    if Length(Trim(SQLTemplate)) = 0 then
      raise Exception.Create(Format('SQL template "%s" not found or empty', [SQLTemplateIdent]));

    try
      DBTools := TDBTools.Create(FDBFileName);
    except
      raise;
    end;

    try
      FolderId := AInParams.AsInt64[0];
      CellIdList := AInParams.AsPointer[1];

      IdList := CellIdList.LockList;
      try
        DBTools.CreateQuery;

        DBTools.FDConnection.StartTransaction;
        try
          for CellId in IdList do
          begin
            DBTools.Query.ClearQuery;
            DBTools.Query.AddQuery(SQLTemplate);

            DBTools.Query.AddParameterAsLargeInt(':id', CellId);
            DBTools.Query.AddParameterAsLargeInt(':folder_id', FolderId);

            DBTools.ExecuteQuery;
          end;
          DBTools.FDConnection.Commit;
        except
          DBTools.FDConnection.Rollback;

          raise;
        end;
      finally
        CellIdList.UnLockList;
      end;
    finally
      DBTools.FreeQuery;
      FreeAndNil(DBTools);
    end;
  except
    on e: Exception do
    begin
      raise TExceptionContainer.CreateExceptionContainer(e, METHOD);
    end;
  end;

  Result := rcOk;
end;

class function TDBAccess.InsertDestinationCell(const AInParams: TParamsExt; const AOutParams: TParamsExt): TDBAResultCode;
const
  METHOD = 'TDBAccess.InsertDestinationCell';
var
  DBTools: TDBTools;
  SQLTemplateIdent: String;
  SQLTemplate: String;
  CellIdList: TCellIdList;
  IdList: TList<Int64>;
  CellId: Int64;
  FolderId: Int64;
begin
  try
    SQLTemplateIdent := 'insert_destination_cell';
    SQLTemplate := FSQLTemplates.GetTemplate(SQLTemplateIdent);
    if Length(Trim(SQLTemplate)) = 0 then
      raise Exception.Create(Format('SQL template "%s" not found or empty', [SQLTemplateIdent]));

    try
      DBTools := TDBTools.Create(FDBFileName);
    except
      raise;
    end;

    try
      FolderId := AInParams.AsInt64[0];
      CellIdList := AInParams.AsPointer[1];

      IdList := CellIdList.LockList;
      try
        DBTools.CreateQuery;

        DBTools.FDConnection.StartTransaction;
        try
          for CellId in IdList do
          begin
            DBTools.Query.ClearQuery;
            DBTools.Query.AddQuery(SQLTemplate);

            DBTools.Query.AddParameterAsLargeInt(':id', CellId);
            DBTools.Query.AddParameterAsLargeInt(':folder_id', FolderId);

            DBTools.ExecuteQuery;
          end;
          DBTools.FDConnection.Commit;
        except
          DBTools.FDConnection.Rollback;

          raise;
        end;
      finally
        CellIdList.UnLockList;
      end;
    finally
      DBTools.FreeQuery;
      FreeAndNil(DBTools);
    end;
  except
    on e: Exception do
    begin
      raise TExceptionContainer.CreateExceptionContainer(e, METHOD);
    end;
  end;

  Result := rcOk;
end;

class function TDBAccess.UpdateCellReminder(const AInParams: TParamsExt; const AOutParams: TParamsExt): TDBAResultCode;
const
  METHOD = 'TDBAccess.UpdateCellReminder';
var
  DBTools: TDBTools;
  SQLTemplateIdent: String;
  SQLTemplate: String;

  CellId: Int64;
  CellRemidDateTime: TDateTime;
begin
  try
    SQLTemplateIdent := 'update_cell_reminder';
    SQLTemplate := FSQLTemplates.GetTemplate(SQLTemplateIdent);
    if Length(Trim(SQLTemplate)) = 0 then
      raise Exception.Create(Format('SQL template "%s" not found or empty', [SQLTemplateIdent]));

    try
      DBTools := TDBTools.Create(FDBFileName);
    except
      raise;
    end;

    try
      CellId := AInParams.AsInt64[0];
      CellRemidDateTime := AInParams.AsDateTime[1];

      DBTools.CreateQuery;

      DBTools.Query.ClearQuery;
      DBTools.Query.AddQuery(SQLTemplate);

      DBTools.Query.AddParameterAsLargeInt(':id', CellId);
      DBTools.Query.AddParameterAsString(':remind_datetime',
        TSQLiteHelpmate.DateTimeToStr(CellRemidDateTime));

      DBTools.FDConnection.StartTransaction;
      try
        DBTools.ExecuteQuery;
        DBTools.FDConnection.Commit;
      except
        DBTools.FDConnection.Rollback;

        raise;
      end;
    finally
      DBTools.FreeQuery;
      FreeAndNil(DBTools);
    end;
  except
    on e: Exception do
    begin
      raise TExceptionContainer.CreateExceptionContainer(e, METHOD);
    end;
  end;

  Result := rcOk;
end;

end.

