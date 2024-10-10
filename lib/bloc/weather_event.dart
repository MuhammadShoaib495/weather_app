part of 'weather_bloc.dart';

@immutable
sealed class WeatherEvent {}
final class WeatherFetched extends WeatherEvent{}
final class WeatherFetchedByCity extends WeatherEvent{
  final String cityName;

  WeatherFetchedByCity(this.cityName);
}