unit mainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, Buttons, fphttpclient, fpjson, jsonparser, opensslsockets, ShellApi,
  Windows;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    Button1: TButton;
    Button3: TButton;
    edtCity: TEdit;
    Image1: TImage;
    imgBtnClose: TImage;
    ImageList2: TImageList;
    formbar: TImageList;
    imgDayNight: TImage;
    ImageList1: TImageList;
    imgDayNight1: TImage;
    imgDayNight2: TImage;
    imgRose: TImage;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    memoJoke: TMemo;
    Panel1: TPanel;
    StatusBar1: TStatusBar;
    stFeelsLike: TStaticText;
    stUV: TStaticText;
    stVisibility: TStaticText;
    stLat: TStaticText;
    stLon: TStaticText;
    stIsDay: TStaticText;
    stWeatherCode: TStaticText;
    stTimeZone: TStaticText;
    stRegion: TStaticText;
    stTemperature: TStaticText;
    stLocation: TStaticText;
    stCountry: TStaticText;
    stLocationTime: TStaticText;
    stUTCOffset: TStaticText;
    stObsTime: TStaticText;
    stWeatherDescription: TStaticText;
    stWindDirection: TStaticText;
    stPressure: TStaticText;
    stPrecip: TStaticText;
    stHummidity: TStaticText;
    stWindSpeed: TStaticText;
    stWindDegree: TStaticText;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure imgBtnCloseMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure imgBtnCloseMouseLeave(Sender: TObject);
    procedure imgBtnCloseMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
    procedure Label13Click(Sender: TObject);
    procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
  private
    procedure OrientateRose(direction: string);
    procedure SetDayNight(daynight: string);
    procedure GetJoke;
  public

  end;

var
  frmMain: TfrmMain;

implementation

uses
  webRequestForm;

{$R *.lfm}

{ TfrmMain }
procedure TfrmMain.GetJoke;
var
  client: TFPHTTPClient;
  response: string;
  parser: TJSONParser;
  jsonObject: TJSONObject;
  jokeField: TJSONString;
  jokeVariant: variant;
begin

  StatusBar1.Panels[0].Text := 'Getting a joke....';
  Application.ProcessMessages;

  // Get A Chuck Norris joke
  client := TFPHTTPClient.Create(nil);

  try
    response := client.Get('https://api.chucknorris.io/jokes/random');
    parser := TJSONParser.Create(response);
    try
      jsonObject := parser.Parse as TJSONObject;
      jokeVariant := jsonObject.Get('value');
      jokeField := TJSONString.Create(jokeVariant);
      memoJoke.Clear;
      memoJoke.Lines.Add(jokeField.Value);
    finally
      parser.Free;
    end;
  finally
    client.Free;
  end;
end;

procedure TfrmMain.Button1Click(Sender: TObject);
begin
  GetJoke;
end;

procedure TfrmMain.Button2Click(Sender: TObject);
begin
  Close;
end;

//procedure TfrmMain.Button2Click(Sender: TObject);
//{ Code to get an Image from the internet }
//var
//  HTTPClient: TFPHTTPClient;
//  ImageStream: TMemoryStream;
//begin
//  HTTPClient := TFPHTTPClient.Create(nil);
//  ImageStream := TMemoryStream.Create;
//  try
//    HTTPClient.Get('https://www.steenland.nl/images/steenland-logo.png', ImageStream);
//    ImageStream.Position := 0;
//    Image1.Picture.LoadFromStream(ImageStream);
//  finally
//    HTTPClient.Free;
//    ImageStream.Free;
//  end;
//end;

procedure TfrmMain.Button3Click(Sender: TObject);
var
  Client: TFPHTTPClient;
  ResponseContent, URL, WeatherIconURL: string;
  JSONData: TJSONData;
  WeatherIcon: TPicture;
  Temperature: double;
  ImageStream: TMemoryStream;
  I: integer;
