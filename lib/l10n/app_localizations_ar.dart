// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'XoDos';

  @override
  String get advancedSettings => 'الإعدادات المتقدمة';

  @override
  String get restartAfterChange => 'التغييرات سارية بعد إعادة التشغيل';

  @override
  String get resetStartupCommand => 'إعادة تعيين أمر التشغيل';

  @override
  String get attention => 'ملاحظة';

  @override
  String get confirmResetCommand => 'إعادة تعيين أمر التشغيل؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get yes => 'نعم';

  @override
  String get signal9ErrorPage => 'صفحة خطأ Signal9';

  @override
  String get containerName => 'اسم الحاوية';

  @override
  String get startupCommand => 'أمر التشغيل';

  @override
  String get vncStartupCommand => 'أمر تشغيل VNC';

  @override
  String get shareUsageHint =>
      'يمكنك استخدام XoDos على جميع الأجهزة في نفس الشبكة (مثل الهواتف، وأجهزة الكمبيوتر المتصلة بنفس الواي فاي).\n\nانقر على الزر أدناه لمشاركة الرابط مع أجهزة أخرى وفتحه في المتصفح.';

  @override
  String get copyShareLink => 'نسخ رابط المشاركة';

  @override
  String get x11InvalidHint => 'هذه الميزة غير متاحة عند استخدام X11';

  @override
  String get cannotGetIpAddress => 'فشل في الحصول على عنوان IP';

  @override
  String get shareLinkCopied => 'تم نسخ رابط المشاركة';

  @override
  String get webRedirectUrl => 'رابط إعادة التوجيه على الويب';

  @override
  String get vncLink => 'رابط VNC';

  @override
  String get globalSettings => 'الإعدادات العامة';

  @override
  String get enableTerminalEditing => 'تمكين تحرير الطرفية هنا';

  @override
  String get terminalMaxLines =>
      'الحد الأقصى لأسطر الطرفية (يتطلب إعادة تشغيل)';

  @override
  String get pulseaudioPort => 'منفذ استقبال PulseAudio';

  @override
  String get enableTerminal => 'تمكين الطرفية';

  @override
  String get enableTerminalKeypad => 'تمكين لوحة مفاتيح الطرفية';

  @override
  String get terminalStickyKeys => 'مفاتيح الطرفية اللاصقة';

  @override
  String get keepScreenOn => 'إبقاء الشاشة مضاءة';

  @override
  String get restartRequiredHint =>
      'الإعدادات التالية ستصبح سارية عند التشغيل التالي.';

  @override
  String get startWithGUI => 'التشغيل مع واجهة المستخدم الرسومية مفعلة';

  @override
  String get reinstallBootPackage => 'إعادة تثبيت حزمة التمهيد';

  @override
  String get getifaddrsBridge => 'جسر getifaddrs';

  @override
  String get fixGetifaddrsPermission =>
      'إصلاح صلاحية getifaddrs على أندرويد 13';

  @override
  String get fakeUOSSystem => 'محاكاة النظام كـ UOS';

  @override
  String get displaySettings => 'إعدادات العرض';

  @override
  String get avncAdvantages =>
      'AVNC يوفر تجربة تحكم أفضل من noVNC:\nأدوات تحكم باللمس، النقر بإصبعين للوحة المفاتيح، الحافظة التلقائية، وضع الصورة داخل الصورة، إلخ.';

  @override
  String get avncSettings => 'إعدادات AVNC';

  @override
  String get aboutAVNC => 'حول AVNC';

  @override
  String get avncResolution => 'دقة تشغيل AVNC';

  @override
  String get resolutionSettings => 'إعدادات الدقة';

  @override
  String get deviceScreenResolution => 'دقة شاشة جهازك هي';

  @override
  String get width => 'العرض';

  @override
  String get height => 'الارتفاع';

  @override
  String get save => 'حفظ';

  @override
  String get applyOnNextLaunch => 'تطبيق عند التشغيل التالي';

  @override
  String get useAVNCByDefault => 'استخدام AVNC افتراضيًا';

  @override
  String get termuxX11Advantages =>
      'Termux:X11 قد يوفر سرعات أعلى من VNC في بعض السيناريوهات.\n\nلاحظ أن Termux:X11 يعمل بشكل مختلف قليلاً عن AVNC:\n- النقر بإصبعين يعكب زر الفأرة الأيمن\n- الضغط على زر الرجوع يظهر لوحة المفاتيح الإضافية\n\nإذا واجهت شاشة سوداء، حاول إغلاق التطبيق وإعادة تشغيله تمامًا.';

  @override
  String get termuxX11Preferences => 'تفضيلات Termux:X11';

  @override
  String get useTermuxX11ByDefault => 'استخدام Termux:X11 افتراضيًا';

  @override
  String get disableVNC => 'تعطيل VNC. يتطلب إعادة تشغيل';

  @override
  String get hidpiAdvantages =>
      'بنقرة واحدة لتمكين وضع HiDPI لعرض أوضح... على حساب تقليل السرعة.';

  @override
  String get hidpiEnvVar => 'متغيرات بيئة HiDPI';

  @override
  String get hidpiSupport => 'دعم HiDPI';

  @override
  String get fileAccess => 'الوصول إلى الملفات';

  @override
  String get fileAccessGuide => 'دليل الوصول إلى الملفات';

  @override
  String get fileAccessHint =>
      'طلب صلاحيات ملفات إضافية للوصول إلى المجلدات الخاصة.';

  @override
  String get requestStoragePermission => 'طلب صلاحية التخزين';

  @override
  String get requestAllFilesAccess => 'طلب الوصول لجميع الملفات';

  @override
  String get ignoreBatteryOptimization => 'تجاهل تحسين البطارية';

  @override
  String get graphicsAcceleration => 'تسريع الرسومات';

  @override
  String get experimentalFeature => 'ميزة تجريبية';

  @override
  String get graphicsAccelerationHint =>
      'يستخدم معالج الرسومات في الجهاز لتحسين أداء الرسومات، ولكن قد يسبب عدم استقرار النظام بسبب اختلاف الأجهزة.\n\nVirgl يوفر تسريعًا لتطبيقات OpenGL ES.';

  @override
  String get virglServerParams => 'معاملات خادم Virgl';

  @override
  String get virglEnvVar => 'متغيرات بيئة Virgl';

  @override
  String get enableVirgl => 'تمكين تسريع Virgl';

  @override
  String get turnipAdvantages =>
      'الأجهزة ذات معالج Adreno يمكنها استخدام برنامج تشغيل Turnip لتسريع تطبيقات Vulkan. مدمج مع برنامج تشغيل Zink لتسريع تطبيقات OpenGL.\n(للأجهزة ذات معالجات Snapdragon ليست قديمة جدًا)';

  @override
  String get turnipEnvVar => 'متغيرات بيئة Turnip';

  @override
  String get enableTurnipZink => 'تمكين برامج تشغيل Turnip+Zink';

  @override
  String get enableDRI3 => 'تمكين DRI3';

  @override
  String get dri3Requirement => 'DRI3 يتطلب Termux:X11 و Turnip';

  @override
  String get windowsAppSupport => 'دعم تطبيقات ويندوز';

  @override
  String get hangoverDescription =>
      'تشغيل تطبيقات ويندوز باستخدام Hangover (تشغيل تطبيقات متعددة الهندسة على Wine الأصلي)!\n\nتشغيل برامج ويندوز يتطلب طبقتين من المحاكاة (الهندسة + النظام) - لا تتوقع أداءً جيدًا!\n\nلتحسين السرعة، حاول تمكين تسريع الرسومات. الأعطال أو الفشل أمر طبيعي.\n\nيوصى بنقل برامج ويندوز إلى سطح المكتب قبل التشغيل.\n\nكن صبورًا. حتى لو لم تظهر واجهة المستخدم الرسومية أي شيء. تحقق من الطرفية - هل ما زالت تعمل أم توقفت بخطأ؟\n\nأو تحقق مما إذا كان تطبيق ويندوز له نسخة Linux arm64 رسمية.';

  @override
  String get installHangoverStable => 'تثبيت Hangover المستقر';

  @override
  String get installHangoverLatest => 'تثبيت Hangover الأحدث (قد يفشل)';

  @override
  String get uninstallHangover => 'إلغاء تثبيت Hangover';

  @override
  String get clearWineData => 'مسح بيانات Wine';

  @override
  String get wineCommandsHint =>
      'أوامر Wine الشائعة. انقر لتشغيل واجهة المستخدم الرسومية وانتظر بصبر.\n\nأوقات التشغيل النموذجية:\nTiger T7510 6GB: أكثر من دقيقة\nSnapdragon 870 12GB: ~10 ثوانٍ';

  @override
  String get switchToJapanese => 'تحويل النظام إلى اليابانية';

  @override
  String get userManual => 'دليل المستخدم';

  @override
  String get openSourceLicenses => 'تراخيص المصدر المفتوح';

  @override
  String get permissionUsage => 'استخدام الصلاحيات';

  @override
  String get privacyStatement =>
      '\nهذا التطبيق لا يجمع معلوماتك الخاصة.\n\nمع ذلك، لا أستطيع التحكم في سلوكيات التطبيقات التي تثبتها/تستخدمها داخل نظام الحاوية (بما في ذلك عبر أوامر الاختصار).\n\nالصلاحيات المطلوبة مستخدمة من أجل:\nصلاحيات الملفات: الوصول إلى مجلدات الهاتف\nالإشعارات وإمكانية الوصول: مطلوبة من قبل Termux:X11';

  @override
  String get supportAuthor => 'دعم المطورين';

  @override
  String get recommendApp => 'إذا وجدته مفيدًا، يرجى التوصية به للآخرين!';

  @override
  String get projectUrl => 'رابط المشروع';

  @override
  String get commandEdit => 'تحرير الأمر';

  @override
  String get commandName => 'اسم الأمر';

  @override
  String get commandContent => 'محتوى الأمر';

  @override
  String get deleteItem => 'حذف العنصر';

  @override
  String get add => 'إضافة';

  @override
  String get resetCommand => 'إعادة تعيين الأمر';

  @override
  String get confirmResetAllCommands => 'إعادة تعيين جميع أوامر الاختصار؟';

  @override
  String get addShortcutCommand => 'إضافة أمر اختصار';

  @override
  String get more => 'المزيد';

  @override
  String get terminal => 'الطرفية';

  @override
  String get control => 'التحكم';

  @override
  String get enterGUI => 'الدخول إلى واجهة المستخدم الرسومية';

  @override
  String get enterNumber => 'يرجى إدخال رقم';

  @override
  String get enterValidNumber => 'يرجى إدخال رقم صحيح';

  @override
  String get installingBootPackage => 'جاري تثبيت حزمة التمهيد';

  @override
  String get copyingContainerSystem => 'جاري نسخ ملفات النظام';

  @override
  String get installingContainerSystem => 'جاري تثبيت ملفات النظام';

  @override
  String get installationComplete => 'اكتمل التثبيت';

  @override
  String get reinstallingBootPackage => 'جاري إعادة تثبيت حزمة التمهيد';

  @override
  String get issueUrl => 'الإبلاغ عن مشكلة';

  @override
  String get faqUrl => 'الأسئلة الشائعة';

  @override
  String get solutionUrl => 'دليل الاستخدام';

  @override
  String get discussionUrl => 'النقاش';

  @override
  String get firstLoadInstructions =>
      'التشغيل الأول يستغرق حوالي 5 إلى 10 دقائق... ولا يتطلب اتصالاً بالإنترنت.\n\nعادةً، التطبيق سيعيد التوجيه تلقائيًا إلى واجهة المستخدم الرسومية بعد التحميل.\n\nفي واجهة المستخدم الرسومية:\n- انقر للنقر الأيسر\n- اضغط مطولاً للنقر الأيمن\n- النقر بإصبعين لفتح لوحة المفاتيح\n- السحب بإصبعين لعجلة الفأرة\n\nيرجى عدم إغلاق التطبيق أثناء التثبيت.\n\nأثناء الانتظار، يمكنك النقر على الزر أدناه لطلب الصلاحيات.\n\nالعديد من المجلدات في XoDos (مثل التنزيلات، المستندات، الصور) مربطة بمجلدات الجهاز المقابلة. بدون هذه الصلاحيات، سيتم رفض الوصول إلى هذه المجلدات.\n\nإذا كنت لا تحتاج للوصول إلى هذه المجلدات، يمكنك تخطي منح صلاحيات الملفات (ولكن هذا قد يتسبب في فشل Firefox عند تنزيل الملفات بسبب رفض الوصول إلى مجلد التنزيلات).';

  @override
  String get updateRequest =>
      'يرجى محاولة استخدام أحدث إصدار. قم بزيارة عنوان المشروع للتحقق من أحدث إصدار.';

  @override
  String get avncScreenResize => 'تكيف حجم الشاشة';

  @override
  String get avncResizeFactor => 'نسبة تحجيم الشاشة';

  @override
  String get avncResizeFactorValue => 'التحجيم الحالي هو';
}
