class ApiUrls {
  /// 🔹 Base URL
  //static const String baseUrl = 'https://backend-jfg8.onrender.com';
  static const String baseUrl = 'https://stage.brahmakosh.com';

  /// 🔹 Common API path
  static const String apiUrl = '$baseUrl/api/mobile';

  /// 🔹 Auth APIs
  static const String register = '$apiUrl/user/register';
  static const String login = '$apiUrl/user/login';
  static const String emailRegister = '$apiUrl/user/register/step1';
  static const String mobileRegister = '$apiUrl/user/register/step2';
  static const String mobileVerify = '$apiUrl/user/register/step2/verify';
  static const String completeProfile = '$apiUrl/user/register/step3';
  static const String checkUser = '$apiUrl/user/check-email';

  ///
  static const String getProfile = '$apiUrl/user/profile';
  static const String uploadProfileImage = '$apiUrl/user/profile/image';

  /// 🔹 Forgot Password APIs
  static const String forgotPassword = '$baseUrl/api/auth/user/forgot-password';
  static const String verifyResetOtp =
      '$baseUrl/api/auth/user/verify-reset-otp';
  static const String resetPassword = '$baseUrl/api/auth/user/reset-password';

  /// 🔹 Testimonials
  static const String testimonials = '$baseUrl/api/testimonials';
  static const String founderMessages = '$baseUrl/api/founder-messages';
  static const String sponsors = '$baseUrl/api/sponsors';
  static const String chantings = '$baseUrl/api/chantings';
  static const String liveAvatars = '$baseUrl/api/live-avatars';

  ///Sadhna APIs
  static const String sadhnaServices = '$baseUrl/api/expert-categories';
  static const String experts = '$baseUrl/api/experts';
  static const String brahmAvatars = '$baseUrl/api/brahm-avatars';
  static const String updateLocation = '$apiUrl/user/get-location';
  static const String reverseGeocode = '$apiUrl/user/reverse-geocode';
  static const String spiritualCheckin = '$apiUrl/content/spiritual-checkin';
  static const String spiritualConfigurations =
      '$baseUrl/api/spiritual-configurations';
  static const String spiritualClipsByConfig =
      '$baseUrl/api/spiritual-clips/configuration';
  static const String saveSpiritualSession =
      '$baseUrl/api/spiritual-stats/save-session';
  static const String panchang = '$baseUrl/api/client/users';
  static const String completeUserDetails = '$baseUrl/api/client/users';
  static const String numerologyHistory = '$baseUrl/api/client/users';
}
