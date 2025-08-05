
import 'package:app_control_gastos_personales/presentation/screens/auth/forgetpassword_screen.dart';
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

    //Ruta Forget Password
    GoRoute(
      path: '/forgetpassword',
      name: ForgetPasswordScreen.name,
      builder: (context, state) {
        return ForgetPasswordScreen();
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

    //Ruta Verify Code
   GoRoute(
      path: '/verifycode',
      name: VerifyCodeScreen.name,
      builder: (context, state) {
        final email = (state.extra as Map)['email'] as String;
        return VerifyCodeScreen(email: email);
      },
    ),

    //Ruta Reset Password
    GoRoute(
        path: '/resetpassword',
        name: ResetPasswordScreen.name,
        builder: (context, state) {
          final email = (state.extra as Map)['email'] as String;
          return ResetPasswordScreen(email: email);
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