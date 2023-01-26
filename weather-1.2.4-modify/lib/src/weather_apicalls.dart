part of weather_library;

Future<Weather> currentWeatherByCityName(String cityName, String apiKey) async {
  String url = 'https://api.openweathermap.org/data/2.5/weather?' +
      'q=$cityName&' +
      'appid=$apiKey';
  try {
    http.Response response = await http.get(url);
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonBody = json.decode(response.body);
      return Weather.current(jsonBody);
    } else {
      throw OpenWeatherAPIException(
          "The API threw an exception: ${response.body}");
    }
  } catch (exception) {
    print(exception);
  }
  return null;
}

Future<List<Weather>> sevenDayForecastByLocation(
    double latitude, double longitude, String apiKey) async {
  List<Weather> forecast = new List<Weather>();
  String url =
      'https://api.openweathermap.org/data/2.5/onecall?exclude=hourly,minutely&' +
          'lat=$latitude&lon=$longitude&' +
          'appid=$apiKey';

  try {
    http.Response response = await http.get(url);
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonForecast = json.decode(response.body);
      // forecast = _parseOnecall(jsonForecast);
      List<dynamic> forecastList = jsonForecast['daily'];
      forecast = forecastList.map((w) {
        return Weather.sevenDay(w);
      }).toList();
      return forecast;
    } else {
      throw OpenWeatherAPIException(
          "The API threw an exception: ${response.body}");
    }
  } catch (exception) {
    print(exception);
  }
  return null;
}

class OpenWeatherAPIException implements Exception {
  String _cause;

  OpenWeatherAPIException(this._cause);

  String toString() => '${this.runtimeType} - $_cause';
}
