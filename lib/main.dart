/*
 * Copyright 2018 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */
import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:weather/weather.dart';
import 'package:flutter/cupertino.dart';

enum AppState {
  NOT_DOWNLOADED,
  DOWNLOADING,
  FINISHED_DOWNLOADING,
  INCORRECT_CITYNAME
}

List<String> weekDayNames = [
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
  "Sunday"
];

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String key = '2d3e871755009b4111c05c8d092fdbcd';
  List<Weather> _data = [];
  bool _visibleSettings = false;
  int segmentedControlValue = 0;
  int units = 1;
  Icon rightIcon = Icon(Icons.settings);
  AppState _state = AppState.NOT_DOWNLOADED;
  String cityname;

  Map<AppState, String> stateOutputMap = {
    AppState.NOT_DOWNLOADED: 'Click the settings button to set a location',
    AppState.INCORRECT_CITYNAME: 'No city found with that name'
  };

  @override
  void initState() {
    super.initState();
  }

  void queryForecast() async {
    /// Removes keyboard
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      _state = AppState.DOWNLOADING;
    });

    Weather current = await currentWeatherByCityName(cityname, key);

    if (current == null) {
      setState(() {
        _state = AppState.INCORRECT_CITYNAME;
      });
    }

    double lat = current.latitude;
    double long = current.longitude;

    List<Weather> forecasts = await sevenDayForecastByLocation(lat, long, key);
    forecasts.insert(0, current);

    setState(() {
      _data = forecasts;
      _state = AppState.FINISHED_DOWNLOADING;
    });
  }

  Image getWeatherImage(String description, double width) {
    print(description);
    if (description == 'Clouds') {
      return Image.asset(
        'assets/images/clouds.png',
        alignment: Alignment.centerLeft,
        width: width,
      );
    } else if (description == 'Rain') {
      return Image.asset(
        'assets/images/rain.png',
        alignment: Alignment.centerLeft,
        width: width,
      );
    } else if (description == 'Snow') {
      return Image.asset(
        'assets/images/snow.png',
        alignment: Alignment.centerLeft,
        width: width - 2,
      );
    } else {
      return Image.asset(
        'assets/images/sun.png',
        alignment: Alignment.centerLeft,
        width: width,
      );
    }
  }

  Widget contentFinishedDownload() {
    return Center(
        child: Column(
      children: [
        SizedBox(height: 24),
        Expanded(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: _data.length == 0 ? 0 : _data.length - 1,
            itemBuilder: (context, index) {
              return Container(
                  height: 36,
                  color: Colors.black,
                  child: ListTile(
                    title: Container(
                      child: Row(
                        children: [
                          Expanded(
                              child: Text(
                            weekDayNames[_data[index + 1].date.weekday - 1],
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.normal),
                          )),
                          Builder(builder: (context) {
                            return getWeatherImage(
                                _data[index + 1].weatherMain, 28);
                          }),
                          SizedBox(width: 100),
                          Container(
                            width: 40,
                            child: Text(
                                _data[index + 1]
                                    .tempMax
                                    .rightUnits(units)
                                    .toStringAsFixed(0),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                )),
                          ),
                          SizedBox(width: 20),
                          Container(
                            width: 40,
                            child: Text(
                                _data[index + 1]
                                    .tempMin
                                    .rightUnits(units)
                                    .toStringAsFixed(0),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w200,
                                )),
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ));
            },
            separatorBuilder: (context, index) {
              return Divider();
            },
          ),
        )
      ],
    ));
  }

  Widget contentDownloading() {
    return Container(
        margin: EdgeInsets.all(25),
        child: Column(children: [
          Text(
            'Fetching Weather...',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          Container(
              margin: EdgeInsets.only(top: 50),
              child: Center(child: CircularProgressIndicator(strokeWidth: 10)))
        ]));
  }

  Widget noContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(stateOutputMap[_state],
              style: TextStyle(
                color: Colors.white,
              )),
        ],
      ),
    );
  }

  Widget _resultView() => _state == AppState.FINISHED_DOWNLOADING
      ? contentFinishedDownload()
      : _state == AppState.DOWNLOADING
          ? contentDownloading()
          : noContent();

  void _saveCity(String input) {
    cityname = input;
    print(cityname);
  }

  Widget _coordinateInputs() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
              margin: EdgeInsets.all(8),
              child: TextField(
                  // initialValue: "hellp",
                  style: TextStyle(
                      fontSize: 14.0, height: 1.0, color: Colors.black),
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: cityname,
                      fillColor: Colors.white,
                      filled: true,
                      hintStyle: TextStyle(color: Colors.black),
                      isDense: true),
                  keyboardType: TextInputType.text,
                  onChanged: _saveCity,
                  onSubmitted: _saveCity)),
        ),
        Container(
            margin: EdgeInsets.all(5),
            width: 200,
            child: CupertinoSlidingSegmentedControl(
                groupValue: units,
                backgroundColor: Color(0x8AAFAFAF),
                thumbColor: Colors.white,
                children: const <int, Widget>{
                  0: Text('˚K'),
                  1: Text('˚C'),
                  2: Text('˚F')
                },
                onValueChanged: (value) {
                  setState(() {
                    units = value;
                    print(units);
                  });
                }))
      ],
    );
  }

  Widget _settingsWidget() {
    return Column(children: [
      _coordinateInputs(),
      Divider(
        height: 20.0,
        thickness: 2.0,
        color: Colors.white,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Color(0xFF232323),
            leading: IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                queryForecast();
              },
            ),
            actions: [
              IconButton(
                icon: rightIcon,
                onPressed: () {
                  setState(() {
                    if (_visibleSettings) {
                      rightIcon = Icon(Icons.settings);
                      queryForecast();
                    } else {
                      rightIcon = Icon(Icons.check);
                    }
                    _visibleSettings = !_visibleSettings;
                  });
                },
              )
            ],
            title: Text('Weather App'),
          ),
          body: Column(
            children: <Widget>[
              Visibility(
                visible: _visibleSettings,
                child: _settingsWidget(),
              ),
              Expanded(child: _resultView())
            ],
          )),
    );
  }
}
