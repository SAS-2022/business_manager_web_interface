// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'CostEra';

  @override
  String get register => 'Registrarse';

  @override
  String get firstName => 'Nombre';

  @override
  String get lastName => 'Apellido';

  @override
  String get emailAddress => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get confirmPass => 'Confirmar contraseña';

  @override
  String get notEmpty => 'No debe estar vacío';

  @override
  String get emailValidation => 'El correo electrónico no es válido';

  @override
  String get shortPassword => 'mín. 8 caracteres';

  @override
  String get needNumber => 'al menos un número';

  @override
  String get needSpCharacter => 'al menos un carácter especial \$ # @ ...etc';

  @override
  String get firstNameRequired => 'El nombre es obligatorio';

  @override
  String get lastNameRequired => 'El apellido es obligatorio';

  @override
  String get emailAddressRequired => 'El correo electrónico es obligatorio';

  @override
  String get passwordRequired => 'La contraseña es obligatoria';

  @override
  String get confirmpasswordRequired =>
      'Confirmar la contraseña es obligatorio';

  @override
  String get passwordNoMatcH => 'Las contraseñas no coinciden';

  @override
  String get connectionError =>
      'Error de conexión, inténtelo de nuevo más tarde';

  @override
  String get createYourAccount => 'Crea tu cuenta';

  @override
  String get personalInfo => 'Información personal';

  @override
  String get accountInfo => 'Información de la cuenta';

  @override
  String get alreadyHaveAccount => '¿Ya tiene una cuenta?';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get forgotPass => 'Olvidé mi contraseña';

  @override
  String get reset => 'Restablecer';

  @override
  String get googleSignIn => 'Google';

  @override
  String get appleSignIn => 'Apple';

  @override
  String get verifyEmail =>
      'Verifique su correo electrónico para poder continuar';

  @override
  String get verifyYourEmail => 'Verifique su correo electrónico';

  @override
  String get verificationLinkSentTo =>
      'Hemos enviado un enlace de verificación a';

  @override
  String get verifyEmailBody =>
      'Abra el correo y toque el enlace para verificar su cuenta. No olvide revisar la carpeta de spam o correo no deseado.';

  @override
  String get resendEmail => 'Reenviar correo';

  @override
  String resendEmailIn(Object seconds) {
    return 'Podrá reenviar en ${seconds}s';
  }

  @override
  String get verificationEmailResent => 'Correo de verificación reenviado';

  @override
  String get emailVerifiedSuccess =>
      '¡Correo verificado! Inicie sesión para continuar';

  @override
  String get wrongEmail => '¿Correo incorrecto?';

  @override
  String get waitingForVerification => 'Esperando verificación...';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get profile => 'Perfil';

  @override
  String get account => 'Cuenta';

  @override
  String get appSettings => 'Configuración de la app';

  @override
  String get buildNumber => 'Número de compilación';

  @override
  String get currency => 'Moneda';

  @override
  String get businessAddress => 'Dirección del negocio';

  @override
  String get assignedCurrency => 'Moneda asignada';

  @override
  String get userNotFound => 'Usuario no encontrado';

  @override
  String get receipies => 'Recetas';

  @override
  String get selectCurrency => 'Seleccionar moneda';

  @override
  String get emailNotVerified => 'Correo no verificado';

  @override
  String get changeCurrency => 'Cambiar moneda';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get accountDeletionMessage =>
      '¿Está seguro de que desea eliminar su cuenta?\nMantendremos sus datos en nuestro servidor hasta por 30 días antes de eliminar permanentemente todo su contenido.\nLamentamos verlo partir y esperamos volver a verlo pronto.';

  @override
  String get accountDeletionSuccess =>
      'Su cuenta se eliminó correctamente, tiene 30 días por si decide cambiar de opinión.';

  @override
  String get contactUs => 'Contáctenos';

  @override
  String get rateUs => 'Califíquenos';

  @override
  String get messageContent => 'Contenido del mensaje';

  @override
  String get send => 'Enviar';

  @override
  String get subject => 'Asunto';

  @override
  String get technical => 'Técnico';

  @override
  String get complaint => 'Queja';

  @override
  String get suggestion => 'Sugerencia';

  @override
  String get messageCannotBeEmpty =>
      'El contenido del mensaje no puede estar vacío';

  @override
  String get selectSubject => 'Seleccione el asunto del mensaje';

  @override
  String get longPressToRemove => 'Mantenga presionado para eliminar';

  @override
  String get personalInformation => 'Información del perfil';

  @override
  String get contactInformation => 'Información de contacto';

  @override
  String get accountInformation => 'Información de la cuenta';

  @override
  String get profileUpdatedSuccessfully => 'Perfil actualizado correctamente';

  @override
  String get messageSentSuccessfully =>
      'El mensaje se ha enviado correctamente, nuestro equipo se pondrá en contacto en breve.';

  @override
  String get thankYouForReachingOut =>
      'Gracias por contactarnos, procuramos resolver el problema en un plazo de 48 horas.';

  @override
  String get screenShots =>
      'Adjunte capturas de pantalla de cualquier problema que haya encontrado';

  @override
  String get manageYourBusiness => 'Administre su negocio';

  @override
  String get sigIn => 'Iniciar sesión';

  @override
  String get or => 'O';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get dontHaveAccount => '¿No tiene una cuenta?';

  @override
  String get orContinueWith => 'o continuar con';

  @override
  String get resetIt => 'Restablecerla';

  @override
  String get senderDetails => 'Sus datos';

  @override
  String get forgotPassSubtitle =>
      'Ingrese su correo electrónico y le enviaremos un enlace de restablecimiento';

  @override
  String get resetPassword => 'Restablecer contraseña';

  @override
  String get resetEmailSent =>
      'Correo de restablecimiento enviado. Revise su bandeja de entrada.';

  @override
  String get invoiceSettings => 'Configuración de facturas';

  @override
  String get invoiceSettingExplained =>
      'Ajuste el contenido de su factura activando o desactivando funciones';

  @override
  String get on => 'Activado';

  @override
  String get off => 'Desactivado';

  @override
  String get companyFinancialDetaiils => 'Mis datos financieros';

  @override
  String get clientCrNumber => 'Número de registro comercial del cliente';

  @override
  String get clientBankDetail => 'Datos bancarios del cliente';

  @override
  String get clientFinancialDetails => 'Número financiero del cliente';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get exitConfirmation =>
      'Tiene cambios sin guardar, ¿está seguro de que desea salir?';

  @override
  String get generalSettings => 'Configuración general';

  @override
  String get generalSettingsExplained =>
      'Cambie la configuración de la app según sus necesidades';

  @override
  String get assignedLanguage => 'Idioma asignado';

  @override
  String get assignedTheme => 'Tema asignado';

  @override
  String get inventoryInfo =>
      'El inventario le permitirá crear hasta 10 ubicaciones para almacenar sus productos';

  @override
  String get inventory => 'Inventario';

  @override
  String get selectNewStore => 'Seleccionar una nueva tienda';

  @override
  String get inventoryLocation => 'Ubicación del inventario';

  @override
  String get financialSettings => 'Configuración financiera';

  @override
  String get financialSettingsDesc =>
      'La configuración financiera le permitirá establecer variables estándar relacionadas con su estado financiero';

  @override
  String get defaultSalesOrderTerms =>
      'Establezca sus términos predeterminados de entrega, devolución y reembolso para sus pedidos de venta';

  @override
  String get defaultPurchaseTerms =>
      'Establezca sus términos predeterminados de entrega, devolución y reembolso para sus órdenes de compra';

  @override
  String get reactivate => 'Reactivar';

  @override
  String get status => 'Estado';

  @override
  String get restartApp => 'Reiniciar app';

  @override
  String get restartAppLangInfo =>
      'Para cambiar el idioma debe reiniciar la app, ¿está seguro de que desea continuar?';

  @override
  String get restartAppThemeInfo =>
      'Para cambiar el tema debe reiniciar la app, ¿está seguro de que desea continuar?';

  @override
  String get inventoryController => 'Controlador de inventario';

  @override
  String get inventoryIntro =>
      'La opción de inventario le permitirá crear ubicaciones en las que puede almacenar productos. Tenga en cuenta que al activar el inventario su pedido quedará directamente vinculado y no podrá procesarlo si no tiene existencias.';

  @override
  String get activateInventory => 'Activar inventario';

  @override
  String get locationName => 'Nombre de la ubicación';

  @override
  String get inventoryLocationLimit =>
      'Ha alcanzado el máximo de ubicaciones de inventario permitidas';

  @override
  String get inventoryValue => 'Valor del inventario';

  @override
  String get inventoryInActive => 'Inventario inactivo';

  @override
  String get doActivateInventory => '¿Desea activar la opción de inventario?';

  @override
  String get locationNameEmpty =>
      'El nombre de la ubicación está vacío, corríjalo para continuar';

  @override
  String get purchaseOrder => 'Órdenes de compra';

  @override
  String get purchaseInfo =>
      'La función de compras le permite crear órdenes de compra para su proveedor, lo que actualizará el costo de su producto automáticamente si así lo elige';

  @override
  String get purchaseSettings => 'Configuración de compras';

  @override
  String get activatePurchases => 'Activar compras';

  @override
  String get updateProductCost => 'Actualizar costo del producto';

  @override
  String get purchases => 'Compras';

  @override
  String get addPurchase => 'Agregar compra';

  @override
  String get editPurchase => 'Editar compra';

  @override
  String get noSupplierFound => 'No se encontró proveedor';

  @override
  String get supplierName => 'Nombre del proveedor';

  @override
  String get supplierNameEmpty => 'El nombre del proveedor está vacío';

  @override
  String get supplierNameInvalid => 'El nombre del proveedor no es válido';

  @override
  String get purchaseTerms => 'Términos de compra';

  @override
  String get generatePO => 'Generar orden de compra';

  @override
  String get generatePoInfo =>
      'Una vez generada la orden de compra, ya no podrá editarla ni modificarla. Si necesita cancelarla, puede eliminar la orden y crear una nueva';

  @override
  String get receivingPO => 'Recepción de orden de compra';

  @override
  String get receive => 'Recibir';

  @override
  String get receiveInfo =>
      'Esto le permitirá confirmar si la orden de compra ha sido recibida, o modificar la cantidad recibida';

  @override
  String get materialAlreadyReceived =>
      'El material de esta orden de compra ya ha sido recibido';

  @override
  String get receiveMaterial => 'Recibir material';

  @override
  String get remove => 'Eliminar';

  @override
  String get storeNotAssigned => 'No se ha asignado una tienda';

  @override
  String storeNotExisting(Object product, Object store) {
    return 'La tienda seleccionada $store no existe para el producto $product';
  }

  @override
  String get purchaseOrderGenerationComplete =>
      'Generación de orden de compra completada';

  @override
  String get generated => 'Generada';

  @override
  String get received => 'Recibido';

  @override
  String get revertingBackNotPossible =>
      'Tenga en cuenta que revertir al costo anterior del artículo no es posible por el momento, hágalo manualmente';

  @override
  String get suppliers => 'Proveedores';

  @override
  String get addSupplier => 'Agregar proveedor';

  @override
  String get editSupplier => 'Editar proveedor';

  @override
  String get supplierOrders => 'Órdenes de proveedor';

  @override
  String get home => 'Inicio';

  @override
  String get product => 'Artículos';

  @override
  String get settings => 'Configuración';

  @override
  String get menu => 'Menú';

  @override
  String get orders => 'Pedidos';

  @override
  String get payments => 'Pagos';

  @override
  String get businessType => 'Tipo de negocio';

  @override
  String get businessCategory => 'Categoría del negocio';

  @override
  String get businessTypeDes =>
      'Seleccione el tipo de negocio que mejor describa su negocio, tenga en cuenta que afectará cómo se calculará el costo del producto';

  @override
  String get businessCategoryDes =>
      'Seleccione la categoría del negocio si está disponible, u otros si no lo está; la revisaremos y trataremos de agregarla en el futuro';

  @override
  String get businessTypeNotDefined =>
      'El tipo de negocio parece no estar definido, revise su cuenta y asigne un tipo de negocio';

  @override
  String get missingCategory => 'Debe seleccionar una categoría';

  @override
  String get missingType => 'Debe seleccionar un tipo';

  @override
  String get fillManualCategory => 'Complete la categoría de su negocio';

  @override
  String get select => 'Seleccionar';

  @override
  String get update => 'Actualizar';

  @override
  String get companyInfo => 'Información de la empresa';

  @override
  String get companyName => 'Nombre de la empresa';

  @override
  String get companyLogo => 'Logo de la empresa';

  @override
  String get save => 'Guardar';

  @override
  String get companyLogoMissing => 'Falta el logo de la empresa';

  @override
  String get dataSaveSuccessfully => 'Datos guardados correctamente';

  @override
  String get failedToSaveData => 'Error al guardar los datos';

  @override
  String get imageRemovedSuccessfully => 'Imagen eliminada correctamente';

  @override
  String get failedToRemoveImage => 'Error al eliminar la imagen';

  @override
  String get currencyDes =>
      'Seleccione la moneda con la que desea operar su negocio, esto se puede cambiar más adelante';

  @override
  String get locationDes =>
      'Seleccione la ubicación desde la cual operará su negocio, esto se puede cambiar más adelante';

  @override
  String get noApiKeyDetected =>
      'No se ha detectado ninguna clave de API, comuníquese con soporte';

  @override
  String get viewMore => 'Ver más';

  @override
  String get locationChoice => '¿Desea otorgar a la app acceso a su ubicación?';

  @override
  String get skip => 'Omitir';

  @override
  String get dataRefereshedSuccessfully => 'Datos actualizados correctamente';

  @override
  String get dataFailedToRefresh => 'Error al actualizar los datos';

  @override
  String get businessTypeSubDes =>
      'Esto nos ayuda a personalizar su experiencia.';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get stepOneOfTwo => 'Paso 1 de 2';

  @override
  String get currencySubDes =>
      'Se usa en todas las facturas, pedidos e informes.';

  @override
  String get stepTwoOfTwo => 'Paso 2 de 2';

  @override
  String get finishSetup => 'Finalizar configuración';

  @override
  String get addressNotRegistered => 'La dirección no ha sido registrada';

  @override
  String get noLocationSelected => 'Ninguna ubicación seleccionada';

  @override
  String get selectLocation => 'Seleccionar ubicación';

  @override
  String get locServiceDisabled => 'Servicio de ubicación deshabilitado';

  @override
  String get locServiceDenied => 'Servicio de ubicación denegado';

  @override
  String get locServiceDeniedForever =>
      'Los permisos de ubicación han sido denegados permanentemente. Si desea establecer su ubicación, debe ir a la configuración de su dispositivo y habilitarlos desde allí.';

  @override
  String get locationPermissionDenied =>
      'El permiso de ubicación ha sido denegado';

  @override
  String get locationPermissionPermanentlyDenied =>
      'El permiso de ubicación ha sido denegado permanentemente';

  @override
  String get locationServicesDisabled =>
      'Los servicios de ubicación han sido deshabilitados';

  @override
  String get networkError => 'Error de red, inténtelo de nuevo';

  @override
  String get configurationError => 'Error de configuración, inténtelo de nuevo';

  @override
  String get somethingWentWrong => 'Algo salió mal, comuníquese con soporte';

  @override
  String get openSettings => 'Abrir configuración';

  @override
  String get retry => 'Reintentar';

  @override
  String get addProduct => 'Agregar artículo';

  @override
  String get editProduct => 'Editar artículo';

  @override
  String get productName => 'Nombre del artículo';

  @override
  String get itemCode => 'Código del artículo';

  @override
  String get productDescription => 'Descripción del artículo';

  @override
  String get productPacking => 'Empaque del artículo (ejemplo kg, uds...)';

  @override
  String get productCost => 'Costo del artículo';

  @override
  String get productCostService => 'Costo del artículo (opcional)';

  @override
  String get productPrice => 'Precio de venta del artículo';

  @override
  String get images => 'Imágenes';

  @override
  String get files => 'Archivos';

  @override
  String get noImages => 'No se encontraron imágenes';

  @override
  String get productNameEmpty => 'El nombre del artículo no puede estar vacío';

  @override
  String get productCostEmpty =>
      'Se necesita el costo del artículo, ingrese 0 si no desea agregar costo';

  @override
  String get productPriceEmpty =>
      'El artículo debe tener un precio, ingrese 0 para artículos gratuitos';

  @override
  String get productImageEmpty => 'Todo artículo debe tener al menos 1 imagen';

  @override
  String get noProductsAdded => 'No se agregaron artículos';

  @override
  String get productCostError =>
      'Verifique si su categoría de negocio está seleccionada';

  @override
  String get addCost => 'Agregar costo';

  @override
  String get editCost => 'Editar costo';

  @override
  String get saveProductFirst =>
      'Guarde el artículo primero, luego podrá agregar su costo';

  @override
  String get costValue => 'Valor del costo';

  @override
  String get error => 'Error';

  @override
  String get noProductFound => 'No se encontraron artículos';

  @override
  String get productCategory => 'Categoría del artículo (opcional)';

  @override
  String get productCategoryHint =>
      'Escriba cualquier categoría, se creará después de agregar un producto';

  @override
  String get id => 'ID';

  @override
  String get filterOptions => 'Opciones de filtro';

  @override
  String get filterProducts => 'Filtrar artículos';

  @override
  String get searchProducts => 'Buscar artículos';

  @override
  String get priceRange => 'Rango de precio';

  @override
  String get minPrice => 'Precio mínimo';

  @override
  String get maxPrice => 'Precio máximo';

  @override
  String get applyFilter => 'Aplicar filtro';

  @override
  String get productCodeExists => 'El código del artículo ya existe';

  @override
  String get itemCodeEmpty => 'El código del artículo no puede estar vacío';

  @override
  String get noCategoriesFound => 'No se encontraron categorías';

  @override
  String get productRecords => 'Registros de artículos';

  @override
  String get productsLimit =>
      'Parece que ha alcanzado el límite de productos de nuestra versión gratuita, suscríbase a nuestro plan de pago para disfrutar de un número ilimitado de productos';

  @override
  String get orderLimit =>
      'Parece que ha alcanzado el límite de pedidos de nuestra versión gratuita, suscríbase a nuestro plan de pago para disfrutar de un número ilimitado de pedidos';

  @override
  String get category => 'Categoría';

  @override
  String get subscribeToAccessInventory =>
      'Suscríbase para acceder al inventario';

  @override
  String get basicInfo => 'Información básica';

  @override
  String get auto => 'Automático';

  @override
  String get packaging => 'Empaque';

  @override
  String get pricing => 'Precios';

  @override
  String get profitMargin => 'Margen de ganancia';

  @override
  String get noItemRecordFound => 'No se encontró registro de artículo';

  @override
  String get clearFilter => 'Borrar filtro';

  @override
  String get receipes => 'Recetas';

  @override
  String get addReceipe => 'Agregar receta';

  @override
  String get editRecipe => 'Editar receta';

  @override
  String get noReceipesFound => 'No se encontraron recetas';

  @override
  String get receipeName => 'Nombre de la receta';

  @override
  String get receipeDescription => 'Descripción de la receta';

  @override
  String get receipePacking => 'Empaque de la receta';

  @override
  String get receipeIngredients => 'Ingredientes de la receta';

  @override
  String get cost => 'Costo';

  @override
  String get pack => 'Empaque';

  @override
  String get packService => 'Paquete o sesiones';

  @override
  String get quantity => 'Cant.';

  @override
  String get suggestions => 'Sugerencias';

  @override
  String get unit => 'Unidad';

  @override
  String get selectedIngredientFirst =>
      'Debe seleccionar un ingrediente primero';

  @override
  String get add => 'Agregar';

  @override
  String get totalCost => 'Costo total';

  @override
  String get packingUnit => 'Unidad';

  @override
  String get receipeNameRequired => 'El nombre de la receta es obligatorio';

  @override
  String get receipePackingRequired =>
      'El valor de empaque de la receta es obligatorio';

  @override
  String get receipePackingUnitRequired =>
      'La unidad de empaque de la receta es obligatoria';

  @override
  String get ingredientsMissing =>
      'Cada receta debe tener al menos un ingrediente';

  @override
  String get tapReceipeToAdd => 'Toque la receta para agregarla al producto';

  @override
  String get recipeDetails => 'Detalles de la receta';

  @override
  String get outputPacking => 'Empaque de salida';

  @override
  String get rawMaterial => 'Materia prima';

  @override
  String get noRawMaterialsFound => 'No se encontró materia prima';

  @override
  String get rawMaterialAdd => 'Agregar nueva';

  @override
  String get rawMaterialEdit => 'Editar actual';

  @override
  String get name => 'Nombre';

  @override
  String get description => 'Descripción';

  @override
  String get nameRequired => 'El nombre es obligatorio';

  @override
  String get quantityRequired => 'La cantidad es obligatoria';

  @override
  String get unitRequired => 'La unidad es obligatoria';

  @override
  String get costRequired => 'El costo es obligatorio';

  @override
  String get quantityAndUnit => 'Cantidad y unidad';

  @override
  String get conversionRates => 'Tasas de conversión';

  @override
  String get gallery => 'Galería';

  @override
  String get camera => 'Cámara';

  @override
  String get addImage => 'Agregar imagen';

  @override
  String get editImage => 'Editar imagen';

  @override
  String get search => 'Buscar';

  @override
  String get imageSelectionError =>
      'Error al intentar seleccionar la imagen, vuelva a intentarlo';

  @override
  String get imageNotSelected => 'Error al seleccionar la imagen';

  @override
  String get cameraPermissionDenied =>
      'Se ha denegado el permiso de acceso a la cámara';

  @override
  String get mediaPermissionDenied =>
      'Se ha denegado el permiso de acceso a los medios';

  @override
  String get failedToUploadImage => 'Error al subir la imagen';

  @override
  String get failedToUploadVideo => 'Error al subir el video';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteConfirmation => '¿Está seguro de que desea eliminar?';

  @override
  String deleteConfirmationWithCount(Object number) {
    return '¿Está seguro de que desea eliminar estos $number elementos?';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get active => 'Activo';

  @override
  String get discard => 'Descartar';

  @override
  String get cancelConfirmation =>
      '¿Está seguro de que desea cancelar este pedido?';

  @override
  String get warning => 'Advertencia';

  @override
  String get ok => 'Aceptar';

  @override
  String get restore => 'Restaurar';

  @override
  String get restoreConfirmation =>
      '¿Está seguro de que desea restaurar este pedido?';

  @override
  String imagesDeleted(Object number) {
    return 'Ha eliminado $number imágenes';
  }

  @override
  String get failedToDeleteImages => 'Error al eliminar la imagen seleccionada';

  @override
  String get selected => 'Seleccionado';

  @override
  String get changingTypeNotPossible =>
      'Ya no puede cambiar el tipo de negocio porque ya ha agregado productos';

  @override
  String get doubleToAdd =>
      'Haga doble clic en la imagen para vincularla a un producto';

  @override
  String get client => 'Cliente';

  @override
  String get clients => 'Clientes';

  @override
  String get addClient => 'Agregar cliente';

  @override
  String get editClient => 'Editar cliente';

  @override
  String get noClientsFound => 'No se encontraron clientes';

  @override
  String get individual => 'Individual';

  @override
  String get company => 'Empresa';

  @override
  String get phoneNumber => 'Número de teléfono';

  @override
  String get clientNameEmpty => 'El nombre del cliente no puede estar vacío';

  @override
  String get clientNameInvalid => 'El nombre del cliente no es válido';

  @override
  String get companyNameEmpty =>
      'El nombre de la empresa no puede estar vacío, vaya a Configuración -> Cuenta y establezca el nombre de su empresa';

  @override
  String get phoneNumberEmpty =>
      'El número de teléfono no puede estar vacío, vaya a Configuración -> Cuenta y establezca el logo de su empresa';

  @override
  String get phoneCodeEmpty => 'Debe seleccionar el código telefónico';

  @override
  String get clientName => 'Nombre del cliente';

  @override
  String get clientOrders => 'Pedidos del cliente';

  @override
  String get clientCompanyName =>
      'El nombre de la empresa del cliente no puede estar vacío';

  @override
  String get financialNumber => 'Número financiero';

  @override
  String get crNumber => 'Número de registro comercial';

  @override
  String get ibanNumber => 'Número IBAN';

  @override
  String get bankName => 'Nombre del banco';

  @override
  String get bankBranch => 'Sucursal bancaria';

  @override
  String get otherPayment => 'Otro método de pago';

  @override
  String get order => 'Pedido';

  @override
  String get due => 'Vencimiento';

  @override
  String get overDue => 'Vencido';

  @override
  String get clientType => 'Tipo de cliente';

  @override
  String get contactInfo => 'Contacto';

  @override
  String get officialData => 'Datos oficiales';

  @override
  String get reports => 'Informes';

  @override
  String get capitalAndExpenses => 'Capital y gastos';

  @override
  String get financialReports => 'Informes financieros';

  @override
  String get expenses => 'Gastos';

  @override
  String get fixedCosts => 'Costos fijos';

  @override
  String get assets => 'Activos';

  @override
  String get costs => 'Costos';

  @override
  String get noOrdersFound => 'No se encontraron pedidos';

  @override
  String get addOrder => 'Agregar pedido';

  @override
  String get editOrder => 'Editar pedido';

  @override
  String get itemQuantity => 'Cantidad';

  @override
  String get discount => 'Descuento';

  @override
  String get price => 'Precio';

  @override
  String get discountedPrice => 'Precio con desc.';

  @override
  String get quantityCannotBeEmpty => 'La cantidad no puede estar vacía';

  @override
  String get priceCannotBeEmpty => 'El precio no puede estar vacío';

  @override
  String get cannotPerformDiscountOnAddedPrice =>
      'No puede aplicar un descuento sobre un aumento de precio';

  @override
  String get totalValue => 'Valor total';

  @override
  String get productListEmpty => 'La lista de productos no puede estar vacía';

  @override
  String get orderTerms => 'Términos del pedido';

  @override
  String get deliveryTerms => 'Términos de entrega';

  @override
  String get deliveryTime => 'Tiempo de entrega';

  @override
  String get immediate => 'Inmediata';

  @override
  String get scheduled => 'Programada';

  @override
  String get selectTime => 'Seleccionar hora';

  @override
  String get selectTimeFirst => 'Seleccione la hora primero';

  @override
  String get selectDate => 'Seleccionar fecha';

  @override
  String get selectDateFirst => 'Seleccione la fecha primero';

  @override
  String get immediateDelivery =>
      'El pedido se configurará para entrega inmediata';

  @override
  String get noOrderFound => 'No se encontró ningún pedido';

  @override
  String get invoice => 'Factura';

  @override
  String get number => 'Número';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get total => 'Total';

  @override
  String get paymentTerms => 'Términos de pago';

  @override
  String get termsandConditions => 'Términos y condiciones';

  @override
  String termsandConditionDesc(Object provider) {
    return 'Todo usuario debe aceptar los términos de $provider antes de continuar';
  }

  @override
  String get apple => 'Apple';

  @override
  String get google => 'Google';

  @override
  String get viewFullTerms =>
      'Puede ver los términos completos haciendo clic en el siguiente enlace';

  @override
  String get agreeToTerms => 'Aceptar términos';

  @override
  String termsSummaryDetails(Object provider) {
    return 'Las suscripciones se renuevan automáticamente a menos que se cancelen al menos 24 horas antes de la renovación, y todas las compras están sujetas a las políticas de $provider.';
  }

  @override
  String get iHaveReadAndAgree =>
      'He leído y acepto los Términos y Condiciones';

  @override
  String get readFullTerms => 'Leer términos completos';

  @override
  String get needToAgreeToTerms =>
      'Debe marcar y confirmar los términos y condiciones de la app';

  @override
  String get ref => 'Ref';

  @override
  String get invoiceNumber => 'Número de factura';

  @override
  String get invoiceGenCompleted => 'Generación de factura completada';

  @override
  String get invoiceGenFailed =>
      'Error al generar la factura, inténtelo de nuevo';

  @override
  String get returnTerms => 'Devolución/reembolso';

  @override
  String get returnTermsService => 'Reembolso o cancelación';

  @override
  String get close => 'Cerrar';

  @override
  String get unsavedData =>
      'Tiene datos sin guardar, guárdelos antes de cerrar';

  @override
  String get returns => 'Devoluciones';

  @override
  String get clientDetails => 'Detalles del cliente';

  @override
  String get billTo => 'Facturar a';

  @override
  String get scheduledOrder => 'Este pedido está programado para el';

  @override
  String get scheduledDate => 'Fecha programada';

  @override
  String get scheduledTime => 'Hora programada';

  @override
  String get orderId => 'ID del pedido';

  @override
  String get invoiced => 'Facturado';

  @override
  String get generateInvoice => 'Generar factura';

  @override
  String get generateInvoiceInfo =>
      'Una vez generada la factura, ya no podrá editar ni modificar su pedido. Si necesita cancelarlo, puede eliminar el pedido y crear uno nuevo';

  @override
  String get generate => 'Generar';

  @override
  String get regenerate => 'Regenerar';

  @override
  String get orderPlacedAt => 'Realizado el';

  @override
  String get noDeliveryTerms => 'No se han establecido términos de entrega';

  @override
  String get noReturnRefundTermsSet =>
      'No se han establecido términos de devolución/reembolso';

  @override
  String get orderMargins => 'Márgenes del pedido';

  @override
  String get grossProfit => 'Ganancia bruta';

  @override
  String get margin => 'Margen';

  @override
  String get draft => 'Borrador';

  @override
  String get noStockAvailableInLocation =>
      'No hay existencias disponibles en la ubicación seleccionada para este producto';

  @override
  String get insufficientInventory =>
      'No tiene suficientes existencias en la ubicación seleccionada';

  @override
  String insufficientStockFor(Object item, Object location) {
    return 'Existencias insuficientes de $item en $location';
  }

  @override
  String get confirmed => 'Confirmado';

  @override
  String get setReminder => 'Establecer recordatorio';

  @override
  String get reminderMe => 'Recordarme';

  @override
  String get reminderNote =>
      'Los recordatorios deben establecerse con al menos 10 minutos de anticipación';

  @override
  String get notificationDisabled =>
      'Las notificaciones están deshabilitadas, lo que significa que no recibirá recordatorios de sus pedidos; habilítelas';

  @override
  String get deliveryCharges => 'Cargos de entrega';

  @override
  String get deliveryFees => 'Tarifas de entrega';

  @override
  String get noDeliveryFees => 'No se han establecido tarifas de entrega';

  @override
  String get delivery => 'Entrega';

  @override
  String get subscribeToAccess => 'Suscríbase para acceder a las estadísticas';

  @override
  String get cancelled => 'Cancelado';

  @override
  String get cancelledOrders => 'Pedidos cancelados';

  @override
  String get cancelledOrder =>
      '¿Desea restaurar este pedido cancelado? Presione sí para restaurarlo o no para mantenerlo cancelado';

  @override
  String get orderRemainsCancelled => 'El pedido permanece cancelado';

  @override
  String get failedToCancelOrder =>
      'Error al cancelar el pedido seleccionado, comuníquese con soporte';

  @override
  String get failedToRestoreOrder =>
      'Error al restaurar el pedido seleccionado, comuníquese con soporte';

  @override
  String get orderCancelled => 'El pedido está cancelado';

  @override
  String get receipeIsMissing =>
      'Falta la receta, verifique si fue eliminada o removida, actualice el producto nuevamente';

  @override
  String get rawItemMissing =>
      'Falta el artículo de materia prima, verifique si fue eliminado o removido, actualice la receta nuevamente';

  @override
  String get taxValue => 'Valor del impuesto';

  @override
  String get failedToDownloadInvoice =>
      'Error al descargar la factura, verifique su conexión';

  @override
  String get collection => 'Cobro de pago';

  @override
  String collectionReminder(Object days) {
    return 'Establezca un recordatorio para activarse cuando el cobro venza en $days días';
  }

  @override
  String get shallWeRemindYou => '¿Desea que le recordemos?';

  @override
  String get quotes => 'Cotizaciones';

  @override
  String get quoteTerms => 'Términos de la cotización';

  @override
  String get addQuote => 'Agregar cotización';

  @override
  String get editQuote => 'Editar cotización';

  @override
  String get noQuotesFound => 'No se encontraron cotizaciones';

  @override
  String get ordered => 'Pedido realizado';

  @override
  String get quoteMargins => 'Márgenes de la cotización';

  @override
  String get quotation => 'Cotización';

  @override
  String get quoted => 'Cotizado';

  @override
  String get makeOrder => 'Convertir en pedido';

  @override
  String get generateQuote => 'Generar cotización';

  @override
  String get edit => 'Editar';

  @override
  String get dublicate => 'Duplicar';

  @override
  String get noAssetsFound => 'No se encontraron activos';

  @override
  String get addAsset => 'Agregar activo';

  @override
  String get editAsset => 'Editar activo';

  @override
  String get value => 'Valor';

  @override
  String get imagesOptional => 'Imágenes (opcional)';

  @override
  String get valueRequired => 'El valor es obligatorio';

  @override
  String get dataNotLoading =>
      'Los datos no se cargaron correctamente, verifique la conexión e inténtelo de nuevo';

  @override
  String get noExpenseFound => 'No se encontraron gastos';

  @override
  String get addExpense => 'Agregar gasto';

  @override
  String get editExpense => 'Editar gasto';

  @override
  String get imageCorrupted => 'Imagen dañada, intente subir otra versión';

  @override
  String imageLimit4(Object count) {
    return 'Solo puede seleccionar hasta 4 imágenes. Ya tiene $count imagen(es).';
  }

  @override
  String get errorRemovingImage => 'Error al eliminar la imagen';

  @override
  String get details => 'Detalles';

  @override
  String get apply => 'Aplicar';

  @override
  String get selectDateRange => 'Seleccionar rango de fechas';

  @override
  String get start => 'Inicio';

  @override
  String get end => 'Fin';

  @override
  String get newsUpdate => 'Novedades';

  @override
  String get featuredProducts => 'Productos destacados';

  @override
  String get latestNews => 'Últimas noticias';

  @override
  String get salesReport => 'Informe de ventas';

  @override
  String get selectDateInfo =>
      'Seleccione el rango de fechas para el cual desea obtener el registro de ventas';

  @override
  String get reportGenSuccess => 'Informe generado correctamente';

  @override
  String get reportGenFailed => 'Error al generar el informe';

  @override
  String get date => 'Fecha';

  @override
  String get productCount => 'Cantidad de productos';

  @override
  String get from => 'Desde';

  @override
  String get to => 'hasta';

  @override
  String get totalSalesValue => 'Valor total de ventas';

  @override
  String get summary => 'Resumen';

  @override
  String get totalOrders => 'Total de pedidos';

  @override
  String get financialDetails => 'Detalles financieros';

  @override
  String get pandLReport => 'Informe de pérdidas y ganancias';

  @override
  String get plVariables => 'Variables de P y G';

  @override
  String get selectDatePL =>
      'Seleccione el rango de fechas para mostrar el informe de pérdidas y ganancias';

  @override
  String get selectOptions => 'Seleccionar opciones';

  @override
  String get optionsSummary => 'Resumen de opciones';

  @override
  String get noOptionsSelected => 'No hay opciones seleccionadas';

  @override
  String get noPreviousRecordSaved => 'No se guardaron registros anteriores';

  @override
  String get export => 'Exportar';

  @override
  String get dateRangeisCrucial =>
      'Se requiere un rango de fechas, selecciónelo antes de continuar';

  @override
  String get saveRecord => 'Guardar registro';

  @override
  String get plSummary => 'Resumen de P y G';

  @override
  String get profitLossStatement => 'Estado de pérdidas y ganancias';

  @override
  String get period => 'Período';

  @override
  String get totalRevenue => 'Ingresos totales';

  @override
  String get operatingExpenses => 'Gastos operativos';

  @override
  String get operatingIncome => 'Ingresos operativos';

  @override
  String get nonOperatingIncomeExpense => 'Ingresos/gastos no operativos';

  @override
  String get earningBeforeTax => 'Utilidad antes de impuestos';

  @override
  String get taxDesc =>
      'Establezca solo el impuesto que le corresponde; si deja el campo vacío, el impuesto no se incluirá en sus registros financieros';

  @override
  String get incomeTax => 'Impuesto sobre la renta';

  @override
  String get salesTax => 'Impuesto sobre ventas';

  @override
  String get stateTax => 'Impuesto estatal';

  @override
  String get governmentTax => 'Impuesto gubernamental';

  @override
  String get netIncome => 'Ingreso neto';

  @override
  String get detailedBreakDown => 'Desglose detallado';

  @override
  String get nonOperatingItems => 'Elementos no operativos';

  @override
  String get investmentIncome => 'Ingresos por inversiones';

  @override
  String get interestExpense => 'Gastos por intereses';

  @override
  String get foreignExchange => 'Ganancia/pérdida por tipo de cambio';

  @override
  String get keyFinancialMetrics => 'Indicadores financieros clave';

  @override
  String get grossProfitMargin => 'Margen de utilidad bruta';

  @override
  String get operatingMargin => 'Margen operativo';

  @override
  String get netProfitMargin => 'Margen de utilidad neta';

  @override
  String get percentageCogs => '% del costo de ventas sobre ingresos';

  @override
  String get saveFinancialRecord =>
      '¿Desea guardar estos registros de datos para uso futuro?';

  @override
  String get pandLStatement => 'Estado de P y G';

  @override
  String get failedToRetrieveData => 'Error al recuperar los datos';

  @override
  String get connectionLost => 'Conexión perdida';

  @override
  String get checkYourConnection => 'Verifica tu conexión a Internet';

  @override
  String get topProducts => 'Artículos más vendidos';

  @override
  String get soldQuantity => 'Cantidad vendida';

  @override
  String get averagePrice => 'Precio promedio';

  @override
  String get subscribe => 'Suscribirse';

  @override
  String get premiumUser => 'Premium';

  @override
  String get googlePlay => 'Tienda Google Play';

  @override
  String get appleStore => 'Apple Store';

  @override
  String paymenetCharging(Object store) {
    return 'El pago se cargará a su cuenta de (tienda) al confirmarse la compra. La suscripción se renueva automáticamente a menos que la renovación automática se desactive al menos 24 horas antes del final del período actual.';
  }

  @override
  String get privacyAndTerms => 'Política de privacidad';

  @override
  String get termsOfUse => 'Términos de uso';

  @override
  String get cont => 'Continuar';

  @override
  String get popular => 'POPULAR';

  @override
  String get goPremium => 'Hazte Premium';

  @override
  String get unlockAll => 'Desbloquea todas las funciones y contenido';

  @override
  String get unlimitedAccess => 'Acceso ilimitado a todo el contenido';

  @override
  String get exclusivePremium => 'Funciones premium exclusivas';

  @override
  String get syncAll => 'Sincroniza en todos tus dispositivos';

  @override
  String get prioritySup => 'Soporte prioritario';

  @override
  String get success => 'Éxito';

  @override
  String get processing => 'Procesando...';

  @override
  String get welcomePre => '¡Bienvenido a Premium!';

  @override
  String get startUsing => 'Empezar a usar la app';

  @override
  String get upgradeToUnlock => 'Actualice para desbloquear esta función';

  @override
  String get viewSub => 'Ver suscripciones';

  @override
  String get notNow => 'Ahora no';

  @override
  String get sevenDayFree =>
      'Prueba GRATIS de 7 días • Cancele en cualquier momento durante la prueba';

  @override
  String get sevenDayDes =>
      'Después del período de prueba, su suscripción se renovará automáticamente y se le cobrará según el plan seleccionado.';

  @override
  String get enterCoupon => 'Ingresar código de cupón';

  @override
  String get applyCoupon => 'Aplicar código de cupón';

  @override
  String couponApplied(Object discount) {
    return 'Cupón aplicado: $discount% de descuento';
  }

  @override
  String get cancelSupscription => 'Cancelar suscripción';

  @override
  String get cancelSubWarning =>
      '¿Está seguro de que desea cancelar su suscripción y perder todas las funciones adicionales?';

  @override
  String freeTrialDays(Object days) {
    return '$days días de prueba gratis';
  }

  @override
  String get freeTrial => 'Prueba gratis';

  @override
  String get purchaseFailed => 'Compra fallida';

  @override
  String get purchaseCancelled => 'Compra cancelada';

  @override
  String get invalidCoupon => 'Código de cupón inválido o expirado';

  @override
  String appliedCoupon(Object coupon) {
    return '¡Cupón aplicado correctamente! \$$coupon% de descuento';
  }

  @override
  String get totalToBePaid => 'Total a cobrar';

  @override
  String get freeMonth => 'Mes gratis';

  @override
  String get freeYear => 'Año gratis';

  @override
  String get selectPlan => 'Seleccione un plan primero';

  @override
  String get noOfferingsAvailable => 'No hay ofertas disponibles';

  @override
  String get selectedPlanNotAvailable =>
      'El plan seleccionado no está disponible';

  @override
  String get purchaseInactive => 'La compra está inactiva';

  @override
  String get unableToLoadPlans =>
      'No se pudieron cargar los planes, inténtelo de nuevo';

  @override
  String get premiumActive => '¡Premium activo!';

  @override
  String get enjoyFreeTrial =>
      'Actualmente está disfrutando de su prueba gratuita';

  @override
  String get enjoyPremium => '¡Bienvenido a CostEra Pro!';

  @override
  String get currentPlan => 'Plan actual';

  @override
  String get freeTrialActive => 'Prueba gratuita activa';

  @override
  String get trialEndsOn => 'La prueba termina el';

  @override
  String get memberSince => 'Miembro desde';

  @override
  String get yourBenefits => 'Sus beneficios Premium';

  @override
  String get generatePdfInvoice => 'Facturas en PDF';

  @override
  String get createProfessionalInvoices =>
      'Cree facturas PDF profesionales al instante';

  @override
  String get detailedFinancialInsights =>
      'Genere informes financieros detallados y análisis';

  @override
  String get expenseTracking => 'Seguimiento de gastos';

  @override
  String get monitorAllExpenses =>
      'Supervise y clasifique todos los gastos de su negocio';

  @override
  String get unlimitedProducts => 'Productos ilimitados';

  @override
  String get addUnlimitedItems =>
      'Agregue productos y servicios ilimitados a su catálogo';

  @override
  String get cloudSync => 'Sincronización en la nube';

  @override
  String get syncAcrossDevices =>
      'Sincronice sus datos de forma segura en todos sus dispositivos';

  @override
  String get prioritySupport => 'Soporte prioritario';

  @override
  String get createAndSendQuotes => 'Cree y envíe cotizaciones profesionales';

  @override
  String get suppliersAccess => 'Acceso a proveedores';

  @override
  String get manageYourSuppliers => 'Administre y controle a sus proveedores';

  @override
  String get inventoryTracking => 'Seguimiento de inventario';

  @override
  String get trackStockInRealTime =>
      'Controle los niveles de existencias en tiempo real';

  @override
  String get orderReminders => 'Recordatorios de pedidos y pagos';

  @override
  String get neverMissAPayment =>
      'Nunca pierda una fecha de vencimiento o un pago';

  @override
  String get fasterCustomerSupport =>
      'Obtenga respuestas más rápidas de nuestro equipo de soporte';

  @override
  String get cancelSubscription => 'Cancelar suscripción';

  @override
  String get cancelAnyTime =>
      'Puede cancelar su suscripción en cualquier momento';

  @override
  String get loadingSubscription => 'Cargando información de la suscripción...';

  @override
  String get errorLoadingSubscription => 'Error al cargar la suscripción';

  @override
  String get cancelSubAtPeriodEnd =>
      'Su suscripción permanecerá activa hasta el final del período de facturación actual. Continuará disfrutando de todos los beneficios premium hasta entonces.';

  @override
  String get subscriptionWillCancel =>
      'Su suscripción se cancelará al final del período de facturación actual.';

  @override
  String get accessUntil => 'Acceso hasta';

  @override
  String get renewsOn => 'Se renueva el';

  @override
  String get cancellationRequested => 'Cancelación solicitada el';

  @override
  String get subscriptionExpired => 'Suscripción expirada';

  @override
  String get premiumBenefitsGone =>
      'Sus beneficios premium ya no están activos. Renueve su suscripción para seguir disfrutando de todas las funciones.';

  @override
  String get daysLeft => 'días restantes de Premium';

  @override
  String get noActiveSubscription =>
      'No se encontró ninguna suscripción activa';

  @override
  String get manageSubscriptionThrough =>
      'Administre su suscripción a través de';

  @override
  String get appStore => 'Tienda App Store';

  @override
  String get resumeSubscription => 'Reanudar suscripción';

  @override
  String get resumeSubscriptionConfirm =>
      '¿Está seguro de que desea reanudar su suscripción? Su suscripción continuará y se renovará automáticamente con normalidad.';

  @override
  String get resumeSubscriptionDesc =>
      'Continúe su suscripción y conserve todos los beneficios';

  @override
  String get resubscribe => 'Volver a suscribirse';

  @override
  String get subscriptionResumed => '¡Su suscripción ha sido reanudada!';

  @override
  String get cancellationPending =>
      'La cancelación de su suscripción está pendiente. Puede reanudarla en cualquier momento antes de la fecha de finalización.';

  @override
  String get failedToResume => 'Error al reanudar';

  @override
  String get failedToCancel => 'Error al cancelar';

  @override
  String get then => 'Luego';

  @override
  String get autoRenewal => 'Información de renovación automática';

  @override
  String autoRenewalDes(Object store) {
    return 'Su suscripción se renovará automáticamente al final de cada período a menos que se cancele al menos 24 horas antes del final del período actual. Puede administrar o cancelar su suscripción en cualquier momento a través de la configuración de su cuenta de $store.';
  }

  @override
  String get daysFree => '-Días de prueba gratis';

  @override
  String subscriptionFeature(Object feature) {
    return '$feature solo está disponible para usuarios de pago, considere suscribirse para disfrutar de acceso ilimitado';
  }

  @override
  String subscriptionOrderFeature(Object feature, Object number) {
    return 'Ha alcanzado el límite de $feature para usuarios gratuitos de $number pedidos, considere suscribirse para disfrutar de acceso ilimitado a todas las funciones y pedidos';
  }

  @override
  String get theFor => 'para';

  @override
  String get months => 'meses';

  @override
  String get salesStats => 'Estadísticas de ventas';

  @override
  String get sales => 'Ventas';

  @override
  String get topClient => 'Mejor cliente';

  @override
  String get totalSales => 'Ventas totales';

  @override
  String get averageMargin => 'Margen promedio';

  @override
  String get topFiveClients => '5 mejores clientes';

  @override
  String get profitDist => 'Distribución del margen de ganancia';

  @override
  String get annual => 'Anual';

  @override
  String get monthly => 'Mensual';

  @override
  String get revenueSplit => 'Distribución de ingresos';

  @override
  String get profit => 'Ganancia';

  @override
  String get viewAll => 'Ver todo';

  @override
  String get dueSoon => 'Vence pronto';

  @override
  String get onTrack => 'En curso';

  @override
  String get noUpcomingPayments => 'No hay pagos próximos';

  @override
  String get operationTimedOut =>
      'La operación agotó el tiempo de espera, verifique su conexión e inténtelo de nuevo';

  @override
  String get today => 'Hoy';

  @override
  String get yesterday => 'Ayer';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get lastWeek => 'Semana pasada';

  @override
  String get thisMonth => 'Este mes';

  @override
  String get lastMonth => 'Mes pasado';

  @override
  String get thisYear => 'Este año';

  @override
  String get lastYear => 'Año pasado';

  @override
  String get selectPeriod => 'Seleccionar período';

  @override
  String get inventoryReport => 'Informe de inventario';

  @override
  String get keepEmptyForAllLocations =>
      'Deje vacío para todas las ubicaciones';

  @override
  String get storeName => 'Nombre de la tienda';

  @override
  String get productStock => 'Existencias';

  @override
  String get code => 'Código';

  @override
  String get tutorialCompleted => 'Tutorial completado';

  @override
  String get tutOrderScreenDes =>
      'El calendario de pedidos llevará un registro de sus pedidos mensuales';

  @override
  String get tutQuotesDes =>
      'Las cotizaciones le permiten crear presupuestos para sus clientes antes de crear un pedido y facturar';

  @override
  String get tutDashScreenDes =>
      'Nuestro botón de inicio o panel mostrará su progreso mensual';

  @override
  String get tutProductScreenDes =>
      'Aquí puede crear, editar y ajustar productos. Puede acceder a todos sus productos desde esta página';

  @override
  String get tutSettingScreeDes =>
      'La pantalla de configuración proporcionará todas las funciones de su app';

  @override
  String get next => 'Siguiente';

  @override
  String get finish => 'Finalizar';

  @override
  String get tutorial => 'Tutorial';

  @override
  String get tutorialSkipped => 'Tutorial omitido';

  @override
  String get startTutorial => 'Iniciar tutorial';

  @override
  String get skipTutorial => 'Omitir tutorial';

  @override
  String get tutorialWelcome => '¡Bienvenido!';

  @override
  String get tutorialStartPrompt => 'Aprendamos a usar la app';

  @override
  String get tutgalleryDes =>
      'Todas las imágenes de sus productos o servicios se pueden subir aquí';

  @override
  String get tutProfileDes =>
      'Edite todos sus datos personales desde la sección de perfil';

  @override
  String get tutAccountDes =>
      'Edite la información de su negocio desde la sección de cuenta';

  @override
  String get tutAppSettingDes =>
      'Modifique la configuración de la app: color, tema y más desde aquí';

  @override
  String get tutClientDes =>
      'Agregue y edite los datos de sus clientes desde aquí';

  @override
  String get tutOrdersDes =>
      'Puede crear y modificar sus pedidos desde la pestaña de pedidos';

  @override
  String get tutSupplierDes =>
      'La pestaña de proveedores le permite agregar proveedores y emitir compras';

  @override
  String get tutPurchasesDes =>
      'La pestaña de compras le permitirá emitir y editar compras';

  @override
  String get tutCapExpReportDes =>
      'La pestaña de capital y gastos es esencial para controlar sus gastos';

  @override
  String get tutFinancialReportDes =>
      'Supervise su negocio y sepa cómo le está yendo emitiendo los informes necesarios';

  @override
  String get tutFilterOptionDes =>
      'La opción de filtro le permitirá buscar un artículo específico o filtrar por varias variables';

  @override
  String get tutAddProductDes =>
      'El botón de agregar le permitirá agregar productos o servicios';

  @override
  String get tutPaymentDes =>
      'Mostrará todos los pagos a crédito de sus clientes';

  @override
  String get days15 => '15 días';

  @override
  String get days30 => '30 días';

  @override
  String get days45 => '45 días';

  @override
  String get more => 'Más';

  @override
  String get all => 'Todos';

  @override
  String get dueOn => 'Vence el';

  @override
  String get addPayment => 'Agregar pago';

  @override
  String get editPayment => 'Editar pago';

  @override
  String get upcomingPayments => 'Pagos próximos';

  @override
  String get updatePayment => 'Actualizar pago';

  @override
  String partialPayment(Object amount) {
    return 'El pago no cubre el monto requerido, quedará un saldo pendiente de $amount';
  }

  @override
  String paymentOverpaid(Object amount) {
    return 'El pago excede el saldo requerido, el monto adicional de $amount se agregará al cliente como crédito';
  }

  @override
  String get paymentCovered =>
      'El pago está totalmente cubierto y la factura de crédito se cerrará en consecuencia';

  @override
  String get clientStatement => 'Estado de cuenta del cliente';

  @override
  String get method => 'Método de pago';

  @override
  String get optional => 'Opcional';

  @override
  String get faq => 'Preguntas frecuentes';

  @override
  String get question => 'Pregunta';

  @override
  String get answer => 'Respuesta';

  @override
  String get referenceOrder => 'Referencia del pedido';

  @override
  String get questionEmpty => 'La lista de preguntas está vacía';

  @override
  String get questionIsEmpty => 'La pregunta no puede estar vacía';

  @override
  String get answerIsEmpty => 'La respuesta no puede estar vacía';

  @override
  String get referenceIsEmpty => 'La referencia no puede estar vacía';

  @override
  String get referenceOrderExits =>
      'La orden de referencia ya existe, seleccione otra';
}
