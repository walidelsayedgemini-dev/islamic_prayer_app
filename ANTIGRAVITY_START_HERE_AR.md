# ابدأ هنا — مشروع الفردوس على Antigravity

هذه حزمة مصدر قابلة للتعديل لتطبيق الفردوس. افتح Antigravity، فك ضغط الأرشيف، ثم اختر مجلد `Firdaws-Antigravity-Source` كمجلد المشروع.

## تشغيل نسخة الويب للتطوير

المشروع يستخدم Flutter 3.47.9 وDart 3.13.7. من الطرفية داخل Antigravity شغّل:

```sh
cd flutter_app
flutter pub get
flutter run -d chrome
```

إذا لم يتوفر Chrome كجهاز Flutter، يمكن تشغيل خادم تطوير الويب هكذا:

```sh
cd flutter_app
flutter pub get
flutter run -d web-server --web-port 3000
```

## أين أعدّل؟

- `flutter_app/lib/screens/`: الشاشات الرئيسية والفرعية.
- `flutter_app/lib/widgets/`: مكونات الواجهة المشتركة.
- `flutter_app/lib/theme/`: الثيمات والألوان والطباعة.
- `flutter_app/assets/`: الصور والخطوط والصوت وبيانات المحتوى.
- `flutter_app/test/`: اختبارات التطبيق.
- `GOOGLE_STITCH_UI_UX_SPEC_AR.md`: مواصفة الشاشات والأفعال والحالات المخصصة للتصميم على Google Stitch.

## بناء نسخة الويب النهائية

من جذر المجلد بعد تثبيت Flutter، شغّل:

```sh
bash scripts/rebuild-web.sh
```

السكربت يعيد بناء Flutter Web ويحدّث مجلد `public/`. أُدرجت ملفات `public/index.html` و`public/manus-routes.json` المطلوبة للسكربت؛ ملفات البناء المولدة ومجلدات الكاش غير مضمّنة، وسيعيد Flutter إنشاؤها.

## محتويات وحدود الحزمة

تتضمن الحزمة كود Flutter والأصول والاختبارات وإعداد Android والويب والوثائق. لا تتضمن `.git` أو `build/` أو `.dart_tool/` أو الحزمة المترجمة الكبيرة داخل `public/`؛ الأرشيف مخصص لتعديل المصدر، ويمكن إعادة توليد نسخة الويب بالأمر أعلاه. لا تتضمن ملفات إعداد iOS لأن مجلد iOS غير موجود ضمن مصدر المشروع الحالي.
