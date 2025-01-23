import 'package:flutter/material.dart';

void main() => runApp(const ColorMixerApp());

class ColorMixerApp extends StatelessWidget {
  const ColorMixerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const ColorMixerScreen(),
    );
  }
}

class ColorMixerScreen extends StatefulWidget {
  const ColorMixerScreen({super.key});

  @override
  State<ColorMixerScreen> createState() => _ColorMixerScreenState();
}

class _ColorMixerScreenState extends State<ColorMixerScreen> {
  double _red = 0;
  double _green = 0;
  double _blue = 0;

  @override
  Widget build(BuildContext context) {
    Color mixedColor =
        Color.fromRGBO(_red.toInt(), _green.toInt(), _blue.toInt(), 1);

    return Scaffold(
      appBar: AppBar(title: const Text('Misturador de Cores')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: mixedColor,
                border: Border.all(color: Colors.black, width: 3),
              ),
            ),
            const SizedBox(height: 20),
            _buildColorSlider('Vermelho', Colors.red, _red, (value) {
              setState(() => _red = value);
            }),
            _buildColorSlider('Verde', Colors.green, _green, (value) {
              setState(() => _green = value);
            }),
            _buildColorSlider('Azul', Colors.blue, _blue, (value) {
              setState(() => _blue = value);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSlider(
      String label, Color color, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        Slider(
          value: value,
          min: 0,
          max: 255,
          activeColor: color,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
