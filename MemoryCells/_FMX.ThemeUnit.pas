unit FMX.ThemeUnit;

interface

uses
    System.Classes
  , System.UITypes
  , FMX.Controls
  ;

type
  TTheme = class
  strict private
    class var FStyleBook: TMemoryStream;
    class var FBackgroundColor: TAlphaColor;
    class var FDarkBackgroundColor: TAlphaColor;
    class var FLightBackgroundColor: TAlphaColor;
    class var FMemoColor: TAlphaColor;
    class var FTextColor: TAlphaColor;
    class var FTextFontSize: Single;
  public
    class constructor Initialize;
    class destructor Finalize;

    class procedure SaveStyleBook(const AStyleBook: TStyleBook);
    class procedure LoadStyleBook(const AStyleBook: TStyleBook);

    class property BackgroundColor: TAlphaColor read FBackgroundColor write FBackgroundColor;
    class property DarkBackgroundColor: TAlphaColor read FDarkBackgroundColor write FDarkBackgroundColor;
    class property LightBackgroundColor: TAlphaColor read FLightBackgroundColor write FLightBackgroundColor;
    class property MemoColor: TAlphaColor read FMemoColor write FMemoColor;
    class property TextColor: TAlphaColor read FTextColor write FTextColor;
    class property TextFontSize: Single read FTextFontSize write FTextFontSize;
  end;

implementation

uses
    System.SysUtils
  , FMX.Styles
  ;

{ TTheme }

class constructor TTheme.Initialize;
begin
  FBackgroundColor := TAlphaColorRec.Gray;
  FMemoColor := TAlphaColorRec.Whitesmoke;
  FTextColor := TAlphaColorRec.Black;
  FTextFontSize := 14;

  FStyleBook := TMemoryStream.Create;
end;

class destructor TTheme.Finalize;
begin
  FreeAndNil(FStyleBook);
end;

class procedure TTheme.SaveStyleBook(const AStyleBook: TStyleBook);
const
  METHOD = 'TTheme.SaveStyleBook';
begin
  if not Assigned(AStyleBook) then
    Exit;

  try
    FStyleBook.Size := 0;
    TStyleStreaming.SaveToStream(AStyleBook.Style, FStyleBook);
    FStyleBook.Position := 0;
  except
    on e: Exception do
      raise Exception.CreateFmt('%s -> %s', [METHOD, e.Message]);
  end;
end;

class procedure TTheme.LoadStyleBook(const AStyleBook: TStyleBook);
const
  METHOD = 'TTheme.SaveStyleBook';
begin
  if not Assigned(AStyleBook) then
    Exit;

  try
    FStyleBook.Position := 0;
    AStyleBook.LoadFromStream(FStyleBook);
  except
    on e: Exception do
      raise Exception.CreateFmt('%s -> %s', [METHOD, e.Message]);
  end;
end;


end.
