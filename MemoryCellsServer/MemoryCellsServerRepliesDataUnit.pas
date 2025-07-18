unit MemoryCellsServerRepliesDataUnit;

interface

uses
    MCParamsUnit
  , TransportContainerUnit
  ;

type
  TServerReplies = class
    class procedure LoadCatalog(
      const AInParams: TParamsExt;
      var ATransportContainer: TTransportContainer);
  end;

implementation

uses
    System.SysUtils
  , UTServerUnit
  , DBAccessUnit
  , UTServerReplyUnit
  , CellUnit
  ;

class procedure TServerReplies.LoadCatalog(
  const AInParams: TParamsExt;
  var ATransportContainer: TTransportContainer);
const
  METHOD = 'TServerReplies.LoadCatalog';
var
  TC: TTransportContainer absolute ATransportContainer;
  FolderId: Int64;
  CellList: TCellList;
  Cell: TCell;
  List: TInnerCellList;
  InParams: TParamsExt;
  OutParams: TParamsExt;
  RecordsCount: Word;
  i: Word;
  CellId: Int64;
  CellContent: String;
  CellTypeId: Integer;
  CellIsDone: Boolean;
begin
  try
    InParams := TParamsExt.Create;
    OutParams := TParamsExt.Create;
    try
      FolderId := AInParams.AsInt64[0];
      CellId := AInParams.AsInt64[1];

      InParams.Clear;
      InParams.Add(FolderId);

      TDBAccess.DBAParamsFunc(TDBAccess.LoadCatalog, InParams, OutParams);

      CellList := OutParams.AsPointer[0];
      List := CellList.LockList;
      try
        RecordsCount := List.Count;

        TC.SetZeroSize;
        TC.SetZeroPosition;

        TC.WriteAsInteger(TUTServerReply.srLoadCatalog.ToInteger);
        TC.WriteAsInt64(FolderId);
        TC.WriteAsWord(RecordsCount);
        i := 0;
        while i < RecordsCount do
        begin
          Cell := List[i];

          TC.WriteAsInt64(Cell.Id);
          TC.WriteAsInt64(Cell.FolderId);
          TC.WriteAsString(Cell.Name);
          TC.WriteAsString(Cell.Desc);
          TC.WriteAsString(Cell.Content);
          TC.WriteAsInteger(Cell.CellTypeId);
          TC.WriteAsBoolean(Cell.IsDone);

          Inc(i);
        end;
      finally
        CellList.UnlockList;
      end;

      if CellId > 0 then
      begin
        InParams.Clear;
        InParams.Add(CellId);

        TDBAccess.DBAParamsFunc(TDBAccess.LoadCell, InParams, OutParams);

        CellId      := OutParams.AsInt64[0];
        FolderId    := OutParams.AsInt64[1];
        CellContent := OutParams.AsString[2];
        CellTypeId  := OutParams.AsInteger[3];
        CellIsDone  := OutParams.AsBoolean[4];

        TC.WriteAsInt64(CellId);
        TC.WriteAsInt64(FolderId);
        TC.WriteAsString(CellContent);
        TC.WriteAsInteger(CellTypeId);
        TC.WriteAsBoolean(CellIsDone);
      end
      else
      begin
        CellId := 0;

        TC.WriteAsInt64(CellId);
      end;
    finally
      FreeAndNil(InParams);
      FreeAndNil(OutParams);
    end;
  except
    on e: Exception do
      TUTServerException.RaiseException(METHOD, e);
  end;
end;

end.
