// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

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
  String get appearance => 'Aparência';

  @override
  String get appearanceSystem => 'Sistema';

  @override
  String get appearanceLight => 'Claro';

  @override
  String get appearanceDark => 'Escuro';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileName => 'Nome';

  @override
  String get profileEmail => 'E-mail';

  @override
  String get profileSave => 'Salvar alterações';

  @override
  String get profileSaved => 'Perfil salvo.';

  @override
  String profileLoadError(String error) {
    return 'Não foi possível carregar o perfil: $error';
  }

  @override
  String profileSaveError(String error) {
    return 'Não foi possível salvar: $error';
  }

  @override
  String get retry => 'Tentar novamente';

  @override
  String get privacyAndData => 'Privacidade e meus dados';

  @override
  String get changeEmail => 'Alterar e-mail';

  @override
  String get changePassword => 'Alterar senha';

  @override
  String get signOut => 'Sair';

  @override
  String get deleteAccountButton => 'Excluir minha conta';

  @override
  String get welcomeTagline =>
      'A saúde e a felicidade do seu companheiro,\ntudo em um só lugar.';

  @override
  String get getStarted => 'Começar';

  @override
  String get signIn => 'Entrar';

  @override
  String get termsPrefix => 'Ao continuar, você aceita nossos ';

  @override
  String get termsOfService => 'Termos de Serviço';

  @override
  String get termsAnd => ' e a ';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get welcomeBack => 'Bem-vindo de volta';

  @override
  String get loginSubtitle => 'Entre para gerenciar os cuidados do seu pet.';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Senha';

  @override
  String get forgotPassword => 'Esqueceu sua senha?';

  @override
  String get orSeparator => 'ou';

  @override
  String get continueWithGoogle => 'Continuar com o Google';

  @override
  String get noAccountPrefix => 'Não tem uma conta? ';

  @override
  String get signUp => 'Cadastre-se';

  @override
  String get hasAccountPrefix => 'Já tem uma conta? ';

  @override
  String get createAccountTitle => 'Crie sua conta';

  @override
  String get createAccountSubtitle => 'Preencha seus dados para começar.';

  @override
  String get fullName => 'Nome completo';

  @override
  String get fullNameHint => 'Ex.: Maria Silva';

  @override
  String get confirmPassword => 'Confirmar senha';

  @override
  String get createAccount => 'Criar conta';

  @override
  String get errEnterEmail => 'Digite seu e-mail.';

  @override
  String get errInvalidEmail => 'O e-mail não tem um formato válido.';

  @override
  String get errEnterPassword => 'Digite sua senha.';

  @override
  String get errEmailAbove => 'Digite seu e-mail acima e toque aqui novamente.';

  @override
  String get errEnterName => 'Digite seu nome.';

  @override
  String get errPasswordShort => 'A senha deve ter pelo menos 6 caracteres.';

  @override
  String get errPasswordMismatch => 'As senhas não coincidem.';

  @override
  String resetEmailSent(String email) {
    return 'Enviamos um e-mail para $email.';
  }

  @override
  String get showPassword => 'Mostrar senha';

  @override
  String get hidePassword => 'Ocultar senha';

  @override
  String get navHome => 'Início';

  @override
  String get navPets => 'Pets';

  @override
  String get navTasks => 'Tarefas';

  @override
  String get navProfile => 'Perfil';

  @override
  String get tasksTitle => 'Tarefas';

  @override
  String tasksLoadError(String error) {
    return 'Não foi possível carregar as tarefas: $error';
  }

  @override
  String genericSaveError(String error) {
    return 'Não foi possível salvar: $error';
  }

  @override
  String get addPetFirst => 'Adicione um pet antes de criar uma tarefa.';

  @override
  String get newTask => 'Nova tarefa';

  @override
  String get petLabel => 'Pet';

  @override
  String get taskPrompt => 'O que precisa ser feito?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar';

  @override
  String get noTasks => 'Ainda não há tarefas.';

  @override
  String get deleteTask => 'Excluir tarefa';

  @override
  String get speciesDog => 'Cão';

  @override
  String get speciesCat => 'Gato';

  @override
  String get speciesOther => 'Outra';

  @override
  String ageDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias',
      one: '$count dia',
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
      one: '$count mês',
    );
    return '$_temp0';
  }

  @override
  String ageYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count anos',
      one: '$count ano',
    );
    return '$_temp0';
  }

  @override
  String get petsLoadError => 'Não foi possível carregar seus pets';

  @override
  String get petsEmptyTitle => 'Você ainda não tem pets';

  @override
  String get petsEmptyBody =>
      'Adicione o primeiro para começar a acompanhar os cuidados.';

  @override
  String get addPet => 'Adicionar pet';

  @override
  String get myPets => 'Meus pets';

  @override
  String get myPetsSubtitle => 'Gerencie os peludos da sua família.';

  @override
  String get statusNoVaccines => 'Sem vacinas';

  @override
  String get statusOverdue => 'Vacina vencida';

  @override
  String get statusDueSoon => 'Vacina próxima';

  @override
  String get statusHealthy => 'Saudável';

  @override
  String get options => 'Opções';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Excluir';

  @override
  String get cellStatus => 'ESTADO';

  @override
  String get cellWeight => 'PESO';

  @override
  String get noRecord => 'Sem registro';

  @override
  String get goodMorning => 'Bom dia!';

  @override
  String get goodAfternoon => 'Boa tarde!';

  @override
  String get goodEvening => 'Boa noite!';

  @override
  String goodMorningName(String name) {
    return 'Bom dia, $name!';
  }

  @override
  String goodAfternoonName(String name) {
    return 'Boa tarde, $name!';
  }

  @override
  String goodEveningName(String name) {
    return 'Boa noite, $name!';
  }

  @override
  String get todayAgenda => 'Esta é a sua agenda de hoje.';

  @override
  String get activitySummary => 'Resumo de atividade';

  @override
  String get viewWalkHistory => 'Ver histórico de passeios';

  @override
  String get todayTitle => 'Hoje';

  @override
  String get noTasksToday => 'Você não tem tarefas para hoje.';

  @override
  String get completedLabel => 'Concluída';

  @override
  String updateTaskError(String error) {
    return 'Não foi possível atualizar a tarefa: $error';
  }

  @override
  String get onlyOnePet => 'Você só tem um pet por enquanto.';

  @override
  String get changePet => 'Trocar de pet';

  @override
  String get yourAccount => 'Sua conta';

  @override
  String get signedIn => 'Sessão iniciada';

  @override
  String get loadingEllipsis => 'Carregando…';

  @override
  String get noPets => 'Sem pets';

  @override
  String get tapToAddFirst => 'Toque para adicionar o primeiro';

  @override
  String get startWalk => 'Iniciar passeio';

  @override
  String get readyForAdventure => 'Prontos para uma aventura?';

  @override
  String get lastWalk => 'Último passeio';

  @override
  String get activeTime => 'Tempo ativo';

  @override
  String get loadingShort => 'Carregando';

  @override
  String get noWalks => 'Sem passeios';

  @override
  String get noWalksToday => 'Sem passeios hoje';

  @override
  String walksToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count passeios hoje',
      one: '$count passeio hoje',
    );
    return '$_temp0';
  }

  @override
  String minutesShort(int count) {
    return '$count min';
  }

  @override
  String todayAt(String time) {
    return 'Hoje, $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Ontem, $time';
  }

  @override
  String get markPending => 'Marcar como pendente';

  @override
  String get markDone => 'Marcar como concluída';

  @override
  String get logout => 'Sair';

  @override
  String get pickFromGallery => 'Escolher da galeria';

  @override
  String get takePhoto => 'Tirar uma foto';

  @override
  String get removePhoto => 'Remover foto';

  @override
  String get uploadPhoto => 'Enviar foto';

  @override
  String get changePhoto => 'Trocar foto';

  @override
  String get birthDate => 'Data de nascimento';

  @override
  String get errEnterPetName => 'Digite o nome.';

  @override
  String get errWeightInvalid => 'O peso não é um número válido.';

  @override
  String get errWeightRange => 'O peso deve estar entre 0 e 200 kg.';

  @override
  String get editPet => 'Editar pet';

  @override
  String editPetSubtitle(String name) {
    return 'Atualize os dados de $name.';
  }

  @override
  String get addPetSubtitle =>
      'Conte-nos sobre seu companheiro para personalizar os cuidados.';

  @override
  String get savePet => 'Salvar pet';

  @override
  String get nameLabel => 'Nome';

  @override
  String get nameHint => 'Ex.: Bella';

  @override
  String get speciesLabel => 'Espécie';

  @override
  String get breedLabel => 'Raça';

  @override
  String get breedHint => 'Ex.: Golden Retriever';

  @override
  String get weightKgLabel => 'Peso (kg)';

  @override
  String get notesLabel => 'Notas';

  @override
  String get optional => 'Opcional';

  @override
  String get notesHint => 'Alergias, número do microchip, manias...';

  @override
  String get datePlaceholder => 'dd/mm/aaaa';

  @override
  String get addVaccine => 'Adicionar vacina';

  @override
  String get editVaccine => 'Editar vacina';

  @override
  String get vaccineName => 'Nome da vacina';

  @override
  String get applicationDate => 'Data de aplicação';

  @override
  String get nextDose => 'Próxima dose';

  @override
  String get remindInAdvance => 'Avisar com antecedência';

  @override
  String get daysUnit => 'dias';

  @override
  String get errRange0to365 => 'Digite um valor entre 0 e 365.';

  @override
  String get logFeeding => 'Registrar alimentação';

  @override
  String get foodType => 'Tipo de alimento';

  @override
  String get foodTypeHint => 'Ex.: ração seca';

  @override
  String get amountLabel => 'Quantidade';

  @override
  String get errValidAmount => 'Digite uma quantidade válida.';

  @override
  String get dateAndTime => 'Data e hora';

  @override
  String get notesOptional => 'Notas (opcional)';

  @override
  String get addMedication => 'Adicionar medicamento';

  @override
  String get editMedication => 'Editar medicamento';

  @override
  String get medicationLabel => 'Medicamento';

  @override
  String get doseLabel => 'Dose';

  @override
  String get doseHint => 'Ex.: 1 comprimido';

  @override
  String get schedulesLabel => 'Horários';

  @override
  String get errTimesFormat => 'Use horários HH:mm separados por vírgula.';

  @override
  String get startDate => 'Data de início';

  @override
  String get endDateOptional => 'Data de término (opcional)';

  @override
  String get activeTreatment => 'Tratamento ativo';

  @override
  String get requiredField => 'Este campo é obrigatório.';

  @override
  String get saving => 'Salvando…';

  @override
  String get noDate => 'Sem data';

  @override
  String get tabSummary => 'Resumo';

  @override
  String get tabVaccines => 'Vacinas';

  @override
  String get tabMedications => 'Medicamentos';

  @override
  String get tabFeeding => 'Alimentação';

  @override
  String get tabWalks => 'Passeios';

  @override
  String deleteItemTitle(String name) {
    return 'Excluir $name';
  }

  @override
  String get cannotBeUndone => 'Esta ação não pode ser desfeita.';

  @override
  String deleteError(String error) {
    return 'Não foi possível excluir: $error';
  }

  @override
  String get metricLastWalk => 'ÚLTIMO PASSEIO';

  @override
  String get metricNextVet => 'PRÓXIMA VISITA AO VET';

  @override
  String get notScheduled => 'Não agendada';

  @override
  String measuredWhen(String when) {
    return 'Medido $when';
  }

  @override
  String get weightHistory => 'Histórico de peso';

  @override
  String get upcomingCare => 'Próximos cuidados';

  @override
  String get nothingPending => 'Nada pendente.';

  @override
  String kindWhen(String kind, String when) {
    return '$kind · $when';
  }

  @override
  String get kindVaccine => 'Vacina';

  @override
  String get kindTask => 'Tarefa';

  @override
  String get recentActivity => 'Atividade recente';

  @override
  String get noWalksRecorded => 'Ainda não há passeios registrados.';

  @override
  String kmIn(String km, String duration) {
    return '$km km em $duration';
  }

  @override
  String appliedOnNext(String date, String when) {
    return 'Aplicada em $date · próxima $when';
  }

  @override
  String get noVaccinesRecorded => 'Sem vacinas registradas.';

  @override
  String get noMedicationsRecorded => 'Sem medicamentos registrados.';

  @override
  String get noFeedingsRecorded => 'Sem alimentações registradas.';

  @override
  String activeWithTimes(String times) {
    return 'Ativo · $times';
  }

  @override
  String get finished => 'Finalizado';

  @override
  String get noWalksYetHint =>
      'Ainda não há passeios.\nUse o botão verde abaixo para registrar um.';

  @override
  String get openWalkHistory => 'Abrir histórico de passeios';

  @override
  String maxSpeedKmh(String speed) {
    return 'máx $speed km/h';
  }

  @override
  String get registerWeightCaps => 'REGISTRAR PESO';

  @override
  String get relToday => 'hoje';

  @override
  String get relYesterday => 'ontem';

  @override
  String get relTomorrow => 'amanhã';

  @override
  String relDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count dias',
      one: 'há $count dia',
    );
    return '$_temp0';
  }

  @override
  String relMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count meses',
      one: 'há $count mês',
    );
    return '$_temp0';
  }

  @override
  String relOverdueDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vencida há $count dias',
      one: 'vencida há $count dia',
    );
    return '$_temp0';
  }

  @override
  String relInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'em $count dias',
      one: 'em $count dia',
    );
    return '$_temp0';
  }

  @override
  String durationHoursMinutes(String hours, String minutes) {
    return '$hours h $minutes min';
  }

  @override
  String cantLoadPets(String error) {
    return 'Não foi possível carregar seus pets: $error';
  }

  @override
  String get addPetBeforeWalk =>
      'Adicione um pet antes de registrar um passeio.';

  @override
  String get whoWalks => 'Com quem você vai passear?';

  @override
  String get choosePet => 'Escolha um pet';

  @override
  String deletePetTitle(String name) {
    return 'Excluir $name?';
  }

  @override
  String get deletePetBody =>
      'As vacinas, medicamentos, registros de peso e passeios também serão apagados. Isso não pode ser desfeito.';

  @override
  String petDeleted(String name) {
    return '$name excluído.';
  }

  @override
  String get walkHistoryTitle => 'Histórico de passeios';

  @override
  String get everyWalkCounts => 'Cada passeio conta';

  @override
  String get reliveWalks =>
      'Reviva os trajetos e compartilhe uma lembrança juntos.';

  @override
  String get historyLoadError =>
      'Não foi possível carregar o histórico. Verifique sua conexão.';

  @override
  String get walksLoadError =>
      'Não foi possível carregar os passeios. Tente novamente ou atualize o histórico.';

  @override
  String get addPetToLogWalks =>
      'Adicione um pet para começar a registrar os passeios.';

  @override
  String get noWalksYetHome =>
      'Ainda não há passeios. Inicie um pelo botão verde do app.';

  @override
  String walkWith(String name) {
    return 'Passeio com $name';
  }

  @override
  String durationMinSec(int minutes, int seconds) {
    return '$minutes min $seconds s';
  }

  @override
  String get loadMoreWalks => 'Carregar mais passeios';

  @override
  String get deleteWalkTitle => 'Excluir este passeio?';

  @override
  String get deleteWalkBody =>
      'O trajeto, as estatísticas e a foto serão apagados. Esta ação não pode ser desfeita.';

  @override
  String get deleteWalkError =>
      'Não foi possível excluir o passeio. Tente novamente.';

  @override
  String get shareAsPng => 'Compartilhar como PNG';

  @override
  String get deleteWalk => 'Excluir passeio';

  @override
  String get noGpsPoints => 'Este passeio não tem pontos de GPS.';

  @override
  String dateAtTime(String date, String time) {
    return '$date às $time';
  }

  @override
  String maxSpeedLabel(String speed) {
    return 'Máx. $speed km/h';
  }

  @override
  String get walkPhoto => 'Foto do passeio';

  @override
  String get mapAttribution => 'Mapa © OpenStreetMap contributors';

  @override
  String get shareWalkTitle => 'Compartilhar passeio';

  @override
  String get sharePrivacyNote =>
      'Você compartilha o traçado e as estatísticas, sem o mapa de ruas. A forma do trajeto pode revelar lugares que você visitou.';

  @override
  String get shareImageError =>
      'Não foi possível preparar a imagem. Tente novamente.';

  @override
  String get shareFailed => 'Não foi possível compartilhar. Tente novamente.';

  @override
  String get sharingEllipsis => 'Compartilhando…';

  @override
  String get sharePng => 'Compartilhar PNG';

  @override
  String get traceCaption => 'Traçado do trajeto · início verde / fim vermelho';

  @override
  String get shareTagline => 'Mais um passeio, uma lembrança juntos.';

  @override
  String get walkNotSaved => 'O passeio não foi salvo';

  @override
  String get walkNotSavedBody =>
      'Você pode tentar salvar novamente. Se sair agora, perderá este trajeto.';

  @override
  String get back => 'Voltar';

  @override
  String get leaveWithoutSaving => 'Sair sem salvar';

  @override
  String get savingWalk => 'Salvando passeio…';

  @override
  String get walkSaved => 'Passeio salvo';

  @override
  String get goodWalk => 'Bom passeio!';

  @override
  String get distanceCaps => 'DISTÂNCIA';

  @override
  String get durationLabel => 'Duração';

  @override
  String get avgSpeed => 'Vel. média';

  @override
  String get yourPet => 'seu pet';

  @override
  String walkedWith(String name) {
    return 'Você passeou com $name';
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
  String get walkInProgress => 'Passeio em andamento';

  @override
  String get locationErrorDefault => 'Ocorreu um erro de localização.';

  @override
  String get mapCaptured => 'Mapa capturado';

  @override
  String get mapCaptureFailed => 'Não foi possível capturar o mapa.';

  @override
  String get mapCaptureChip => 'Captura do mapa';

  @override
  String get finishWalk => 'Finalizar passeio';

  @override
  String get gpsActive => 'GPS ativo';

  @override
  String get gpsInactive => 'GPS inativo';

  @override
  String get durationCaps => 'DURAÇÃO';

  @override
  String get weightLoadError => 'Não foi possível carregar o histórico.';

  @override
  String get weightDeleteError => 'Não foi possível excluir o registro.';

  @override
  String get deleteWeightTitle => 'Excluir registro de peso';

  @override
  String get noWeightRecords => 'Ainda não há registros de peso.';

  @override
  String get logWeight => 'Registrar peso';

  @override
  String get errWeightPositive => 'Digite um peso maior que zero.';

  @override
  String get weightSaveRetry =>
      'Não foi possível salvar o peso. Você pode tentar o mesmo registro novamente.';

  @override
  String get confirmIdentity => 'Confirmar identidade';

  @override
  String get currentPassword => 'Senha atual';

  @override
  String get confirmGoogleAccount =>
      'Confirme sua conta do Google para continuar.';

  @override
  String get verifyingEllipsis => 'Verificando…';

  @override
  String get confirm => 'Confirmar';

  @override
  String get errEnterCurrentPassword => 'Digite sua senha atual.';

  @override
  String get identityVerifyError =>
      'Não foi possível verificar sua identidade. Tente novamente.';

  @override
  String get passwordChangeError =>
      'Não foi possível alterar a senha. Tente novamente.';

  @override
  String get googlePasswordNote =>
      'Sua conta usa o Google. Gerencie a senha pela sua conta do Google.';

  @override
  String get newPassword => 'Nova senha';

  @override
  String get repeatNewPassword => 'Repetir nova senha';

  @override
  String get errMin6Chars => 'Use pelo menos 6 caracteres.';

  @override
  String get newEmail => 'Novo e-mail';

  @override
  String get sendLink => 'Enviar link';

  @override
  String get sendingEllipsis => 'Enviando…';

  @override
  String get checkingEllipsis => 'Verificando…';

  @override
  String get alreadyOpenedLink => 'Já abri o link';

  @override
  String linkSentTo(String email) {
    return 'Enviamos um link para $email. Seu e-mail atual não muda até você abri-lo.';
  }

  @override
  String notConfirmedYet(String email) {
    return 'Você ainda não confirmou o link. Abra o e-mail que enviamos para $email.';
  }

  @override
  String get errEnterNewEmail => 'Digite o novo e-mail.';

  @override
  String get errValidEmail => 'Digite um e-mail válido.';

  @override
  String get emailLinkError =>
      'Não foi possível enviar o link. Tente novamente.';

  @override
  String get emailCheckError => 'Não foi possível verificar. Tente novamente.';

  @override
  String get googleEmailNote =>
      'Sua conta usa o Google. Gerencie seu e-mail pela sua conta do Google.';

  @override
  String emailUpdated(String email) {
    return 'E-mail atualizado: $email';
  }

  @override
  String get passwordUpdated => 'Senha atualizada.';

  @override
  String get deleteAccountTitle => 'Excluir conta';

  @override
  String get deleteAccountBody =>
      'Sua conta, seus pets e os registros deles serão apagados. Esta ação não pode ser desfeita.';

  @override
  String get deleteForever => 'Excluir definitivamente';

  @override
  String get deletionInProgress => 'Exclusão em andamento';

  @override
  String get deletionInProgressBody =>
      'Sua conta já está bloqueada e estamos terminando de apagar seus dados. Será concluído automaticamente em alguns minutos.';

  @override
  String get understood => 'Entendi';

  @override
  String signOutError(String error) {
    return 'Não foi possível sair: $error';
  }

  @override
  String deleteAccountError(String error) {
    return 'Não foi possível excluir a conta: $error';
  }

  @override
  String get privacyTitle => 'Privacidade';

  @override
  String get privacySessionChanged =>
      'A sessão mudou. Entre novamente pelo seu perfil.';

  @override
  String get privacyLoadError => 'Não foi possível carregar a privacidade.';

  @override
  String get prefSavedRemindersFailed =>
      'Preferência salva. Não foi possível atualizar os avisos deste dispositivo; tente novamente antes de fechar.';

  @override
  String get prefNotSaved => 'A preferência não foi salva. Tente novamente.';

  @override
  String get downloadMyData => 'Baixar meus dados';

  @override
  String get downloadMyDataBody =>
      'O arquivo inclui suas fotos e trajetos de GPS. Escolha um destino privado ao salvar ou compartilhar.';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get exportIncomplete =>
      'O arquivo não foi concluído. Você pode iniciar outra exportação.';

  @override
  String get exportShareFailed =>
      'Não foi possível salvar ou compartilhar. O arquivo continua pronto para tentar novamente.';

  @override
  String get requestNotRegistered =>
      'Não foi possível registrar a solicitação. Mantivemos o texto para você tentar novamente.';

  @override
  String get yourNotices => 'Seus avisos';

  @override
  String get careReminders => 'Lembretes de cuidados';

  @override
  String get careRemindersHint => 'Vacinas, medicamentos e tarefas';

  @override
  String get teamNotices => 'Avisos da equipe';

  @override
  String get yourData => 'Seus dados';

  @override
  String get yourDataBody =>
      'Baixe seu perfil, pets, cuidados, fotos e trajetos em um arquivo JSON.';

  @override
  String get prepareFile => 'Preparar arquivo';

  @override
  String recordsPrepared(int count) {
    return '$count registros preparados';
  }

  @override
  String get cancelExport => 'Cancelar exportação';

  @override
  String get saveOrShareJson => 'Salvar ou compartilhar JSON';

  @override
  String get requestsTitle => 'Solicitações';

  @override
  String get requestType => 'Tipo de solicitação';

  @override
  String get reqConsulta => 'Consulta';

  @override
  String get reqAcceso => 'Acesso à informação';

  @override
  String get reqCorreccion => 'Correção';

  @override
  String get reqOposicion => 'Oposição';

  @override
  String get reqBloqueo => 'Bloqueio';

  @override
  String get reqAnonimizacion => 'Anonimização';

  @override
  String get detailLabel => 'Detalhes';

  @override
  String get registerRequest => 'Registrar solicitação';

  @override
  String get requestsByEmail =>
      'Por enquanto você pode enviar suas solicitações ao e-mail de suporte.';

  @override
  String get requestChannelMissing =>
      'O canal de consultas ainda não foi configurado.';

  @override
  String get refreshRequests => 'Atualizar solicitações';

  @override
  String get authUserDisabled => 'Esta conta está desativada.';

  @override
  String get authBadCredentials => 'E-mail ou senha incorretos.';

  @override
  String get authEmailInUse => 'Já existe uma conta com esse e-mail.';

  @override
  String get authWeakPassword =>
      'A senha é muito fraca (mínimo de 6 caracteres).';

  @override
  String get authAccountExists =>
      'Já existe uma conta com esse e-mail criada com outro método de acesso.';

  @override
  String get authRecentLogin =>
      'Por segurança, entre novamente para fazer esta alteração.';

  @override
  String get authUserMismatch =>
      'A conta escolhida não corresponde à sessão atual.';

  @override
  String get authTooMany =>
      'Muitas tentativas falhas. Aguarde alguns minutos e tente novamente.';

  @override
  String get authNoInternet => 'Sem conexão com a internet.';

  @override
  String get authNotEnabled => 'Este método de acesso não está ativado.';

  @override
  String get authNoSession => 'Não há sessão iniciada.';

  @override
  String get authSessionChanged =>
      'A sessão mudou. Tente novamente pela sua conta.';

  @override
  String get authCancelled => 'Operação cancelada.';

  @override
  String get authGoogleAccount => 'Sua conta entra com o Google.';

  @override
  String get authPasswordFields =>
      'Preencha a senha atual e uma nova com pelo menos 6 caracteres.';

  @override
  String get authSameEmail => 'Esse já é o e-mail da sua conta.';

  @override
  String get authSignupFailed => 'Não foi possível criar a conta.';

  @override
  String get authSigninFailed => 'Não foi possível entrar.';

  @override
  String get authGoogleSigninFailed => 'Não foi possível entrar com o Google.';

  @override
  String get authGoogleUnavailable =>
      'O acesso com o Google não está disponível nesta plataforma.';

  @override
  String get authPushDisconnect =>
      'Não foi possível desconectar as notificações. Tente sair novamente.';

  @override
  String get authGeneric =>
      'Não foi possível concluir a operação. Tente novamente.';

  @override
  String get googleInterrupted =>
      'O acesso com o Google foi interrompido. Tente novamente.';

  @override
  String get googleUiUnavailable =>
      'Não foi possível abrir a janela do Google.';

  @override
  String get googleConfigError =>
      'O app não está configurado corretamente para o Google. Tente mais tarde.';

  @override
  String get googleUserMismatch =>
      'A conta do Google não corresponde à esperada.';

  @override
  String get apiSessionChanged => 'A sessão mudou.';

  @override
  String get apiInvalidResponse =>
      'O servidor retornou uma resposta inválida. Tente novamente.';

  @override
  String get apiListTooLarge =>
      'A lista é grande demais para esta tela. Resultados incompletos não foram exibidos.';

  @override
  String get apiTimeout => 'O servidor demorou demais para responder.';

  @override
  String get apiOffline =>
      'Sem conexão com o servidor. Verifique sua internet.';

  @override
  String apiHttpStatus(String status) {
    return 'O servidor respondeu com um erro ($status).';
  }

  @override
  String noticeVaccineTitle(String pet) {
    return 'Vacina de $pet';
  }

  @override
  String noticeVaccineBody(String vaccine, String date) {
    return '$vaccine está chegando: $date.';
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
  String get photoOpenFailed =>
      'Não foi possível abrir a imagem. Tente novamente.';

  @override
  String get photoTooLarge => 'A imagem é grande demais. Tente outra.';

  @override
  String get photoTooLargeAfter =>
      'A foto é grande demais mesmo depois de reduzida. Tente outra.';

  @override
  String get photoInvalidType => 'Escolha uma imagem JPEG ou PNG.';

  @override
  String get photoInvalidOrLarge => 'A imagem não é válida ou é grande demais.';

  @override
  String get photoUnreadable => 'Não foi possível ler a imagem. Tente outra.';

  @override
  String get exportCancelled => 'Exportação cancelada.';

  @override
  String get exportSessionChanged =>
      'A sessão mudou. O arquivo não foi preparado.';

  @override
  String get exportTooBig =>
      'O arquivo precisa de assistência por causa do tamanho.';

  @override
  String get exportStartFailed =>
      'Não foi possível iniciar uma exportação válida.';

  @override
  String get exportInvalidResponse =>
      'A exportação retornou uma resposta inválida. Inicie outra.';

  @override
  String get exportIncompleteService =>
      'A exportação não foi concluída. Inicie outra.';

  @override
  String get captureNotReady => 'O mapa ainda não está pronto.';

  @override
  String get captureUnreadable => 'Não foi possível ler a imagem do mapa.';

  @override
  String get captureTooLarge =>
      'A captura do mapa ficou grande demais. Tente com menos zoom.';

  @override
  String get locGpsOff => 'O GPS está desativado. Ative-o para continuar.';

  @override
  String get locDenied => 'Permissão de localização negada.';

  @override
  String get locDeniedForever =>
      'Permissão negada permanentemente. Ative-a nas configurações do sistema.';

  @override
  String locFailed(String error) {
    return 'Não foi possível obter a localização: $error';
  }

  @override
  String get inactivityTitle => 'Aviso por falta de passeios';

  @override
  String get inactivityHint =>
      'Avisamos se o prazo escolhido passar sem um passeio registrado.';

  @override
  String get inactivityAfter => 'Avisar após';

  @override
  String inactivityDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias',
      one: '$count dia',
    );
    return '$_temp0';
  }

  @override
  String get inactivityIncludeNew => 'Incluir pets sem passeios registrados';

  @override
  String get kindInactivity => 'Sem passeios';

  @override
  String get premiumTitle => 'Premium';

  @override
  String premiumActiveUntil(String date) {
    return 'Premium ativo até $date';
  }

  @override
  String get premiumInactive => 'Sem Premium ativo';

  @override
  String get premiumSourceManual => 'Concedido pela equipe PawLife';

  @override
  String get premiumSourcePaid => 'Assinatura';

  @override
  String get premiumNoPurchases =>
      'Por enquanto o Premium é concedido pela equipe PawLife. Ainda não há compras dentro do app.';

  @override
  String get premiumLoadError =>
      'Não foi possível consultar seu status Premium.';

  @override
  String get apiAccountDeleting => 'Sua conta está sendo excluída.';

  @override
  String get apiAccountUnavailable => 'A conta não está disponível.';

  @override
  String get apiRateLimited =>
      'Muitas alterações seguidas. Aguarde um pouco e tente novamente.';

  @override
  String get apiPhotoProcessor =>
      'Não foi possível processar a foto agora. Tente mais tarde.';

  @override
  String get apiInvalidPhoto => 'A foto não é válida.';

  @override
  String get apiTooLarge => 'Os dados são grandes demais para salvar.';

  @override
  String get apiExportExpired => 'A exportação expirou. Inicie outra.';

  @override
  String get apiBillingReview =>
      'Sua conta tem uma assinatura ou compra que precisa ser revisada antes de ser excluída.';

  @override
  String get apiPrivacyUnavailable =>
      'O canal de privacidade ainda não está disponível.';

  @override
  String get apiServiceBusy =>
      'O serviço não está disponível no momento. Tente novamente em alguns minutos.';

  @override
  String get apiDeviceConflict =>
      'Este dispositivo já está associado a outra conta.';

  @override
  String get cellNextVaccine => 'PRÓXIMA VACINA';
}
