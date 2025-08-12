import 'package:flutter/material.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
// Alias para la API principal
import 'package:flutter_iconpicker/flutter_iconpicker.dart' as FIP;
// Import para las configuraciones (v3.6+)
import 'package:flutter_iconpicker/Models/configuration.dart' as FIPConfig;

class IconPickerButton extends StatefulWidget {
  final IconData? initial;
  final void Function(IconData icon) onPicked;

  const IconPickerButton({super.key, this.initial, required this.onPicked});

  @override
  State<IconPickerButton> createState() => _IconPickerButtonState();
}

class _IconPickerButtonState extends State<IconPickerButton> {
  late IconData _icon;

  @override
  void initState() {
    super.initState();
    _icon = widget.initial ?? Icons.category;
  }

  Future<void> _pick() async {
    final picked = await FIP.showIconPicker(
      context,
      configuration: const FIPConfig.SinglePickerConfiguration(
        // Para TODOS los Material (normal + Sharp + Rounded + Outlined) usa:
        // iconPackModes: [FIP.IconPack.allMaterial],
        iconPackModes: [FIP.IconPack.material],
        //searchIcon: true,
        showTooltips: true,
      ),
    );

    if (picked != null) {
      final iconData = picked.data; // <- IconData real
      setState(() => _icon = iconData);
      widget.onPicked(iconData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: AppTheme.azulPalido,
          child: Icon(_icon, color: AppTheme.azulOscuro),
        ),
        const SizedBox(width: 12),
        FilledButton.tonal(onPressed: _pick, child: const Text('Elegir ícono')),
      ],
    );
  }
}
