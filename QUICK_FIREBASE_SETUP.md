# إعداد Firebase السريع

## ⚠️ خطأ شائع
```
Failed to load FirebaseOptions from resource. Check that you have defined values.xml correctly.
```

## الحل السريع (5 دقائق)

### الخطوة 1: إنشاء مشروع Firebase

1. اذهب إلى [Firebase Console](https://console.firebase.google.com/)
2. اضغط على **Add project** (إضافة مشروع)
3. أدخل اسم المشروع (مثلاً: `smart-vehicle`)
4. اتبع الخطوات لإكمال إنشاء المشروع

### الخطوة 2: إضافة تطبيق Android

1. في Firebase Console، اضغط على أيقونة **Android** (أو **Add app** > **Android**)
2. أدخل:
   - **Package name**: `com.example.smartvehicle`
   - **App nickname**: (اختياري) Smart Vehicle
   - **Debug signing certificate SHA-1**: (اتركه فارغاً للاختبار)
3. اضغط **Register app**

### الخطوة 3: تحميل ملف google-services.json

1. بعد التسجيل، سيظهر لك زر **Download google-services.json**
2. اضغط على الزر لتحميل الملف
3. **انسخ الملف** إلى المجلد التالي:
   ```
   android/app/google-services.json
   ```

### الخطوة 4: إضافة Google Services Plugin

افتح ملف `android/build.gradle.kts` وأضف:

```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

افتح ملف `android/app/build.gradle.kts` وأضف في نهاية الملف:

```kotlin
plugins {
    // ... existing plugins
    id("com.google.gms.google-services")
}
```

### الخطوة 5: تفعيل Authentication

1. في Firebase Console، اذهب إلى **Authentication**
2. اضغط **Get started**
3. فعّل **Email/Password** provider
4. احفظ

### الخطوة 6: إنشاء Firestore Database

1. في Firebase Console، اذهب إلى **Firestore Database**
2. اضغط **Create database**
3. اختر **Start in test mode** (للاختبار)
4. اختر موقع قاعدة البيانات (مثلاً: `us-central1`)
5. اضغط **Enable**

### الخطوة 7: إعادة تشغيل التطبيق

```bash
flutter clean
flutter pub get
flutter run
```

## ✅ التحقق من الإعداد

بعد إكمال الخطوات، يجب أن يعمل التطبيق بدون أخطاء Firebase.

## 📝 ملاحظات مهمة

- **Package name** يجب أن يطابق `com.example.smartvehicle` في `android/app/build.gradle.kts`
- ملف `google-services.json` يجب أن يكون في `android/app/` وليس في `android/`
- بعد إضافة الملف، أعد تشغيل Android Studio

## 🔒 Security Rules (لاحقاً)

بعد الاختبار، يجب تحديث قواعد Firestore الأمنية. راجع `FIREBASE_SETUP.md` للتفاصيل.

## 🆘 إذا استمرت المشكلة

1. تأكد من أن `google-services.json` في المكان الصحيح
2. تأكد من إضافة plugin في `build.gradle.kts`
3. قم بـ `flutter clean` ثم `flutter pub get`
4. أعد تشغيل Android Studio

