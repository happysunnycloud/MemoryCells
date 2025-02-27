unit CellUnit;

interface

uses
    System.Generics.Collections
  , System.Classes
  ;

type
  TCellIdList = class(TThreadList<Int64>)
  strict private
    function GetCount: Word;
  public
    procedure CopyFrom(const AIdList: TCellIdList);
    function ToString: String; override;
    function Contains(const AId: Int64): Boolean;
    property Count: Word read GetCount;
  end;

  TCell = class
  strict private
    FId: Int64;
    FFolderId: Int64;
    FName: String;
    FDesc: String;
    FContent: String;
    FCellTypeId: Integer;
    FIsDone: Boolean;
    FUpdateDateTime: TDateTime;
    FOnContentChanged: TNotifyEvent;
    FOnDescChanged: TNotifyEvent;
    FOnIsDoneChanged: TNotifyEvent;
    FLinkedCellIdList: TCellIdList;
    FRemindDateTime: TDateTime;
    FRemind: Boolean;

    procedure Init(
      const AId: Int64;
      const AFolderId: Int64;
      const ACellTypeId: Integer);

    procedure SetContent(const AContent: String);
    procedure SetDesc(const ADesc: String);
    procedure SetIsDone(const AIsDone: Boolean);
  public
    constructor Create; overload;
    constructor Create(
      const AId: Int64;
      const AFolderId: Int64;
      const ACellTypeId: Integer); overload;

    destructor Destroy; override;

    property Id: Int64 read FId write FId;
    property FolderId: Int64 read FFolderId write FFolderId;
    property Name: String read FName write FName;
    property Desc: String read FDesc write SetDesc;
    property Content: String read FContent write SetContent;
    property CellTypeId: Integer read FCellTypeId write FCellTypeId;
    property IsDone: Boolean read FIsDone write SetIsDone;
    property UpdateDateTime: TDateTime read FUpdateDateTime write FUpdateDateTime;
    property LinkedCellIdList: TCellIdList read FLinkedCellIdList write FLinkedCellIdList;
    property RemindDateTime: TDateTime read FRemindDateTime write FRemindDateTime;
    property Remind: Boolean read FRemind write FRemind;

    property OnContentChanged: TNotifyEvent read FOnContentChanged write FOnContentChanged;
    property OnDescChanged: TNotifyEvent read FOnDescChanged write FOnDescChanged;
    property OnIsDoneChanged: TNotifyEvent read FOnIsDoneChanged write FOnIsDoneChanged;

    procedure CopyFrom(const ACell: TCell);
    procedure Clear;
  end;

  TCellList = class(TThreadList<TCell>)
  strict private
    FFolderParentId: Int64;

    procedure SetFolderParentId(AFolderParentId: Int64);
    function GetFolderParentId: Int64;
  public
    destructor Destroy; override;

    procedure DeleteAll;
    procedure Delete(var ACell: TCell);

    property FolderParentId: Int64 read GetFolderParentId write SetFolderParentId;

    function GetCell(const ACellId: Int64): TCell;

    procedure CopyFrom(const ACellList: TCellList);
  end;

  TInnerCellList = TList<TCell>;

  TListHelper = class helper for TInnerCellList
    function GetByCellId(const ACellId: Int64): TCell;
  end;

implementation

uses
  System.SysUtils;

{ TCellIdList. Begin }

function TCellIdList.GetCount: Word;
var
  IdList: TList<Int64>;
begin
  IdList := LockList;
  try
    Result := IdList.Count;
  finally
    UnlockList;
  end;
end;

procedure TCellIdList.CopyFrom(const AIdList: TCellIdList);
var
  IdList: TList<Int64>;
  Id: Int64;
begin
  IdList := AIdList.LockList;
  try
    Clear;
    for Id in IdList do
    begin
      Add(Id);
    end;
  finally
    AIdList.UnlockList;
  end;
end;

function TCellIdList.ToString: String;
var
  IdList: TList<Int64>;
  i: Word;
begin
  Result := '';

  IdList := LockList;
  try
    i := 0;
    while i < IdList.Count do
    begin
      Result := Result + ', ' + IdList.Items[i].ToString;

      Inc(i);
    end;

    Result := Trim(Result);
    Result := Copy(Result, 2, Length(Result) - 1);
  finally
    UnlockList;
  end;
end;

function TCellIdList.Contains(const AId: Int64): Boolean;
var
  IdList: TList<Int64>;
begin
  IdList := LockList;
  try
    Result := IdList.Contains(AId);
  finally
    UnlockList;
  end;
end;

{ TCellIdList. End }

procedure TCell.Init(
  const AId: Int64;
  const AFolderId: Int64;
  const ACellTypeId: Integer);
begin
  Clear;

  FId := AId;
  FFolderId := AFolderId;
  FCellTypeId := ACellTypeId;
end;

