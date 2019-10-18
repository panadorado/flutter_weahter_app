import 'dart:async';
import 'dart:convert' show json;
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../util/utils.dart' as util;
import 'package:intl/intl.dart';

class Klimatic extends StatefulWidget {

  @override
  _KlimaticState createState() => _KlimaticState();
}

class _KlimaticState extends State<Klimatic> {

  String _cityEntered;
  int animReload = 5;

  void _showExit() {
    AlertDialog dialog = new AlertDialog (
      title: Center(child: Text('Chú ý!',style: TextStyle(fontSize: 18.0, color: Colors.white),),),
      content: Text("Bạn có muốn thoát ?",style: styleDialog(),),
      backgroundColor: Color.fromARGB(255, 24, 24, 24),
      actions: <Widget>[
        FlatButton(
          onPressed: ()=>exit(0),
          child: Text('Yes'),
        ),
        FlatButton(
          onPressed: ()=> Navigator.pop(context),
          child: Text('No'),
        )
      ],
    );
    showDialog(context: context, child: dialog);
  }

  /*Future<void> thenAsync() async{
    Future.delayed(Duration(seconds: 5)).then((_){
      setState(() => updateTempWidget(_cityEntered));
    }).catchError((e){
      print('failed: ${e.toString()}');
    });
  }*/

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App',style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Color.fromARGB(250, 24, 24, 24),
      ),
      body: Stack(
          children: <Widget>[
            Center(child: Image.asset('images/bg_weather_3.png', width: 360.0, fit: BoxFit.fill,),),
            Center(child: Padding(
              padding: const EdgeInsets.fromLTRB(68.0, 130.0, 68.0, 130.0),
              child: Card(
                color: Color.fromARGB(75, 24, 24, 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('${_cityEntered == null ? util.defaultCity : _cityEntered}', style: cityStyle()),
                    Text(DateFormat('hh:mm:ss').format(now), style: tempStyle(),),
                    Text(DateFormat('dd/MM/yyyy').format(now), style: tempStyle()),
                    updateTempWidget(_cityEntered),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.fromLTRB(0.0, 350.0, 0.0, 0.0),
                  color: Color.fromARGB(100, 24, 24, 24),
                  width: 50,
                  height: 50,
                  child: IconButton(
                      icon: Icon(Icons.refresh),
                      color: Colors.white,
                      onPressed: (){
                        setState(() {
                          setState(() => updateTempWidget(_cityEntered));
                        });
                      }
                  ),
                ),
                Padding(padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0)),
                Container(
                  margin: const EdgeInsets.fromLTRB(0.0, 350.0, 0.0, 0.0),
                  color: Color.fromARGB(100, 24, 24, 24),
                  width: 50,
                  height: 50,
                  child: IconButton(
                      icon: Icon(Icons.close),
                      color: Colors.white,
                      onPressed: (){
                        setState(() {
                          _showExit();
                        });
                      }
                  ),
                ),
              ],
            )
          ),
        ]
      ),
    );
  }

  Future<Map> getWeather(String appId, String city) async {
    String apiUrl = 'http://api.openweathermap.org/data/2.5/weather?q=$city,VN&appid='
        '${util.appId}&units=metric';

    http.Response response = await http.get(apiUrl);
    return json.decode(response.body);
  }

  Widget updateTempWidget(String city) {
    return new FutureBuilder(
        future: getWeather(util.appId, city == null ? util.defaultCity : city),
        builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
          //where we get all of the json data, we setup  widget etc.
          if (snapshot.hasData) {
            Map content = snapshot.data;
            return new Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.network('https://openweathermap.org/img/wn/' + content['weather'][0]['icon'].toString() + '@2x.png', width: 78.0,),
                    Text(content['weather'][0]['description'].toString(), style: tempStyle(),),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Text('Temperature:         ', style: tempStyle(),),
                        Text('Humidity:   ', style: tempStyle(),),
                        Text('Pressure:   ', style: tempStyle(),),
                        Text('Wind speed:        ', style: tempStyle(),)
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Text(content['main']['temp'].toString() + '°C', style: tempStyle(),),
                        Text(content['main']['humidity'].toString() + '%', style: tempStyle(),),
                        Text(content['main']['pressure'].toString() + 'hpa', style: tempStyle(),),
                        Text(content['wind']['speed'].toString() + 'm/s', style: tempStyle(),),
                      ],
                    )
                  ],
                )
              ],
            );
          }
          else {
            return Container();
          }
        }
    );
  }
}

TextStyle cityStyle() {
  return TextStyle(
      color: Colors.white,
      fontSize: 20.9,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.bold
  );
}

TextStyle tempStyle() {
  return TextStyle(
    color: Colors.white,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w500,
    fontSize: 16.0,
  );
}

TextStyle styleDialog() {
  return TextStyle(
    color: Colors.white,
  );
}