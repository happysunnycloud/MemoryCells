unit ServerRepliesParserUnit;

interface

uses
    System.SysUtils

  , TransportContainerUnit
  , ParamsExtUnit
  ;
type
  TServerRepliesParser = class
  strict private
    class procedure RaiseException(
      const AMethod: String;
      const AE: Exception);
  public

    class procedure LoadCatalog(
      const ATransportContainer: TTransportContainer;
      const AFoldersParams: TParamsExt;
      const ACellParams: TParamsExt);
  end;

implementation

uses
    UTServerReplyUnit
  , CellUnit
  ;

class procedure TServerRepliesParser.RaiseException(
  const AMethod: String;
  const AE: Exception);
var
  ExceptionMessage: String;
begin
  ExceptionMessage := ClassName + '.' + AMethod + ' -> ' + AE.Message;
  raise Exception.Create(ExceptionMessage);
end;

class procedure TServerRepliesParser.LoadCatalog(
  const ATransportContainer: TTransportContainer;
  const AFoldersParams: TParamsExt;
  const ACellParams: TParamsExt);
var
  TC: TTransportContainer absolute ATransportContainer;
  FoldersParams: TParamsExt absolute AFoldersParams;
  CellParams: TParamsExt absolute ACellParams;
const
  METHOD = 'LoadCatalog';
var
  FolderId: Int64;
  i: Word;
  RecordsCount: Word;
  CellList: TCellList;
  Cell: TCell;
  CellId: Int64;
  CellContent: String;
  CellTypeId: Integer;
  CellIsDone: Boolean;
begin
  try
    TC.SetZeroPosition;

    TC.ReadAsInteger; //ReplyCommand
    FolderId      := TC.ReadAsInt64;
    RecordsCount  := TC.ReadAsWord;

    CellList := TCellList.Create;
    try
      //*** Folders ***//
      i := 0;
      while i < RecordsCount do
      begin
        Cell := TCell.Create;

        Cell.Id         := TC.ReadAsInt64;
        Cell.FolderId   := TC.ReadAsInt64;
        Cell.Name       := TC.ReadAsString;
        Cell.Desc       := TC.ReadAsString;
        Cell.Content    := TC.ReadAsString;
        Cell.CellTypeId := TC.ReadAsInteger;
        Cell.IsDone     := TC.ReadAsBoolean;

        CellList.Add(Cell);

        Inc(i);
      end;

      FoldersParams.Clear;
      FoldersParams.Add(FolderId);
      FoldersParams.Add(CellList);

      //*** Cell ***//
      CellId      := TC.ReadAsInt64;
      FolderId    := TC.ReadAsInt64;
      CellContent := TC.ReadAsString;
      CellTypeId  := TC.ReadAsInteger;
      CellIsDone  := TC.ReadAsBoolean;

      CellParams.Clear;
      CellParams.Add(CellId);
      CellParams.Add(FolderId);
      CellParams.Add(CellContent);
      CellParams.Add(CellTypeId);
      CellParams.Add(CellIsDone);
    finally
      FreeAndNil(CellList);
    end;
  except
    on e: Exception do
      RaiseException(METHOD, e);
  end;
end;

end.
