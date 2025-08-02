import 'package:app_control_gastos_personales/presentation/screens/splash_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:app_control_gastos_personales/presentation/screens/screens.dart';
final appRouter = GoRouter(
  initialLocation: '/splash/0',
  routes: [

    //Ruta SplashScreen
     GoRoute(
      path: '/splash/:page',
      name: SplashScreen.name,
      builder: (context, state) {
        final pageIndex = state.pathParameters['page'] ?? '0';
        return SplashScreen(pageIndex: int.parse(pageIndex));
      }
    ),

    //Ruta Login
    GoRoute(
      path: '/login/:page',
      name: LoginScreen.name,
      builder: (context, state) {
        final pageIndex = state.pathParameters['page'] ?? '0';
        return LoginScreen(pageIndex: int.parse(pageIndex));
      }
    ),
    
    //Ruta SingUp
    GoRoute(
      path: '/signup/:page',
      name: SignUpScreen.name,
      builder: (context, state) {
        final pageIndex = state.pathParameters['page'] ?? '0';

        return SignUpScreen( pageIndex:int.parse(pageIndex));
      },
    ),

    //Ruta HomeScreen
    GoRoute(
      path: '/home/:page',
      name: HomeScreen.name,
      builder: (context, state) {
        final pageIndex = state.pathParameters['page'] ?? '0';
        return HomeScreen(pageIndex: int.parse(pageIndex));
      },
    ),
  ]
);