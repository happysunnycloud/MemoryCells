program MemoryCellsServer;

uses
  System.StartUpCopy,
  FMX.Forms,
  MemoryCellsServerUnit in 'MemoryCellsServerUnit.pas' {MainForm},
  UTServerUnit in '..\..\DevelopmentsCollection\UTCS\UTServerUnit.pas',
  TransportContainerUnit in '..\..\DevelopmentsCollection\UTCS\TransportContainerUnit.pas',
  UTCSTypesUnit in '..\..\DevelopmentsCollection\UTCS\UTCSTypesUnit.pas',
  UTClientRequestUnit in '..\MemoryCellsCommon\UTClientRequestUnit.pas',
  UTServerReplyUnit in '..\MemoryCellsCommon\UTServerReplyUnit.pas',
  AddLogUnit in '..\..\DevelopmentsCollection\AddLogUnit.pas',
  PingTimeoutThreadUnit in '..\..\DevelopmentsCollection\UTCS\PingTimeoutThreadUnit.pas',
  DBAccessUnit in '..\MemoryCellsCommon\DBAccessUnit.pas',
  CellUnit in '..\MemoryCellsCommon\CellUnit.pas',
  DBToolsUnit in '..\..\DevelopmentsCollection\DBToolsUnit.pas',
  SQLTemplatesUnit in '..\..\DevelopmentsCollection\SQLTemplatesUnit.pas',
  ToolsUnit in '..\..\DevelopmentsCollection\ToolsUnit.pas',
  ParamsExtUnit in '..\MemoryCellsCommon\ParamsExtUnit.pas',
  ParamsClassUnit in '..\..\DevelopmentsCollection\ParamsClassUnit.pas',
  ExceptionContainerUnit in '..\MemoryCellsCommon\ExceptionContainerUnit.pas',
  MemoryCellsServerRepliesDataUnit in 'MemoryCellsServerRepliesDataUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
