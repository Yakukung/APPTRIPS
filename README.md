#ติดตั้งนี่ก่อน
 
flutter pub add http
flutter pub get

#ใส่นี่ลงไฟล์ pubspec.yaml ที่บรรทัด 60
  assets:
    - assets/images/
    - assets/config/

#ให้สิทธิ์ android ใช้เน็ตได้ android/app/src/main/AndroidManifest.xml
วางไว้บรรทัดที่ 2

<uses-permission android:name="android.permission.INTERNET" />
    <application
        android:label="flutter_ui_1"
