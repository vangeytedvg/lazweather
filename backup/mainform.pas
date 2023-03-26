unit mainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  fphttpclient, fpjson, jsonparser, opensslsockets;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    editURL: TEdit;
    edtCity: TEdit;
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lbJokes: TListBox;
    Log: TMemo;
    stFeelsLike: TStaticText;
    stUV: TStaticText;
    stVisibility: TStaticText;
    stLat: TStaticText;
    stLon: TStaticText;
    stIsDay: TStaticText;
    stWeatherCode: TStaticText;
    stTimeZone: TStaticText;
    stRegion: TStaticText;
    stCountry2: TStaticText;
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
    procedure Image2Click(Sender: TObject);
    procedure stCountry2Click(Sender: TObject);
  private

  public

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.Button1Click(Sender: TObject);
var
  client: TFPHTTPClient;
  response: string;
  parser: TJSONParser;
  jsonObject: TJSONObject;
  jokeField: TJSONString;
  jokeVariant: variant;
begin

  // Get A Chuck Norris joke
  client := TFPHTTPClient.Create(nil);

  try
    response := client.Get('https://api.chucknorris.io/jokes/random');
    parser := TJSONParser.Create(response);
    try
      jsonObject := parser.Parse as TJSONObject;
      jokeVariant := jsonObject.Get('value');
      jokeField := TJSONString.Create(jokeVariant);
      lbJokes.Items.Add(jokeField.Value);

    finally
      parser.Free;
    end;
  finally
    client.Free;
  end;
end;

procedure TfrmMain.Button2Click(Sender: TObject);
{ Code to get an Image from the internet }
var
  HTTPClient: TFPHTTPClient;
  ImageStream: TMemoryStream;
begin
  HTTPClient := TFPHTTPClient.Create(nil);
  ImageStream := TMemoryStream.Create;
  try
    HTTPClient.Get('https://www.steenland.nl/images/steenland-logo.png', ImageStream);
    ImageStream.Position := 0;
    Image1.Picture.LoadFromStream(ImageStream);
  finally
    HTTPClient.Free;
    ImageStream.Free;
  end;
end;

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
  Client := TFPHTTPClient.Create(nil);
  URL := 'http://api.weatherstack.com/current?access_key=e20d123e786d2dc17186b881fdf67186&query='
    + edtCity.Text;
  editURL.Text := URL;
  ResponseContent := Client.Get(URL);
  for I := 0 to Client.ResponseHeaders.Count - 1 do
    Log.Lines.Add(Client.ResponseHeaders[I]);

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
      stPressure.Caption := JSONData.FindPath('current.pressure').AsInteger.ToString;
      stPrecip.Caption := JSONData.FindPath('current.precip').AsFloat.ToString;
      stHummidity.Caption := JSONData.FindPath('current.humidity').AsInteger.ToString + '%';
      stFeelsLike.Caption := JSONData.FindPath('current.feelslike').AsInteger.ToString + ' °Celsius.';
      stUV.Caption := JSONData.FindPath('current.uv_index').AsInteger.ToString;
      stVisibility.Caption:=JSONData.FindPath('current.visibility').AsInteger.ToString;
      stIsDay.Caption:=JSONData.FindPath('current.isday').AsString;
      // Here we retrieve the URL to the weather Icon
      WeatherIconURL := JSONData.FindPath('current.weather_icons[0]').AsString;
    finally
      JSONData.Free;
    end;
  except
    ShowMessage('rrir');
  end;

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

procedure TfrmMain.Image2Click(Sender: TObject);
begin

end;

procedure TfrmMain.stCountry2Click(Sender: TObject);
begin

end;

end.