begin

  if edtCity.Text = '' then
  begin
    ShowMessage('Please enter a city!');
    edtCity.SetFocus;
    exit;
  end;
  // Always get a joke
  FormWeb.Show;
  GetJoke;
  StatusBar1.Panels[0].Text := 'Getting weather data';
  Application.ProcessMessages;

  Client := TFPHTTPClient.Create(nil);
  URL := 'http://api.weatherstack.com/current?access_key=e20d123e786d2dc17186b881fdf67186&query='
    + edtCity.Text;

  ResponseContent := Client.Get(URL);

  JSONData := GetJSON(ResponseContent);

  // Might be strange, but this API returns only success false if the city can't be found...
  if ResponseContent.Contains('succes') then
    exit;
  try
    try
      // Extract the temperature information from the JSON response
      Temperature := JSONData.FindPath('current.temperature').AsFloat;
      stTemperature.Caption := FloatToStr(Temperature) + ' °C.';
      stLocation.Caption := JSONData.FindPath('location.name').AsString;
      stCountry.Caption := JSONData.FindPath('location.country').AsString;
      stRegion.Caption := JSONData.FindPath('location.region').AsString;
      stLat.Caption := JSONData.FindPath('location.lat').AsString;
      stLon.Caption := JSONData.FindPath('location.lon').AsString;
      stTimeZone.Caption := JSONData.FindPath('location.timezone_id').AsString;
      stLocationTime.Caption := JSONData.FindPath('location.localtime').AsString;
      stUTCOffset.Caption := JSONData.FindPath('location.utc_offset').AsString;
      stObsTime.Caption := JSONData.FindPath('current.observation_time').AsString;
      stWeatherCode.Caption := JSONData.FindPath('current.weather_code').AsString;
      stWeatherDescription.Caption :=
        JSONData.FindPath('current.weather_descriptions[0]').AsString;
      stWindSpeed.Caption := JSONData.FindPath('current.wind_speed').AsInteger.ToString;
      stWindDegree.Caption :=
        JSONData.FindPath('current.wind_degree').AsInteger.ToString;
      stWindDirection.Caption := JSONData.FindPath('current.wind_dir').AsString;
      OrientateRose(JSONData.FindPath('current.wind_dir').AsString);
      stPressure.Caption := JSONData.FindPath('current.pressure').AsInteger.ToString;
      stPrecip.Caption := JSONData.FindPath('current.precip').AsFloat.ToString;
      stHummidity.Caption := JSONData.FindPath('current.humidity').AsInteger.ToString
        + '%';
      stFeelsLike.Caption := JSONData.FindPath('current.feelslike').AsInteger.ToString +
        ' °Celsius.';
      stUV.Caption := JSONData.FindPath('current.uv_index').AsInteger.ToString;
      stVisibility.Caption := JSONData.FindPath('current.visibility').AsInteger.ToString;
      stIsDay.Caption := JSONData.FindPath('current.is_day').AsString;
      SetDayNight(JSONData.FindPath('current.is_day').AsString);


      // Here we retrieve the URL to the weather Icon
      WeatherIconURL := JSONData.FindPath('current.weather_icons[0]').AsString;
    finally
      JSONData.Free;
      StatusBar1.Panels[0].Text := 'Ready';
      FormWeb.Close;
    end;
  except
    on E: Exception do
      ShowMessage(E.Message);
  end;
  FormWeb.Close;

  // Load the weather picture into a TMemoryStream
  ImageStream := TMemoryStream.Create;
  try
    Client.Get(WeatherIconURL, ImageStream);
    // Reset the position of the stream to the beginning
    ImageStream.Position := 0;
    // Load the weather picture from the stream
    WeatherIcon := TPicture.Create;
    try
      WeatherIcon.LoadFromStream(ImageStream);
      // Display the weather picture in a TImage component
      Image1.Picture.Assign(WeatherIcon);
    finally
      WeatherIcon.Free;
    end;
  finally
    ImageStream.Free;
  end;
  Client.Free;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  bmp: Graphics.TBitmap;
begin
  bmp := Graphics.TBitMap.Create;
  try
    ImageList1.GetBitmap(0, bmp);
    imgRose.Picture.Assign(bmp);
  finally
    bmp.Free;
  end;
  bmp := Graphics.TBitmap.Create;
  try
    formbar.GetBitmap(0, bmp);
    imgBtnClose.Picture.Assign(bmp);
  finally
    bmp.Free;
  end;
end;

procedure TfrmMain.imgBtnCloseMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
var
  bmp: Graphics.TBitmap;
begin
  bmp := Graphics.TBitmap.Create;
  try
    formbar.GetBitmap(0, bmp);
    imgBtnClose.Picture.Assign(bmp);
  finally
    bmp.Free;
  end;

end;

procedure TfrmMain.imgBtnCloseMouseLeave(Sender: TObject);
var
  bmp: Graphics.TBitmap;

begin
  bmp := Graphics.TBitmap.Create;
  try
    formbar.GetBitmap(0, bmp);
    imgBtnClose.Picture.Assign(bmp);
  finally
    bmp.Free;
  end;

end;

procedure TfrmMain.imgBtnCloseMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: integer);
var
  bmp: Graphics.TBitmap;
begin
  bmp := Graphics.TBitmap.Create;
  try
    formbar.GetBitmap(1, bmp);
    imgBtnClose.Picture.Assign(bmp);
  finally
    bmp.Free;
  end;

end;

procedure TfrmMain.Label13Click(Sender: TObject);
begin
  // Open the weather code file
  ShellExecute(0, 'open', PChar('.\wcodes.ods'), '', '', 5);
end;

procedure TfrmMain.Panel1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  ReleaseCapture;
  SendMessage(Handle, WM_NCLBUTTONDOWN, HTCAPTION, 0);
end;


procedure TfrmMain.SetDayNight(daynight: string);
var
  index: integer;
  bmp: Graphics.TBitMap;
begin
  case daynight of
    'yes': index := 0;
    'no': index := 1;
  end;
  bmp := Graphics.TBitMap.Create;
  try
    ImageList2.GetBitmap(index, bmp);
    imgDayNight.Picture.Assign(bmp);
  finally
  end;
end;

procedure TfrmMain.OrientateRose(direction: string);
var
  index: integer;
  bmp: TBitmap;
begin
  case direction of
    'N': index := 0;
    'ENE': index := 1;
    'E': index := 2;
    'ESE': index := 3;
    'S': index := 4;
    'WSW': index := 5;
    'SSW': index := 5;
    'W': index := 6;
    'NW': index := 7;
    'WNW': index := 7;
  end;
  //bmp := TBitMap.Create;
  //try
  //  ImageList1.GetBitmap(index, bmp);
  //  imgRose.Picture.Assign(bmp);
  //finally
  //end;
end;


end.
