import 'package:app_control_gastos_personales/utils/session_controller.dart';
import 'package:app_control_gastos_personales/config/router/app_router.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized();

  //bloquear la orientación del dispositivo
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await SessionController.instance.loadSession();


  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(),
    );
  }
}
