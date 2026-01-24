import 'dart:convert';

import 'package:brahmakosh/common/api_urls.dart';
import 'package:brahmakosh/core/common_imports.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:brahmakosh/core/services/storage_service.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:http/http.dart' as http;

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  /// ❌ serverClientId ANDROID me bilkul mat do
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  var isLoading = false.obs;
  var isEmailLoading = false.obs;

  User? get currentUser => _auth.currentUser;

Future<void> loginWithEmail() async {
  if (isEmailLoading.value) return;

  final email = emailController.text.trim();
  final password = passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    Get.snackbar("Required", "Email & Password required");
    return;
  }

  isEmailLoading.value = true;

  final url = Uri.parse(ApiUrls.login);

  final headers = {
    'Content-Type': 'application/json',
  };

  final body = {
    "email": email,
    "password": password,
    "clientId": "CLI-KBHUMT",
  };

  /// 🔹 PRINT REQUEST
  print("📤 LOGIN REQUEST");
  print("➡️ URL: $url");
  print("➡️ Headers: $headers");
  print("➡️ Body: ${jsonEncode(body)}");

  try {
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    /// 🔹 PRINT RESPONSE
    print("📥 LOGIN RESPONSE");
    print("⬅️ Status Code: ${response.statusCode}");
    print("⬅️ Headers: ${response.headers}");
    print("⬅️ Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final userId = data['data']?['user']?['_id'] ?? '';
      final token = data['data']?['token'] ?? '';

      await StorageService.setBool(AppConstants.keyIsLoggedIn, true);
      await StorageService.setString(AppConstants.keyUserId, userId);
      await StorageService.setString(AppConstants.keyAuthToken, token);
      await StorageService.setString(AppConstants.keyUserEmail, email);

      Get.offAllNamed(AppConstants.routeDashboard);
    } else {
      final msg = jsonDecode(response.body)['message'] ?? "Login failed";
      Get.snackbar("Login Failed", msg);
    }
  } catch (e, stack) {
    print("❌ LOGIN EXCEPTION");
    print("Error: $e");
    print("StackTrace: $stack");

    Get.snackbar("Error", "Something went wrong");
  } finally {
    isEmailLoading.value = false;
  }
}

  Future<void> signInWithGoogle() async {
    if (isLoading.value) {
      print('⏳ Already loading, returning...');
      return;
    }

    print('🚀 Google Sign-In START');
    isLoading.value = true;

    try {
      /// 🔥 CLEAR OLD SESSION
      print('🧹 Signing out previous Google session...');
      await _googleSignIn.signOut();
      print('✅ Old Google session cleared');

      /// 1️⃣ Google chooser
      print('🟢 Opening Google account chooser...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      print('🟡 Google chooser returned');

      if (googleUser == null) {
        print('⚠️ USER CANCELLED Google Sign-In');
        return;
      }

      print('👤 Google User Email: ${googleUser.email}');
      print('👤 Google User ID   : ${googleUser.id}');
      print('👤 Google User Name : ${googleUser.displayName}');

      /// 2️⃣ Get tokens
      print('🔐 Fetching Google auth tokens...');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print('🔑 accessToken is null? ${googleAuth.accessToken == null}');
      print('🆔 idToken     is null? ${googleAuth.idToken == null}');

      if (googleAuth.idToken == null) {
        throw Exception('❌ Google ID Token is NULL');
      }

      /// 🔥🔥🔥 ID TOKEN PRINT (THIS IS WHAT YOU WANT)
      print('================ ID TOKEN START ================');
      print(googleAuth.idToken);
      print('================ ID TOKEN END ==================');

      /// 3️⃣ Firebase credential
      print('🧩 Creating Firebase OAuth credential...');
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('✅ Firebase credential created');

      /// 4️⃣ Firebase sign-in
      print('🔥 Signing in to Firebase...');
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      print('🔥 Firebase sign-in response received');

      final User? user = userCredential.user;
      print('👤 Firebase user null? ${user == null}');

      if (user == null) {
        throw Exception('❌ Firebase user is NULL');
      }

      print('✅ Firebase UID   : ${user.uid}');
      print('✅ Firebase Email : ${user.email}');
      print(
        '✅ Is New User    : ${userCredential.additionalUserInfo?.isNewUser}',
      );

      /// 5️⃣ Save session
      final userEmail = user.email ?? '';
      print('💾 Saving session to storage...');
      await StorageService.setBool(AppConstants.keyIsLoggedIn, true);
      await StorageService.setString(AppConstants.keyUserId, user.uid);
      await StorageService.setString(AppConstants.keyUserEmail, userEmail);
      print('✅ Session saved with email: $userEmail');

      /// Navigation
      print('➡️ Navigating to mobile OTP with email: $userEmail');
      await Future.delayed(const Duration(milliseconds: 300));

      /// 🔍 CHECK USER AFTER GOOGLE LOGIN
      await _checkUserAfterGoogleLogin(userEmail);

      print('🏁 Navigation complete');
    } catch (e, s) {
      print('❌ ERROR');
      print(e);
      print(s);
    } finally {
      print('🔚 Google Sign-In END');
      isLoading.value = false;
    }
  }

  Future<void> _checkUserAfterGoogleLogin(String email) async {
    try {
      print('🔍 Checking user status for email: $email');

      final response = await http.post(
        Uri.parse(ApiUrls.checkUser),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email, "clientId": "CLI-KBHUMT"}),
      );

      print('📦 CheckUser Status: ${response.statusCode}');
      print('📦 CheckUser Body  : ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final bool registered = data['data']?['registered'] ?? false;

        if (registered) {
          /// ✅ USER EXISTS → DASHBOARD
          final user = data['data']?['user'];
          final token = data['data']?['token'] ?? '';

          await StorageService.setBool(AppConstants.keyIsLoggedIn, true);
          await StorageService.setString(
            AppConstants.keyUserId,
            user?['_id'] ?? '',
          );
          await StorageService.setString(
            AppConstants.keyUserEmail,
            user?['email'] ?? '',
          );
          await StorageService.setString(AppConstants.keyAuthToken, token);

          print('✅ Existing user → Dashboard');
          Get.offAllNamed(AppConstants.routeDashboard);
        } else {
          /// 🆕 NEW USER → MOBILE OTP
          print('🆕 New user → Mobile OTP');
          Get.toNamed(AppConstants.mobileOtp, arguments: email);
        }
      } else {
        Get.snackbar("Error", "User check failed");
      }
    } catch (e) {
      print('❌ Check user error: $e');
      Get.snackbar("Error", "Something went wrong");
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();

    await StorageService.clear();

    Get.offAllNamed(AppConstants.routeLogin);
  }
}
