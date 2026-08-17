// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'CostEra';

  @override
  String get register => 'Registrati';

  @override
  String get firstName => 'Nome';

  @override
  String get lastName => 'Cognome';

  @override
  String get emailAddress => 'Indirizzo Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPass => 'Conferma Password';

  @override
  String get notEmpty => 'Non deve essere vuoto';

  @override
  String get emailValidation => 'L\'email non è valida';

  @override
  String get shortPassword => 'min 8 caratteri';

  @override
  String get needNumber => 'almeno un numero';

  @override
  String get needSpCharacter => 'almeno un carattere speciale \$ # @ ...ecc';

  @override
  String get firstNameRequired => 'Il nome è obbligatorio';

  @override
  String get lastNameRequired => 'Il cognome è obbligatorio';

  @override
  String get emailAddressRequired => 'L\'indirizzo email è obbligatorio';

  @override
  String get passwordRequired => 'La password è obbligatoria';

  @override
  String get confirmpasswordRequired =>
      'La conferma della password è obbligatoria';

  @override
  String get passwordNoMatcH => 'Le password non corrispondono';

  @override
  String get connectionError => 'Errore di connessione, riprova più tardi';

  @override
  String get createYourAccount => 'Crea il tuo Account';

  @override
  String get personalInfo => 'Informazioni Personali';

  @override
  String get accountInfo => 'Informazioni Account';

  @override
  String get alreadyHaveAccount => 'Hai già un account!';

  @override
  String get login => 'Accedi';

  @override
  String get forgotPass => 'Password Dimenticata';

  @override
  String get reset => 'Reimposta';

  @override
  String get googleSignIn => 'Google';

  @override
  String get appleSignIn => 'Apple';

  @override
  String get verifyEmail => 'Verifica la tua email per procedere';

  @override
  String get verifyYourEmail => 'Verifica la tua Email';

  @override
  String get verificationLinkSentTo => 'Abbiamo inviato un link di verifica a';

  @override
  String get verifyEmailBody =>
      'Apri l\'email e tocca il link per verificare il tuo account. Non dimenticare di controllare la cartella spam o posta indesiderata.';

  @override
  String get resendEmail => 'Reinvia Email';

  @override
  String resendEmailIn(Object seconds) {
    return 'Reinvio disponibile tra ${seconds}s';
  }

  @override
  String get verificationEmailResent => 'Email di verifica reinviata';

  @override
  String get emailVerifiedSuccess => 'Email verificata! Accedi per continuare';

  @override
  String get wrongEmail => 'Email sbagliata?';

  @override
  String get waitingForVerification => 'In attesa di verifica...';

  @override
  String get signOut => 'Esci';

  @override
  String get profile => 'Profilo';

  @override
  String get account => 'Account';

  @override
  String get appSettings => 'Impostazioni App';

  @override
  String get buildNumber => 'Numero Build';

  @override
  String get currency => 'Valuta';

  @override
  String get businessAddress => 'Indirizzo Aziendale';

  @override
  String get assignedCurrency => 'Valuta Assegnata';

  @override
  String get userNotFound => 'Utente Non Trovato';

  @override
  String get receipies => 'Ricette';

  @override
  String get selectCurrency => 'Seleziona Valuta';

  @override
  String get emailNotVerified => 'Email Non Verificata';

  @override
  String get changeCurrency => 'Cambia Valuta';

  @override
  String get deleteAccount => 'Elimina Account';

  @override
  String get accountDeletionMessage =>
      'Sei sicuro di voler procedere con l\'eliminazione del tuo account?\nManterremo i tuoi dati sul nostro server per un massimo di 30 giorni prima di eliminare definitivamente tutti i tuoi contenuti!\nCi dispiace vederti andare via e speriamo di rivederti un giorno.';

  @override
  String get accountDeletionSuccess =>
      'Il tuo account è stato eliminato con successo, hai 30 giorni nel caso decidessi di cambiare idea!';

  @override
  String get contactUs => 'Contattaci';

  @override
  String get rateUs => 'Valutaci';

  @override
  String get messageContent => 'Contenuto del Messaggio';

  @override
  String get send => 'Invia';

  @override
  String get subject => 'Oggetto';

  @override
  String get technical => 'Tecnico';

  @override
  String get complaint => 'Reclamo';

  @override
  String get suggestion => 'Suggerimento';

  @override
  String get messageCannotBeEmpty =>
      'Il contenuto del messaggio non può essere vuoto';

  @override
  String get selectSubject => 'Seleziona l\'oggetto del messaggio';

  @override
  String get longPressToRemove => 'Tieni premuto per rimuovere';

  @override
  String get personalInformation => 'Informazioni Profilo';

  @override
  String get contactInformation => 'Informazioni di Contatto';

  @override
  String get accountInformation => 'Informazioni Account';

  @override
  String get profileUpdatedSuccessfully => 'Profilo aggiornato con successo';

  @override
  String get messageSentSuccessfully =>
      'Il messaggio è stato inviato con successo, il nostro team dedicato ti contatterà a breve.';

  @override
  String get thankYouForReachingOut =>
      'Grazie per averci contattato, faremo del nostro meglio per risolvere il problema entro 48 ore.';

  @override
  String get screenShots =>
      'Allega screenshot di eventuali problemi riscontrati';

  @override
  String get manageYourBusiness => 'Gestisci la Tua Attività';

  @override
  String get sigIn => 'Accedi';

  @override
  String get or => 'Oppure';

  @override
  String get continueWithGoogle => 'Continua con Google';

  @override
  String get dontHaveAccount => 'Non hai un Account?';

  @override
  String get orContinueWith => 'oppure Continua con';

  @override
  String get resetIt => 'Reimpostala';

  @override
  String get senderDetails => 'I Tuoi Dati';

  @override
  String get forgotPassSubtitle =>
      'Inserisci la tua email e ti invieremo un link di reimpostazione';

  @override
  String get resetPassword => 'Reimposta Password';

  @override
  String get resetEmailSent =>
      'Email di reimpostazione inviata. Controlla la tua casella di posta.';

  @override
  String get invoiceSettings => 'Impostazioni Fattura';

  @override
  String get invoiceSettingExplained =>
      'Modifica il contenuto della tua fattura abilitando o disabilitando le funzionalità';

  @override
  String get on => 'Attivo';

  @override
  String get off => 'Disattivo';

  @override
  String get companyFinancialDetaiils => 'I Miei Dati Finanziari';

  @override
  String get clientCrNumber => 'Numero CR Cliente';

  @override
  String get clientBankDetail => 'Dati Bancari Cliente';

  @override
  String get clientFinancialDetails => 'Numero Finanziario Cliente';

  @override
  String get yes => 'Sì';

  @override
  String get no => 'No';

  @override
  String get exitConfirmation =>
      'Hai modifiche non salvate, sei sicuro di voler uscire?';

  @override
  String get generalSettings => 'Impostazioni Generali';

  @override
  String get generalSettingsExplained =>
      'Modifica le impostazioni dell\'app in base alle tue esigenze';

  @override
  String get assignedLanguage => 'Lingua Assegnata';

  @override
  String get assignedTheme => 'Tema Assegnato';

  @override
  String get inventoryInfo =>
      'L\'inventario ti permetterà di creare fino a 10 sedi per conservare i tuoi prodotti';

  @override
  String get inventory => 'Inventario';

  @override
  String get selectNewStore => 'Seleziona una Nuova Sede';

  @override
  String get inventoryLocation => 'Sede Inventario';

  @override
  String get financialSettings => 'Impostazioni Finanziarie';

  @override
  String get financialSettingsDesc =>
      'Le impostazioni finanziarie ti permetteranno di impostare le variabili standard relative al tuo bilancio';

  @override
  String get defaultSalesOrderTerms =>
      'Imposta i termini predefiniti di consegna, reso e rimborso per i tuoi ordini di vendita';

  @override
  String get defaultPurchaseTerms =>
      'Imposta i termini predefiniti di consegna, reso e rimborso per i tuoi ordini di acquisto';

  @override
  String get reactivate => 'Riattiva';

  @override
  String get status => 'Stato';

  @override
  String get restartApp => 'Riavvia App';

  @override
  String get restartAppLangInfo =>
      'Per cambiare la lingua devi riavviare l\'app, sei sicuro di voler procedere?';

  @override
  String get restartAppThemeInfo =>
      'Per cambiare il Tema devi riavviare l\'app, sei sicuro di voler procedere?';

  @override
  String get inventoryController => 'Controller Inventario';

  @override
  String get inventoryIntro =>
      'L\'opzione inventario ti permetterà di creare sedi in cui conservare i prodotti. Tieni presente che quando attivi l\'inventario il tuo ordine sarà direttamente collegato e non potrai elaborarlo se sei fuori scorta.';

  @override
  String get activateInventory => 'Attiva Inventario';

  @override
  String get locationName => 'Nome Sede';

  @override
  String get inventoryLocationLimit =>
      'Hai raggiunto il numero massimo di sedi di inventario consentite';

  @override
  String get inventoryValue => 'Valore Inventario';

  @override
  String get inventoryInActive => 'Inventario Non Attivo';

  @override
  String get doActivateInventory => 'Vuoi attivare l\'opzione inventario?';

  @override
  String get locationNameEmpty =>
      'Il nome della sede è vuoto, correggilo per procedere';

  @override
  String get purchaseOrder => 'Ordini di Acquisto';

  @override
  String get purchaseInfo =>
      'La funzione di acquisto ti consente di creare ordini di acquisto per il tuo fornitore che aggiorneranno automaticamente il costo del prodotto se lo desideri';

  @override
  String get purchaseSettings => 'Impostazioni Acquisti';

  @override
  String get activatePurchases => 'Attiva Acquisti';

  @override
  String get updateProductCost => 'Aggiorna Costo Prodotto';

  @override
  String get purchases => 'Acquisti';

  @override
  String get addPurchase => 'Aggiungi Acquisto';

  @override
  String get editPurchase => 'Modifica Acquisto';

  @override
  String get noSupplierFound => 'Nessun Fornitore Trovato';

  @override
  String get supplierName => 'Nome Fornitore';

  @override
  String get supplierNameEmpty => 'Nome fornitore vuoto';

  @override
  String get supplierNameInvalid => 'Il nome del fornitore non è valido';

  @override
  String get purchaseTerms => 'Termini di Acquisto';

  @override
  String get generatePO => 'Genera Ordine di Acquisto';

  @override
  String get generatePoInfo =>
      'Una volta generato l\'ordine di acquisto non potrai più modificarlo. Se hai bisogno di annullarlo, puoi eliminare l\'ordine e crearne uno nuovo';

  @override
  String get receivingPO => 'Ricezione Ordine di Acquisto';

  @override
  String get receive => 'Ricevi';

  @override
  String get receiveInfo =>
      'Questo ti permetterà di confermare se l\'ordine di acquisto è stato ricevuto, o modificare la quantità ricevuta';

  @override
  String get materialAlreadyReceived =>
      'Il materiale di questo ordine di acquisto è già stato ricevuto';

  @override
  String get receiveMaterial => 'Ricevi Materiale';

  @override
  String get remove => 'Rimuovi';

  @override
  String get storeNotAssigned => 'Nessuna sede è stata assegnata';

  @override
  String storeNotExisting(Object product, Object store) {
    return 'La sede selezionata $store non esiste per il prodotto $product';
  }

  @override
  String get purchaseOrderGenerationComplete =>
      'Generazione dell\'ordine di acquisto completata';

  @override
  String get generated => 'Generato';

  @override
  String get received => 'Ricevuto';

  @override
  String get revertingBackNotPossible =>
      'Nota che al momento non è possibile ripristinare il costo precedente dell\'articolo, effettua questa operazione manualmente';

  @override
  String get suppliers => 'Fornitori';

  @override
  String get addSupplier => 'Aggiungi Fornitore';

  @override
  String get editSupplier => 'Modifica Fornitore';

  @override
  String get supplierOrders => 'Ordini Fornitore';

  @override
  String get home => 'Home';

  @override
  String get product => 'Articoli';

  @override
  String get settings => 'Impostazioni';

  @override
  String get menu => 'Menu';

  @override
  String get orders => 'Ordini';

  @override
  String get payments => 'Pagamenti';

  @override
  String get businessType => 'Tipo di Attività';

  @override
  String get businessCategory => 'Categoria Attività';

  @override
  String get businessTypeDes =>
      'Seleziona il tipo di attività che meglio descrive la tua azienda, tieni presente che influenzerà il calcolo del costo dei prodotti';

  @override
  String get businessCategoryDes =>
      'Seleziona la categoria dell\'attività se disponibile, oppure altro se non disponibile, la esamineremo e cercheremo di aggiungerla in futuro';

  @override
  String get businessTypeNotDefined =>
      'Il tipo di attività non sembra essere definito, controlla il tuo account e assegna un tipo di attività';

  @override
  String get missingCategory => 'Devi selezionare una categoria';

  @override
  String get missingType => 'Devi selezionare un tipo';

  @override
  String get fillManualCategory => 'Inserisci la tua categoria di attività';

  @override
  String get select => 'Seleziona';

  @override
  String get update => 'Aggiorna';

  @override
  String get companyInfo => 'Informazioni Azienda';

  @override
  String get companyName => 'Nome Azienda';

  @override
  String get companyLogo => 'Logo Azienda';

  @override
  String get save => 'Salva';

  @override
  String get companyLogoMissing => 'Il logo aziendale è mancante';

  @override
  String get dataSaveSuccessfully => 'Dati salvati con successo';

  @override
  String get failedToSaveData => 'Salvataggio dati non riuscito';

  @override
  String get imageRemovedSuccessfully => 'Immagine rimossa con successo';

  @override
  String get failedToRemoveImage => 'Rimozione immagine non riuscita';

  @override
  String get currencyDes =>
      'Seleziona la valuta con cui desideri condurre la tua attività, potrai cambiarla in seguito';

  @override
  String get locationDes =>
      'Seleziona la sede da cui verrà condotta la tua attività, potrai cambiarla in seguito';

  @override
  String get noApiKeyDetected =>
      'Nessuna chiave API rilevata, contatta l\'assistenza';

  @override
  String get viewMore => 'Vedi Altro';

  @override
  String get locationChoice =>
      'Vuoi concedere all\'app l\'accesso alla tua posizione?';

  @override
  String get skip => 'Salta';

  @override
  String get dataRefereshedSuccessfully => 'Dati Aggiornati con Successo';

  @override
  String get dataFailedToRefresh => 'Aggiornamento Dati Non Riuscito';

  @override
  String get businessTypeSubDes =>
      'Questo ci aiuta a personalizzare la tua esperienza.';

  @override
  String get continueLabel => 'Continua';

  @override
  String get stepOneOfTwo => 'Passo 1 di 2';

  @override
  String get currencySubDes =>
      'Utilizzata in tutte le fatture, ordini e report.';

  @override
  String get stepTwoOfTwo => 'Passo 2 di 2';

  @override
  String get finishSetup => 'Completa configurazione';

  @override
  String get addressNotRegistered => 'L\'indirizzo non è stato registrato';

  @override
  String get noLocationSelected => 'Nessuna Sede Selezionata';

  @override
  String get selectLocation => 'Seleziona Sede';

  @override
  String get locServiceDisabled => 'Servizio di localizzazione disattivato';

  @override
  String get locServiceDenied => 'Servizio di localizzazione negato';

  @override
  String get locServiceDeniedForever =>
      'I permessi di localizzazione sono stati negati permanentemente. Se desideri impostare la tua posizione devi andare nelle impostazioni del tuo dispositivo e abilitarli da lì.';

  @override
  String get locationPermissionDenied =>
      'Il permesso di localizzazione è stato negato';

  @override
  String get locationPermissionPermanentlyDenied =>
      'Il permesso di localizzazione è stato negato permanentemente';

  @override
  String get locationServicesDisabled =>
      'I servizi di localizzazione sono stati disattivati';

  @override
  String get networkError => 'Errore di rete, riprova';

  @override
  String get configurationError => 'Errore di configurazione, riprova';

  @override
  String get somethingWentWrong =>
      'Qualcosa è andato storto, contatta l\'assistenza';

  @override
  String get openSettings => 'Apri Impostazioni';

  @override
  String get retry => 'Riprova';

  @override
  String get addProduct => 'Aggiungi Articolo';

  @override
  String get editProduct => 'Modifica Articolo';

  @override
  String get productName => 'Nome Articolo';

  @override
  String get itemCode => 'Codice Articolo';

  @override
  String get productDescription => 'Descrizione Articolo';

  @override
  String get productPacking => 'Confezione Articolo (esempio kg, pz...)';

  @override
  String get productCost => 'Costo Articolo';

  @override
  String get productCostService => 'Costo Articolo (Opzionale)';

  @override
  String get productPrice => 'Prezzo di Vendita Articolo';

  @override
  String get images => 'Immagini';

  @override
  String get files => 'File';

  @override
  String get noImages => 'Nessuna Immagine Trovata';

  @override
  String get productNameEmpty => 'Il nome dell\'articolo non può essere vuoto';

  @override
  String get productCostEmpty =>
      'Il costo dell\'articolo è necessario, inserisci 0 se non vuoi aggiungere un costo';

  @override
  String get productPriceEmpty =>
      'L\'articolo deve avere un prezzo, inserisci 0 per articoli gratuiti';

  @override
  String get productImageEmpty => 'Ogni articolo deve avere almeno 1 immagine';

  @override
  String get noProductsAdded => 'Nessun Articolo Aggiunto';

  @override
  String get productCostError =>
      'Verifica se la Categoria di attività è selezionata';

  @override
  String get addCost => 'Aggiungi Costo';

  @override
  String get editCost => 'Modifica Costo';

  @override
  String get saveProductFirst =>
      'Salva prima l\'articolo, poi potrai aggiungere il costo';

  @override
  String get costValue => 'Valore Costo';

  @override
  String get error => 'Errore';

  @override
  String get noProductFound => 'Nessun Articolo Trovato';

  @override
  String get productCategory => 'Categoria Articolo (Opzionale)';

  @override
  String get productCategoryHint =>
      'Digita una categoria qualsiasi, verrà creata dopo aver aggiunto un prodotto';

  @override
  String get id => 'ID';

  @override
  String get filterOptions => 'Opzioni Filtro';

  @override
  String get filterProducts => 'Filtra Articoli';

  @override
  String get searchProducts => 'Cerca Articoli';

  @override
  String get priceRange => 'Fascia di Prezzo';

  @override
  String get minPrice => 'Prezzo Minimo';

  @override
  String get maxPrice => 'Prezzo Massimo';

  @override
  String get applyFilter => 'Applica Filtro';

  @override
  String get productCodeExists => 'Il codice articolo esiste già';

  @override
  String get itemCodeEmpty => 'Il codice articolo non può essere vuoto';

  @override
  String get noCategoriesFound => 'Nessuna categoria trovata';

  @override
  String get productRecords => 'Registri Articolo';

  @override
  String get productsLimit =>
      'Sembra che tu abbia raggiunto il limite di prodotti della versione gratuita, abbonati al nostro piano a pagamento per un numero illimitato di prodotti';

  @override
  String get orderLimit =>
      'Sembra che tu abbia raggiunto il limite di ordini della versione gratuita, abbonati al nostro piano a pagamento per un numero illimitato di ordini';

  @override
  String get category => 'Categoria';

  @override
  String get subscribeToAccessInventory =>
      'Abbonati per Accedere all\'Inventario';

  @override
  String get basicInfo => 'Informazioni di base';

  @override
  String get auto => 'Auto';

  @override
  String get packaging => 'Confezionamento';

  @override
  String get pricing => 'Prezzi';

  @override
  String get profitMargin => 'Margine di profitto';

  @override
  String get noItemRecordFound => 'Nessun record articolo trovato';

  @override
  String get clearFilter => 'Cancella Filtro';

  @override
  String get receipes => 'Ricette';

  @override
  String get addReceipe => 'Aggiungi Ricetta';

  @override
  String get editRecipe => 'Modifica Ricetta';

  @override
  String get noReceipesFound => 'Nessuna Ricetta Trovata';

  @override
  String get receipeName => 'Nome Ricetta';

  @override
  String get receipeDescription => 'Descrizione Ricetta';

  @override
  String get receipePacking => 'Confezione Ricetta';

  @override
  String get receipeIngredients => 'Ingredienti Ricetta';

  @override
  String get cost => 'Costo';

  @override
  String get pack => 'Confezione';

  @override
  String get packService => 'Confezione o Sessioni';

  @override
  String get quantity => 'Qtà';

  @override
  String get suggestions => 'Suggerimenti';

  @override
  String get unit => 'Unità';

  @override
  String get selectedIngredientFirst => 'Devi prima selezionare un ingrediente';

  @override
  String get add => 'Aggiungi';

  @override
  String get totalCost => 'Costo Totale';

  @override
  String get packingUnit => 'Unità';

  @override
  String get receipeNameRequired => 'Il nome della ricetta è obbligatorio';

  @override
  String get receipePackingRequired =>
      'Il valore di confezione della ricetta è obbligatorio';

  @override
  String get receipePackingUnitRequired =>
      'L\'unità di confezione della ricetta è obbligatoria';

  @override
  String get ingredientsMissing =>
      'Ogni ricetta deve avere almeno un ingrediente';

  @override
  String get tapReceipeToAdd => 'Tocca la ricetta per aggiungerla al prodotto';

  @override
  String get recipeDetails => 'Dettagli Ricetta';

  @override
  String get outputPacking => 'Confezione di Uscita';

  @override
  String get rawMaterial => 'Materia Prima';

  @override
  String get noRawMaterialsFound => 'Nessuna Materia Prima Trovata';

  @override
  String get rawMaterialAdd => 'Aggiungi Nuovo';

  @override
  String get rawMaterialEdit => 'Modifica Attuale';

  @override
  String get name => 'Nome';

  @override
  String get description => 'Descrizione';

  @override
  String get nameRequired => 'Il nome è obbligatorio';

  @override
  String get quantityRequired => 'La quantità è obbligatoria';

  @override
  String get unitRequired => 'L\'unità è obbligatoria';

  @override
  String get costRequired => 'Il costo è obbligatorio';

  @override
  String get quantityAndUnit => 'Quantità e Unità';

  @override
  String get conversionRates => 'Tassi di Conversione';

  @override
  String get gallery => 'Galleria';

  @override
  String get camera => 'Fotocamera';

  @override
  String get addImage => 'Aggiungi Immagine';

  @override
  String get editImage => 'Modifica Immagine';

  @override
  String get search => 'Cerca';

  @override
  String get imageSelectionError =>
      'Errore durante la selezione dell\'immagine, riprova';

  @override
  String get imageNotSelected => 'Selezione immagine non riuscita';

  @override
  String get cameraPermissionDenied => 'Autorizzazione fotocamera negata';

  @override
  String get mediaPermissionDenied =>
      'Autorizzazione ai contenuti multimediali negata';

  @override
  String get failedToUploadImage => 'Caricamento immagine non riuscito';

  @override
  String get failedToUploadVideo => 'Caricamento video non riuscito';

  @override
  String get delete => 'Elimina';

  @override
  String get deleteConfirmation => 'Sei sicuro di voler eliminare?';

  @override
  String deleteConfirmationWithCount(Object number) {
    return 'Sei sicuro di voler eliminare questi $number articoli';
  }

  @override
  String get cancel => 'Annulla';

  @override
  String get active => 'Attivo';

  @override
  String get discard => 'Scarta';

  @override
  String get cancelConfirmation =>
      'Sei sicuro di voler annullare questo ordine?';

  @override
  String get warning => 'Attenzione';

  @override
  String get ok => 'Ok';

  @override
  String get restore => 'Ripristina';

  @override
  String get restoreConfirmation =>
      'Sei sicuro di voler ripristinare questo ordine';

  @override
  String imagesDeleted(Object number) {
    return 'Hai eliminato $number immagini';
  }

  @override
  String get failedToDeleteImages =>
      'Impossibile eliminare l\'immagine selezionata';

  @override
  String get selected => 'Selezionato';

  @override
  String get changingTypeNotPossible =>
      'Non puoi più cambiare il tipo di attività poiché hai già aggiunto prodotti';

  @override
  String get doubleToAdd =>
      'Tocca due volte sull\'immagine per collegarla a un prodotto';

  @override
  String get client => 'Cliente';

  @override
  String get clients => 'Clienti';

  @override
  String get addClient => 'Aggiungi Cliente';

  @override
  String get editClient => 'Modifica Cliente';

  @override
  String get noClientsFound => 'Nessun Cliente Trovato';

  @override
  String get individual => 'Privato';

  @override
  String get company => 'Azienda';

  @override
  String get phoneNumber => 'Numero di Telefono';

  @override
  String get clientNameEmpty => 'Il nome del cliente non può essere vuoto';

  @override
  String get clientNameInvalid => 'Il nome del cliente non è valido';

  @override
  String get companyNameEmpty =>
      'Il nome dell\'azienda non può essere vuoto, vai su impostazioni -> account e imposta il nome della tua azienda';

  @override
  String get phoneNumberEmpty =>
      'Il numero di telefono non può essere vuoto, vai su impostazioni -> account e imposta il logo della tua azienda';

  @override
  String get phoneCodeEmpty => 'Il prefisso telefonico deve essere selezionato';

  @override
  String get clientName => 'Nome Cliente';

  @override
  String get clientOrders => 'Ordini Cliente';

  @override
  String get clientCompanyName =>
      'Il nome dell\'azienda del cliente non può essere vuoto';

  @override
  String get financialNumber => 'Numero Finanziario';

  @override
  String get crNumber => 'Numero CR';

  @override
  String get ibanNumber => 'Numero IBAN';

  @override
  String get bankName => 'Nome Banca';

  @override
  String get bankBranch => 'Filiale Banca';

  @override
  String get otherPayment => 'Altro Metodo di Pagamento';

  @override
  String get order => 'Ordine';

  @override
  String get due => 'Scaduto';

  @override
  String get overDue => 'In Ritardo';

  @override
  String get clientType => 'Tipo Cliente';

  @override
  String get contactInfo => 'Contatto';

  @override
  String get officialData => 'Dati Ufficiali';

  @override
  String get reports => 'Report';

  @override
  String get capitalAndExpenses => 'Capitale e Spese';

  @override
  String get financialReports => 'Report Finanziari';

  @override
  String get expenses => 'Spese';

  @override
  String get fixedCosts => 'Costi Fissi';

  @override
  String get assets => 'Beni';

  @override
  String get costs => 'Costi';

  @override
  String get noOrdersFound => 'Nessun Ordine Trovato';

  @override
  String get addOrder => 'Aggiungi Ordine';

  @override
  String get editOrder => 'Modifica Ordine';

  @override
  String get itemQuantity => 'Quantità';

  @override
  String get discount => 'Sconto';

  @override
  String get price => 'Prezzo';

  @override
  String get discountedPrice => 'Prezzo Scont.';

  @override
  String get quantityCannotBeEmpty => 'La quantità non può essere vuota';

  @override
  String get priceCannotBeEmpty => 'Il prezzo non può essere vuoto';

  @override
  String get cannotPerformDiscountOnAddedPrice =>
      'Non puoi applicare uno sconto su un aumento di prezzo';

  @override
  String get totalValue => 'Valore Totale';

  @override
  String get productListEmpty => 'L\'elenco prodotti non può essere vuoto';

  @override
  String get orderTerms => 'Termini d\'Ordine';

  @override
  String get deliveryTerms => 'Termini di Consegna';

  @override
  String get deliveryTime => 'Orario di Consegna';

  @override
  String get immediate => 'Immediata';

  @override
  String get scheduled => 'Programmata';

  @override
  String get selectTime => 'Seleziona Orario';

  @override
  String get selectTimeFirst => 'Seleziona Prima l\'Orario';

  @override
  String get selectDate => 'Seleziona Data';

  @override
  String get selectDateFirst => 'Seleziona Prima la Data';

  @override
  String get immediateDelivery => 'L\'ordine verrà consegnato immediatamente';

  @override
  String get noOrderFound => 'Nessun ordine trovato';

  @override
  String get invoice => 'Fattura';

  @override
  String get number => 'Numero';

  @override
  String get subtotal => 'Subtotale';

  @override
  String get total => 'Totale';

  @override
  String get paymentTerms => 'Termini di Pagamento';

  @override
  String get termsandConditions => 'Termini e Condizioni';

  @override
  String termsandConditionDesc(Object provider) {
    return 'Ogni utente deve accettare i termini di $provider prima di procedere';
  }

  @override
  String get apple => 'Apple';

  @override
  String get google => 'Google';

  @override
  String get viewFullTerms =>
      'Puoi visualizzare i termini completi cliccando sul link sottostante';

  @override
  String get agreeToTerms => 'Accetta i Termini';

  @override
  String termsSummaryDetails(Object provider) {
    return 'Gli abbonamenti si rinnovano automaticamente salvo cancellazione almeno 24 ore prima del rinnovo, e tutti gli acquisti sono soggetti alle norme di $provider.';
  }

  @override
  String get iHaveReadAndAgree =>
      'Ho letto e accetto i Termini e le Condizioni';

  @override
  String get readFullTerms => 'Leggi i termini completi';

  @override
  String get needToAgreeToTerms =>
      'Devi verificare e accettare i termini e le condizioni dell\'app';

  @override
  String get ref => 'Rif';

  @override
  String get invoiceNumber => 'Numero Fattura';

  @override
  String get invoiceGenCompleted => 'Generazione fattura completata';

  @override
  String get invoiceGenFailed => 'Generazione fattura non riuscita, riprova';

  @override
  String get returnTerms => 'Reso/Rimborso';

  @override
  String get returnTermsService => 'Rimborso o Annulla';

  @override
  String get close => 'Chiudi';

  @override
  String get unsavedData => 'Hai dati non salvati, salva prima di chiudere';

  @override
  String get returns => 'Resi';

  @override
  String get clientDetails => 'Dettagli Cliente';

  @override
  String get billTo => 'Fatturato A';

  @override
  String get scheduledOrder => 'Questo Ordine è Programmato Per';

  @override
  String get scheduledDate => 'Data Programmata';

  @override
  String get scheduledTime => 'Orario Programmato';

  @override
  String get orderId => 'ID Ordine';

  @override
  String get invoiced => 'Fatturato';

  @override
  String get generateInvoice => 'Genera Fattura';

  @override
  String get generateInvoiceInfo =>
      'Una volta generata la fattura non potrai più modificare il tuo ordine. Se hai bisogno di annullarlo puoi eliminare l\'ordine e crearne uno nuovo';

  @override
  String get generate => 'Genera';

  @override
  String get regenerate => 'Rigenera';

  @override
  String get orderPlacedAt => 'Effettuato Alle';

  @override
  String get noDeliveryTerms => 'Nessun termine di consegna è stato impostato';

  @override
  String get noReturnRefundTermsSet =>
      'Nessun termine di reso/rimborso è stato impostato';

  @override
  String get orderMargins => 'Margini Ordine';

  @override
  String get grossProfit => 'Profitto Lordo';

  @override
  String get margin => 'Margine';

  @override
  String get draft => 'Bozza';

  @override
  String get noStockAvailableInLocation =>
      'Nessuna scorta disponibile nella sede selezionata per questo prodotto';

  @override
  String get insufficientInventory =>
      'Non hai abbastanza scorte nella sede selezionata';

  @override
  String insufficientStockFor(Object item, Object location) {
    return 'Scorte insufficienti per $item in $location';
  }

  @override
  String get confirmed => 'Confermato';

  @override
  String get setReminder => 'Imposta Promemoria';

  @override
  String get reminderMe => 'Ricordamelo';

  @override
  String get reminderNote =>
      'I promemoria devono essere impostati almeno 10 minuti nel futuro';

  @override
  String get notificationDisabled =>
      'Le notifiche sono disattivate, quindi non riceverai promemoria per i tuoi ordini, attivale';

  @override
  String get deliveryCharges => 'Spese di Consegna';

  @override
  String get deliveryFees => 'Costi di Consegna';

  @override
  String get noDeliveryFees => 'Nessun costo di consegna impostato';

  @override
  String get delivery => 'Consegna';

  @override
  String get subscribeToAccess => 'Abbonati per Accedere alle Statistiche';

  @override
  String get cancelled => 'Annullato';

  @override
  String get cancelledOrders => 'Ordini Annullati';

  @override
  String get cancelledOrder =>
      'Vuoi ripristinare questo ordine annullato, premi sì per ripristinarlo e no per mantenerlo annullato';

  @override
  String get orderRemainsCancelled => 'L\'ordine rimane annullato';

  @override
  String get failedToCancelOrder =>
      'Impossibile annullare l\'ordine selezionato, contatta l\'assistenza';

  @override
  String get failedToRestoreOrder =>
      'Impossibile ripristinare l\'ordine selezionato, contatta l\'assistenza';

  @override
  String get orderCancelled => 'L\'Ordine è Annullato';

  @override
  String get receipeIsMissing =>
      'La ricetta è mancante, verifica se è stata eliminata o rimossa, aggiorna nuovamente il prodotto';

  @override
  String get rawItemMissing =>
      'La materia prima è mancante, verifica se è stata eliminata o rimossa, aggiorna nuovamente la ricetta';

  @override
  String get taxValue => 'Valore Imposta';

  @override
  String get failedToDownloadInvoice =>
      'Impossibile scaricare la fattura, controlla la tua connessione';

  @override
  String get collection => 'Riscossione Pagamento';

  @override
  String collectionReminder(Object days) {
    return 'Imposta un promemoria da attivare quando la riscossione è dovuta tra $days giorni';
  }

  @override
  String get shallWeRemindYou => 'Vuoi che ti ricordiamo?';

  @override
  String get quotes => 'Preventivi';

  @override
  String get quoteTerms => 'Termini del Preventivo';

  @override
  String get addQuote => 'Aggiungi Preventivo';

  @override
  String get editQuote => 'Modifica Preventivo';

  @override
  String get noQuotesFound => 'Nessun Preventivo Trovato';

  @override
  String get ordered => 'Ordinato';

  @override
  String get quoteMargins => 'Margini Preventivo';

  @override
  String get quotation => 'Preventivo';

  @override
  String get quoted => 'Preventivato';

  @override
  String get makeOrder => 'Converti in Ordine';

  @override
  String get generateQuote => 'Genera Preventivo';

  @override
  String get edit => 'Modifica';

  @override
  String get dublicate => 'Duplica';

  @override
  String get noAssetsFound => 'Nessun Bene Trovato';

  @override
  String get addAsset => 'Aggiungi Bene';

  @override
  String get editAsset => 'Modifica Bene';

  @override
  String get value => 'Valore';

  @override
  String get imagesOptional => 'Immagini (Opzionale)';

  @override
  String get valueRequired => 'Il valore è obbligatorio';

  @override
  String get dataNotLoading =>
      'I dati non sono stati caricati correttamente, controlla la connessione e riprova';

  @override
  String get noExpenseFound => 'Nessuna Spesa Trovata';

  @override
  String get addExpense => 'Aggiungi Spesa';

  @override
  String get editExpense => 'Modifica Spesa';

  @override
  String get imageCorrupted =>
      'Immagine danneggiata, prova a caricare un\'altra versione';

  @override
  String imageLimit4(Object count) {
    return 'Puoi selezionare al massimo 4 immagini. Ne hai già $count.';
  }

  @override
  String get errorRemovingImage => 'Errore durante la rimozione dell\'immagine';

  @override
  String get details => 'Dettagli';

  @override
  String get apply => 'Applica';

  @override
  String get selectDateRange => 'Seleziona Intervallo Date';

  @override
  String get start => 'Inizio';

  @override
  String get end => 'Fine';

  @override
  String get newsUpdate => 'Novità';

  @override
  String get featuredProducts => 'Prodotti in Evidenza';

  @override
  String get latestNews => 'Ultime Notizie';

  @override
  String get salesReport => 'Report Vendite';

  @override
  String get selectDateInfo =>
      'Seleziona l\'intervallo di date per cui desideri ottenere il registro vendite';

  @override
  String get reportGenSuccess => 'Report Generato con Successo';

  @override
  String get reportGenFailed => 'Generazione Report Non Riuscita';

  @override
  String get date => 'Data';

  @override
  String get productCount => 'Conteggio Prodotti';

  @override
  String get from => 'Da';

  @override
  String get to => 'a';

  @override
  String get totalSalesValue => 'Valore Totale Vendite';

  @override
  String get summary => 'Riepilogo';

  @override
  String get totalOrders => 'Ordini Totali';

  @override
  String get financialDetails => 'Dettagli Finanziari';

  @override
  String get pandLReport => 'Report Profitti e Perdite';

  @override
  String get plVariables => 'Variabili P & L';

  @override
  String get selectDatePL =>
      'Seleziona l\'intervallo di date in cui mostrare il report profitti e perdite';

  @override
  String get selectOptions => 'Seleziona Opzioni';

  @override
  String get optionsSummary => 'Riepilogo Opzioni';

  @override
  String get noOptionsSelected => 'Nessuna opzione selezionata';

  @override
  String get noPreviousRecordSaved =>
      'Nessun record precedente è stato salvato';

  @override
  String get export => 'Esporta';

  @override
  String get dateRangeisCrucial =>
      'L\'intervallo di date è obbligatorio, selezionalo prima di procedere';

  @override
  String get saveRecord => 'Salva Record';

  @override
  String get plSummary => 'Riepilogo P & L';

  @override
  String get profitLossStatement => 'Conto Economico';

  @override
  String get period => 'Periodo';

  @override
  String get totalRevenue => 'Ricavi Totali';

  @override
  String get operatingExpenses => 'Spese Operative';

  @override
  String get operatingIncome => 'Reddito Operativo';

  @override
  String get nonOperatingIncomeExpense => 'Proventi/Oneri Non Operativi';

  @override
  String get earningBeforeTax => 'Utili Prima delle Imposte';

  @override
  String get taxDesc =>
      'Imposta solo la tassa che ti riguarda, se lasci il campo vuoto la tassa non sarà inclusa nei tuoi registri finanziari';

  @override
  String get incomeTax => 'Imposta sul Reddito';

  @override
  String get salesTax => 'Imposta sulle Vendite';

  @override
  String get stateTax => 'Imposta Statale';

  @override
  String get governmentTax => 'Imposta Governativa';

  @override
  String get netIncome => 'Reddito Netto';

  @override
  String get detailedBreakDown => 'Ripartizione Dettagliata';

  @override
  String get nonOperatingItems => 'Voci Non Operative';

  @override
  String get investmentIncome => 'Reddito da Investimenti';

  @override
  String get interestExpense => 'Oneri Finanziari';

  @override
  String get foreignExchange => 'Utile/Perdita su Cambi Esteri';

  @override
  String get keyFinancialMetrics => 'Indicatori Finanziari Chiave';

  @override
  String get grossProfitMargin => 'Margine di Profitto Lordo';

  @override
  String get operatingMargin => 'Margine Operativo';

  @override
  String get netProfitMargin => 'Margine di Profitto Netto';

  @override
  String get percentageCogs => 'COGS % dei Ricavi';

  @override
  String get saveFinancialRecord =>
      'Vuoi salvare questi dati per un utilizzo futuro?';

  @override
  String get pandLStatement => 'Rendiconto P & L';

  @override
  String get failedToRetrieveData => 'Impossibile recuperare i dati';

  @override
  String get connectionLost => 'Connessione Persa';

  @override
  String get checkYourConnection => 'Controlla la tua connessione Internet';

  @override
  String get topProducts => 'Articoli Principali';

  @override
  String get soldQuantity => 'Quantità Venduta';

  @override
  String get averagePrice => 'Prezzo Medio';

  @override
  String get subscribe => 'Abbonati';

  @override
  String get premiumUser => 'Premium';

  @override
  String get googlePlay => 'Google Play Store';

  @override
  String get appleStore => 'Apple Store';

  @override
  String paymenetCharging(Object store) {
    return 'Il pagamento verrà addebitato sul tuo account (store) alla conferma dell\'acquisto. L\'abbonamento si rinnova automaticamente a meno che il rinnovo automatico non venga disattivato almeno 24 ore prima della fine del periodo corrente.';
  }

  @override
  String get privacyAndTerms => 'Informativa sulla Privacy';

  @override
  String get termsOfUse => 'Termini di Utilizzo';

  @override
  String get cont => 'Continua';

  @override
  String get popular => 'POPOLARE';

  @override
  String get goPremium => 'Passa a Premium';

  @override
  String get unlockAll => 'Sblocca tutte le funzionalità e i contenuti';

  @override
  String get unlimitedAccess => 'Accesso illimitato a tutti i contenuti';

  @override
  String get exclusivePremium => 'Funzionalità premium esclusive';

  @override
  String get syncAll => 'Sincronizza su tutti i tuoi dispositivi';

  @override
  String get prioritySup => 'Assistenza prioritaria';

  @override
  String get success => 'Successo';

  @override
  String get processing => 'Elaborazione in corso...';

  @override
  String get welcomePre => 'Benvenuto in Premium!';

  @override
  String get startUsing => 'Inizia a Usare l\'App';

  @override
  String get upgradeToUnlock =>
      'Esegui l\'upgrade per sbloccare questa funzione';

  @override
  String get viewSub => 'Visualizza Abbonamenti';

  @override
  String get notNow => 'Non Ora';

  @override
  String get sevenDayFree =>
      'Prova GRATUITA di 7 giorni • Annulla in qualsiasi momento durante la prova';

  @override
  String get sevenDayDes =>
      'Dopo il periodo di prova, il tuo abbonamento si rinnoverà automaticamente e ti verrà addebitato in base al piano selezionato.';

  @override
  String get enterCoupon => 'Inserisci Codice Coupon';

  @override
  String get applyCoupon => 'Applica Codice Coupon';

  @override
  String couponApplied(Object discount) {
    return 'Coupon applicato: $discount% di sconto';
  }

  @override
  String get cancelSupscription => 'Annulla Abbonamento';

  @override
  String get cancelSubWarning =>
      'Sei sicuro di voler annullare il tuo abbonamento e perdere tutte le funzionalità aggiunte?';

  @override
  String freeTrialDays(Object days) {
    return '$days giorni di prova gratuita';
  }

  @override
  String get freeTrial => 'Prova Gratuita';

  @override
  String get purchaseFailed => 'Acquisto Non Riuscito';

  @override
  String get purchaseCancelled => 'Acquisto Annullato';

  @override
  String get invalidCoupon => 'Codice coupon non valido o scaduto';

  @override
  String appliedCoupon(Object coupon) {
    return 'Coupon applicato con successo! Sconto del \$$coupon%';
  }

  @override
  String get totalToBePaid => 'Totale da Pagare';

  @override
  String get freeMonth => 'Mese Gratuito';

  @override
  String get freeYear => 'Anno Gratuito';

  @override
  String get selectPlan => 'Seleziona Prima un Piano';

  @override
  String get noOfferingsAvailable => 'Nessuna offerta disponibile';

  @override
  String get selectedPlanNotAvailable =>
      'Il piano selezionato non è disponibile';

  @override
  String get purchaseInactive => 'L\'acquisto è inattivo';

  @override
  String get unableToLoadPlans => 'Impossibile caricare i piani, riprova';

  @override
  String get premiumActive => 'Premium Attivo!';

  @override
  String get enjoyFreeTrial =>
      'Stai attualmente usufruendo della tua prova gratuita';

  @override
  String get enjoyPremium => 'Benvenuto in CostEra Pro!';

  @override
  String get currentPlan => 'Piano Attuale';

  @override
  String get freeTrialActive => 'Prova Gratuita Attiva';

  @override
  String get trialEndsOn => 'La prova termina il';

  @override
  String get memberSince => 'Membro dal';

  @override
  String get yourBenefits => 'I Tuoi Vantaggi Premium';

  @override
  String get generatePdfInvoice => 'Fatture PDF';

  @override
  String get createProfessionalInvoices =>
      'Crea fatture PDF professionali istantaneamente';

  @override
  String get detailedFinancialInsights =>
      'Genera report finanziari dettagliati e approfondimenti';

  @override
  String get expenseTracking => 'Monitoraggio Spese';

  @override
  String get monitorAllExpenses =>
      'Monitora e categorizza tutte le tue spese aziendali';

  @override
  String get unlimitedProducts => 'Prodotti Illimitati';

  @override
  String get addUnlimitedItems =>
      'Aggiungi prodotti e servizi illimitati al tuo catalogo';

  @override
  String get cloudSync => 'Sincronizzazione Cloud';

  @override
  String get syncAcrossDevices =>
      'Sincronizza i tuoi dati su tutti i tuoi dispositivi in modo sicuro';

  @override
  String get prioritySupport => 'Assistenza Prioritaria';

  @override
  String get createAndSendQuotes => 'Crea e invia preventivi professionali';

  @override
  String get suppliersAccess => 'Accesso Fornitori';

  @override
  String get manageYourSuppliers => 'Gestisci e monitora i tuoi fornitori';

  @override
  String get inventoryTracking => 'Monitoraggio Inventario';

  @override
  String get trackStockInRealTime =>
      'Monitora i livelli di scorta in tempo reale';

  @override
  String get orderReminders => 'Promemoria Ordini e Pagamenti';

  @override
  String get neverMissAPayment => 'Non perdere mai una scadenza o un pagamento';

  @override
  String get fasterCustomerSupport =>
      'Ottieni risposte più rapide dal nostro team di assistenza';

  @override
  String get cancelSubscription => 'Annulla Abbonamento';

  @override
  String get cancelAnyTime =>
      'Puoi annullare il tuo abbonamento in qualsiasi momento';

  @override
  String get loadingSubscription => 'Caricamento informazioni abbonamento...';

  @override
  String get errorLoadingSubscription =>
      'Errore nel caricamento dell\'abbonamento';

  @override
  String get cancelSubAtPeriodEnd =>
      'Il tuo abbonamento rimarrà attivo fino alla fine del periodo di fatturazione corrente. Continuerai a godere di tutti i vantaggi premium fino ad allora.';

  @override
  String get subscriptionWillCancel =>
      'Il tuo abbonamento verrà annullato alla fine del periodo di fatturazione corrente.';

  @override
  String get accessUntil => 'Accesso fino al';

  @override
  String get renewsOn => 'Si rinnova il';

  @override
  String get cancellationRequested => 'Annullamento richiesto il';

  @override
  String get subscriptionExpired => 'Abbonamento Scaduto';

  @override
  String get premiumBenefitsGone =>
      'I tuoi vantaggi premium non sono più attivi. Rinnova il tuo abbonamento per continuare a usufruire di tutte le funzionalità.';

  @override
  String get daysLeft => 'giorni rimanenti per Premium';

  @override
  String get noActiveSubscription => 'Nessun abbonamento attivo trovato';

  @override
  String get manageSubscriptionThrough => 'Gestisci il tuo abbonamento tramite';

  @override
  String get appStore => 'App Store';

  @override
  String get resumeSubscription => 'Riprendi Abbonamento';

  @override
  String get resumeSubscriptionConfirm =>
      'Sei sicuro di voler riprendere il tuo abbonamento? Il tuo abbonamento continuerà e si rinnoverà automaticamente come di consueto.';

  @override
  String get resumeSubscriptionDesc =>
      'Continua il tuo abbonamento e mantieni tutti i vantaggi';

  @override
  String get resubscribe => 'Ri-abbonati';

  @override
  String get subscriptionResumed => 'Il tuo abbonamento è stato ripreso!';

  @override
  String get cancellationPending =>
      'L\'annullamento del tuo abbonamento è in sospeso. Puoi riprenderlo in qualsiasi momento prima della data di fine.';

  @override
  String get failedToResume => 'Ripresa non riuscita';

  @override
  String get failedToCancel => 'Annullamento non riuscito';

  @override
  String get then => 'Poi';

  @override
  String get autoRenewal => 'Informazioni sul Rinnovo Automatico';

  @override
  String autoRenewalDes(Object store) {
    return 'Il tuo abbonamento si rinnoverà automaticamente alla fine di ogni periodo a meno che non venga annullato almeno 24 ore prima della fine del periodo corrente. Puoi gestire o annullare il tuo abbonamento in qualsiasi momento tramite le impostazioni del tuo account $store.';
  }

  @override
  String get daysFree => '-Giorni di Prova Gratuita';

  @override
  String subscriptionFeature(Object feature) {
    return 'La funzione $feature è disponibile solo per utenti a pagamento, valuta di abbonarti per un accesso illimitato';
  }

  @override
  String subscriptionOrderFeature(Object feature, Object number) {
    return 'Hai raggiunto il limite di $feature per utenti gratuiti di $number ordini, valuta di abbonarti per un accesso illimitato a tutte le funzionalità e ordini';
  }

  @override
  String get theFor => 'per';

  @override
  String get months => 'mesi';

  @override
  String get salesStats => 'Statistiche di Vendita';

  @override
  String get sales => 'Vendite';

  @override
  String get topClient => 'Miglior Cliente';

  @override
  String get totalSales => 'Vendite Totali';

  @override
  String get averageMargin => 'Margine Medio';

  @override
  String get topFiveClients => 'Migliori 5 Clienti';

  @override
  String get profitDist => 'Distribuzione Margine di Profitto';

  @override
  String get annual => 'Annuale';

  @override
  String get monthly => 'Mensile';

  @override
  String get revenueSplit => 'Ripartizione Ricavi';

  @override
  String get profit => 'Profitto';

  @override
  String get viewAll => 'Vedi Tutto';

  @override
  String get dueSoon => 'In Scadenza';

  @override
  String get onTrack => 'In Linea';

  @override
  String get noUpcomingPayments => 'Nessun Pagamento in Arrivo';

  @override
  String get operationTimedOut =>
      'Operazione scaduta, controlla la tua connessione e riprova';

  @override
  String get today => 'Oggi';

  @override
  String get yesterday => 'Ieri';

  @override
  String get thisWeek => 'Questa Settimana';

  @override
  String get lastWeek => 'Settimana Scorsa';

  @override
  String get thisMonth => 'Questo Mese';

  @override
  String get lastMonth => 'Mese Scorso';

  @override
  String get thisYear => 'Quest\'Anno';

  @override
  String get lastYear => 'Anno Scorso';

  @override
  String get selectPeriod => 'Seleziona Periodo';

  @override
  String get inventoryReport => 'Report Inventario';

  @override
  String get keepEmptyForAllLocations => 'Lascia vuoto per tutte le sedi';

  @override
  String get storeName => 'Nome Sede';

  @override
  String get productStock => 'Scorte';

  @override
  String get code => 'Codice';

  @override
  String get tutorialCompleted => 'Tutorial Completato';

  @override
  String get tutOrderScreenDes =>
      'Il calendario ordini terrà traccia dei tuoi ordini mensili';

  @override
  String get tutQuotesDes =>
      'I preventivi ti permettono di creare preventivi per i tuoi clienti prima di creare un ordine e fatturare';

  @override
  String get tutDashScreenDes =>
      'Il nostro pulsante home o dashboard mostrerà i tuoi progressi mensili';

  @override
  String get tutProductScreenDes =>
      'Qui puoi creare, modificare e regolare i prodotti. Tutti i tuoi prodotti sono accessibili da questa pagina';

  @override
  String get tutSettingScreeDes =>
      'La schermata delle impostazioni fornirà tutte le funzionalità per la tua app';

  @override
  String get next => 'Avanti';

  @override
  String get finish => 'Fine';

  @override
  String get tutorial => 'Tutorial';

  @override
  String get tutorialSkipped => 'Tutorial Saltato';

  @override
  String get startTutorial => 'Avvia Tutorial';

  @override
  String get skipTutorial => 'Salta Tutorial';

  @override
  String get tutorialWelcome => 'Benvenuto!';

  @override
  String get tutorialStartPrompt => 'Impariamo come usare l\'app';

  @override
  String get tutgalleryDes =>
      'Tutte le immagini dei tuoi prodotti o servizi possono essere caricate qui';

  @override
  String get tutProfileDes =>
      'Modifica tutti i tuoi dati personali dalla sezione profilo';

  @override
  String get tutAccountDes =>
      'Modifica le informazioni della tua attività dalla sezione account';

  @override
  String get tutAppSettingDes =>
      'Modifica le impostazioni dell\'app come colore, tema e altro da qui!';

  @override
  String get tutClientDes =>
      'Aggiungi e modifica i dettagli dei tuoi clienti da qui';

  @override
  String get tutOrdersDes =>
      'Puoi creare e modificare i tuoi ordini tramite la scheda ordini';

  @override
  String get tutSupplierDes =>
      'La scheda Fornitori ti permette di aggiungere fornitori ed emettere acquisti';

  @override
  String get tutPurchasesDes =>
      'La scheda Acquisti ti permetterà di emettere e modificare acquisti';

  @override
  String get tutCapExpReportDes =>
      'La scheda Capitale e Spese è essenziale per controllare le tue spese';

  @override
  String get tutFinancialReportDes =>
      'Monitora la tua attività e sappi come stai andando emettendo i report necessari';

  @override
  String get tutFilterOptionDes =>
      'L\'opzione filtro ti permetterà di cercare un articolo specifico o filtrare per diverse variabili';

  @override
  String get tutAddProductDes =>
      'Il pulsante aggiungi ti permetterà di aggiungere prodotti o servizi!';

  @override
  String get tutPaymentDes =>
      'Mostrerà tutti i pagamenti a credito dei tuoi clienti';

  @override
  String get days15 => '15 giorni';

  @override
  String get days30 => '30 giorni';

  @override
  String get days45 => '45 giorni';

  @override
  String get more => 'Altro';

  @override
  String get all => 'Tutti';

  @override
  String get dueOn => 'Scade il';

  @override
  String get addPayment => 'Aggiungi Pagamento';

  @override
  String get editPayment => 'Modifica Pagamento';

  @override
  String get upcomingPayments => 'Pagamenti in Arrivo';

  @override
  String get updatePayment => 'Aggiorna Pagamento';

  @override
  String partialPayment(Object amount) {
    return 'Il pagamento non copre l\'importo richiesto, il saldo rimanente di $amount rimarrà in sospeso';
  }

  @override
  String paymentOverpaid(Object amount) {
    return 'Il pagamento supera il saldo richiesto, l\'importo aggiuntivo di $amount verrà aggiunto al cliente come credito';
  }

  @override
  String get paymentCovered =>
      'Il pagamento è completamente coperto e la fattura a credito verrà chiusa di conseguenza';

  @override
  String get clientStatement => 'Estratto Conto Cliente';

  @override
  String get method => 'Metodo di pagamento';

  @override
  String get optional => 'Opzionale';

  @override
  String get faq => 'Domande Frequenti';

  @override
  String get question => 'Domanda';

  @override
  String get answer => 'Risposta';

  @override
  String get referenceOrder => 'Riferimento Ordine';

  @override
  String get questionEmpty => 'L\'elenco domande è vuoto';

  @override
  String get questionIsEmpty => 'La domanda non può essere vuota';

  @override
  String get answerIsEmpty => 'La risposta non può essere vuota';

  @override
  String get referenceIsEmpty => 'Il riferimento non può essere vuoto';

  @override
  String get referenceOrderExits =>
      'L\'ordine di riferimento esiste già, selezionane un altro';
}
