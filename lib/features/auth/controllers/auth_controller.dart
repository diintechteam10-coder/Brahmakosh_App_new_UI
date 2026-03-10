import 'dart:convert';
import 'package:brahmakosh/common/api_urls.dart';
import 'package:brahmakosh/core/common_imports.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:brahmakosh/core/services/storage_service.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '449350149768-k2k2uu8uglq1ibntel03ai1kj9ddaqhb.apps.googleusercontent.com',
    scopes: ['email'],
  );

  var isGoogleLoading = false.obs;
  var isAppleLoading = false.obs;
  var isEmailLoading = false.obs;
  var isLoginPasswordHidden = true.obs;

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

    final headers = {'Content-Type': 'application/json'};

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
    if (isGoogleLoading.value || isAppleLoading.value || isEmailLoading.value) {
      print('⏳ Already loading, returning...');
      return;
    }

    print('🚀 Google Sign-In START');
    isGoogleLoading.value = true;

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

      /// 🔍 CHECK USER AFTER SOCIAL LOGIN
      await _checkUserAfterSocialLogin(userEmail);

      print('🏁 Navigation complete');
    } catch (e, s) {
      print('❌ ERROR');
      print(e);
      print(s);
    } finally {
      print('🔚 Google Sign-In END');
      isGoogleLoading.value = false;
    }
  }


Future<void> signInWithApple() async {
  if (isGoogleLoading.value || isAppleLoading.value || isEmailLoading.value) {
    print('⏳ Already loading, returning...');
    return;
  }

  print('🚀 Apple Sign-In START');
  isAppleLoading.value = true;

  try {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      webAuthenticationOptions: WebAuthenticationOptions(
        clientId: 'com.brahmakosh.service',
        redirectUri: Uri.parse(
          'https://brahmakosh.firebaseapp.com/__/auth/handler',
        ),
      ),
    );

    print("============== APPLE CREDENTIAL DEBUG ==============");
    print("🍏 Apple Email: ${credential.email}");
    print("🍏 Apple Given Name: ${credential.givenName}");
    print("🍏 Apple Family Name: ${credential.familyName}");
    print("🍏 Apple User ID: ${credential.userIdentifier}");
    print("🍏 Apple IdentityToken: ${credential.identityToken}");
    print("🍏 Apple AuthCode: ${credential.authorizationCode}");
    print("====================================================");

    /// Firebase credential
    final oAuthProvider = OAuthProvider('apple.com');

    final firebaseCredential = oAuthProvider.credential(
      idToken: credential.identityToken,
      accessToken: credential.authorizationCode,
    );

    print('🔥 Signing in to Firebase with Apple...');

    final UserCredential userCredential =
        await _auth.signInWithCredential(firebaseCredential);

    final User? user = userCredential.user;

    if (user == null) {
      print("❌ Firebase user is NULL");
      return;
    }

    print('✅ Firebase UID   : ${user.uid}');
    print('✅ Firebase Email : ${user.email}');
    print(
        '✅ Is New User    : ${userCredential.additionalUserInfo?.isNewUser}');

    /// Try to get email
    String userEmail = user.email ?? credential.email ?? '';

    /// If still empty try storage
    if (userEmail.isEmpty) {
      userEmail =
          await StorageService.getString(AppConstants.keyUserEmail) ?? '';

      print("📦 Email loaded from storage: $userEmail");
    }

    /// Extract from Apple JWT
    if (userEmail.isEmpty && credential.identityToken != null) {
      try {
        final parts = credential.identityToken!.split('.');

        if (parts.length == 3) {
          final payload = parts[1];

          final normalized = base64Url.normalize(payload);

          final decoded = utf8.decode(base64Url.decode(normalized));

          final payloadMap = jsonDecode(decoded);

          print("🔍 Apple JWT Payload: $payloadMap");

          userEmail = payloadMap['email'] ?? '';

          print("✅ Extracted Email from JWT: $userEmail");
        }
      } catch (e) {
        print("⚠️ Failed to decode Apple JWT: $e");
      }
    }

    /// If still empty Apple didn't return email
    if (userEmail.isEmpty) {
      print(
          "⚠️ Apple did not return email (normal after first login if hidden email selected)");
    }

    print("📧 Final Email Used: $userEmail");

    /// Save session
    await StorageService.setBool(AppConstants.keyIsLoggedIn, true);
    await StorageService.setString(AppConstants.keyUserId, user.uid);

    if (userEmail.isNotEmpty) {
      await StorageService.setString(AppConstants.keyUserEmail, userEmail);
    }

    await Future.delayed(const Duration(milliseconds: 300));

    /// Backend check
    if (userEmail.isNotEmpty) {
      await _checkUserAfterSocialLogin(userEmail);
    } else {
      Get.snackbar(
        "Apple Login",
        "Email not available. Please login again or use another method.",
      );
    }
  } catch (e, s) {
    print("❌ APPLE LOGIN ERROR TYPE: ${e.runtimeType}");
    print("❌ ERROR MESSAGE: $e");
    print("❌ STACK TRACE: $s");

    if (e is FirebaseAuthException) {
      print("🔥 Firebase Error Code: ${e.code}");
      print("🔥 Firebase Error Message: ${e.message}");
    }

    Get.snackbar("Apple Login Failed", e.toString());
  } finally {
    print('🔚 Apple Sign-In END');
    isAppleLoading.value = false;
  }
}

  Future<void> _checkUserAfterSocialLogin(String email) async {
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
