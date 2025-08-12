import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:app_control_gastos_personales/presentation/widgets/icon_picker_button.dart';
import 'package:app_control_gastos_personales/application/controllers/category/create_category_controller.dart';

class CreateCategoryScreen extends StatelessWidget {
  static const name = 'create-category-screen';
  const CreateCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(CreateCategoryController());

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva categoría')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: c.formKey,
          child: Column(
            children: [
              TextFormField(
                controller: c.nameCtrl,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              IconPickerButton(
                initial: Icons.category,
                onPicked: (icon) => c.pickedIcon = icon,
              ),
              const SizedBox(height: 12),

              // ---------- SELECT: ingreso/egreso ----------
              Obx(() {
                if (c.loadingTypes.value) {
                  return const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ));
                }
                return DropdownButtonFormField<int>(
                  value: c.selectedTypeId.value,
                  decoration: const InputDecoration(labelText: 'Tipo de transacción'),
                  items: c.types
                      .map((t) => DropdownMenuItem(
                            value: t.typeId,
                            child: Text(t.description),
                          ))
                      .toList(),
                  onChanged: (v) => c.selectedTypeId.value = v ?? 1,
                );
              }),
              const SizedBox(height: 12),

              Obx(() => SwitchListTile(
                    value: c.state.value,
                    onChanged: (v) => c.state.value = v,
                    title: const Text('Activo'),
                  )),
              const Spacer(),
              Obx(() => FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.verde,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    ),
                    onPressed: c.isSaving.value
                        ? null
                        : () async {
                            final ok = await c.save();
                            if (!context.mounted) return;
                            if (ok) context.pop(true);
                          },
                    child: c.isSaving.value
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Guardar', style: TextStyle(color: Colors.white)),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
