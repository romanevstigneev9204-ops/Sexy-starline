import 'package:flutter/widgets.dart';

/// UI language. Default [AppLanguage.ru] per RU market prefs.
enum AppLanguage { ru, en }

extension AppLanguageX on AppLanguage {
  Locale get locale => Locale(name);

  static AppLanguage fromLocale(Locale locale) {
    if (locale.languageCode.toLowerCase() == 'en') {
      return AppLanguage.en;
    }
    return AppLanguage.ru;
  }

  String get settingsLabel {
    switch (this) {
      case AppLanguage.ru:
        return S.languageRu;
      case AppLanguage.en:
        return S.languageEn;
    }
  }

  String get settingsHint {
    switch (this) {
      case AppLanguage.ru:
        return S.languageRuHint;
      case AppLanguage.en:
        return S.languageEnHint;
    }
  }
}

/// Dual-locale string catalog (ARB-style Dart source; default RU).
class AppStrings {
  const AppStrings({
    required this.appName,
    required this.brandMark,
    required this.loginTitle,
    required this.loginSubtitle,
    required this.loginHint,
    required this.passwordHint,
    required this.loginCta,
    required this.loginFooter,
    required this.demoBanner,
    required this.loginDemoCta,
    required this.loginRealCta,
    required this.devicesTitle,
    required this.devicesSubtitle,
    required this.devicePrimary,
    required this.sharedReadonly,
    required this.sharedFromOnline,
    required this.navHome,
    required this.navMap,
    required this.navEvents,
    required this.armed,
    required this.disarmed,
    required this.offline,
    required this.engineOff,
    required this.engineOn,
    required this.doorsClosed,
    required this.doorsOpen,
    required this.statusOnline,
    required this.battery,
    required this.cabin,
    required this.engineTemp,
    required this.gsm,
    required this.disarm,
    required this.arm,
    required this.start,
    required this.stop,
    required this.horn,
    required this.moreCommands,
    required this.quietArm,
    required this.quietDisarm,
    required this.panic,
    required this.valetOn,
    required this.valetOff,
    required this.valetActive,
    required this.comfortCommands,
    required this.webastoOn,
    required this.webastoOff,
    required this.webastoActive,
    required this.auxOn,
    required this.auxOff,
    required this.auxActive,
    required this.apiBudget,
    required this.updatedAgo,
    required this.noLink,
    required this.offlineDetail,
    required this.checkLink,
    required this.checkSim,
    required this.disarmTitle,
    required this.disarmBody,
    required this.disarmConfirm,
    required this.startTitle,
    required this.startBody,
    required this.startHold,
    required this.panicTitle,
    required this.panicBody,
    required this.panicConfirm,
    required this.valetTitle,
    required this.valetBody,
    required this.valetConfirm,
    required this.webastoTitle,
    required this.webastoBody,
    required this.webastoConfirm,
    required this.auxTitle,
    required this.auxBody,
    required this.auxConfirm,
    required this.cancel,
    required this.lastPoint,
    required this.refreshPosition,
    required this.tracksTitle,
    required this.tracksEmpty,
    required this.tracksLoad,
    required this.tracksHide,
    required this.tracksShow,
    required this.tracksRefresh,
    required this.tracksThrottle,
    required this.tracksBudgetHint,
    required this.trackMileage,
    required this.trackDuration,
    required this.geofencesTitle,
    required this.geofencesHint,
    required this.geofencesEmpty,
    required this.geofenceAdd,
    required this.geofenceEdit,
    required this.geofenceNameHint,
    required this.geofenceRadius,
    required this.geofenceSave,
    required this.geofenceDelete,
    required this.geofenceEnabled,
    required this.geofenceEnter,
    required this.geofenceExit,
    required this.geofencesHide,
    required this.geofencesShow,
    required this.geofenceAlertEnter,
    required this.geofenceAlertExit,
    required this.geofencesDemoSeed,
    required this.obdTitle,
    required this.obdSection,
    required this.obdFuel,
    required this.obdMileage,
    required this.obdErrors,
    required this.obdUnsupported,
    required this.obdRefresh,
    required this.obdEmpty,
    required this.obdDemoHint,
    required this.eventsTitle,
    required this.filterAll,
    required this.filterAlarms,
    required this.filterCommands,
    required this.today,
    required this.settingsTitle,
    required this.theme,
    required this.themeValue,
    required this.themeSheetTitle,
    required this.themeNightDrive,
    required this.themeNightDriveHint,
    required this.themeSystem,
    required this.themeSystemHint,
    required this.themeDayMetal,
    required this.themeDayMetalHint,
    required this.themeClose,
    required this.language,
    required this.languageSheetTitle,
    required this.languageRu,
    required this.languageRuHint,
    required this.languageEn,
    required this.languageEnHint,
    required this.apiLimit,
    required this.simBalance,
    required this.simBalanceEmpty,
    required this.simBalanceDemoHint,
    required this.devices,
    required this.about,
    required this.aboutValue,
    required this.logout,
    required this.rateLimitBadge,
    required this.rateLimitTitle,
    required this.rateLimitBody,
    required this.rateLimitCta,
    required this.menuDevices,
    required this.menuSettings,
    required this.commandPending,
    required this.commandOk,
    required this.commandFail,
    required this.captchaTitle,
    required this.captchaBody,
    required this.captchaSmsBody,
    required this.captchaHint,
    required this.continueLabel,
    required this.resendCode,
    required this.resendCodeNow,
    required this.backToLogin,
    required this.budgetNearBanner,
    required this.budgetHomeLabel,
    required this.demoCaptchaHint,
    required this.apiBudgetLabel,
    required this.simNoData,
    required this.obdNoErrors,
    required this.obdErrorOne,
    required this.obdErrorFew,
    required this.obdErrorMany,
    required this.obdFuelPart,
    required this.obdMileagePart,
    required this.obdLitres,
    required this.obdKm,
    required this.demoUnavailable,
  });

