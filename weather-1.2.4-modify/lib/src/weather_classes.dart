/*
 * Copyright 2018 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */
part of weather_library;

/// A class for holding a temperature.
/// Can output temperature as Kelvin, Celsius or Fahrenheit.
/// All results are returned as [double].
class Temperature {
  double _kelvin;

  Temperature(this._kelvin);

  /// Convert temperature to Kelvin
  double get kelvin => _kelvin;

  /// Convert temperature to Celsius
  double get celsius => _kelvin - 273.15;

  /// Convert temperature to Fahrenheit
  double get fahrenheit => _kelvin * (9 / 5) - 459.67;

  double rightUnits(int units) {
    if (units == 0) {
      return kelvin;
    } else if (units == 1) {
      return celsius;
    } else if (units == 2) {
      return fahrenheit;
    }
    return kelvin;
  }

  String toString() => '${fahrenheit.toStringAsFixed(1)} ˚F';
}

/// A class for storing a weather-query response from OpenWeatherMap.
/// This includes various measures such as location,
/// temperature, wind, snow, rain and humidity.
class Weather {
  String _country, _areaName, _weatherMain, _weatherDescription, _weatherIcon;
  Temperature _temperature, _tempMin, _tempMax, _tempFeelsLike;
  Map<String, dynamic> _weatherData;

  DateTime _date, _sunrise, _sunset;
  double _latitude,
      _longitude,
      _pressure,
      _windSpeed,
      _windDegree,
      _windGust,
      _humidity,
      _cloudiness;

  int _weatherConditionCode;

  Weather.current(Map<String, dynamic> jsonData) {
    Map<String, dynamic> main = jsonData['main'];
    Map<String, dynamic> coord = jsonData['coord'];
    Map<String, dynamic> sys = jsonData['sys'];
    Map<String, dynamic> wind = jsonData['wind'];
    Map<String, dynamic> clouds = jsonData['clouds'];
    Map<String, dynamic> weather = jsonData['weather'][0];

    _latitude = _unpackDouble(coord, 'lat');
    _longitude = _unpackDouble(coord, 'lon');

    _country = _unpackString(sys, 'country');
    _sunrise = _unpackDate(sys, 'sunrise');
    _sunset = _unpackDate(sys, 'sunset');

    _weatherData = jsonData;
    _weatherMain = _unpackString(weather, 'main');
    _weatherDescription = _unpackString(weather, 'description');
    _weatherIcon = _unpackString(weather, 'icon');
    _weatherConditionCode = _unpackInt(weather, 'id');

    _temperature = _unpackTemperature(main, 'temp');
    _tempMin = _unpackTemperature(main, 'temp_min');
    _tempMax = _unpackTemperature(main, 'temp_max');
    _tempFeelsLike = _unpackTemperature(main, 'feels_like');

    _humidity = _unpackDouble(main, 'humidity');
    _pressure = _unpackDouble(main, 'pressure');

    _windSpeed = _unpackDouble(wind, 'speed');
    _windDegree = _unpackDouble(wind, 'deg');
    _windGust = _unpackDouble(wind, 'gust');

    _cloudiness = _unpackDouble(clouds, 'all');

    _areaName = _unpackString(jsonData, 'name');
    _date = _unpackDate(jsonData, 'dt');
  }

  Weather.sevenDay(Map<String, dynamic> jsonData) {
    Map<String, dynamic> temp = jsonData['temp'];
    Map<String, dynamic> weather = jsonData['weather'][0];

    // _weatherData = jsonData;
    _weatherMain = _unpackString(weather, 'main');
    _weatherDescription = _unpackString(weather, 'description');
    _weatherIcon = _unpackString(weather, 'icon');
    _weatherConditionCode = _unpackInt(weather, 'id');

    _tempMin = _unpackTemperature(temp, 'min');
    _tempMax = _unpackTemperature(temp, 'max');
    _date = _unpackDate(jsonData, 'dt');
  }

  /// The original JSON data from the API
  Map<String, dynamic> toJson() => _weatherData;

  /// A long description of the weather
  String get weatherDescription => _weatherDescription;

  /// A brief description of the weather
  String get weatherMain => _weatherMain;

  /// Icon depicting current weather
  String get weatherIcon => _weatherIcon;

  /// Weather condition codes
  int get weatherConditionCode => _weatherConditionCode;

  /// The level of cloudiness in Okta (0-9 scale)
  double get cloudiness => _cloudiness;

  /// Wind direction in degrees
  double get windDegree => _windDegree;

  /// Wind speed in m/s
  double get windSpeed => _windSpeed;

  /// Wind gust in m/s
  double get windGust => _windGust;

  /// Max [Temperature]. Available as Kelvin, Celsius and Fahrenheit.
  Temperature get tempMax => _tempMax;

  /// Min [Temperature]. Available as Kelvin, Celsius and Fahrenheit.
  Temperature get tempMin => _tempMin;

  /// Mean [Temperature]. Available as Kelvin, Celsius and Fahrenheit.
  Temperature get temperature => _temperature;

  /// The 'feels like' [Temperature]. Available as Kelvin, Celsius and Fahrenheit.
  Temperature get tempFeelsLike => _tempFeelsLike;

  /// Pressure in Pascal
  double get pressure => _pressure;

  /// Humidity in percent
  double get humidity => _humidity;

  /// Longitude of the weather observation
  double get longitude => _longitude;

  /// Latitude of the weather observation
  double get latitude => _latitude;

  /// Date of the weather observation
  DateTime get date => _date;

  /// Timestamp of sunset
  DateTime get sunset => _sunset;

  /// Timestamp of sunrise
  DateTime get sunrise => _sunrise;

  /// Name of the area, ex Mountain View, or Copenhagen Municipality
  String get areaName => _areaName;

  /// Country code, ex US or DK
  String get country => _country;
}
