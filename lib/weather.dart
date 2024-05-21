import 'package:http/http.dart' as http; // For making API calls
import 'dart:convert'; // For JSON parsing
import 'package:geolocator/geolocator.dart';
// Weather Model Class
class Weather {
  final double temperature;
  final String description;
  final String iconCode;
  final String name;

  Weather(this.temperature, this.description, this.iconCode, this.name);

  // Function to convert Kelvin to Celsius (customizable based on your needs)
  double get celciusTemperature => temperature;
  String get weatherIconUrl => 'https://openweathermap.org/img/wn/$iconCode@2x.png';
}

class WeatherService {
  static const String apiKey = 'b8eef573a6187028c52c72ea4a69e43a'; // Replace with your API key
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<Weather> getWeather(Position city) async {
    double lat = city.latitude;
    double long = city.longitude;
    final response = await http.get(Uri.parse('$baseUrl?lat=$lat&lon=$long&appid=$apiKey&units=metric'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Weather(
          data['main']['temp'],
          data['weather'][0]['description'],
          data['weather'][0]['icon'],
          data['name']);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}