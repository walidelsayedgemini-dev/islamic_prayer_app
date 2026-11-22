# تنفيذ إعادة التصميم الفردوسي — عقد وحدات العمل

المرجع البصري هو `flutter_app/assets/images/garden/garden_day_paradise.jpg`: نخيل وحدائق وأزهار وماء صاف وقباب خيالية بضوء فخم. التصميم الجديد غني وهادئ في الوقت نفسه، لا تحديثًا تجميليًا لواجهات البطاقات السابقة. كل وحدة تعيد صياغة التخطيط والتسلسل والنص الإرشادي والتحكم والمشهد بحسب وظيفتها، ضمن خطة `plan.md` ومعايير `TODO.md` الجديدة.

## الثوابت

Flutter 3.47.9/Dart 3.13.7 في `/home/ubuntu/sdks/flutter`. التطبيق داخل `/home/ubuntu/firdaws/flutter_app`. baseline: `8f453697a0791fd43222a204d64cbc8d60d09ec0`. 56 ثيمًا و30 لعبة و8 محركات. تحفظ providers/models/services وقواعد اللعب والأسئلة والنص الديني والمكافآت والحسابات والوقت والمفاتيح والإعدادات وFirdawsNavBridge والواجهات العامة/constructor signatures. لا حذف لعبة/ثيم أو تقليص كتالوج. لا كتابة إلى خدمات production أو تجربة تمنح مكافآت للمستخدم أثناء الفحص.

## ترتيب الوحدات

تُنجز وحدتا الهوية والمكونات أولًا قبل إعادة تصميم الشاشات بالتوازي. كل عامل يعدل الملفات المسندة إليه وحدها، بلا git أو browser أو build أو تعديل اختبار أو docs عامة. يستطيع قراءة بقية المصدر للربط. يجرى analyzer محدود للملفات التي يملكها بعد كتابة ملفاتها، وتُحفظ نهايات الأسطر الأصلية عند التنسيق. تنسيق ملفات لم يملكها العامل ممنوع. المراجعة النهائية read-only وتتتبع callbacks والحسابات وحفظ الخيارات، ويعالج الأب الأخطاء المؤكدة فقط.

## عقد الهوية

عامل الهوية يملك `lib/theme/islamic_theme.dart` وملف part جديد `lib/theme/paradise_theme_registry.dart` فقط، ويكتب manifest الصور خارجيًا في `/home/ubuntu/firdaws-paradise-assets.json`.

الواجهة العامة: `FirdawsParadiseRegistry.forKey(String key)`, `all` (56 عنصرًا بترتيب `IslamicTheme.allThemes`), `paletteFor(String key, bool isNight)`, `imageFor(String key)`؛ و`ParadiseThemeSpec` يحوي `key,title,caption,imageAsset,accent`. كل ملف manifest يحوي 56 عنصرًا (key/title/caption/imageAsset/prompt). الـdisplay metadata خيالي؛ الكتالوج التاريخي الأصلي محفوظ.

صورة `emerald_gold` تستخدم الملف المحلي المحبوب `assets/images/paradise/emerald_gold.jpg` (الأب نسخه من الصورة الأصلية). أما الصور الخمس والخمسون الجديدة فلا يكتب مولد الصور ملفات محلية؛ جميعها من نوع Managed Storage. اكتب في `imageAsset` مسار Managed Storage النسبي الدقيق المعاد كما هو من الأداة: `/manus-storage/async-images/{job-id}/image-n.webp`، أو المسار المحلي الأساسي فقط. لا تخترع أو تشكل host. يهيئ الأب جميع مراجع 56 صورة في manifest. `FirdawsNatureLook.sceneryAsset` يحتفظ بالمسار للواجهة؛ كل مستهلك للصورة يختار `Image.asset` للمسار المحلي و`Image.network` للمسار `/manus-storage/`. لا تستبدل URL بتحويل إلى ملف محلي أو تكوين Web URL.

