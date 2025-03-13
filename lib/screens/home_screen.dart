import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:weatherapp/bloc/weather_bloc_bloc.dart';

class HomeScreen extends StatefulWidget {
  final Position position;
  const HomeScreen({super.key, required this.position});
  

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // final ScrollController _scrollController = ScrollController();
  // final _offsetToArmed = 220.0;
  bool _isDayTime(DateTime currentTime, DateTime sunrise, DateTime sunset) {
    // Check if current time is between sunrise and sunset
    return currentTime.isAfter(sunrise) && currentTime.isBefore(sunset);
  }
  bool isDayTime = true;
  Widget getWeatherIcon(
    int code,
    DateTime currentTime,
    DateTime sunrise,
    DateTime sunset,
  ) {
    isDayTime = _isDayTime(currentTime, sunrise, sunset);
    switch (code) {
      case >= 200 && < 300:
        return Image.asset(
          isDayTime ? 'assets/thunderstorm.png' : 'assets/thunderstorm.png',
        );
      case >= 300 && < 400:
        return Image.asset(
          isDayTime ? 'assets/drizzle.png' : 'assets/drizzle.png',
        );
      case >= 500 && < 600:
        return Image.asset(isDayTime ? 'assets/rain.png' : 'assets/rain.png');
      case >= 600 && < 700:
        return Image.asset(isDayTime ? 'assets/snow.png' : 'assets/snow.png');
      case >= 700 && < 800:
        return Image.asset(
          isDayTime ? 'assets/atmosphere.png' : 'assets/atmosphere.png',
        );
      case == 800:
        return Image.asset(
          isDayTime ? 'assets/clear.png' : 'assets/nightc.png',
        );
      case > 800 && <= 804:
        return Image.asset(
          isDayTime ? 'assets/clouds.png' : 'assets/cloudy2.png',
        );
      default:
        return Image.asset(
          isDayTime ? 'assets/clouds.png' : 'assets/cloudy2.png',
        );
    }
  }

  String getGreeting(DateTime time) {
    int hour = time.hour; // Get the hour from the time

    if (hour >= 3.30 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 15.30) {
      return 'Good Afternoon';
    } else if (hour >= 15.30 && hour < 22) {
      return 'Good Evening';
    } else {
      return 'Good Night'; // After 10 PM, it's night time
    }
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   statusBarColor: Colors.transparent, // Transparent status bar
    //   statusBarIconBrightness: Brightness.dark, // Set status bar icon brightness
    // ));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ),
        
      ),
      body: Padding(
        // padding: const EdgeInsets.fromLTRB(40, 50, 40, 20),
        padding: const EdgeInsets.fromLTRB(40, 1.2 * kToolbarHeight, 40, 20),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Align(
                alignment: const AlignmentDirectional(3, -0.3),
                child: Container(
                  height: 300,
                  width: 300,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    // color: Colors.deepPurple,
                    color: Color(0xFF673AB7),
                    // color: Color.fromARGB(255, 147, 64, 255),
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(-3, -0.3),
                child: Container(
                  height: 300,
                  width: 300,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF673AB7),
                    // color: Color.fromARGB(255, 147, 64, 255),
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0, -1.2),
                child: Container(
                  height: 300,
                  width: 600,
                  decoration: const BoxDecoration(
                    // color: Color(0xFFFFAB40),
                    color: Color.fromARGB(255, 40, 0, 110),
                    ),
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
                child: Container(
                  decoration: const BoxDecoration(color: Colors.transparent),
                ),
              ),

              BlocBuilder<WeatherBlocBloc, WeatherBlocState>(
                builder: (context, state) {
                  if (state is WeatherBlocSuccess) {
                    return RefreshIndicator(
                      color: Colors.white60,
                      backgroundColor: Colors.transparent,
                      onRefresh: () async {
                        // Perform your asynchronous operation
                        await Future.delayed(Duration(seconds: 2));
                        // Check if the widget is still mounted before using BuildContext
                        if (context.mounted) {
                          // Your logic that uses BuildContext
                          context.read<WeatherBlocBloc>().add(
                            FetchWeather(widget.position),
                          );
                        }
                      },
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                // 'Good Morning',
                                getGreeting(state.weather.date!),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '📍 ${state.weather.areaName}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              const SizedBox(height: 8),
                              getWeatherIcon(
                                state.weather.weatherConditionCode!,
                                state.weather.date as DateTime,
                                state.weather.sunrise as DateTime,
                                state.weather.sunset as DateTime,
                              ),
                              Center(
                                child: Text(
                                  '${state.weather.temperature!.celsius!.round()}°C',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 55,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  state.weather.weatherMain!.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Center(
                                child: Text(
                                  // DateFormat('EEEE dd •').add_jm().format(state.weather.date!),
                                  DateFormat(
                                    'EEEE dd MMMM',
                                  ).format(state.weather.date!),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              // ##############################################
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset('assets/11.png', scale: 8),
                                      const SizedBox(width: 5),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Sunrise',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            DateFormat().add_jm().format(
                                              state.weather.sunrise!,
                                            ),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Image.asset('assets/12.png', scale: 8),
                                      const SizedBox(width: 5),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Sunset',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            DateFormat().add_jm().format(
                                              state.weather.sunset!,
                                            ),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.0),
                                child: Divider(color: Colors.grey),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset('assets/13.png', scale: 8),
                                      const SizedBox(width: 5),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Temp Max',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            "${state.weather.tempMax!.celsius!.toStringAsFixed(2)} °C",
                                            // "${state.weather.tempMax!.celsius!.round()} °C",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Image.asset('assets/14.png', scale: 8),
                                      const SizedBox(width: 5),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Temp Min',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            "${state.weather.tempMin!.celsius!.toStringAsFixed(2)} °C",
                                            // "${state.weather.tempMin!.celsius!.round()} °C",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else if (state is WeatherBlocFailure) {
                    return RefreshIndicator(
                      color: Colors.white60,
                      backgroundColor: Colors.transparent ,
                      onRefresh: () async {
                        // Perform your asynchronous operation
                        await Future.delayed(Duration(seconds: 2));

                        // Check if the widget is still mounted before using BuildContext
                        if (context.mounted) {
                          // Your logic that uses BuildContext
                          context.read<WeatherBlocBloc>().add(FetchWeather(widget.position));
                        }
                      },
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child:  SingleChildScrollView(
                          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                          child:  Text(
                        "Please check your internet connection and try again",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    )));
                  }
                  else{
                    return Center(child: CircularProgressIndicator(color: Colors.white60, backgroundColor: Colors.transparent,));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