procedure TCell.Clear;
begin
  FId := 0;
  FFolderId := 0;
  FName := '*';
  FDesc := '';
  FContent := '';
  FCellTypeId := 0;
  FIsDone := false;
  FUpdateDateTime := Now();
  FRemindDateTime := 0;
  FRemind := false;

  FOnContentChanged := nil;
  FOnDescChanged := nil;
  FOnIsDoneChanged := nil;

  if Assigned(FLinkedCellIdList) then
    FreeAndNil(FLinkedCellIdList);

  FLinkedCellIdList := TCellIdList.Create;
end;

constructor TCell.Create;
begin
  Init(0, 0, 0);
end;

constructor TCell.Create(
  const AId: Int64;
  const AFolderId: Int64;
  const ACellTypeId: Integer);
begin
  Init(AId, AFolderId, ACellTypeId);
end;

destructor TCell.Destroy;
begin
  if Assigned(FLinkedCellIdList) then
    FreeAndNil(FLinkedCellIdList);

  inherited;
end;

procedure TCell.SetContent(const AContent: String);
begin
  FContent := AContent;
//  if FContent.Length = 0 then
//    Exit;

  FDesc := Copy(Content, 1, 200);
  if Length(FContent) > Length(FDesc) then
    FDesc := Concat(FDesc, '...');

  if Assigned(FOnContentChanged) then
    FOnContentChanged(Self);
end;

procedure TCell.SetDesc(const ADesc: String);
begin
  FDesc := ADesc;

  if Assigned(FOnDescChanged) then
    FOnDescChanged(Self);
end;

procedure TCell.SetIsDone(const AIsDone: Boolean);
begin
  FIsDone := AIsDone;

  if Assigned(FOnIsDoneChanged) then
    FOnIsDoneChanged(Self);
end;

procedure TCell.CopyFrom(const ACell: TCell);
begin
  FId := ACell.Id;
  FFolderId := ACell.FolderId;
  FName := ACell.Name;
  FDesc := ACell.Desc;
  FContent := ACell.Content;
  FCellTypeId := ACell.CellTypeId;
  FIsDone := ACell.IsDone;
  FUpdateDateTime := ACell.UpdateDateTime;
  FRemindDateTime := ACell.RemindDateTime;
  FRemind := ACell.Remind;

  FOnContentChanged := ACell.OnContentChanged;
  FOnDescChanged := ACell.OnDescChanged;
  FOnIsDoneChanged := ACell.OnIsDoneChanged;

  FLinkedCellIdList.CopyFrom(ACell.LinkedCellIdList);
end;

destructor TCellList.Destroy;
var
  CellList: TInnerCellList;
  Cell: TCell;
begin
  CellList := LockList;
  try
    for Cell in CellList do
      Cell.Free;

    CellList.Clear;
  finally
    UnlockList;
  end;

  inherited;
end;

procedure TCellList.SetFolderParentId(AFolderParentId: Int64);
begin
  LockList;
  try
    FFolderParentId := AFolderParentId;
  finally
    UnlockList;
  end;
end;

function TCellList.GetFolderParentId: Int64;
begin
  LockList;
  try
    Result := FFolderParentId;
  finally
    UnlockList;
  end;
end;

procedure TCellList.DeleteAll;
var
  CellList: TInnerCellList;
  Cell: TCell;
begin
  CellList := LockList;
  try
    for Cell in CellList do
      Cell.Free;

    CellList.Clear;
  finally
    UnlockList;
  end;
end;

procedure TCellList.Delete(var ACell: TCell);
begin
  Remove(ACell);
  ACell.Free;
  ACell := nil;
end;

function TCellList.GetCell(const ACellId: Int64): TCell;
var
  CellList: TInnerCellList;
  Cell: TCell;
begin
  Result := nil;

  CellList := LockList;
  try
    for Cell in CellList do
      if Cell.Id = ACellid then
        Exit(Cell);
  finally
    UnlockList;
  end;
end;

procedure TCellList.CopyFrom(const ACellList: TCellList);
var
  InnerCellList: TInnerCellList;
  InnerCell: TCell;
  OuterCellList: TInnerCellList;
  OuterCell: TCell;
begin
  DeleteAll;

  InnerCellList := LockList;
  OuterCellList := ACellList.LockList;
  try
    for OuterCell in OuterCellList do
    begin
      InnerCell := TCell.Create;
      InnerCell.CopyFrom(OuterCell);
      InnerCellList.Add(InnerCell);
    end;
  finally
    UnlockList;
    ACellList.UnlockList;
  end;
end;

function TListHelper.GetByCellId(const ACellId: Int64): TCell;
var
  i: Word;
begin
  Result := nil;

  i := Count;
  while i > 0 do
  begin
    Dec(i);

    if Items[i].Id = ACellId then
      Exit(Items[i]);
  end;
end;

end.
