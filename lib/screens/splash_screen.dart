import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../Auth/auth_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
/*   with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation; */

  @override
  void initState(){
    super.initState();

   /*  _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _controller.forward(); */

    WidgetsBinding.instance.addPostFrameCallback((_) {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthGate()),
        );
      }
    });
  });
  }

  /* @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  } */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
       /*  child: ScaleTransition(
          scale: _scaleAnimation, */
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/lottie/food.json',
                width: 250,
                height: 250,
                fit: BoxFit.contain,
              ),
              /* Icon(Icons.fastfood, size: 100, color: Colors.orange.shade700), */
              /* Image.asset(
                'assets/logo.png',
                width: 150,
                height: 150,
              ), */
              const SizedBox(height: 20),
              const Text(
                'Bienvenido a Garnachas MX',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
  }
}