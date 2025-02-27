unit MemoryCellsServerUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Memo.Types, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo,
  IdContext,

  UTServerUnit,
  TransportContainerUnit, FMX.StdCtrls;

type
  TMainForm = class(TForm)
    LogMemo: TMemo;
    Button1: TButton;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    FIsClosing: Boolean;

    procedure LogMessage(const AMessage: String);
    procedure RaiseAppException(const AMethod: String; const AE: Exception);
  public
    { Public declarations }
    procedure ServerExceptionHandler(const AExceptionMessage: String);
    procedure ServerOnReadHandler(
      const AServer: TUTServer;
      const AContext: TIdContext;
      const ATransportContainer: TTransportContainer);

    procedure ServerOnConnected(Sender: TObject);
    procedure ServerOnDisconnected(Sender: TObject);
  end;

var
  MainForm: TMainForm;
  UTServer: TUTServer;

implementation

{$R *.fmx}

uses
    UTClientRequestUnit
  , UTServerReplyUnit
  , DBAccessUnit
  , ParamsExtUnit
  , MemoryCellsServerRepliesDataUnit
  , AddLogUnit
  ;

const
  DB_PATH = '..\..\..\MemoryCellsDataBase\';
  DB_FILE_NAME = 'CAT.db';

procedure TMainForm.RaiseAppException(const AMethod: String; const AE: Exception);
var
  ExceptionMessage: String;
begin
  ExceptionMessage := AE.Message;

  TThread.ForceQueue(nil,
    procedure
    begin
      LogMessage(ExceptionMessage);
    end);
end;

procedure TMainForm.LogMessage(const AMessage: String);
begin
  TThread.Queue(nil,
    procedure
    begin
      LogMemo.Lines.Insert(0, DateTimeToStr(Now) + ' -> ' + AMessage);
      LogMemo.ScrollToTop(false);
    end);
end;

procedure TMainForm.ServerExceptionHandler(const AExceptionMessage: String);
var
  ExceptionMessage: String;
begin
  if FIsClosing then
    Exit;

  ExceptionMessage := AExceptionMessage;

  TThread.ForceQueue(nil,
    procedure
    begin
      LogMessage(ExceptionMessage);
    end);
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  FIsClosing := true;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  ReportMemoryLeaksOnShutdown := true;

  FIsClosing := false;

  TDBAccess.Init(DB_PATH + DB_FILE_NAME, '..\..\..\MemoryCellsCommon\SQLTemplates');

  UTServer := TUTServer.Create;
  UTServer.Connection.Active := true;
  UTServer.OnException := ServerExceptionHandler;
  UTServer.OnRead := ServerOnReadHandler;
  UTServer.OnConnected := ServerOnConnected;
  UTServer.OnDiconnected := ServerOnDisconnected;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  if Assigned(UTServer) then
  begin
    UTServer.Connection.Active := false;
    UTServer.Free;
  end;

  TDBAccess.UnInit;
  TLogger.UnInit;
end;

procedure TMainForm.ServerOnReadHandler(
  const AServer: TUTServer;
  const AContext: TIdContext;
  const ATransportContainer: TTransportContainer);
const
  METHOD = 'TMainForm.ServerOnReadHandler';
var
  TC: TTransportContainer absolute ATransportContainer;
  ReplyTC: TTransportContainer;
  FolderId: Int64;
  CellId: Int64;
  InParams: TParamsExt;
begin
  try
    ReplyTC := TTransportContainer.Create;
    InParams := TParamsExt.Create;
    try
      if TUTClientRequest.crLoadCatalog = TUTClientRequest(TC.ReadAsInteger(0)) then
      begin
        FolderId := TC.ReadAsInt64(1);
        CellId := TC.ReadAsInt64(2);

        LogMessage(Format('User read -> FolderId: %d CellId: %d', [FolderId, CellId]));

        //*********//
        InParams.Clear;
        InParams.Add(FolderId);
        InParams.Add(CellId);

        TServerReplies.LoadCatalog(InParams, ReplyTC);
        //*********//

        AServer.Reply(AContext, ReplyTC);
        //AServer.Reply(AContext, srLoadCatalog.ToInteger);
      end;
    finally
      FreeAndNil(InParams);
      FreeAndNil(ReplyTC);
    end;
  except
    on e: Exception do
      RaiseAppException(METHOD, e);
  end;
end;

procedure TMainForm.ServerOnConnected(Sender: TObject);
begin
  LogMessage('User connected');
end;

procedure TMainForm.ServerOnDisconnected(Sender: TObject);
begin
  LogMessage('User diconnected');
end;

end.
