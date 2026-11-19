import 'package:flutter/material.dart';
import '../app_state.dart';
import '../format.dart';
import '../models.dart';
import '../theme.dart';

class RefuelFormScreen extends StatefulWidget {
  const RefuelFormScreen({super.key});

  @override
  State<RefuelFormScreen> createState() => _RefuelFormScreenState();
}

class _RefuelFormScreenState extends State<RefuelFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _price = TextEditingController();
  final _km = TextEditingController();
  final _liters = TextEditingController();
  Fuel _fuel = Fuel.gasolina;
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _price.dispose();
    _km.dispose();
    _liters.dispose();
    super.dispose();
  }

  double get _total =>
      (parseNum(_price.text) ?? 0) * (parseNum(_liters.text) ?? 0);

  String? _positive(String? v, String label) {
    final n = parseNum(v);
    if (n == null || n <= 0) return 'Informe $label válido';
    return null;
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (d == null || !mounted) return;
    final t = await showTimePicker(
        context: context, initialTime: TimeOfDay.fromDateTime(_date));
    if (t == null) return;
    setState(() => _date = DateTime(d.year, d.month, d.day, t.hour, t.minute));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await appState.addRefuel(Refuel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      fuel: _fuel,
      pricePerLiter: parseNum(_price.text)!,
      km: parseNum(_km.text)!,
      liters: parseNum(_liters.text)!,
      date: _date,
    ));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const dec = TextInputType.numberWithOptions(decimal: true);
    return Scaffold(
      appBar: AppBar(title: const Text('Novo abastecimento')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Combustível',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SegmentedButton<Fuel>(
              segments: Fuel.values
                  .map((f) => ButtonSegment(value: f, label: Text(f.label)))
                  .toList(),
              selected: {_fuel},
              onSelectionChanged: (s) => setState(() => _fuel = s.first),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _price,
              keyboardType: dec,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                  labelText: 'Preço por litro', prefixText: 'R\$ '),
              validator: (v) => _positive(v, 'um preço'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _km,
              keyboardType: dec,
              decoration: const InputDecoration(
                  labelText: 'Quilometragem atual', suffixText: 'km'),
              validator: (v) =>
                  _positive(v, 'a quilometragem') ??
                  appState.validateKm(parseNum(v)!, _date),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _liters,
              keyboardType: dec,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                  labelText: 'Litros abastecidos', suffixText: 'L'),
              validator: (v) => _positive(v, 'a quantidade'),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                    labelText: 'Data e horário',
                    suffixIcon: Icon(Icons.calendar_month)),
                child: Text(dateTimeStr(_date)),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kGreenLight.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Valor total',
                      style: TextStyle(fontSize: 16)),
                  Text(money(_total),
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: kGreenDark)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: const Text('Salvar abastecimento'),
            ),
          ],
        ),
      ),
    );
  }
}