  final String appName;
  final String brandMark;
  final String loginTitle;
  final String loginSubtitle;
  final String loginHint;
  final String passwordHint;
  final String loginCta;
  final String loginFooter;
  final String demoBanner;
  final String loginDemoCta;
  final String loginRealCta;
  final String devicesTitle;
  final String devicesSubtitle;
  final String devicePrimary;
  final String sharedReadonly;
  final String sharedFromOnline;
  final String navHome;
  final String navMap;
  final String navEvents;
  final String armed;
  final String disarmed;
  final String offline;
  final String engineOff;
  final String engineOn;
  final String doorsClosed;
  final String doorsOpen;
  final String statusOnline;
  final String battery;
  final String cabin;
  final String engineTemp;
  final String gsm;
  final String disarm;
  final String arm;
  final String start;
  final String stop;
  final String horn;
  final String moreCommands;
  final String quietArm;
  final String quietDisarm;
  final String panic;
  final String valetOn;
  final String valetOff;
  final String valetActive;
  final String comfortCommands;
  final String webastoOn;
  final String webastoOff;
  final String webastoActive;
  final String auxOn;
  final String auxOff;
  final String auxActive;
  final String apiBudget;
  final String updatedAgo;
  final String noLink;
  final String offlineDetail;
  final String checkLink;
  final String checkSim;
  final String disarmTitle;
  final String disarmBody;
  final String disarmConfirm;
  final String startTitle;
  final String startBody;
  final String startHold;
  final String panicTitle;
  final String panicBody;
  final String panicConfirm;
  final String valetTitle;
  final String valetBody;
  final String valetConfirm;
  final String webastoTitle;
  final String webastoBody;
  final String webastoConfirm;
  final String auxTitle;
  final String auxBody;
  final String auxConfirm;
  final String cancel;
  final String lastPoint;
  final String refreshPosition;
  final String tracksTitle;
  final String tracksEmpty;
  final String tracksLoad;
  final String tracksHide;
  final String tracksShow;
  final String tracksRefresh;
  final String tracksThrottle;
  final String tracksBudgetHint;
  final String trackMileage;
  final String trackDuration;
  final String geofencesTitle;
  final String geofencesHint;
  final String geofencesEmpty;
  final String geofenceAdd;
  final String geofenceEdit;
  final String geofenceNameHint;
  final String geofenceRadius;
  final String geofenceSave;
  final String geofenceDelete;
  final String geofenceEnabled;
  final String geofenceEnter;
  final String geofenceExit;
  final String geofencesHide;
  final String geofencesShow;
  final String geofenceAlertEnter;
  final String geofenceAlertExit;
  final String geofencesDemoSeed;
  final String obdTitle;
  final String obdSection;
  final String obdFuel;
  final String obdMileage;
  final String obdErrors;
  final String obdUnsupported;
  final String obdRefresh;
  final String obdEmpty;
  final String obdDemoHint;
  final String eventsTitle;
  final String filterAll;
  final String filterAlarms;
  final String filterCommands;
  final String today;
  final String settingsTitle;
  final String theme;
  final String themeValue;
  final String themeSheetTitle;
  final String themeNightDrive;
  final String themeNightDriveHint;
  final String themeSystem;
  final String themeSystemHint;
  final String themeDayMetal;
  final String themeDayMetalHint;
  final String themeClose;
  final String language;
  final String languageSheetTitle;
  final String languageRu;
  final String languageRuHint;
  final String languageEn;
  final String languageEnHint;
  final String apiLimit;
  final String simBalance;
  final String simBalanceEmpty;
  final String simBalanceDemoHint;
  final String devices;
  final String about;
  final String aboutValue;
  final String logout;
  final String rateLimitBadge;
  final String rateLimitTitle;
  final String rateLimitBody;
  final String rateLimitCta;
  final String menuDevices;
  final String menuSettings;
  final String commandPending;
  final String commandOk;
  final String commandFail;
  final String captchaTitle;
  final String captchaBody;
  final String captchaSmsBody;
  final String captchaHint;
  final String continueLabel;
  final String resendCode;
  final String resendCodeNow;
  final String backToLogin;
  final String budgetNearBanner;
  final String budgetHomeLabel;
  final String demoCaptchaHint;
  final String apiBudgetLabel;
  final String simNoData;
  final String obdNoErrors;
  final String obdErrorOne;
  final String obdErrorFew;
  final String obdErrorMany;
  final String obdFuelPart;
  final String obdMileagePart;
  final String obdLitres;
  final String obdKm;
  final String demoUnavailable;

