// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CostEra';

  @override
  String get register => 'Register';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get password => 'Password';

  @override
  String get confirmPass => 'Confirm Password';

  @override
  String get notEmpty => 'Should not be empty';

  @override
  String get emailValidation => 'Email is not valid';

  @override
  String get shortPassword => 'min 8 characters';

  @override
  String get needNumber => 'at least a number';

  @override
  String get needSpCharacter => 'at least one \$ # @ ...etc';

  @override
  String get firstNameRequired => 'First name is required';

  @override
  String get lastNameRequired => 'Last name is required';

  @override
  String get emailAddressRequired => 'Email address is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get confirmpasswordRequired => 'Confirm password is required';

  @override
  String get passwordNoMatcH => 'Passwords don\'t match';

  @override
  String get connectionError => 'Connection Error, try again later';

  @override
  String get createYourAccount => 'Create Your Account';

  @override
  String get personalInfo => 'Personal Info';

  @override
  String get accountInfo => 'Account Info';

  @override
  String get alreadyHaveAccount => 'Already have an account!';

  @override
  String get login => 'Login';

  @override
  String get forgotPass => 'Forgot Password';

  @override
  String get reset => 'Reset';

  @override
  String get googleSignIn => 'Google';

  @override
  String get appleSignIn => 'Apple';

  @override
  String get verifyEmail => 'Kindly verfiy email in order to proceed';

  @override
  String get verifyYourEmail => 'Verify Your Email';

  @override
  String get verificationLinkSentTo => 'We\'ve sent a verification link to';

  @override
  String get verifyEmailBody =>
      'Open the email and tap the link to verify your account. Don\'t forget to check your spam or junk folder.';

  @override
  String get resendEmail => 'Resend Email';

  @override
  String resendEmailIn(Object seconds) {
    return 'Resend available in ${seconds}s';
  }

  @override
  String get verificationEmailResent => 'Verification email resent';

  @override
  String get emailVerifiedSuccess =>
      'Email verified! Please log in to continue';

  @override
  String get wrongEmail => 'Wrong email?';

  @override
  String get waitingForVerification => 'Waiting for verification...';

  @override
  String get signOut => 'Sign Out';

  @override
  String get profile => 'Profile';

  @override
  String get account => 'Account';

  @override
  String get appSettings => 'App Settings';

  @override
  String get buildNumber => 'Build Number';

  @override
  String get currency => 'Currency';

  @override
  String get businessAddress => 'Business Address';

  @override
  String get assignedCurrency => 'Assigned Currency';

  @override
  String get userNotFound => 'User Not Found';

  @override
  String get receipies => 'Receipies';

  @override
  String get selectCurrency => 'Select Currency';

  @override
  String get emailNotVerified => 'Email Not Verified';

  @override
  String get changeCurrency => 'Change Currency';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get accountDeletionMessage =>
      'Are you sure you want to proceed with deleting your account?\nWe will keep your data on our server for up to 30 days before permanently deleting all your content!\nWe regret to see you leave and hope one day we shall see you again.';

  @override
  String get accountDeletionSuccess =>
      'Your account was successfully deleted, you have 30 days if you decided to change your mind!';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get rateUs => 'Rate Us';

  @override
  String get messageContent => 'Message Content';

  @override
  String get send => 'Send';

  @override
  String get subject => 'Subject';

  @override
  String get technical => 'Technical';

  @override
  String get complaint => 'Complaint';

  @override
  String get suggestion => 'Suggestion';

  @override
  String get messageCannotBeEmpty => 'Message content cannot be empty';

  @override
  String get selectSubject => 'Select message subject';

  @override
  String get longPressToRemove => 'Long press to remove';

  @override
  String get personalInformation => 'Profile Information';

  @override
  String get contactInformation => 'Contact Information';

  @override
  String get accountInformation => 'Account Information';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully';

  @override
  String get messageSentSuccessfully =>
      'Message has been sent successfully, our dedicated team will reach out shortly.';

  @override
  String get thankYouForReachingOut =>
      'Thank you for reaching out, we try our best to resolve the issue within 48 hours.';

  @override
  String get screenShots =>
      'Attach screen shots of any issue you have encountered';

  @override
  String get manageYourBusiness => 'Manage Your Business';

  @override
  String get sigIn => 'Sign In';

  @override
  String get or => 'Or';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get dontHaveAccount => 'Don\'t have an Account?';

  @override
  String get orContinueWith => 'or Continue with';

  @override
  String get resetIt => 'Reset it';

  @override
  String get senderDetails => 'Your Details';

  @override
  String get forgotPassSubtitle =>
      'Enter your email and we\'ll send you a reset link';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetEmailSent => 'Reset email sent. Please check your inbox.';

  @override
  String get invoiceSettings => 'Invoice Settings';

  @override
  String get invoiceSettingExplained =>
      'Adjust the content of your invoice by changing enabling or disabling features';

  @override
  String get on => 'On';

  @override
  String get off => 'Off';

  @override
  String get companyFinancialDetaiils => 'My Financial Details';

  @override
  String get clientCrNumber => 'Client CR Number';

  @override
  String get clientBankDetail => 'Client Bank Details';

  @override
  String get clientFinancialDetails => 'Client Financial Number';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get exitConfirmation =>
      'You have unsaved changes, are you sure you want to exit?';

  @override
  String get generalSettings => 'General Settings';

  @override
  String get generalSettingsExplained =>
      'Change your app settings as per your requirement';

  @override
  String get assignedLanguage => 'Assigned Language';

  @override
  String get assignedTheme => 'Assigned Theme';

  @override
  String get inventoryInfo =>
      'Inventory will allow you create up to 10 locations to store your products';

  @override
  String get inventory => 'Inventory';

  @override
  String get selectNewStore => 'Select a New Store';

  @override
  String get inventoryLocation => 'Inventory Location';

  @override
  String get financialSettings => 'Financial Settings';

  @override
  String get financialSettingsDesc =>
      'Financial settings will allow you set standart variables related to your financial statement';

  @override
  String get defaultSalesOrderTerms =>
      'Set your default delivery, return, and refund terms for your sales orders';

  @override
  String get defaultPurchaseTerms =>
      'Set your default delivery, return, and refund terms for your purchase orders';

  @override
  String get reactivate => 'Re-activate';

  @override
  String get status => 'Status';

  @override
  String get restartApp => 'Restart App';

  @override
  String get restartAppLangInfo =>
      'In order to change the langauge you need to restart the app, Are you sure you want to proceed?';

  @override
  String get restartAppThemeInfo =>
      'In order to change the Theme you need to restart the app, Are you sure you want to proceed?';

  @override
  String get inventoryController => 'Inventory Controller';

  @override
  String get inventoryIntro =>
      'The inventory option will allow you to create location in which you can store products. Be aware though when you activate the inventory your order will be directly linked and you won\'t be able to process them if you\'re out of stock.';

  @override
  String get activateInventory => 'Activate Inventory';

  @override
  String get locationName => 'Location Name';

  @override
  String get inventoryLocationLimit =>
      'You have reached the maximum inventory locations allowed';

  @override
  String get inventoryValue => 'Inventory Value';

  @override
  String get inventoryInActive => 'Inventory In-active';

  @override
  String get doActivateInventory =>
      'Do you want to activate the inventory option?';

  @override
  String get locationNameEmpty => 'Location name is empty, fix it to proceed';

  @override
  String get purchaseOrder => 'Purchase Orders';

  @override
  String get purchaseInfo =>
      'The purchase feature allows you to create purchase orders for your supplier which will update your product cost automaically if you chose to';

  @override
  String get purchaseSettings => 'Purchase Settings';

  @override
  String get activatePurchases => 'Activate Purchases';

  @override
  String get updateProductCost => 'Update Product Cost';

  @override
  String get purchases => 'Purchases';

  @override
  String get addPurchase => 'Add Purchase';

  @override
  String get editPurchase => 'Edit Purchase';

  @override
  String get noSupplierFound => 'No supplier Found';

  @override
  String get supplierName => 'Supplier Name';

  @override
  String get supplierNameEmpty => 'Supplier name empty';

  @override
  String get supplierNameInvalid => 'Supplier name is invalid';

  @override
  String get purchaseTerms => 'Purchase Terms';

  @override
  String get generatePO => 'Generate PO';

  @override
  String get generatePoInfo =>
      'Once purchase order is generated you can no longer edit or modify your order. Incase you need to cancel it you can delete the order and create a new one';

  @override
  String get receivingPO => 'Receiving Purchase Order';

  @override
  String get receive => 'Receive';

  @override
  String get receiveInfo =>
      'This will allow you to confirm if the purchase order has been received, or modify that quantity that was received';

  @override
  String get materialAlreadyReceived =>
      'Material from this purchase order has already been received';

  @override
  String get receiveMaterial => 'Receive Material';

  @override
  String get remove => 'Remove';

  @override
  String get storeNotAssigned => 'Store hasn\'t been assigned';

  @override
  String storeNotExisting(Object product, Object store) {
    return 'Selected store $store doesn\'t exist for product $product';
  }

  @override
  String get purchaseOrderGenerationComplete =>
      'Purchase order generation complete';

  @override
  String get generated => 'Generated';

  @override
  String get received => 'Received';

  @override
  String get revertingBackNotPossible =>
      'Please note that reverting back to the previous item cost is not possible at the moment, kindly do that manually';

  @override
  String get suppliers => 'Suppliers';

  @override
  String get addSupplier => 'Add Supplier';

  @override
  String get editSupplier => 'Edit Supplier';

  @override
  String get supplierOrders => 'Supplier Orders';

  @override
  String get home => 'Home';

  @override
  String get product => 'Items';

  @override
  String get settings => 'Settings';

  @override
  String get menu => 'Menu';

  @override
  String get orders => 'Orders';

  @override
  String get payments => 'Payments';

  @override
  String get businessType => 'Business Type';

  @override
  String get businessCategory => 'Business Category';

  @override
  String get businessTypeDes =>
      'Select the business type that best describes your business, and keep in the mind that it will affect how product cost will calculated';

  @override
  String get businessCategoryDes =>
      'Select the business category if available or others if not available, we will look into it and will try to add it in the future';

  @override
  String get businessTypeNotDefined =>
      'Business type seems to be not defined, kindly check your account and assign a business type';

  @override
  String get missingCategory => 'You need to select a category';

  @override
  String get missingType => 'You need to select a type';

  @override
  String get fillManualCategory => 'Fill in your business category';

  @override
  String get select => 'Select';

  @override
  String get update => 'Update';

  @override
  String get companyInfo => 'Company Information';

  @override
  String get companyName => 'Company Name';

  @override
  String get companyLogo => 'Company Logo';

  @override
  String get save => 'Save';

  @override
  String get companyLogoMissing => 'Company logo is missing';

  @override
  String get dataSaveSuccessfully => 'Data saved successfully';

  @override
  String get failedToSaveData => 'Failed to save data';

  @override
  String get imageRemovedSuccessfully => 'Image removed successfully';

  @override
  String get failedToRemoveImage => 'Failed to remove image';

  @override
  String get currencyDes =>
      'Select the currency in which you would like to conduct your business with, this can be changed later';

  @override
  String get locationDes =>
      'Select the location from which you business will be conducted, this can be changed later';

  @override
  String get noApiKeyDetected =>
      'No api key has been detected, please contact support';

  @override
  String get viewMore => 'View More';

  @override
  String get locationChoice => 'Would you like to grant the app your location?';

  @override
  String get skip => 'Skip';

  @override
  String get dataRefereshedSuccessfully => 'Data Refreshed Successfully';

  @override
  String get dataFailedToRefresh => 'Data Failed to Refresh';

  @override
  String get businessTypeSubDes => 'This helps us personalise your experience.';

  @override
  String get continueLabel => 'Continue';

  @override
  String get stepOneOfTwo => 'Step 1 of 2';

  @override
  String get currencySubDes => 'Used across all invoices, orders and reports.';

  @override
  String get stepTwoOfTwo => 'Step 2 of 2';

  @override
  String get finishSetup => 'Finish setup';

  @override
  String get addressNotRegistered => 'Address has not been registered';

  @override
  String get noLocationSelected => 'No Location Selected';

  @override
  String get selectLocation => 'Select Location';

  @override
  String get locServiceDisabled => 'Location service disabled';

  @override
  String get locServiceDenied => 'Location service denied';

  @override
  String get locServiceDeniedForever =>
      'Location permissions are permanently denied. if you wish to set your location you need to head to your device settings and enable them from there.';

  @override
  String get locationPermissionDenied => 'Location permission has been denied';

  @override
  String get locationPermissionPermanentlyDenied =>
      'Location permission has been denied permanently';

  @override
  String get locationServicesDisabled => 'Location services have been disabled';

  @override
  String get networkError => 'Network error, try again';

  @override
  String get configurationError => 'Configuration error, try again';

  @override
  String get somethingWentWrong =>
      'Something went wrong, please contact support';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get retry => 'Retry';

  @override
  String get addProduct => 'Add Item';

  @override
  String get editProduct => 'Edit Item';

  @override
  String get productName => 'Item Name';

  @override
  String get itemCode => 'Item Code';

  @override
  String get productDescription => 'Item Description';

  @override
  String get productPacking => 'Item Packing (example kg, pcs...)';

  @override
  String get productCost => 'Item Cost';

  @override
  String get productCostService => 'Item Cost (Optional)';

  @override
  String get productPrice => 'Item Selling Price';

  @override
  String get images => 'Images';

  @override
  String get files => 'Files';

  @override
  String get noImages => 'No Images Found';

  @override
  String get productNameEmpty => 'Item name cannot be empty';

  @override
  String get productCostEmpty =>
      'Item cost is needed, enter 0 if you don\'t wish to add cost';

  @override
  String get productPriceEmpty =>
      'Item should have a price, enter 0 for free Items';

  @override
  String get productImageEmpty => 'Any Item should have at least 1 images';

  @override
  String get noProductsAdded => 'No Items Added';

  @override
  String get productCostError => 'Check if you business Category is selected';

  @override
  String get addCost => 'Add Cost';

  @override
  String get editCost => 'Edit Cost';

  @override
  String get saveProductFirst => 'Save Item first, then you cant add your cost';

  @override
  String get costValue => 'Cost Value';

  @override
  String get error => 'Error';

  @override
  String get noProductFound => 'No Items Found';

  @override
  String get productCategory => 'Item Category (Optional)';

  @override
  String get productCategoryHint =>
      'Type in any category, shall be created after you add a product';

  @override
  String get id => 'ID';

  @override
  String get filterOptions => 'Filter Options';

  @override
  String get filterProducts => 'Filter Items';

  @override
  String get searchProducts => 'Search Items';

  @override
  String get priceRange => 'Price Range';

  @override
  String get minPrice => 'Min Price';

  @override
  String get maxPrice => 'Max Price';

  @override
  String get applyFilter => 'Apply Filter';

  @override
  String get productCodeExists => 'Item Code already Exists';

  @override
  String get itemCodeEmpty => 'Item code cannot be empty';

  @override
  String get noCategoriesFound => 'No categories found';

  @override
  String get productRecords => 'Item Records';

  @override
  String get productsLimit =>
      'It seems you\'ve reached the product limit on our free version, subscribe to our paid plan to enjoy an unlimited number of products';

  @override
  String get orderLimit =>
      'Its seems you\'ve reached the order limit on our free version, subscribe to our paid plan to enjoy and unlimited number of orders';

  @override
  String get category => 'Category';

  @override
  String get subscribeToAccessInventory => 'Subscribe to Access Inventory';

  @override
  String get basicInfo => 'Basic info';

  @override
  String get auto => 'Auto';

  @override
  String get packaging => 'Packaging';

  @override
  String get pricing => 'Pricing';

  @override
  String get profitMargin => 'Profit margin';

  @override
  String get noItemRecordFound => 'No item record found';

  @override
  String get clearFilter => 'Clear Filter';

  @override
  String get receipes => 'Receipes';

  @override
  String get addReceipe => 'Add Receipe';

  @override
  String get editRecipe => 'Edit Receipe';

  @override
  String get noReceipesFound => 'No Receipes Found';

  @override
  String get receipeName => 'Receipe Name';

  @override
  String get receipeDescription => 'Receipe Description';

  @override
  String get receipePacking => 'Receipe Packing';

  @override
  String get receipeIngredients => 'Receipe Ingredients';

  @override
  String get cost => 'Cost';

  @override
  String get pack => 'Pack';

  @override
  String get packService => 'Package or Sessions';

  @override
  String get quantity => 'Qyt';

  @override
  String get suggestions => 'Suggestions';

  @override
  String get unit => 'Unit';

  @override
  String get selectedIngredientFirst =>
      'You need to select and ingredient first';

  @override
  String get add => 'Add';

  @override
  String get totalCost => 'Total Cost';

  @override
  String get packingUnit => 'Unit';

  @override
  String get receipeNameRequired => 'Receipe name is required';

  @override
  String get receipePackingRequired => 'Receipe packing Value is required';

  @override
  String get receipePackingUnitRequired => 'Receipe packing Unit is required';

  @override
  String get ingredientsMissing =>
      'Each receipe should have at least an ingredient';

  @override
  String get tapReceipeToAdd => 'Tap on the receipt to add to product';

  @override
  String get recipeDetails => 'Recipe Details';

  @override
  String get outputPacking => 'Output Packing';

  @override
  String get rawMaterial => 'Raw Material';

  @override
  String get noRawMaterialsFound => 'No Raw material was found';

  @override
  String get rawMaterialAdd => 'Add New';

  @override
  String get rawMaterialEdit => 'Edit Current';

  @override
  String get name => 'Name';

  @override
  String get description => 'Description';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get quantityRequired => 'Quantity is required';

  @override
  String get unitRequired => 'Unit is required';

  @override
  String get costRequired => 'Cost is required';

  @override
  String get quantityAndUnit => 'Quantity and Unit';

  @override
  String get conversionRates => 'Conversion Rates';

  @override
  String get gallery => 'Gallery';

  @override
  String get camera => 'Camera';

  @override
  String get addImage => 'Add Image';

  @override
  String get editImage => 'Edit Image';

  @override
  String get search => 'Search';

  @override
  String get imageSelectionError =>
      'Error trying to select image, kindly try again';

  @override
  String get imageNotSelected => 'Failed to select image';

  @override
  String get cameraPermissionDenied => 'Camera permission has been denied';

  @override
  String get mediaPermissionDenied => 'Media permission has been denied';

  @override
  String get failedToUploadImage => 'Failed to upload image';

  @override
  String get failedToUploadVideo => 'Failed to upload Video';

  @override
  String get delete => 'Delete';

  @override
  String get deleteConfirmation => 'Are you sure you want to delete?';

  @override
  String deleteConfirmationWithCount(Object number) {
    return 'Are you sure you want to delete these $number items';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get active => 'Active';

  @override
  String get discard => 'Discard';

  @override
  String get cancelConfirmation =>
      'Are you sure you want to cancel this order?';

  @override
  String get warning => 'Warning';

  @override
  String get ok => 'Ok';

  @override
  String get restore => 'Restore';

  @override
  String get restoreConfirmation =>
      'Are you sure you want to restore this order';

  @override
  String imagesDeleted(Object number) {
    return 'You have deleted $number images';
  }

  @override
  String get failedToDeleteImages => 'Failed to delete the selected image';

  @override
  String get selected => 'Selected';

  @override
  String get changingTypeNotPossible =>
      'You can no longer change business type as you have already added products';

  @override
  String get doubleToAdd => 'Double click on the image to link to a product';

  @override
  String get client => 'Client';

  @override
  String get clients => 'Clients';

  @override
  String get addClient => 'Add Client';

  @override
  String get editClient => 'Edit Client';

  @override
  String get noClientsFound => 'No Clients Found';

  @override
  String get individual => 'Individual';

  @override
  String get company => 'Company';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get clientNameEmpty => 'Client name cannot be empty';

  @override
  String get clientNameInvalid => 'Client name is invalid';

  @override
  String get companyNameEmpty =>
      'Company name cannot be empty, please go to settings -> account and set your company name';

  @override
  String get phoneNumberEmpty =>
      'Phone number cannot be empty, please go to settings -> account and set your company logo';

  @override
  String get phoneCodeEmpty => 'Phone code needs to be selected';

  @override
  String get clientName => 'Client Name';

  @override
  String get clientOrders => 'Client Orders';

  @override
  String get clientCompanyName => 'Client company name cannot be empty';

  @override
  String get financialNumber => 'Financial Number';

  @override
  String get crNumber => 'CR Number';

  @override
  String get ibanNumber => 'IBAN Number';

  @override
  String get bankName => 'Bank Name';

  @override
  String get bankBranch => 'Bank Branch';

  @override
  String get otherPayment => 'Other Payment Method';

  @override
  String get order => 'Order';

  @override
  String get due => 'Due';

  @override
  String get overDue => 'Overdue';

  @override
  String get clientType => 'Client Type';

  @override
  String get contactInfo => 'Contact';

  @override
  String get officialData => 'Official data';

  @override
  String get reports => 'Reports';

  @override
  String get capitalAndExpenses => 'Capital & Expenses';

  @override
  String get financialReports => 'Financial Reports';

  @override
  String get expenses => 'Expenses';

  @override
  String get fixedCosts => 'Fixed Costs';

  @override
  String get assets => 'Assets';

  @override
  String get costs => 'Costs';

  @override
  String get noOrdersFound => 'No Orders Found';

  @override
  String get addOrder => 'Add Order';

  @override
  String get editOrder => 'Edit Order';

  @override
  String get itemQuantity => 'Quantity';

  @override
  String get discount => 'Discount';

  @override
  String get price => 'Price';

  @override
  String get discountedPrice => 'Dis. Price';

  @override
  String get quantityCannotBeEmpty => 'Quantity cannot be empty';

  @override
  String get priceCannotBeEmpty => 'Price cannot be empty';

  @override
  String get cannotPerformDiscountOnAddedPrice =>
      'You cannot perform a discount on price increase';

  @override
  String get totalValue => 'Total Value';

  @override
  String get productListEmpty => 'Product list cannot be empty';

  @override
  String get orderTerms => 'Order Terms';

  @override
  String get deliveryTerms => 'Delivery Terms';

  @override
  String get deliveryTime => 'Delivery Time';

  @override
  String get immediate => 'Immediate';

  @override
  String get scheduled => 'Scheduled';

  @override
  String get selectTime => 'Select Time';

  @override
  String get selectTimeFirst => 'Select Time First';

  @override
  String get selectDate => 'Select Date';

  @override
  String get selectDateFirst => 'Select Date First';

  @override
  String get immediateDelivery =>
      'Order will be set to be delivered immediately';

  @override
  String get noOrderFound => 'No order found';

  @override
  String get invoice => 'Invoice';

  @override
  String get number => 'Number';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get total => 'Total';

  @override
  String get paymentTerms => 'Payment Terms';

  @override
  String get termsandConditions => 'Terms and Conditions';

  @override
  String get termsIntroWeb =>
      'Please read and accept our Terms of Service before continuing.';

  @override
  String termsandConditionDesc(Object provider) {
    return 'Every user needs to agree to $provider terms before proceeding';
  }

  @override
  String get apple => 'Apple';

  @override
  String get google => 'Google';

  @override
  String get viewFullTerms =>
      'You can view the full terms by clicking on the below link';

  @override
  String get agreeToTerms => 'Agree to Terms';

  @override
  String termsSummaryDetails(Object provider) {
    return 'Subscriptions renew automatically unless cancelled at least 24 hours before renewal, and all purchases are subject to $provider\'s policies.';
  }

  @override
  String get iHaveReadAndAgree =>
      'I have read and agree to the Terms and Conditions';

  @override
  String get readFullTerms => 'Read Full Terms';

  @override
  String get needToAgreeToTerms =>
      'You need to check and confirm the apps terms and conditions';

  @override
  String get ref => 'Ref';

  @override
  String get invoiceNumber => 'Invoice Number';

  @override
  String get invoiceGenCompleted => 'Invoice generation completed';

  @override
  String get invoiceGenFailed => 'Invoice generation failed, please try again';

  @override
  String get returnTerms => 'Return/Refund';

  @override
  String get returnTermsService => 'Refund or Cancel';

  @override
  String get close => 'Close';

  @override
  String get unsavedData => 'You have unsaved data, save before closing';

  @override
  String get returns => 'Returns';

  @override
  String get clientDetails => 'Client Details';

  @override
  String get billTo => 'Bill To';

  @override
  String get scheduledOrder => 'This Order is Scheduled On';

  @override
  String get scheduledDate => 'Scheduled Date';

  @override
  String get scheduledTime => 'Scheduled Time';

  @override
  String get orderId => 'Order Id';

  @override
  String get invoiced => 'Invoiced';

  @override
  String get generateInvoice => 'Generate Invoice';

  @override
  String get generateInvoiceInfo =>
      'Once invoice is generated you can no longer edit or modify your order. Incase you need to cancel it you can delete the order and create a new one';

  @override
  String get generate => 'Generate';

  @override
  String get regenerate => 'Re-Generate';

  @override
  String get orderPlacedAt => 'Placed At';

  @override
  String get noDeliveryTerms => 'No delivery terms has been set';

  @override
  String get noReturnRefundTermsSet => 'No return/refund terms has been set';

  @override
  String get orderMargins => 'Order Margins';

  @override
  String get grossProfit => 'Gross Profit';

  @override
  String get margin => 'Margin';

  @override
  String get draft => 'Draft';

  @override
  String get noStockAvailableInLocation =>
      'No stock available in the selected location for this product';

  @override
  String get insufficientInventory =>
      'You don\'t have enough stock in the selected location';

  @override
  String insufficientStockFor(Object item, Object location) {
    return 'Insufficient stock for $item in $location';
  }

  @override
  String get confirmed => 'Confirmed';

  @override
  String get setReminder => 'Set Reminder';

  @override
  String get reminderMe => 'Remind Me';

  @override
  String get reminderNote =>
      'Reminders need to be set at least 10 minutes in the future';

  @override
  String get notificationDisabled =>
      'Notifications are disabled, meaning you won\'t receive reminders for your orders, enable them';

  @override
  String get deliveryCharges => 'Delivery Charges';

  @override
  String get deliveryFees => 'Delivery Fees';

  @override
  String get noDeliveryFees => 'No delivery fees set';

  @override
  String get delivery => 'Delivery';

  @override
  String get subscribeToAccess => 'Subscribe to Access Statistics';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get cancelledOrders => 'Cancelled Orders';

  @override
  String get cancelledOrder =>
      'Do you want to restore this cancelled order, press yes to restore and no to keep it cancelled';

  @override
  String get orderRemainsCancelled => 'Order remains cancelled';

  @override
  String get failedToCancelOrder =>
      'Failed to cancel the selected order, pleast contact support';

  @override
  String get failedToRestoreOrder =>
      'Failed to restore the selected order, please contact support';

  @override
  String get orderCancelled => 'Order is Cancelled';

  @override
  String get receipeIsMissing =>
      'Receipe is missing, check if it\'s deleted or removed, update the product again';

  @override
  String get rawItemMissing =>
      'Raw item is missing, check if it\'s deleted or removed, update the receipe again';

  @override
  String get taxValue => 'Tax Value';

  @override
  String get failedToDownloadInvoice =>
      'Failed to download the invoice, please check your connection';

  @override
  String get collection => 'Payment Collection';

  @override
  String collectionReminder(Object days) {
    return 'Set a reminder to trigger when collection is due in $days days';
  }

  @override
  String get shallWeRemindYou => 'Shall we reminder you?';

  @override
  String get quotes => 'Quotations';

  @override
  String get quoteTerms => 'Quote Terms';

  @override
  String get addQuote => 'Add Quote';

  @override
  String get editQuote => 'Edit Quote';

  @override
  String get noQuotesFound => 'No Quotes Found';

  @override
  String get ordered => 'Ordered';

  @override
  String get quoteMargins => 'Quote Margins';

  @override
  String get quotation => 'Quotation';

  @override
  String get quoted => 'Quoted';

  @override
  String get makeOrder => 'Convert to Order';

  @override
  String get generateQuote => 'Generate Quotation';

  @override
  String get edit => 'Edit';

  @override
  String get dublicate => 'Dublicate';

  @override
  String get noAssetsFound => 'No Assets found';

  @override
  String get addAsset => 'Add Asset';

  @override
  String get editAsset => 'Edit Asset';

  @override
  String get value => 'Value';

  @override
  String get imagesOptional => 'Images (Optional)';

  @override
  String get valueRequired => 'Value is required';

  @override
  String get dataNotLoading =>
      'Data didn\'t load properly, check connection and try again';

  @override
  String get noExpenseFound => 'No Expenses Found';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get editExpense => 'Edit Expense';

  @override
  String get imageCorrupted => 'Image corrupted, try uploading another version';

  @override
  String imageLimit4(Object count) {
    return 'You can only select up to 4 images. You already have $count image(s).';
  }

  @override
  String get errorRemovingImage => 'Error removing image';

  @override
  String get details => 'Details';

  @override
  String get apply => 'Apply';

  @override
  String get selectDateRange => 'Select Date Range';

  @override
  String get start => 'Start';

  @override
  String get end => 'End';

  @override
  String get newsUpdate => 'News Up§';

  @override
  String get featuredProducts => 'Featured Products';

  @override
  String get latestNews => 'Latest News';

  @override
  String get salesReport => 'Sales Report';

  @override
  String get selectDateInfo =>
      'Select the date range in which you would like to obtain the sales record for';

  @override
  String get reportGenSuccess => 'Report Generated Successfully';

  @override
  String get reportGenFailed => 'Report Generation Failed';

  @override
  String get date => 'Date';

  @override
  String get productCount => 'Product Count';

  @override
  String get from => 'From';

  @override
  String get to => 'to';

  @override
  String get totalSalesValue => 'Total Sales Value';

  @override
  String get summary => 'Summary';

  @override
  String get totalOrders => 'Total Orders';

  @override
  String get financialDetails => 'Financial Details';

  @override
  String get pandLReport => 'Profit and Loss Report';

  @override
  String get plVariables => 'P & L Variables';

  @override
  String get selectDatePL =>
      'Select the date range in which you need to show the profit and loss report';

  @override
  String get selectOptions => 'Select Options';

  @override
  String get optionsSummary => 'Options Summary';

  @override
  String get noOptionsSelected => 'No options selected';

  @override
  String get noPreviousRecordSaved => 'No previous records were saved';

  @override
  String get export => 'Export';

  @override
  String get dateRangeisCrucial =>
      'Date range is required, kindly select range before you can proceed';

  @override
  String get saveRecord => 'Save Record';

  @override
  String get plSummary => 'P & L Summary';

  @override
  String get profitLossStatement => 'Profit & Loss Statement';

  @override
  String get period => 'Period';

  @override
  String get totalRevenue => 'Total Revenue';

  @override
  String get operatingExpenses => 'Operating Expenses';

  @override
  String get operatingIncome => 'Operating Income';

  @override
  String get nonOperatingIncomeExpense => 'Non-Operating Income/Expenses';

  @override
  String get earningBeforeTax => 'Earnings Before Tax';

  @override
  String get taxDesc =>
      'Only set the tax that applies for you, if you leave the field empty then the tax won\'t be included in your financial records';

  @override
  String get incomeTax => 'Income Tax';

  @override
  String get salesTax => 'Sales Tax';

  @override
  String get stateTax => 'State Tax';

  @override
  String get governmentTax => 'Government Tax';

  @override
  String get netIncome => 'Net Income';

  @override
  String get detailedBreakDown => 'Detailed Breakdown';

  @override
  String get nonOperatingItems => 'Non Operating Items';

  @override
  String get investmentIncome => 'Investment Income';

  @override
  String get interestExpense => 'Interest Expense';

  @override
  String get foreignExchange => 'Foreign Exchange Gain/Loss';

  @override
  String get keyFinancialMetrics => 'Key Financial Metrics';

  @override
  String get grossProfitMargin => 'Gross Profit Margin';

  @override
  String get operatingMargin => 'Operating Margin';

  @override
  String get netProfitMargin => 'Net Profit Margin';

  @override
  String get percentageCogs => 'COGS % of Revenue';

  @override
  String get saveFinancialRecord =>
      'Would you like to save these data records for future use?';

  @override
  String get pandLStatement => 'P & L Statement';

  @override
  String get failedToRetrieveData => 'Failed to retrieve data';

  @override
  String get connectionLost => 'Connection Lost';

  @override
  String get checkYourConnection => 'Check your internet connection';

  @override
  String get topProducts => 'Top Items';

  @override
  String get soldQuantity => 'Sold Quantity';

  @override
  String get averagePrice => 'Average Price';

  @override
  String get subscribe => 'Subscribe';

  @override
  String get premiumUser => 'Premium';

  @override
  String get googlePlay => 'Google Play store';

  @override
  String get appleStore => 'Apple Store';

  @override
  String paymenetCharging(Object store) {
    return 'Payment will be charged to your (store) account at confirmation of purchase. Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period.';
  }

  @override
  String get privacyAndTerms => 'Privacy Policy';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get cont => 'Continue';

  @override
  String get popular => 'POPULAR';

  @override
  String get goPremium => 'Go Premium';

  @override
  String get unlockAll => 'Unlock all features and content';

  @override
  String get unlimitedAccess => 'Unlimited access to all content';

  @override
  String get exclusivePremium => 'Exclusive premium features';

  @override
  String get syncAll => 'Sync across all your devices';

  @override
  String get prioritySup => 'Priority support';

  @override
  String get subscribeOnMobile => 'Subscribe from our mobile app';

  @override
  String get subscribeOnMobileDesc =>
      'CostEra Premium subscriptions are currently available through our iOS and Android app. Subscribe there, and Premium unlocks here on the web automatically — no separate sign-up needed.';

  @override
  String get downloadForIOS => 'Download for iOS';

  @override
  String get downloadForAndroid => 'Download for Android';

  @override
  String get manageSubscriptionOnDevice =>
      'Manage your subscription from the App Store or Google Play on your device.';

  @override
  String get success => 'Success';

  @override
  String get processing => 'Processing...';

  @override
  String get welcomePre => 'Welcome to Premium!';

  @override
  String get startUsing => 'Start Using App';

  @override
  String get upgradeToUnlock => 'Upgrade to unlock this feature';

  @override
  String get viewSub => 'View Subscriptions';

  @override
  String get notNow => 'Not Now';

  @override
  String get sevenDayFree => '7-day FREE trial • Cancel anytime during trial';

  @override
  String get sevenDayDes =>
      'After the trial period, your subscription will automatically renew and you will be charged based on your selected plan.';

  @override
  String get enterCoupon => 'Enter Coupon Code';

  @override
  String get applyCoupon => 'Apply Coupon Code';

  @override
  String couponApplied(Object discount) {
    return 'Coupon applied: $discount% discount';
  }

  @override
  String get cancelSupscription => 'Cancel Supscription';

  @override
  String get cancelSubWarning =>
      'Are you sure you want to cancel your subscription and lose all the added features?';

  @override
  String freeTrialDays(Object days) {
    return '$days day free trial';
  }

  @override
  String get freeTrial => 'Free Trial';

  @override
  String get purchaseFailed => 'Purchase Failed';

  @override
  String get purchaseCancelled => 'Purchase Cancelled';

  @override
  String get invalidCoupon => 'Invalid or expired coupon code';

  @override
  String appliedCoupon(Object coupon) {
    return 'Coupon applied successfully! \$$coupon% discount';
  }

  @override
  String get totalToBePaid => 'Total to be charged';

  @override
  String get freeMonth => 'Free Month';

  @override
  String get freeYear => 'Free Year';

  @override
  String get selectPlan => 'Select Plan First';

  @override
  String get noOfferingsAvailable => 'No offerings available';

  @override
  String get selectedPlanNotAvailable => 'Selected plan is not available';

  @override
  String get purchaseInactive => 'Purchase is inactive';

  @override
  String get unableToLoadPlans => 'Unable to load plans, try again';

  @override
  String get premiumActive => 'Premium Active!';

  @override
  String get enjoyFreeTrial => 'You are currently enjoying your free trial';

  @override
  String get enjoyPremium => 'Welcome to CostEra Pro!';

  @override
  String get currentPlan => 'Current Plan';

  @override
  String get freeTrialActive => 'Free Trial Active';

  @override
  String get trialEndsOn => 'Trial ends on';

  @override
  String get memberSince => 'Member since';

  @override
  String get yourBenefits => 'Your Premium Benefits';

  @override
  String get generatePdfInvoice => 'PDF Invoices';

  @override
  String get createProfessionalInvoices =>
      'Create professional PDF invoices instantly';

  @override
  String get detailedFinancialInsights =>
      'Generate detailed financial reports and insights';

  @override
  String get expenseTracking => 'Expense Tracking';

  @override
  String get monitorAllExpenses =>
      'Monitor and categorize all your business expenses';

  @override
  String get unlimitedProducts => 'Unlimited Products';

  @override
  String get addUnlimitedItems =>
      'Add unlimited products and services to your catalog';

  @override
  String get cloudSync => 'Cloud Sync';

  @override
  String get syncAcrossDevices =>
      'Sync your data across all your devices securely';

  @override
  String get prioritySupport => 'Priority Support';

  @override
  String get createAndSendQuotes => 'Create and send professional quotes';

  @override
  String get suppliersAccess => 'Suppliers Access';

  @override
  String get manageYourSuppliers => 'Manage and track your suppliers';

  @override
  String get inventoryTracking => 'Inventory Tracking';

  @override
  String get trackStockInRealTime => 'Track stock levels in real time';

  @override
  String get orderReminders => 'Order & Payment Reminders';

  @override
  String get neverMissAPayment => 'Never miss a due date or payment';

  @override
  String get fasterCustomerSupport =>
      'Get faster responses from our support team';

  @override
  String get cancelSubscription => 'Cancel Subscription';

  @override
  String get cancelAnyTime => 'You can cancel your subscription at any time';

  @override
  String get loadingSubscription => 'Loading subscription info...';

  @override
  String get errorLoadingSubscription => 'Error loading subscription';

  @override
  String get cancelSubAtPeriodEnd =>
      'Your subscription will remain active until the end of your current billing period. You will continue to enjoy all premium benefits until then.';

  @override
  String get subscriptionWillCancel =>
      'Your subscription will be cancelled at the end of the current billing period.';

  @override
  String get accessUntil => 'Access until';

  @override
  String get renewsOn => 'Renews on';

  @override
  String get cancellationRequested => 'Cancellation requested on';

  @override
  String get subscriptionExpired => 'Subscription Expired';

  @override
  String get premiumBenefitsGone =>
      'Your premium benefits are no longer active. Please renew your subscription to continue enjoying all features.';

  @override
  String get daysLeft => 'days left for Premium';

  @override
  String get noActiveSubscription => 'No active subscription found';

  @override
  String get manageSubscriptionThrough =>
      'Please manage your subscription through';

  @override
  String get appStore => 'App store';

  @override
  String get resumeSubscription => 'Resume Subscription';

  @override
  String get resumeSubscriptionConfirm =>
      'Are you sure you want to resume your subscription? Your subscription will continue and auto-renew as normal.';

  @override
  String get resumeSubscriptionDesc =>
      'Continue your subscription and keep all benefits';

  @override
  String get resubscribe => 'Re-Subscribe';

  @override
  String get subscriptionResumed => 'Your subscription has been resumed!';

  @override
  String get cancellationPending =>
      'Your subscription cancellation is pending. You can resume it anytime before the end date.';

  @override
  String get failedToResume => 'Failed to resume';

  @override
  String get failedToCancel => 'Failed to cancel';

  @override
  String get then => 'Then';

  @override
  String get autoRenewal => 'Auto-Renewal Information';

  @override
  String autoRenewalDes(Object store) {
    return 'Your subscription will automatically renew at the end of each period unless cancelled at least 24 hours before the end of the current period. You can manage or cancel your subscription anytime through your $store account settings.';
  }

  @override
  String get daysFree => '-Day Free Trial';

  @override
  String subscriptionFeature(Object feature) {
    return 'The $feature is only available for paid user, consider subscribing to enjoy unlimited access';
  }

  @override
  String subscriptionOrderFeature(Object feature, Object number) {
    return 'You have reached the $feature limit for free users of $number orders, consider subscribing to enjoy unlimited access to all features and orders';
  }

  @override
  String get theFor => 'for';

  @override
  String get months => 'months';

  @override
  String get salesStats => 'Sales Statistics';

  @override
  String get sales => 'Sales';

  @override
  String get topClient => 'Top Client';

  @override
  String get totalSales => 'Total Sales';

  @override
  String get averageMargin => 'Average Margin';

  @override
  String get topFiveClients => 'Top 5 Clients';

  @override
  String get profitDist => 'Profit Margin Distribution';

  @override
  String get annual => 'Annual';

  @override
  String get monthly => 'Monthly';

  @override
  String get revenueSplit => 'Revenue Split';

  @override
  String get profit => 'Profit';

  @override
  String get viewAll => 'View All';

  @override
  String get dueSoon => 'Due Soon';

  @override
  String get onTrack => 'On Track';

  @override
  String get noUpcomingPayments => 'No Upcoming Payments';

  @override
  String get operationTimedOut =>
      'Operation timedout, check your connection and try again';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get thisWeek => 'This Week';

  @override
  String get lastWeek => 'Last Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get lastMonth => 'Last Month';

  @override
  String get thisYear => 'This Year';

  @override
  String get lastYear => 'Last Year';

  @override
  String get selectPeriod => 'Select Period';

  @override
  String get inventoryReport => 'Inventory Report';

  @override
  String get keepEmptyForAllLocations => 'Keep empty for all locations';

  @override
  String get storeName => 'Store Name';

  @override
  String get productStock => 'Stock';

  @override
  String get code => 'Code';

  @override
  String get tutorialCompleted => 'Tutorial Completed';

  @override
  String get tutOrderScreenDes =>
      'The order calender will keep track of your monthly orders';

  @override
  String get tutQuotesDes =>
      'The quotes allow you to create quotations for your clients before creating an order and invoicing';

  @override
  String get tutDashScreenDes =>
      'Our home button or dashboard will show your monthly progress';

  @override
  String get tutProductScreenDes =>
      'Here you can create, edit and adjust products. All your products can be accessed from this page';

  @override
  String get tutSettingScreeDes =>
      'The settings screen will provide all functionality for your app';

  @override
  String get next => 'Next';

  @override
  String get finish => 'Finish';

  @override
  String get tutorial => 'Tutorial';

  @override
  String get tutorialSkipped => 'Tutorial Skipped';

  @override
  String get startTutorial => 'Start Tutorial';

  @override
  String get skipTutorial => 'Skip Tutorial';

  @override
  String get tutorialWelcome => 'Welcome!';

  @override
  String get tutorialStartPrompt => 'Let us learn how to use the app';

  @override
  String get tutgalleryDes =>
      'All your product or service images can be uploaded here';

  @override
  String get tutProfileDes =>
      'Edit all your personal details from the profile section';

  @override
  String get tutAccountDes =>
      'Edit your business information from the account section';

  @override
  String get tutAppSettingDes =>
      'Modify the app settings from color, theme and more from here!';

  @override
  String get tutClientDes => 'Add and Edit your client details from here';

  @override
  String get tutOrdersDes =>
      'You can create and modify your order through the orders tab';

  @override
  String get tutSupplierDes =>
      'The Suppliers tab allows you to add suppliers and issue purchases';

  @override
  String get tutPurchasesDes =>
      'The Purchase tab will allow you to issue and edit purchases';

  @override
  String get tutCapExpReportDes =>
      'The Capital and Expenses tab is essential for controlling your expenses';

  @override
  String get tutFinancialReportDes =>
      'Monitor your business and know how you\'re doing by issuing the required reports';

  @override
  String get tutFilterOptionDes =>
      'The filter option will allow you to search for a specific item or filter by several variables';

  @override
  String get tutAddProductDes =>
      'The add button will allow you to add product or services!';

  @override
  String get tutPaymentDes => 'Will show all credit payments for your clients';

  @override
  String get days15 => '15 days';

  @override
  String get days30 => '30 days';

  @override
  String get days45 => '45 days';

  @override
  String get more => 'More';

  @override
  String get all => 'All';

  @override
  String get dueOn => 'Due On';

  @override
  String get addPayment => 'Add Payment';

  @override
  String get editPayment => 'Edit Payment';

  @override
  String get upcomingPayments => 'Upcoming Payments';

  @override
  String get updatePayment => 'Update Payment';

  @override
  String partialPayment(Object amount) {
    return 'The payment doesn\'t cover the required amount, remaining balance of $amount will remain pending';
  }

  @override
  String paymentOverpaid(Object amount) {
    return 'The payment exceeds the required balance, the additional amount of $amount will be added to the client as credit';
  }

  @override
  String get paymentCovered =>
      'Payment is fully covered and the credit invoice shall be closed accordingly';

  @override
  String get clientStatement => 'Client Statement';

  @override
  String get method => 'Payment method';

  @override
  String get optional => 'Optional';

  @override
  String get faq => 'Frequently Asked Questions';

  @override
  String get question => 'Question';

  @override
  String get answer => 'Answer';

  @override
  String get referenceOrder => 'Order Reference';

  @override
  String get questionEmpty => 'Question List is Empty';

  @override
  String get questionIsEmpty => 'Question cannot be empty';

  @override
  String get answerIsEmpty => 'Answer cannot be empty';

  @override
  String get referenceIsEmpty => 'Reference cannot be empty';

  @override
  String get referenceOrderExits =>
      'Reference order already exists, select another one';
}
