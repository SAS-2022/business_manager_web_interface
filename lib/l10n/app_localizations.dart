import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'CostEra'**
  String get appTitle;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPass.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPass;

  /// No description provided for @notEmpty.
  ///
  /// In en, this message translates to:
  /// **'Should not be empty'**
  String get notEmpty;

  /// No description provided for @emailValidation.
  ///
  /// In en, this message translates to:
  /// **'Email is not valid'**
  String get emailValidation;

  /// No description provided for @shortPassword.
  ///
  /// In en, this message translates to:
  /// **'min 8 characters'**
  String get shortPassword;

  /// No description provided for @needNumber.
  ///
  /// In en, this message translates to:
  /// **'at least a number'**
  String get needNumber;

  /// No description provided for @needSpCharacter.
  ///
  /// In en, this message translates to:
  /// **'at least one \$ # @ ...etc'**
  String get needSpCharacter;

  /// No description provided for @firstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get firstNameRequired;

  /// No description provided for @lastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Last name is required'**
  String get lastNameRequired;

  /// No description provided for @emailAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Email address is required'**
  String get emailAddressRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @confirmpasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm password is required'**
  String get confirmpasswordRequired;

  /// No description provided for @passwordNoMatcH.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordNoMatcH;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection Error, try again later'**
  String get connectionError;

  /// No description provided for @createYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Your Account'**
  String get createYourAccount;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get personalInfo;

  /// No description provided for @accountInfo.
  ///
  /// In en, this message translates to:
  /// **'Account Info'**
  String get accountInfo;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account!'**
  String get alreadyHaveAccount;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @forgotPass.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPass;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @googleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get googleSignIn;

  /// No description provided for @appleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get appleSignIn;

  /// No description provided for @verifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Kindly verfiy email in order to proceed'**
  String get verifyEmail;

  /// No description provided for @verifyYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyYourEmail;

  /// No description provided for @verificationLinkSentTo.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a verification link to'**
  String get verificationLinkSentTo;

  /// No description provided for @verifyEmailBody.
  ///
  /// In en, this message translates to:
  /// **'Open the email and tap the link to verify your account. Don\'t forget to check your spam or junk folder.'**
  String get verifyEmailBody;

  /// No description provided for @resendEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend Email'**
  String get resendEmail;

  /// No description provided for @resendEmailIn.
  ///
  /// In en, this message translates to:
  /// **'Resend available in {seconds}s'**
  String resendEmailIn(Object seconds);

  /// No description provided for @verificationEmailResent.
  ///
  /// In en, this message translates to:
  /// **'Verification email resent'**
  String get verificationEmailResent;

  /// No description provided for @emailVerifiedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Email verified! Please log in to continue'**
  String get emailVerifiedSuccess;

  /// No description provided for @wrongEmail.
  ///
  /// In en, this message translates to:
  /// **'Wrong email?'**
  String get wrongEmail;

  /// No description provided for @waitingForVerification.
  ///
  /// In en, this message translates to:
  /// **'Waiting for verification...'**
  String get waitingForVerification;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @buildNumber.
  ///
  /// In en, this message translates to:
  /// **'Build Number'**
  String get buildNumber;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @businessAddress.
  ///
  /// In en, this message translates to:
  /// **'Business Address'**
  String get businessAddress;

  /// No description provided for @assignedCurrency.
  ///
  /// In en, this message translates to:
  /// **'Assigned Currency'**
  String get assignedCurrency;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User Not Found'**
  String get userNotFound;

  /// No description provided for @receipies.
  ///
  /// In en, this message translates to:
  /// **'Receipies'**
  String get receipies;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// No description provided for @emailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Email Not Verified'**
  String get emailNotVerified;

  /// No description provided for @changeCurrency.
  ///
  /// In en, this message translates to:
  /// **'Change Currency'**
  String get changeCurrency;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @accountDeletionMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to proceed with deleting your account?\nWe will keep your data on our server for up to 30 days before permanently deleting all your content!\nWe regret to see you leave and hope one day we shall see you again.'**
  String get accountDeletionMessage;

  /// No description provided for @accountDeletionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your account was successfully deleted, you have 30 days if you decided to change your mind!'**
  String get accountDeletionSuccess;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @rateUs.
  ///
  /// In en, this message translates to:
  /// **'Rate Us'**
  String get rateUs;

  /// No description provided for @messageContent.
  ///
  /// In en, this message translates to:
  /// **'Message Content'**
  String get messageContent;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @technical.
  ///
  /// In en, this message translates to:
  /// **'Technical'**
  String get technical;

  /// No description provided for @complaint.
  ///
  /// In en, this message translates to:
  /// **'Complaint'**
  String get complaint;

  /// No description provided for @suggestion.
  ///
  /// In en, this message translates to:
  /// **'Suggestion'**
  String get suggestion;

  /// No description provided for @messageCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Message content cannot be empty'**
  String get messageCannotBeEmpty;

  /// No description provided for @selectSubject.
  ///
  /// In en, this message translates to:
  /// **'Select message subject'**
  String get selectSubject;

  /// No description provided for @longPressToRemove.
  ///
  /// In en, this message translates to:
  /// **'Long press to remove'**
  String get longPressToRemove;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Profile Information'**
  String get personalInformation;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @accountInformation.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformation;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @messageSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Message has been sent successfully, our dedicated team will reach out shortly.'**
  String get messageSentSuccessfully;

  /// No description provided for @thankYouForReachingOut.
  ///
  /// In en, this message translates to:
  /// **'Thank you for reaching out, we try our best to resolve the issue within 48 hours.'**
  String get thankYouForReachingOut;

  /// No description provided for @screenShots.
  ///
  /// In en, this message translates to:
  /// **'Attach screen shots of any issue you have encountered'**
  String get screenShots;

  /// No description provided for @manageYourBusiness.
  ///
  /// In en, this message translates to:
  /// **'Manage Your Business'**
  String get manageYourBusiness;

  /// No description provided for @sigIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get sigIn;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get or;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an Account?'**
  String get dontHaveAccount;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or Continue with'**
  String get orContinueWith;

  /// No description provided for @resetIt.
  ///
  /// In en, this message translates to:
  /// **'Reset it'**
  String get resetIt;

  /// No description provided for @senderDetails.
  ///
  /// In en, this message translates to:
  /// **'Your Details'**
  String get senderDetails;

  /// No description provided for @forgotPassSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a reset link'**
  String get forgotPassSubtitle;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Reset email sent. Please check your inbox.'**
  String get resetEmailSent;

  /// No description provided for @invoiceSettings.
  ///
  /// In en, this message translates to:
  /// **'Invoice Settings'**
  String get invoiceSettings;

  /// No description provided for @invoiceSettingExplained.
  ///
  /// In en, this message translates to:
  /// **'Adjust the content of your invoice by changing enabling or disabling features'**
  String get invoiceSettingExplained;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @companyFinancialDetaiils.
  ///
  /// In en, this message translates to:
  /// **'My Financial Details'**
  String get companyFinancialDetaiils;

  /// No description provided for @clientCrNumber.
  ///
  /// In en, this message translates to:
  /// **'Client CR Number'**
  String get clientCrNumber;

  /// No description provided for @clientBankDetail.
  ///
  /// In en, this message translates to:
  /// **'Client Bank Details'**
  String get clientBankDetail;

  /// No description provided for @clientFinancialDetails.
  ///
  /// In en, this message translates to:
  /// **'Client Financial Number'**
  String get clientFinancialDetails;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @exitConfirmation.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes, are you sure you want to exit?'**
  String get exitConfirmation;

  /// No description provided for @generalSettings.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get generalSettings;

  /// No description provided for @generalSettingsExplained.
  ///
  /// In en, this message translates to:
  /// **'Change your app settings as per your requirement'**
  String get generalSettingsExplained;

  /// No description provided for @assignedLanguage.
  ///
  /// In en, this message translates to:
  /// **'Assigned Language'**
  String get assignedLanguage;

  /// No description provided for @assignedTheme.
  ///
  /// In en, this message translates to:
  /// **'Assigned Theme'**
  String get assignedTheme;

  /// No description provided for @inventoryInfo.
  ///
  /// In en, this message translates to:
  /// **'Inventory will allow you create up to 10 locations to store your products'**
  String get inventoryInfo;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @selectNewStore.
  ///
  /// In en, this message translates to:
  /// **'Select a New Store'**
  String get selectNewStore;

  /// No description provided for @inventoryLocation.
  ///
  /// In en, this message translates to:
  /// **'Inventory Location'**
  String get inventoryLocation;

  /// No description provided for @financialSettings.
  ///
  /// In en, this message translates to:
  /// **'Financial Settings'**
  String get financialSettings;

  /// No description provided for @financialSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Financial settings will allow you set standart variables related to your financial statement'**
  String get financialSettingsDesc;

  /// No description provided for @defaultSalesOrderTerms.
  ///
  /// In en, this message translates to:
  /// **'Set your default delivery, return, and refund terms for your sales orders'**
  String get defaultSalesOrderTerms;

  /// No description provided for @defaultPurchaseTerms.
  ///
  /// In en, this message translates to:
  /// **'Set your default delivery, return, and refund terms for your purchase orders'**
  String get defaultPurchaseTerms;

  /// No description provided for @reactivate.
  ///
  /// In en, this message translates to:
  /// **'Re-activate'**
  String get reactivate;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @restartApp.
  ///
  /// In en, this message translates to:
  /// **'Restart App'**
  String get restartApp;

  /// No description provided for @restartAppLangInfo.
  ///
  /// In en, this message translates to:
  /// **'In order to change the langauge you need to restart the app, Are you sure you want to proceed?'**
  String get restartAppLangInfo;

  /// No description provided for @restartAppThemeInfo.
  ///
  /// In en, this message translates to:
  /// **'In order to change the Theme you need to restart the app, Are you sure you want to proceed?'**
  String get restartAppThemeInfo;

  /// No description provided for @inventoryController.
  ///
  /// In en, this message translates to:
  /// **'Inventory Controller'**
  String get inventoryController;

  /// No description provided for @inventoryIntro.
  ///
  /// In en, this message translates to:
  /// **'The inventory option will allow you to create location in which you can store products. Be aware though when you activate the inventory your order will be directly linked and you won\'t be able to process them if you\'re out of stock.'**
  String get inventoryIntro;

  /// No description provided for @activateInventory.
  ///
  /// In en, this message translates to:
  /// **'Activate Inventory'**
  String get activateInventory;

  /// No description provided for @locationName.
  ///
  /// In en, this message translates to:
  /// **'Location Name'**
  String get locationName;

  /// No description provided for @inventoryLocationLimit.
  ///
  /// In en, this message translates to:
  /// **'You have reached the maximum inventory locations allowed'**
  String get inventoryLocationLimit;

  /// No description provided for @inventoryValue.
  ///
  /// In en, this message translates to:
  /// **'Inventory Value'**
  String get inventoryValue;

  /// No description provided for @inventoryInActive.
  ///
  /// In en, this message translates to:
  /// **'Inventory In-active'**
  String get inventoryInActive;

  /// No description provided for @doActivateInventory.
  ///
  /// In en, this message translates to:
  /// **'Do you want to activate the inventory option?'**
  String get doActivateInventory;

  /// No description provided for @locationNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Location name is empty, fix it to proceed'**
  String get locationNameEmpty;

  /// No description provided for @purchaseOrder.
  ///
  /// In en, this message translates to:
  /// **'Purchase Orders'**
  String get purchaseOrder;

  /// No description provided for @purchaseInfo.
  ///
  /// In en, this message translates to:
  /// **'The purchase feature allows you to create purchase orders for your supplier which will update your product cost automaically if you chose to'**
  String get purchaseInfo;

  /// No description provided for @purchaseSettings.
  ///
  /// In en, this message translates to:
  /// **'Purchase Settings'**
  String get purchaseSettings;

  /// No description provided for @activatePurchases.
  ///
  /// In en, this message translates to:
  /// **'Activate Purchases'**
  String get activatePurchases;

  /// No description provided for @updateProductCost.
  ///
  /// In en, this message translates to:
  /// **'Update Product Cost'**
  String get updateProductCost;

  /// No description provided for @purchases.
  ///
  /// In en, this message translates to:
  /// **'Purchases'**
  String get purchases;

  /// No description provided for @addPurchase.
  ///
  /// In en, this message translates to:
  /// **'Add Purchase'**
  String get addPurchase;

  /// No description provided for @editPurchase.
  ///
  /// In en, this message translates to:
  /// **'Edit Purchase'**
  String get editPurchase;

  /// No description provided for @noSupplierFound.
  ///
  /// In en, this message translates to:
  /// **'No supplier Found'**
  String get noSupplierFound;

  /// No description provided for @supplierName.
  ///
  /// In en, this message translates to:
  /// **'Supplier Name'**
  String get supplierName;

  /// No description provided for @supplierNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Supplier name empty'**
  String get supplierNameEmpty;

  /// No description provided for @supplierNameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Supplier name is invalid'**
  String get supplierNameInvalid;

  /// No description provided for @purchaseTerms.
  ///
  /// In en, this message translates to:
  /// **'Purchase Terms'**
  String get purchaseTerms;

  /// No description provided for @generatePO.
  ///
  /// In en, this message translates to:
  /// **'Generate PO'**
  String get generatePO;

  /// No description provided for @generatePoInfo.
  ///
  /// In en, this message translates to:
  /// **'Once purchase order is generated you can no longer edit or modify your order. Incase you need to cancel it you can delete the order and create a new one'**
  String get generatePoInfo;

  /// No description provided for @receivingPO.
  ///
  /// In en, this message translates to:
  /// **'Receiving Purchase Order'**
  String get receivingPO;

  /// No description provided for @receive.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get receive;

  /// No description provided for @receiveInfo.
  ///
  /// In en, this message translates to:
  /// **'This will allow you to confirm if the purchase order has been received, or modify that quantity that was received'**
  String get receiveInfo;

  /// No description provided for @materialAlreadyReceived.
  ///
  /// In en, this message translates to:
  /// **'Material from this purchase order has already been received'**
  String get materialAlreadyReceived;

  /// No description provided for @receiveMaterial.
  ///
  /// In en, this message translates to:
  /// **'Receive Material'**
  String get receiveMaterial;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @storeNotAssigned.
  ///
  /// In en, this message translates to:
  /// **'Store hasn\'t been assigned'**
  String get storeNotAssigned;

  /// No description provided for @storeNotExisting.
  ///
  /// In en, this message translates to:
  /// **'Selected store {store} doesn\'t exist for product {product}'**
  String storeNotExisting(Object product, Object store);

  /// No description provided for @purchaseOrderGenerationComplete.
  ///
  /// In en, this message translates to:
  /// **'Purchase order generation complete'**
  String get purchaseOrderGenerationComplete;

  /// No description provided for @generated.
  ///
  /// In en, this message translates to:
  /// **'Generated'**
  String get generated;

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// No description provided for @revertingBackNotPossible.
  ///
  /// In en, this message translates to:
  /// **'Please note that reverting back to the previous item cost is not possible at the moment, kindly do that manually'**
  String get revertingBackNotPossible;

  /// No description provided for @suppliers.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get suppliers;

  /// No description provided for @addSupplier.
  ///
  /// In en, this message translates to:
  /// **'Add Supplier'**
  String get addSupplier;

  /// No description provided for @editSupplier.
  ///
  /// In en, this message translates to:
  /// **'Edit Supplier'**
  String get editSupplier;

  /// No description provided for @supplierOrders.
  ///
  /// In en, this message translates to:
  /// **'Supplier Orders'**
  String get supplierOrders;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get product;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @businessType.
  ///
  /// In en, this message translates to:
  /// **'Business Type'**
  String get businessType;

  /// No description provided for @businessCategory.
  ///
  /// In en, this message translates to:
  /// **'Business Category'**
  String get businessCategory;

  /// No description provided for @businessTypeDes.
  ///
  /// In en, this message translates to:
  /// **'Select the business type that best describes your business, and keep in the mind that it will affect how product cost will calculated'**
  String get businessTypeDes;

  /// No description provided for @businessCategoryDes.
  ///
  /// In en, this message translates to:
  /// **'Select the business category if available or others if not available, we will look into it and will try to add it in the future'**
  String get businessCategoryDes;

  /// No description provided for @businessTypeNotDefined.
  ///
  /// In en, this message translates to:
  /// **'Business type seems to be not defined, kindly check your account and assign a business type'**
  String get businessTypeNotDefined;

  /// No description provided for @missingCategory.
  ///
  /// In en, this message translates to:
  /// **'You need to select a category'**
  String get missingCategory;

  /// No description provided for @missingType.
  ///
  /// In en, this message translates to:
  /// **'You need to select a type'**
  String get missingType;

  /// No description provided for @fillManualCategory.
  ///
  /// In en, this message translates to:
  /// **'Fill in your business category'**
  String get fillManualCategory;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @companyInfo.
  ///
  /// In en, this message translates to:
  /// **'Company Information'**
  String get companyInfo;

  /// No description provided for @companyName.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get companyName;

  /// No description provided for @companyLogo.
  ///
  /// In en, this message translates to:
  /// **'Company Logo'**
  String get companyLogo;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @companyLogoMissing.
  ///
  /// In en, this message translates to:
  /// **'Company logo is missing'**
  String get companyLogoMissing;

  /// No description provided for @dataSaveSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Data saved successfully'**
  String get dataSaveSuccessfully;

  /// No description provided for @failedToSaveData.
  ///
  /// In en, this message translates to:
  /// **'Failed to save data'**
  String get failedToSaveData;

  /// No description provided for @imageRemovedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Image removed successfully'**
  String get imageRemovedSuccessfully;

  /// No description provided for @failedToRemoveImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove image'**
  String get failedToRemoveImage;

  /// No description provided for @currencyDes.
  ///
  /// In en, this message translates to:
  /// **'Select the currency in which you would like to conduct your business with, this can be changed later'**
  String get currencyDes;

  /// No description provided for @locationDes.
  ///
  /// In en, this message translates to:
  /// **'Select the location from which you business will be conducted, this can be changed later'**
  String get locationDes;

  /// No description provided for @noApiKeyDetected.
  ///
  /// In en, this message translates to:
  /// **'No api key has been detected, please contact support'**
  String get noApiKeyDetected;

  /// No description provided for @viewMore.
  ///
  /// In en, this message translates to:
  /// **'View More'**
  String get viewMore;

  /// No description provided for @locationChoice.
  ///
  /// In en, this message translates to:
  /// **'Would you like to grant the app your location?'**
  String get locationChoice;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @dataRefereshedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Data Refreshed Successfully'**
  String get dataRefereshedSuccessfully;

  /// No description provided for @dataFailedToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Data Failed to Refresh'**
  String get dataFailedToRefresh;

  /// No description provided for @businessTypeSubDes.
  ///
  /// In en, this message translates to:
  /// **'This helps us personalise your experience.'**
  String get businessTypeSubDes;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @stepOneOfTwo.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 2'**
  String get stepOneOfTwo;

  /// No description provided for @currencySubDes.
  ///
  /// In en, this message translates to:
  /// **'Used across all invoices, orders and reports.'**
  String get currencySubDes;

  /// No description provided for @stepTwoOfTwo.
  ///
  /// In en, this message translates to:
  /// **'Step 2 of 2'**
  String get stepTwoOfTwo;

  /// No description provided for @finishSetup.
  ///
  /// In en, this message translates to:
  /// **'Finish setup'**
  String get finishSetup;

  /// No description provided for @addressNotRegistered.
  ///
  /// In en, this message translates to:
  /// **'Address has not been registered'**
  String get addressNotRegistered;

  /// No description provided for @noLocationSelected.
  ///
  /// In en, this message translates to:
  /// **'No Location Selected'**
  String get noLocationSelected;

  /// No description provided for @selectLocation.
  ///
  /// In en, this message translates to:
  /// **'Select Location'**
  String get selectLocation;

  /// No description provided for @locServiceDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location service disabled'**
  String get locServiceDisabled;

  /// No description provided for @locServiceDenied.
  ///
  /// In en, this message translates to:
  /// **'Location service denied'**
  String get locServiceDenied;

  /// No description provided for @locServiceDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are permanently denied. if you wish to set your location you need to head to your device settings and enable them from there.'**
  String get locServiceDeniedForever;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission has been denied'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission has been denied permanently'**
  String get locationPermissionPermanentlyDenied;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services have been disabled'**
  String get locationServicesDisabled;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error, try again'**
  String get networkError;

  /// No description provided for @configurationError.
  ///
  /// In en, this message translates to:
  /// **'Configuration error, try again'**
  String get configurationError;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong, please contact support'**
  String get somethingWentWrong;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addProduct;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get editProduct;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get productName;

  /// No description provided for @itemCode.
  ///
  /// In en, this message translates to:
  /// **'Item Code'**
  String get itemCode;

  /// No description provided for @productDescription.
  ///
  /// In en, this message translates to:
  /// **'Item Description'**
  String get productDescription;

  /// No description provided for @productPacking.
  ///
  /// In en, this message translates to:
  /// **'Item Packing (example kg, pcs...)'**
  String get productPacking;

  /// No description provided for @productCost.
  ///
  /// In en, this message translates to:
  /// **'Item Cost'**
  String get productCost;

  /// No description provided for @productCostService.
  ///
  /// In en, this message translates to:
  /// **'Item Cost (Optional)'**
  String get productCostService;

  /// No description provided for @productPrice.
  ///
  /// In en, this message translates to:
  /// **'Item Selling Price'**
  String get productPrice;

  /// No description provided for @images.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// No description provided for @files.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get files;

  /// No description provided for @noImages.
  ///
  /// In en, this message translates to:
  /// **'No Images Found'**
  String get noImages;

  /// No description provided for @productNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Item name cannot be empty'**
  String get productNameEmpty;

  /// No description provided for @productCostEmpty.
  ///
  /// In en, this message translates to:
  /// **'Item cost is needed, enter 0 if you don\'t wish to add cost'**
  String get productCostEmpty;

  /// No description provided for @productPriceEmpty.
  ///
  /// In en, this message translates to:
  /// **'Item should have a price, enter 0 for free Items'**
  String get productPriceEmpty;

  /// No description provided for @productImageEmpty.
  ///
  /// In en, this message translates to:
  /// **'Any Item should have at least 1 images'**
  String get productImageEmpty;

  /// No description provided for @noProductsAdded.
  ///
  /// In en, this message translates to:
  /// **'No Items Added'**
  String get noProductsAdded;

  /// No description provided for @productCostError.
  ///
  /// In en, this message translates to:
  /// **'Check if you business Category is selected'**
  String get productCostError;

  /// No description provided for @addCost.
  ///
  /// In en, this message translates to:
  /// **'Add Cost'**
  String get addCost;

  /// No description provided for @editCost.
  ///
  /// In en, this message translates to:
  /// **'Edit Cost'**
  String get editCost;

  /// No description provided for @saveProductFirst.
  ///
  /// In en, this message translates to:
  /// **'Save Item first, then you cant add your cost'**
  String get saveProductFirst;

  /// No description provided for @costValue.
  ///
  /// In en, this message translates to:
  /// **'Cost Value'**
  String get costValue;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @noProductFound.
  ///
  /// In en, this message translates to:
  /// **'No Items Found'**
  String get noProductFound;

  /// No description provided for @productCategory.
  ///
  /// In en, this message translates to:
  /// **'Item Category (Optional)'**
  String get productCategory;

  /// No description provided for @productCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Type in any category, shall be created after you add a product'**
  String get productCategoryHint;

  /// No description provided for @id.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get id;

  /// No description provided for @filterOptions.
  ///
  /// In en, this message translates to:
  /// **'Filter Options'**
  String get filterOptions;

  /// No description provided for @filterProducts.
  ///
  /// In en, this message translates to:
  /// **'Filter Items'**
  String get filterProducts;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search Items'**
  String get searchProducts;

  /// No description provided for @priceRange.
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get priceRange;

  /// No description provided for @minPrice.
  ///
  /// In en, this message translates to:
  /// **'Min Price'**
  String get minPrice;

  /// No description provided for @maxPrice.
  ///
  /// In en, this message translates to:
  /// **'Max Price'**
  String get maxPrice;

  /// No description provided for @applyFilter.
  ///
  /// In en, this message translates to:
  /// **'Apply Filter'**
  String get applyFilter;

  /// No description provided for @productCodeExists.
  ///
  /// In en, this message translates to:
  /// **'Item Code already Exists'**
  String get productCodeExists;

  /// No description provided for @itemCodeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Item code cannot be empty'**
  String get itemCodeEmpty;

  /// No description provided for @noCategoriesFound.
  ///
  /// In en, this message translates to:
  /// **'No categories found'**
  String get noCategoriesFound;

  /// No description provided for @productRecords.
  ///
  /// In en, this message translates to:
  /// **'Item Records'**
  String get productRecords;

  /// No description provided for @productsLimit.
  ///
  /// In en, this message translates to:
  /// **'It seems you\'ve reached the product limit on our free version, subscribe to our paid plan to enjoy an unlimited number of products'**
  String get productsLimit;

  /// No description provided for @orderLimit.
  ///
  /// In en, this message translates to:
  /// **'Its seems you\'ve reached the order limit on our free version, subscribe to our paid plan to enjoy and unlimited number of orders'**
  String get orderLimit;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @subscribeToAccessInventory.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to Access Inventory'**
  String get subscribeToAccessInventory;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic info'**
  String get basicInfo;

  /// No description provided for @auto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get auto;

  /// No description provided for @packaging.
  ///
  /// In en, this message translates to:
  /// **'Packaging'**
  String get packaging;

  /// No description provided for @pricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get pricing;

  /// No description provided for @profitMargin.
  ///
  /// In en, this message translates to:
  /// **'Profit margin'**
  String get profitMargin;

  /// No description provided for @noItemRecordFound.
  ///
  /// In en, this message translates to:
  /// **'No item record found'**
  String get noItemRecordFound;

  /// No description provided for @clearFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear Filter'**
  String get clearFilter;

  /// No description provided for @receipes.
  ///
  /// In en, this message translates to:
  /// **'Receipes'**
  String get receipes;

  /// No description provided for @addReceipe.
  ///
  /// In en, this message translates to:
  /// **'Add Receipe'**
  String get addReceipe;

  /// No description provided for @editRecipe.
  ///
  /// In en, this message translates to:
  /// **'Edit Receipe'**
  String get editRecipe;

  /// No description provided for @noReceipesFound.
  ///
  /// In en, this message translates to:
  /// **'No Receipes Found'**
  String get noReceipesFound;

  /// No description provided for @receipeName.
  ///
  /// In en, this message translates to:
  /// **'Receipe Name'**
  String get receipeName;

  /// No description provided for @receipeDescription.
  ///
  /// In en, this message translates to:
  /// **'Receipe Description'**
  String get receipeDescription;

  /// No description provided for @receipePacking.
  ///
  /// In en, this message translates to:
  /// **'Receipe Packing'**
  String get receipePacking;

  /// No description provided for @receipeIngredients.
  ///
  /// In en, this message translates to:
  /// **'Receipe Ingredients'**
  String get receipeIngredients;

  /// No description provided for @cost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get cost;

  /// No description provided for @pack.
  ///
  /// In en, this message translates to:
  /// **'Pack'**
  String get pack;

  /// No description provided for @packService.
  ///
  /// In en, this message translates to:
  /// **'Package or Sessions'**
  String get packService;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Qyt'**
  String get quantity;

  /// No description provided for @suggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get suggestions;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @selectedIngredientFirst.
  ///
  /// In en, this message translates to:
  /// **'You need to select and ingredient first'**
  String get selectedIngredientFirst;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @totalCost.
  ///
  /// In en, this message translates to:
  /// **'Total Cost'**
  String get totalCost;

  /// No description provided for @packingUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get packingUnit;

  /// No description provided for @receipeNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Receipe name is required'**
  String get receipeNameRequired;

  /// No description provided for @receipePackingRequired.
  ///
  /// In en, this message translates to:
  /// **'Receipe packing Value is required'**
  String get receipePackingRequired;

  /// No description provided for @receipePackingUnitRequired.
  ///
  /// In en, this message translates to:
  /// **'Receipe packing Unit is required'**
  String get receipePackingUnitRequired;

  /// No description provided for @ingredientsMissing.
  ///
  /// In en, this message translates to:
  /// **'Each receipe should have at least an ingredient'**
  String get ingredientsMissing;

  /// No description provided for @tapReceipeToAdd.
  ///
  /// In en, this message translates to:
  /// **'Tap on the receipt to add to product'**
  String get tapReceipeToAdd;

  /// No description provided for @recipeDetails.
  ///
  /// In en, this message translates to:
  /// **'Recipe Details'**
  String get recipeDetails;

  /// No description provided for @outputPacking.
  ///
  /// In en, this message translates to:
  /// **'Output Packing'**
  String get outputPacking;

  /// No description provided for @rawMaterial.
  ///
  /// In en, this message translates to:
  /// **'Raw Material'**
  String get rawMaterial;

  /// No description provided for @noRawMaterialsFound.
  ///
  /// In en, this message translates to:
  /// **'No Raw material was found'**
  String get noRawMaterialsFound;

  /// No description provided for @rawMaterialAdd.
  ///
  /// In en, this message translates to:
  /// **'Add New'**
  String get rawMaterialAdd;

  /// No description provided for @rawMaterialEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Current'**
  String get rawMaterialEdit;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @quantityRequired.
  ///
  /// In en, this message translates to:
  /// **'Quantity is required'**
  String get quantityRequired;

  /// No description provided for @unitRequired.
  ///
  /// In en, this message translates to:
  /// **'Unit is required'**
  String get unitRequired;

  /// No description provided for @costRequired.
  ///
  /// In en, this message translates to:
  /// **'Cost is required'**
  String get costRequired;

  /// No description provided for @quantityAndUnit.
  ///
  /// In en, this message translates to:
  /// **'Quantity and Unit'**
  String get quantityAndUnit;

  /// No description provided for @conversionRates.
  ///
  /// In en, this message translates to:
  /// **'Conversion Rates'**
  String get conversionRates;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @addImage.
  ///
  /// In en, this message translates to:
  /// **'Add Image'**
  String get addImage;

  /// No description provided for @editImage.
  ///
  /// In en, this message translates to:
  /// **'Edit Image'**
  String get editImage;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @imageSelectionError.
  ///
  /// In en, this message translates to:
  /// **'Error trying to select image, kindly try again'**
  String get imageSelectionError;

  /// No description provided for @imageNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Failed to select image'**
  String get imageNotSelected;

  /// No description provided for @cameraPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission has been denied'**
  String get cameraPermissionDenied;

  /// No description provided for @mediaPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Media permission has been denied'**
  String get mediaPermissionDenied;

  /// No description provided for @failedToUploadImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload image'**
  String get failedToUploadImage;

  /// No description provided for @failedToUploadVideo.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload Video'**
  String get failedToUploadVideo;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete?'**
  String get deleteConfirmation;

  /// No description provided for @deleteConfirmationWithCount.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete these {number} items'**
  String deleteConfirmationWithCount(Object number);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @cancelConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this order?'**
  String get cancelConfirmation;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @restoreConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to restore this order'**
  String get restoreConfirmation;

  /// No description provided for @imagesDeleted.
  ///
  /// In en, this message translates to:
  /// **'You have deleted {number} images'**
  String imagesDeleted(Object number);

  /// No description provided for @failedToDeleteImages.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete the selected image'**
  String get failedToDeleteImages;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @changingTypeNotPossible.
  ///
  /// In en, this message translates to:
  /// **'You can no longer change business type as you have already added products'**
  String get changingTypeNotPossible;

  /// No description provided for @doubleToAdd.
  ///
  /// In en, this message translates to:
  /// **'Double click on the image to link to a product'**
  String get doubleToAdd;

  /// No description provided for @client.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get client;

  /// No description provided for @clients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get clients;

  /// No description provided for @addClient.
  ///
  /// In en, this message translates to:
  /// **'Add Client'**
  String get addClient;

  /// No description provided for @editClient.
  ///
  /// In en, this message translates to:
  /// **'Edit Client'**
  String get editClient;

  /// No description provided for @noClientsFound.
  ///
  /// In en, this message translates to:
  /// **'No Clients Found'**
  String get noClientsFound;

  /// No description provided for @individual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get individual;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @clientNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Client name cannot be empty'**
  String get clientNameEmpty;

  /// No description provided for @clientNameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Client name is invalid'**
  String get clientNameInvalid;

  /// No description provided for @companyNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Company name cannot be empty, please go to settings -> account and set your company name'**
  String get companyNameEmpty;

  /// No description provided for @phoneNumberEmpty.
  ///
  /// In en, this message translates to:
  /// **'Phone number cannot be empty, please go to settings -> account and set your company logo'**
  String get phoneNumberEmpty;

  /// No description provided for @phoneCodeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Phone code needs to be selected'**
  String get phoneCodeEmpty;

  /// No description provided for @clientName.
  ///
  /// In en, this message translates to:
  /// **'Client Name'**
  String get clientName;

  /// No description provided for @clientOrders.
  ///
  /// In en, this message translates to:
  /// **'Client Orders'**
  String get clientOrders;

  /// No description provided for @clientCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Client company name cannot be empty'**
  String get clientCompanyName;

  /// No description provided for @financialNumber.
  ///
  /// In en, this message translates to:
  /// **'Financial Number'**
  String get financialNumber;

  /// No description provided for @crNumber.
  ///
  /// In en, this message translates to:
  /// **'CR Number'**
  String get crNumber;

  /// No description provided for @ibanNumber.
  ///
  /// In en, this message translates to:
  /// **'IBAN Number'**
  String get ibanNumber;

  /// No description provided for @bankName.
  ///
  /// In en, this message translates to:
  /// **'Bank Name'**
  String get bankName;

  /// No description provided for @bankBranch.
  ///
  /// In en, this message translates to:
  /// **'Bank Branch'**
  String get bankBranch;

  /// No description provided for @otherPayment.
  ///
  /// In en, this message translates to:
  /// **'Other Payment Method'**
  String get otherPayment;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @due.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get due;

  /// No description provided for @overDue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overDue;

  /// No description provided for @clientType.
  ///
  /// In en, this message translates to:
  /// **'Client Type'**
  String get clientType;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactInfo;

  /// No description provided for @officialData.
  ///
  /// In en, this message translates to:
  /// **'Official data'**
  String get officialData;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @capitalAndExpenses.
  ///
  /// In en, this message translates to:
  /// **'Capital & Expenses'**
  String get capitalAndExpenses;

  /// No description provided for @financialReports.
  ///
  /// In en, this message translates to:
  /// **'Financial Reports'**
  String get financialReports;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @fixedCosts.
  ///
  /// In en, this message translates to:
  /// **'Fixed Costs'**
  String get fixedCosts;

  /// No description provided for @assets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get assets;

  /// No description provided for @costs.
  ///
  /// In en, this message translates to:
  /// **'Costs'**
  String get costs;

  /// No description provided for @noOrdersFound.
  ///
  /// In en, this message translates to:
  /// **'No Orders Found'**
  String get noOrdersFound;

  /// No description provided for @addOrder.
  ///
  /// In en, this message translates to:
  /// **'Add Order'**
  String get addOrder;

  /// No description provided for @editOrder.
  ///
  /// In en, this message translates to:
  /// **'Edit Order'**
  String get editOrder;

  /// No description provided for @itemQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get itemQuantity;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @discountedPrice.
  ///
  /// In en, this message translates to:
  /// **'Dis. Price'**
  String get discountedPrice;

  /// No description provided for @quantityCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Quantity cannot be empty'**
  String get quantityCannotBeEmpty;

  /// No description provided for @priceCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Price cannot be empty'**
  String get priceCannotBeEmpty;

  /// No description provided for @cannotPerformDiscountOnAddedPrice.
  ///
  /// In en, this message translates to:
  /// **'You cannot perform a discount on price increase'**
  String get cannotPerformDiscountOnAddedPrice;

  /// No description provided for @totalValue.
  ///
  /// In en, this message translates to:
  /// **'Total Value'**
  String get totalValue;

  /// No description provided for @productListEmpty.
  ///
  /// In en, this message translates to:
  /// **'Product list cannot be empty'**
  String get productListEmpty;

  /// No description provided for @orderTerms.
  ///
  /// In en, this message translates to:
  /// **'Order Terms'**
  String get orderTerms;

  /// No description provided for @deliveryTerms.
  ///
  /// In en, this message translates to:
  /// **'Delivery Terms'**
  String get deliveryTerms;

  /// No description provided for @deliveryTime.
  ///
  /// In en, this message translates to:
  /// **'Delivery Time'**
  String get deliveryTime;

  /// No description provided for @immediate.
  ///
  /// In en, this message translates to:
  /// **'Immediate'**
  String get immediate;

  /// No description provided for @scheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get scheduled;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// No description provided for @selectTimeFirst.
  ///
  /// In en, this message translates to:
  /// **'Select Time First'**
  String get selectTimeFirst;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @selectDateFirst.
  ///
  /// In en, this message translates to:
  /// **'Select Date First'**
  String get selectDateFirst;

  /// No description provided for @immediateDelivery.
  ///
  /// In en, this message translates to:
  /// **'Order will be set to be delivered immediately'**
  String get immediateDelivery;

  /// No description provided for @noOrderFound.
  ///
  /// In en, this message translates to:
  /// **'No order found'**
  String get noOrderFound;

  /// No description provided for @invoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get invoice;

  /// No description provided for @number.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get number;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @paymentTerms.
  ///
  /// In en, this message translates to:
  /// **'Payment Terms'**
  String get paymentTerms;

  /// No description provided for @termsandConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsandConditions;

  /// No description provided for @termsIntroWeb.
  ///
  /// In en, this message translates to:
  /// **'Please read and accept our Terms of Service before continuing.'**
  String get termsIntroWeb;

  /// No description provided for @termsandConditionDesc.
  ///
  /// In en, this message translates to:
  /// **'Every user needs to agree to {provider} terms before proceeding'**
  String termsandConditionDesc(Object provider);

  /// No description provided for @apple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get apple;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @viewFullTerms.
  ///
  /// In en, this message translates to:
  /// **'You can view the full terms by clicking on the below link'**
  String get viewFullTerms;

  /// No description provided for @agreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'Agree to Terms'**
  String get agreeToTerms;

  /// No description provided for @termsSummaryDetails.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions renew automatically unless cancelled at least 24 hours before renewal, and all purchases are subject to {provider}\'s policies.'**
  String termsSummaryDetails(Object provider);

  /// No description provided for @iHaveReadAndAgree.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to the Terms and Conditions'**
  String get iHaveReadAndAgree;

  /// No description provided for @readFullTerms.
  ///
  /// In en, this message translates to:
  /// **'Read Full Terms'**
  String get readFullTerms;

  /// No description provided for @needToAgreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'You need to check and confirm the apps terms and conditions'**
  String get needToAgreeToTerms;

  /// No description provided for @ref.
  ///
  /// In en, this message translates to:
  /// **'Ref'**
  String get ref;

  /// No description provided for @invoiceNumber.
  ///
  /// In en, this message translates to:
  /// **'Invoice Number'**
  String get invoiceNumber;

  /// No description provided for @invoiceGenCompleted.
  ///
  /// In en, this message translates to:
  /// **'Invoice generation completed'**
  String get invoiceGenCompleted;

  /// No description provided for @invoiceGenFailed.
  ///
  /// In en, this message translates to:
  /// **'Invoice generation failed, please try again'**
  String get invoiceGenFailed;

  /// No description provided for @returnTerms.
  ///
  /// In en, this message translates to:
  /// **'Return/Refund'**
  String get returnTerms;

  /// No description provided for @returnTermsService.
  ///
  /// In en, this message translates to:
  /// **'Refund or Cancel'**
  String get returnTermsService;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @unsavedData.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved data, save before closing'**
  String get unsavedData;

  /// No description provided for @returns.
  ///
  /// In en, this message translates to:
  /// **'Returns'**
  String get returns;

  /// No description provided for @clientDetails.
  ///
  /// In en, this message translates to:
  /// **'Client Details'**
  String get clientDetails;

  /// No description provided for @billTo.
  ///
  /// In en, this message translates to:
  /// **'Bill To'**
  String get billTo;

  /// No description provided for @scheduledOrder.
  ///
  /// In en, this message translates to:
  /// **'This Order is Scheduled On'**
  String get scheduledOrder;

  /// No description provided for @scheduledDate.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Date'**
  String get scheduledDate;

  /// No description provided for @scheduledTime.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Time'**
  String get scheduledTime;

  /// No description provided for @orderId.
  ///
  /// In en, this message translates to:
  /// **'Order Id'**
  String get orderId;

  /// No description provided for @invoiced.
  ///
  /// In en, this message translates to:
  /// **'Invoiced'**
  String get invoiced;

  /// No description provided for @generateInvoice.
  ///
  /// In en, this message translates to:
  /// **'Generate Invoice'**
  String get generateInvoice;

  /// No description provided for @generateInvoiceInfo.
  ///
  /// In en, this message translates to:
  /// **'Once invoice is generated you can no longer edit or modify your order. Incase you need to cancel it you can delete the order and create a new one'**
  String get generateInvoiceInfo;

  /// No description provided for @generate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// No description provided for @regenerate.
  ///
  /// In en, this message translates to:
  /// **'Re-Generate'**
  String get regenerate;

  /// No description provided for @orderPlacedAt.
  ///
  /// In en, this message translates to:
  /// **'Placed At'**
  String get orderPlacedAt;

  /// No description provided for @noDeliveryTerms.
  ///
  /// In en, this message translates to:
  /// **'No delivery terms has been set'**
  String get noDeliveryTerms;

  /// No description provided for @noReturnRefundTermsSet.
  ///
  /// In en, this message translates to:
  /// **'No return/refund terms has been set'**
  String get noReturnRefundTermsSet;

  /// No description provided for @orderMargins.
  ///
  /// In en, this message translates to:
  /// **'Order Margins'**
  String get orderMargins;

  /// No description provided for @grossProfit.
  ///
  /// In en, this message translates to:
  /// **'Gross Profit'**
  String get grossProfit;

  /// No description provided for @margin.
  ///
  /// In en, this message translates to:
  /// **'Margin'**
  String get margin;

  /// No description provided for @draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draft;

  /// No description provided for @noStockAvailableInLocation.
  ///
  /// In en, this message translates to:
  /// **'No stock available in the selected location for this product'**
  String get noStockAvailableInLocation;

  /// No description provided for @insufficientInventory.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have enough stock in the selected location'**
  String get insufficientInventory;

  /// No description provided for @insufficientStockFor.
  ///
  /// In en, this message translates to:
  /// **'Insufficient stock for {item} in {location}'**
  String insufficientStockFor(Object item, Object location);

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @setReminder.
  ///
  /// In en, this message translates to:
  /// **'Set Reminder'**
  String get setReminder;

  /// No description provided for @reminderMe.
  ///
  /// In en, this message translates to:
  /// **'Remind Me'**
  String get reminderMe;

  /// No description provided for @reminderNote.
  ///
  /// In en, this message translates to:
  /// **'Reminders need to be set at least 10 minutes in the future'**
  String get reminderNote;

  /// No description provided for @notificationDisabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications are disabled, meaning you won\'t receive reminders for your orders, enable them'**
  String get notificationDisabled;

  /// No description provided for @deliveryCharges.
  ///
  /// In en, this message translates to:
  /// **'Delivery Charges'**
  String get deliveryCharges;

  /// No description provided for @deliveryFees.
  ///
  /// In en, this message translates to:
  /// **'Delivery Fees'**
  String get deliveryFees;

  /// No description provided for @noDeliveryFees.
  ///
  /// In en, this message translates to:
  /// **'No delivery fees set'**
  String get noDeliveryFees;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @subscribeToAccess.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to Access Statistics'**
  String get subscribeToAccess;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @cancelledOrders.
  ///
  /// In en, this message translates to:
  /// **'Cancelled Orders'**
  String get cancelledOrders;

  /// No description provided for @cancelledOrder.
  ///
  /// In en, this message translates to:
  /// **'Do you want to restore this cancelled order, press yes to restore and no to keep it cancelled'**
  String get cancelledOrder;

  /// No description provided for @orderRemainsCancelled.
  ///
  /// In en, this message translates to:
  /// **'Order remains cancelled'**
  String get orderRemainsCancelled;

  /// No description provided for @failedToCancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel the selected order, pleast contact support'**
  String get failedToCancelOrder;

  /// No description provided for @failedToRestoreOrder.
  ///
  /// In en, this message translates to:
  /// **'Failed to restore the selected order, please contact support'**
  String get failedToRestoreOrder;

  /// No description provided for @orderCancelled.
  ///
  /// In en, this message translates to:
  /// **'Order is Cancelled'**
  String get orderCancelled;

  /// No description provided for @receipeIsMissing.
  ///
  /// In en, this message translates to:
  /// **'Receipe is missing, check if it\'s deleted or removed, update the product again'**
  String get receipeIsMissing;

  /// No description provided for @rawItemMissing.
  ///
  /// In en, this message translates to:
  /// **'Raw item is missing, check if it\'s deleted or removed, update the receipe again'**
  String get rawItemMissing;

  /// No description provided for @taxValue.
  ///
  /// In en, this message translates to:
  /// **'Tax Value'**
  String get taxValue;

  /// No description provided for @failedToDownloadInvoice.
  ///
  /// In en, this message translates to:
  /// **'Failed to download the invoice, please check your connection'**
  String get failedToDownloadInvoice;

  /// No description provided for @collection.
  ///
  /// In en, this message translates to:
  /// **'Payment Collection'**
  String get collection;

  /// No description provided for @collectionReminder.
  ///
  /// In en, this message translates to:
  /// **'Set a reminder to trigger when collection is due in {days} days'**
  String collectionReminder(Object days);

  /// No description provided for @shallWeRemindYou.
  ///
  /// In en, this message translates to:
  /// **'Shall we reminder you?'**
  String get shallWeRemindYou;

  /// No description provided for @quotes.
  ///
  /// In en, this message translates to:
  /// **'Quotations'**
  String get quotes;

  /// No description provided for @quoteTerms.
  ///
  /// In en, this message translates to:
  /// **'Quote Terms'**
  String get quoteTerms;

  /// No description provided for @addQuote.
  ///
  /// In en, this message translates to:
  /// **'Add Quote'**
  String get addQuote;

  /// No description provided for @editQuote.
  ///
  /// In en, this message translates to:
  /// **'Edit Quote'**
  String get editQuote;

  /// No description provided for @noQuotesFound.
  ///
  /// In en, this message translates to:
  /// **'No Quotes Found'**
  String get noQuotesFound;

  /// No description provided for @ordered.
  ///
  /// In en, this message translates to:
  /// **'Ordered'**
  String get ordered;

  /// No description provided for @quoteMargins.
  ///
  /// In en, this message translates to:
  /// **'Quote Margins'**
  String get quoteMargins;

  /// No description provided for @quotation.
  ///
  /// In en, this message translates to:
  /// **'Quotation'**
  String get quotation;

  /// No description provided for @quoted.
  ///
  /// In en, this message translates to:
  /// **'Quoted'**
  String get quoted;

  /// No description provided for @makeOrder.
  ///
  /// In en, this message translates to:
  /// **'Convert to Order'**
  String get makeOrder;

  /// No description provided for @generateQuote.
  ///
  /// In en, this message translates to:
  /// **'Generate Quotation'**
  String get generateQuote;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @dublicate.
  ///
  /// In en, this message translates to:
  /// **'Dublicate'**
  String get dublicate;

  /// No description provided for @noAssetsFound.
  ///
  /// In en, this message translates to:
  /// **'No Assets found'**
  String get noAssetsFound;

  /// No description provided for @addAsset.
  ///
  /// In en, this message translates to:
  /// **'Add Asset'**
  String get addAsset;

  /// No description provided for @editAsset.
  ///
  /// In en, this message translates to:
  /// **'Edit Asset'**
  String get editAsset;

  /// No description provided for @value.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get value;

  /// No description provided for @imagesOptional.
  ///
  /// In en, this message translates to:
  /// **'Images (Optional)'**
  String get imagesOptional;

  /// No description provided for @valueRequired.
  ///
  /// In en, this message translates to:
  /// **'Value is required'**
  String get valueRequired;

  /// No description provided for @dataNotLoading.
  ///
  /// In en, this message translates to:
  /// **'Data didn\'t load properly, check connection and try again'**
  String get dataNotLoading;

  /// No description provided for @noExpenseFound.
  ///
  /// In en, this message translates to:
  /// **'No Expenses Found'**
  String get noExpenseFound;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// No description provided for @editExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get editExpense;

  /// No description provided for @imageCorrupted.
  ///
  /// In en, this message translates to:
  /// **'Image corrupted, try uploading another version'**
  String get imageCorrupted;

  /// No description provided for @imageLimit4.
  ///
  /// In en, this message translates to:
  /// **'You can only select up to 4 images. You already have {count} image(s).'**
  String imageLimit4(Object count);

  /// No description provided for @errorRemovingImage.
  ///
  /// In en, this message translates to:
  /// **'Error removing image'**
  String get errorRemovingImage;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @selectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select Date Range'**
  String get selectDateRange;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @end.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get end;

  /// No description provided for @newsUpdate.
  ///
  /// In en, this message translates to:
  /// **'News Up§'**
  String get newsUpdate;

  /// No description provided for @featuredProducts.
  ///
  /// In en, this message translates to:
  /// **'Featured Products'**
  String get featuredProducts;

  /// No description provided for @latestNews.
  ///
  /// In en, this message translates to:
  /// **'Latest News'**
  String get latestNews;

  /// No description provided for @salesReport.
  ///
  /// In en, this message translates to:
  /// **'Sales Report'**
  String get salesReport;

  /// No description provided for @selectDateInfo.
  ///
  /// In en, this message translates to:
  /// **'Select the date range in which you would like to obtain the sales record for'**
  String get selectDateInfo;

  /// No description provided for @reportGenSuccess.
  ///
  /// In en, this message translates to:
  /// **'Report Generated Successfully'**
  String get reportGenSuccess;

  /// No description provided for @reportGenFailed.
  ///
  /// In en, this message translates to:
  /// **'Report Generation Failed'**
  String get reportGenFailed;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @productCount.
  ///
  /// In en, this message translates to:
  /// **'Product Count'**
  String get productCount;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get to;

  /// No description provided for @totalSalesValue.
  ///
  /// In en, this message translates to:
  /// **'Total Sales Value'**
  String get totalSalesValue;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @totalOrders.
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get totalOrders;

  /// No description provided for @financialDetails.
  ///
  /// In en, this message translates to:
  /// **'Financial Details'**
  String get financialDetails;

  /// No description provided for @pandLReport.
  ///
  /// In en, this message translates to:
  /// **'Profit and Loss Report'**
  String get pandLReport;

  /// No description provided for @plVariables.
  ///
  /// In en, this message translates to:
  /// **'P & L Variables'**
  String get plVariables;

  /// No description provided for @selectDatePL.
  ///
  /// In en, this message translates to:
  /// **'Select the date range in which you need to show the profit and loss report'**
  String get selectDatePL;

  /// No description provided for @selectOptions.
  ///
  /// In en, this message translates to:
  /// **'Select Options'**
  String get selectOptions;

  /// No description provided for @optionsSummary.
  ///
  /// In en, this message translates to:
  /// **'Options Summary'**
  String get optionsSummary;

  /// No description provided for @noOptionsSelected.
  ///
  /// In en, this message translates to:
  /// **'No options selected'**
  String get noOptionsSelected;

  /// No description provided for @noPreviousRecordSaved.
  ///
  /// In en, this message translates to:
  /// **'No previous records were saved'**
  String get noPreviousRecordSaved;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @dateRangeisCrucial.
  ///
  /// In en, this message translates to:
  /// **'Date range is required, kindly select range before you can proceed'**
  String get dateRangeisCrucial;

  /// No description provided for @saveRecord.
  ///
  /// In en, this message translates to:
  /// **'Save Record'**
  String get saveRecord;

  /// No description provided for @plSummary.
  ///
  /// In en, this message translates to:
  /// **'P & L Summary'**
  String get plSummary;

  /// No description provided for @profitLossStatement.
  ///
  /// In en, this message translates to:
  /// **'Profit & Loss Statement'**
  String get profitLossStatement;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenue;

  /// No description provided for @operatingExpenses.
  ///
  /// In en, this message translates to:
  /// **'Operating Expenses'**
  String get operatingExpenses;

  /// No description provided for @operatingIncome.
  ///
  /// In en, this message translates to:
  /// **'Operating Income'**
  String get operatingIncome;

  /// No description provided for @nonOperatingIncomeExpense.
  ///
  /// In en, this message translates to:
  /// **'Non-Operating Income/Expenses'**
  String get nonOperatingIncomeExpense;

  /// No description provided for @earningBeforeTax.
  ///
  /// In en, this message translates to:
  /// **'Earnings Before Tax'**
  String get earningBeforeTax;

  /// No description provided for @taxDesc.
  ///
  /// In en, this message translates to:
  /// **'Only set the tax that applies for you, if you leave the field empty then the tax won\'t be included in your financial records'**
  String get taxDesc;

  /// No description provided for @incomeTax.
  ///
  /// In en, this message translates to:
  /// **'Income Tax'**
  String get incomeTax;

  /// No description provided for @salesTax.
  ///
  /// In en, this message translates to:
  /// **'Sales Tax'**
  String get salesTax;

  /// No description provided for @stateTax.
  ///
  /// In en, this message translates to:
  /// **'State Tax'**
  String get stateTax;

  /// No description provided for @governmentTax.
  ///
  /// In en, this message translates to:
  /// **'Government Tax'**
  String get governmentTax;

  /// No description provided for @netIncome.
  ///
  /// In en, this message translates to:
  /// **'Net Income'**
  String get netIncome;

  /// No description provided for @detailedBreakDown.
  ///
  /// In en, this message translates to:
  /// **'Detailed Breakdown'**
  String get detailedBreakDown;

  /// No description provided for @nonOperatingItems.
  ///
  /// In en, this message translates to:
  /// **'Non Operating Items'**
  String get nonOperatingItems;

  /// No description provided for @investmentIncome.
  ///
  /// In en, this message translates to:
  /// **'Investment Income'**
  String get investmentIncome;

  /// No description provided for @interestExpense.
  ///
  /// In en, this message translates to:
  /// **'Interest Expense'**
  String get interestExpense;

  /// No description provided for @foreignExchange.
  ///
  /// In en, this message translates to:
  /// **'Foreign Exchange Gain/Loss'**
  String get foreignExchange;

  /// No description provided for @keyFinancialMetrics.
  ///
  /// In en, this message translates to:
  /// **'Key Financial Metrics'**
  String get keyFinancialMetrics;

  /// No description provided for @grossProfitMargin.
  ///
  /// In en, this message translates to:
  /// **'Gross Profit Margin'**
  String get grossProfitMargin;

  /// No description provided for @operatingMargin.
  ///
  /// In en, this message translates to:
  /// **'Operating Margin'**
  String get operatingMargin;

  /// No description provided for @netProfitMargin.
  ///
  /// In en, this message translates to:
  /// **'Net Profit Margin'**
  String get netProfitMargin;

  /// No description provided for @percentageCogs.
  ///
  /// In en, this message translates to:
  /// **'COGS % of Revenue'**
  String get percentageCogs;

  /// No description provided for @saveFinancialRecord.
  ///
  /// In en, this message translates to:
  /// **'Would you like to save these data records for future use?'**
  String get saveFinancialRecord;

  /// No description provided for @pandLStatement.
  ///
  /// In en, this message translates to:
  /// **'P & L Statement'**
  String get pandLStatement;

  /// No description provided for @failedToRetrieveData.
  ///
  /// In en, this message translates to:
  /// **'Failed to retrieve data'**
  String get failedToRetrieveData;

  /// No description provided for @connectionLost.
  ///
  /// In en, this message translates to:
  /// **'Connection Lost'**
  String get connectionLost;

  /// No description provided for @checkYourConnection.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection'**
  String get checkYourConnection;

  /// No description provided for @topProducts.
  ///
  /// In en, this message translates to:
  /// **'Top Items'**
  String get topProducts;

  /// No description provided for @soldQuantity.
  ///
  /// In en, this message translates to:
  /// **'Sold Quantity'**
  String get soldQuantity;

  /// No description provided for @averagePrice.
  ///
  /// In en, this message translates to:
  /// **'Average Price'**
  String get averagePrice;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @premiumUser.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premiumUser;

  /// No description provided for @googlePlay.
  ///
  /// In en, this message translates to:
  /// **'Google Play store'**
  String get googlePlay;

  /// No description provided for @appleStore.
  ///
  /// In en, this message translates to:
  /// **'Apple Store'**
  String get appleStore;

  /// No description provided for @paymenetCharging.
  ///
  /// In en, this message translates to:
  /// **'Payment will be charged to your (store) account at confirmation of purchase. Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period.'**
  String paymenetCharging(Object store);

  /// No description provided for @privacyAndTerms.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyAndTerms;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @cont.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get cont;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'POPULAR'**
  String get popular;

  /// No description provided for @goPremium.
  ///
  /// In en, this message translates to:
  /// **'Go Premium'**
  String get goPremium;

  /// No description provided for @unlockAll.
  ///
  /// In en, this message translates to:
  /// **'Unlock all features and content'**
  String get unlockAll;

  /// No description provided for @unlimitedAccess.
  ///
  /// In en, this message translates to:
  /// **'Unlimited access to all content'**
  String get unlimitedAccess;

  /// No description provided for @exclusivePremium.
  ///
  /// In en, this message translates to:
  /// **'Exclusive premium features'**
  String get exclusivePremium;

  /// No description provided for @syncAll.
  ///
  /// In en, this message translates to:
  /// **'Sync across all your devices'**
  String get syncAll;

  /// No description provided for @prioritySup.
  ///
  /// In en, this message translates to:
  /// **'Priority support'**
  String get prioritySup;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @welcomePre.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Premium!'**
  String get welcomePre;

  /// No description provided for @startUsing.
  ///
  /// In en, this message translates to:
  /// **'Start Using App'**
  String get startUsing;

  /// No description provided for @upgradeToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to unlock this feature'**
  String get upgradeToUnlock;

  /// No description provided for @viewSub.
  ///
  /// In en, this message translates to:
  /// **'View Subscriptions'**
  String get viewSub;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notNow;

  /// No description provided for @sevenDayFree.
  ///
  /// In en, this message translates to:
  /// **'7-day FREE trial • Cancel anytime during trial'**
  String get sevenDayFree;

  /// No description provided for @sevenDayDes.
  ///
  /// In en, this message translates to:
  /// **'After the trial period, your subscription will automatically renew and you will be charged based on your selected plan.'**
  String get sevenDayDes;

  /// No description provided for @enterCoupon.
  ///
  /// In en, this message translates to:
  /// **'Enter Coupon Code'**
  String get enterCoupon;

  /// No description provided for @applyCoupon.
  ///
  /// In en, this message translates to:
  /// **'Apply Coupon Code'**
  String get applyCoupon;

  /// No description provided for @couponApplied.
  ///
  /// In en, this message translates to:
  /// **'Coupon applied: {discount}% discount'**
  String couponApplied(Object discount);

  /// No description provided for @cancelSupscription.
  ///
  /// In en, this message translates to:
  /// **'Cancel Supscription'**
  String get cancelSupscription;

  /// No description provided for @cancelSubWarning.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel your subscription and lose all the added features?'**
  String get cancelSubWarning;

  /// No description provided for @freeTrialDays.
  ///
  /// In en, this message translates to:
  /// **'{days} day free trial'**
  String freeTrialDays(Object days);

  /// No description provided for @freeTrial.
  ///
  /// In en, this message translates to:
  /// **'Free Trial'**
  String get freeTrial;

  /// No description provided for @purchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase Failed'**
  String get purchaseFailed;

  /// No description provided for @purchaseCancelled.
  ///
  /// In en, this message translates to:
  /// **'Purchase Cancelled'**
  String get purchaseCancelled;

  /// No description provided for @invalidCoupon.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired coupon code'**
  String get invalidCoupon;

  /// No description provided for @appliedCoupon.
  ///
  /// In en, this message translates to:
  /// **'Coupon applied successfully! \${coupon}% discount'**
  String appliedCoupon(Object coupon);

  /// No description provided for @totalToBePaid.
  ///
  /// In en, this message translates to:
  /// **'Total to be charged'**
  String get totalToBePaid;

  /// No description provided for @freeMonth.
  ///
  /// In en, this message translates to:
  /// **'Free Month'**
  String get freeMonth;

  /// No description provided for @freeYear.
  ///
  /// In en, this message translates to:
  /// **'Free Year'**
  String get freeYear;

  /// No description provided for @selectPlan.
  ///
  /// In en, this message translates to:
  /// **'Select Plan First'**
  String get selectPlan;

  /// No description provided for @noOfferingsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No offerings available'**
  String get noOfferingsAvailable;

  /// No description provided for @selectedPlanNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Selected plan is not available'**
  String get selectedPlanNotAvailable;

  /// No description provided for @purchaseInactive.
  ///
  /// In en, this message translates to:
  /// **'Purchase is inactive'**
  String get purchaseInactive;

  /// No description provided for @unableToLoadPlans.
  ///
  /// In en, this message translates to:
  /// **'Unable to load plans, try again'**
  String get unableToLoadPlans;

  /// No description provided for @premiumActive.
  ///
  /// In en, this message translates to:
  /// **'Premium Active!'**
  String get premiumActive;

  /// No description provided for @enjoyFreeTrial.
  ///
  /// In en, this message translates to:
  /// **'You are currently enjoying your free trial'**
  String get enjoyFreeTrial;

  /// No description provided for @enjoyPremium.
  ///
  /// In en, this message translates to:
  /// **'Welcome to CostEra Pro!'**
  String get enjoyPremium;

  /// No description provided for @currentPlan.
  ///
  /// In en, this message translates to:
  /// **'Current Plan'**
  String get currentPlan;

  /// No description provided for @freeTrialActive.
  ///
  /// In en, this message translates to:
  /// **'Free Trial Active'**
  String get freeTrialActive;

  /// No description provided for @trialEndsOn.
  ///
  /// In en, this message translates to:
  /// **'Trial ends on'**
  String get trialEndsOn;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since'**
  String get memberSince;

  /// No description provided for @yourBenefits.
  ///
  /// In en, this message translates to:
  /// **'Your Premium Benefits'**
  String get yourBenefits;

  /// No description provided for @generatePdfInvoice.
  ///
  /// In en, this message translates to:
  /// **'PDF Invoices'**
  String get generatePdfInvoice;

  /// No description provided for @createProfessionalInvoices.
  ///
  /// In en, this message translates to:
  /// **'Create professional PDF invoices instantly'**
  String get createProfessionalInvoices;

  /// No description provided for @detailedFinancialInsights.
  ///
  /// In en, this message translates to:
  /// **'Generate detailed financial reports and insights'**
  String get detailedFinancialInsights;

  /// No description provided for @expenseTracking.
  ///
  /// In en, this message translates to:
  /// **'Expense Tracking'**
  String get expenseTracking;

  /// No description provided for @monitorAllExpenses.
  ///
  /// In en, this message translates to:
  /// **'Monitor and categorize all your business expenses'**
  String get monitorAllExpenses;

  /// No description provided for @unlimitedProducts.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Products'**
  String get unlimitedProducts;

  /// No description provided for @addUnlimitedItems.
  ///
  /// In en, this message translates to:
  /// **'Add unlimited products and services to your catalog'**
  String get addUnlimitedItems;

  /// No description provided for @cloudSync.
  ///
  /// In en, this message translates to:
  /// **'Cloud Sync'**
  String get cloudSync;

  /// No description provided for @syncAcrossDevices.
  ///
  /// In en, this message translates to:
  /// **'Sync your data across all your devices securely'**
  String get syncAcrossDevices;

  /// No description provided for @prioritySupport.
  ///
  /// In en, this message translates to:
  /// **'Priority Support'**
  String get prioritySupport;

  /// No description provided for @createAndSendQuotes.
  ///
  /// In en, this message translates to:
  /// **'Create and send professional quotes'**
  String get createAndSendQuotes;

  /// No description provided for @suppliersAccess.
  ///
  /// In en, this message translates to:
  /// **'Suppliers Access'**
  String get suppliersAccess;

  /// No description provided for @manageYourSuppliers.
  ///
  /// In en, this message translates to:
  /// **'Manage and track your suppliers'**
  String get manageYourSuppliers;

  /// No description provided for @inventoryTracking.
  ///
  /// In en, this message translates to:
  /// **'Inventory Tracking'**
  String get inventoryTracking;

  /// No description provided for @trackStockInRealTime.
  ///
  /// In en, this message translates to:
  /// **'Track stock levels in real time'**
  String get trackStockInRealTime;

  /// No description provided for @orderReminders.
  ///
  /// In en, this message translates to:
  /// **'Order & Payment Reminders'**
  String get orderReminders;

  /// No description provided for @neverMissAPayment.
  ///
  /// In en, this message translates to:
  /// **'Never miss a due date or payment'**
  String get neverMissAPayment;

  /// No description provided for @fasterCustomerSupport.
  ///
  /// In en, this message translates to:
  /// **'Get faster responses from our support team'**
  String get fasterCustomerSupport;

  /// No description provided for @cancelSubscription.
  ///
  /// In en, this message translates to:
  /// **'Cancel Subscription'**
  String get cancelSubscription;

  /// No description provided for @cancelAnyTime.
  ///
  /// In en, this message translates to:
  /// **'You can cancel your subscription at any time'**
  String get cancelAnyTime;

  /// No description provided for @loadingSubscription.
  ///
  /// In en, this message translates to:
  /// **'Loading subscription info...'**
  String get loadingSubscription;

  /// No description provided for @errorLoadingSubscription.
  ///
  /// In en, this message translates to:
  /// **'Error loading subscription'**
  String get errorLoadingSubscription;

  /// No description provided for @cancelSubAtPeriodEnd.
  ///
  /// In en, this message translates to:
  /// **'Your subscription will remain active until the end of your current billing period. You will continue to enjoy all premium benefits until then.'**
  String get cancelSubAtPeriodEnd;

  /// No description provided for @subscriptionWillCancel.
  ///
  /// In en, this message translates to:
  /// **'Your subscription will be cancelled at the end of the current billing period.'**
  String get subscriptionWillCancel;

  /// No description provided for @accessUntil.
  ///
  /// In en, this message translates to:
  /// **'Access until'**
  String get accessUntil;

  /// No description provided for @renewsOn.
  ///
  /// In en, this message translates to:
  /// **'Renews on'**
  String get renewsOn;

  /// No description provided for @cancellationRequested.
  ///
  /// In en, this message translates to:
  /// **'Cancellation requested on'**
  String get cancellationRequested;

  /// No description provided for @subscriptionExpired.
  ///
  /// In en, this message translates to:
  /// **'Subscription Expired'**
  String get subscriptionExpired;

  /// No description provided for @premiumBenefitsGone.
  ///
  /// In en, this message translates to:
  /// **'Your premium benefits are no longer active. Please renew your subscription to continue enjoying all features.'**
  String get premiumBenefitsGone;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'days left for Premium'**
  String get daysLeft;

  /// No description provided for @noActiveSubscription.
  ///
  /// In en, this message translates to:
  /// **'No active subscription found'**
  String get noActiveSubscription;

  /// No description provided for @manageSubscriptionThrough.
  ///
  /// In en, this message translates to:
  /// **'Please manage your subscription through'**
  String get manageSubscriptionThrough;

  /// No description provided for @appStore.
  ///
  /// In en, this message translates to:
  /// **'App store'**
  String get appStore;

  /// No description provided for @resumeSubscription.
  ///
  /// In en, this message translates to:
  /// **'Resume Subscription'**
  String get resumeSubscription;

  /// No description provided for @resumeSubscriptionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to resume your subscription? Your subscription will continue and auto-renew as normal.'**
  String get resumeSubscriptionConfirm;

  /// No description provided for @resumeSubscriptionDesc.
  ///
  /// In en, this message translates to:
  /// **'Continue your subscription and keep all benefits'**
  String get resumeSubscriptionDesc;

  /// No description provided for @resubscribe.
  ///
  /// In en, this message translates to:
  /// **'Re-Subscribe'**
  String get resubscribe;

  /// No description provided for @subscriptionResumed.
  ///
  /// In en, this message translates to:
  /// **'Your subscription has been resumed!'**
  String get subscriptionResumed;

  /// No description provided for @cancellationPending.
  ///
  /// In en, this message translates to:
  /// **'Your subscription cancellation is pending. You can resume it anytime before the end date.'**
  String get cancellationPending;

  /// No description provided for @failedToResume.
  ///
  /// In en, this message translates to:
  /// **'Failed to resume'**
  String get failedToResume;

  /// No description provided for @failedToCancel.
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel'**
  String get failedToCancel;

  /// No description provided for @then.
  ///
  /// In en, this message translates to:
  /// **'Then'**
  String get then;

  /// No description provided for @autoRenewal.
  ///
  /// In en, this message translates to:
  /// **'Auto-Renewal Information'**
  String get autoRenewal;

  /// No description provided for @autoRenewalDes.
  ///
  /// In en, this message translates to:
  /// **'Your subscription will automatically renew at the end of each period unless cancelled at least 24 hours before the end of the current period. You can manage or cancel your subscription anytime through your {store} account settings.'**
  String autoRenewalDes(Object store);

  /// No description provided for @daysFree.
  ///
  /// In en, this message translates to:
  /// **'-Day Free Trial'**
  String get daysFree;

  /// No description provided for @subscriptionFeature.
  ///
  /// In en, this message translates to:
  /// **'The {feature} is only available for paid user, consider subscribing to enjoy unlimited access'**
  String subscriptionFeature(Object feature);

  /// No description provided for @subscriptionOrderFeature.
  ///
  /// In en, this message translates to:
  /// **'You have reached the {feature} limit for free users of {number} orders, consider subscribing to enjoy unlimited access to all features and orders'**
  String subscriptionOrderFeature(Object feature, Object number);

  /// No description provided for @theFor.
  ///
  /// In en, this message translates to:
  /// **'for'**
  String get theFor;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get months;

  /// No description provided for @salesStats.
  ///
  /// In en, this message translates to:
  /// **'Sales Statistics'**
  String get salesStats;

  /// No description provided for @sales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get sales;

  /// No description provided for @topClient.
  ///
  /// In en, this message translates to:
  /// **'Top Client'**
  String get topClient;

  /// No description provided for @totalSales.
  ///
  /// In en, this message translates to:
  /// **'Total Sales'**
  String get totalSales;

  /// No description provided for @averageMargin.
  ///
  /// In en, this message translates to:
  /// **'Average Margin'**
  String get averageMargin;

  /// No description provided for @topFiveClients.
  ///
  /// In en, this message translates to:
  /// **'Top 5 Clients'**
  String get topFiveClients;

  /// No description provided for @profitDist.
  ///
  /// In en, this message translates to:
  /// **'Profit Margin Distribution'**
  String get profitDist;

  /// No description provided for @annual.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get annual;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @revenueSplit.
  ///
  /// In en, this message translates to:
  /// **'Revenue Split'**
  String get revenueSplit;

  /// No description provided for @profit.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get profit;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @dueSoon.
  ///
  /// In en, this message translates to:
  /// **'Due Soon'**
  String get dueSoon;

  /// No description provided for @onTrack.
  ///
  /// In en, this message translates to:
  /// **'On Track'**
  String get onTrack;

  /// No description provided for @noUpcomingPayments.
  ///
  /// In en, this message translates to:
  /// **'No Upcoming Payments'**
  String get noUpcomingPayments;

  /// No description provided for @operationTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Operation timedout, check your connection and try again'**
  String get operationTimedOut;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @lastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last Week'**
  String get lastWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonth;

  /// No description provided for @thisYear.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get thisYear;

  /// No description provided for @lastYear.
  ///
  /// In en, this message translates to:
  /// **'Last Year'**
  String get lastYear;

  /// No description provided for @selectPeriod.
  ///
  /// In en, this message translates to:
  /// **'Select Period'**
  String get selectPeriod;

  /// No description provided for @inventoryReport.
  ///
  /// In en, this message translates to:
  /// **'Inventory Report'**
  String get inventoryReport;

  /// No description provided for @keepEmptyForAllLocations.
  ///
  /// In en, this message translates to:
  /// **'Keep empty for all locations'**
  String get keepEmptyForAllLocations;

  /// No description provided for @storeName.
  ///
  /// In en, this message translates to:
  /// **'Store Name'**
  String get storeName;

  /// No description provided for @productStock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get productStock;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @tutorialCompleted.
  ///
  /// In en, this message translates to:
  /// **'Tutorial Completed'**
  String get tutorialCompleted;

  /// No description provided for @tutOrderScreenDes.
  ///
  /// In en, this message translates to:
  /// **'The order calender will keep track of your monthly orders'**
  String get tutOrderScreenDes;

  /// No description provided for @tutQuotesDes.
  ///
  /// In en, this message translates to:
  /// **'The quotes allow you to create quotations for your clients before creating an order and invoicing'**
  String get tutQuotesDes;

  /// No description provided for @tutDashScreenDes.
  ///
  /// In en, this message translates to:
  /// **'Our home button or dashboard will show your monthly progress'**
  String get tutDashScreenDes;

  /// No description provided for @tutProductScreenDes.
  ///
  /// In en, this message translates to:
  /// **'Here you can create, edit and adjust products. All your products can be accessed from this page'**
  String get tutProductScreenDes;

  /// No description provided for @tutSettingScreeDes.
  ///
  /// In en, this message translates to:
  /// **'The settings screen will provide all functionality for your app'**
  String get tutSettingScreeDes;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @tutorial.
  ///
  /// In en, this message translates to:
  /// **'Tutorial'**
  String get tutorial;

  /// No description provided for @tutorialSkipped.
  ///
  /// In en, this message translates to:
  /// **'Tutorial Skipped'**
  String get tutorialSkipped;

  /// No description provided for @startTutorial.
  ///
  /// In en, this message translates to:
  /// **'Start Tutorial'**
  String get startTutorial;

  /// No description provided for @skipTutorial.
  ///
  /// In en, this message translates to:
  /// **'Skip Tutorial'**
  String get skipTutorial;

  /// No description provided for @tutorialWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get tutorialWelcome;

  /// No description provided for @tutorialStartPrompt.
  ///
  /// In en, this message translates to:
  /// **'Let us learn how to use the app'**
  String get tutorialStartPrompt;

  /// No description provided for @tutgalleryDes.
  ///
  /// In en, this message translates to:
  /// **'All your product or service images can be uploaded here'**
  String get tutgalleryDes;

  /// No description provided for @tutProfileDes.
  ///
  /// In en, this message translates to:
  /// **'Edit all your personal details from the profile section'**
  String get tutProfileDes;

  /// No description provided for @tutAccountDes.
  ///
  /// In en, this message translates to:
  /// **'Edit your business information from the account section'**
  String get tutAccountDes;

  /// No description provided for @tutAppSettingDes.
  ///
  /// In en, this message translates to:
  /// **'Modify the app settings from color, theme and more from here!'**
  String get tutAppSettingDes;

  /// No description provided for @tutClientDes.
  ///
  /// In en, this message translates to:
  /// **'Add and Edit your client details from here'**
  String get tutClientDes;

  /// No description provided for @tutOrdersDes.
  ///
  /// In en, this message translates to:
  /// **'You can create and modify your order through the orders tab'**
  String get tutOrdersDes;

  /// No description provided for @tutSupplierDes.
  ///
  /// In en, this message translates to:
  /// **'The Suppliers tab allows you to add suppliers and issue purchases'**
  String get tutSupplierDes;

  /// No description provided for @tutPurchasesDes.
  ///
  /// In en, this message translates to:
  /// **'The Purchase tab will allow you to issue and edit purchases'**
  String get tutPurchasesDes;

  /// No description provided for @tutCapExpReportDes.
  ///
  /// In en, this message translates to:
  /// **'The Capital and Expenses tab is essential for controlling your expenses'**
  String get tutCapExpReportDes;

  /// No description provided for @tutFinancialReportDes.
  ///
  /// In en, this message translates to:
  /// **'Monitor your business and know how you\'re doing by issuing the required reports'**
  String get tutFinancialReportDes;

  /// No description provided for @tutFilterOptionDes.
  ///
  /// In en, this message translates to:
  /// **'The filter option will allow you to search for a specific item or filter by several variables'**
  String get tutFilterOptionDes;

  /// No description provided for @tutAddProductDes.
  ///
  /// In en, this message translates to:
  /// **'The add button will allow you to add product or services!'**
  String get tutAddProductDes;

  /// No description provided for @tutPaymentDes.
  ///
  /// In en, this message translates to:
  /// **'Will show all credit payments for your clients'**
  String get tutPaymentDes;

  /// No description provided for @days15.
  ///
  /// In en, this message translates to:
  /// **'15 days'**
  String get days15;

  /// No description provided for @days30.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get days30;

  /// No description provided for @days45.
  ///
  /// In en, this message translates to:
  /// **'45 days'**
  String get days45;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @dueOn.
  ///
  /// In en, this message translates to:
  /// **'Due On'**
  String get dueOn;

  /// No description provided for @addPayment.
  ///
  /// In en, this message translates to:
  /// **'Add Payment'**
  String get addPayment;

  /// No description provided for @editPayment.
  ///
  /// In en, this message translates to:
  /// **'Edit Payment'**
  String get editPayment;

  /// No description provided for @upcomingPayments.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Payments'**
  String get upcomingPayments;

  /// No description provided for @updatePayment.
  ///
  /// In en, this message translates to:
  /// **'Update Payment'**
  String get updatePayment;

  /// No description provided for @partialPayment.
  ///
  /// In en, this message translates to:
  /// **'The payment doesn\'t cover the required amount, remaining balance of {amount} will remain pending'**
  String partialPayment(Object amount);

  /// No description provided for @paymentOverpaid.
  ///
  /// In en, this message translates to:
  /// **'The payment exceeds the required balance, the additional amount of {amount} will be added to the client as credit'**
  String paymentOverpaid(Object amount);

  /// No description provided for @paymentCovered.
  ///
  /// In en, this message translates to:
  /// **'Payment is fully covered and the credit invoice shall be closed accordingly'**
  String get paymentCovered;

  /// No description provided for @clientStatement.
  ///
  /// In en, this message translates to:
  /// **'Client Statement'**
  String get clientStatement;

  /// No description provided for @method.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get method;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faq;

  /// No description provided for @question.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get question;

  /// No description provided for @answer.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get answer;

  /// No description provided for @referenceOrder.
  ///
  /// In en, this message translates to:
  /// **'Order Reference'**
  String get referenceOrder;

  /// No description provided for @questionEmpty.
  ///
  /// In en, this message translates to:
  /// **'Question List is Empty'**
  String get questionEmpty;

  /// No description provided for @questionIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Question cannot be empty'**
  String get questionIsEmpty;

  /// No description provided for @answerIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Answer cannot be empty'**
  String get answerIsEmpty;

  /// No description provided for @referenceIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Reference cannot be empty'**
  String get referenceIsEmpty;

  /// No description provided for @referenceOrderExits.
  ///
  /// In en, this message translates to:
  /// **'Reference order already exists, select another one'**
  String get referenceOrderExits;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'es', 'fr', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
