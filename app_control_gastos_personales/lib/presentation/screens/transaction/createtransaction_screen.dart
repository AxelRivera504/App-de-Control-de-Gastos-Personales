import 'package:app_control_gastos_personales/application/controllers/transaction/transaction_controller.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:app_control_gastos_personales/presentation/widgets/base_design.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class CreateTransactionScreen extends StatefulWidget {
  static const name = 'add-transaction-screen';
  const CreateTransactionScreen({super.key});

  @override
  State<CreateTransactionScreen> createState() => _CreateTransactionScreenState();
}

class _CreateTransactionScreenState extends State<CreateTransactionScreen> {
  late final String categoryId;
  late final int trantypeid;     // 1 o 2
  late final String categoryName;
  late final bool isIncome;

  late CreateTransactionController c;
  bool _inited = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Toma los argumentos una sola vez
    if (!_inited) {
      final args = GoRouterState.of(context).extra as Map;
      categoryId   = args['categoryId'] as String;
      trantypeid   = args['trantypeid'] as int;
      categoryName = args['categoryName'] as String? ?? '';
      isIncome     = trantypeid == 1;

      // Si hubiese una instancia previa (por hot-restart o navegación), elimínala una sola vez
      if (Get.isRegistered<CreateTransactionController>()) {
        Get.delete<CreateTransactionController>(force: true);
      }

      // Crea el controller UNA vez
      c = Get.put(CreateTransactionController(
        categoryId: categoryId,
        trantypeid: trantypeid,
      ));

      _inited = true;
    }
  }

  @override
  void dispose() {
    // Limpia el controller al salir de la pantalla
    if (Get.isRegistered<CreateTransactionController>()) {
      Get.delete<CreateTransactionController>(force: true);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: BaseDesign(
        header: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Text(
                isIncome ? 'Añadir Ingreso' : 'Añadir Egreso',
                style: const TextStyle(
                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              const Icon(Icons.notifications_none, color: Colors.white),
            ],
          ),
        ),

        // Contenido scrolleable + padding por teclado (sin Obx global)
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
          ),
          child: Form(
            key: c.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Fecha
                const Text('Fecha'),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () async {
                    FocusScope.of(context).unfocus();   // opcional, por claridad
                    await c.pickDate(context);          // <-- importante: await
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Obx(() => Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.verdePalido.withOpacity(.4),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${c.date.value.day.toString().padLeft(2, '0')}/'
                          '${c.date.value.month.toString().padLeft(2, '0')}/'
                          '${c.date.value.year}',
                          style: const TextStyle(
                            color: AppTheme.verdeOscuro,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.calendar_month_outlined, color: AppTheme.verdeOscuro),
                      ],
                    ),
                  )),
                ),
                const SizedBox(height: 16),

                // Categoría (solo display)
                const Text('Categoría'),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.verdePalido.withOpacity(.4),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    categoryName,
                    style: const TextStyle(
                      color: AppTheme.verdeOscuro,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Monto
                const Text('Monto'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: c.amountCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.verdePalido.withOpacity(.4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    hintText: '0.00',
                  ),
                  validator: (v) =>
                      (double.tryParse((v ?? '').replaceAll(',', '.')) == null)
                          ? 'Monto inválido'
                          : null,
                ),
                const SizedBox(height: 16),

                // Nota
                const Text('Nota'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: c.notesCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.verdePalido.withOpacity(.4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'Ingresa una nota (opcional)',
                  ),
                ),
                const SizedBox(height: 24),

                // Guardar
                Obx(() => FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.verde,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
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
                          : const Text('Guardar',
                              style: TextStyle(color: Colors.white)),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
