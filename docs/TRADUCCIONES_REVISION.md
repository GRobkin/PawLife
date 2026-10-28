# Traducciones para revisión lingüística

Fecha: 28/10/2026. Fuente: `lib/l10n/app_{es,en,pt}.arb` (rama `feature/us28-us29-idiomas-tema`). El español es el original; el inglés y el portugués los redacté yo y **nadie los revisó**.

Total: 430 cadenas. Los marcadores `{nombre}` se reemplazan en tiempo de ejecución y no se deben traducir ni quitar; `⏎` es un salto de línea. Los plurales usan sintaxis ICU (`{count, plural, one{...} other{...}}`): hay que revisar ambas formas.

## Qué revisar

- **Registro:** el español usa voseo rioplatense ("Iniciá", "Escribí"). ¿El inglés y el portugués deben ser neutros/informales? Propongo tuteo informal en pt ("você") e inglés neutro.
- **Portugués:** variante brasileña ("Entrar", "E-mail", "Sair"). Confirmar si se prefiere europea.
- **Términos de la marca:** "Mascota" → *Pet* en en/pt; "Paseo" → *Walk* / *Passeio*; "Recordatorios" → *Reminders* / *Lembretes*.
- **Textos legales y de privacidad** (Privacidad, exportación, eliminación de cuenta): conviene que los valide quien responda legalmente por el servicio.
- **No se traducen** los textos que escriben las personas (nombres, notas, mensajes del administrador) ni los mensajes que devuelve el servidor.

