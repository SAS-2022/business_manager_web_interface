class ErrorClass {
  String userNoTFoundError({String? e}) {
    return 'User details missing, check your connection and try again\n\nError: $e';
  }

  //Business type missing
  String businessTypeMissing() {
    return 'Business types missing, check your connection and try again';
  }

  //Business category missing
  String businessCategoryMissing() {
    return 'Business category missing, check you connection and try again';
  }

  //Product Errors
  //Product not found
  String productNotFound({String? e}) {
    if (e != null && e.isEmpty) {
      return 'Product not found, check your connection and try again\n\nError: $e';
    }
    return 'Product not found, check your connection and try again';
  }

  //Product data is not loading
  String productNotLoading() {
    return 'Product not loading, check your connection and try again';
  }

  String productRecordNotFound({String? e}) {
    return 'Product record not found, check your connection\n\n$e';
  }

  //Products not loading
  String productsNotLoading() {
    return 'Products not loading, check your connection and try again';
  }

  //Image Gallery Errors
  //Images not loading
  String imagesNotLoading() {
    return 'Images not loading, check your connection and try again';
  }

  //Recipe errors
  //Receipes not loading
  String receipesNotLoading(String e) {
    return 'Receipes not loading, check your connection and try again\n$e';
  }

  //Receipt cost issue
  String receipesCostFailed() {
    return 'Receipes cost not loading, try again later';
  }

  //Raw material Errors
  //Raw material missing or not loading
  String rawMaterialNotLoading() {
    return 'Raw materials not loading, check your connection and try again';
  }

  //Raw material not added
  String rawMaterialNotAdded() {
    return 'Raw material not added, check your connection and try again';
  }

  //Clients not loading
  String clientsNotLoading() {
    return 'Clients could not be loaded, please check your connectiong and try again';
  }

  //Client can't be loaded
  String clientNotLoading() {
    return 'Client could not be loaded, please check your connection and try again';
  }

  //Orders can't be loaded
  String ordersNotLoading() {
    return 'Orders could not be loaded, please check your connection and try again';
  }

  //quotes can't be loaded
  String quotesNotLoading(String e) {
    return 'Quotes could not be loaded, please check your connection and try again\n$e';
  }

  //Total value can't be loaded
  String totalValueNotLoading() {
    return 'Error loading total value';
  }

  //Error for news data
  String newsDataError(String e) {
    return 'Error loading news, try again later or check your connection\n\nError: $e';
  }

  //Assets
  String assetsNotLoading(String e) {
    return """Error assets not loading.\n\n$e """;
  }

  //Expenses
  String expensesNotLoading(String e) {
    return """Error expenses not loading.\n\n$e """;
  }

  //Connection issue
  String connectionError(String e) {
    return """There seems to be an issue, check your connection and try again!\n$e""";
  }

  //Failed to generate id
  String failedToGenerateId(String e) {
    return 'Failed to generate id, check you connection and try again\n\nError: $e';
  }

  //Failed to generate records data
  String failedToGetRecords(String e) {
    return 'Failed to generate product records, check connection and try again\n\nError: $e';
  }

  //Unable to obtain invoices settings
  String unableToGetInvoiceSettings(String e) {
    return 'Unable to get invoice settings, check you connection and try again\n\nError: $e';
  }

  //Unable to obtain General settings
  String unableToGetGeneralSettings(String e) {
    return 'Unable to get general settings, check you connection and try again\n\nError: $e';
  }

  //Unable to obtain General settings
  String chartStatNotFound(String e) {
    return 'Unable to sales statistics, check you connection and try again\n\nError: $e';
  }

  //Unable to delete account
  String accountDeletionFailed(String e) {
    return 'Account deletion failed, check your connection if the problem persists contact our service team:\n$e';
  }

  //Purchase Not Loading
  String purchaseNotLoading(String e) {
    return 'Purchase not loading, check your connection if the problem persists contact our service team:\n$e';
  }

  //supplier Not Loading
  String supplierNotLoading(String e) {
    return 'Supplier not loading, check your connection if the problem persists contact our service team:\n$e';
  }

  //Error getting report data Not Loading
  String reportDataFailed(String e) {
    return 'Your report data could not be generated, check your connection if the problem persists contact our service team:\n$e';
  }

  //Error confirming terms
  String confirmingTermsFailed({String? e}) {
    return 'There was an error confirming your acceptance of our terms and conditions, please check your connection and try again.\n\nError: $e';
  }

  String noCategoriesFounds({String? e}) {
    return 'No categories found, check your connection and try again\n\nError: $e';
  }

  String questionNotLoading({String? e}) {
    return 'No questions were found, check your connection and try again\n\nError: $e';
  }

  String paymentsNotLoading({String? e}) {
    return 'No payments were found, check your connection and try again\n\nError: $e';
  }
}