  static AppStrings forLanguage(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return en;
      case AppLanguage.ru:
        return ru;
    }
  }

  static const ru = AppStrings(
    appName: 'SEXY STARLINE',
    brandMark: 'Sexy Starline',
    loginTitle: 'Контроль охраны',
    loginSubtitle: 'Войдите через StarLine ID, чтобы видеть статус и команды своего авто.',
    loginHint: 'Логин StarLine ID',
    passwordHint: 'Пароль',
    loginCta: 'Войти',
    loginFooter: 'Поддерживается captcha / SMS, если потребует SLID',
    demoBanner: 'Демо-режим: без AppId можно сразу посмотреть UI на mock-данных. Нажмите «Продолжить в демо».',
    loginDemoCta: 'Продолжить в демо',
    loginRealCta: 'Войти через StarLine ID',
    devicesTitle: 'Ваши устройства',
    devicesSubtitle: 'Выберите основное авто для Home и команд.',
    devicePrimary: 'Основное',
    sharedReadonly: 'Общий доступ (read-only)',
    sharedFromOnline: 'шаринг из StarLine Online',
    navHome: 'Главная',
    navMap: 'Карта',
    navEvents: 'События',
    armed: 'НА ОХРАНЕ',
    disarmed: 'СНЯТО С ОХРАНЫ',
    offline: 'ОФЛАЙН',
    engineOff: 'Двигатель выкл.',
    engineOn: 'Двигатель вкл.',
    doorsClosed: 'Двери закрыты',
    doorsOpen: 'Двери открыты',
    statusOnline: 'Online',
    battery: 'АКБ',
    cabin: 'Салон',
    engineTemp: 'Двиг.',
    gsm: 'GSM',
    disarm: 'Снять с охраны',
    arm: 'Поставить на охрану',
    start: 'Запуск',
    stop: 'Стоп',
    horn: 'Сигнал',
    moreCommands: 'Дополнительно',
    quietArm: 'Тихая охрана',
    quietDisarm: 'Тихо снять',
    panic: 'Паника',
    valetOn: 'Сервисный режим',
    valetOff: 'Выйти из сервиса',
    valetActive: 'Сервисный режим включён',
    comfortCommands: 'Комфорт',
    webastoOn: 'Включить Webasto',
    webastoOff: 'Выключить Webasto',
    webastoActive: 'Webasto включён',
    auxOn: 'Доп. канал вкл.',
    auxOff: 'Доп. канал выкл.',
    auxActive: 'Доп. канал включён',
    apiBudget: 'Бюджет API',
    updatedAgo: 'Обновлено',
    noLink: 'Нет связи с авто',
    offlineDetail: 'Последний снимок {mins} мин назад. Команды могут не дойти.',
    checkLink: 'Проверить связь',
    checkSim: 'Проверьте баланс SIM и покрытие GSM.',
    disarmTitle: 'Снять с охраны?',
    disarmBody: 'Двери разблокируются. Подтвердите, если вы рядом с авто.',
    disarmConfirm: 'Да, снять с охраны',
    startTitle: 'Запустить двигатель?',
    startBody: 'Команда уйдёт в StarLine. Убедитесь, что авто в безопасном месте.',
    startHold: 'Удерживайте, чтобы запустить',
    panicTitle: 'Включить панику?',
    panicBody: 'Сирена и световые сигналы. Используйте только при реальной угрозе.',
    panicConfirm: 'Да, паника',
    valetTitle: 'Включить сервисный режим?',
    valetBody: 'Охрана и автозапуск будут ограничены. Нужно для сервиса или мойки.',
    valetConfirm: 'Включить сервис',
    webastoTitle: 'Включить Webasto?',
    webastoBody: 'Подогреватель салона/двигателя получит команду. Убедитесь, что это безопасно.',
    webastoConfirm: 'Да, включить Webasto',
    auxTitle: 'Включить доп. канал?',
    auxBody: 'Дополнительный канал (AUX/out) переключится. Проверьте, что подключено к каналу.',
    auxConfirm: 'Да, включить канал',
    cancel: 'Отмена',
    lastPoint: 'Последняя точка',
    refreshPosition: 'Обновить позицию',
    tracksTitle: 'Треки за сегодня',
    tracksEmpty: 'Нет поездок за выбранный период',
    tracksLoad: 'Показать треки',
    tracksHide: 'Скрыть трек',
    tracksShow: 'Показать трек',
    tracksRefresh: 'Обновить треки',
    tracksThrottle: 'Треки обновляются не чаще раза в 10 мин (лимит StarLine /ways).',
    tracksBudgetHint: 'Запрос трека расходует бюджет API · период ≤ 24 ч',
    trackMileage: 'Пробег',
    trackDuration: 'В пути',
    geofencesTitle: 'Геозоны',
    geofencesHint: 'Локальные зоны на устройстве. Алерты по позиции из опроса Home — без API геозон StarLine.',
    geofencesEmpty: 'Нет геозон — добавьте вокруг текущего авто',
    geofenceAdd: 'Добавить геозону',
    geofenceEdit: 'Геозона',
    geofenceNameHint: 'Название',
    geofenceRadius: 'Радиус, м',
    geofenceSave: 'Сохранить',
    geofenceDelete: 'Удалить',
    geofenceEnabled: 'Включена',
    geofenceEnter: 'Вход',
    geofenceExit: 'Выход',
    geofencesHide: 'Скрыть зоны',
    geofencesShow: 'Показать зоны',
    geofenceAlertEnter: 'Вход в геозону',
    geofenceAlertExit: 'Выход из геозоны',
    geofencesDemoSeed: 'Демо: Дом и Офис около Лесной',
    obdTitle: 'OBD',
    obdSection: 'Диагностика OBD',
    obdFuel: 'Топливо',
    obdMileage: 'Пробег',
    obdErrors: 'Ошибки',
    obdUnsupported: 'OBD недоступен на этом устройстве',
    obdRefresh: 'Обновить OBD',
    obdEmpty: 'Нет данных OBD',
    obdDemoHint: 'Демо-данные',
    eventsTitle: 'Журнал событий',
    filterAll: 'Все',
    filterAlarms: 'Тревоги',
    filterCommands: 'Команды',
    today: 'Сегодня',
    settingsTitle: 'Настройки',
    theme: 'Тема',
    themeValue: 'Night Drive',
    themeSheetTitle: 'Тема оформления',
    themeNightDrive: 'Night Drive',
    themeNightDriveHint: 'Графит · cyan · amber (текущая)',
    themeSystem: 'Системная',
    themeSystemHint: 'Следует системной схеме; пока всегда Night Drive',
    themeDayMetal: 'Day Metal',
    themeDayMetalHint: 'Скоро — светлая тема',
    themeClose: 'Готово',
    language: 'Язык',
    languageSheetTitle: 'Язык интерфейса',
    languageRu: 'Русский',
    languageRuHint: 'По умолчанию для РФ',
    languageEn: 'English',
    languageEnHint: 'Optional English UI',
    apiLimit: 'Лимит API',
    simBalance: 'Баланс SIM',
    simBalanceEmpty: 'Нет данных от StarLine',
    simBalanceDemoHint: 'Демо-данные',
    devices: 'Устройства',
    about: 'О приложении',
    aboutValue: 'Sexy Starline MVP · owner-only',
    logout: 'Выйти из сессии',
    rateLimitBadge: 'HTTP 429',
    rateLimitTitle: 'Лимит\nзапросов',
    rateLimitBody:
        'Достигнут дневной лимит StarLine Open API (~1000).\nПоказываем кэш. Обновление — завтра или реже.',
    rateLimitCta: 'Понятно, работать с кэшем',
    menuDevices: 'Устройства',
    menuSettings: 'Настройки',
    commandPending: 'Команда отправлена…',
    commandOk: 'Готово',
    commandFail: 'Не удалось выполнить команду',
    captchaTitle: 'Подтверждение входа',
    captchaBody: 'Введите код из SMS или captcha из ответа StarLine ID.',
    captchaSmsBody: 'Введите код из SMS, отправленного StarLine ID.',
    captchaHint: 'Код из SMS / captcha',
    continueLabel: 'Продолжить',
    resendCode: 'Отправить код ещё раз',
    resendCodeNow: 'Отправить код ещё раз',
    backToLogin: 'К экрану входа',
    budgetNearBanner: 'Близко к лимиту API — опрос каждые ~3 мин. Тяните для обновления.',
    budgetHomeLabel: 'Бюджет API',
    demoCaptchaHint: 'Демо-челлендж: логин captcha или sms + любой пароль → код 1234.',
    apiBudgetLabel: '~{count} / {limit} запросов сегодня',
    simNoData: 'Нет данных',
    obdNoErrors: 'Нет ошибок',
    obdErrorOne: '1 ошибка',
    obdErrorFew: '{n} ошибки',
    obdErrorMany: '{n} ошибок',
    obdFuelPart: 'Топливо {v}',
    obdMileagePart: 'Пробег {v}',
    obdLitres: 'л',
    obdKm: 'км',
    demoUnavailable: 'Демо недоступно',
  );

  static const en = AppStrings(
    appName: 'SEXY STARLINE',
    brandMark: 'Sexy Starline',
    loginTitle: 'Security control',
    loginSubtitle: 'Sign in with StarLine ID to see status and commands for your car.',
    loginHint: 'StarLine ID login',
    passwordHint: 'Password',
    loginCta: 'Sign in',
    loginFooter: 'Captcha / SMS supported when SLID requires it',
    demoBanner: 'Demo mode: no AppId needed — explore the UI on mock data. Tap “Continue in demo”.',
    loginDemoCta: 'Continue in demo',
    loginRealCta: 'Sign in with StarLine ID',
    devicesTitle: 'Your devices',
    devicesSubtitle: 'Pick a primary car for Home and commands.',
    devicePrimary: 'Primary',
    sharedReadonly: 'Shared access (read-only)',
    sharedFromOnline: 'shared from StarLine Online',
    navHome: 'Home',
    navMap: 'Map',
    navEvents: 'Events',
    armed: 'ARMED',
    disarmed: 'DISARMED',
    offline: 'OFFLINE',
    engineOff: 'Engine off',
    engineOn: 'Engine on',
    doorsClosed: 'Doors closed',
    doorsOpen: 'Doors open',
    statusOnline: 'Online',
    battery: 'Battery',
    cabin: 'Cabin',
    engineTemp: 'Engine',
    gsm: 'GSM',
    disarm: 'Disarm',
    arm: 'Arm',
    start: 'Start',
    stop: 'Stop',
    horn: 'Horn',
    moreCommands: 'More',
    quietArm: 'Silent arm',
    quietDisarm: 'Silent disarm',
    panic: 'Panic',
    valetOn: 'Valet mode',
    valetOff: 'Exit valet',
    valetActive: 'Valet mode on',
    comfortCommands: 'Comfort',
    webastoOn: 'Turn on Webasto',
    webastoOff: 'Turn off Webasto',
    webastoActive: 'Webasto on',
    auxOn: 'AUX on',
    auxOff: 'AUX off',
    auxActive: 'AUX on',
    apiBudget: 'API budget',
    updatedAgo: 'Updated',
    noLink: 'No link to the car',
    offlineDetail: 'Last snapshot {mins} min ago. Commands may not arrive.',
    checkLink: 'Check link',
    checkSim: 'Check SIM balance and GSM coverage.',
    disarmTitle: 'Disarm?',
    disarmBody: 'Doors will unlock. Confirm if you are near the car.',
    disarmConfirm: 'Yes, disarm',
    startTitle: 'Start the engine?',
    startBody: 'The command goes to StarLine. Make sure the car is in a safe place.',
    startHold: 'Hold to start',
    panicTitle: 'Trigger panic?',
    panicBody: 'Siren and lights. Use only for a real threat.',
    panicConfirm: 'Yes, panic',
    valetTitle: 'Enable valet mode?',
    valetBody: 'Security and remote start will be limited. Use for service or wash.',
    valetConfirm: 'Enable valet',
    webastoTitle: 'Turn on Webasto?',
    webastoBody: 'Cabin/engine heater will get a command. Make sure it is safe.',
    webastoConfirm: 'Yes, turn on Webasto',
    auxTitle: 'Turn on AUX?',
    auxBody: 'The AUX/out channel will switch. Check what is wired to it.',
    auxConfirm: 'Yes, turn on channel',
    cancel: 'Cancel',
    lastPoint: 'Last point',
    refreshPosition: 'Refresh position',
    tracksTitle: 'Tracks today',
    tracksEmpty: 'No trips for the selected period',
    tracksLoad: 'Show tracks',
    tracksHide: 'Hide track',
    tracksShow: 'Show track',
    tracksRefresh: 'Refresh tracks',
    tracksThrottle: 'Tracks refresh at most once every 10 min (StarLine /ways limit).',
    tracksBudgetHint: 'Track request uses API budget · period ≤ 24 h',
    trackMileage: 'Mileage',
    trackDuration: 'Duration',
    geofencesTitle: 'Geofences',
    geofencesHint: 'On-device zones. Alerts use Home poll position — no StarLine geofence API.',
    geofencesEmpty: 'No geofences — add one around the current car',
    geofenceAdd: 'Add geofence',
    geofenceEdit: 'Geofence',
    geofenceNameHint: 'Name',
    geofenceRadius: 'Radius, m',
    geofenceSave: 'Save',
    geofenceDelete: 'Delete',
    geofenceEnabled: 'Enabled',
    geofenceEnter: 'Enter',
    geofenceExit: 'Exit',
    geofencesHide: 'Hide zones',
    geofencesShow: 'Show zones',
    geofenceAlertEnter: 'Entered geofence',
    geofenceAlertExit: 'Left geofence',
    geofencesDemoSeed: 'Demo: Home and Office near Lesnaya',
    obdTitle: 'OBD',
    obdSection: 'OBD diagnostics',
    obdFuel: 'Fuel',
    obdMileage: 'Mileage',
    obdErrors: 'Errors',
    obdUnsupported: 'OBD unavailable on this device',
    obdRefresh: 'Refresh OBD',
    obdEmpty: 'No OBD data',
    obdDemoHint: 'Demo data',
    eventsTitle: 'Event log',
    filterAll: 'All',
    filterAlarms: 'Alarms',
    filterCommands: 'Commands',
    today: 'Today',
    settingsTitle: 'Settings',
    theme: 'Theme',
    themeValue: 'Night Drive',
    themeSheetTitle: 'Appearance',
    themeNightDrive: 'Night Drive',
    themeNightDriveHint: 'Graphite · cyan · amber (current)',
    themeSystem: 'System',
    themeSystemHint: 'Follows system scheme; still Night Drive for now',
    themeDayMetal: 'Day Metal',
    themeDayMetalHint: 'Soon — light theme',
    themeClose: 'Done',
    language: 'Language',
    languageSheetTitle: 'Interface language',
    languageRu: 'Russian',
    languageRuHint: 'Default for RU market',
    languageEn: 'English',
    languageEnHint: 'Optional English UI',
    apiLimit: 'API limit',
    simBalance: 'SIM balance',
    simBalanceEmpty: 'No data from StarLine',
    simBalanceDemoHint: 'Demo data',
    devices: 'Devices',
    about: 'About',
    aboutValue: 'Sexy Starline MVP · owner-only',
    logout: 'Sign out',
    rateLimitBadge: 'HTTP 429',
    rateLimitTitle: 'Request\nlimit',
    rateLimitBody:
        'Daily StarLine Open API limit reached (~1000).\nShowing cache. Refresh tomorrow or less often.',
    rateLimitCta: 'OK, use cache',
    menuDevices: 'Devices',
    menuSettings: 'Settings',
    commandPending: 'Command sent…',
    commandOk: 'Done',
    commandFail: 'Command failed',
    captchaTitle: 'Sign-in confirmation',
    captchaBody: 'Enter the SMS code or captcha from StarLine ID.',
    captchaSmsBody: 'Enter the SMS code sent by StarLine ID.',
    captchaHint: 'SMS / captcha code',
    continueLabel: 'Continue',
    resendCode: 'Resend code',
    resendCodeNow: 'Resend code',
    backToLogin: 'Back to sign in',
    budgetNearBanner: 'Near API limit — polling every ~3 min. Pull to refresh.',
    budgetHomeLabel: 'API budget',
    demoCaptchaHint: 'Demo challenge: login captcha or sms + any password → code 1234.',
    apiBudgetLabel: '~{count} / {limit} requests today',
    simNoData: 'No data',
    obdNoErrors: 'No errors',
    obdErrorOne: '1 error',
    obdErrorFew: '{n} errors',
    obdErrorMany: '{n} errors',
    obdFuelPart: 'Fuel {v}',
    obdMileagePart: 'Mileage {v}',
    obdLitres: 'L',
    obdKm: 'km',
    demoUnavailable: 'Demo unavailable',
  );
}

