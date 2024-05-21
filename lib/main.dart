import 'package:flutter/material.dart';
import 'package:weatherapp/weather.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(const WeatherApp());
}



Future<Position> getLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the 
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale 
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // Get the device's current location
  return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
}

// Main App Screen
class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<WeatherApp> {
  Weather? weatherData;
  String city = 'London';

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  void _fetchWeather() async {
    Position location = await getLocation();
    String apiKey = dotenv.env['API_KEY'] ?? '';
    final weatherService = WeatherService(apiKey);
    final weather = await weatherService.getWeather(location);
    city = weather.name;
    setState(() {
      weatherData = weather;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Weather App'),
        ),
        body: Center(
          child: weatherData == null
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      city,
                      style: const TextStyle(fontSize: 48),
                    ),
                    Text(
                      '${weatherData!.celciusTemperature.toStringAsFixed(1)}°C',
                      style: const TextStyle(fontSize: 56),
                    ),
                    Text(weatherData!.description, 
                    style: const TextStyle(fontSize: 24)),
                    // Add an image widget to display weather icon based on iconCode
                    Image.network(
                      weatherData!.weatherIconUrl,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
