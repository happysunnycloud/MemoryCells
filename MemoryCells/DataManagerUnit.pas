unit DataManagerUnit;

interface

uses
    System.SyncObjs
  , CellUnit
  ;

type
  TDataManager = class
  strict private
    FAccessCriticalSection: TCriticalSection;
    FCellList: TCellList;
//    FCurrentFolderId: Int64;
//    FCurrentCell: TCell;

//    procedure SetCurrentFolderId(ACurrentFolderId: Int64);
//    function GetCurrentFolderId: Int64;
  public
    constructor Create;
    destructor Destroy; override;

    property CellList: TCellList read FCellList;
//    property CurrentFolderId: Int64 read GetCurrentFolderId write SetCurrentFolderId;
//    property CurrentCell: TCell read FCurrentCell write FCurrentCell;
  end;

implementation

uses
    System.SysUtils

  , DBAccessUnit
  ;

constructor TDataManager.Create;
begin
  FAccessCriticalSection := TCriticalSection.Create;
  FCellList := TCellList.Create;
//  FCurrentFolderId := 0;
//  FCurrentCell := nil;
end;

destructor TDataManager.Destroy;
begin
  FCellList.DeleteAll;
  FreeAndNil(FCellList);
  FreeAndNil(FAccessCriticalSection);

  inherited;
end;

//procedure TDataManager.SetCurrentFolderId(ACurrentFolderId: Int64);
//begin
//  FAccessCriticalSection.Enter;
//  try
//    FCurrentFolderId := ACurrentFolderId;
//  finally
//    FAccessCriticalSection.Leave;
//  end;
//end;

//function TDataManager.GetCurrentFolderId: Int64;
//begin
//  FAccessCriticalSection.Enter;
//  try
//    Result := FCurrentFolderId;
//  finally
//    FAccessCriticalSection.Leave;
//  end;
//end;

end.
