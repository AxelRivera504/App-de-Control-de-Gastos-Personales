
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
  //Ruta Help Center
  GoRoute(
    path: '/help',
    name: HelpCenterScreen.name,
    builder: (context, state) => const HelpCenterScreen(),
  ),


    
    // Ruta ProfileScreen
    GoRoute(
      path: '/profile',
      name: ProfileScreen.name,
      builder: (context, state) => const ProfileScreen(),
    ),

  //Ruta HomeScreen
    GoRoute(
      path: '/home',
      name: HomeScreen.name,
      builder: (context, state) => const HomeScreen(),
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

    GoRoute(
      path: '/main',
      name: MainNavigationScreen.name,
      builder: (context, state) => const MainNavigationScreen(),
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
  ]
);