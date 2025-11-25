// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:translate/src/core/reusables/auth_button.dart' hide kAccentColor, kBackgroundColor, kPrimaryColor;
// import 'package:translate/src/features/auth/presentation/providers/auth_provider.dart';
//
// // Theme Constants (Matching AppShell, Feed, Onboarding)
// const Color kPrimaryBlue = Color(0xFF1E3A8A);
// const Color kAmberAccent = Colors.amber;
// const Color kBackgroundColor = Color(0xFFF9FAFB); // Light Grey
//
// class LoginScreen extends StatelessWidget {
//   const LoginScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // Listen to the provider
//     final authProvider = Provider.of<AuthProvider>(context);
//
//     return Scaffold(
//       backgroundColor: kPrimaryBlue, // Blue background for the top branding area
//       body: Stack(
//         children: [
//           // Decorative Circle (Top Right)
//           Positioned(
//             top: -50,
//             right: -50,
//             child: Container(
//               width: 200,
//               height: 200,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white.withOpacity(0.05),
//               ),
//             ),
//           ),
//
//           Column(
//             children: [
//               // --- Top Section: Branding ---
//               Expanded(
//                 flex: 4,
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(24),
//                         decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.1),
//                             shape: BoxShape.circle,
//                             border: Border.all(color: Colors.white.withOpacity(0.2), width: 1)
//                         ),
//                         child: const Icon(Icons.g_translate_rounded, color: kAmberAccent, size: 64),
//                       ),
//                       const SizedBox(height: 24),
//                       const Text(
//                         'GoTranslate',
//                         style: TextStyle(
//                           fontSize: 36,
//                           color: Colors.white,
//                           fontWeight: FontWeight.w800, // Bold like other headers
//                           letterSpacing: 0.5,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Break language barriers instantly.',
//                         style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.blue.shade100,
//                             fontWeight: FontWeight.w500
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//               // --- Bottom Section: Action ---
//               Expanded(
//                 flex: 3,
//                 child: Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
//                   decoration: const BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(40), // Smoother curve
//                       topRight: Radius.circular(40),
//                     ),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         "Welcome Back",
//                         style: TextStyle(
//                           fontSize: 28,
//                           fontWeight: FontWeight.w800,
//                           color: kPrimaryBlue, // Using Theme Color
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       Text(
//                         "Sign in to continue contributing to the largest open source database for Ugandan languages.",
//                         style: TextStyle(
//                           fontSize: 15,
//                           color: Colors.grey.shade600,
//                           height: 1.6,
//                         ),
//                       ),
//
//                       const Spacer(),
//
//                       // --- Google Sign In Button ---
//                       authProvider.isLoading
//                           ? const Center(
//                         child: CircularProgressIndicator(color: kPrimaryBlue),
//                       )
//                           : AuthButton(
//                         text: 'Sign In with Google',
//                         isPrimary: true,
//                         backgroundColor: kPrimaryBlue, // Updated Color
//                         foregroundColor: Colors.white,
//                         onPressed: () async {
//                           try {
//                             await authProvider.signInWithGoogle();
//                           } catch (e) {
//                             if (context.mounted) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                   content: Text("Sign in failed: $e"),
//                                   backgroundColor: Colors.red,
//                                 ),
//                               );
//                             }
//                           }
//                         },
//                       ),
//
//                       const SizedBox(height: 16),
//
//                       // Error Message Display
//                       if (authProvider.error != null)
//                         Center(
//                           child: Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                                 color: Colors.red.shade50,
//                                 borderRadius: BorderRadius.circular(8)
//                             ),
//                             child: Text(
//                               'Error: ${authProvider.error}',
//                               style: TextStyle(color: Colors.red.shade700, fontSize: 12),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