كل prompt فني 16:9 إنجليزي، متأثر بأسلوب المرجع، مع اختلاف واضح لكل عنوان: لون/فصل/وقت وماء/نبات/خامة وعمق/تكوين. لا تصور خيالي يزعم أنه صورة لمكان مقدس أو حقيقي؛ تجنب نسخ الأضرحة أو الكعبة أو المعالم والمساجد، والنص والكاليغرافي والأشخاص. المشاهد مناظر حدائق فردوسية رمزية فقط. كل مفتاح له لوحة نهار/ليل مقروءة ومميزة؛ لا تعاد الثيمات الـ56 إلى الأربعة القديمة، وتظل مفاتيح ThemeOption وdayPalette/nightPalette الأصلية والكتالوج محفوظة.

## عقد المكونات

عامل المكونات يملك `widgets/calm_ui.dart`, `nature_ui.dart`, `firdaws_3d_ui.dart` وملف `widgets/paradise_ui.dart` جديد. يحافظ على API القديم، ويعيد بناء الأسطح والإطار/البطاقات/الأيقونات/الحالات. يستعمل `FirdawsNatureLook.sceneryAsset` المتوفر كما هو، لا يكتب ملفات theme. يظهر الصورة عبر Image.asset للمسار المحلي أو Image.network للـManaged Storage على نفس المسار النسبي تمامًا. يمتلك الصورة fallback وloading state دون طلب مضيف خارجي.

يوفر في `paradise_ui.dart`:

- `ParadiseHero({required String title, String? subtitle, String? imageAsset, Widget? footer, double minHeight=220})`: مقدمة سينمائية فردوسية مرنة بسطح تظليل يضمن قراءة العنوان.
- `ParadiseChip({required String label, IconData? icon, bool selected=false, VoidCallback? onTap})`.
- `ParadiseMetric({required String value, required String label, IconData? icon})`.
- `ParadiseSection({required String title, required Widget child, Widget? action})`.

الشاشات تستعمل هذه الواجهات أو المكونات القديمة المتوافقة لتخلق تكوينًا مختلفًا لكل شاشة. لا تكرر hero كبيرًا فوق hero كبير داخل نفس شاشة الصلاة. تتحمل minWidth=320 والنص المكبّر؛ ارتفاع hero حد أدنى لا حد أقصى للنص، والأزرار bottom ثابتة واضحة عند الحاجة. إذا كانت الصفحة قارئًا لا تجعل خلفية الصورة تحت النص الديني؛ يحتفظ بصفحة قراءة نظيفة وبمقدمة/أدوات مميزة. لا تعرض كل البيانات داخل نفس جدول/cards سابق مع تغيير اللون فقط.

## وحدات الألعاب

تُسند ملفات engines الأربع مستقلًا، كل ملف يمثل زوج المحركات المرتبطين فيه. يغير الشكل/ترتيب التحكم/HUD/الرسوم والتسميات، لا state machine أو physics أو scoring أو durations أو callback arguments. وحدة scenic renderer/HUD تملك `arena_3d_backdrop.dart` و`gfx/arena_4k_stage_compositor.dart` فقط؛ تعطي المشاهد اختلافًا فعليًا عبر 30 لعبة وعوالمها مستخدمًا صور الـ56 من السجل نفسه، وتحفظ أولوية أحداث اللعبة وreduced-motion freeze للمنظر دون اللعب. يدعم renderer الصور المحلية وNetworkImage باستخدام المسار الدقيق ذاته. لا يتكرر نفس المنظر في كل بطاقة. بقية وحدات lobby/hub/quiz/family/store/events تملك شاشة واحدة لكل عامل.

## نتيجة كل عامل

تعاد نتيجة منظمة باسم الوحدة والملفات المعدلة والتغييرات المرئية الفعلية وتأكيد العقود التي بقيت وأخطاء analyzer المؤكدة. لا يدعي العامل فحصًا بصريًا أو تشغيل الاختبارات ما لم يفعل، ولا يطلق build مشتركًا. الأب يجمع النتائج ويشغل الاختبارات المتأثرة ويحدث النسخة الفعلية والمعاينة والحفظ.
