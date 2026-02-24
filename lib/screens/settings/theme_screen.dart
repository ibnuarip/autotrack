import 'package:flutter/material.dart';
import '../../main.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  late ThemeMode _selectedMode;

  @override
  void initState() {
    super.initState();
    _selectedMode = MyApp.currentThemeMode;
  }

  void _changeTheme(ThemeMode? mode) {
    if (mode != null) {
      setState(() {
        _selectedMode = mode;
      });
      MyApp.of(context)?.changeTheme(mode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tema Aplikasi'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Pilih tema tampilan aplikasi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Light Mode'),
            subtitle: const Text('Tampilan terang'),
            secondary: const Icon(Icons.light_mode),
            value: ThemeMode.light,
            groupValue: _selectedMode,
            onChanged: _changeTheme,
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark Mode'),
            subtitle: const Text('Tampilan gelap'),
            secondary: const Icon(Icons.dark_mode),
            value: ThemeMode.dark,
            groupValue: _selectedMode,
            onChanged: _changeTheme,
          ),
          RadioListTile<ThemeMode>(
            title: const Text('System Default'),
            subtitle: const Text('Mengikuti pengaturan sistem'),
            secondary: const Icon(Icons.settings_suggest),
            value: ThemeMode.system,
            groupValue: _selectedMode,
            onChanged: _changeTheme,
          ),
        ],
      ),
    );
  }
}
