unit MCParamsUnit;

interface

uses
    ParamsExtUnit
  , CellUnit
  ;

const
  PARAM_IDENT_CellReminderFormRemindDateTime = 'CellReminderFormRemindDateTime';
  PARAM_IDENT_CellReminderFormRemind = 'CellReminderFormRemind';
  PARAM_IDENT_CellReminderFormOpenReminderPanel = 'CellReminderFormOpenReminderPanel';
  PARAM_IDENT_RestartReminder = 'RestartReminder';

type
  TParamsExt = class (ParamsExtUnit.TParamsExt)
  public
    destructor Destroy; override;

    procedure Clear; reintroduce;
    procedure Add(const AValue: Pointer); reintroduce; overload;
    procedure CopyFrom(const AParamsObj: TParamsExt); reintroduce;
  end;

implementation

destructor TParamsExt.Destroy;
begin
  Clear;

  inherited;
end;

procedure TParamsExt.Clear;
var
  i: Word;
  CellIdListTmp: TCellIdList;
  CellListTmp: TCellList;
  CellTmp: TCell;
  p: Pointer;
begin
  i := Length;
  while i > 0 do
  begin
    Dec(i);

    if TypeOfVar[i] = varByRef then
    begin
      p := AsPointer[i];
      if TObject(p) is TCellIdList then
      begin
        CellIdListTmp := TCellIdList(p);
        CellIdListTmp.Free;
      end
      else
      if TObject(p) is TCellList then
      begin
        CellListTmp := TCellList(p);
        CellListTmp.Free;
      end
      else
      if TObject(p) is TCell then
      begin
        CellTmp := TCell(p);
        CellTmp.Free;
      end;
    end;
  end;

  inherited;
end;

procedure TParamsExt.Add(const AValue: Pointer);
var
  CellIdList: TCellIdList;
  CellList: TCellList;
  Cell: TCell;
begin
  if TObject(AValue) is TCellIdList then
  begin
    CellIdList := TCellIdList.Create;
    CellIdList.CopyFrom(AValue);

    inherited Add(CellIdList);
  end
  else
  if TObject(AValue) is TCellList then
  begin
    CellList := TCellList.Create;
    CellList.CopyFrom(AValue);

    inherited Add(CellList);
  end
  else
  if TObject(AValue) is TCell then
  begin
    Cell := TCell.Create;
    Cell.CopyFrom(AValue);

    inherited Add(Cell);
  end
  else
    inherited Add(AValue);
end;

procedure TParamsExt.CopyFrom(const AParamsObj: TParamsExt);
var
  i: Word;
  ParamsObj: TParamsExt absolute AParamsObj;
  CellIdList: TCellIdList;
  CellIdListTmp: TCellIdList;
  CellList: TCellList;
  CellListTmp: TCellList;
  Cell: TCell;
  CellTmp: TCell;
  p: Pointer;
begin
  i := 0;
  while i < AParamsObj.Length do
  begin
    //Если в параметрах передается ссылка на список TCellIdList, то копируем и сам список
    if AParamsObj.TypeOfVar[i] = varByRef then
    begin
      p := AParamsObj.AsPointer[i];
      if TObject(p) is TCellIdList then
      begin
        CellIdListTmp := TCellIdList(p);

        CellIdList := TCellIdList.Create;
        CellIdList.CopyFrom(CellIdListTmp);

        inherited Add(CellIdList);
      end
      else
      if TObject(p) is TCellList then
      begin
        CellListTmp := TCellList(p);

        CellList := TCellList.Create;
        CellList.CopyFrom(CellListTmp);

        inherited Add(CellList);
      end
      else
      if TObject(p) is TCell then
      begin
        CellTmp := TCell(p);

        Cell := TCell.Create;
        Cell.CopyFrom(CellTmp);

        inherited Add(Cell);
      end
      else
        inherited Add(p);
    end
    else
    begin
      inherited Add(AParamsObj.Params[i].v, AParamsObj.Params[i].Ident);
    end;

    Inc(i);
  end;
end;

end.