| # | Clave | Español | English | Português | Nota |
|---|---|---|---|---|---|
| 1 | `language` | Idioma | Language | Idioma | |
| 2 | `languageSystem` | Sistema | System | Sistema | |
| 3 | `languageEs` | Español | Español | Español | |
| 4 | `languageEn` | English | English | English | |
| 5 | `languagePt` | Português | Português | Português | |
| 6 | `appearance` | Apariencia | Appearance | Aparência | |
| 7 | `appearanceSystem` | Sistema | System | Sistema | |
| 8 | `appearanceLight` | Claro | Light | Claro | |
| 9 | `appearanceDark` | Oscuro | Dark | Escuro | |
| 10 | `profileTitle` | Perfil | Profile | Perfil | |
| 11 | `profileName` | Nombre | Name | Nome | |
| 12 | `profileEmail` | Correo electrónico | Email | E-mail | |
| 13 | `profileSave` | Guardar cambios | Save changes | Salvar alterações | |
| 14 | `profileSaved` | Perfil guardado. | Profile saved. | Perfil salvo. | |
| 15 | `profileLoadError` | No se pudo cargar el perfil: {error} | Couldn't load the profile: {error} | Não foi possível carregar o perfil: {error} | |
| 16 | `profileSaveError` | No se pudo guardar: {error} | Couldn't save: {error} | Não foi possível salvar: {error} | |
| 17 | `retry` | Reintentar | Retry | Tentar novamente | |
| 18 | `privacyAndData` | Privacidad y mis datos | Privacy and my data | Privacidade e meus dados | |
| 19 | `changeEmail` | Cambiar correo | Change email | Alterar e-mail | |
| 20 | `changePassword` | Cambiar contraseña | Change password | Alterar senha | |
| 21 | `signOut` | Cerrar sesión | Sign out | Sair | |
| 22 | `deleteAccountButton` | Eliminar mi cuenta | Delete my account | Excluir minha conta | |
| 23 | `welcomeTagline` | La salud y felicidad de tu compañero,⏎todo en un solo lugar. | Your companion's health and happiness,⏎all in one place. | A saúde e a felicidade do seu companheiro,⏎tudo em um só lugar. | |
| 24 | `getStarted` | Comenzar | Get started | Começar | |
| 25 | `signIn` | Iniciar sesión | Sign in | Entrar | |
| 26 | `termsPrefix` | Al continuar, aceptás nuestros  | By continuing, you accept our  | Ao continuar, você aceita nossos  | |
| 27 | `termsOfService` | Términos del servicio | Terms of Service | Termos de Serviço | |
| 28 | `termsAnd` |  y la  |  and the  |  e a  | |
| 29 | `privacyPolicy` | Política de privacidad | Privacy Policy | Política de Privacidade | |
| 30 | `welcomeBack` | Bienvenido de nuevo | Welcome back | Bem-vindo de volta | |
| 31 | `loginSubtitle` | Iniciá sesión para gestionar los cuidados de tu mascota. | Sign in to manage your pet's care. | Entre para gerenciar os cuidados do seu pet. | |
| 32 | `emailLabel` | Correo electrónico | Email | E-mail | |
| 33 | `passwordLabel` | Contraseña | Password | Senha | |
| 34 | `forgotPassword` | ¿Olvidaste tu contraseña? | Forgot your password? | Esqueceu sua senha? | |
| 35 | `orSeparator` | o | or | ou | |
| 36 | `continueWithGoogle` | Continuar con Google | Continue with Google | Continuar com o Google | |
| 37 | `noAccountPrefix` | ¿No tenés una cuenta?  | Don't have an account?  | Não tem uma conta?  | |
| 38 | `signUp` | Registrate | Sign up | Cadastre-se | |
| 39 | `hasAccountPrefix` | ¿Ya tenés una cuenta?  | Already have an account?  | Já tem uma conta?  | |
| 40 | `createAccountTitle` | Creá tu cuenta | Create your account | Crie sua conta | |
| 41 | `createAccountSubtitle` | Completá tus datos para empezar. | Fill in your details to get started. | Preencha seus dados para começar. | |
| 42 | `fullName` | Nombre completo | Full name | Nome completo | |
| 43 | `fullNameHint` | Ej. Juana Pérez | e.g. Jane Smith | Ex.: Maria Silva | |
| 44 | `confirmPassword` | Confirmar contraseña | Confirm password | Confirmar senha | |
| 45 | `createAccount` | Crear cuenta | Create account | Criar conta | |
| 46 | `errEnterEmail` | Escribí tu correo electrónico. | Enter your email. | Digite seu e-mail. | |
| 47 | `errInvalidEmail` | El correo no tiene un formato válido. | The email format isn't valid. | O e-mail não tem um formato válido. | |
| 48 | `errEnterPassword` | Escribí tu contraseña. | Enter your password. | Digite sua senha. | |
| 49 | `errEmailAbove` | Escribí tu correo arriba y volvé a pulsar aquí. | Enter your email above and tap here again. | Digite seu e-mail acima e toque aqui novamente. | |
| 50 | `errEnterName` | Escribí tu nombre. | Enter your name. | Digite seu nome. | |
| 51 | `errPasswordShort` | La contraseña debe tener al menos 6 caracteres. | The password must be at least 6 characters. | A senha deve ter pelo menos 6 caracteres. | |
| 52 | `errPasswordMismatch` | Las contraseñas no coinciden. | The passwords don't match. | As senhas não coincidem. | |
| 53 | `resetEmailSent` | Te enviamos un correo a {email}. | We sent an email to {email}. | Enviamos um e-mail para {email}. | |
| 54 | `showPassword` | Mostrar contraseña | Show password | Mostrar senha | |
| 55 | `hidePassword` | Ocultar contraseña | Hide password | Ocultar senha | |
| 56 | `navHome` | Inicio | Home | Início | |
| 57 | `navPets` | Mascotas | Pets | Pets | |
| 58 | `navTasks` | Tareas | Tasks | Tarefas | |
| 59 | `navProfile` | Perfil | Profile | Perfil | |
| 60 | `tasksTitle` | Tareas | Tasks | Tarefas | |
| 61 | `tasksLoadError` | No se pudieron cargar las tareas: {error} | Couldn't load tasks: {error} | Não foi possível carregar as tarefas: {error} | |
| 62 | `genericSaveError` | No se pudo guardar: {error} | Couldn't save: {error} | Não foi possível salvar: {error} | |
| 63 | `addPetFirst` | Agregá una mascota antes de crear una tarea. | Add a pet before creating a task. | Adicione um pet antes de criar uma tarefa. | |
| 64 | `newTask` | Nueva tarea | New task | Nova tarefa | |
| 65 | `petLabel` | Mascota | Pet | Pet | |
| 66 | `taskPrompt` | ¿Qué hay que hacer? | What needs to be done? | O que precisa ser feito? | |
| 67 | `cancel` | Cancelar | Cancel | Cancelar | |
| 68 | `save` | Guardar | Save | Salvar | |
| 69 | `noTasks` | Todavía no hay tareas. | No tasks yet. | Ainda não há tarefas. | |
| 70 | `deleteTask` | Eliminar tarea | Delete task | Excluir tarefa | |
| 71 | `speciesDog` | Perro | Dog | Cão | |
| 72 | `speciesCat` | Gato | Cat | Gato | |
| 73 | `speciesOther` | Otra | Other | Outra | |
| 74 | `ageDays` | {count, plural, one{{count} día} other{{count} días}} | {count, plural, one{{count} day} other{{count} days}} | {count, plural, one{{count} dia} other{{count} dias}} | |
| 75 | `ageWeeks` | {count, plural, one{{count} semana} other{{count} semanas}} | {count, plural, one{{count} week} other{{count} weeks}} | {count, plural, one{{count} semana} other{{count} semanas}} | |
| 76 | `ageMonths` | {count, plural, one{{count} mes} other{{count} meses}} | {count, plural, one{{count} month} other{{count} months}} | {count, plural, one{{count} mês} other{{count} meses}} | |
| 77 | `ageYears` | {count, plural, one{{count} año} other{{count} años}} | {count, plural, one{{count} year} other{{count} years}} | {count, plural, one{{count} ano} other{{count} anos}} | |
| 78 | `petsLoadError` | No se pudieron cargar tus mascotas | Couldn't load your pets | Não foi possível carregar seus pets | |
| 79 | `petsEmptyTitle` | Todavía no tenés mascotas | You don't have any pets yet | Você ainda não tem pets | |
| 80 | `petsEmptyBody` | Agregá la primera para empezar a llevar sus cuidados. | Add the first one to start tracking their care. | Adicione o primeiro para começar a acompanhar os cuidados. | |
| 81 | `addPet` | Agregar mascota | Add pet | Adicionar pet | |
| 82 | `myPets` | Mis mascotas | My pets | Meus pets | |
| 83 | `myPetsSubtitle` | Gestioná a los miembros peludos de tu familia. | Manage your family's furry members. | Gerencie os peludos da sua família. | |
| 84 | `statusNoVaccines` | Sin vacunas | No vaccines | Sem vacinas | |
| 85 | `statusOverdue` | Vacuna vencida | Vaccine overdue | Vacina vencida | |
| 86 | `statusDueSoon` | Vacuna próxima | Vaccine due soon | Vacina próxima | |
| 87 | `statusHealthy` | Sano | Healthy | Saudável | |
| 88 | `options` | Opciones | Options | Opções | |
| 89 | `edit` | Editar | Edit | Editar | |
| 90 | `delete` | Eliminar | Delete | Excluir | |
| 91 | `cellStatus` | ESTADO | STATUS | ESTADO | |
| 92 | `cellWeight` | PESO | WEIGHT | PESO | |
| 93 | `noRecord` | Sin registro | No record | Sem registro | |
| 94 | `goodMorning` | ¡Buenos días! | Good morning! | Bom dia! | |
| 95 | `goodAfternoon` | ¡Buenas tardes! | Good afternoon! | Boa tarde! | |
| 96 | `goodEvening` | ¡Buenas noches! | Good evening! | Boa noite! | |
| 97 | `goodMorningName` | ¡Buenos días, {name}! | Good morning, {name}! | Bom dia, {name}! | |
| 98 | `goodAfternoonName` | ¡Buenas tardes, {name}! | Good afternoon, {name}! | Boa tarde, {name}! | |
| 99 | `goodEveningName` | ¡Buenas noches, {name}! | Good evening, {name}! | Boa noite, {name}! | |
| 100 | `todayAgenda` | Esta es tu agenda de hoy. | This is your agenda for today. | Esta é a sua agenda de hoje. | |
| 101 | `activitySummary` | Resumen de actividad | Activity summary | Resumo de atividade | |
| 102 | `viewWalkHistory` | Ver historial de paseos | View walk history | Ver histórico de passeios | |
| 103 | `todayTitle` | Hoy | Today | Hoje | |
| 104 | `noTasksToday` | No tenés tareas para hoy. | You have no tasks for today. | Você não tem tarefas para hoje. | |
| 105 | `completedLabel` | Completada | Completed | Concluída | |
| 106 | `updateTaskError` | No se pudo actualizar la tarea: {error} | Couldn't update the task: {error} | Não foi possível atualizar a tarefa: {error} | |
| 107 | `onlyOnePet` | Solo tenés una mascota por ahora. | You only have one pet for now. | Você só tem um pet por enquanto. | |
| 108 | `changePet` | Cambiar de mascota | Switch pet | Trocar de pet | |
| 109 | `yourAccount` | Tu cuenta | Your account | Sua conta | |
| 110 | `signedIn` | Sesión iniciada | Signed in | Sessão iniciada | |
| 111 | `loadingEllipsis` | Cargando… | Loading… | Carregando… | |
| 112 | `noPets` | Sin mascotas | No pets | Sem pets | |
| 113 | `tapToAddFirst` | Tocá para agregar la primera | Tap to add your first one | Toque para adicionar o primeiro | |
| 114 | `startWalk` | Iniciar paseo | Start walk | Iniciar passeio | |
| 115 | `readyForAdventure` | ¿Listos para una aventura? | Ready for an adventure? | Prontos para uma aventura? | |
| 116 | `lastWalk` | Último paseo | Last walk | Último passeio | |
| 117 | `activeTime` | Tiempo activo | Active time | Tempo ativo | |
| 118 | `loadingShort` | Cargando | Loading | Carregando | |
| 119 | `noWalks` | Sin paseos | No walks | Sem passeios | |
| 120 | `noWalksToday` | Sin paseos hoy | No walks today | Sem passeios hoje | |
| 121 | `walksToday` | {count, plural, one{{count} paseo hoy} other{{count} paseos hoy}} | {count, plural, one{{count} walk today} other{{count} walks today}} | {count, plural, one{{count} passeio hoje} other{{count} passeios hoje}} | |
| 122 | `minutesShort` | {count} min | {count} min | {count} min | |
| 123 | `todayAt` | Hoy, {time} | Today, {time} | Hoje, {time} | |
| 124 | `yesterdayAt` | Ayer, {time} | Yesterday, {time} | Ontem, {time} | |
| 125 | `markPending` | Marcar pendiente | Mark as pending | Marcar como pendente | |
| 126 | `markDone` | Marcar completada | Mark as done | Marcar como concluída | |
| 127 | `logout` | Cerrar sesión | Sign out | Sair | |
| 128 | `pickFromGallery` | Elegir de la galería | Choose from gallery | Escolher da galeria | |
| 129 | `takePhoto` | Tomar una foto | Take a photo | Tirar uma foto | |
| 130 | `removePhoto` | Quitar foto | Remove photo | Remover foto | |
| 131 | `uploadPhoto` | Subir foto | Upload photo | Enviar foto | |
| 132 | `changePhoto` | Cambiar foto | Change photo | Trocar foto | |
| 133 | `birthDate` | Fecha de nacimiento | Date of birth | Data de nascimento | |
| 134 | `errEnterPetName` | Escribí el nombre. | Enter the name. | Digite o nome. | |
| 135 | `errWeightInvalid` | El peso no es un número válido. | The weight isn't a valid number. | O peso não é um número válido. | |
| 136 | `errWeightRange` | El peso tiene que estar entre 0 y 200 kg. | The weight must be between 0 and 200 kg. | O peso deve estar entre 0 e 200 kg. | |
| 137 | `editPet` | Editar mascota | Edit pet | Editar pet | |
| 138 | `editPetSubtitle` | Actualizá los datos de {name}. | Update {name}'s details. | Atualize os dados de {name}. | |
| 139 | `addPetSubtitle` | Contanos sobre tu compañero para personalizar sus cuidados. | Tell us about your companion to personalize their care. | Conte-nos sobre seu companheiro para personalizar os cuidados. | |
| 140 | `savePet` | Guardar mascota | Save pet | Salvar pet | |
| 141 | `nameLabel` | Nombre | Name | Nome | |
| 142 | `nameHint` | Ej. Bella | e.g. Bella | Ex.: Bella | |
| 143 | `speciesLabel` | Especie | Species | Espécie | |
| 144 | `breedLabel` | Raza | Breed | Raça | |
| 145 | `breedHint` | Ej. Golden Retriever | e.g. Golden Retriever | Ex.: Golden Retriever | |
| 146 | `weightKgLabel` | Peso (kg) | Weight (kg) | Peso (kg) | |
| 147 | `notesLabel` | Notas | Notes | Notas | |
| 148 | `optional` | Opcional | Optional | Opcional | |
| 149 | `notesHint` | Alergias, número de microchip, manías... | Allergies, microchip number, quirks... | Alergias, número do microchip, manias... | |
| 150 | `datePlaceholder` | dd/mm/aaaa | mm/dd/yyyy | dd/mm/aaaa | |
| 151 | `addVaccine` | Añadir vacuna | Add vaccine | Adicionar vacina | |
| 152 | `editVaccine` | Editar vacuna | Edit vaccine | Editar vacina | |
| 153 | `vaccineName` | Nombre de la vacuna | Vaccine name | Nome da vacina | |
| 154 | `applicationDate` | Fecha de aplicación | Date given | Data de aplicação | |
| 155 | `nextDose` | Próxima dosis | Next dose | Próxima dose | |
| 156 | `remindInAdvance` | Avisar con anticipación | Remind in advance | Avisar com antecedência | |
| 157 | `daysUnit` | días | days | dias | |
| 158 | `errRange0to365` | Ingresá un valor entre 0 y 365. | Enter a value between 0 and 365. | Digite um valor entre 0 e 365. | |
| 159 | `logFeeding` | Registrar alimentación | Log feeding | Registrar alimentação | |
| 160 | `foodType` | Tipo de alimento | Food type | Tipo de alimento | |
| 161 | `foodTypeHint` | Ej. alimento seco | e.g. dry food | Ex.: ração seca | |
| 162 | `amountLabel` | Cantidad | Amount | Quantidade | |
| 163 | `errValidAmount` | Ingresá una cantidad válida. | Enter a valid amount. | Digite uma quantidade válida. | |
| 164 | `dateAndTime` | Fecha y hora | Date and time | Data e hora | |
| 165 | `notesOptional` | Notas (opcional) | Notes (optional) | Notas (opcional) | |
| 166 | `addMedication` | Añadir medicamento | Add medication | Adicionar medicamento | |
| 167 | `editMedication` | Editar medicamento | Edit medication | Editar medicamento | |
| 168 | `medicationLabel` | Medicamento | Medication | Medicamento | |
| 169 | `doseLabel` | Dosis | Dose | Dose | |
| 170 | `doseHint` | Ej. 1 comprimido | e.g. 1 tablet | Ex.: 1 comprimido | |
| 171 | `schedulesLabel` | Horarios | Times | Horários | |
| 172 | `errTimesFormat` | Usá horarios HH:mm separados por coma. | Use HH:mm times separated by commas. | Use horários HH:mm separados por vírgula. | |
| 173 | `startDate` | Fecha de inicio | Start date | Data de início | |
| 174 | `endDateOptional` | Fecha de fin (opcional) | End date (optional) | Data de término (opcional) | |
| 175 | `activeTreatment` | Tratamiento activo | Active treatment | Tratamento ativo | |
| 176 | `requiredField` | Este campo es obligatorio. | This field is required. | Este campo é obrigatório. | |
| 177 | `saving` | Guardando… | Saving… | Salvando… | |
| 178 | `noDate` | Sin fecha | No date | Sem data | |
| 179 | `tabSummary` | Resumen | Summary | Resumo | |
| 180 | `tabVaccines` | Vacunas | Vaccines | Vacinas | |
| 181 | `tabMedications` | Medicamentos | Medications | Medicamentos | |
| 182 | `tabFeeding` | Alimentación | Feeding | Alimentação | |
| 183 | `tabWalks` | Paseos | Walks | Passeios | |
| 184 | `deleteItemTitle` | Eliminar {name} | Delete {name} | Excluir {name} | |
| 185 | `cannotBeUndone` | Esta acción no se puede deshacer. | This action can't be undone. | Esta ação não pode ser desfeita. | |
| 186 | `deleteError` | No se pudo eliminar: {error} | Couldn't delete: {error} | Não foi possível excluir: {error} | |
| 187 | `metricLastWalk` | ÚLTIMO PASEO | LAST WALK | ÚLTIMO PASSEIO | |
| 188 | `metricNextVet` | PRÓXIMA VISITA AL VET | NEXT VET VISIT | PRÓXIMA VISITA AO VET | |
| 189 | `notScheduled` | Sin agendar | Not scheduled | Não agendada | |
| 190 | `measuredWhen` | Medido {when} | Measured {when} | Medido {when} | |
| 191 | `weightHistory` | Historial de peso | Weight history | Histórico de peso | |
| 192 | `upcomingCare` | Próximos cuidados | Upcoming care | Próximos cuidados | |
| 193 | `nothingPending` | No hay nada pendiente. | Nothing pending. | Nada pendente. | |
| 194 | `kindWhen` | {kind} · {when} | {kind} · {when} | {kind} · {when} | |
| 195 | `kindVaccine` | Vacuna | Vaccine | Vacina | |
| 196 | `kindTask` | Tarea | Task | Tarefa | |
| 197 | `recentActivity` | Actividad reciente | Recent activity | Atividade recente | |
| 198 | `noWalksRecorded` | Todavía no hay paseos registrados. | No walks recorded yet. | Ainda não há passeios registrados. | |
| 199 | `kmIn` | {km} km en {duration} | {km} km in {duration} | {km} km em {duration} | |
| 200 | `appliedOnNext` | Aplicada el {date} · próxima {when} | Given {date} · next {when} | Aplicada em {date} · próxima {when} | |
| 201 | `noVaccinesRecorded` | Sin vacunas registradas. | No vaccines recorded. | Sem vacinas registradas. | |
| 202 | `noMedicationsRecorded` | Sin medicamentos registrados. | No medications recorded. | Sem medicamentos registrados. | |
| 203 | `noFeedingsRecorded` | Sin alimentaciones registradas. | No feedings recorded. | Sem alimentações registradas. | |
| 204 | `activeWithTimes` | Activo · {times} | Active · {times} | Ativo · {times} | |
| 205 | `finished` | Finalizado | Finished | Finalizado | |
| 206 | `noWalksYetHint` | Todavía no hay paseos.⏎Usá el botón verde de abajo para registrar uno. | No walks yet.⏎Use the green button below to record one. | Ainda não há passeios.⏎Use o botão verde abaixo para registrar um. | |
| 207 | `openWalkHistory` | Abrir historial de paseos | Open walk history | Abrir histórico de passeios | |
| 208 | `maxSpeedKmh` | máx {speed} km/h | max {speed} km/h | máx {speed} km/h | |
| 209 | `registerWeightCaps` | REGISTRAR PESO | LOG WEIGHT | REGISTRAR PESO | |
| 210 | `relToday` | hoy | today | hoje | |
| 211 | `relYesterday` | ayer | yesterday | ontem | |
| 212 | `relTomorrow` | mañana | tomorrow | amanhã | |
| 213 | `relDaysAgo` | {count, plural, one{hace {count} día} other{hace {count} días}} | {count, plural, one{{count} day ago} other{{count} days ago}} | {count, plural, one{há {count} dia} other{há {count} dias}} | |
| 214 | `relMonthsAgo` | {count, plural, one{hace {count} mes} other{hace {count} meses}} | {count, plural, one{{count} month ago} other{{count} months ago}} | {count, plural, one{há {count} mês} other{há {count} meses}} | |
| 215 | `relOverdueDays` | {count, plural, one{vencida hace {count} día} other{vencida hace {count} días}} | {count, plural, one{overdue by {count} day} other{overdue by {count} days}} | {count, plural, one{vencida há {count} dia} other{vencida há {count} dias}} | |
| 216 | `relInDays` | {count, plural, one{en {count} día} other{en {count} días}} | {count, plural, one{in {count} day} other{in {count} days}} | {count, plural, one{em {count} dia} other{em {count} dias}} | |
| 217 | `durationHoursMinutes` | {hours} h {minutes} min | {hours} h {minutes} min | {hours} h {minutes} min | |
| 218 | `cantLoadPets` | No se pudieron cargar tus mascotas: {error} | Couldn't load your pets: {error} | Não foi possível carregar seus pets: {error} | |
| 219 | `addPetBeforeWalk` | Agregá una mascota antes de registrar un paseo. | Add a pet before recording a walk. | Adicione um pet antes de registrar um passeio. | |
| 220 | `whoWalks` | ¿Con quién vas a pasear? | Who are you walking with? | Com quem você vai passear? | |
| 221 | `choosePet` | Elegí una mascota | Choose a pet | Escolha um pet | |
| 222 | `deletePetTitle` | ¿Eliminar a {name}? | Delete {name}? | Excluir {name}? | |
| 223 | `deletePetBody` | Se borrarán también sus vacunas, medicamentos, registros de peso y paseos. No se puede deshacer. | Their vaccines, medications, weight records and walks will also be deleted. This can't be undone. | As vacinas, medicamentos, registros de peso e passeios também serão apagados. Isso não pode ser desfeito. | |
| 224 | `petDeleted` | {name} eliminada. | {name} deleted. | {name} excluído. | |
| 225 | `walkHistoryTitle` | Historial de paseos | Walk history | Histórico de passeios | |
| 226 | `everyWalkCounts` | Cada paseo cuenta | Every walk counts | Cada passeio conta | |
| 227 | `reliveWalks` | Reviví sus recorridos y compartí un recuerdo juntos. | Relive their routes and share a memory together. | Reviva os trajetos e compartilhe uma lembrança juntos. | |
| 228 | `historyLoadError` | No se pudo cargar el historial. Comprobá tu conexión. | Couldn't load the history. Check your connection. | Não foi possível carregar o histórico. Verifique sua conexão. | |
| 229 | `walksLoadError` | No se pudieron cargar los paseos. Reintentá o actualizá el historial. | Couldn't load the walks. Retry or refresh the history. | Não foi possível carregar os passeios. Tente novamente ou atualize o histórico. | |
| 230 | `addPetToLogWalks` | Agregá una mascota para empezar a registrar sus paseos. | Add a pet to start recording their walks. | Adicione um pet para começar a registrar os passeios. | |
| 231 | `noWalksYetHome` | Todavía no hay paseos. Iniciá uno desde el botón verde de la app. | No walks yet. Start one from the app's green button. | Ainda não há passeios. Inicie um pelo botão verde do app. | |
| 232 | `walkWith` | Paseo con {name} | Walk with {name} | Passeio com {name} | |
| 233 | `durationMinSec` | {minutes} min {seconds} s | {minutes} min {seconds} s | {minutes} min {seconds} s | |
| 234 | `loadMoreWalks` | Cargar más paseos | Load more walks | Carregar mais passeios | |
| 235 | `deleteWalkTitle` | ¿Eliminar este paseo? | Delete this walk? | Excluir este passeio? | |
| 236 | `deleteWalkBody` | Se borrarán el recorrido, sus estadísticas y la foto. Esta acción no se puede deshacer. | The route, its statistics and the photo will be deleted. This action can't be undone. | O trajeto, as estatísticas e a foto serão apagados. Esta ação não pode ser desfeita. | |
| 237 | `deleteWalkError` | No se pudo eliminar el paseo. Reintentá. | Couldn't delete the walk. Try again. | Não foi possível excluir o passeio. Tente novamente. | |
| 238 | `shareAsPng` | Compartir como PNG | Share as PNG | Compartilhar como PNG | |
| 239 | `deleteWalk` | Eliminar paseo | Delete walk | Excluir passeio | |
| 240 | `noGpsPoints` | Este paseo no tiene puntos de GPS. | This walk has no GPS points. | Este passeio não tem pontos de GPS. | |
| 241 | `dateAtTime` | {date} a las {time} | {date} at {time} | {date} às {time} | |
| 242 | `maxSpeedLabel` | Máx. {speed} km/h | Max {speed} km/h | Máx. {speed} km/h | |
| 243 | `walkPhoto` | Foto del paseo | Walk photo | Foto do passeio | |
| 244 | `mapAttribution` | Mapa © OpenStreetMap contributors | Map © OpenStreetMap contributors | Mapa © OpenStreetMap contributors | |
| 245 | `shareWalkTitle` | Compartir paseo | Share walk | Compartilhar passeio | |
| 246 | `sharePrivacyNote` | Compartís la traza y las estadísticas, sin el mapa de calles. La forma del recorrido puede revelar lugares que visitaste. | You're sharing the route line and statistics, without the street map. The shape of the route can reveal places you visited. | Você compartilha o traçado e as estatísticas, sem o mapa de ruas. A forma do trajeto pode revelar lugares que você visitou. | |
| 247 | `shareImageError` | No se pudo preparar la imagen. Intentá otra vez. | Couldn't prepare the image. Try again. | Não foi possível preparar a imagem. Tente novamente. | |
| 248 | `shareFailed` | No se pudo compartir. Volvé a intentarlo. | Couldn't share. Please try again. | Não foi possível compartilhar. Tente novamente. | |
| 249 | `sharingEllipsis` | Compartiendo… | Sharing… | Compartilhando… | |
| 250 | `sharePng` | Compartir PNG | Share PNG | Compartilhar PNG | |
| 251 | `traceCaption` | Traza del recorrido · inicio verde / final rojo | Route trace · green start / red end | Traçado do trajeto · início verde / fim vermelho | |
| 252 | `shareTagline` | Un paseo más, un recuerdo juntos. | One more walk, a memory together. | Mais um passeio, uma lembrança juntos. | |
| 253 | `walkNotSaved` | El paseo no se guardó | The walk wasn't saved | O passeio não foi salvo | |
| 254 | `walkNotSavedBody` | Podés reintentar el guardado. Si salís ahora, perderás este recorrido. | You can retry saving. If you leave now, you'll lose this route. | Você pode tentar salvar novamente. Se sair agora, perderá este trajeto. | |
| 255 | `back` | Volver | Back | Voltar | |
| 256 | `leaveWithoutSaving` | Salir sin guardar | Leave without saving | Sair sem salvar | |
| 257 | `savingWalk` | Guardando paseo… | Saving walk… | Salvando passeio… | |
| 258 | `walkSaved` | Paseo guardado | Walk saved | Passeio salvo | |
| 259 | `goodWalk` | ¡Buen paseo! | Great walk! | Bom passeio! | |
| 260 | `distanceCaps` | DISTANCIA | DISTANCE | DISTÂNCIA | |
| 261 | `durationLabel` | Duración | Duration | Duração | |
| 262 | `avgSpeed` | Vel. promedio | Avg. speed | Vel. média | |
| 263 | `yourPet` | tu mascota | your pet | seu pet | |
| 264 | `walkedWith` | Paseaste con {name} | You walked with {name} | Você passeou com {name} | |
| 265 | `durationSeconds` | {count} s | {count} s | {count} s | |
| 266 | `durationHm` | {hours}h {minutes}min | {hours}h {minutes}min | {hours}h {minutes}min | |
| 267 | `walkInProgress` | Paseo en curso | Walk in progress | Passeio em andamento | |
| 268 | `locationErrorDefault` | Ocurrió un error de ubicación. | A location error occurred. | Ocorreu um erro de localização. | |
| 269 | `mapCaptured` | Mapa capturado | Map captured | Mapa capturado | |
| 270 | `mapCaptureFailed` | No se pudo capturar el mapa. | Couldn't capture the map. | Não foi possível capturar o mapa. | |
| 271 | `mapCaptureChip` | Captura del mapa | Map capture | Captura do mapa | |
| 272 | `finishWalk` | Finalizar paseo | Finish walk | Finalizar passeio | |
| 273 | `gpsActive` | GPS activo | GPS active | GPS ativo | |
| 274 | `gpsInactive` | GPS inactivo | GPS inactive | GPS inativo | |
| 275 | `durationCaps` | DURACIÓN | DURATION | DURAÇÃO | |
| 276 | `caloriesUnavailable` | Calorías: no disponible | Calories: not available | Calorias: indisponível | |
| 277 | `weightLoadError` | No se pudo cargar el historial. | Couldn't load the history. | Não foi possível carregar o histórico. | |
| 278 | `weightDeleteError` | No se pudo eliminar el registro. | Couldn't delete the record. | Não foi possível excluir o registro. | |
| 279 | `deleteWeightTitle` | Eliminar registro de peso | Delete weight record | Excluir registro de peso | |
| 280 | `noWeightRecords` | Todavía no hay registros de peso. | No weight records yet. | Ainda não há registros de peso. | |
| 281 | `logWeight` | Registrar peso | Log weight | Registrar peso | |
| 282 | `errWeightPositive` | Ingresá un peso mayor que cero. | Enter a weight greater than zero. | Digite um peso maior que zero. | |
| 283 | `weightSaveRetry` | No se pudo guardar el peso. Podés reintentar el mismo registro. | Couldn't save the weight. You can retry the same record. | Não foi possível salvar o peso. Você pode tentar o mesmo registro novamente. | |
| 284 | `confirmIdentity` | Confirmar identidad | Confirm identity | Confirmar identidade | |
| 285 | `currentPassword` | Contraseña actual | Current password | Senha atual | |
| 286 | `confirmGoogleAccount` | Confirmá tu cuenta de Google para continuar. | Confirm your Google account to continue. | Confirme sua conta do Google para continuar. | |
| 287 | `verifyingEllipsis` | Verificando… | Verifying… | Verificando… | |
| 288 | `confirm` | Confirmar | Confirm | Confirmar | |
| 289 | `errEnterCurrentPassword` | Ingresá tu contraseña actual. | Enter your current password. | Digite sua senha atual. | |
| 290 | `identityVerifyError` | No se pudo verificar tu identidad. Intentá otra vez. | Couldn't verify your identity. Try again. | Não foi possível verificar sua identidade. Tente novamente. | |
| 291 | `passwordChangeError` | No se pudo cambiar la contraseña. Intentá otra vez. | Couldn't change the password. Try again. | Não foi possível alterar a senha. Tente novamente. | |
| 292 | `googlePasswordNote` | Tu cuenta utiliza Google. Gestioná su contraseña desde tu cuenta de Google. | Your account uses Google. Manage its password from your Google account. | Sua conta usa o Google. Gerencie a senha pela sua conta do Google. | |
| 293 | `newPassword` | Nueva contraseña | New password | Nova senha | |
| 294 | `repeatNewPassword` | Repetir nueva contraseña | Repeat new password | Repetir nova senha | |
| 295 | `errMin6Chars` | Usá al menos 6 caracteres. | Use at least 6 characters. | Use pelo menos 6 caracteres. | |
| 296 | `newEmail` | Correo nuevo | New email | Novo e-mail | |
| 297 | `sendLink` | Enviar enlace | Send link | Enviar link | |
| 298 | `sendingEllipsis` | Enviando… | Sending… | Enviando… | |
| 299 | `checkingEllipsis` | Comprobando… | Checking… | Verificando… | |
| 300 | `alreadyOpenedLink` | Ya abrí el enlace | I've opened the link | Já abri o link | |
| 301 | `linkSentTo` | Te enviamos un enlace a {email}. Tu correo actual no cambia hasta que lo abras. | We sent a link to {email}. Your current email won't change until you open it. | Enviamos um link para {email}. Seu e-mail atual não muda até você abri-lo. | |
| 302 | `notConfirmedYet` | Todavía no confirmaste el enlace. Abrí el correo que enviamos a {email}. | You haven't confirmed the link yet. Open the email we sent to {email}. | Você ainda não confirmou o link. Abra o e-mail que enviamos para {email}. | |
| 303 | `errEnterNewEmail` | Ingresá el correo nuevo. | Enter the new email. | Digite o novo e-mail. | |
| 304 | `errValidEmail` | Ingresá un correo válido. | Enter a valid email. | Digite um e-mail válido. | |
| 305 | `emailLinkError` | No se pudo enviar el enlace. Intentá otra vez. | Couldn't send the link. Try again. | Não foi possível enviar o link. Tente novamente. | |
| 306 | `emailCheckError` | No se pudo comprobar. Intentá otra vez. | Couldn't check. Try again. | Não foi possível verificar. Tente novamente. | |
| 307 | `googleEmailNote` | Tu cuenta utiliza Google. Gestioná tu correo desde tu cuenta de Google. | Your account uses Google. Manage your email from your Google account. | Sua conta usa o Google. Gerencie seu e-mail pela sua conta do Google. | |
| 308 | `emailUpdated` | Correo actualizado: {email} | Email updated: {email} | E-mail atualizado: {email} | |
| 309 | `passwordUpdated` | Contraseña actualizada. | Password updated. | Senha atualizada. | |
| 310 | `deleteAccountTitle` | Eliminar cuenta | Delete account | Excluir conta | |
| 311 | `deleteAccountBody` | Se borrarán tu cuenta, tus mascotas y sus registros. Esta acción no se puede deshacer. | Your account, your pets and their records will be deleted. This action can't be undone. | Sua conta, seus pets e os registros deles serão apagados. Esta ação não pode ser desfeita. | |
| 312 | `deleteForever` | Eliminar definitivamente | Delete permanently | Excluir definitivamente | |
| 313 | `deletionInProgress` | Eliminación en curso | Deletion in progress | Exclusão em andamento | |
| 314 | `deletionInProgressBody` | Tu cuenta ya está bloqueada y estamos terminando de borrar tus datos. Se completará automáticamente en unos minutos. | Your account is already locked and we're finishing deleting your data. It will complete automatically in a few minutes. | Sua conta já está bloqueada e estamos terminando de apagar seus dados. Será concluído automaticamente em alguns minutos. | |
| 315 | `understood` | Entendido | Got it | Entendi | |
| 316 | `signOutError` | No se pudo cerrar sesión: {error} | Couldn't sign out: {error} | Não foi possível sair: {error} | |
| 317 | `deleteAccountError` | No se pudo eliminar la cuenta: {error} | Couldn't delete the account: {error} | Não foi possível excluir a conta: {error} | |
| 318 | `privacyTitle` | Privacidad | Privacy | Privacidade | |
| 319 | `privacySessionChanged` | La sesión cambió. Volvé a entrar desde tu perfil. | The session changed. Sign in again from your profile. | A sessão mudou. Entre novamente pelo seu perfil. | |
| 320 | `privacyLoadError` | No se pudo cargar la privacidad. | Couldn't load privacy settings. | Não foi possível carregar a privacidade. | |
| 321 | `prefSavedRemindersFailed` | Preferencia guardada. No se pudieron actualizar los avisos de este dispositivo; reintentá antes de cerrarlo. | Preference saved. This device's notifications couldn't be updated; retry before closing. | Preferência salva. Não foi possível atualizar os avisos deste dispositivo; tente novamente antes de fechar. | |
| 322 | `prefNotSaved` | No se guardó la preferencia. Reintentá. | The preference wasn't saved. Try again. | A preferência não foi salva. Tente novamente. | |
| 323 | `downloadMyData` | Descargar mis datos | Download my data | Baixar meus dados | |
| 324 | `downloadMyDataBody` | El archivo incluye tus fotos y recorridos GPS. Elegí un destino privado cuando lo guardes o compartas. | The file includes your photos and GPS routes. Choose a private destination when you save or share it. | O arquivo inclui suas fotos e trajetos de GPS. Escolha um destino privado ao salvar ou compartilhar. | |
| 325 | `continueLabel` | Continuar | Continue | Continuar | |
| 326 | `exportIncomplete` | No se completó el archivo. Podés iniciar otra exportación. | The file wasn't completed. You can start another export. | O arquivo não foi concluído. Você pode iniciar outra exportação. | |
| 327 | `exportShareFailed` | No se pudo guardar o compartir. El archivo sigue preparado para reintentar. | Couldn't save or share. The file is still ready to retry. | Não foi possível salvar ou compartilhar. O arquivo continua pronto para tentar novamente. | |
| 328 | `requestNotRegistered` | No se pudo registrar la solicitud. Conservamos el texto para reintentar. | Couldn't register the request. We kept your text so you can retry. | Não foi possível registrar a solicitação. Mantivemos o texto para você tentar novamente. | |
| 329 | `yourNotices` | Tus avisos | Your notifications | Seus avisos | |
| 330 | `careReminders` | Recordatorios de cuidados | Care reminders | Lembretes de cuidados | |
| 331 | `careRemindersHint` | Vacunas, medicamentos y tareas | Vaccines, medications and tasks | Vacinas, medicamentos e tarefas | |
| 332 | `teamNotices` | Avisos del equipo | Team notices | Avisos da equipe | |
| 333 | `yourData` | Tus datos | Your data | Seus dados | |
| 334 | `yourDataBody` | Descargá tu perfil, mascotas, cuidados, fotos y recorridos en un archivo JSON. | Download your profile, pets, care records, photos and routes as a JSON file. | Baixe seu perfil, pets, cuidados, fotos e trajetos em um arquivo JSON. | |
| 335 | `prepareFile` | Preparar archivo | Prepare file | Preparar arquivo | |
| 336 | `recordsPrepared` | {count} registros preparados | {count} records prepared | {count} registros preparados | |
| 337 | `cancelExport` | Cancelar exportación | Cancel export | Cancelar exportação | |
| 338 | `saveOrShareJson` | Guardar o compartir JSON | Save or share JSON | Salvar ou compartilhar JSON | |
| 339 | `requestsTitle` | Solicitudes | Requests | Solicitações | |
| 340 | `requestType` | Tipo de solicitud | Request type | Tipo de solicitação | |
| 341 | `reqConsulta` | Consulta | Inquiry | Consulta | |
| 342 | `reqAcceso` | Acceso a información | Access to information | Acesso à informação | |
| 343 | `reqCorreccion` | Corrección | Correction | Correção | |
| 344 | `reqOposicion` | Oposición | Objection | Oposição | |
| 345 | `reqBloqueo` | Bloqueo | Blocking | Bloqueio | |
| 346 | `reqAnonimizacion` | Anonimización | Anonymization | Anonimização | |
| 347 | `detailLabel` | Detalle | Details | Detalhes | |
| 348 | `registerRequest` | Registrar solicitud | Submit request | Registrar solicitação | |
| 349 | `requestsByEmail` | Por ahora podés enviar tus solicitudes al correo de soporte. | For now you can send your requests to the support email. | Por enquanto você pode enviar suas solicitações ao e-mail de suporte. | |
| 350 | `requestChannelMissing` | El canal de consultas todavía no está configurado. | The inquiries channel isn't set up yet. | O canal de consultas ainda não foi configurado. | |
| 351 | `refreshRequests` | Actualizar solicitudes | Refresh requests | Atualizar solicitações | |
| 352 | `authUserDisabled` | Esta cuenta está deshabilitada. | This account is disabled. | Esta conta está desativada. | |
| 353 | `authBadCredentials` | Correo o contraseña incorrectos. | Incorrect email or password. | E-mail ou senha incorretos. | |
| 354 | `authEmailInUse` | Ya existe una cuenta con ese correo. | An account with that email already exists. | Já existe uma conta com esse e-mail. | |
| 355 | `authWeakPassword` | La contraseña es demasiado débil (mínimo 6 caracteres). | The password is too weak (minimum 6 characters). | A senha é muito fraca (mínimo de 6 caracteres). | |
| 356 | `authAccountExists` | Ya hay una cuenta con ese correo creada con otro método de acceso. | An account with that email already exists using a different sign-in method. | Já existe uma conta com esse e-mail criada com outro método de acesso. | |
| 357 | `authRecentLogin` | Por seguridad, volvé a iniciar sesión para hacer este cambio. | For security, sign in again to make this change. | Por segurança, entre novamente para fazer esta alteração. | |
| 358 | `authUserMismatch` | La cuenta elegida no coincide con la sesión actual. | The chosen account doesn't match the current session. | A conta escolhida não corresponde à sessão atual. | |
| 359 | `authTooMany` | Demasiados intentos fallidos. Esperá unos minutos y probá de nuevo. | Too many failed attempts. Wait a few minutes and try again. | Muitas tentativas falhas. Aguarde alguns minutos e tente novamente. | |
| 360 | `authNoInternet` | No hay conexión a internet. | No internet connection. | Sem conexão com a internet. | |
| 361 | `authNotEnabled` | Este método de acceso no está habilitado. | This sign-in method isn't enabled. | Este método de acesso não está ativado. | |
| 362 | `authNoSession` | No hay sesión iniciada. | You're not signed in. | Não há sessão iniciada. | |
| 363 | `authSessionChanged` | La sesión cambió. Volvé a intentar desde tu cuenta. | The session changed. Try again from your account. | A sessão mudou. Tente novamente pela sua conta. | |
| 364 | `authCancelled` | Operación cancelada. | Operation cancelled. | Operação cancelada. | |
| 365 | `authGoogleAccount` | Tu cuenta utiliza Google para iniciar sesión. | Your account signs in with Google. | Sua conta entra com o Google. | |
| 366 | `authPasswordFields` | Completá la contraseña actual y una nueva de al menos 6 caracteres. | Fill in the current password and a new one of at least 6 characters. | Preencha a senha atual e uma nova com pelo menos 6 caracteres. | |
| 367 | `authSameEmail` | Ese ya es el correo de tu cuenta. | That's already your account's email. | Esse já é o e-mail da sua conta. | |
| 368 | `authSignupFailed` | No se pudo crear la cuenta. | Couldn't create the account. | Não foi possível criar a conta. | |
| 369 | `authSigninFailed` | No se pudo iniciar sesión. | Couldn't sign in. | Não foi possível entrar. | |
| 370 | `authGoogleSigninFailed` | No se pudo iniciar sesión con Google. | Couldn't sign in with Google. | Não foi possível entrar com o Google. | |
| 371 | `authGoogleUnavailable` | El acceso con Google no está disponible en esta plataforma. | Google sign-in isn't available on this platform. | O acesso com o Google não está disponível nesta plataforma. | |
| 372 | `authPushDisconnect` | No se pudieron desconectar las notificaciones. Reintentá cerrar sesión. | Couldn't disconnect notifications. Try signing out again. | Não foi possível desconectar as notificações. Tente sair novamente. | |
| 373 | `authGeneric` | No se pudo completar la operación. Intentá otra vez. | Couldn't complete the operation. Try again. | Não foi possível concluir a operação. Tente novamente. | |
| 374 | `googleInterrupted` | El acceso con Google se interrumpió. Probá de nuevo. | Google sign-in was interrupted. Try again. | O acesso com o Google foi interrompido. Tente novamente. | |
| 375 | `googleUiUnavailable` | No se pudo abrir el diálogo de Google. | Couldn't open the Google dialog. | Não foi possível abrir a janela do Google. | |
| 376 | `googleConfigError` | La app no está bien configurada para Google. Intentá más tarde. | The app isn't configured correctly for Google. Try again later. | O app não está configurado corretamente para o Google. Tente mais tarde. | |
| 377 | `googleUserMismatch` | La cuenta de Google no coincide con la esperada. | The Google account doesn't match the expected one. | A conta do Google não corresponde à esperada. | |
| 378 | `apiSessionChanged` | La sesión cambió. | The session changed. | A sessão mudou. | |
| 379 | `apiInvalidResponse` | El servidor devolvió una respuesta inválida. Reintentá. | The server returned an invalid response. Try again. | O servidor retornou uma resposta inválida. Tente novamente. | |
| 380 | `apiListTooLarge` | El listado es demasiado grande para esta pantalla. No se mostraron resultados incompletos. | The list is too large for this screen. Incomplete results were not shown. | A lista é grande demais para esta tela. Resultados incompletos não foram exibidos. | |
| 381 | `apiTimeout` | El servidor tardó demasiado en responder. | The server took too long to respond. | O servidor demorou demais para responder. | |
| 382 | `apiOffline` | No hay conexión con el servidor. Comprobá tu conexión a internet. | Can't reach the server. Check your internet connection. | Sem conexão com o servidor. Verifique sua internet. | |
| 383 | `apiHttpStatus` | El servidor respondió con un error ({status}). | The server responded with an error ({status}). | O servidor respondeu com um erro ({status}). | |
| 384 | `noticeVaccineTitle` | Vacuna de {pet} | {pet}'s vaccine | Vacina de {pet} | |
| 385 | `noticeVaccineBody` | Se acerca {vaccine}: {date}. | {vaccine} is coming up: {date}. | {vaccine} está chegando: {date}. | |
| 386 | `noticeMedicationTitle` | Medicamento de {pet} | {pet}'s medication | Medicamento de {pet} | |
| 387 | `noticeMedicationBody` | {medication}: {dose}. | {medication}: {dose}. | {medication}: {dose}. | |
| 388 | `photoOpenFailed` | No se pudo abrir la imagen. Probá otra vez. | Couldn't open the image. Try again. | Não foi possível abrir a imagem. Tente novamente. | |
| 389 | `photoTooLarge` | La imagen es demasiado grande. Probá con otra. | The image is too large. Try another one. | A imagem é grande demais. Tente outra. | |
| 390 | `photoTooLargeAfter` | La foto es demasiado grande incluso después de reducirla. Probá con otra. | The photo is too large even after shrinking it. Try another one. | A foto é grande demais mesmo depois de reduzida. Tente outra. | |
| 391 | `photoInvalidType` | Elegí una imagen JPEG o PNG. | Choose a JPEG or PNG image. | Escolha uma imagem JPEG ou PNG. | |
| 392 | `photoInvalidOrLarge` | La imagen no es válida o es demasiado grande. | The image isn't valid or is too large. | A imagem não é válida ou é grande demais. | |
| 393 | `photoUnreadable` | No se pudo leer la imagen. Probá con otra. | Couldn't read the image. Try another one. | Não foi possível ler a imagem. Tente outra. | |
| 394 | `exportCancelled` | Exportación cancelada. | Export cancelled. | Exportação cancelada. | |
| 395 | `exportSessionChanged` | La sesión cambió. No se preparó el archivo. | The session changed. The file wasn't prepared. | A sessão mudou. O arquivo não foi preparado. | |
| 396 | `exportTooBig` | El archivo necesita asistencia por su tamaño. | The file is too large and needs assistance. | O arquivo precisa de assistência por causa do tamanho. | |
| 397 | `exportStartFailed` | No se pudo iniciar una exportación válida. | Couldn't start a valid export. | Não foi possível iniciar uma exportação válida. | |
| 398 | `exportInvalidResponse` | La exportación devolvió una respuesta inválida. Iniciá otra. | The export returned an invalid response. Start another one. | A exportação retornou uma resposta inválida. Inicie outra. | |
| 399 | `exportIncompleteService` | No se completó la exportación. Iniciá otra. | The export wasn't completed. Start another one. | A exportação não foi concluída. Inicie outra. | |
| 400 | `captureNotReady` | El mapa todavía no está listo. | The map isn't ready yet. | O mapa ainda não está pronto. | |
| 401 | `captureUnreadable` | No se pudo leer la imagen del mapa. | Couldn't read the map image. | Não foi possível ler a imagem do mapa. | |
| 402 | `captureTooLarge` | La captura del mapa salió demasiado grande. Probá con menos zoom. | The map capture is too large. Try zooming out less. | A captura do mapa ficou grande demais. Tente com menos zoom. | |
| 403 | `locGpsOff` | El GPS está desactivado. Activalo para continuar. | GPS is off. Turn it on to continue. | O GPS está desativado. Ative-o para continuar. | |
| 404 | `locDenied` | Permiso de ubicación denegado. | Location permission denied. | Permissão de localização negada. | |
| 405 | `locDeniedForever` | Permiso denegado permanentemente. Habilitalo desde ajustes del sistema. | Permission permanently denied. Enable it in system settings. | Permissão negada permanentemente. Ative-a nas configurações do sistema. | |
| 406 | `locFailed` | No se pudo obtener la ubicación: {error} | Couldn't get the location: {error} | Não foi possível obter a localização: {error} | |
| 407 | `inactivityTitle` | Aviso por falta de paseos | No-walk reminder | Aviso por falta de passeios | |
| 408 | `inactivityHint` | Te avisamos si pasa el plazo que elegís sin registrar un paseo. | We'll remind you if the period you choose passes without a recorded walk. | Avisamos se o prazo escolhido passar sem um passeio registrado. | |
| 409 | `inactivityAfter` | Avisar tras | Remind after | Avisar após | |
| 410 | `inactivityDays` | {count, plural, one{{count} día} other{{count} días}} | {count, plural, one{{count} day} other{{count} days}} | {count, plural, one{{count} dia} other{{count} dias}} | |
| 411 | `inactivityIncludeNew` | Incluir mascotas sin paseos registrados | Include pets with no recorded walks | Incluir pets sem passeios registrados | |
| 412 | `kindInactivity` | Sin paseos | No walks | Sem passeios | |
| 413 | `premiumTitle` | Premium | Premium | Premium | |
| 414 | `premiumActiveUntil` | Premium activo hasta {date} | Premium active until {date} | Premium ativo até {date} | |
| 415 | `premiumInactive` | Sin Premium activo | No active Premium | Sem Premium ativo | |
| 416 | `premiumSourceManual` | Concedido por el equipo de PawLife | Granted by the PawLife team | Concedido pela equipe PawLife | |
| 417 | `premiumSourcePaid` | Suscripción | Subscription | Assinatura | |
| 418 | `premiumNoPurchases` | Por ahora Premium lo concede el equipo de PawLife. Todavía no hay compras dentro de la app. | For now Premium is granted by the PawLife team. There are no in-app purchases yet. | Por enquanto o Premium é concedido pela equipe PawLife. Ainda não há compras dentro do app. | |
| 419 | `premiumLoadError` | No se pudo consultar tu estado de Premium. | Couldn't check your Premium status. | Não foi possível consultar seu status Premium. | |
| 420 | `apiAccountDeleting` | Tu cuenta se está eliminando. | Your account is being deleted. | Sua conta está sendo excluída. | |
| 421 | `apiAccountUnavailable` | La cuenta no está disponible. | The account isn't available. | A conta não está disponível. | |
| 422 | `apiRateLimited` | Hiciste demasiados cambios seguidos. Esperá un rato y probá de nuevo. | Too many changes in a row. Wait a while and try again. | Muitas alterações seguidas. Aguarde um pouco e tente novamente. | |
| 423 | `apiPhotoProcessor` | No se pudo procesar la foto ahora. Reintentá más tarde. | The photo can't be processed right now. Try again later. | Não foi possível processar a foto agora. Tente mais tarde. | |
| 424 | `apiInvalidPhoto` | La foto no es válida. | The photo isn't valid. | A foto não é válida. | |
| 425 | `apiTooLarge` | Los datos son demasiado grandes para guardarse. | The data is too large to save. | Os dados são grandes demais para salvar. | |
| 426 | `apiExportExpired` | La exportación venció. Iniciá otra. | The export expired. Start another one. | A exportação expirou. Inicie outra. | |
| 427 | `apiBillingReview` | Tu cuenta tiene una suscripción o compra que debe revisarse antes de eliminarla. | Your account has a subscription or purchase that must be reviewed before it can be deleted. | Sua conta tem uma assinatura ou compra que precisa ser revisada antes de ser excluída. | |
| 428 | `apiPrivacyUnavailable` | El canal de privacidad todavía no está disponible. | The privacy channel isn't available yet. | O canal de privacidade ainda não está disponível. | |
| 429 | `apiServiceBusy` | El servicio no está disponible en este momento. Reintentá en unos minutos. | The service isn't available right now. Try again in a few minutes. | O serviço não está disponível no momento. Tente novamente em alguns minutos. | |
| 430 | `apiDeviceConflict` | Este dispositivo ya está asociado a otra cuenta. | This device is already linked to another account. | Este dispositivo já está associado a outra conta. | |