/// Bound by [SexyStarlineApp] when locale preference changes.
abstract final class S {
  static AppStrings _current = AppStrings.ru;

  static AppStrings get current => _current;

  static void bind(AppLanguage language) {
    _current = AppStrings.forLanguage(language);
  }

  static String get appName => _current.appName;
  static String get brandMark => _current.brandMark;
  static String get loginTitle => _current.loginTitle;
  static String get loginSubtitle => _current.loginSubtitle;
  static String get loginHint => _current.loginHint;
  static String get passwordHint => _current.passwordHint;
  static String get loginCta => _current.loginCta;
  static String get loginFooter => _current.loginFooter;
  static String get demoBanner => _current.demoBanner;
  static String get loginDemoCta => _current.loginDemoCta;
  static String get loginRealCta => _current.loginRealCta;
  static String get devicesTitle => _current.devicesTitle;
  static String get devicesSubtitle => _current.devicesSubtitle;
  static String get devicePrimary => _current.devicePrimary;
  static String get sharedReadonly => _current.sharedReadonly;
  static String get sharedFromOnline => _current.sharedFromOnline;
  static String get navHome => _current.navHome;
  static String get navMap => _current.navMap;
  static String get navEvents => _current.navEvents;
  static String get armed => _current.armed;
  static String get disarmed => _current.disarmed;
  static String get offline => _current.offline;
  static String get engineOff => _current.engineOff;
  static String get engineOn => _current.engineOn;
  static String get doorsClosed => _current.doorsClosed;
  static String get doorsOpen => _current.doorsOpen;
  static String get statusOnline => _current.statusOnline;
  static String get battery => _current.battery;
  static String get cabin => _current.cabin;
  static String get engineTemp => _current.engineTemp;
  static String get gsm => _current.gsm;
  static String get disarm => _current.disarm;
  static String get arm => _current.arm;
  static String get start => _current.start;
  static String get stop => _current.stop;
  static String get horn => _current.horn;
  static String get moreCommands => _current.moreCommands;
  static String get quietArm => _current.quietArm;
  static String get quietDisarm => _current.quietDisarm;
  static String get panic => _current.panic;
  static String get valetOn => _current.valetOn;
  static String get valetOff => _current.valetOff;
  static String get valetActive => _current.valetActive;
  static String get comfortCommands => _current.comfortCommands;
  static String get webastoOn => _current.webastoOn;
  static String get webastoOff => _current.webastoOff;
  static String get webastoActive => _current.webastoActive;
  static String get auxOn => _current.auxOn;
  static String get auxOff => _current.auxOff;
  static String get auxActive => _current.auxActive;
  static String get apiBudget => _current.apiBudget;
  static String get updatedAgo => _current.updatedAgo;
  static String get noLink => _current.noLink;
  static String get offlineDetail => _current.offlineDetail;
  static String get checkLink => _current.checkLink;
  static String get checkSim => _current.checkSim;
  static String get disarmTitle => _current.disarmTitle;
  static String get disarmBody => _current.disarmBody;
  static String get disarmConfirm => _current.disarmConfirm;
  static String get startTitle => _current.startTitle;
  static String get startBody => _current.startBody;
  static String get startHold => _current.startHold;
  static String get panicTitle => _current.panicTitle;
  static String get panicBody => _current.panicBody;
  static String get panicConfirm => _current.panicConfirm;
  static String get valetTitle => _current.valetTitle;
  static String get valetBody => _current.valetBody;
  static String get valetConfirm => _current.valetConfirm;
  static String get webastoTitle => _current.webastoTitle;
  static String get webastoBody => _current.webastoBody;
  static String get webastoConfirm => _current.webastoConfirm;
  static String get auxTitle => _current.auxTitle;
  static String get auxBody => _current.auxBody;
  static String get auxConfirm => _current.auxConfirm;
  static String get cancel => _current.cancel;
  static String get lastPoint => _current.lastPoint;
  static String get refreshPosition => _current.refreshPosition;
  static String get tracksTitle => _current.tracksTitle;
  static String get tracksEmpty => _current.tracksEmpty;
  static String get tracksLoad => _current.tracksLoad;
  static String get tracksHide => _current.tracksHide;
  static String get tracksShow => _current.tracksShow;
  static String get tracksRefresh => _current.tracksRefresh;
  static String get tracksThrottle => _current.tracksThrottle;
  static String get tracksBudgetHint => _current.tracksBudgetHint;
  static String get trackMileage => _current.trackMileage;
  static String get trackDuration => _current.trackDuration;
  static String get geofencesTitle => _current.geofencesTitle;
  static String get geofencesHint => _current.geofencesHint;
  static String get geofencesEmpty => _current.geofencesEmpty;
  static String get geofenceAdd => _current.geofenceAdd;
  static String get geofenceEdit => _current.geofenceEdit;
  static String get geofenceNameHint => _current.geofenceNameHint;
  static String get geofenceRadius => _current.geofenceRadius;
  static String get geofenceSave => _current.geofenceSave;
  static String get geofenceDelete => _current.geofenceDelete;
  static String get geofenceEnabled => _current.geofenceEnabled;
  static String get geofenceEnter => _current.geofenceEnter;
  static String get geofenceExit => _current.geofenceExit;
  static String get geofencesHide => _current.geofencesHide;
  static String get geofencesShow => _current.geofencesShow;
  static String get geofenceAlertEnter => _current.geofenceAlertEnter;
  static String get geofenceAlertExit => _current.geofenceAlertExit;
  static String get geofencesDemoSeed => _current.geofencesDemoSeed;
  static String get obdTitle => _current.obdTitle;
  static String get obdSection => _current.obdSection;
  static String get obdFuel => _current.obdFuel;
  static String get obdMileage => _current.obdMileage;
  static String get obdErrors => _current.obdErrors;
  static String get obdUnsupported => _current.obdUnsupported;
  static String get obdRefresh => _current.obdRefresh;
  static String get obdEmpty => _current.obdEmpty;
  static String get obdDemoHint => _current.obdDemoHint;
  static String get eventsTitle => _current.eventsTitle;
  static String get filterAll => _current.filterAll;
  static String get filterAlarms => _current.filterAlarms;
  static String get filterCommands => _current.filterCommands;
  static String get today => _current.today;
  static String get settingsTitle => _current.settingsTitle;
  static String get theme => _current.theme;
  static String get themeValue => _current.themeValue;
  static String get themeSheetTitle => _current.themeSheetTitle;
  static String get themeNightDrive => _current.themeNightDrive;
  static String get themeNightDriveHint => _current.themeNightDriveHint;
  static String get themeSystem => _current.themeSystem;
  static String get themeSystemHint => _current.themeSystemHint;
  static String get themeDayMetal => _current.themeDayMetal;
  static String get themeDayMetalHint => _current.themeDayMetalHint;
  static String get themeClose => _current.themeClose;
  static String get language => _current.language;
  static String get languageSheetTitle => _current.languageSheetTitle;
  static String get languageRu => _current.languageRu;
  static String get languageRuHint => _current.languageRuHint;
  static String get languageEn => _current.languageEn;
  static String get languageEnHint => _current.languageEnHint;
  static String get apiLimit => _current.apiLimit;
  static String get simBalance => _current.simBalance;
  static String get simBalanceEmpty => _current.simBalanceEmpty;
  static String get simBalanceDemoHint => _current.simBalanceDemoHint;
  static String get devices => _current.devices;
  static String get about => _current.about;
  static String get aboutValue => _current.aboutValue;
  static String get logout => _current.logout;
  static String get rateLimitBadge => _current.rateLimitBadge;
  static String get rateLimitTitle => _current.rateLimitTitle;
  static String get rateLimitBody => _current.rateLimitBody;
  static String get rateLimitCta => _current.rateLimitCta;
  static String get menuDevices => _current.menuDevices;
  static String get menuSettings => _current.menuSettings;
  static String get commandPending => _current.commandPending;
  static String get commandOk => _current.commandOk;
  static String get commandFail => _current.commandFail;
  static String get captchaTitle => _current.captchaTitle;
  static String get captchaBody => _current.captchaBody;
  static String get captchaSmsBody => _current.captchaSmsBody;
  static String get captchaHint => _current.captchaHint;
  static String get continueLabel => _current.continueLabel;
  static String get resendCode => _current.resendCode;
  static String get resendCodeNow => _current.resendCodeNow;
  static String get backToLogin => _current.backToLogin;
  static String get budgetNearBanner => _current.budgetNearBanner;
  static String get budgetHomeLabel => _current.budgetHomeLabel;
  static String get demoCaptchaHint => _current.demoCaptchaHint;
  static String get apiBudgetLabel => _current.apiBudgetLabel;
  static String get simNoData => _current.simNoData;
  static String get obdNoErrors => _current.obdNoErrors;
  static String get obdErrorOne => _current.obdErrorOne;
  static String get obdErrorFew => _current.obdErrorFew;
  static String get obdErrorMany => _current.obdErrorMany;
  static String get obdFuelPart => _current.obdFuelPart;
  static String get obdMileagePart => _current.obdMileagePart;
  static String get obdLitres => _current.obdLitres;
  static String get obdKm => _current.obdKm;
  static String get demoUnavailable => _current.demoUnavailable;
}

