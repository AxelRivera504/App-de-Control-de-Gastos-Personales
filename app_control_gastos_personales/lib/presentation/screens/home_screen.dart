import 'package:app_control_gastos_personales/controllers/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
class HomeScreen extends StatelessWidget {
  static const name = 'home-screen';
  final int pageIndex;
  const HomeScreen({super.key, required this.pageIndex});

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
            context.go('/splash/0');
          },
          child: Text('Cerrar sesión'),
        ),
      ),
    );
  }
}



