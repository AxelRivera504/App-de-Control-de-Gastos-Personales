
import 'package:app_control_gastos_personales/presentation/screens/splash_screen.dart';
import 'package:app_control_gastos_personales/presentation/screens/screens.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [

    //Ruta SplashScreen
     GoRoute(
      path: '/splash',
      name: SplashScreen.name,
      builder: (context, state) {
        return SplashScreen();
      }
    ),

    //Ruta InitialScreen
    GoRoute(
      path: '/initial',
      name: InitialScreen.name,
      builder: (context, state) => const InitialScreen(),
    ),


    //Ruta Login
    GoRoute(
      path: '/login',
      name: LoginScreen.name,
      builder: (context, state) {
        return LoginScreen();
      }
    ),
    
    //Ruta SingUp
    GoRoute(
      path: '/signup',
      name: SignUpScreen.name,
      builder: (context, state) {
        return SignUpScreen();
      },
    ),

    //Ruta HomeScreen
    GoRoute(
      path: '/home',
      name: HomeScreen.name,
      builder: (context, state) {
        return HomeScreen();
      },
    ),
  ]
);