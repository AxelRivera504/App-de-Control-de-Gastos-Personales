// lib/presentation/screens/analysis/create_analysis_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:app_control_gastos_personales/presentation/widgets/icon_picker_button.dart';
import 'package:app_control_gastos_personales/application/controllers/analysis/create_analysis_controller.dart';

class CreateAnalysisScreen extends StatelessWidget {
  static const name = 'create-analysis-screen';
  const CreateAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(CreateAnalysisController());

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Análisis')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: c.formKey,
          child: Column(
            children: [
              TextFormField(
                controller: c.titleCtrl,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: c.descriptionCtrl,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              IconPickerButton(initial: Icons.analytics, onPicked: (icon) => c.pickedIcon = icon),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Obx(() => Text(c.startDate.value == null ? 'Fecha inicio' : c.startDate.value!.toLocal().toString().split(' ')[0])),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: c.startDate.value ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) c.startDate.value = picked;
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Obx(() => Text(c.endDate.value == null ? 'Fecha fin' : c.endDate.value!.toLocal().toString().split(' ')[0])),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: c.endDate.value ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) c.endDate.value = picked;
                      },
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Obx(() => FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: AppTheme.verde, padding: const EdgeInsets.symmetric(vertical: 14)),
                    onPressed: c.isSaving.value
                        ? null
                        : () async {
                            final ok = await c.save();
                            if (!context.mounted) return;
                            if (ok) context.pop(true);
                          },
                    child: c.isSaving.value
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Guardar', style: TextStyle(color: Colors.white)),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
