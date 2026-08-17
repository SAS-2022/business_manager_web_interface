// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'CostEra';

  @override
  String get register => 'تسجيل';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get lastName => 'اسم العائلة';

  @override
  String get emailAddress => 'عنوان البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get confirmPass => 'تأكيد كلمة المرور';

  @override
  String get notEmpty => 'يجب ألا يكون فارغًا';

  @override
  String get emailValidation => 'البريد الإلكتروني غير صالح';

  @override
  String get shortPassword => '8 أحرف على الأقل';

  @override
  String get needNumber => 'على الأقل رقم واحد';

  @override
  String get needSpCharacter => 'على الأقل رمز خاص \$ # @ ...إلخ';

  @override
  String get firstNameRequired => 'الاسم الأول مطلوب';

  @override
  String get lastNameRequired => 'اسم العائلة مطلوب';

  @override
  String get emailAddressRequired => 'عنوان البريد الإلكتروني مطلوب';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';

  @override
  String get confirmpasswordRequired => 'تأكيد كلمة المرور مطلوب';

  @override
  String get passwordNoMatcH => 'كلمات المرور غير متطابقة';

  @override
  String get connectionError => 'خطأ في الاتصال، حاول مرة أخرى لاحقًا';

  @override
  String get createYourAccount => 'أنشئ حسابك';

  @override
  String get personalInfo => 'المعلومات الشخصية';

  @override
  String get accountInfo => 'معلومات الحساب';

  @override
  String get alreadyHaveAccount => 'هل لديك حساب بالفعل؟';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get forgotPass => 'نسيت كلمة المرور';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get googleSignIn => 'جوجل';

  @override
  String get appleSignIn => 'آبل';

  @override
  String get verifyEmail => 'يرجى التحقق من البريد الإلكتروني للمتابعة';

  @override
  String get verifyYourEmail => 'تحقق من بريدك الإلكتروني';

  @override
  String get verificationLinkSentTo => 'لقد أرسلنا رابط التحقق إلى';

  @override
  String get verifyEmailBody =>
      'افتح البريد الإلكتروني واضغط على الرابط لتفعيل حسابك. لا تنسَ التحقق من مجلد الرسائل غير المرغوب فيها (سبام).';

  @override
  String get resendEmail => 'إعادة إرسال البريد الإلكتروني';

  @override
  String resendEmailIn(Object seconds) {
    return 'يمكنك إعادة الإرسال خلال $seconds ثانية';
  }

  @override
  String get verificationEmailResent => 'تم إعادة إرسال بريد التحقق';

  @override
  String get emailVerifiedSuccess =>
      'تم التحقق من البريد الإلكتروني! يرجى تسجيل الدخول للمتابعة';

  @override
  String get wrongEmail => 'بريد إلكتروني خاطئ؟';

  @override
  String get waitingForVerification => 'في انتظار التحقق...';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get account => 'الحساب';

  @override
  String get appSettings => 'إعدادات التطبيق';

  @override
  String get buildNumber => 'رقم الإصدار';

  @override
  String get currency => 'العملة';

  @override
  String get businessAddress => 'عنوان العمل';

  @override
  String get assignedCurrency => 'العملة المعينة';

  @override
  String get userNotFound => 'المستخدم غير موجود';

  @override
  String get receipies => 'وصفات';

  @override
  String get selectCurrency => 'اختر العملة';

  @override
  String get emailNotVerified => 'البريد الإلكتروني غير مُحقق';

  @override
  String get changeCurrency => 'تغيير العملة';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get accountDeletionMessage =>
      'هل أنت متأكد من رغبتك في متابعة حذف حسابك؟\nسنحتفظ ببياناتك على خادمنا لمدة تصل إلى 30 يومًا قبل حذف جميع محتواك بشكل نهائي!\nنشعر بالأسى لرؤيتك تغادر ونأمل أن نراك مرة أخرى يومًا ما.';

  @override
  String get accountDeletionSuccess =>
      'تم حذف حسابك بنجاح، لديك 30 يومًا إذا قررت تغيير رأيك!';

  @override
  String get contactUs => 'اتصل بنا';

  @override
  String get rateUs => 'قيّمنا';

  @override
  String get messageContent => 'محتوى الرساله';

  @override
  String get send => 'ارسال';

  @override
  String get subject => 'الموضوع';

  @override
  String get technical => 'فني';

  @override
  String get complaint => 'شكوى';

  @override
  String get suggestion => 'اقتراح';

  @override
  String get messageCannotBeEmpty => 'محتوى الرسالة لا يمكن أن يكون فارغًا';

  @override
  String get selectSubject => 'اختر موضوع الرسالة';

  @override
  String get longPressToRemove => 'اضغط مطولًا لإزالة';

  @override
  String get personalInformation => 'المعلومات الشخصية';

  @override
  String get contactInformation => 'معلومات الاتصال';

  @override
  String get accountInformation => 'معلومات الحساب';

  @override
  String get profileUpdatedSuccessfully => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String get messageSentSuccessfully =>
      'تم إرسال الرسالة بنجاح، سيتواصل فريقنا المختص معك قريبًا.';

  @override
  String get thankYouForReachingOut =>
      'شكرًا لتواصلك معنا، سنبذل قصارى جهدنا لحل المشكلة خلال 48 ساعة.';

  @override
  String get screenShots => 'أرفق لقطات شاشة لأي مشكلة واجهتها';

  @override
  String get manageYourBusiness => 'إدارة عملك';

  @override
  String get sigIn => 'تسجيل الدخول';

  @override
  String get or => 'أو';

  @override
  String get continueWithGoogle => 'المتابعة باستخدام جوجل';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get orContinueWith => 'أو المتابعة باستخدام';

  @override
  String get resetIt => 'إعادة تعيينها';

  @override
  String get senderDetails => 'تفاصيلك';

  @override
  String get forgotPassSubtitle =>
      'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة التعيين';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get resetEmailSent =>
      'تم إرسال بريد إعادة التعيين. يرجى التحقق من صندوق الوارد.';

  @override
  String get invoiceSettings => 'إعدادات الفاتورة';

  @override
  String get invoiceSettingExplained =>
      'قم بضبط محتوى فاتورتك عن طريق تفعيل أو تعطيل الميزات';

  @override
  String get on => 'تشغيل';

  @override
  String get off => 'إيقاف';

  @override
  String get companyFinancialDetaiils => 'تفاصيلي المالية';

  @override
  String get clientCrNumber => 'رقم السجل التجاري للعميل';

  @override
  String get clientBankDetail => 'تفاصيل بنك العميل';

  @override
  String get clientFinancialDetails => 'التفاصيل المالية للعميل';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get exitConfirmation =>
      'لديك تغييرات غير محفوظة، هل أنت متأكد أنك تريد الخروج؟';

  @override
  String get generalSettings => 'الإعدادات العامة';

  @override
  String get generalSettingsExplained => 'غيّر إعدادات تطبيقك وفقًا لمتطلباتك';

  @override
  String get assignedLanguage => 'اللغة المعينة';

  @override
  String get assignedTheme => 'السمة المعينة';

  @override
  String get inventoryInfo =>
      'سيسمح لك المخزون بإنشاء ما يصل إلى 10 مواقع لتخزين منتجاتك';

  @override
  String get inventory => 'المخزون';

  @override
  String get selectNewStore => 'اختر متجرًا جديدًا';

  @override
  String get inventoryLocation => 'موقع المخزون';

  @override
  String get financialSettings => 'الإعدادات المالية';

  @override
  String get financialSettingsDesc =>
      'ستسمح لك الإعدادات المالية بتعيين المتغيرات القياسية المتعلقة ببيانك المالي';

  @override
  String get defaultSalesOrderTerms =>
      'عيّن شروط التسليم والإرجاع والاسترداد الافتراضية لطلبات المبيعات الخاصة بك';

  @override
  String get defaultPurchaseTerms =>
      'عيّن شروط التسليم والإرجاع والاسترداد الافتراضية لطلبات الشراء الخاصة بك';

  @override
  String get reactivate => 'إعادة التفعيل';

  @override
  String get status => 'الحالة';

  @override
  String get restartApp => 'إعادة تشغيل التطبيق';

  @override
  String get restartAppLangInfo =>
      'لتغيير اللغة، تحتاج إلى إعادة تشغيل التطبيق. هل أنت متأكد من رغبتك في المتابعة؟';

  @override
  String get restartAppThemeInfo =>
      'لتغيير السمة، تحتاج إلى إعادة تشغيل التطبيق. هل أنت متأكد من رغبتك في المتابعة؟';

  @override
  String get inventoryController => 'وحدة التحكم في المخزون';

  @override
  String get inventoryIntro =>
      'خيار المخزون سيسمح لك بإنشاء مواقع لتخزين المنتجات. لكن انتبه، عند تفعيل المخزون، سيرتبط طلبك مباشرة ولن تتمكن معالجته في حال نفاد المخزون.';

  @override
  String get activateInventory => 'تفعيل المخزون';

  @override
  String get locationName => 'اسم الموقع';

  @override
  String get inventoryLocationLimit =>
      'لقد وصلت إلى الحد الأقصى المسموح به لمواقع المخزون';

  @override
  String get inventoryValue => 'قيمة المخزون';

  @override
  String get inventoryInActive => 'المخزون معطل';

  @override
  String get doActivateInventory => 'هل ترغب في تفعيل خيار المخزون؟';

  @override
  String get locationNameEmpty => 'اسم الموقع فارغ، يرجى إصلاحه للمتابعة';

  @override
  String get purchaseOrder => 'أمر الشراء';

  @override
  String get purchaseInfo =>
      'تتيح لك ميزة الشراء إنشاء أوامر شراء لمورديك والتي ستقوم بتحديث تكلفة المنتج تلقائيًا إذا اخترت ذلك';

  @override
  String get purchaseSettings => 'إعدادات الشراء';

  @override
  String get activatePurchases => 'تفعيل الشراء';

  @override
  String get updateProductCost => 'تحديث تكلفة المنتج';

  @override
  String get purchases => 'المشتريات';

  @override
  String get addPurchase => 'إضافة شراء';

  @override
  String get editPurchase => 'تعديل الشراء';

  @override
  String get noSupplierFound => 'لم يتم العثور على مورد';

  @override
  String get supplierName => 'اسم المورد';

  @override
  String get supplierNameEmpty => 'اسم المورد لا يمكن أن يكون فارغًا';

  @override
  String get supplierNameInvalid => 'اسم المورد غير صالح';

  @override
  String get purchaseTerms => 'شروط الشراء';

  @override
  String get generatePO => 'إنشاء أمر شراء';

  @override
  String get generatePoInfo =>
      'بمجرد إنشاء أمر الشراء، لن تتمكن بعد ذلك من تعديل أو تغيير طلبك. في حال احتجت إلى إلغائه، يمكنك حذف الطلب وإنشاء طلب جديد';

  @override
  String get receivingPO => 'استلام أمر الشراء';

  @override
  String get receive => 'استلام';

  @override
  String get receiveInfo =>
      'سيسمح لك هذا بتأكيد ما إذا تم استلام أمر الشراء أو تعديل الكمية المستلمة';

  @override
  String get materialAlreadyReceived =>
      'تم استلام المواد من أمر الشراء هذا مسبقًا';

  @override
  String get receiveMaterial => 'استلام المادة';

  @override
  String get remove => 'إزالة';

  @override
  String get storeNotAssigned => 'لم يتم تعيين المتجر';

  @override
  String storeNotExisting(Object product, Object store) {
    return 'المتجر المحدد $store غير موجود لهذا المنتج $product';
  }

  @override
  String get purchaseOrderGenerationComplete => 'اكتمل إنشاء أمر الشراء';

  @override
  String get generated => 'تم الإنشاء';

  @override
  String get received => 'تم الاستلام';

  @override
  String get revertingBackNotPossible =>
      'يرجى ملاحظة أنه لا يمكن الرجوع إلى تكلفة الصنف السابقة في الوقت الحالي، يرجى القيام بذلك يدويًا';

  @override
  String get suppliers => 'الموردون';

  @override
  String get addSupplier => 'إضافة مورد';

  @override
  String get editSupplier => 'تعديل المورد';

  @override
  String get supplierOrders => 'طلبات الموردين';

  @override
  String get home => 'الرئيسية';

  @override
  String get product => 'الاصناف';

  @override
  String get settings => 'الإعدادات';

  @override
  String get menu => 'القائمة';

  @override
  String get orders => 'الطلبات';

  @override
  String get payments => 'المدفوعات';

  @override
  String get businessType => 'نوع العمل';

  @override
  String get businessCategory => 'فئة العمل';

  @override
  String get businessTypeDes =>
      'اختر نوع العمل الذي يصف عملك بشكل أفضل، وضع في اعتبارك أنه سيؤثر على كيفية حساب تكلفة المنتج';

  @override
  String get businessCategoryDes =>
      'اختر فئة العمل إذا كانت متوفرة أو أخرى إذا لم تكن متوفرة، سننظر في الأمر وسنحاول إضافتها في المستقبل';

  @override
  String get businessTypeNotDefined =>
      'يبدو أن نوع العمل غير محدد، يرجى التحقق من حسابك وتعيين نوع العمل';

  @override
  String get missingCategory => 'تحتاج إلى اختيار فئة';

  @override
  String get missingType => 'تحتاج إلى اختيار نوع';

  @override
  String get fillManualCategory => 'املأ فئة عملك';

  @override
  String get select => 'اختر';

  @override
  String get update => 'تحديث';

  @override
  String get companyInfo => 'معلومات الشركة';

  @override
  String get companyName => 'اسم الشركة';

  @override
  String get companyLogo => 'شعار الشركة';

  @override
  String get save => 'حفظ';

  @override
  String get companyLogoMissing => 'شعار الشركة مفقود';

  @override
  String get dataSaveSuccessfully => 'تم حفظ البيانات بنجاح';

  @override
  String get failedToSaveData => 'فشل في حفظ البيانات';

  @override
  String get imageRemovedSuccessfully => 'تمت إزالة الصورة بنجاح';

  @override
  String get failedToRemoveImage => 'فشل في إزالة الصورة';

  @override
  String get currencyDes =>
      'اختر العملة التي ترغب في إجراء عملك بها، يمكن تغييرها لاحقًا';

  @override
  String get locationDes =>
      'اختر الموقع الذي سيتم إجراء عملك منه، يمكن تغييره لاحقًا';

  @override
  String get noApiKeyDetected => 'لم يتم اكتشاف مفتاح API، يرجى الاتصال بالدعم';

  @override
  String get viewMore => 'عرض المزيد';

  @override
  String get locationChoice => 'هل ترغب في منح التطبيق إذن الوصول إلى موقعك؟';

  @override
  String get skip => 'تخطي';

  @override
  String get dataRefereshedSuccessfully => 'تم تحديث البيانات بنجاح';

  @override
  String get dataFailedToRefresh => 'فشل في تحديث البيانات';

  @override
  String get businessTypeSubDes => 'سيساعدنا ذلك في تخصيص تجربتك.';

  @override
  String get continueLabel => 'متابعة';

  @override
  String get stepOneOfTwo => 'الخطوة 1 من 2';

  @override
  String get currencySubDes => 'تُستخدم عبر جميع الفواتير والطلبات والتقارير.';

  @override
  String get stepTwoOfTwo => 'الخطوة 2 من 2';

  @override
  String get finishSetup => 'إنهاء الإعداد';

  @override
  String get addressNotRegistered => 'لم يتم تسجيل العنوان';

  @override
  String get noLocationSelected => 'لم يتم اختيار الموقع';

  @override
  String get selectLocation => 'اختر الموقع';

  @override
  String get locServiceDisabled => 'خدمة الموقع معطلة';

  @override
  String get locServiceDenied => 'تم رفض خدمة الموقع';

  @override
  String get locServiceDeniedForever =>
      'تم رفض أذونات الموقع بشكل دائم. إذا كنت ترغب في تعيين موقعك، يرجى الانتقال إلى إعدادات جهازك وتمكين الأذونات من هناك.';

  @override
  String get locationPermissionDenied => 'تم رفض إذن الموقع';

  @override
  String get locationPermissionPermanentlyDenied =>
      'تم رفض إذن الموقع بشكل دائم';

  @override
  String get locationServicesDisabled => 'تم تعطيل خدمات الموقع';

  @override
  String get networkError => 'خطأ في الشبكة، حاول مرة أخرى';

  @override
  String get configurationError => 'خطأ في الإعدادات، حاول مرة أخرى';

  @override
  String get somethingWentWrong => 'حدث خطأ ما، يرجى الاتصال بالدعم';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get retry => 'جرب مره اخرى';

  @override
  String get addProduct => 'إضافة صنف';

  @override
  String get editProduct => 'تعديل الصنف';

  @override
  String get productName => 'اسم الصنف';

  @override
  String get itemCode => 'رمز الصنف';

  @override
  String get productDescription => 'وصف الصنف';

  @override
  String get productPacking => 'عبوة الصنف (مثال: كجم، قطعة...)';

  @override
  String get productCost => 'تكلفة الصنف';

  @override
  String get productCostService => 'تكلفة الصنف (اختياري)';

  @override
  String get productPrice => 'سعر بيع الصنف';

  @override
  String get images => 'الصور';

  @override
  String get files => 'الملفات';

  @override
  String get noImages => 'لم يتم العثور على صور';

  @override
  String get productNameEmpty => 'اسم الصنف لا يمكن أن يكون فارغًا';

  @override
  String get productCostEmpty =>
      'يجب إدخال تكلفة الصنف، أدخل 0 إذا كنت لا ترغب في إضافة تكلفة';

  @override
  String get productPriceEmpty =>
      'يجب أن يحتوي الصنف على سعر، أدخل 0 للمنتجات المجانية';

  @override
  String get productImageEmpty =>
      'يجب أن يحتوي أي صنف على صورة واحدة على الأقل';

  @override
  String get noProductsAdded => 'لم يتم إضافة أي أصناف';

  @override
  String get productCostError => 'تحقق مما إذا كانت فئة عملك محددة';

  @override
  String get addCost => 'إضافة تكلفة';

  @override
  String get editCost => 'تعديل التكلفة';

  @override
  String get saveProductFirst => 'احفظ الصنف أولاً، ثم يمكنك إضافة التكلفة';

  @override
  String get costValue => 'قيمة التكلفة';

  @override
  String get error => 'خطأ';

  @override
  String get noProductFound => 'لم يتم العثور على أصناف';

  @override
  String get productCategory => 'فئة الصنف (اختياري)';

  @override
  String get productCategoryHint =>
      'اكتب أي فئة؛ سيتم إنشاؤها بعد إضافة المنتج';

  @override
  String get id => 'المعرف';

  @override
  String get filterOptions => 'خيارات التصفية';

  @override
  String get filterProducts => 'تصفية الأصناف';

  @override
  String get searchProducts => 'بحث في الأصناف';

  @override
  String get priceRange => 'نطاق السعر';

  @override
  String get minPrice => 'أقل سعر';

  @override
  String get maxPrice => 'أعلى سعر';

  @override
  String get applyFilter => 'تطبيق التصفية';

  @override
  String get productCodeExists => 'رمز الصنف موجود مسبقًا';

  @override
  String get itemCodeEmpty => 'رمز الصنف لا يمكن أن يكون فارغًا';

  @override
  String get noCategoriesFound => 'لم يتم العثور على فئات';

  @override
  String get productRecords => 'سجلات الصنف';

  @override
  String get productsLimit =>
      'يبدو أنك وصلت إلى حد المنتجات في الإصدار المجاني، اشترك في خطتنا المدفوعة للاستمتاع بعدد غير محدود من المنتجات';

  @override
  String get orderLimit =>
      'يبدو أنك وصلت إلى حد الطلبات في الإصدار المجاني، اشترك في خطتنا المدفوعة للاستمتاع بعدد غير محدود من الطلبات';

  @override
  String get category => 'الفئة';

  @override
  String get subscribeToAccessInventory => 'اشترك للوصول إلى المخزون';

  @override
  String get basicInfo => 'معلومات أساسية';

  @override
  String get auto => 'تلقائي';

  @override
  String get packaging => 'التعبئة';

  @override
  String get pricing => 'التسعير';

  @override
  String get profitMargin => 'هامش الربح';

  @override
  String get noItemRecordFound => 'لم يتم العثور على أي سجل للصنف';

  @override
  String get clearFilter => 'مسح الفلاتر';

  @override
  String get receipes => 'وصفات';

  @override
  String get addReceipe => 'إضافة وصفة';

  @override
  String get editRecipe => 'تعديل الوصفة';

  @override
  String get noReceipesFound => 'لم يتم العثور على وصفات';

  @override
  String get receipeName => 'اسم الوصفة';

  @override
  String get receipeDescription => 'وصف الوصفة';

  @override
  String get receipePacking => 'تعبئة الوصفة';

  @override
  String get receipeIngredients => 'مكونات الوصفة';

  @override
  String get cost => 'التكلفة';

  @override
  String get pack => 'التعبئة';

  @override
  String get packService => 'حزمة او جلسات';

  @override
  String get quantity => 'الكمية';

  @override
  String get suggestions => 'اقتراحات';

  @override
  String get unit => 'وحدة';

  @override
  String get selectedIngredientFirst => 'تحتاج إلى اختيار مكون أولاً';

  @override
  String get add => 'إضافة';

  @override
  String get totalCost => 'التكلفة الإجمالية';

  @override
  String get packingUnit => 'الوحدة';

  @override
  String get receipeNameRequired => 'اسم الوصفة مطلوب';

  @override
  String get receipePackingRequired => 'قيمة تعبئة الوصفة مطلوبة';

  @override
  String get receipePackingUnitRequired => 'وحدة تعبئة الوصفة مطلوبة';

  @override
  String get ingredientsMissing =>
      'يجب أن تحتوي كل وصفة على مكون واحد على الأقل';

  @override
  String get tapReceipeToAdd => 'اضغط على الوصفة لإضافتها إلى المنتج';

  @override
  String get recipeDetails => 'تفاصيل الوصفة';

  @override
  String get outputPacking => 'تعبئة الناتج';

  @override
  String get rawMaterial => 'المواد الخام';

  @override
  String get noRawMaterialsFound => 'لم يتم العثور على مواد خام';

  @override
  String get rawMaterialAdd => 'إضافة جديد';

  @override
  String get rawMaterialEdit => 'تعديل الحالي';

  @override
  String get name => 'الاسم';

  @override
  String get description => 'الوصف';

  @override
  String get nameRequired => 'الاسم مطلوب';

  @override
  String get quantityRequired => 'الكمية مطلوبة';

  @override
  String get unitRequired => 'الوحدة مطلوبة';

  @override
  String get costRequired => 'التكلفة مطلوبة';

  @override
  String get quantityAndUnit => 'الكمية والوحدة';

  @override
  String get conversionRates => 'معدلات التحويل';

  @override
  String get gallery => 'المعرض';

  @override
  String get camera => 'الكاميرا';

  @override
  String get addImage => 'إضافة صورة';

  @override
  String get editImage => 'تعديل الصورة';

  @override
  String get search => 'بحث';

  @override
  String get imageSelectionError =>
      'خطأ في محاولة اختيار الصورة، يرجى المحاولة مرة أخرى';

  @override
  String get imageNotSelected => 'فشل في اختيار الصورة';

  @override
  String get cameraPermissionDenied => 'لم يتم منح إذن الوصول إلى الكاميرا';

  @override
  String get mediaPermissionDenied => 'لم يتم منح إذن الوصول إلى الوسائط';

  @override
  String get failedToUploadImage => 'فشل في تحميل الصورة';

  @override
  String get failedToUploadVideo => 'فشل في تحميل الفيديو';

  @override
  String get delete => 'حذف';

  @override
  String get deleteConfirmation => 'هل أنت متأكد أنك تريد الحذف؟';

  @override
  String deleteConfirmationWithCount(Object number) {
    return 'هل أنت متأكد من رغبتك في حذف $number عنصرًا؟';
  }

  @override
  String get cancel => 'إلغاء';

  @override
  String get active => 'نشط';

  @override
  String get discard => 'تجاهل';

  @override
  String get cancelConfirmation => 'هل أنت متأكد من رغبتك في إلغاء هذا الطلب؟';

  @override
  String get warning => 'تحذير';

  @override
  String get ok => 'موافق';

  @override
  String get restore => 'استعادة';

  @override
  String get restoreConfirmation =>
      'هل أنت متأكد من رغبتك في استعادة هذا الطلب؟';

  @override
  String imagesDeleted(Object number) {
    return 'تم حذف $number من الصور';
  }

  @override
  String get failedToDeleteImages => 'فشل في حذف الصورة المحددة';

  @override
  String get selected => 'محدد';

  @override
  String get changingTypeNotPossible =>
      'لا يمكنك تغيير نوع العمل بعد الآن لأنك قد أضفت منتجات بالفعل';

  @override
  String get doubleToAdd => 'انقر مرتين على الصورة لإضافتها إلى المنتج';

  @override
  String get client => 'عميل';

  @override
  String get clients => 'العملاء';

  @override
  String get addClient => 'إضافة عميل';

  @override
  String get editClient => 'تعديل العميل';

  @override
  String get noClientsFound => 'لم يتم العثور على عملاء';

  @override
  String get individual => 'فرد';

  @override
  String get company => 'شركة';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get clientNameEmpty => 'اسم العميل لا يمكن أن يكون فارغًا';

  @override
  String get clientNameInvalid => 'اسم العميل غير صالح';

  @override
  String get companyNameEmpty =>
      'اسم الشركة لا يمكن أن يكون فارغًا، يرجى الذهاب إلى الإعدادات -> الحساب وتعيين اسم شركتك';

  @override
  String get phoneNumberEmpty =>
      'رقم الهاتف لا يمكن أن يكون فارغًا، يرجى الذهاب إلى الإعدادات -> الحساب وتعيين شعار شركتك';

  @override
  String get phoneCodeEmpty => 'يجب اختيار رمز الهاتف';

  @override
  String get clientName => 'اسم العميل';

  @override
  String get clientOrders => 'طلبات العميل';

  @override
  String get clientCompanyName => 'اسم شركة العميل لا يمكن أن يكون فارغًا';

  @override
  String get financialNumber => 'الرقم المالي';

  @override
  String get crNumber => 'رقم السجل التجاري';

  @override
  String get ibanNumber => 'رقم الآيبان';

  @override
  String get bankName => 'اسم البنك';

  @override
  String get bankBranch => 'فرع البنك';

  @override
  String get otherPayment => 'طريقة دفع أخرى';

  @override
  String get order => 'طلب';

  @override
  String get due => 'مستحق';

  @override
  String get overDue => 'متأخر الدفع';

  @override
  String get clientType => 'نوع العميل';

  @override
  String get contactInfo => 'معلومات الاتصال';

  @override
  String get officialData => 'البيانات الرسمية';

  @override
  String get reports => 'التقارير';

  @override
  String get capitalAndExpenses => 'رأس المال والمصروفات';

  @override
  String get financialReports => 'التقارير المالية';

  @override
  String get expenses => 'المصروفات';

  @override
  String get fixedCosts => 'التكاليف الثابتة';

  @override
  String get assets => 'الأصول';

  @override
  String get costs => 'التكاليف';

  @override
  String get noOrdersFound => 'لم يتم العثور على طلبات';

  @override
  String get addOrder => 'إضافة طلب';

  @override
  String get editOrder => 'تعديل الطلب';

  @override
  String get itemQuantity => 'الكمية';

  @override
  String get discount => 'الخصم';

  @override
  String get price => 'السعر';

  @override
  String get discountedPrice => 'السعر المخفض';

  @override
  String get quantityCannotBeEmpty => 'الكمية لا يمكن أن تكون فارغة';

  @override
  String get priceCannotBeEmpty => 'السعر لا يمكن أن يكون فارغًا';

  @override
  String get cannotPerformDiscountOnAddedPrice =>
      'لا يمكنك إجراء خصم على زيادة السعر';

  @override
  String get totalValue => 'القيمة الإجمالية';

  @override
  String get productListEmpty => 'قائمة المنتجات لا يمكن أن تكون فارغة';

  @override
  String get orderTerms => 'شروط الطلب';

  @override
  String get deliveryTerms => 'شروط التسليم';

  @override
  String get deliveryTime => 'وقت التسليم';

  @override
  String get immediate => 'فوري';

  @override
  String get scheduled => 'مجدول';

  @override
  String get selectTime => 'اختر الوقت';

  @override
  String get selectTimeFirst => 'اختر الوقت أولاً';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get selectDateFirst => 'اختر التاريخ أولاً';

  @override
  String get immediateDelivery => 'سيتم تحديد الطلب ليتم تسليمه فورًا';

  @override
  String get noOrderFound => 'لم يتم العثور على طلب';

  @override
  String get invoice => 'فاتورة';

  @override
  String get number => 'رقم';

  @override
  String get subtotal => 'المجموع الفرعي';

  @override
  String get total => 'الإجمالي';

  @override
  String get paymentTerms => 'شروط الدفع';

  @override
  String get termsandConditions => 'الشروط والأحكام';

  @override
  String termsandConditionDesc(Object provider) {
    return 'يجب على كل مستخدم الموافقة على شروط $provider قبل المتابعة';
  }

  @override
  String get apple => 'آبل';

  @override
  String get google => 'غوغل';

  @override
  String get viewFullTerms =>
      'يمكنك عرض الشروط الكاملة بالنقر على الرابط أدناه';

  @override
  String get agreeToTerms => 'الموافقة على الشروط';

  @override
  String termsSummaryDetails(Object provider) {
    return 'يتم تجديد الاشتراكات تلقائيًا ما لم يتم إلغاؤها قبل 24 ساعة على الأقل من موعد التجديد، وتخضع جميع عمليات الشراء لسياسات $provider.';
  }

  @override
  String get iHaveReadAndAgree => 'لقد قرأت ووافقت على الشروط والأحكام';

  @override
  String get readFullTerms => 'قراءة الشروط كاملة';

  @override
  String get needToAgreeToTerms =>
      'يجب عليك الاطلاع على شروط وأحكام التطبيق والموافقة عليها';

  @override
  String get ref => 'مرجع';

  @override
  String get invoiceNumber => 'رقم الفاتورة';

  @override
  String get invoiceGenCompleted => 'اكتمل إنشاء الفاتورة';

  @override
  String get invoiceGenFailed => 'فشل إنشاء الفاتورة، يرجى المحاولة مرة أخرى';

  @override
  String get returnTerms => 'شروط الإرجاع أو الاسترداد';

  @override
  String get returnTermsService => 'الاسترداد أو الإلغاء';

  @override
  String get close => 'إغلاق';

  @override
  String get unsavedData => 'لديك بيانات غير محفوظة، احفظها قبل الإغلاق';

  @override
  String get returns => 'الإرجاع';

  @override
  String get clientDetails => 'تفاصيل العميل';

  @override
  String get billTo => 'فاتورة إلى';

  @override
  String get scheduledOrder => 'هذا الطلب مجدول في';

  @override
  String get scheduledDate => 'تاريخ مجدول';

  @override
  String get scheduledTime => 'وقت مجدول';

  @override
  String get orderId => 'معرف الطلب';

  @override
  String get invoiced => 'تم فوترته';

  @override
  String get generateInvoice => 'إنشاء فاتورة';

  @override
  String get generateInvoiceInfo =>
      'بمجرد إنشاء الفاتورة، لن تتمكن بعد ذلك من تعديل طلبك أو تغييره. في حال احتجت إلى إلغائه، يمكنك حذف الطلب وإنشاء طلب جديد';

  @override
  String get generate => 'إنشاء';

  @override
  String get regenerate => 'إعادة إنشاء';

  @override
  String get orderPlacedAt => 'تم الطلب في';

  @override
  String get noDeliveryTerms => 'لم يتم تحديد شروط التسليم';

  @override
  String get noReturnRefundTermsSet => 'لم يتم تحديد شروط الإرجاع أو الاسترداد';

  @override
  String get orderMargins => 'هوامش الطلب';

  @override
  String get grossProfit => 'إجمالي الربح';

  @override
  String get margin => 'هامش الربح';

  @override
  String get draft => 'مسودة';

  @override
  String get noStockAvailableInLocation =>
      'لا يوجد مخزون متوفر في الموقع المحدد لهذا المنتج';

  @override
  String get insufficientInventory => 'ليس لديك مخزون كافٍ في الموقع المحدد';

  @override
  String insufficientStockFor(Object item, Object location) {
    return 'لا يوجد مخزون كافٍ للعنصر $item في الموقع $location';
  }

  @override
  String get confirmed => 'تم التأكيد';

  @override
  String get setReminder => 'تعيين تذكير';

  @override
  String get reminderMe => 'ذكرني';

  @override
  String get reminderNote =>
      'يجب ضبط التذكيرات بحيث تكون على الأقل بعد 10 دقائق من الآن';

  @override
  String get notificationDisabled =>
      'تم تعطيل الإشعارات، مما يعني أنك لن تتلقى تذكيرات لطلباتك، قم بتمكينها';

  @override
  String get deliveryCharges => 'رسوم التوصيل';

  @override
  String get deliveryFees => 'تكاليف التوصيل';

  @override
  String get noDeliveryFees => 'لم يتم تحديد رسوم التوصيل';

  @override
  String get delivery => 'التوصيل';

  @override
  String get subscribeToAccess => 'اشترك للوصول إلى الإحصاءات';

  @override
  String get cancelled => 'ملغى';

  @override
  String get cancelledOrders => 'الطلبات الملغاة';

  @override
  String get cancelledOrder =>
      'هل تريد استعادة هذا الطلب الملغى؟ اضغط نعم للاستعادة أو لا للإبقاء عليه مُلغى';

  @override
  String get orderRemainsCancelled => 'يبقى الطلب ملغى';

  @override
  String get failedToCancelOrder =>
      'فشل في إلغاء الطلب المحدد، يرجى الاتصال بالدعم';

  @override
  String get failedToRestoreOrder =>
      'فشل في استعادة الطلب المحدد، يرجى الاتصال بالدعم';

  @override
  String get orderCancelled => 'تم إلغاء الطلب';

  @override
  String get receipeIsMissing =>
      'الوصفة مفقودة، تحقق مما إذا تم حذفها أو إزالتها، ثم حدّث المنتج مرة أخرى';

  @override
  String get rawItemMissing =>
      'المادة الخام مفقودة، تحقق مما إذا تم حذفها أو إزالتها، ثم حدّث الوصفة مرة أخرى';

  @override
  String get taxValue => 'قيمة الضريبة';

  @override
  String get failedToDownloadInvoice =>
      'فشل تنزيل الفاتورة، يرجى التحقق من اتصالك بالإنترنت';

  @override
  String get collection => 'تحصيل المدفوعات';

  @override
  String collectionReminder(Object days) {
    return 'قم بتعيين تذكير ليتم تفعيله عندما يحين موعد التحصيل بعد $days يومًا';
  }

  @override
  String get shallWeRemindYou => 'هل ترغب أن نذكرك؟';

  @override
  String get quotes => 'عروض الأسعار';

  @override
  String get quoteTerms => 'شروط عرض السعر';

  @override
  String get addQuote => 'إضافة عرض سعر';

  @override
  String get editQuote => 'تعديل عرض السعر';

  @override
  String get noQuotesFound => 'لم يتم العثور على أي عروض أسعار';

  @override
  String get ordered => 'تم الطلب';

  @override
  String get quoteMargins => 'هوامش عرض السعر';

  @override
  String get quotation => 'تسعيره';

  @override
  String get quoted => 'تم التسعير';

  @override
  String get makeOrder => 'تحويل إلى طلب';

  @override
  String get generateQuote => 'إنشاء عرض سعر';

  @override
  String get edit => 'تعديل';

  @override
  String get dublicate => 'تكرار';

  @override
  String get noAssetsFound => 'لم يتم العثور على أصول';

  @override
  String get addAsset => 'إضافة أصل';

  @override
  String get editAsset => 'تعديل الأصل';

  @override
  String get value => 'القيمة';

  @override
  String get imagesOptional => 'الصور (اختياري)';

  @override
  String get valueRequired => 'القيمة مطلوبة';

  @override
  String get dataNotLoading =>
      'لم يتم تحميل البيانات بشكل صحيح، تحقق من الاتصال وحاول مرة أخرى';

  @override
  String get noExpenseFound => 'لم يتم العثور على مصروفات';

  @override
  String get addExpense => 'إضافة مصروف';

  @override
  String get editExpense => 'تعديل المصروف';

  @override
  String get imageCorrupted => 'الصورة تالفة، حاول رفع نسخة أخرى';

  @override
  String imageLimit4(Object count) {
    return 'يمكنك اختيار ما يصل إلى 4 صور فقط. لديك بالفعل $count صورة/صور.';
  }

  @override
  String get errorRemovingImage => 'خطأ في إزالة الصورة';

  @override
  String get details => 'تفاصيل';

  @override
  String get apply => 'تطبيق';

  @override
  String get selectDateRange => 'اختر نطاق التاريخ';

  @override
  String get start => 'ابدأ';

  @override
  String get end => 'إنهاء';

  @override
  String get newsUpdate => 'الأخبار';

  @override
  String get featuredProducts => 'المنتجات المميزة';

  @override
  String get latestNews => 'آخر الأخبار';

  @override
  String get salesReport => 'تقرير المبيعات';

  @override
  String get selectDateInfo =>
      'حدد نطاق التاريخ الذي ترغب في الحصول على سجل المبيعات فيه';

  @override
  String get reportGenSuccess => 'تم إنشاء التقرير بنجاح';

  @override
  String get reportGenFailed => 'فشل إنشاء التقرير';

  @override
  String get date => 'التاريخ';

  @override
  String get productCount => 'عدد المنتجات';

  @override
  String get from => 'من';

  @override
  String get to => 'إلى';

  @override
  String get totalSalesValue => 'إجمالي قيمة المبيعات';

  @override
  String get summary => 'ملخص';

  @override
  String get totalOrders => 'إجمالي الطلبات';

  @override
  String get financialDetails => 'التفاصيل المالية';

  @override
  String get pandLReport => 'تقرير الأرباح والخسائر';

  @override
  String get plVariables => 'متغيرات الأرباح والخسائر';

  @override
  String get selectDatePL =>
      'حدد نطاق التاريخ الذي ترغب في عرض تقرير الأرباح والخسائر فيه';

  @override
  String get selectOptions => 'اختر الخيارات';

  @override
  String get optionsSummary => 'ملخص الخيارات';

  @override
  String get noOptionsSelected => 'لم يتم اختيار أي خيارات';

  @override
  String get noPreviousRecordSaved => 'لم يتم حفظ أي سجلات سابقة';

  @override
  String get export => 'تصدير';

  @override
  String get dateRangeisCrucial =>
      'نطاق التاريخ مطلوب، يرجى تحديد النطاق قبل المتابعة';

  @override
  String get saveRecord => 'حفظ السجل';

  @override
  String get plSummary => 'ملخص الأرباح والخسائر';

  @override
  String get profitLossStatement => 'Profit & Loss Statement';

  @override
  String get period => 'الفترة';

  @override
  String get totalRevenue => 'إجمالي الإيرادات';

  @override
  String get operatingExpenses => 'المصروفات التشغيلية';

  @override
  String get operatingIncome => 'الدخل التشغيلي';

  @override
  String get nonOperatingIncomeExpense => 'الدخل/المصروفات غير التشغيلية';

  @override
  String get earningBeforeTax => 'الأرباح قبل الضريبة';

  @override
  String get taxDesc =>
      'قم بتعيين الضريبة المطبقة عليك فقط؛ إذا تركت الحقل فارغًا فلن يتم تضمين الضريبة في سجلاتك المالية';

  @override
  String get incomeTax => 'ضريبة الدخل';

  @override
  String get salesTax => 'ضريبة المبيعات';

  @override
  String get stateTax => 'ضريبة الولاية';

  @override
  String get governmentTax => 'ضريبة حكومية';

  @override
  String get netIncome => 'صافي الدخل';

  @override
  String get detailedBreakDown => 'تفصيل مفصل';

  @override
  String get nonOperatingItems => 'بنود غير تشغيلية';

  @override
  String get investmentIncome => 'دخل الاستثمار';

  @override
  String get interestExpense => 'مصاريف الفائدة';

  @override
  String get foreignExchange => 'ربح/خسارة صرف العملات الأجنبية';

  @override
  String get keyFinancialMetrics => 'Key Financial Metrics';

  @override
  String get grossProfitMargin => 'هامش الربح الإجمالي';

  @override
  String get operatingMargin => 'هامش التشغيل';

  @override
  String get netProfitMargin => 'هامش الربح الصافي';

  @override
  String get percentageCogs => 'نسبة تكلفة البضائع المباعة من الإيرادات';

  @override
  String get saveFinancialRecord =>
      'هل ترغب في حفظ سجلات البيانات هذه للاستخدام المستقبلي؟';

  @override
  String get pandLStatement => 'بيان الأرباح والخسائر';

  @override
  String get failedToRetrieveData => 'فشل في استرداد البيانات';

  @override
  String get connectionLost => 'انقطع الاتصال';

  @override
  String get checkYourConnection => 'تحقق من اتصالك بالإنترنت';

  @override
  String get topProducts => 'أفضل المنتجات';

  @override
  String get soldQuantity => 'الكمية المباعة';

  @override
  String get averagePrice => 'متوسط السعر';

  @override
  String get subscribe => 'اشتراك';

  @override
  String get premiumUser => 'مستخدم بريميوم';

  @override
  String get googlePlay => 'متجر Google Play';

  @override
  String get appleStore => 'متجر App Store';

  @override
  String paymenetCharging(Object store) {
    return 'سيتم تحصيل المبلغ من حسابك على (store) عند تأكيد الشراء. يتم تجديد الاشتراك تلقائيًا ما لم يتم إيقاف التشغيل التلقائي قبل 24 ساعة على الأقل من نهاية الفترة الحالية.';
  }

  @override
  String get privacyAndTerms => 'سياسة الخصوصية';

  @override
  String get termsOfUse => 'شروط الاستخدام';

  @override
  String get cont => 'متابعة';

  @override
  String get popular => 'شائع';

  @override
  String get goPremium => 'انتقل إلى المميزات المدفوعة';

  @override
  String get unlockAll => 'افتح جميع الميزات والمحتوى';

  @override
  String get unlimitedAccess => 'وصول غير محدود إلى جميع المحتويات';

  @override
  String get exclusivePremium => 'ميزات حصرية للمستخدمين المميزين';

  @override
  String get syncAll => 'مزامنة عبر جميع أجهزتك';

  @override
  String get prioritySup => 'دعم ذو أولوية';

  @override
  String get success => 'نجح';

  @override
  String get processing => 'جاري المعالجة...';

  @override
  String get welcomePre => 'مرحبًا بك في العضوية المميزة!';

  @override
  String get startUsing => 'بدء استخدام التطبيق';

  @override
  String get upgradeToUnlock => 'قم بالترقية لفتح هذه الميزة';

  @override
  String get viewSub => 'عرض الاشتراكات';

  @override
  String get notNow => 'ليس الآن';

  @override
  String get sevenDayFree =>
      'تجربة مجانية لمدة 7 أيام • يمكنك الإلغاء في أي وقت خلال الفترة التجريبية';

  @override
  String get sevenDayDes =>
      'بعد انتهاء فترة التجربة، سيتم تجديد اشتراكك تلقائيًا وسيتم تحصيل المبلغ وفقًا للخطة التي اخترتها.';

  @override
  String get enterCoupon => 'أدخل رمز القسيمة';

  @override
  String get applyCoupon => 'تطبيق رمز القسيمة';

  @override
  String couponApplied(Object discount) {
    return 'تم تطبيق القسيمة: خصم $discount%';
  }

  @override
  String get cancelSupscription => 'الغاء الإشتراك';

  @override
  String get cancelSubWarning =>
      'هل أنت متأكد من رغبتك في إلغاء اشتراكك وفقدان جميع الميزات المضافة؟';

  @override
  String freeTrialDays(Object days) {
    return 'تجربة مجانية لمدة $days يوم';
  }

  @override
  String get freeTrial => 'تجربة مجانية';

  @override
  String get purchaseFailed => 'فشل الشراء';

  @override
  String get purchaseCancelled => 'تم إلغاء الشراء';

  @override
  String get invalidCoupon => 'رمز القسيمة غير صالح أو منتهي الصلاحية';

  @override
  String appliedCoupon(Object coupon) {
    return 'تم تطبيق القسيمة بنجاح! خصم \$$coupon٪';
  }

  @override
  String get totalToBePaid => 'المبلغ الإجمالي للدفع';

  @override
  String get freeMonth => 'شهر مجاني';

  @override
  String get freeYear => 'سنة مجانية';

  @override
  String get selectPlan => 'اختر الخطة أولاً';

  @override
  String get noOfferingsAvailable => 'لا توجد عروض متاحة';

  @override
  String get selectedPlanNotAvailable => 'الخطة المحددة غير متاحة';

  @override
  String get purchaseInactive => 'الشراء غير نشط';

  @override
  String get unableToLoadPlans => 'تعذر تحميل الخطط، حاول مرة أخرى';

  @override
  String get premiumActive => 'البريميوم مفعل!';

  @override
  String get enjoyFreeTrial => 'أنت تستخدم حاليًا الفترة التجريبية المجانية';

  @override
  String get enjoyPremium => 'مرحبًا بك في CostEra Pro!';

  @override
  String get currentPlan => 'الباقة الحالية';

  @override
  String get freeTrialActive => 'الفترة التجريبية مفعلة';

  @override
  String get trialEndsOn => 'تنتهي الفترة التجريبية في';

  @override
  String get memberSince => 'عضو منذ';

  @override
  String get yourBenefits => 'مزايا البريميوم الخاصة بك';

  @override
  String get generatePdfInvoice => 'فواتير PDF';

  @override
  String get createProfessionalInvoices => 'إنشاء فواتير PDF احترافية فورًا';

  @override
  String get detailedFinancialInsights => 'إنشاء تقارير مالية مفصلة ورؤى';

  @override
  String get expenseTracking => 'تتبع المصروفات';

  @override
  String get monitorAllExpenses => 'مراقبة وتصنيف جميع مصروفات عملك';

  @override
  String get unlimitedProducts => 'منتجات غير محدودة';

  @override
  String get addUnlimitedItems =>
      'إضافة منتجات وخدمات غير محدودة إلى الكتالوج الخاص بك';

  @override
  String get cloudSync => 'مزامنة السحابة';

  @override
  String get syncAcrossDevices => 'مزامنة بياناتك عبر جميع أجهزتك بأمان';

  @override
  String get prioritySupport => 'دعم ذو أولوية';

  @override
  String get createAndSendQuotes => 'إنشاء وإرسال عروض الأسعار';

  @override
  String get suppliersAccess => 'إدارة الموردين';

  @override
  String get manageYourSuppliers => 'إدارة ومتابعة الموردين';

  @override
  String get inventoryTracking => 'تتبع المخزون';

  @override
  String get trackStockInRealTime => 'تتبع مستويات المخزون في الوقت الفعلي';

  @override
  String get orderReminders => 'تذكيرات الطلبات والمدفوعات';

  @override
  String get neverMissAPayment => 'لا تفوّت أي موعد استحقاق أو دفعة';

  @override
  String get fasterCustomerSupport => 'احصل على ردود أسرع من فريق الدعم';

  @override
  String get cancelSubscription => 'إلغاء الاشتراك';

  @override
  String get cancelAnyTime => 'يمكنك إلغاء اشتراكك في أي وقت';

  @override
  String get loadingSubscription => 'جاري تحميل معلومات الاشتراك...';

  @override
  String get errorLoadingSubscription => 'خطأ في تحميل الاشتراك';

  @override
  String get cancelSubAtPeriodEnd =>
      'سيظل اشتراكك نشطًا حتى نهاية فترة الفوترة الحالية. ستستمر في الاستمتاع بجميع مزايا العضوية المميزة حتى ذلك الحين.';

  @override
  String get subscriptionWillCancel =>
      'سيتم إلغاء اشتراكك في نهاية فترة الفوترة الحالية.';

  @override
  String get accessUntil => 'الوصول حتى';

  @override
  String get renewsOn => 'يجدد في';

  @override
  String get cancellationRequested => 'تم طلب الإلغاء في';

  @override
  String get subscriptionExpired => 'انتهت صلاحية الاشتراك';

  @override
  String get premiumBenefitsGone =>
      'لم تعد مزايا العضوية المميزة نشطة. يرجى تجديد اشتراكك لمواصلة الاستمتاع بجميع الميزات.';

  @override
  String get daysLeft => 'أيام متبقية للبريميوم';

  @override
  String get noActiveSubscription => 'No active subscription found';

  @override
  String get manageSubscriptionThrough => 'يرجى إدارة اشتراكك من خلال';

  @override
  String get appStore => 'متجر App Store';

  @override
  String get resumeSubscription => 'استئناف الاشتراك';

  @override
  String get resumeSubscriptionConfirm =>
      'هل أنت متأكد أنك تريد استئناف اشتراكك؟ سيستمر اشتراكك وسيتم تجديده تلقائيًا كالمعتاد.';

  @override
  String get resumeSubscriptionDesc => 'تابع اشتراكك واحتفظ بجميع المزايا';

  @override
  String get resubscribe => 'إعادة الاشتراك';

  @override
  String get subscriptionResumed => 'تم استئناف اشتراكك!';

  @override
  String get cancellationPending =>
      'إلغاء اشتراكك قيد الانتظار. يمكنك استئنافه في أي وقت قبل تاريخ الانتهاء.';

  @override
  String get failedToResume => 'فشل في استئناف الاشتراك';

  @override
  String get failedToCancel => 'فشل في إلغاء الاشتراك';

  @override
  String get then => 'ثم';

  @override
  String get autoRenewal => 'معلومات التجديد التلقائي';

  @override
  String autoRenewalDes(Object store) {
    return '$store سيتم تجديد اشتراكك تلقائيًا في نهاية كل فترة ما لم يتم إلغاؤه قبل 24 ساعة على الأقل من نهاية الفترة الحالية. يمكنك إدارة اشتراكك أو إلغاؤه في أي وقت من خلال إعدادات حساب';
  }

  @override
  String get daysFree => 'تجربة مجانية لمدة - يوم';

  @override
  String subscriptionFeature(Object feature) {
    return 'الميزة $feature متاحة فقط للمستخدمين المدفوعين، ضع في اعتبارك الاشتراك للاستمتاع بوصول غير محدود';
  }

  @override
  String subscriptionOrderFeature(Object feature, Object number) {
    return 'لقد وصلت إلى حد $feature للمستخدمين المجانيين وهو $number طلبًا؛ ضع في اعتبارك الاشتراك للاستمتاع بوصول غير محدود إلى جميع الميزات والطلبات';
  }

  @override
  String get theFor => 'لمدة';

  @override
  String get months => 'أشهر';

  @override
  String get salesStats => 'إحصائيات المبيعات';

  @override
  String get sales => 'المبيعات';

  @override
  String get topClient => 'أفضل العملاء';

  @override
  String get totalSales => 'إجمالي المبيعات';

  @override
  String get averageMargin => 'متوسط هامش الربح';

  @override
  String get topFiveClients => 'أفضل 5 عملاء';

  @override
  String get profitDist => 'توزيع هامش الربح';

  @override
  String get annual => 'سنوي';

  @override
  String get monthly => 'شهري';

  @override
  String get revenueSplit => 'تقسيم الإيرادات';

  @override
  String get profit => 'الربح';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get dueSoon => 'مستحق قريبًا';

  @override
  String get onTrack => 'على المسار الصحيح';

  @override
  String get noUpcomingPayments => 'لا توجد دفعات قادمة';

  @override
  String get operationTimedOut => 'انتهت المهلة، تحقق من اتصالك وحاول مرة أخرى';

  @override
  String get today => 'اليوم';

  @override
  String get yesterday => 'أمس';

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String get lastWeek => 'الأسبوع الماضي';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get lastMonth => 'الشهر الماضي';

  @override
  String get thisYear => 'هذا العام';

  @override
  String get lastYear => 'العام الماضي';

  @override
  String get selectPeriod => 'اختر الفترة';

  @override
  String get inventoryReport => 'تقرير المخزون';

  @override
  String get keepEmptyForAllLocations => 'اتركه فارغًا لجميع المواقع';

  @override
  String get storeName => 'اسم المتجر';

  @override
  String get productStock => 'المخزون';

  @override
  String get code => 'الرمز';

  @override
  String get tutorialCompleted => 'تم إكمال البرنامج التعليمي';

  @override
  String get tutOrderScreenDes => 'سيقوم تقويم الطلبات بتتبع طلباتك الشهرية';

  @override
  String get tutQuotesDes =>
      'تتيح لك عروض الأسعار إنشاء عروض أسعار لعملائك قبل إنشاء الطلب وإصدار الفاتورة';

  @override
  String get tutDashScreenDes =>
      'سيعرض زر الصفحة الرئيسية أو لوحة المعلومات تقدمك الشهري';

  @override
  String get tutProductScreenDes =>
      'هنا يمكنك إنشاء المنتجات وتعديلها وتخصيصها. يمكن الوصول إلى جميع منتجاتك من هذه الصفحة';

  @override
  String get tutSettingScreeDes => 'ستوفر شاشة الإعدادات جميع وظائف تطبيقك';

  @override
  String get next => 'التالي';

  @override
  String get finish => 'انهاء';

  @override
  String get tutorial => 'البرنامج التعليمي';

  @override
  String get tutorialSkipped => 'تم تخطي البرنامج التعليمي';

  @override
  String get startTutorial => 'ابدأ البرنامج التعليمي';

  @override
  String get skipTutorial => 'تخطي البرنامج التعليمي';

  @override
  String get tutorialWelcome => 'مرحبًا!';

  @override
  String get tutorialStartPrompt => 'هيا نتعلم كيفية استخدام التطبيق';

  @override
  String get tutgalleryDes => 'يمكنك تحميل جميع صور منتجك أو خدمتك هنا';

  @override
  String get tutProfileDes =>
      'يمكنك تعديل جميع بياناتك الشخصية من قسم الملف الشخصي';

  @override
  String get tutAccountDes => 'يمكنك تعديل معلومات عملك من قسم الحساب';

  @override
  String get tutAppSettingDes =>
      'يمكنك تعديل إعدادات التطبيق من الألوان والسمات والمزيد من هنا!';

  @override
  String get tutClientDes => 'أضف وعدّل بيانات عملائك من هنا';

  @override
  String get tutOrdersDes => 'يمكنك إنشاء وتعديل طلباتك من خلال تبويب الطلبات';

  @override
  String get tutSupplierDes =>
      'يتيح لك تبويب الموردين إضافة الموردين وإصدار المشتريات';

  @override
  String get tutPurchasesDes =>
      'يتيح لك تبويب المشتريات إصدار وتعديل المشتريات';

  @override
  String get tutCapExpReportDes =>
      'يعتبر تبويب رأس المال والمصروفات أساسياً للتحكم في نفقاتك';

  @override
  String get tutFinancialReportDes =>
      'راقب أعمالك وتعرف على أدائك من خلال إصدار التقارير المطلوبة';

  @override
  String get tutFilterOptionDes =>
      'يتيح لك خيار التصفية البحث عن عنصر معين أو التصفية حسب متغيرات متعددة';

  @override
  String get tutAddProductDes => 'يتيح لك زر الإضافة إضافة منتجات أو خدمات!';

  @override
  String get tutPaymentDes => 'سيعرض جميع مدفوعات الائتمان لعملائك';

  @override
  String get days15 => '15 يومًا';

  @override
  String get days30 => '30 يومًا';

  @override
  String get days45 => '45 يومًا';

  @override
  String get more => 'المزيد';

  @override
  String get all => 'الكل';

  @override
  String get dueOn => 'تاريخ الاستحقاق';

  @override
  String get addPayment => 'إضافة دفعة';

  @override
  String get editPayment => 'تعديل الدفعة';

  @override
  String get upcomingPayments => 'الدفعات القادمة';

  @override
  String get updatePayment => 'تحديث الدفعة';

  @override
  String partialPayment(Object amount) {
    return 'الدفعة لا تغطي المبلغ المطلوب، سيظل الرصيد المتبقي $amount معلقًا';
  }

  @override
  String paymentOverpaid(Object amount) {
    return 'الدفعة تتجاوز الرصيد المطلوب، سيتم إضافة المبلغ الإضافي $amount كرصيد للعميل';
  }

  @override
  String get paymentCovered =>
      'تم تغطية الدفعة بالكامل وسيتم إغلاق فاتورة الائتمان وفقًا لذلك';

  @override
  String get clientStatement => 'كشف حساب العميل';

  @override
  String get method => 'طريقة الدفع';

  @override
  String get optional => 'اختياري';

  @override
  String get faq => 'الأسئلة الشائعة';

  @override
  String get question => 'سؤال';

  @override
  String get answer => 'إجابة';

  @override
  String get referenceOrder => 'مرجع الطلب';

  @override
  String get questionEmpty => 'قائمة الأسئلة فارغة';

  @override
  String get questionIsEmpty => 'لا يمكن أن يكون السؤال فارغًا';

  @override
  String get answerIsEmpty => 'لا يمكن أن تكون الإجابة فارغة';

  @override
  String get referenceIsEmpty => 'لا يمكن أن يكون المرجع فارغًا';

  @override
  String get referenceOrderExits => 'طلب مرجعي موجود بالفعل، اختر طلبًا آخر';
}
