
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:weather_app/bloc/weather_bloc.dart';
import 'package:weather_app/presentation/widget/additional_info_item.dart';
import 'package:weather_app/presentation/widget/hourly_forecast_item.dart';


class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _controller = TextEditingController();


  @override
  void initState() {
    super.initState();
    context.read<WeatherBloc>().add(WeatherFetched());

  }
  @override
  void dispose() {
    _controller.dispose(); // Dispose of the controller
    super.dispose();
  }

  void _weatherUpdatefetched() {
    String cityName = _controller.text.trim();
    if (cityName.isNotEmpty) {
      context.read<WeatherBloc>().add(WeatherFetchedByCity(cityName));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
               context.read<WeatherBloc>().add(WeatherFetched());
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocBuilder<WeatherBloc, WeatherState>(
        builder: (context, state) {

          if (state is WeatherFailure) {
            return Center(
              child: Text(state.error),
            );
          }
          if (state is! WeatherSuccess) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }

          final data = state.weatherModel;
          final currentCity = state.currentCity;

          final currentTemp = (data.currentTemp - 273.15).toInt();
          final currentSky = data.currentSky;
          final currentPressure = data.currentPressure;
          final currentWindSpeed = data.currentWindSpeed;
          final currentHumidity = data.currentHumidity;

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    keyboardType: TextInputType.text,
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter city name', // Hint text to guide the user
                      border: OutlineInputBorder(), // Optional: adds a border to the TextField
                    ),
                    onSubmitted: (value) {
                      // This is called when the user presses the "Enter" key
                      if (value.isNotEmpty) {
                        _weatherUpdatefetched(); // Call your function to fetch weather
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 50,
                      child:Text(
                        '$currentCity', // Display the current city name
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),                  ),
                    ),
                  ),
                  // main card
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 10,
                            sigmaY: 10,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  '$currentTemp C',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Icon(
                                  currentSky == 'Clouds' || currentSky == 'Rain'
                                      ? Icons.cloud
                                      : Icons.sunny,
                                  size: 64,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  currentSky,
                                  style: const TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Hourly Forecast',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SizedBox(
                      height: 120,
                      child: ListView.builder(
                        itemCount: 55, // This can be the length of hourlyForecast if you want to show more dynamically
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          // Assuming `data` is your WeatherModel instance
                          final hourlySky = data.hourlySky;
                          final hourlyTemp = data.hourlyTemp.map((temp) => (temp - 273.15).toDouble()).toList(); // Convert each temperature to Celsius
                          final dateTimes = data.dateTime; // This is now List<String>

                          // Parsing the datetime string to DateTime
                          final time = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTimes[index]);

                          return HourlyForecastItem(
                            time: DateFormat.j().format(time), // Formatting the time for display
                            temperature: hourlyTemp[index].toStringAsFixed(1), // Convert temperature to string with one decimal
                            icon: hourlySky[index] == 'Clouds' || hourlySky[index] == 'Rain'
                                ? Icons.cloud
                                : Icons.sunny,
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'Additional Information',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      AdditionalInfoItem(
                        icon: Icons.water_drop,
                        label: 'Humidity',
                        value: currentHumidity.toString(),
                      ),
                      AdditionalInfoItem(
                        icon: Icons.air,
                        label: 'Wind Speed',
                        value: currentWindSpeed.toString(),
                      ),
                      AdditionalInfoItem(
                        icon: Icons.beach_access,
                        label: 'Pressure',
                        value: currentPressure.toString(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
