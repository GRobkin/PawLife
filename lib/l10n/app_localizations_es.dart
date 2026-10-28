// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get languageEs => 'Español';

  @override
  String get languageEn => 'English';

  @override
  String get languagePt => 'Português';

  @override
  String get appearance => 'Apariencia';

  @override
  String get appearanceSystem => 'Sistema';

  @override
  String get appearanceLight => 'Claro';

  @override
  String get appearanceDark => 'Oscuro';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileName => 'Nombre';

  @override
  String get profileEmail => 'Correo electrónico';

  @override
  String get profileSave => 'Guardar cambios';

  @override
  String get profileSaved => 'Perfil guardado.';

  @override
  String profileLoadError(String error) {
    return 'No se pudo cargar el perfil: $error';
  }

  @override
  String profileSaveError(String error) {
    return 'No se pudo guardar: $error';
  }

  @override
  String get retry => 'Reintentar';

  @override
  String get privacyAndData => 'Privacidad y mis datos';

  @override
  String get changeEmail => 'Cambiar correo';

  @override
  String get changePassword => 'Cambiar contraseña';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get deleteAccountButton => 'Eliminar mi cuenta';

  @override
  String get welcomeTagline =>
      'La salud y felicidad de tu compañero,\ntodo en un solo lugar.';

  @override
  String get getStarted => 'Comenzar';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get termsPrefix => 'Al continuar, aceptás nuestros ';

  @override
  String get termsOfService => 'Términos del servicio';

  @override
  String get termsAnd => ' y la ';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get welcomeBack => 'Bienvenido de nuevo';

  @override
  String get loginSubtitle =>
      'Iniciá sesión para gestionar los cuidados de tu mascota.';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get orSeparator => 'o';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get noAccountPrefix => '¿No tenés una cuenta? ';

  @override
  String get signUp => 'Registrate';

  @override
  String get hasAccountPrefix => '¿Ya tenés una cuenta? ';

  @override
  String get createAccountTitle => 'Creá tu cuenta';

  @override
  String get createAccountSubtitle => 'Completá tus datos para empezar.';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get fullNameHint => 'Ej. Juana Pérez';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get errEnterEmail => 'Escribí tu correo electrónico.';

  @override
  String get errInvalidEmail => 'El correo no tiene un formato válido.';

  @override
  String get errEnterPassword => 'Escribí tu contraseña.';

  @override
  String get errEmailAbove => 'Escribí tu correo arriba y volvé a pulsar aquí.';

  @override
  String get errEnterName => 'Escribí tu nombre.';

  @override
  String get errPasswordShort =>
      'La contraseña debe tener al menos 6 caracteres.';

  @override
  String get errPasswordMismatch => 'Las contraseñas no coinciden.';

  @override
  String resetEmailSent(String email) {
    return 'Te enviamos un correo a $email.';
  }

  @override
  String get showPassword => 'Mostrar contraseña';

  @override
  String get hidePassword => 'Ocultar contraseña';

  @override
  String get navHome => 'Inicio';

  @override
  String get navPets => 'Mascotas';

  @override
  String get navTasks => 'Tareas';

  @override
  String get navProfile => 'Perfil';

  @override
  String get tasksTitle => 'Tareas';

  @override
  String tasksLoadError(String error) {
    return 'No se pudieron cargar las tareas: $error';
  }

  @override
  String genericSaveError(String error) {
    return 'No se pudo guardar: $error';
  }

  @override
  String get addPetFirst => 'Agregá una mascota antes de crear una tarea.';

  @override
  String get newTask => 'Nueva tarea';

  @override
  String get petLabel => 'Mascota';

  @override
  String get taskPrompt => '¿Qué hay que hacer?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get noTasks => 'Todavía no hay tareas.';

  @override
  String get deleteTask => 'Eliminar tarea';

  @override
  String get speciesDog => 'Perro';

  @override
  String get speciesCat => 'Gato';

  @override
  String get speciesOther => 'Otra';

  @override
  String ageDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '$count día',
    );
    return '$_temp0';
  }

  @override
  String ageWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count semanas',
      one: '$count semana',
    );
    return '$_temp0';
  }

  @override
  String ageMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meses',
      one: '$count mes',
    );
    return '$_temp0';
  }

  @override
  String ageYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count años',
      one: '$count año',
    );
    return '$_temp0';
  }

  @override
  String get petsLoadError => 'No se pudieron cargar tus mascotas';

  @override
  String get petsEmptyTitle => 'Todavía no tenés mascotas';

  @override
  String get petsEmptyBody =>
      'Agregá la primera para empezar a llevar sus cuidados.';

  @override
  String get addPet => 'Agregar mascota';

  @override
  String get myPets => 'Mis mascotas';

  @override
  String get myPetsSubtitle => 'Gestioná a los miembros peludos de tu familia.';

  @override
  String get statusNoVaccines => 'Sin vacunas';

  @override
  String get statusOverdue => 'Vacuna vencida';

  @override
  String get statusDueSoon => 'Vacuna próxima';

  @override
  String get statusHealthy => 'Sano';

  @override
  String get options => 'Opciones';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get cellStatus => 'ESTADO';

  @override
  String get cellWeight => 'PESO';

  @override
  String get noRecord => 'Sin registro';

  @override
  String get goodMorning => '¡Buenos días!';

  @override
  String get goodAfternoon => '¡Buenas tardes!';

  @override
  String get goodEvening => '¡Buenas noches!';

  @override
  String goodMorningName(String name) {
    return '¡Buenos días, $name!';
  }

  @override
  String goodAfternoonName(String name) {
    return '¡Buenas tardes, $name!';
  }

  @override
  String goodEveningName(String name) {
    return '¡Buenas noches, $name!';
  }

  @override
  String get todayAgenda => 'Esta es tu agenda de hoy.';

  @override
  String get activitySummary => 'Resumen de actividad';

  @override
  String get viewWalkHistory => 'Ver historial de paseos';

  @override
  String get todayTitle => 'Hoy';

  @override
  String get noTasksToday => 'No tenés tareas para hoy.';

  @override
  String get completedLabel => 'Completada';

  @override
  String updateTaskError(String error) {
    return 'No se pudo actualizar la tarea: $error';
  }

  @override
  String get onlyOnePet => 'Solo tenés una mascota por ahora.';

  @override
  String get changePet => 'Cambiar de mascota';

  @override
  String get yourAccount => 'Tu cuenta';

  @override
  String get signedIn => 'Sesión iniciada';

  @override
  String get loadingEllipsis => 'Cargando…';

  @override
  String get noPets => 'Sin mascotas';

  @override
  String get tapToAddFirst => 'Tocá para agregar la primera';

  @override
  String get startWalk => 'Iniciar paseo';

  @override
  String get readyForAdventure => '¿Listos para una aventura?';

  @override
  String get lastWalk => 'Último paseo';

  @override
  String get activeTime => 'Tiempo activo';

  @override
  String get loadingShort => 'Cargando';

  @override
  String get noWalks => 'Sin paseos';

  @override
  String get noWalksToday => 'Sin paseos hoy';

  @override
  String walksToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count paseos hoy',
      one: '$count paseo hoy',
    );
    return '$_temp0';
  }

  @override
  String minutesShort(int count) {
    return '$count min';
  }

  @override
  String todayAt(String time) {
    return 'Hoy, $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Ayer, $time';
  }

  @override
  String get markPending => 'Marcar pendiente';

  @override
  String get markDone => 'Marcar completada';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get pickFromGallery => 'Elegir de la galería';

  @override
  String get takePhoto => 'Tomar una foto';

  @override
  String get removePhoto => 'Quitar foto';

  @override
  String get uploadPhoto => 'Subir foto';

  @override
  String get changePhoto => 'Cambiar foto';

  @override
  String get birthDate => 'Fecha de nacimiento';

  @override
  String get errEnterPetName => 'Escribí el nombre.';

  @override
  String get errWeightInvalid => 'El peso no es un número válido.';

  @override
  String get errWeightRange => 'El peso tiene que estar entre 0 y 200 kg.';

  @override
  String get editPet => 'Editar mascota';

  @override
  String editPetSubtitle(String name) {
    return 'Actualizá los datos de $name.';
  }

  @override
  String get addPetSubtitle =>
      'Contanos sobre tu compañero para personalizar sus cuidados.';

  @override
  String get savePet => 'Guardar mascota';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get nameHint => 'Ej. Bella';

  @override
  String get speciesLabel => 'Especie';

  @override
  String get breedLabel => 'Raza';

  @override
  String get breedHint => 'Ej. Golden Retriever';

  @override
  String get weightKgLabel => 'Peso (kg)';

  @override
  String get notesLabel => 'Notas';

  @override
  String get optional => 'Opcional';

  @override
  String get notesHint => 'Alergias, número de microchip, manías...';

  @override
  String get datePlaceholder => 'dd/mm/aaaa';

  @override
  String get addVaccine => 'Añadir vacuna';

  @override
  String get editVaccine => 'Editar vacuna';

  @override
  String get vaccineName => 'Nombre de la vacuna';

  @override
  String get applicationDate => 'Fecha de aplicación';

  @override
  String get nextDose => 'Próxima dosis';

  @override
  String get remindInAdvance => 'Avisar con anticipación';

  @override
  String get daysUnit => 'días';

  @override
  String get errRange0to365 => 'Ingresá un valor entre 0 y 365.';

  @override
  String get logFeeding => 'Registrar alimentación';

  @override
  String get foodType => 'Tipo de alimento';

  @override
  String get foodTypeHint => 'Ej. alimento seco';

  @override
  String get amountLabel => 'Cantidad';

  @override
  String get errValidAmount => 'Ingresá una cantidad válida.';

  @override
  String get dateAndTime => 'Fecha y hora';

  @override
  String get notesOptional => 'Notas (opcional)';

  @override
  String get addMedication => 'Añadir medicamento';

  @override
  String get editMedication => 'Editar medicamento';

  @override
  String get medicationLabel => 'Medicamento';

  @override
  String get doseLabel => 'Dosis';

  @override
  String get doseHint => 'Ej. 1 comprimido';

  @override
  String get schedulesLabel => 'Horarios';

  @override
  String get errTimesFormat => 'Usá horarios HH:mm separados por coma.';

  @override
  String get startDate => 'Fecha de inicio';

  @override
  String get endDateOptional => 'Fecha de fin (opcional)';

  @override
  String get activeTreatment => 'Tratamiento activo';

  @override
  String get requiredField => 'Este campo es obligatorio.';

  @override
  String get saving => 'Guardando…';

  @override
  String get noDate => 'Sin fecha';

  @override
  String get tabSummary => 'Resumen';

  @override
  String get tabVaccines => 'Vacunas';

  @override
  String get tabMedications => 'Medicamentos';

  @override
  String get tabFeeding => 'Alimentación';

  @override
  String get tabWalks => 'Paseos';

  @override
  String deleteItemTitle(String name) {
    return 'Eliminar $name';
  }

  @override
  String get cannotBeUndone => 'Esta acción no se puede deshacer.';

  @override
  String deleteError(String error) {
    return 'No se pudo eliminar: $error';
  }

  @override
  String get metricLastWalk => 'ÚLTIMO PASEO';

  @override
  String get metricNextVet => 'PRÓXIMA VISITA AL VET';

  @override
  String get notScheduled => 'Sin agendar';

  @override
  String measuredWhen(String when) {
    return 'Medido $when';
  }

  @override
  String get weightHistory => 'Historial de peso';

  @override
  String get upcomingCare => 'Próximos cuidados';

  @override
  String get nothingPending => 'No hay nada pendiente.';

  @override
  String kindWhen(String kind, String when) {
    return '$kind · $when';
  }

  @override
  String get kindVaccine => 'Vacuna';

  @override
  String get kindTask => 'Tarea';

  @override
  String get recentActivity => 'Actividad reciente';

  @override
  String get noWalksRecorded => 'Todavía no hay paseos registrados.';

  @override
  String kmIn(String km, String duration) {
    return '$km km en $duration';
  }

  @override
  String appliedOnNext(String date, String when) {
    return 'Aplicada el $date · próxima $when';
  }

  @override
  String get noVaccinesRecorded => 'Sin vacunas registradas.';

  @override
  String get noMedicationsRecorded => 'Sin medicamentos registrados.';

  @override
  String get noFeedingsRecorded => 'Sin alimentaciones registradas.';

  @override
  String activeWithTimes(String times) {
    return 'Activo · $times';
  }

  @override
  String get finished => 'Finalizado';

  @override
  String get noWalksYetHint =>
      'Todavía no hay paseos.\nUsá el botón verde de abajo para registrar uno.';

  @override
  String get openWalkHistory => 'Abrir historial de paseos';

  @override
  String maxSpeedKmh(String speed) {
    return 'máx $speed km/h';
  }

  @override
  String get registerWeightCaps => 'REGISTRAR PESO';

  @override
  String get relToday => 'hoy';

  @override
  String get relYesterday => 'ayer';

  @override
  String get relTomorrow => 'mañana';

  @override
  String relDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count días',
      one: 'hace $count día',
    );
    return '$_temp0';
  }

  @override
  String relMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count meses',
      one: 'hace $count mes',
    );
    return '$_temp0';
  }

  @override
  String relOverdueDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vencida hace $count días',
      one: 'vencida hace $count día',
    );
    return '$_temp0';
  }

  @override
  String relInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'en $count días',
      one: 'en $count día',
    );
    return '$_temp0';
  }

  @override
  String durationHoursMinutes(String hours, String minutes) {
    return '$hours h $minutes min';
  }

  @override
  String cantLoadPets(String error) {
    return 'No se pudieron cargar tus mascotas: $error';
  }

  @override
  String get addPetBeforeWalk =>
      'Agregá una mascota antes de registrar un paseo.';

  @override
  String get whoWalks => '¿Con quién vas a pasear?';

  @override
  String get choosePet => 'Elegí una mascota';

  @override
  String deletePetTitle(String name) {
    return '¿Eliminar a $name?';
  }

  @override
  String get deletePetBody =>
      'Se borrarán también sus vacunas, medicamentos, registros de peso y paseos. No se puede deshacer.';

  @override
  String petDeleted(String name) {
    return '$name eliminada.';
  }

  @override
  String get walkHistoryTitle => 'Historial de paseos';

  @override
  String get everyWalkCounts => 'Cada paseo cuenta';

  @override
  String get reliveWalks =>
      'Reviví sus recorridos y compartí un recuerdo juntos.';

  @override
  String get historyLoadError =>
      'No se pudo cargar el historial. Comprobá tu conexión.';

  @override
  String get walksLoadError =>
      'No se pudieron cargar los paseos. Reintentá o actualizá el historial.';

  @override
  String get addPetToLogWalks =>
      'Agregá una mascota para empezar a registrar sus paseos.';

  @override
  String get noWalksYetHome =>
      'Todavía no hay paseos. Iniciá uno desde el botón verde de la app.';

  @override
  String walkWith(String name) {
    return 'Paseo con $name';
  }

  @override
  String durationMinSec(int minutes, int seconds) {
    return '$minutes min $seconds s';
  }

  @override
  String get loadMoreWalks => 'Cargar más paseos';

  @override
  String get deleteWalkTitle => '¿Eliminar este paseo?';

  @override
  String get deleteWalkBody =>
      'Se borrarán el recorrido, sus estadísticas y la foto. Esta acción no se puede deshacer.';

  @override
  String get deleteWalkError => 'No se pudo eliminar el paseo. Reintentá.';

  @override
  String get shareAsPng => 'Compartir como PNG';

  @override
  String get deleteWalk => 'Eliminar paseo';

  @override
  String get noGpsPoints => 'Este paseo no tiene puntos de GPS.';

  @override
  String dateAtTime(String date, String time) {
    return '$date a las $time';
  }

  @override
  String maxSpeedLabel(String speed) {
    return 'Máx. $speed km/h';
  }

  @override
  String get walkPhoto => 'Foto del paseo';

  @override
  String get mapAttribution => 'Mapa © OpenStreetMap contributors';

  @override
  String get shareWalkTitle => 'Compartir paseo';

  @override
  String get sharePrivacyNote =>
      'Compartís la traza y las estadísticas, sin el mapa de calles. La forma del recorrido puede revelar lugares que visitaste.';

  @override
  String get shareImageError =>
      'No se pudo preparar la imagen. Intentá otra vez.';

  @override
  String get shareFailed => 'No se pudo compartir. Volvé a intentarlo.';

  @override
  String get sharingEllipsis => 'Compartiendo…';

  @override
  String get sharePng => 'Compartir PNG';

  @override
  String get traceCaption => 'Traza del recorrido · inicio verde / final rojo';

  @override
  String get shareTagline => 'Un paseo más, un recuerdo juntos.';

  @override
  String get walkNotSaved => 'El paseo no se guardó';

  @override
  String get walkNotSavedBody =>
      'Podés reintentar el guardado. Si salís ahora, perderás este recorrido.';

  @override
  String get back => 'Volver';

  @override
  String get leaveWithoutSaving => 'Salir sin guardar';

  @override
  String get savingWalk => 'Guardando paseo…';

  @override
  String get walkSaved => 'Paseo guardado';

  @override
  String get goodWalk => '¡Buen paseo!';

  @override
  String get distanceCaps => 'DISTANCIA';

  @override
  String get durationLabel => 'Duración';

  @override
  String get avgSpeed => 'Vel. promedio';

  @override
  String get yourPet => 'tu mascota';

  @override
  String walkedWith(String name) {
    return 'Paseaste con $name';
  }

  @override
  String durationSeconds(int count) {
    return '$count s';
  }

  @override
  String durationHm(int hours, int minutes) {
    return '${hours}h ${minutes}min';
  }

  @override
  String get walkInProgress => 'Paseo en curso';

  @override
  String get locationErrorDefault => 'Ocurrió un error de ubicación.';

  @override
  String get mapCaptured => 'Mapa capturado';

  @override
  String get mapCaptureFailed => 'No se pudo capturar el mapa.';

  @override
  String get mapCaptureChip => 'Captura del mapa';

  @override
  String get finishWalk => 'Finalizar paseo';

  @override
  String get gpsActive => 'GPS activo';

  @override
  String get gpsInactive => 'GPS inactivo';

  @override
  String get durationCaps => 'DURACIÓN';

  @override
  String get weightLoadError => 'No se pudo cargar el historial.';

  @override
  String get weightDeleteError => 'No se pudo eliminar el registro.';

  @override
  String get deleteWeightTitle => 'Eliminar registro de peso';

  @override
  String get noWeightRecords => 'Todavía no hay registros de peso.';

  @override
  String get logWeight => 'Registrar peso';

  @override
  String get errWeightPositive => 'Ingresá un peso mayor que cero.';

  @override
  String get weightSaveRetry =>
      'No se pudo guardar el peso. Podés reintentar el mismo registro.';

  @override
  String get confirmIdentity => 'Confirmar identidad';

  @override
  String get currentPassword => 'Contraseña actual';

  @override
  String get confirmGoogleAccount =>
      'Confirmá tu cuenta de Google para continuar.';

  @override
  String get verifyingEllipsis => 'Verificando…';

  @override
  String get confirm => 'Confirmar';

  @override
  String get errEnterCurrentPassword => 'Ingresá tu contraseña actual.';

  @override
  String get identityVerifyError =>
      'No se pudo verificar tu identidad. Intentá otra vez.';

  @override
  String get passwordChangeError =>
      'No se pudo cambiar la contraseña. Intentá otra vez.';

  @override
  String get googlePasswordNote =>
      'Tu cuenta utiliza Google. Gestioná su contraseña desde tu cuenta de Google.';

  @override
  String get newPassword => 'Nueva contraseña';

  @override
  String get repeatNewPassword => 'Repetir nueva contraseña';

  @override
  String get errMin6Chars => 'Usá al menos 6 caracteres.';

  @override
  String get newEmail => 'Correo nuevo';

  @override
  String get sendLink => 'Enviar enlace';

  @override
  String get sendingEllipsis => 'Enviando…';

  @override
  String get checkingEllipsis => 'Comprobando…';

  @override
  String get alreadyOpenedLink => 'Ya abrí el enlace';

  @override
  String linkSentTo(String email) {
    return 'Te enviamos un enlace a $email. Tu correo actual no cambia hasta que lo abras.';
  }

  @override
  String notConfirmedYet(String email) {
    return 'Todavía no confirmaste el enlace. Abrí el correo que enviamos a $email.';
  }

  @override
  String get errEnterNewEmail => 'Ingresá el correo nuevo.';

  @override
  String get errValidEmail => 'Ingresá un correo válido.';

  @override
  String get emailLinkError => 'No se pudo enviar el enlace. Intentá otra vez.';

  @override
  String get emailCheckError => 'No se pudo comprobar. Intentá otra vez.';

  @override
  String get googleEmailNote =>
      'Tu cuenta utiliza Google. Gestioná tu correo desde tu cuenta de Google.';

  @override
  String emailUpdated(String email) {
    return 'Correo actualizado: $email';
  }

  @override
  String get passwordUpdated => 'Contraseña actualizada.';

  @override
  String get deleteAccountTitle => 'Eliminar cuenta';

  @override
  String get deleteAccountBody =>
      'Se borrarán tu cuenta, tus mascotas y sus registros. Esta acción no se puede deshacer.';

  @override
  String get deleteForever => 'Eliminar definitivamente';

  @override
  String get deletionInProgress => 'Eliminación en curso';

  @override
  String get deletionInProgressBody =>
      'Tu cuenta ya está bloqueada y estamos terminando de borrar tus datos. Se completará automáticamente en unos minutos.';

  @override
  String get understood => 'Entendido';

  @override
  String signOutError(String error) {
    return 'No se pudo cerrar sesión: $error';
  }

  @override
  String deleteAccountError(String error) {
    return 'No se pudo eliminar la cuenta: $error';
  }

  @override
  String get privacyTitle => 'Privacidad';

  @override
  String get privacySessionChanged =>
      'La sesión cambió. Volvé a entrar desde tu perfil.';

  @override
  String get privacyLoadError => 'No se pudo cargar la privacidad.';

  @override
  String get prefSavedRemindersFailed =>
      'Preferencia guardada. No se pudieron actualizar los avisos de este dispositivo; reintentá antes de cerrarlo.';

  @override
  String get prefNotSaved => 'No se guardó la preferencia. Reintentá.';

  @override
  String get downloadMyData => 'Descargar mis datos';

  @override
  String get downloadMyDataBody =>
      'El archivo incluye tus fotos y recorridos GPS. Elegí un destino privado cuando lo guardes o compartas.';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get exportIncomplete =>
      'No se completó el archivo. Podés iniciar otra exportación.';

  @override
  String get exportShareFailed =>
      'No se pudo guardar o compartir. El archivo sigue preparado para reintentar.';

  @override
  String get requestNotRegistered =>
      'No se pudo registrar la solicitud. Conservamos el texto para reintentar.';

  @override
  String get yourNotices => 'Tus avisos';

  @override
  String get careReminders => 'Recordatorios de cuidados';

  @override
  String get careRemindersHint => 'Vacunas, medicamentos y tareas';

  @override
  String get teamNotices => 'Avisos del equipo';

  @override
  String get yourData => 'Tus datos';

  @override
  String get yourDataBody =>
      'Descargá tu perfil, mascotas, cuidados, fotos y recorridos en un archivo JSON.';

  @override
  String get prepareFile => 'Preparar archivo';

  @override
  String recordsPrepared(int count) {
    return '$count registros preparados';
  }

  @override
  String get cancelExport => 'Cancelar exportación';

  @override
  String get saveOrShareJson => 'Guardar o compartir JSON';

  @override
  String get requestsTitle => 'Solicitudes';

  @override
  String get requestType => 'Tipo de solicitud';

  @override
  String get reqConsulta => 'Consulta';

  @override
  String get reqAcceso => 'Acceso a información';

  @override
  String get reqCorreccion => 'Corrección';

  @override
  String get reqOposicion => 'Oposición';

  @override
  String get reqBloqueo => 'Bloqueo';

  @override
  String get reqAnonimizacion => 'Anonimización';

  @override
  String get detailLabel => 'Detalle';

  @override
  String get registerRequest => 'Registrar solicitud';

  @override
  String get requestsByEmail =>
      'Por ahora podés enviar tus solicitudes al correo de soporte.';

  @override
  String get requestChannelMissing =>
      'El canal de consultas todavía no está configurado.';

  @override
  String get refreshRequests => 'Actualizar solicitudes';

  @override
  String get authUserDisabled => 'Esta cuenta está deshabilitada.';

  @override
  String get authBadCredentials => 'Correo o contraseña incorrectos.';

  @override
  String get authEmailInUse => 'Ya existe una cuenta con ese correo.';

  @override
  String get authWeakPassword =>
      'La contraseña es demasiado débil (mínimo 6 caracteres).';

  @override
  String get authAccountExists =>
      'Ya hay una cuenta con ese correo creada con otro método de acceso.';

  @override
  String get authRecentLogin =>
      'Por seguridad, volvé a iniciar sesión para hacer este cambio.';

  @override
  String get authUserMismatch =>
      'La cuenta elegida no coincide con la sesión actual.';

  @override
  String get authTooMany =>
      'Demasiados intentos fallidos. Esperá unos minutos y probá de nuevo.';

  @override
  String get authNoInternet => 'No hay conexión a internet.';

  @override
  String get authNotEnabled => 'Este método de acceso no está habilitado.';

  @override
  String get authNoSession => 'No hay sesión iniciada.';

  @override
  String get authSessionChanged =>
      'La sesión cambió. Volvé a intentar desde tu cuenta.';

  @override
  String get authCancelled => 'Operación cancelada.';

  @override
  String get authGoogleAccount =>
      'Tu cuenta utiliza Google para iniciar sesión.';

  @override
  String get authPasswordFields =>
      'Completá la contraseña actual y una nueva de al menos 6 caracteres.';

  @override
  String get authSameEmail => 'Ese ya es el correo de tu cuenta.';

  @override
  String get authSignupFailed => 'No se pudo crear la cuenta.';

  @override
  String get authSigninFailed => 'No se pudo iniciar sesión.';

  @override
  String get authGoogleSigninFailed => 'No se pudo iniciar sesión con Google.';

  @override
  String get authGoogleUnavailable =>
      'El acceso con Google no está disponible en esta plataforma.';

  @override
  String get authPushDisconnect =>
      'No se pudieron desconectar las notificaciones. Reintentá cerrar sesión.';

  @override
  String get authGeneric =>
      'No se pudo completar la operación. Intentá otra vez.';

  @override
  String get googleInterrupted =>
      'El acceso con Google se interrumpió. Probá de nuevo.';

  @override
  String get googleUiUnavailable => 'No se pudo abrir el diálogo de Google.';

  @override
  String get googleConfigError =>
      'La app no está bien configurada para Google. Intentá más tarde.';

  @override
  String get googleUserMismatch =>
      'La cuenta de Google no coincide con la esperada.';

  @override
  String get apiSessionChanged => 'La sesión cambió.';

  @override
  String get apiInvalidResponse =>
      'El servidor devolvió una respuesta inválida. Reintentá.';

  @override
  String get apiListTooLarge =>
      'El listado es demasiado grande para esta pantalla. No se mostraron resultados incompletos.';

  @override
  String get apiTimeout => 'El servidor tardó demasiado en responder.';

  @override
  String get apiOffline =>
      'No hay conexión con el servidor. Comprobá tu conexión a internet.';

  @override
  String apiHttpStatus(String status) {
    return 'El servidor respondió con un error ($status).';
  }

  @override
  String noticeVaccineTitle(String pet) {
    return 'Vacuna de $pet';
  }

  @override
  String noticeVaccineBody(String vaccine, String date) {
    return 'Se acerca $vaccine: $date.';
  }

  @override
  String noticeMedicationTitle(String pet) {
    return 'Medicamento de $pet';
  }

  @override
  String noticeMedicationBody(String medication, String dose) {
    return '$medication: $dose.';
  }

  @override
  String get photoOpenFailed => 'No se pudo abrir la imagen. Probá otra vez.';

  @override
  String get photoTooLarge => 'La imagen es demasiado grande. Probá con otra.';

  @override
  String get photoTooLargeAfter =>
      'La foto es demasiado grande incluso después de reducirla. Probá con otra.';

  @override
  String get photoInvalidType => 'Elegí una imagen JPEG o PNG.';

  @override
  String get photoInvalidOrLarge =>
      'La imagen no es válida o es demasiado grande.';

  @override
  String get photoUnreadable => 'No se pudo leer la imagen. Probá con otra.';

  @override
  String get exportCancelled => 'Exportación cancelada.';

  @override
  String get exportSessionChanged =>
      'La sesión cambió. No se preparó el archivo.';

  @override
  String get exportTooBig => 'El archivo necesita asistencia por su tamaño.';

  @override
  String get exportStartFailed => 'No se pudo iniciar una exportación válida.';

  @override
  String get exportInvalidResponse =>
      'La exportación devolvió una respuesta inválida. Iniciá otra.';

  @override
  String get exportIncompleteService =>
      'No se completó la exportación. Iniciá otra.';

  @override
  String get captureNotReady => 'El mapa todavía no está listo.';

  @override
  String get captureUnreadable => 'No se pudo leer la imagen del mapa.';

  @override
  String get captureTooLarge =>
      'La captura del mapa salió demasiado grande. Probá con menos zoom.';

  @override
  String get locGpsOff => 'El GPS está desactivado. Activalo para continuar.';

  @override
  String get locDenied => 'Permiso de ubicación denegado.';

  @override
  String get locDeniedForever =>
      'Permiso denegado permanentemente. Habilitalo desde ajustes del sistema.';

  @override
  String locFailed(String error) {
    return 'No se pudo obtener la ubicación: $error';
  }

  @override
  String get inactivityTitle => 'Aviso por falta de paseos';

  @override
  String get inactivityHint =>
      'Te avisamos si pasa el plazo que elegís sin registrar un paseo.';

  @override
  String get inactivityAfter => 'Avisar tras';

  @override
  String inactivityDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '$count día',
    );
    return '$_temp0';
  }

  @override
  String get inactivityIncludeNew => 'Incluir mascotas sin paseos registrados';

  @override
  String get kindInactivity => 'Sin paseos';

  @override
  String get premiumTitle => 'Premium';

  @override
  String premiumActiveUntil(String date) {
    return 'Premium activo hasta $date';
  }

  @override
  String get premiumInactive => 'Sin Premium activo';

  @override
  String get premiumSourceManual => 'Concedido por el equipo de PawLife';

  @override
  String get premiumSourcePaid => 'Suscripción';

  @override
  String get premiumNoPurchases =>
      'Por ahora Premium lo concede el equipo de PawLife. Todavía no hay compras dentro de la app.';

  @override
  String get premiumLoadError => 'No se pudo consultar tu estado de Premium.';

  @override
  String get apiAccountDeleting => 'Tu cuenta se está eliminando.';

  @override
  String get apiAccountUnavailable => 'La cuenta no está disponible.';

  @override
  String get apiRateLimited =>
      'Hiciste demasiados cambios seguidos. Esperá un rato y probá de nuevo.';

  @override
  String get apiPhotoProcessor =>
      'No se pudo procesar la foto ahora. Reintentá más tarde.';

  @override
  String get apiInvalidPhoto => 'La foto no es válida.';

  @override
  String get apiTooLarge => 'Los datos son demasiado grandes para guardarse.';

  @override
  String get apiExportExpired => 'La exportación venció. Iniciá otra.';

  @override
  String get apiBillingReview =>
      'Tu cuenta tiene una suscripción o compra que debe revisarse antes de eliminarla.';

  @override
  String get apiPrivacyUnavailable =>
      'El canal de privacidad todavía no está disponible.';

  @override
  String get apiServiceBusy =>
      'El servicio no está disponible en este momento. Reintentá en unos minutos.';

  @override
  String get apiDeviceConflict =>
      'Este dispositivo ya está asociado a otra cuenta.';

  @override
  String get cellNextVaccine => 'PRÓXIMA VACUNA';

  @override
  String homeTasksPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas pendientes hoy',
      one: '$count tarea pendiente hoy',
    );
    return '$_temp0';
  }

  @override
  String get homeAllDone => 'Todo al día';
}
