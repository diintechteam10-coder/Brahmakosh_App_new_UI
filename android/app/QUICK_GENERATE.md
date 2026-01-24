# ⚡ JKS File तुरंत Generate करें

## 🚀 तरीका 1: Android Studio से (2 मिनट में) ⭐

1. **Android Studio खोलें**
2. Menu bar में जाएं: **Build** → **Generate Signed Bundle / APK**
3. **Android App Bundle** चुनें (या APK)
4. **Create new...** button पर click करें
5. ये details भरें:
   ```
   Key store path: android/app/ankurmaurya.jks
   Password: ankur@457
   Key alias: ankurmaurya  
   Key password: ankur@457
   Validity: 10000
   ```
6. Certificate information:
   - First and Last Name: `Ankur Maurya`
   - Organizational Unit: `Development`
   - Organization: `Brahmakosh`
   - City: `City`
   - State: `State`
   - Country Code: `IN`
7. **OK** click करें
8. File `android/app/ankurmaurya.jks` में create हो जाएगी!

## 🔧 तरीका 2: Java Install करके (5 मिनट)

### Step 1: Java JDK Download करें
1. https://adoptium.net/temurin/releases/ पर जाएं
2. **Version 17** या **21** चुनें
3. **Windows x64** download करें
4. Install करें (default settings OK हैं)

### Step 2: JKS Generate करें
1. Command Prompt खोलें (Admin rights की जरूरत नहीं)
2. Run करें:
   ```cmd
   cd "c:\flutter apps\brahmakosh\android\app"
   generate_keystore.bat
   ```

या manually:
```cmd
cd "c:\flutter apps\brahmakosh\android\app"
keytool -genkey -v -keystore ankurmaurya.jks -keyalg RSA -keysize 2048 -validity 10000 -alias ankurmaurya -storepass "ankur@457" -keypass "ankur@457" -dname "CN=Ankur Maurya, OU=Development, O=Brahmakosh, L=City, ST=State, C=IN"
```

## ✅ Check करें

File generate होने के बाद:
```
c:\flutter apps\brahmakosh\android\app\ankurmaurya.jks
```

यह file exist करनी चाहिए!

## ⚠️ Important

- File को safe रखें!
- Backup जरूर लें
- Git में commit न करें (already ignored है)

