import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get languageSystem;

  /// No description provided for @languageEs.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get languageEs;

  /// No description provided for @languageEn.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @languagePt.
  ///
  /// In es, this message translates to:
  /// **'Português'**
  String get languagePt;

  /// No description provided for @appearance.
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get appearance;

  /// No description provided for @appearanceSystem.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get appearanceSystem;

  /// No description provided for @appearanceLight.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get appearanceLight;

  /// No description provided for @appearanceDark.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get appearanceDark;

  /// No description provided for @profileTitle.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get profileTitle;

  /// No description provided for @profileName.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get profileName;

  /// No description provided for @profileEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get profileEmail;

  /// No description provided for @profileSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get profileSave;

  /// No description provided for @profileSaved.
  ///
  /// In es, this message translates to:
  /// **'Perfil guardado.'**
  String get profileSaved;

  /// No description provided for @profileLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar el perfil: {error}'**
  String profileLoadError(String error);

  /// No description provided for @profileSaveError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar: {error}'**
  String profileSaveError(String error);

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @privacyAndData.
  ///
  /// In es, this message translates to:
  /// **'Privacidad y mis datos'**
  String get privacyAndData;

  /// No description provided for @changeEmail.
  ///
  /// In es, this message translates to:
  /// **'Cambiar correo'**
  String get changeEmail;

  /// No description provided for @changePassword.
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get changePassword;

  /// No description provided for @signOut.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get signOut;

  /// No description provided for @deleteAccountButton.
  ///
  /// In es, this message translates to:
  /// **'Eliminar mi cuenta'**
  String get deleteAccountButton;

  /// No description provided for @welcomeTagline.
  ///
  /// In es, this message translates to:
  /// **'La salud y felicidad de tu compañero,\ntodo en un solo lugar.'**
  String get welcomeTagline;

  /// No description provided for @getStarted.
  ///
  /// In es, this message translates to:
  /// **'Comenzar'**
  String get getStarted;

  /// No description provided for @signIn.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get signIn;

  /// No description provided for @termsPrefix.
  ///
  /// In es, this message translates to:
  /// **'Al continuar, aceptás nuestros '**
  String get termsPrefix;

  /// No description provided for @termsOfService.
  ///
  /// In es, this message translates to:
  /// **'Términos del servicio'**
  String get termsOfService;

  /// No description provided for @termsAnd.
  ///
  /// In es, this message translates to:
  /// **' y la '**
  String get termsAnd;

  /// No description provided for @privacyPolicy.
  ///
  /// In es, this message translates to:
  /// **'Política de privacidad'**
  String get privacyPolicy;

  /// No description provided for @welcomeBack.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido de nuevo'**
  String get welcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Iniciá sesión para gestionar los cuidados de tu mascota.'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get passwordLabel;

  /// No description provided for @forgotPassword.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get forgotPassword;

  /// No description provided for @orSeparator.
  ///
  /// In es, this message translates to:
  /// **'o'**
  String get orSeparator;

  /// No description provided for @continueWithGoogle.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get continueWithGoogle;

  /// No description provided for @noAccountPrefix.
  ///
  /// In es, this message translates to:
  /// **'¿No tenés una cuenta? '**
  String get noAccountPrefix;

  /// No description provided for @signUp.
  ///
  /// In es, this message translates to:
  /// **'Registrate'**
  String get signUp;

  /// No description provided for @hasAccountPrefix.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tenés una cuenta? '**
  String get hasAccountPrefix;

  /// No description provided for @createAccountTitle.
  ///
  /// In es, this message translates to:
  /// **'Creá tu cuenta'**
  String get createAccountTitle;

  /// No description provided for @createAccountSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Completá tus datos para empezar.'**
  String get createAccountSubtitle;

  /// No description provided for @fullName.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Juana Pérez'**
  String get fullNameHint;

  /// No description provided for @confirmPassword.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get confirmPassword;

  /// No description provided for @createAccount.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get createAccount;

  /// No description provided for @errEnterEmail.
  ///
  /// In es, this message translates to:
  /// **'Escribí tu correo electrónico.'**
  String get errEnterEmail;

  /// No description provided for @errInvalidEmail.
  ///
  /// In es, this message translates to:
  /// **'El correo no tiene un formato válido.'**
  String get errInvalidEmail;

  /// No description provided for @errEnterPassword.
  ///
  /// In es, this message translates to:
  /// **'Escribí tu contraseña.'**
  String get errEnterPassword;

  /// No description provided for @errEmailAbove.
  ///
  /// In es, this message translates to:
  /// **'Escribí tu correo arriba y volvé a pulsar aquí.'**
  String get errEmailAbove;

  /// No description provided for @errEnterName.
  ///
  /// In es, this message translates to:
  /// **'Escribí tu nombre.'**
  String get errEnterName;

  /// No description provided for @errPasswordShort.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 6 caracteres.'**
  String get errPasswordShort;

  /// No description provided for @errPasswordMismatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden.'**
  String get errPasswordMismatch;

  /// No description provided for @resetEmailSent.
  ///
  /// In es, this message translates to:
  /// **'Te enviamos un correo a {email}.'**
  String resetEmailSent(String email);

  /// No description provided for @showPassword.
  ///
  /// In es, this message translates to:
  /// **'Mostrar contraseña'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In es, this message translates to:
  /// **'Ocultar contraseña'**
  String get hidePassword;

  /// No description provided for @navHome.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get navHome;

  /// No description provided for @navPets.
  ///
  /// In es, this message translates to:
  /// **'Mascotas'**
  String get navPets;

  /// No description provided for @navTasks.
  ///
  /// In es, this message translates to:
  /// **'Tareas'**
  String get navTasks;

  /// No description provided for @navProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get navProfile;

  /// No description provided for @tasksTitle.
  ///
  /// In es, this message translates to:
  /// **'Tareas'**
  String get tasksTitle;

  /// No description provided for @tasksLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar las tareas: {error}'**
  String tasksLoadError(String error);

  /// No description provided for @genericSaveError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar: {error}'**
  String genericSaveError(String error);

  /// No description provided for @addPetFirst.
  ///
  /// In es, this message translates to:
  /// **'Agregá una mascota antes de crear una tarea.'**
  String get addPetFirst;

  /// No description provided for @newTask.
  ///
  /// In es, this message translates to:
  /// **'Nueva tarea'**
  String get newTask;

  /// No description provided for @petLabel.
  ///
  /// In es, this message translates to:
  /// **'Mascota'**
  String get petLabel;

  /// No description provided for @taskPrompt.
  ///
  /// In es, this message translates to:
  /// **'¿Qué hay que hacer?'**
  String get taskPrompt;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @noTasks.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay tareas.'**
  String get noTasks;

  /// No description provided for @deleteTask.
  ///
  /// In es, this message translates to:
  /// **'Eliminar tarea'**
  String get deleteTask;

  /// No description provided for @speciesDog.
  ///
  /// In es, this message translates to:
  /// **'Perro'**
  String get speciesDog;

  /// No description provided for @speciesCat.
  ///
  /// In es, this message translates to:
  /// **'Gato'**
  String get speciesCat;

  /// No description provided for @speciesOther.
  ///
  /// In es, this message translates to:
  /// **'Otra'**
  String get speciesOther;

  /// No description provided for @ageDays.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{{count} día} other{{count} días}}'**
  String ageDays(int count);

  /// No description provided for @ageWeeks.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{{count} semana} other{{count} semanas}}'**
  String ageWeeks(int count);

  /// No description provided for @ageMonths.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{{count} mes} other{{count} meses}}'**
  String ageMonths(int count);

  /// No description provided for @ageYears.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{{count} año} other{{count} años}}'**
  String ageYears(int count);

  /// No description provided for @petsLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar tus mascotas'**
  String get petsLoadError;

  /// No description provided for @petsEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Todavía no tenés mascotas'**
  String get petsEmptyTitle;

  /// No description provided for @petsEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Agregá la primera para empezar a llevar sus cuidados.'**
  String get petsEmptyBody;

  /// No description provided for @addPet.
  ///
  /// In es, this message translates to:
  /// **'Agregar mascota'**
  String get addPet;

  /// No description provided for @myPets.
  ///
  /// In es, this message translates to:
  /// **'Mis mascotas'**
  String get myPets;

  /// No description provided for @myPetsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Gestioná a los miembros peludos de tu familia.'**
  String get myPetsSubtitle;

  /// No description provided for @statusNoVaccines.
  ///
  /// In es, this message translates to:
  /// **'Sin vacunas'**
  String get statusNoVaccines;

  /// No description provided for @statusOverdue.
  ///
  /// In es, this message translates to:
  /// **'Vacuna vencida'**
  String get statusOverdue;

  /// No description provided for @statusDueSoon.
  ///
  /// In es, this message translates to:
  /// **'Vacuna próxima'**
  String get statusDueSoon;

  /// No description provided for @statusHealthy.
  ///
  /// In es, this message translates to:
  /// **'Sano'**
  String get statusHealthy;

  /// No description provided for @options.
  ///
  /// In es, this message translates to:
  /// **'Opciones'**
  String get options;

  /// No description provided for @edit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @cellStatus.
  ///
  /// In es, this message translates to:
  /// **'ESTADO'**
  String get cellStatus;

  /// No description provided for @cellWeight.
  ///
  /// In es, this message translates to:
  /// **'PESO'**
  String get cellWeight;

  /// No description provided for @noRecord.
  ///
  /// In es, this message translates to:
  /// **'Sin registro'**
  String get noRecord;

  /// No description provided for @goodMorning.
  ///
  /// In es, this message translates to:
  /// **'¡Buenos días!'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In es, this message translates to:
  /// **'¡Buenas tardes!'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In es, this message translates to:
  /// **'¡Buenas noches!'**
  String get goodEvening;

  /// No description provided for @goodMorningName.
  ///
  /// In es, this message translates to:
  /// **'¡Buenos días, {name}!'**
  String goodMorningName(String name);

  /// No description provided for @goodAfternoonName.
  ///
  /// In es, this message translates to:
  /// **'¡Buenas tardes, {name}!'**
  String goodAfternoonName(String name);

  /// No description provided for @goodEveningName.
  ///
  /// In es, this message translates to:
  /// **'¡Buenas noches, {name}!'**
  String goodEveningName(String name);

  /// No description provided for @todayAgenda.
  ///
  /// In es, this message translates to:
  /// **'Esta es tu agenda de hoy.'**
  String get todayAgenda;

  /// No description provided for @activitySummary.
  ///
  /// In es, this message translates to:
  /// **'Resumen de actividad'**
  String get activitySummary;

  /// No description provided for @viewWalkHistory.
  ///
  /// In es, this message translates to:
  /// **'Ver historial de paseos'**
  String get viewWalkHistory;

  /// No description provided for @todayTitle.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get todayTitle;

  /// No description provided for @noTasksToday.
  ///
  /// In es, this message translates to:
  /// **'No tenés tareas para hoy.'**
  String get noTasksToday;

  /// No description provided for @completedLabel.
  ///
  /// In es, this message translates to:
  /// **'Completada'**
  String get completedLabel;

  /// No description provided for @updateTaskError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo actualizar la tarea: {error}'**
  String updateTaskError(String error);

  /// No description provided for @onlyOnePet.
  ///
  /// In es, this message translates to:
  /// **'Solo tenés una mascota por ahora.'**
  String get onlyOnePet;

  /// No description provided for @changePet.
  ///
  /// In es, this message translates to:
  /// **'Cambiar de mascota'**
  String get changePet;

  /// No description provided for @yourAccount.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta'**
  String get yourAccount;

  /// No description provided for @signedIn.
  ///
  /// In es, this message translates to:
  /// **'Sesión iniciada'**
  String get signedIn;

  /// No description provided for @loadingEllipsis.
  ///
  /// In es, this message translates to:
  /// **'Cargando…'**
  String get loadingEllipsis;

  /// No description provided for @noPets.
  ///
  /// In es, this message translates to:
  /// **'Sin mascotas'**
  String get noPets;

  /// No description provided for @tapToAddFirst.
  ///
  /// In es, this message translates to:
  /// **'Tocá para agregar la primera'**
  String get tapToAddFirst;

  /// No description provided for @startWalk.
  ///
  /// In es, this message translates to:
  /// **'Iniciar paseo'**
  String get startWalk;

  /// No description provided for @readyForAdventure.
  ///
  /// In es, this message translates to:
  /// **'¿Listos para una aventura?'**
  String get readyForAdventure;

  /// No description provided for @lastWalk.
  ///
  /// In es, this message translates to:
  /// **'Último paseo'**
  String get lastWalk;

  /// No description provided for @activeTime.
  ///
  /// In es, this message translates to:
  /// **'Tiempo activo'**
  String get activeTime;

  /// No description provided for @loadingShort.
  ///
  /// In es, this message translates to:
  /// **'Cargando'**
  String get loadingShort;

  /// No description provided for @noWalks.
  ///
  /// In es, this message translates to:
  /// **'Sin paseos'**
  String get noWalks;

  /// No description provided for @noWalksToday.
  ///
  /// In es, this message translates to:
  /// **'Sin paseos hoy'**
  String get noWalksToday;

  /// No description provided for @walksToday.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{{count} paseo hoy} other{{count} paseos hoy}}'**
  String walksToday(int count);

  /// No description provided for @minutesShort.
  ///
  /// In es, this message translates to:
  /// **'{count} min'**
  String minutesShort(int count);

  /// No description provided for @todayAt.
  ///
  /// In es, this message translates to:
  /// **'Hoy, {time}'**
  String todayAt(String time);

  /// No description provided for @yesterdayAt.
  ///
  /// In es, this message translates to:
  /// **'Ayer, {time}'**
  String yesterdayAt(String time);

  /// No description provided for @markPending.
  ///
  /// In es, this message translates to:
  /// **'Marcar pendiente'**
  String get markPending;

  /// No description provided for @markDone.
  ///
  /// In es, this message translates to:
  /// **'Marcar completada'**
  String get markDone;

  /// No description provided for @logout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get logout;

  /// No description provided for @pickFromGallery.
  ///
  /// In es, this message translates to:
  /// **'Elegir de la galería'**
  String get pickFromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In es, this message translates to:
  /// **'Tomar una foto'**
  String get takePhoto;

  /// No description provided for @removePhoto.
  ///
  /// In es, this message translates to:
  /// **'Quitar foto'**
  String get removePhoto;

  /// No description provided for @uploadPhoto.
  ///
  /// In es, this message translates to:
  /// **'Subir foto'**
  String get uploadPhoto;

  /// No description provided for @changePhoto.
  ///
  /// In es, this message translates to:
  /// **'Cambiar foto'**
  String get changePhoto;

  /// No description provided for @birthDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de nacimiento'**
  String get birthDate;

  /// No description provided for @errEnterPetName.
  ///
  /// In es, this message translates to:
  /// **'Escribí el nombre.'**
  String get errEnterPetName;

  /// No description provided for @errWeightInvalid.
  ///
  /// In es, this message translates to:
  /// **'El peso no es un número válido.'**
  String get errWeightInvalid;

  /// No description provided for @errWeightRange.
  ///
  /// In es, this message translates to:
  /// **'El peso tiene que estar entre 0 y 200 kg.'**
  String get errWeightRange;

  /// No description provided for @editPet.
  ///
  /// In es, this message translates to:
  /// **'Editar mascota'**
  String get editPet;

  /// No description provided for @editPetSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Actualizá los datos de {name}.'**
  String editPetSubtitle(String name);

  /// No description provided for @addPetSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Contanos sobre tu compañero para personalizar sus cuidados.'**
  String get addPetSubtitle;

  /// No description provided for @savePet.
  ///
  /// In es, this message translates to:
  /// **'Guardar mascota'**
  String get savePet;

  /// No description provided for @nameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get nameLabel;

  /// No description provided for @nameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Bella'**
  String get nameHint;

  /// No description provided for @speciesLabel.
  ///
  /// In es, this message translates to:
  /// **'Especie'**
  String get speciesLabel;

  /// No description provided for @breedLabel.
  ///
  /// In es, this message translates to:
  /// **'Raza'**
  String get breedLabel;

  /// No description provided for @breedHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Golden Retriever'**
  String get breedHint;

  /// No description provided for @weightKgLabel.
  ///
  /// In es, this message translates to:
  /// **'Peso (kg)'**
  String get weightKgLabel;

  /// No description provided for @notesLabel.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get notesLabel;

  /// No description provided for @optional.
  ///
  /// In es, this message translates to:
  /// **'Opcional'**
  String get optional;

  /// No description provided for @notesHint.
  ///
  /// In es, this message translates to:
  /// **'Alergias, número de microchip, manías...'**
  String get notesHint;

  /// No description provided for @datePlaceholder.
  ///
  /// In es, this message translates to:
  /// **'dd/mm/aaaa'**
  String get datePlaceholder;

  /// No description provided for @addVaccine.
  ///
  /// In es, this message translates to:
  /// **'Añadir vacuna'**
  String get addVaccine;

  /// No description provided for @editVaccine.
  ///
  /// In es, this message translates to:
  /// **'Editar vacuna'**
  String get editVaccine;

  /// No description provided for @vaccineName.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la vacuna'**
  String get vaccineName;

  /// No description provided for @applicationDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de aplicación'**
  String get applicationDate;

  /// No description provided for @nextDose.
  ///
  /// In es, this message translates to:
  /// **'Próxima dosis'**
  String get nextDose;

  /// No description provided for @remindInAdvance.
  ///
  /// In es, this message translates to:
  /// **'Avisar con anticipación'**
  String get remindInAdvance;

  /// No description provided for @daysUnit.
  ///
  /// In es, this message translates to:
  /// **'días'**
  String get daysUnit;

  /// No description provided for @errRange0to365.
  ///
  /// In es, this message translates to:
  /// **'Ingresá un valor entre 0 y 365.'**
  String get errRange0to365;

  /// No description provided for @logFeeding.
  ///
  /// In es, this message translates to:
  /// **'Registrar alimentación'**
  String get logFeeding;

  /// No description provided for @foodType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de alimento'**
  String get foodType;

  /// No description provided for @foodTypeHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. alimento seco'**
  String get foodTypeHint;

  /// No description provided for @amountLabel.
  ///
  /// In es, this message translates to:
  /// **'Cantidad'**
  String get amountLabel;

  /// No description provided for @errValidAmount.
  ///
  /// In es, this message translates to:
  /// **'Ingresá una cantidad válida.'**
  String get errValidAmount;

  /// No description provided for @dateAndTime.
  ///
  /// In es, this message translates to:
  /// **'Fecha y hora'**
  String get dateAndTime;

  /// No description provided for @notesOptional.
  ///
  /// In es, this message translates to:
  /// **'Notas (opcional)'**
  String get notesOptional;

  /// No description provided for @addMedication.
  ///
  /// In es, this message translates to:
  /// **'Añadir medicamento'**
  String get addMedication;

  /// No description provided for @editMedication.
  ///
  /// In es, this message translates to:
  /// **'Editar medicamento'**
  String get editMedication;

  /// No description provided for @medicationLabel.
  ///
  /// In es, this message translates to:
  /// **'Medicamento'**
  String get medicationLabel;

  /// No description provided for @doseLabel.
  ///
  /// In es, this message translates to:
  /// **'Dosis'**
  String get doseLabel;

  /// No description provided for @doseHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. 1 comprimido'**
  String get doseHint;

  /// No description provided for @schedulesLabel.
  ///
  /// In es, this message translates to:
  /// **'Horarios'**
  String get schedulesLabel;

  /// No description provided for @errTimesFormat.
  ///
  /// In es, this message translates to:
  /// **'Usá horarios HH:mm separados por coma.'**
  String get errTimesFormat;

  /// No description provided for @startDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de inicio'**
  String get startDate;

  /// No description provided for @endDateOptional.
  ///
  /// In es, this message translates to:
  /// **'Fecha de fin (opcional)'**
  String get endDateOptional;

  /// No description provided for @activeTreatment.
  ///
  /// In es, this message translates to:
  /// **'Tratamiento activo'**
  String get activeTreatment;

  /// No description provided for @requiredField.
  ///
  /// In es, this message translates to:
  /// **'Este campo es obligatorio.'**
  String get requiredField;

  /// No description provided for @saving.
  ///
  /// In es, this message translates to:
  /// **'Guardando…'**
  String get saving;

  /// No description provided for @noDate.
  ///
  /// In es, this message translates to:
  /// **'Sin fecha'**
  String get noDate;

  /// No description provided for @tabSummary.
  ///
  /// In es, this message translates to:
  /// **'Resumen'**
  String get tabSummary;

  /// No description provided for @tabVaccines.
  ///
  /// In es, this message translates to:
  /// **'Vacunas'**
  String get tabVaccines;

  /// No description provided for @tabMedications.
  ///
  /// In es, this message translates to:
  /// **'Medicamentos'**
  String get tabMedications;

  /// No description provided for @tabFeeding.
  ///
  /// In es, this message translates to:
  /// **'Alimentación'**
  String get tabFeeding;

  /// No description provided for @tabWalks.
  ///
  /// In es, this message translates to:
  /// **'Paseos'**
  String get tabWalks;

  /// No description provided for @deleteItemTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar {name}'**
  String deleteItemTitle(String name);

  /// No description provided for @cannotBeUndone.
  ///
  /// In es, this message translates to:
  /// **'Esta acción no se puede deshacer.'**
  String get cannotBeUndone;

  /// No description provided for @deleteError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo eliminar: {error}'**
  String deleteError(String error);

  /// No description provided for @metricLastWalk.
  ///
  /// In es, this message translates to:
  /// **'ÚLTIMO PASEO'**
  String get metricLastWalk;

  /// No description provided for @metricNextVet.
  ///
  /// In es, this message translates to:
  /// **'PRÓXIMA VISITA AL VET'**
  String get metricNextVet;

  /// No description provided for @notScheduled.
  ///
  /// In es, this message translates to:
  /// **'Sin agendar'**
  String get notScheduled;

  /// No description provided for @measuredWhen.
  ///
  /// In es, this message translates to:
  /// **'Medido {when}'**
  String measuredWhen(String when);

  /// No description provided for @weightHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial de peso'**
  String get weightHistory;

  /// No description provided for @upcomingCare.
  ///
  /// In es, this message translates to:
  /// **'Próximos cuidados'**
  String get upcomingCare;

  /// No description provided for @nothingPending.
  ///
  /// In es, this message translates to:
  /// **'No hay nada pendiente.'**
  String get nothingPending;

  /// No description provided for @kindWhen.
  ///
  /// In es, this message translates to:
  /// **'{kind} · {when}'**
  String kindWhen(String kind, String when);

  /// No description provided for @kindVaccine.
  ///
  /// In es, this message translates to:
  /// **'Vacuna'**
  String get kindVaccine;

  /// No description provided for @kindTask.
  ///
  /// In es, this message translates to:
  /// **'Tarea'**
  String get kindTask;

  /// No description provided for @recentActivity.
  ///
  /// In es, this message translates to:
  /// **'Actividad reciente'**
  String get recentActivity;

  /// No description provided for @noWalksRecorded.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay paseos registrados.'**
  String get noWalksRecorded;

  /// No description provided for @kmIn.
  ///
  /// In es, this message translates to:
  /// **'{km} km en {duration}'**
  String kmIn(String km, String duration);

  /// No description provided for @appliedOnNext.
  ///
  /// In es, this message translates to:
  /// **'Aplicada el {date} · próxima {when}'**
  String appliedOnNext(String date, String when);

  /// No description provided for @noVaccinesRecorded.
  ///
  /// In es, this message translates to:
  /// **'Sin vacunas registradas.'**
  String get noVaccinesRecorded;

  /// No description provided for @noMedicationsRecorded.
  ///
  /// In es, this message translates to:
  /// **'Sin medicamentos registrados.'**
  String get noMedicationsRecorded;

  /// No description provided for @noFeedingsRecorded.
  ///
  /// In es, this message translates to:
  /// **'Sin alimentaciones registradas.'**
  String get noFeedingsRecorded;

  /// No description provided for @activeWithTimes.
  ///
  /// In es, this message translates to:
  /// **'Activo · {times}'**
  String activeWithTimes(String times);

  /// No description provided for @finished.
  ///
  /// In es, this message translates to:
  /// **'Finalizado'**
  String get finished;

  /// No description provided for @noWalksYetHint.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay paseos.\nUsá el botón verde de abajo para registrar uno.'**
  String get noWalksYetHint;

  /// No description provided for @openWalkHistory.
  ///
  /// In es, this message translates to:
  /// **'Abrir historial de paseos'**
  String get openWalkHistory;

  /// No description provided for @maxSpeedKmh.
  ///
  /// In es, this message translates to:
  /// **'máx {speed} km/h'**
  String maxSpeedKmh(String speed);

  /// No description provided for @registerWeightCaps.
  ///
  /// In es, this message translates to:
  /// **'REGISTRAR PESO'**
  String get registerWeightCaps;

  /// No description provided for @relToday.
  ///
  /// In es, this message translates to:
  /// **'hoy'**
  String get relToday;

  /// No description provided for @relYesterday.
  ///
  /// In es, this message translates to:
  /// **'ayer'**
  String get relYesterday;

  /// No description provided for @relTomorrow.
  ///
  /// In es, this message translates to:
  /// **'mañana'**
  String get relTomorrow;

  /// No description provided for @relDaysAgo.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{hace {count} día} other{hace {count} días}}'**
  String relDaysAgo(int count);

  /// No description provided for @relMonthsAgo.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{hace {count} mes} other{hace {count} meses}}'**
  String relMonthsAgo(int count);

  /// No description provided for @relOverdueDays.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{vencida hace {count} día} other{vencida hace {count} días}}'**
  String relOverdueDays(int count);

  /// No description provided for @relInDays.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{en {count} día} other{en {count} días}}'**
  String relInDays(int count);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In es, this message translates to:
  /// **'{hours} h {minutes} min'**
  String durationHoursMinutes(String hours, String minutes);

  /// No description provided for @cantLoadPets.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar tus mascotas: {error}'**
  String cantLoadPets(String error);

  /// No description provided for @addPetBeforeWalk.
  ///
  /// In es, this message translates to:
  /// **'Agregá una mascota antes de registrar un paseo.'**
  String get addPetBeforeWalk;

  /// No description provided for @whoWalks.
  ///
  /// In es, this message translates to:
  /// **'¿Con quién vas a pasear?'**
  String get whoWalks;

  /// No description provided for @choosePet.
  ///
  /// In es, this message translates to:
  /// **'Elegí una mascota'**
  String get choosePet;

  /// No description provided for @deletePetTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar a {name}?'**
  String deletePetTitle(String name);

  /// No description provided for @deletePetBody.
  ///
  /// In es, this message translates to:
  /// **'Se borrarán también sus vacunas, medicamentos, registros de peso y paseos. No se puede deshacer.'**
  String get deletePetBody;

  /// No description provided for @petDeleted.
  ///
  /// In es, this message translates to:
  /// **'{name} eliminada.'**
  String petDeleted(String name);

  /// No description provided for @walkHistoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Historial de paseos'**
  String get walkHistoryTitle;

  /// No description provided for @everyWalkCounts.
  ///
  /// In es, this message translates to:
  /// **'Cada paseo cuenta'**
  String get everyWalkCounts;

  /// No description provided for @reliveWalks.
  ///
  /// In es, this message translates to:
  /// **'Reviví sus recorridos y compartí un recuerdo juntos.'**
  String get reliveWalks;

  /// No description provided for @historyLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar el historial. Comprobá tu conexión.'**
  String get historyLoadError;

  /// No description provided for @walksLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar los paseos. Reintentá o actualizá el historial.'**
  String get walksLoadError;

  /// No description provided for @addPetToLogWalks.
  ///
  /// In es, this message translates to:
  /// **'Agregá una mascota para empezar a registrar sus paseos.'**
  String get addPetToLogWalks;

  /// No description provided for @noWalksYetHome.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay paseos. Iniciá uno desde el botón verde de la app.'**
  String get noWalksYetHome;

  /// No description provided for @walkWith.
  ///
  /// In es, this message translates to:
  /// **'Paseo con {name}'**
  String walkWith(String name);

  /// No description provided for @durationMinSec.
  ///
  /// In es, this message translates to:
  /// **'{minutes} min {seconds} s'**
  String durationMinSec(int minutes, int seconds);

  /// No description provided for @loadMoreWalks.
  ///
  /// In es, this message translates to:
  /// **'Cargar más paseos'**
  String get loadMoreWalks;

  /// No description provided for @deleteWalkTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar este paseo?'**
  String get deleteWalkTitle;

  /// No description provided for @deleteWalkBody.
  ///
  /// In es, this message translates to:
  /// **'Se borrarán el recorrido, sus estadísticas y la foto. Esta acción no se puede deshacer.'**
  String get deleteWalkBody;

  /// No description provided for @deleteWalkError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo eliminar el paseo. Reintentá.'**
  String get deleteWalkError;

  /// No description provided for @shareAsPng.
  ///
  /// In es, this message translates to:
  /// **'Compartir como PNG'**
  String get shareAsPng;

  /// No description provided for @deleteWalk.
  ///
  /// In es, this message translates to:
  /// **'Eliminar paseo'**
  String get deleteWalk;

  /// No description provided for @noGpsPoints.
  ///
  /// In es, this message translates to:
  /// **'Este paseo no tiene puntos de GPS.'**
  String get noGpsPoints;

  /// No description provided for @dateAtTime.
  ///
  /// In es, this message translates to:
  /// **'{date} a las {time}'**
  String dateAtTime(String date, String time);

  /// No description provided for @maxSpeedLabel.
  ///
  /// In es, this message translates to:
  /// **'Máx. {speed} km/h'**
  String maxSpeedLabel(String speed);

  /// No description provided for @walkPhoto.
  ///
  /// In es, this message translates to:
  /// **'Foto del paseo'**
  String get walkPhoto;

  /// No description provided for @mapAttribution.
  ///
  /// In es, this message translates to:
  /// **'Mapa © OpenStreetMap contributors'**
  String get mapAttribution;

  /// No description provided for @shareWalkTitle.
  ///
  /// In es, this message translates to:
  /// **'Compartir paseo'**
  String get shareWalkTitle;

  /// No description provided for @sharePrivacyNote.
  ///
  /// In es, this message translates to:
  /// **'Compartís la traza y las estadísticas, sin el mapa de calles. La forma del recorrido puede revelar lugares que visitaste.'**
  String get sharePrivacyNote;

  /// No description provided for @shareImageError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo preparar la imagen. Intentá otra vez.'**
  String get shareImageError;

  /// No description provided for @shareFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo compartir. Volvé a intentarlo.'**
  String get shareFailed;

  /// No description provided for @sharingEllipsis.
  ///
  /// In es, this message translates to:
  /// **'Compartiendo…'**
  String get sharingEllipsis;

  /// No description provided for @sharePng.
  ///
  /// In es, this message translates to:
  /// **'Compartir PNG'**
  String get sharePng;

  /// No description provided for @traceCaption.
  ///
  /// In es, this message translates to:
  /// **'Traza del recorrido · inicio verde / final rojo'**
  String get traceCaption;

  /// No description provided for @shareTagline.
  ///
  /// In es, this message translates to:
  /// **'Un paseo más, un recuerdo juntos.'**
  String get shareTagline;

  /// No description provided for @walkNotSaved.
  ///
  /// In es, this message translates to:
  /// **'El paseo no se guardó'**
  String get walkNotSaved;

  /// No description provided for @walkNotSavedBody.
  ///
  /// In es, this message translates to:
  /// **'Podés reintentar el guardado. Si salís ahora, perderás este recorrido.'**
  String get walkNotSavedBody;

  /// No description provided for @back.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get back;

  /// No description provided for @leaveWithoutSaving.
  ///
  /// In es, this message translates to:
  /// **'Salir sin guardar'**
  String get leaveWithoutSaving;

  /// No description provided for @savingWalk.
  ///
  /// In es, this message translates to:
  /// **'Guardando paseo…'**
  String get savingWalk;

  /// No description provided for @walkSaved.
  ///
  /// In es, this message translates to:
  /// **'Paseo guardado'**
  String get walkSaved;

  /// No description provided for @goodWalk.
  ///
  /// In es, this message translates to:
  /// **'¡Buen paseo!'**
  String get goodWalk;

  /// No description provided for @distanceCaps.
  ///
  /// In es, this message translates to:
  /// **'DISTANCIA'**
  String get distanceCaps;

  /// No description provided for @durationLabel.
  ///
  /// In es, this message translates to:
  /// **'Duración'**
  String get durationLabel;

  /// No description provided for @avgSpeed.
  ///
  /// In es, this message translates to:
  /// **'Vel. promedio'**
  String get avgSpeed;

  /// No description provided for @yourPet.
  ///
  /// In es, this message translates to:
  /// **'tu mascota'**
  String get yourPet;

  /// No description provided for @walkedWith.
  ///
  /// In es, this message translates to:
  /// **'Paseaste con {name}'**
  String walkedWith(String name);

  /// No description provided for @durationSeconds.
  ///
  /// In es, this message translates to:
  /// **'{count} s'**
  String durationSeconds(int count);

  /// No description provided for @durationHm.
  ///
  /// In es, this message translates to:
  /// **'{hours}h {minutes}min'**
  String durationHm(int hours, int minutes);

  /// No description provided for @walkInProgress.
  ///
  /// In es, this message translates to:
  /// **'Paseo en curso'**
  String get walkInProgress;

  /// No description provided for @locationErrorDefault.
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un error de ubicación.'**
  String get locationErrorDefault;

  /// No description provided for @mapCaptured.
  ///
  /// In es, this message translates to:
  /// **'Mapa capturado'**
  String get mapCaptured;

  /// No description provided for @mapCaptureFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo capturar el mapa.'**
  String get mapCaptureFailed;

  /// No description provided for @mapCaptureChip.
  ///
  /// In es, this message translates to:
  /// **'Captura del mapa'**
  String get mapCaptureChip;

  /// No description provided for @finishWalk.
  ///
  /// In es, this message translates to:
  /// **'Finalizar paseo'**
  String get finishWalk;

  /// No description provided for @gpsActive.
  ///
  /// In es, this message translates to:
  /// **'GPS activo'**
  String get gpsActive;

  /// No description provided for @gpsInactive.
  ///
  /// In es, this message translates to:
  /// **'GPS inactivo'**
  String get gpsInactive;

  /// No description provided for @durationCaps.
  ///
  /// In es, this message translates to:
  /// **'DURACIÓN'**
  String get durationCaps;

  /// No description provided for @weightLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar el historial.'**
  String get weightLoadError;

  /// No description provided for @weightDeleteError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo eliminar el registro.'**
  String get weightDeleteError;

  /// No description provided for @deleteWeightTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar registro de peso'**
  String get deleteWeightTitle;

  /// No description provided for @noWeightRecords.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay registros de peso.'**
  String get noWeightRecords;

  /// No description provided for @logWeight.
  ///
  /// In es, this message translates to:
  /// **'Registrar peso'**
  String get logWeight;

  /// No description provided for @errWeightPositive.
  ///
  /// In es, this message translates to:
  /// **'Ingresá un peso mayor que cero.'**
  String get errWeightPositive;

  /// No description provided for @weightSaveRetry.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar el peso. Podés reintentar el mismo registro.'**
  String get weightSaveRetry;

  /// No description provided for @confirmIdentity.
  ///
  /// In es, this message translates to:
  /// **'Confirmar identidad'**
  String get confirmIdentity;

  /// No description provided for @currentPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actual'**
  String get currentPassword;

  /// No description provided for @confirmGoogleAccount.
  ///
  /// In es, this message translates to:
  /// **'Confirmá tu cuenta de Google para continuar.'**
  String get confirmGoogleAccount;

  /// No description provided for @verifyingEllipsis.
  ///
  /// In es, this message translates to:
  /// **'Verificando…'**
  String get verifyingEllipsis;

  /// No description provided for @confirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// No description provided for @errEnterCurrentPassword.
  ///
  /// In es, this message translates to:
  /// **'Ingresá tu contraseña actual.'**
  String get errEnterCurrentPassword;

  /// No description provided for @identityVerifyError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo verificar tu identidad. Intentá otra vez.'**
  String get identityVerifyError;

  /// No description provided for @passwordChangeError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cambiar la contraseña. Intentá otra vez.'**
  String get passwordChangeError;

  /// No description provided for @googlePasswordNote.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta utiliza Google. Gestioná su contraseña desde tu cuenta de Google.'**
  String get googlePasswordNote;

  /// No description provided for @newPassword.
  ///
  /// In es, this message translates to:
  /// **'Nueva contraseña'**
  String get newPassword;

  /// No description provided for @repeatNewPassword.
  ///
  /// In es, this message translates to:
  /// **'Repetir nueva contraseña'**
  String get repeatNewPassword;

  /// No description provided for @errMin6Chars.
  ///
  /// In es, this message translates to:
  /// **'Usá al menos 6 caracteres.'**
  String get errMin6Chars;

  /// No description provided for @newEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo nuevo'**
  String get newEmail;

  /// No description provided for @sendLink.
  ///
  /// In es, this message translates to:
  /// **'Enviar enlace'**
  String get sendLink;

  /// No description provided for @sendingEllipsis.
  ///
  /// In es, this message translates to:
  /// **'Enviando…'**
  String get sendingEllipsis;

  /// No description provided for @checkingEllipsis.
  ///
  /// In es, this message translates to:
  /// **'Comprobando…'**
  String get checkingEllipsis;

  /// No description provided for @alreadyOpenedLink.
  ///
  /// In es, this message translates to:
  /// **'Ya abrí el enlace'**
  String get alreadyOpenedLink;

  /// No description provided for @linkSentTo.
  ///
  /// In es, this message translates to:
  /// **'Te enviamos un enlace a {email}. Tu correo actual no cambia hasta que lo abras.'**
  String linkSentTo(String email);

  /// No description provided for @notConfirmedYet.
  ///
  /// In es, this message translates to:
  /// **'Todavía no confirmaste el enlace. Abrí el correo que enviamos a {email}.'**
  String notConfirmedYet(String email);

  /// No description provided for @errEnterNewEmail.
  ///
  /// In es, this message translates to:
  /// **'Ingresá el correo nuevo.'**
  String get errEnterNewEmail;

  /// No description provided for @errValidEmail.
  ///
  /// In es, this message translates to:
  /// **'Ingresá un correo válido.'**
  String get errValidEmail;

  /// No description provided for @emailLinkError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo enviar el enlace. Intentá otra vez.'**
  String get emailLinkError;

  /// No description provided for @emailCheckError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo comprobar. Intentá otra vez.'**
  String get emailCheckError;

  /// No description provided for @googleEmailNote.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta utiliza Google. Gestioná tu correo desde tu cuenta de Google.'**
  String get googleEmailNote;

  /// No description provided for @emailUpdated.
  ///
  /// In es, this message translates to:
  /// **'Correo actualizado: {email}'**
  String emailUpdated(String email);

  /// No description provided for @passwordUpdated.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actualizada.'**
  String get passwordUpdated;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar cuenta'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountBody.
  ///
  /// In es, this message translates to:
  /// **'Se borrarán tu cuenta, tus mascotas y sus registros. Esta acción no se puede deshacer.'**
  String get deleteAccountBody;

  /// No description provided for @deleteForever.
  ///
  /// In es, this message translates to:
  /// **'Eliminar definitivamente'**
  String get deleteForever;

  /// No description provided for @deletionInProgress.
  ///
  /// In es, this message translates to:
  /// **'Eliminación en curso'**
  String get deletionInProgress;

  /// No description provided for @deletionInProgressBody.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta ya está bloqueada y estamos terminando de borrar tus datos. Se completará automáticamente en unos minutos.'**
  String get deletionInProgressBody;

  /// No description provided for @understood.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get understood;

  /// No description provided for @signOutError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cerrar sesión: {error}'**
  String signOutError(String error);

  /// No description provided for @deleteAccountError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo eliminar la cuenta: {error}'**
  String deleteAccountError(String error);

  /// No description provided for @privacyTitle.
  ///
  /// In es, this message translates to:
  /// **'Privacidad'**
  String get privacyTitle;

  /// No description provided for @privacySessionChanged.
  ///
  /// In es, this message translates to:
  /// **'La sesión cambió. Volvé a entrar desde tu perfil.'**
  String get privacySessionChanged;

  /// No description provided for @privacyLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar la privacidad.'**
  String get privacyLoadError;

  /// No description provided for @prefSavedRemindersFailed.
  ///
  /// In es, this message translates to:
  /// **'Preferencia guardada. No se pudieron actualizar los avisos de este dispositivo; reintentá antes de cerrarlo.'**
  String get prefSavedRemindersFailed;

  /// No description provided for @prefNotSaved.
  ///
  /// In es, this message translates to:
  /// **'No se guardó la preferencia. Reintentá.'**
  String get prefNotSaved;

  /// No description provided for @downloadMyData.
  ///
  /// In es, this message translates to:
  /// **'Descargar mis datos'**
  String get downloadMyData;

  /// No description provided for @downloadMyDataBody.
  ///
  /// In es, this message translates to:
  /// **'El archivo incluye tus fotos y recorridos GPS. Elegí un destino privado cuando lo guardes o compartas.'**
  String get downloadMyDataBody;

  /// No description provided for @continueLabel.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get continueLabel;

  /// No description provided for @exportIncomplete.
  ///
  /// In es, this message translates to:
  /// **'No se completó el archivo. Podés iniciar otra exportación.'**
  String get exportIncomplete;

  /// No description provided for @exportShareFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar o compartir. El archivo sigue preparado para reintentar.'**
  String get exportShareFailed;

  /// No description provided for @requestNotRegistered.
  ///
  /// In es, this message translates to:
  /// **'No se pudo registrar la solicitud. Conservamos el texto para reintentar.'**
  String get requestNotRegistered;

  /// No description provided for @yourNotices.
  ///
  /// In es, this message translates to:
  /// **'Tus avisos'**
  String get yourNotices;

  /// No description provided for @careReminders.
  ///
  /// In es, this message translates to:
  /// **'Recordatorios de cuidados'**
  String get careReminders;

  /// No description provided for @careRemindersHint.
  ///
  /// In es, this message translates to:
  /// **'Vacunas, medicamentos y tareas'**
  String get careRemindersHint;

  /// No description provided for @teamNotices.
  ///
  /// In es, this message translates to:
  /// **'Avisos del equipo'**
  String get teamNotices;

  /// No description provided for @yourData.
  ///
  /// In es, this message translates to:
  /// **'Tus datos'**
  String get yourData;

  /// No description provided for @yourDataBody.
  ///
  /// In es, this message translates to:
  /// **'Descargá tu perfil, mascotas, cuidados, fotos y recorridos en un archivo JSON.'**
  String get yourDataBody;

  /// No description provided for @prepareFile.
  ///
  /// In es, this message translates to:
  /// **'Preparar archivo'**
  String get prepareFile;

  /// No description provided for @recordsPrepared.
  ///
  /// In es, this message translates to:
  /// **'{count} registros preparados'**
  String recordsPrepared(int count);

  /// No description provided for @cancelExport.
  ///
  /// In es, this message translates to:
  /// **'Cancelar exportación'**
  String get cancelExport;

  /// No description provided for @saveOrShareJson.
  ///
  /// In es, this message translates to:
  /// **'Guardar o compartir JSON'**
  String get saveOrShareJson;

  /// No description provided for @requestsTitle.
  ///
  /// In es, this message translates to:
  /// **'Solicitudes'**
  String get requestsTitle;

  /// No description provided for @requestType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de solicitud'**
  String get requestType;

  /// No description provided for @reqConsulta.
  ///
  /// In es, this message translates to:
  /// **'Consulta'**
  String get reqConsulta;

  /// No description provided for @reqAcceso.
  ///
  /// In es, this message translates to:
  /// **'Acceso a información'**
  String get reqAcceso;

  /// No description provided for @reqCorreccion.
  ///
  /// In es, this message translates to:
  /// **'Corrección'**
  String get reqCorreccion;

  /// No description provided for @reqOposicion.
  ///
  /// In es, this message translates to:
  /// **'Oposición'**
  String get reqOposicion;

  /// No description provided for @reqBloqueo.
  ///
  /// In es, this message translates to:
  /// **'Bloqueo'**
  String get reqBloqueo;

  /// No description provided for @reqAnonimizacion.
  ///
  /// In es, this message translates to:
  /// **'Anonimización'**
  String get reqAnonimizacion;

  /// No description provided for @detailLabel.
  ///
  /// In es, this message translates to:
  /// **'Detalle'**
  String get detailLabel;

  /// No description provided for @registerRequest.
  ///
  /// In es, this message translates to:
  /// **'Registrar solicitud'**
  String get registerRequest;

  /// No description provided for @requestsByEmail.
  ///
  /// In es, this message translates to:
  /// **'Por ahora podés enviar tus solicitudes al correo de soporte.'**
  String get requestsByEmail;

  /// No description provided for @requestChannelMissing.
  ///
  /// In es, this message translates to:
  /// **'El canal de consultas todavía no está configurado.'**
  String get requestChannelMissing;

  /// No description provided for @refreshRequests.
  ///
  /// In es, this message translates to:
  /// **'Actualizar solicitudes'**
  String get refreshRequests;

  /// No description provided for @authUserDisabled.
  ///
  /// In es, this message translates to:
  /// **'Esta cuenta está deshabilitada.'**
  String get authUserDisabled;

  /// No description provided for @authBadCredentials.
  ///
  /// In es, this message translates to:
  /// **'Correo o contraseña incorrectos.'**
  String get authBadCredentials;

  /// No description provided for @authEmailInUse.
  ///
  /// In es, this message translates to:
  /// **'Ya existe una cuenta con ese correo.'**
  String get authEmailInUse;

  /// No description provided for @authWeakPassword.
  ///
  /// In es, this message translates to:
  /// **'La contraseña es demasiado débil (mínimo 6 caracteres).'**
  String get authWeakPassword;

  /// No description provided for @authAccountExists.
  ///
  /// In es, this message translates to:
  /// **'Ya hay una cuenta con ese correo creada con otro método de acceso.'**
  String get authAccountExists;

  /// No description provided for @authRecentLogin.
  ///
  /// In es, this message translates to:
  /// **'Por seguridad, volvé a iniciar sesión para hacer este cambio.'**
  String get authRecentLogin;

  /// No description provided for @authUserMismatch.
  ///
  /// In es, this message translates to:
  /// **'La cuenta elegida no coincide con la sesión actual.'**
  String get authUserMismatch;

  /// No description provided for @authTooMany.
  ///
  /// In es, this message translates to:
  /// **'Demasiados intentos fallidos. Esperá unos minutos y probá de nuevo.'**
  String get authTooMany;

  /// No description provided for @authNoInternet.
  ///
  /// In es, this message translates to:
  /// **'No hay conexión a internet.'**
  String get authNoInternet;

  /// No description provided for @authNotEnabled.
  ///
  /// In es, this message translates to:
  /// **'Este método de acceso no está habilitado.'**
  String get authNotEnabled;

  /// No description provided for @authNoSession.
  ///
  /// In es, this message translates to:
  /// **'No hay sesión iniciada.'**
  String get authNoSession;

  /// No description provided for @authSessionChanged.
  ///
  /// In es, this message translates to:
  /// **'La sesión cambió. Volvé a intentar desde tu cuenta.'**
  String get authSessionChanged;

  /// No description provided for @authCancelled.
  ///
  /// In es, this message translates to:
  /// **'Operación cancelada.'**
  String get authCancelled;

  /// No description provided for @authGoogleAccount.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta utiliza Google para iniciar sesión.'**
  String get authGoogleAccount;

  /// No description provided for @authPasswordFields.
  ///
  /// In es, this message translates to:
  /// **'Completá la contraseña actual y una nueva de al menos 6 caracteres.'**
  String get authPasswordFields;

  /// No description provided for @authSameEmail.
  ///
  /// In es, this message translates to:
  /// **'Ese ya es el correo de tu cuenta.'**
  String get authSameEmail;

  /// No description provided for @authSignupFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo crear la cuenta.'**
  String get authSignupFailed;

  /// No description provided for @authSigninFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo iniciar sesión.'**
  String get authSigninFailed;

  /// No description provided for @authGoogleSigninFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo iniciar sesión con Google.'**
  String get authGoogleSigninFailed;

  /// No description provided for @authGoogleUnavailable.
  ///
  /// In es, this message translates to:
  /// **'El acceso con Google no está disponible en esta plataforma.'**
  String get authGoogleUnavailable;

  /// No description provided for @authPushDisconnect.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron desconectar las notificaciones. Reintentá cerrar sesión.'**
  String get authPushDisconnect;

  /// No description provided for @authGeneric.
  ///
  /// In es, this message translates to:
  /// **'No se pudo completar la operación. Intentá otra vez.'**
  String get authGeneric;

  /// No description provided for @googleInterrupted.
  ///
  /// In es, this message translates to:
  /// **'El acceso con Google se interrumpió. Probá de nuevo.'**
  String get googleInterrupted;

  /// No description provided for @googleUiUnavailable.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir el diálogo de Google.'**
  String get googleUiUnavailable;

  /// No description provided for @googleConfigError.
  ///
  /// In es, this message translates to:
  /// **'La app no está bien configurada para Google. Intentá más tarde.'**
  String get googleConfigError;

  /// No description provided for @googleUserMismatch.
  ///
  /// In es, this message translates to:
  /// **'La cuenta de Google no coincide con la esperada.'**
  String get googleUserMismatch;

  /// No description provided for @apiSessionChanged.
  ///
  /// In es, this message translates to:
  /// **'La sesión cambió.'**
  String get apiSessionChanged;

  /// No description provided for @apiInvalidResponse.
  ///
  /// In es, this message translates to:
  /// **'El servidor devolvió una respuesta inválida. Reintentá.'**
  String get apiInvalidResponse;

  /// No description provided for @apiListTooLarge.
  ///
  /// In es, this message translates to:
  /// **'El listado es demasiado grande para esta pantalla. No se mostraron resultados incompletos.'**
  String get apiListTooLarge;

  /// No description provided for @apiTimeout.
  ///
  /// In es, this message translates to:
  /// **'El servidor tardó demasiado en responder.'**
  String get apiTimeout;

  /// No description provided for @apiOffline.
  ///
  /// In es, this message translates to:
  /// **'No hay conexión con el servidor. Comprobá tu conexión a internet.'**
  String get apiOffline;

  /// No description provided for @apiHttpStatus.
  ///
  /// In es, this message translates to:
  /// **'El servidor respondió con un error ({status}).'**
  String apiHttpStatus(String status);

  /// No description provided for @noticeVaccineTitle.
  ///
  /// In es, this message translates to:
  /// **'Vacuna de {pet}'**
  String noticeVaccineTitle(String pet);

  /// No description provided for @noticeVaccineBody.
  ///
  /// In es, this message translates to:
  /// **'Se acerca {vaccine}: {date}.'**
  String noticeVaccineBody(String vaccine, String date);

  /// No description provided for @noticeMedicationTitle.
  ///
  /// In es, this message translates to:
  /// **'Medicamento de {pet}'**
  String noticeMedicationTitle(String pet);

  /// No description provided for @noticeMedicationBody.
  ///
  /// In es, this message translates to:
  /// **'{medication}: {dose}.'**
  String noticeMedicationBody(String medication, String dose);

  /// No description provided for @photoOpenFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir la imagen. Probá otra vez.'**
  String get photoOpenFailed;

  /// No description provided for @photoTooLarge.
  ///
  /// In es, this message translates to:
  /// **'La imagen es demasiado grande. Probá con otra.'**
  String get photoTooLarge;

  /// No description provided for @photoTooLargeAfter.
  ///
  /// In es, this message translates to:
  /// **'La foto es demasiado grande incluso después de reducirla. Probá con otra.'**
  String get photoTooLargeAfter;

  /// No description provided for @photoInvalidType.
  ///
  /// In es, this message translates to:
  /// **'Elegí una imagen JPEG o PNG.'**
  String get photoInvalidType;

  /// No description provided for @photoInvalidOrLarge.
  ///
  /// In es, this message translates to:
  /// **'La imagen no es válida o es demasiado grande.'**
  String get photoInvalidOrLarge;

  /// No description provided for @photoUnreadable.
  ///
  /// In es, this message translates to:
  /// **'No se pudo leer la imagen. Probá con otra.'**
  String get photoUnreadable;

  /// No description provided for @exportCancelled.
  ///
  /// In es, this message translates to:
  /// **'Exportación cancelada.'**
  String get exportCancelled;

  /// No description provided for @exportSessionChanged.
  ///
  /// In es, this message translates to:
  /// **'La sesión cambió. No se preparó el archivo.'**
  String get exportSessionChanged;

  /// No description provided for @exportTooBig.
  ///
  /// In es, this message translates to:
  /// **'El archivo necesita asistencia por su tamaño.'**
  String get exportTooBig;

  /// No description provided for @exportStartFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo iniciar una exportación válida.'**
  String get exportStartFailed;

  /// No description provided for @exportInvalidResponse.
  ///
  /// In es, this message translates to:
  /// **'La exportación devolvió una respuesta inválida. Iniciá otra.'**
  String get exportInvalidResponse;

  /// No description provided for @exportIncompleteService.
  ///
  /// In es, this message translates to:
  /// **'No se completó la exportación. Iniciá otra.'**
  String get exportIncompleteService;

  /// No description provided for @captureNotReady.
  ///
  /// In es, this message translates to:
  /// **'El mapa todavía no está listo.'**
  String get captureNotReady;

  /// No description provided for @captureUnreadable.
  ///
  /// In es, this message translates to:
  /// **'No se pudo leer la imagen del mapa.'**
  String get captureUnreadable;

  /// No description provided for @captureTooLarge.
  ///
  /// In es, this message translates to:
  /// **'La captura del mapa salió demasiado grande. Probá con menos zoom.'**
  String get captureTooLarge;

  /// No description provided for @locGpsOff.
  ///
  /// In es, this message translates to:
  /// **'El GPS está desactivado. Activalo para continuar.'**
  String get locGpsOff;

  /// No description provided for @locDenied.
  ///
  /// In es, this message translates to:
  /// **'Permiso de ubicación denegado.'**
  String get locDenied;

  /// No description provided for @locDeniedForever.
  ///
  /// In es, this message translates to:
  /// **'Permiso denegado permanentemente. Habilitalo desde ajustes del sistema.'**
  String get locDeniedForever;

  /// No description provided for @locFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo obtener la ubicación: {error}'**
  String locFailed(String error);

  /// No description provided for @inactivityTitle.
  ///
  /// In es, this message translates to:
  /// **'Aviso por falta de paseos'**
  String get inactivityTitle;

  /// No description provided for @inactivityHint.
  ///
  /// In es, this message translates to:
  /// **'Te avisamos si pasa el plazo que elegís sin registrar un paseo.'**
  String get inactivityHint;

  /// No description provided for @inactivityAfter.
  ///
  /// In es, this message translates to:
  /// **'Avisar tras'**
  String get inactivityAfter;

  /// No description provided for @inactivityDays.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{{count} día} other{{count} días}}'**
  String inactivityDays(int count);

  /// No description provided for @inactivityIncludeNew.
  ///
  /// In es, this message translates to:
  /// **'Incluir mascotas sin paseos registrados'**
  String get inactivityIncludeNew;

  /// No description provided for @kindInactivity.
  ///
  /// In es, this message translates to:
  /// **'Sin paseos'**
  String get kindInactivity;

  /// No description provided for @premiumTitle.
  ///
  /// In es, this message translates to:
  /// **'Premium'**
  String get premiumTitle;

  /// No description provided for @premiumActiveUntil.
  ///
  /// In es, this message translates to:
  /// **'Premium activo hasta {date}'**
  String premiumActiveUntil(String date);

  /// No description provided for @premiumInactive.
  ///
  /// In es, this message translates to:
  /// **'Sin Premium activo'**
  String get premiumInactive;

  /// No description provided for @premiumSourceManual.
  ///
  /// In es, this message translates to:
  /// **'Concedido por el equipo de PawLife'**
  String get premiumSourceManual;

  /// No description provided for @premiumSourcePaid.
  ///
  /// In es, this message translates to:
  /// **'Suscripción'**
  String get premiumSourcePaid;

  /// No description provided for @premiumNoPurchases.
  ///
  /// In es, this message translates to:
  /// **'Por ahora Premium lo concede el equipo de PawLife. Todavía no hay compras dentro de la app.'**
  String get premiumNoPurchases;

  /// No description provided for @premiumLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo consultar tu estado de Premium.'**
  String get premiumLoadError;

  /// No description provided for @apiAccountDeleting.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta se está eliminando.'**
  String get apiAccountDeleting;

  /// No description provided for @apiAccountUnavailable.
  ///
  /// In es, this message translates to:
  /// **'La cuenta no está disponible.'**
  String get apiAccountUnavailable;

  /// No description provided for @apiRateLimited.
  ///
  /// In es, this message translates to:
  /// **'Hiciste demasiados cambios seguidos. Esperá un rato y probá de nuevo.'**
  String get apiRateLimited;

  /// No description provided for @apiPhotoProcessor.
  ///
  /// In es, this message translates to:
  /// **'No se pudo procesar la foto ahora. Reintentá más tarde.'**
  String get apiPhotoProcessor;

  /// No description provided for @apiInvalidPhoto.
  ///
  /// In es, this message translates to:
  /// **'La foto no es válida.'**
  String get apiInvalidPhoto;

  /// No description provided for @apiTooLarge.
  ///
  /// In es, this message translates to:
  /// **'Los datos son demasiado grandes para guardarse.'**
  String get apiTooLarge;

  /// No description provided for @apiExportExpired.
  ///
  /// In es, this message translates to:
  /// **'La exportación venció. Iniciá otra.'**
  String get apiExportExpired;

  /// No description provided for @apiBillingReview.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta tiene una suscripción o compra que debe revisarse antes de eliminarla.'**
  String get apiBillingReview;

  /// No description provided for @apiPrivacyUnavailable.
  ///
  /// In es, this message translates to:
  /// **'El canal de privacidad todavía no está disponible.'**
  String get apiPrivacyUnavailable;

  /// No description provided for @apiServiceBusy.
  ///
  /// In es, this message translates to:
  /// **'El servicio no está disponible en este momento. Reintentá en unos minutos.'**
  String get apiServiceBusy;

  /// No description provided for @apiDeviceConflict.
  ///
  /// In es, this message translates to:
  /// **'Este dispositivo ya está asociado a otra cuenta.'**
  String get apiDeviceConflict;

  /// No description provided for @cellNextVaccine.
  ///
  /// In es, this message translates to:
  /// **'PRÓXIMA VACUNA'**
  String get cellNextVaccine;

  /// No description provided for @homeTasksPending.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{{count} tarea pendiente hoy} other{{count} tareas pendientes hoy}}'**
  String homeTasksPending(int count);

  /// No description provided for @homeAllDone.
  ///
  /// In es, this message translates to:
  /// **'Todo al día'**
  String get homeAllDone;

  /// No description provided for @holdToFinish.
  ///
  /// In es, this message translates to:
  /// **'Mantené pulsado para finalizar'**
  String get holdToFinish;

  /// No description provided for @shareStyleForest.
  ///
  /// In es, this message translates to:
  /// **'Bosque'**
  String get shareStyleForest;

  /// No description provided for @shareStyleMint.
  ///
  /// In es, this message translates to:
  /// **'Menta'**
  String get shareStyleMint;

  /// No description provided for @shareStyleStats.
  ///
  /// In es, this message translates to:
  /// **'Cifras'**
  String get shareStyleStats;

  /// No description provided for @shareStyleLabel.
  ///
  /// In es, this message translates to:
  /// **'Estilo de la tarjeta'**
  String get shareStyleLabel;

  /// No description provided for @wearableStart.
  ///
  /// In es, this message translates to:
  /// **'INICIAR'**
  String get wearableStart;

  /// No description provided for @wearablePause.
  ///
  /// In es, this message translates to:
  /// **'PAUSAR'**
  String get wearablePause;

  /// No description provided for @wearableResume.
  ///
  /// In es, this message translates to:
  /// **'SEGUIR'**
  String get wearableResume;

  /// No description provided for @wearableStop.
  ///
  /// In es, this message translates to:
  /// **'TERMINAR'**
  String get wearableStop;

  /// No description provided for @wearableSaving.
  ///
  /// In es, this message translates to:
  /// **'GUARDANDO'**
  String get wearableSaving;

  /// No description provided for @wearableSaved.
  ///
  /// In es, this message translates to:
  /// **'GUARDADO'**
  String get wearableSaved;

  /// No description provided for @wearableDone.
  ///
  /// In es, this message translates to:
  /// **'LISTO'**
  String get wearableDone;

  /// No description provided for @wearableRetry.
  ///
  /// In es, this message translates to:
  /// **'REINTENTAR'**
  String get wearableRetry;

  /// No description provided for @wearableNoGps.
  ///
  /// In es, this message translates to:
  /// **'SIN GPS'**
  String get wearableNoGps;

  /// No description provided for @wearableNoPet.
  ///
  /// In es, this message translates to:
  /// **'SIN MASCOTA'**
  String get wearableNoPet;

  /// No description provided for @wearableNotSaved.
  ///
  /// In es, this message translates to:
  /// **'NO GUARDÓ'**
  String get wearableNotSaved;

  /// No description provided for @wearableOpen.
  ///
  /// In es, this message translates to:
  /// **'Modo reloj'**
  String get wearableOpen;

  /// No description provided for @visitsTitle.
  ///
  /// In es, this message translates to:
  /// **'Visitas al veterinario'**
  String get visitsTitle;

  /// No description provided for @visitsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay visitas registradas.'**
  String get visitsEmpty;

  /// No description provided for @visitsAdd.
  ///
  /// In es, this message translates to:
  /// **'Registrar visita'**
  String get visitsAdd;

  /// No description provided for @visitReason.
  ///
  /// In es, this message translates to:
  /// **'Motivo'**
  String get visitReason;

  /// No description provided for @visitVet.
  ///
  /// In es, this message translates to:
  /// **'Veterinario o clínica'**
  String get visitVet;

  /// No description provided for @visitNotes.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get visitNotes;

  /// No description provided for @visitDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get visitDate;

  /// No description provided for @visitNextDate.
  ///
  /// In es, this message translates to:
  /// **'Próxima visita'**
  String get visitNextDate;

  /// No description provided for @visitNone.
  ///
  /// In es, this message translates to:
  /// **'Ninguna'**
  String get visitNone;

  /// No description provided for @visitDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar visita'**
  String get visitDeleteTitle;

  /// No description provided for @visitsLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar las visitas.'**
  String get visitsLoadError;

  /// No description provided for @visitsSaveError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar la visita. Probá de nuevo.'**
  String get visitsSaveError;

  /// No description provided for @visitsDeleteError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo eliminar la visita.'**
  String get visitsDeleteError;

  /// No description provided for @errVisitReason.
  ///
  /// In es, this message translates to:
  /// **'Indicá el motivo de la visita.'**
  String get errVisitReason;

  /// No description provided for @errVisitNextBefore.
  ///
  /// In es, this message translates to:
  /// **'La próxima visita debe ser posterior a la fecha.'**
  String get errVisitNextBefore;
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
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
