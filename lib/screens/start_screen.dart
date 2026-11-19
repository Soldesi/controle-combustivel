import 'package:flutter/material.dart';
import '../app_state.dart';
import '../format.dart';
import '../theme.dart';
import 'refuel_form_screen.dart';

/// Tela inicial: resumo do veículo e atalhos.
class StartScreen extends StatelessWidget {
  final void Function(int tab) onGoTo;
  const StartScreen({super.key, required this.onGoTo});

  @override
  Widget build(BuildContext context) {
    final v = appState.vehicle;
    final ind = appState.indicators;
    final totalSpent = ind.fold<double>(0, (s, e) => s + e.refuel.total);
    final withData = ind.where((e) => e.kmPerL != null).toList();
    final last = appState.sortedDesc.isEmpty ? null : appState.sortedDesc.first;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kGreenDark, kGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 34,
                backgroundColor: Colors.white24,
                child: Icon(Icons.local_gas_station,
                    color: Colors.white, size: 38),
              ),
              const SizedBox(height: 12),
              const Text('Controle de Combustível',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                v == null
                    ? 'Comece cadastrando seu veículo'
                    : '${v.brand} ${v.model} - ${v.year}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: v == null ? _noVehicle() : _summary(context, totalSpent, withData.length, ind.length, last),
        ),
      ],
    );
  }

  Widget _noVehicle() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.directions_car_outlined,
                size: 56, color: kGreenLight),
            const SizedBox(height: 12),
            const Text('Nenhum veículo cadastrado',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text(
              'Cadastre seu veículo para registrar abastecimentos e acompanhar seus gastos.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => onGoTo(1),
              icon: const Icon(Icons.add),
              label: const Text('Cadastrar veículo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summary(BuildContext context, double totalSpent, int withData,
      int count, dynamic last) {
    final indicators = appState.indicators;
    final lastKmL = indicators.reversed
        .map((e) => e.kmPerL)
        .firstWhere((e) => e != null, orElse: () => null);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _Stat('Total gasto', money(totalSpent), Icons.payments),
            _Stat('Abastecimentos', '$count', Icons.local_gas_station),
            _Stat('Último km/L', lastKmL == null ? '—' : num2(lastKmL),
                Icons.speed),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          color: Colors.white,
          child: ListTile(
            leading: const CircleAvatar(
                backgroundColor: kGreenLight,
                child: Icon(Icons.history, color: Colors.white)),
            title: Text(last == null
                ? 'Nenhum abastecimento ainda'
                : 'Último: ${last.fuel.label} - ${money(last.total)}'),
            subtitle: Text(last == null
                ? 'Registre o primeiro para começar'
                : dateTimeStr(last.date)),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const RefuelFormScreen())),
          icon: const Icon(Icons.add),
          label: const Text('Novo abastecimento'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => onGoTo(3),
          icon: const Icon(Icons.insights),
          label: const Text('Ver dashboard'),
          style: OutlinedButton.styleFrom(
              foregroundColor: kGreenDark,
              minimumSize: const Size.fromHeight(50)),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _Stat(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          child: Column(
            children: [
              Icon(icon, color: kGreen, size: 22),
              const SizedBox(height: 4),
              FittedBox(
                child: Text(value,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kGreenDark)),
              ),
              Text(label,
                  style: const TextStyle(fontSize: 11, color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }
}
