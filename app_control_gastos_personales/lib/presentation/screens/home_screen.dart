import 'package:app_control_gastos_personales/utils/session_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  static const name = 'home-screen';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: TextButton(
          onPressed: () {
            final session = SessionController.instance;
            session.clearSession();
            context.go('/splash');
          },
          child: Text('Cerrar sesión'),
        ),
      ),
    );
  }
}



