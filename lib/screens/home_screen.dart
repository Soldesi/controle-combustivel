import 'package:flutter/material.dart';
import '../app_state.dart';
import 'dashboard_screen.dart';
import 'fuel_list_screen.dart';
import 'start_screen.dart';
import 'vehicle_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _titles = [
    'Início',
    'Meu veículo',
    'Abastecimentos',
    'Dashboard',
  ];

  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: Text(_titles[_index])),
          body: IndexedStack(
            index: _index,
            children: [
              StartScreen(onGoTo: _go),
              const VehicleScreen(),
              FuelListScreen(onGoToVehicle: () => _go(1)),
              DashboardScreen(onGoToVehicle: () => _go(1)),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: _go,
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Início'),
              NavigationDestination(
                  icon: Icon(Icons.directions_car_outlined),
                  selectedIcon: Icon(Icons.directions_car),
                  label: 'Veículo'),
              NavigationDestination(
                  icon: Icon(Icons.local_gas_station_outlined),
                  selectedIcon: Icon(Icons.local_gas_station),
                  label: 'Abastecer'),
              NavigationDestination(
                  icon: Icon(Icons.insights_outlined),
                  selectedIcon: Icon(Icons.insights),
                  label: 'Dashboard'),
            ],
          ),
        );
      },
    );
  }
}
