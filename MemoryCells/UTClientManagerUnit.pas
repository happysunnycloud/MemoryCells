unit UTClientManagerUnit;

interface

uses
  System.Classes,

  LockedListExtUnit,
  UTClientUnit;

const
  ONLINE_STATE_COLOR = $FF00A127;
  OFFLINE_STATE_COLOR = $FF6C005D;

type
  TUTClientList = TLockedListExt<TUTClient>;

  TUTClientManager = class
  strict private
    FUTClientList: TUTClientList;
    FPingClient: TUTClient;
    FDataClient: TUTClient;

    function GetPingClient: TUTClient;
    function GetDataClient: TUTClient;
    function GetItem(Index: Integer): TUTClient;

    procedure InternalPingOnConnectHandler(Sender: TObject);
    procedure InternalPingOnDisconnectHandler(Sender: TObject);
  private
  public
    constructor Create;
    destructor Destroy; override;

    function CreatePingClient(
      const AHostName: String;
      const AIP: String;
      const APort: Word): TUTClient;
    function CreateDataClient(
      const AHostName: String;
      const AIP: String;
      const APort: Word): TUTClient;
    function CreateClient(
      const AHostName: String;
      const AIP: String;
      const APort: Word;
      const AActivatePingControl: Boolean = false): TUTClient;
    procedure FreeAllClients;

    property PingClient: TUTClient read GetPingClient;
    property DataClient: TUTClient read GetDataClient;
    property Items[Index: Integer]: TUTClient read GetItem;
  end;

implementation

uses
    System.SysUtils
  , CommonUnit
  ;

function TUTClientManager.GetPingClient: TUTClient;
begin
  Result := FPingClient;
end;

function TUTClientManager.GetDataClient: TUTClient;
begin
  Result := FDataClient;
end;

function TUTClientManager.GetItem(Index: Integer): TUTClient;
const
  METHOD = 'TUTClientManager.GetItem';
begin
  if (Index > Pred(FUTClientList.Count)) or
     (Index < 0)
  then
    THelpmate.RaiseException(METHOD, Exception.Create('Index out of range'));

  Result := FUTClientList.Items[Index];
end;

procedure TUTClientManager.InternalPingOnConnectHandler(Sender: TObject);
begin
  if Assigned(FPingClient.OnConnected) then
    FPingClient.OnConnected(Sender);
end;

procedure TUTClientManager.InternalPingOnDisconnectHandler(Sender: TObject);
begin
  if Assigned(FPingClient.OnDisconnected) then
    FPingClient.OnDisconnected(Sender);

  FPingClient := nil;
end;

constructor TUTClientManager.Create;
begin
  FUTClientList := TUTClientList.Create;
  FPingClient := nil;
end;

destructor TUTClientManager.Destroy;
begin
  FreeAllClients;

  FreeAndNil(FUTClientList);

  inherited;
end;

procedure TUTClientManager.FreeAllClients;
const
  METHOD = 'TUTClientManager.FreeAllClients';
var
  UTClient: TUTClient;
begin
  try
    while FUTClientList.Count > 0 do
    begin
      UTClient := FUTClientList.Items[0];
      FUTClientList.Remove(UTClient);
      UTClient.Disconnect;
      FreeAndNil(UTClient);
    end;

    FPingClient := nil;
  except
    on e: Exception do
      THelpmate.RaiseException(METHOD, e);
  end;
end;

function TUTClientManager.CreatePingClient(
  const AHostName: String;
  const AIP: String;
  const APort: Word): TUTClient;
begin
  if Assigned(FPingClient) then
    raise Exception.Create('There can only be one such ping client');

  Result := CreateClient(AHostName, AIP, APort, true);
  FPingClient := Result;
  FPingClient.OnConnected := InternalPingOnConnectHandler;
  FPingClient.OnDisconnected := InternalPingOnDisconnectHandler;
end;

function TUTClientManager.CreateDataClient(
  const AHostName: String;
  const AIP: String;
  const APort: Word): TUTClient;
begin
  Result := CreateClient(AHostName, AIP, APort);
  FDataClient := Result;
end;

function TUTClientManager.CreateClient(
  const AHostName: String;
  const AIP: String;
  const APort: Word;
  const AActivatePingControl: Boolean = false): TUTClient;
const
  METHOD = 'TUTClientManager.CreateClient';
begin
  Result := nil;
  try
    Result := TUTClient.Create(AHostName, AIP, APort, AActivatePingControl);
    FUTClientList.Add(Result);
  except
    on e: Exception do
      THelpmate.RaiseException(METHOD, e);
  end;
end;

end.
