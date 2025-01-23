import 'package:flutter/material.dart';

void main() => runApp(const SliderApp());

class SliderApp extends StatelessWidget {
  const SliderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SliderExample(),
    );
  }
}

class SliderExample extends StatefulWidget {
  const SliderExample({super.key});

  @override
  State<SliderExample> createState() => _SliderExampleState();
}

class _SliderExampleState extends State<SliderExample> {
  double _currentSliderValue = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Slider')),
      body: Slider(
        value: _currentSliderValue,
        max: 255,
        divisions: 255,
        label: _currentSliderValue.round().toString(),
        onChanged: (double value) {
          setState(() {
            _currentSliderValue = value;
          });
        },
      ),
    );
  }
}

class CoresSelecionadasTela extends StatelessWidget {
  final List<Color> cores;

  const CoresSelecionadasTela({super.key, required this.cores});

  Color _calcularMistura() {
    if (cores.isEmpty) return Colors.white;
    if (cores.length == 1) return cores.first;

    // Calcular a média das cores
    int r = 0, g = 0, b = 0;
    for (final cor in cores) {
      r += cor.red;
      g += cor.green;
      b += cor.blue;
    }
    return Color.fromARGB(255, r, g, b);
  }

  @override
  Widget build(BuildContext context) {
    final Color corFinal = _calcularMistura();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Resultado das cores selecionadas',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: corFinal,
                border: Border.all(color: Colors.black, width: 3),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
