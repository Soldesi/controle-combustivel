import 'package:flutter/material.dart';
import '../app_state.dart';
import '../format.dart';
import '../models.dart';
import '../theme.dart';
import 'refuel_form_screen.dart';

class FuelListScreen extends StatelessWidget {
  final VoidCallback onGoToVehicle;
  const FuelListScreen({super.key, required this.onGoToVehicle});

  Future<void> _confirmDelete(BuildContext context, Refuel r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir abastecimento?'),
        content: Text('${r.fuel.label} - ${dateTimeStr(r.date)}'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Excluir')),
        ],
      ),
    );
    if (ok == true) await appState.deleteRefuel(r.id);
  }

  @override
  Widget build(BuildContext context) {
    if (appState.vehicle == null) {
      return _Empty(
        icon: Icons.directions_car_outlined,
        text: 'Cadastre um veículo para registrar abastecimentos.',
        action: FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(200, 48)),
          onPressed: onGoToVehicle,
          child: const Text('Cadastrar veículo'),
        ),
      );
    }
    final list = appState.sortedDesc;
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const RefuelFormScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Abastecer'),
      ),
      body: list.isEmpty
          ? const _Empty(
              icon: Icons.local_gas_station_outlined,
              text: 'Nenhum abastecimento registrado ainda.')
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final r = list[i];
                return Card(
                  color: Colors.white,
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: kGreenLight,
                      child: Icon(Icons.local_gas_station, color: Colors.white),
                    ),
                    title: Text('${r.fuel.label} - ${money(r.total)}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        '${dateTimeStr(r.date)}\n'
                        '${num2(r.liters)} L x ${money(r.pricePerLiter)} | ${num0(r.km)} km'),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _confirmDelete(context, r),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _Empty extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget? action;
  const _Empty({required this.icon, required this.text, this.action});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: kGreenLight),
            const SizedBox(height: 12),
            Text(text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black54)),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}
