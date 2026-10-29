// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEs => 'Español';

  @override
  String get languageEn => 'English';

  @override
  String get languagePt => 'Português';

  @override
  String get appearance => 'Appearance';

  @override
  String get appearanceSystem => 'System';

  @override
  String get appearanceLight => 'Light';

  @override
  String get appearanceDark => 'Dark';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileName => 'Name';

  @override
  String get profileEmail => 'Email';

  @override
  String get profileSave => 'Save changes';

  @override
  String get profileSaved => 'Profile saved.';

  @override
  String profileLoadError(String error) {
    return 'Couldn\'t load the profile: $error';
  }

  @override
  String profileSaveError(String error) {
    return 'Couldn\'t save: $error';
  }

  @override
  String get retry => 'Retry';

  @override
  String get privacyAndData => 'Privacy and my data';

  @override
  String get changeEmail => 'Change email';

  @override
  String get changePassword => 'Change password';

  @override
  String get signOut => 'Sign out';

  @override
  String get deleteAccountButton => 'Delete my account';

  @override
  String get welcomeTagline =>
      'Your companion\'s health and happiness,\nall in one place.';

  @override
  String get getStarted => 'Get started';

  @override
  String get signIn => 'Sign in';

  @override
  String get termsPrefix => 'By continuing, you accept our ';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get termsAnd => ' and the ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to manage your pet\'s care.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get orSeparator => 'or';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get noAccountPrefix => 'Don\'t have an account? ';

  @override
  String get signUp => 'Sign up';

  @override
  String get hasAccountPrefix => 'Already have an account? ';

  @override
  String get createAccountTitle => 'Create your account';

  @override
  String get createAccountSubtitle => 'Fill in your details to get started.';

  @override
  String get fullName => 'Full name';

  @override
  String get fullNameHint => 'e.g. Jane Smith';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get createAccount => 'Create account';

  @override
  String get errEnterEmail => 'Enter your email.';

  @override
  String get errInvalidEmail => 'The email format isn\'t valid.';

  @override
  String get errEnterPassword => 'Enter your password.';

  @override
  String get errEmailAbove => 'Enter your email above and tap here again.';

  @override
  String get errEnterName => 'Enter your name.';

  @override
  String get errPasswordShort => 'The password must be at least 6 characters.';

  @override
  String get errPasswordMismatch => 'The passwords don\'t match.';

  @override
  String resetEmailSent(String email) {
    return 'We sent an email to $email.';
  }

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get navHome => 'Home';

  @override
  String get navPets => 'Pets';

  @override
  String get navTasks => 'Tasks';

  @override
  String get navProfile => 'Profile';

  @override
  String get tasksTitle => 'Tasks';

  @override
  String tasksLoadError(String error) {
    return 'Couldn\'t load tasks: $error';
  }

  @override
  String genericSaveError(String error) {
    return 'Couldn\'t save: $error';
  }

  @override
  String get addPetFirst => 'Add a pet before creating a task.';

  @override
  String get newTask => 'New task';

  @override
  String get petLabel => 'Pet';

  @override
  String get taskPrompt => 'What needs to be done?';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get noTasks => 'No tasks yet.';

  @override
  String get deleteTask => 'Delete task';

  @override
  String get speciesDog => 'Dog';

  @override
  String get speciesCat => 'Cat';

  @override
  String get speciesOther => 'Other';

  @override
  String ageDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
    );
    return '$_temp0';
  }

  @override
  String ageWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks',
      one: '$count week',
    );
    return '$_temp0';
  }

  @override
  String ageMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months',
      one: '$count month',
    );
    return '$_temp0';
  }

  @override
  String ageYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years',
      one: '$count year',
    );
    return '$_temp0';
  }

  @override
  String get petsLoadError => 'Couldn\'t load your pets';

  @override
  String get petsEmptyTitle => 'You don\'t have any pets yet';

  @override
  String get petsEmptyBody => 'Add the first one to start tracking their care.';

  @override
  String get addPet => 'Add pet';

  @override
  String get myPets => 'My pets';

  @override
  String get myPetsSubtitle => 'Manage your family\'s furry members.';

  @override
  String get statusNoVaccines => 'No vaccines';

  @override
  String get statusOverdue => 'Vaccine overdue';

  @override
  String get statusDueSoon => 'Vaccine due soon';

  @override
  String get statusHealthy => 'Healthy';

  @override
  String get options => 'Options';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get cellStatus => 'STATUS';

  @override
  String get cellWeight => 'WEIGHT';

  @override
  String get noRecord => 'No record';

  @override
  String get goodMorning => 'Good morning!';

  @override
  String get goodAfternoon => 'Good afternoon!';

  @override
  String get goodEvening => 'Good evening!';

  @override
  String goodMorningName(String name) {
    return 'Good morning, $name!';
  }

  @override
  String goodAfternoonName(String name) {
    return 'Good afternoon, $name!';
  }

  @override
  String goodEveningName(String name) {
    return 'Good evening, $name!';
  }

  @override
  String get todayAgenda => 'This is your agenda for today.';

  @override
  String get activitySummary => 'Activity summary';

  @override
  String get viewWalkHistory => 'View walk history';

  @override
  String get todayTitle => 'Today';

  @override
  String get noTasksToday => 'You have no tasks for today.';

  @override
  String get completedLabel => 'Completed';

  @override
  String updateTaskError(String error) {
    return 'Couldn\'t update the task: $error';
  }

  @override
  String get onlyOnePet => 'You only have one pet for now.';

  @override
  String get changePet => 'Switch pet';

  @override
  String get yourAccount => 'Your account';

  @override
  String get signedIn => 'Signed in';

  @override
  String get loadingEllipsis => 'Loading…';

  @override
  String get noPets => 'No pets';

  @override
  String get tapToAddFirst => 'Tap to add your first one';

  @override
  String get startWalk => 'Start walk';

  @override
  String get readyForAdventure => 'Ready for an adventure?';

  @override
  String get lastWalk => 'Last walk';

  @override
  String get activeTime => 'Active time';

  @override
  String get loadingShort => 'Loading';

  @override
  String get noWalks => 'No walks';

  @override
  String get noWalksToday => 'No walks today';

  @override
  String walksToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count walks today',
      one: '$count walk today',
    );
    return '$_temp0';
  }

  @override
  String minutesShort(int count) {
    return '$count min';
  }

  @override
  String todayAt(String time) {
    return 'Today, $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Yesterday, $time';
  }

  @override
  String get markPending => 'Mark as pending';

  @override
  String get markDone => 'Mark as done';

  @override
  String get logout => 'Sign out';

  @override
  String get pickFromGallery => 'Choose from gallery';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get uploadPhoto => 'Upload photo';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get birthDate => 'Date of birth';

  @override
  String get errEnterPetName => 'Enter the name.';

  @override
  String get errWeightInvalid => 'The weight isn\'t a valid number.';

  @override
  String get errWeightRange => 'The weight must be between 0 and 200 kg.';

  @override
  String get editPet => 'Edit pet';

  @override
  String editPetSubtitle(String name) {
    return 'Update $name\'s details.';
  }

  @override
  String get addPetSubtitle =>
      'Tell us about your companion to personalize their care.';

  @override
  String get savePet => 'Save pet';

  @override
  String get nameLabel => 'Name';

  @override
  String get nameHint => 'e.g. Bella';

  @override
  String get speciesLabel => 'Species';

  @override
  String get breedLabel => 'Breed';

  @override
  String get breedHint => 'e.g. Golden Retriever';

  @override
  String get weightKgLabel => 'Weight (kg)';

  @override
  String get notesLabel => 'Notes';

  @override
  String get optional => 'Optional';

  @override
  String get notesHint => 'Allergies, microchip number, quirks...';

  @override
  String get datePlaceholder => 'mm/dd/yyyy';

  @override
  String get addVaccine => 'Add vaccine';

  @override
  String get editVaccine => 'Edit vaccine';

  @override
  String get vaccineName => 'Vaccine name';

  @override
  String get applicationDate => 'Date given';

  @override
  String get nextDose => 'Next dose';

  @override
  String get remindInAdvance => 'Remind in advance';

  @override
  String get daysUnit => 'days';

  @override
  String get errRange0to365 => 'Enter a value between 0 and 365.';

  @override
  String get logFeeding => 'Log feeding';

  @override
  String get foodType => 'Food type';

  @override
  String get foodTypeHint => 'e.g. dry food';

  @override
  String get amountLabel => 'Amount';

  @override
  String get errValidAmount => 'Enter a valid amount.';

  @override
  String get dateAndTime => 'Date and time';

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String get addMedication => 'Add medication';

  @override
  String get editMedication => 'Edit medication';

  @override
  String get medicationLabel => 'Medication';

  @override
  String get doseLabel => 'Dose';

  @override
  String get doseHint => 'e.g. 1 tablet';

  @override
  String get schedulesLabel => 'Times';

  @override
  String get errTimesFormat => 'Use HH:mm times separated by commas.';

  @override
  String get startDate => 'Start date';

  @override
  String get endDateOptional => 'End date (optional)';

  @override
  String get activeTreatment => 'Active treatment';

  @override
  String get requiredField => 'This field is required.';

  @override
  String get saving => 'Saving…';

  @override
  String get noDate => 'No date';

  @override
  String get tabSummary => 'Summary';

  @override
  String get tabVaccines => 'Vaccines';

  @override
  String get tabMedications => 'Medications';

  @override
  String get tabFeeding => 'Feeding';

  @override
  String get tabWalks => 'Walks';

  @override
  String deleteItemTitle(String name) {
    return 'Delete $name';
  }

  @override
  String get cannotBeUndone => 'This action can\'t be undone.';

  @override
  String deleteError(String error) {
    return 'Couldn\'t delete: $error';
  }

  @override
  String get metricLastWalk => 'LAST WALK';

  @override
  String get metricNextVet => 'NEXT VET VISIT';

  @override
  String get notScheduled => 'Not scheduled';

  @override
  String measuredWhen(String when) {
    return 'Measured $when';
  }

  @override
  String get weightHistory => 'Weight history';

  @override
  String get upcomingCare => 'Upcoming care';

  @override
  String get nothingPending => 'Nothing pending.';

  @override
  String kindWhen(String kind, String when) {
    return '$kind · $when';
  }

  @override
  String get kindVaccine => 'Vaccine';

  @override
  String get kindTask => 'Task';

  @override
  String get recentActivity => 'Recent activity';

  @override
  String get noWalksRecorded => 'No walks recorded yet.';

  @override
  String kmIn(String km, String duration) {
    return '$km km in $duration';
  }

  @override
  String appliedOnNext(String date, String when) {
    return 'Given $date · next $when';
  }

  @override
  String get noVaccinesRecorded => 'No vaccines recorded.';

  @override
  String get noMedicationsRecorded => 'No medications recorded.';

  @override
  String get noFeedingsRecorded => 'No feedings recorded.';

  @override
  String activeWithTimes(String times) {
    return 'Active · $times';
  }

  @override
  String get finished => 'Finished';

  @override
  String get noWalksYetHint =>
      'No walks yet.\nUse the green button below to record one.';

  @override
  String get openWalkHistory => 'Open walk history';

  @override
  String maxSpeedKmh(String speed) {
    return 'max $speed km/h';
  }

  @override
  String get registerWeightCaps => 'LOG WEIGHT';

  @override
  String get relToday => 'today';

  @override
  String get relYesterday => 'yesterday';

  @override
  String get relTomorrow => 'tomorrow';

  @override
  String relDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '$count day ago',
    );
    return '$_temp0';
  }

  @override
  String relMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months ago',
      one: '$count month ago',
    );
    return '$_temp0';
  }

  @override
  String relOverdueDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'overdue by $count days',
      one: 'overdue by $count day',
    );
    return '$_temp0';
  }

  @override
  String relInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count days',
      one: 'in $count day',
    );
    return '$_temp0';
  }

  @override
  String durationHoursMinutes(String hours, String minutes) {
    return '$hours h $minutes min';
  }

  @override
  String cantLoadPets(String error) {
    return 'Couldn\'t load your pets: $error';
  }

  @override
  String get addPetBeforeWalk => 'Add a pet before recording a walk.';

  @override
  String get whoWalks => 'Who are you walking with?';

  @override
  String get choosePet => 'Choose a pet';

  @override
  String deletePetTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get deletePetBody =>
      'Their vaccines, medications, weight records and walks will also be deleted. This can\'t be undone.';

  @override
  String petDeleted(String name) {
    return '$name deleted.';
  }

  @override
  String get walkHistoryTitle => 'Walk history';

  @override
  String get everyWalkCounts => 'Every walk counts';

  @override
  String get reliveWalks => 'Relive their routes and share a memory together.';

  @override
  String get historyLoadError =>
      'Couldn\'t load the history. Check your connection.';

  @override
  String get walksLoadError =>
      'Couldn\'t load the walks. Retry or refresh the history.';

  @override
  String get addPetToLogWalks => 'Add a pet to start recording their walks.';

  @override
  String get noWalksYetHome =>
      'No walks yet. Start one from the app\'s green button.';

  @override
  String walkWith(String name) {
    return 'Walk with $name';
  }

  @override
  String durationMinSec(int minutes, int seconds) {
    return '$minutes min $seconds s';
  }

  @override
  String get loadMoreWalks => 'Load more walks';

  @override
  String get deleteWalkTitle => 'Delete this walk?';

  @override
  String get deleteWalkBody =>
      'The route, its statistics and the photo will be deleted. This action can\'t be undone.';

  @override
  String get deleteWalkError => 'Couldn\'t delete the walk. Try again.';

  @override
  String get shareAsPng => 'Share as PNG';

  @override
  String get deleteWalk => 'Delete walk';

  @override
  String get noGpsPoints => 'This walk has no GPS points.';

  @override
  String dateAtTime(String date, String time) {
    return '$date at $time';
  }

  @override
  String maxSpeedLabel(String speed) {
    return 'Max $speed km/h';
  }

  @override
  String get walkPhoto => 'Walk photo';

  @override
  String get mapAttribution => 'Map © OpenStreetMap contributors';

  @override
  String get shareWalkTitle => 'Share walk';

  @override
  String get sharePrivacyNote =>
      'You\'re sharing the route line and statistics, without the street map. The shape of the route can reveal places you visited.';

  @override
  String get shareImageError => 'Couldn\'t prepare the image. Try again.';

  @override
  String get shareFailed => 'Couldn\'t share. Please try again.';

  @override
  String get sharingEllipsis => 'Sharing…';

  @override
  String get sharePng => 'Share PNG';

  @override
  String get traceCaption => 'Route trace · green start / red end';

  @override
  String get shareTagline => 'One more walk, a memory together.';

  @override
  String get walkNotSaved => 'The walk wasn\'t saved';

  @override
  String get walkNotSavedBody =>
      'You can retry saving. If you leave now, you\'ll lose this route.';

  @override
  String get back => 'Back';

  @override
  String get leaveWithoutSaving => 'Leave without saving';

  @override
  String get savingWalk => 'Saving walk…';

  @override
  String get walkSaved => 'Walk saved';

  @override
  String get goodWalk => 'Great walk!';

  @override
  String get distanceCaps => 'DISTANCE';

  @override
  String get durationLabel => 'Duration';

  @override
  String get avgSpeed => 'Avg. speed';

  @override
  String get yourPet => 'your pet';

  @override
  String walkedWith(String name) {
    return 'You walked with $name';
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
  String get walkInProgress => 'Walk in progress';

  @override
  String get locationErrorDefault => 'A location error occurred.';

  @override
  String get mapCaptured => 'Map captured';

  @override
  String get mapCaptureFailed => 'Couldn\'t capture the map.';

  @override
  String get mapCaptureChip => 'Map capture';

  @override
  String get finishWalk => 'Finish walk';

  @override
  String get gpsActive => 'GPS active';

  @override
  String get gpsInactive => 'GPS inactive';

  @override
  String get durationCaps => 'DURATION';

  @override
  String get weightLoadError => 'Couldn\'t load the history.';

  @override
  String get weightDeleteError => 'Couldn\'t delete the record.';

  @override
  String get deleteWeightTitle => 'Delete weight record';

  @override
  String get noWeightRecords => 'No weight records yet.';

  @override
  String get logWeight => 'Log weight';

  @override
  String get errWeightPositive => 'Enter a weight greater than zero.';

  @override
  String get weightSaveRetry =>
      'Couldn\'t save the weight. You can retry the same record.';

  @override
  String get confirmIdentity => 'Confirm identity';

  @override
  String get currentPassword => 'Current password';

  @override
  String get confirmGoogleAccount => 'Confirm your Google account to continue.';

  @override
  String get verifyingEllipsis => 'Verifying…';

  @override
  String get confirm => 'Confirm';

  @override
  String get errEnterCurrentPassword => 'Enter your current password.';

  @override
  String get identityVerifyError =>
      'Couldn\'t verify your identity. Try again.';

  @override
  String get passwordChangeError => 'Couldn\'t change the password. Try again.';

  @override
  String get googlePasswordNote =>
      'Your account uses Google. Manage its password from your Google account.';

  @override
  String get newPassword => 'New password';

  @override
  String get repeatNewPassword => 'Repeat new password';

  @override
  String get errMin6Chars => 'Use at least 6 characters.';

  @override
  String get newEmail => 'New email';

  @override
  String get sendLink => 'Send link';

  @override
  String get sendingEllipsis => 'Sending…';

  @override
  String get checkingEllipsis => 'Checking…';

  @override
  String get alreadyOpenedLink => 'I\'ve opened the link';

  @override
  String linkSentTo(String email) {
    return 'We sent a link to $email. Your current email won\'t change until you open it.';
  }

  @override
  String notConfirmedYet(String email) {
    return 'You haven\'t confirmed the link yet. Open the email we sent to $email.';
  }

  @override
  String get errEnterNewEmail => 'Enter the new email.';

  @override
  String get errValidEmail => 'Enter a valid email.';

  @override
  String get emailLinkError => 'Couldn\'t send the link. Try again.';

  @override
  String get emailCheckError => 'Couldn\'t check. Try again.';

  @override
  String get googleEmailNote =>
      'Your account uses Google. Manage your email from your Google account.';

  @override
  String emailUpdated(String email) {
    return 'Email updated: $email';
  }

  @override
  String get passwordUpdated => 'Password updated.';

  @override
  String get deleteAccountTitle => 'Delete account';

  @override
  String get deleteAccountBody =>
      'Your account, your pets and their records will be deleted. This action can\'t be undone.';

  @override
  String get deleteForever => 'Delete permanently';

  @override
  String get deletionInProgress => 'Deletion in progress';

  @override
  String get deletionInProgressBody =>
      'Your account is already locked and we\'re finishing deleting your data. It will complete automatically in a few minutes.';

  @override
  String get understood => 'Got it';

  @override
  String signOutError(String error) {
    return 'Couldn\'t sign out: $error';
  }

  @override
  String deleteAccountError(String error) {
    return 'Couldn\'t delete the account: $error';
  }

  @override
  String get privacyTitle => 'Privacy';

  @override
  String get privacySessionChanged =>
      'The session changed. Sign in again from your profile.';

  @override
  String get privacyLoadError => 'Couldn\'t load privacy settings.';

  @override
  String get prefSavedRemindersFailed =>
      'Preference saved. This device\'s notifications couldn\'t be updated; retry before closing.';

  @override
  String get prefNotSaved => 'The preference wasn\'t saved. Try again.';

  @override
  String get downloadMyData => 'Download my data';

  @override
  String get downloadMyDataBody =>
      'The file includes your photos and GPS routes. Choose a private destination when you save or share it.';

  @override
  String get continueLabel => 'Continue';

  @override
  String get exportIncomplete =>
      'The file wasn\'t completed. You can start another export.';

  @override
  String get exportShareFailed =>
      'Couldn\'t save or share. The file is still ready to retry.';

  @override
  String get requestNotRegistered =>
      'Couldn\'t register the request. We kept your text so you can retry.';

  @override
  String get yourNotices => 'Your notifications';

  @override
  String get careReminders => 'Care reminders';

  @override
  String get careRemindersHint => 'Vaccines, medications and tasks';

  @override
  String get teamNotices => 'Team notices';

  @override
  String get yourData => 'Your data';

  @override
  String get yourDataBody =>
      'Download your profile, pets, care records, photos and routes as a JSON file.';

  @override
  String get prepareFile => 'Prepare file';

  @override
  String recordsPrepared(int count) {
    return '$count records prepared';
  }

  @override
  String get cancelExport => 'Cancel export';

  @override
  String get saveOrShareJson => 'Save or share JSON';

  @override
  String get requestsTitle => 'Requests';

  @override
  String get requestType => 'Request type';

  @override
  String get reqConsulta => 'Inquiry';

  @override
  String get reqAcceso => 'Access to information';

  @override
  String get reqCorreccion => 'Correction';

  @override
  String get reqOposicion => 'Objection';

  @override
  String get reqBloqueo => 'Blocking';

  @override
  String get reqAnonimizacion => 'Anonymization';

  @override
  String get detailLabel => 'Details';

  @override
  String get registerRequest => 'Submit request';

  @override
  String get requestsByEmail =>
      'For now you can send your requests to the support email.';

  @override
  String get requestChannelMissing =>
      'The inquiries channel isn\'t set up yet.';

  @override
  String get refreshRequests => 'Refresh requests';

  @override
  String get authUserDisabled => 'This account is disabled.';

  @override
  String get authBadCredentials => 'Incorrect email or password.';

  @override
  String get authEmailInUse => 'An account with that email already exists.';

  @override
  String get authWeakPassword =>
      'The password is too weak (minimum 6 characters).';

  @override
  String get authAccountExists =>
      'An account with that email already exists using a different sign-in method.';

  @override
  String get authRecentLogin =>
      'For security, sign in again to make this change.';

  @override
  String get authUserMismatch =>
      'The chosen account doesn\'t match the current session.';

  @override
  String get authTooMany =>
      'Too many failed attempts. Wait a few minutes and try again.';

  @override
  String get authNoInternet => 'No internet connection.';

  @override
  String get authNotEnabled => 'This sign-in method isn\'t enabled.';

  @override
  String get authNoSession => 'You\'re not signed in.';

  @override
  String get authSessionChanged =>
      'The session changed. Try again from your account.';

  @override
  String get authCancelled => 'Operation cancelled.';

  @override
  String get authGoogleAccount => 'Your account signs in with Google.';

  @override
  String get authPasswordFields =>
      'Fill in the current password and a new one of at least 6 characters.';

  @override
  String get authSameEmail => 'That\'s already your account\'s email.';

  @override
  String get authSignupFailed => 'Couldn\'t create the account.';

  @override
  String get authSigninFailed => 'Couldn\'t sign in.';

  @override
  String get authGoogleSigninFailed => 'Couldn\'t sign in with Google.';

  @override
  String get authGoogleUnavailable =>
      'Google sign-in isn\'t available on this platform.';

  @override
  String get authPushDisconnect =>
      'Couldn\'t disconnect notifications. Try signing out again.';

  @override
  String get authGeneric => 'Couldn\'t complete the operation. Try again.';

  @override
  String get googleInterrupted => 'Google sign-in was interrupted. Try again.';

  @override
  String get googleUiUnavailable => 'Couldn\'t open the Google dialog.';

  @override
  String get googleConfigError =>
      'The app isn\'t configured correctly for Google. Try again later.';

  @override
  String get googleUserMismatch =>
      'The Google account doesn\'t match the expected one.';

  @override
  String get apiSessionChanged => 'The session changed.';

  @override
  String get apiInvalidResponse =>
      'The server returned an invalid response. Try again.';

  @override
  String get apiListTooLarge =>
      'The list is too large for this screen. Incomplete results were not shown.';

  @override
  String get apiTimeout => 'The server took too long to respond.';

  @override
  String get apiOffline =>
      'Can\'t reach the server. Check your internet connection.';

  @override
  String apiHttpStatus(String status) {
    return 'The server responded with an error ($status).';
  }

  @override
  String noticeVaccineTitle(String pet) {
    return '$pet\'s vaccine';
  }

  @override
  String noticeVaccineBody(String vaccine, String date) {
    return '$vaccine is coming up: $date.';
  }

  @override
  String noticeMedicationTitle(String pet) {
    return '$pet\'s medication';
  }

  @override
  String noticeMedicationBody(String medication, String dose) {
    return '$medication: $dose.';
  }

  @override
  String get photoOpenFailed => 'Couldn\'t open the image. Try again.';

  @override
  String get photoTooLarge => 'The image is too large. Try another one.';

  @override
  String get photoTooLargeAfter =>
      'The photo is too large even after shrinking it. Try another one.';

  @override
  String get photoInvalidType => 'Choose a JPEG or PNG image.';

  @override
  String get photoInvalidOrLarge => 'The image isn\'t valid or is too large.';

  @override
  String get photoUnreadable => 'Couldn\'t read the image. Try another one.';

  @override
  String get exportCancelled => 'Export cancelled.';

  @override
  String get exportSessionChanged =>
      'The session changed. The file wasn\'t prepared.';

  @override
  String get exportTooBig => 'The file is too large and needs assistance.';

  @override
  String get exportStartFailed => 'Couldn\'t start a valid export.';

  @override
  String get exportInvalidResponse =>
      'The export returned an invalid response. Start another one.';

  @override
  String get exportIncompleteService =>
      'The export wasn\'t completed. Start another one.';

  @override
  String get captureNotReady => 'The map isn\'t ready yet.';

  @override
  String get captureUnreadable => 'Couldn\'t read the map image.';

  @override
  String get captureTooLarge =>
      'The map capture is too large. Try zooming out less.';

  @override
  String get locGpsOff => 'GPS is off. Turn it on to continue.';

  @override
  String get locDenied => 'Location permission denied.';

  @override
  String get locDeniedForever =>
      'Permission permanently denied. Enable it in system settings.';

  @override
  String locFailed(String error) {
    return 'Couldn\'t get the location: $error';
  }

  @override
  String get inactivityTitle => 'No-walk reminder';

  @override
  String get inactivityHint =>
      'We\'ll remind you if the period you choose passes without a recorded walk.';

  @override
  String get inactivityAfter => 'Remind after';

  @override
  String inactivityDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
    );
    return '$_temp0';
  }

  @override
  String get inactivityIncludeNew => 'Include pets with no recorded walks';

  @override
  String get kindInactivity => 'No walks';

  @override
  String get premiumTitle => 'Premium';

  @override
  String premiumActiveUntil(String date) {
    return 'Premium active until $date';
  }

  @override
  String get premiumInactive => 'No active Premium';

  @override
  String get premiumSourceManual => 'Granted by the PawLife team';

  @override
  String get premiumSourcePaid => 'Subscription';

  @override
  String get premiumNoPurchases =>
      'Test mode: the purchase is simulated and nothing is charged.';

  @override
  String get premiumLoadError => 'Couldn\'t check your Premium status.';

  @override
  String get apiAccountDeleting => 'Your account is being deleted.';

  @override
  String get apiAccountUnavailable => 'The account isn\'t available.';

  @override
  String get apiRateLimited =>
      'Too many changes in a row. Wait a while and try again.';

  @override
  String get apiPhotoProcessor =>
      'The photo can\'t be processed right now. Try again later.';

  @override
  String get apiInvalidPhoto => 'The photo isn\'t valid.';

  @override
  String get apiTooLarge => 'The data is too large to save.';

  @override
  String get apiExportExpired => 'The export expired. Start another one.';

  @override
  String get apiBillingReview =>
      'Your account has a subscription or purchase that must be reviewed before it can be deleted.';

  @override
  String get apiPrivacyUnavailable =>
      'The privacy channel isn\'t available yet.';

  @override
  String get apiServiceBusy =>
      'The service isn\'t available right now. Try again in a few minutes.';

  @override
  String get apiDeviceConflict =>
      'This device is already linked to another account.';

  @override
  String get cellNextVaccine => 'NEXT VACCINE';

  @override
  String homeTasksPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks left today',
      one: '$count task left today',
    );
    return '$_temp0';
  }

  @override
  String get homeAllDone => 'All caught up';

  @override
  String get holdToFinish => 'Press and hold to finish';

  @override
  String get shareStyleForest => 'Forest';

  @override
  String get shareStyleMint => 'Mint';

  @override
  String get shareStyleStats => 'Stats';

  @override
  String get shareStyleLabel => 'Card style';

  @override
  String get wearableStart => 'START';

  @override
  String get wearablePause => 'PAUSE';

  @override
  String get wearableResume => 'RESUME';

  @override
  String get wearableStop => 'FINISH';

  @override
  String get wearableSaving => 'SAVING';

  @override
  String get wearableSaved => 'SAVED';

  @override
  String get wearableDone => 'DONE';

  @override
  String get wearableRetry => 'RETRY';

  @override
  String get wearableNoGps => 'NO GPS';

  @override
  String get wearableNoPet => 'NO PET';

  @override
  String get wearableNotSaved => 'NOT SAVED';

  @override
  String get wearableOpen => 'Watch mode';

  @override
  String get visitsTitle => 'Vet visits';

  @override
  String get visitsEmpty => 'No visits logged yet.';

  @override
  String get visitsAdd => 'Log visit';

  @override
  String get visitReason => 'Reason';

  @override
  String get visitVet => 'Vet or clinic';

  @override
  String get visitNotes => 'Notes';

  @override
  String get visitDate => 'Date';

  @override
  String get visitNextDate => 'Next visit';

  @override
  String get visitNone => 'None';

  @override
  String get visitDeleteTitle => 'Delete visit';

  @override
  String get visitsLoadError => 'Couldn\'t load the visits.';

  @override
  String get visitsSaveError => 'Couldn\'t save the visit. Try again.';

  @override
  String get visitsDeleteError => 'Couldn\'t delete the visit.';

  @override
  String get errVisitReason => 'Enter the reason for the visit.';

  @override
  String get errVisitNextBefore =>
      'The next visit must be after the visit date.';

  @override
  String get premiumHeadline => 'More to care better';

  @override
  String get premiumBenefitsTitle => 'What\'s included';

  @override
  String get premiumBenefitPdf => 'Vet report';

  @override
  String get premiumBenefitPdfDesc =>
      'Vaccines, weight and walks in a PDF ready for the visit.';

  @override
  String get premiumBenefitStats => 'Walk stats';

  @override
  String get premiumBenefitStatsDesc =>
      'Distance and time by week and by month.';

  @override
  String get premiumBenefitPets => 'Unlimited pets';

  @override
  String get premiumBenefitPetsDesc =>
      'Your whole furry family in one account.';

  @override
  String get premiumBenefitCards => 'Exclusive cards';

  @override
  String get premiumBenefitCardsDesc => 'New styles to share every walk.';

  @override
  String get premiumBenefitReminders => 'Advanced reminders';

  @override
  String get premiumBenefitRemindersDesc =>
      'Repeats and alerts for the whole family.';

  @override
  String get premiumPlanMonthly => 'Monthly';

  @override
  String get premiumPlanYearly => 'Yearly';

  @override
  String get premiumPerMonth => '/month';

  @override
  String get premiumPerYear => '/year';

  @override
  String get premiumSave => 'Save 33%';

  @override
  String get premiumSubscribe => 'Subscribe';

  @override
  String get premiumConfirmTitle => 'Confirm subscription';

  @override
  String get premiumConfirm => 'Confirm purchase';

  @override
  String get premiumTestBadge => 'Test';

  @override
  String get premiumSuccess => 'Done! You\'re Premium now.';

  @override
  String premiumSimulatedActive(String date) {
    return 'Test Premium active until $date';
  }

  @override
  String get premiumCancelSimulated => 'Cancel test subscription';

  @override
  String get premiumPurchaseError =>
      'Couldn\'t complete the purchase. Try again.';

  @override
  String get taskTimeLabel => 'Time';

  @override
  String get errTaskEmpty => 'Write what needs to be done.';

  @override
  String get errTaskPast => 'Pick a future date and time.';

  @override
  String get welcomeHeadline => 'Closer.\nAlways.';

  @override
  String get vaccineNewDose => 'New dose';

  @override
  String vaccineDoseOn(String date) {
    return 'Given on $date';
  }

  @override
  String vaccinePreviousDoses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count previous doses',
      one: '1 previous dose',
    );
    return '$_temp0';
  }

  @override
  String get vaccineHideHistory => 'Hide history';

  @override
  String get healthAtAGlance => 'Health at a glance';

  @override
  String vaccinesUpToDate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count up to date',
      one: '1 up to date',
      zero: 'No vaccines',
    );
    return '$_temp0';
  }

  @override
  String vaccinesOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count overdue',
      one: '1 overdue',
      zero: 'Nothing overdue',
    );
    return '$_temp0';
  }

  @override
  String get petViewProfile => 'View profile';

  @override
  String get petSwitch => 'Switch pet';

  @override
  String get editTask => 'Edit task';

  @override
  String get apiPlanPetLimit =>
      'The free plan allows up to 2 pets. Upgrade to Premium to add more.';

  @override
  String get premiumLockedCard => 'This style is Premium.';

  @override
  String get premiumFreeLimits =>
      'Free plan: up to 2 pets and the classic walk card.';

  @override
  String get premiumCompareFree => 'Free';

  @override
  String get premiumComparePremium => 'Premium';

  @override
  String get premiumRowPets => 'Pets';

  @override
  String get premiumRowPetsFree => 'Up to 2';

  @override
  String get premiumRowPetsPremium => 'Unlimited';

  @override
  String get premiumRowCards => 'Walk cards';

  @override
  String get premiumRowCardsFree => '1 style';

  @override
  String get premiumRowCardsPremium => '3 styles';

  @override
  String get premiumComingSoon => 'Coming soon to Premium';

  @override
  String get premiumTodayTitle => 'Premium includes today';

  @override
  String get premiumTestScope =>
      'In test mode the card styles unlock; the pet limit is only lifted by a real server-side Premium.';

  @override
  String get apiPlanTaskLimit =>
      'The free plan allows up to 5 pending tasks. Complete one or upgrade to Premium.';

  @override
  String get premiumRowTasks => 'Pending tasks';

  @override
  String get premiumRowTasksFree => 'Up to 5';

  @override
  String get premiumRowTasksPremium => 'Unlimited';

  @override
  String get premiumUsageTitle => 'Your free plan usage';

  @override
  String get premiumUsagePets => 'Pets';

  @override
  String get premiumUsageTasks => 'Pending tasks';
}
