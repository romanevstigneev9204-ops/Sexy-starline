/// Russian UI copy for MVP (no EN locale yet).
abstract final class S {
  static const appName = 'SEXY STARLINE';
  static const brandMark = 'Sexy Starline';

  // Login
  static const loginTitle = 'Контроль охраны';
  static const loginSubtitle =
      'Войдите через StarLine ID, чтобы видеть статус и команды своего авто.';
  static const loginHint = 'Логин StarLine ID';
  static const passwordHint = 'Пароль';
  static const loginCta = 'Войти';
  static const loginFooter =
      'Поддерживается captcha / SMS, если потребует SLID';
  static const demoBanner =
      'Демо-режим: нет AppId/Secret. UI работает на mock-данных.';
  static const loginDemoCta = 'Продолжить в демо';

  // Devices
  static const devicesTitle = 'Ваши устройства';
  static const devicesSubtitle =
      'Выберите основное авто для Home и команд.';
  static const devicePrimary = 'Основное';
  static const sharedReadonly = 'Общий доступ (read-only)';
  static const sharedFromOnline = 'шаринг из StarLine Online';

  // Home
  static const navHome = 'Главная';
  static const navMap = 'Карта';
  static const navEvents = 'События';
  static const armed = 'НА ОХРАНЕ';
  static const disarmed = 'СНЯТО С ОХРАНЫ';
  static const offline = 'ОФЛАЙН';
  static const engineOff = 'Двигатель выкл.';
  static const engineOn = 'Двигатель вкл.';
  static const doorsClosed = 'Двери закрыты';
  static const doorsOpen = 'Двери открыты';
  static const statusOnline = 'Online';
  static const battery = 'АКБ';
  static const cabin = 'Салон';
  static const engineTemp = 'Двиг.';
  static const gsm = 'GSM';
  static const disarm = 'Снять с охраны';
  static const arm = 'Поставить на охрану';
  static const start = 'Запуск';
  static const stop = 'Стоп';
  static const horn = 'Сигнал';
  static const moreCommands = 'Дополнительно';
  static const quietArm = 'Тихая охрана';
  static const quietDisarm = 'Тихо снять';
  static const panic = 'Паника';
  static const valetOn = 'Сервисный режим';
  static const valetOff = 'Выйти из сервиса';
  static const valetActive = 'Сервисный режим включён';
  static const comfortCommands = 'Комфорт';
  static const webastoOn = 'Включить Webasto';
  static const webastoOff = 'Выключить Webasto';
  static const webastoActive = 'Webasto включён';
  static const auxOn = 'Доп. канал вкл.';
  static const auxOff = 'Доп. канал выкл.';
  static const auxActive = 'Доп. канал включён';
  static const apiBudget = 'Бюджет API';
  static const updatedAgo = 'Обновлено';
  static const noLink = 'Нет связи с авто';
  static const offlineDetail =
      'Последний снимок {mins} мин назад. Команды могут не дойти.';
  static const checkLink = 'Проверить связь';
  static const checkSim = 'Проверьте баланс SIM и покрытие GSM.';

  // Confirm
  static const disarmTitle = 'Снять с охраны?';
  static const disarmBody =
      'Двери разблокируются. Подтвердите, если вы рядом с авто.';
  static const disarmConfirm = 'Да, снять с охраны';
  static const startTitle = 'Запустить двигатель?';
  static const startBody =
      'Команда уйдёт в StarLine. Убедитесь, что авто в безопасном месте.';
  static const startHold = 'Удерживайте, чтобы запустить';
  static const panicTitle = 'Включить панику?';
  static const panicBody =
      'Сирена и световые сигналы. Используйте только при реальной угрозе.';
  static const panicConfirm = 'Да, паника';
  static const valetTitle = 'Включить сервисный режим?';
  static const valetBody =
      'Охрана и автозапуск будут ограничены. Нужно для сервиса или мойки.';
  static const valetConfirm = 'Включить сервис';
  static const webastoTitle = 'Включить Webasto?';
  static const webastoBody =
      'Подогреватель салона/двигателя получит команду. Убедитесь, что это безопасно.';
  static const webastoConfirm = 'Да, включить Webasto';
  static const auxTitle = 'Включить доп. канал?';
  static const auxBody =
      'Дополнительный канал (AUX/out) переключится. Проверьте, что подключено к каналу.';
  static const auxConfirm = 'Да, включить канал';
  static const cancel = 'Отмена';

  // Map
  static const lastPoint = 'Последняя точка';
  static const refreshPosition = 'Обновить позицию';
  static const tracksTitle = 'Треки за сегодня';
  static const tracksEmpty = 'Нет поездок за выбранный период';
  static const tracksLoad = 'Показать треки';
  static const tracksHide = 'Скрыть трек';
  static const tracksShow = 'Показать трек';
  static const tracksRefresh = 'Обновить треки';
  static const tracksThrottle =
      'Треки обновляются не чаще раза в 10 мин (лимит StarLine /ways).';
  static const tracksBudgetHint =
      'Запрос трека расходует бюджет API · период ≤ 24 ч';
  static const trackMileage = 'Пробег';
  static const trackDuration = 'В пути';

  // Geofences (client-side)
  static const geofencesTitle = 'Геозоны';
  static const geofencesHint =
      'Локальные зоны на устройстве. Алерты по позиции из опроса Home — без API геозон StarLine.';
  static const geofencesEmpty = 'Нет геозон — добавьте вокруг текущего авто';
  static const geofenceAdd = 'Добавить геозону';
  static const geofenceEdit = 'Геозона';
  static const geofenceNameHint = 'Название';
  static const geofenceRadius = 'Радиус, м';
  static const geofenceSave = 'Сохранить';
  static const geofenceDelete = 'Удалить';
  static const geofenceEnabled = 'Включена';
  static const geofenceEnter = 'Вход';
  static const geofenceExit = 'Выход';
  static const geofencesHide = 'Скрыть зоны';
  static const geofencesShow = 'Показать зоны';
  static const geofenceAlertEnter = 'Вход в геозону';
  static const geofenceAlertExit = 'Выход из геозоны';
  static const geofencesDemoSeed = 'Демо: Дом и Офис около Лесной';

  // OBD
  static const obdTitle = 'OBD';
  static const obdSection = 'Диагностика OBD';
  static const obdFuel = 'Топливо';
  static const obdMileage = 'Пробег';
  static const obdErrors = 'Ошибки';
  static const obdUnsupported = 'OBD недоступен на этом устройстве';
  static const obdRefresh = 'Обновить OBD';
  static const obdEmpty = 'Нет данных OBD';
  static const obdDemoHint = 'Демо-данные';

  // Events
  static const eventsTitle = 'Журнал событий';
  static const filterAll = 'Все';
  static const filterAlarms = 'Тревоги';
  static const filterCommands = 'Команды';
  static const today = 'Сегодня';

  // Settings
  static const settingsTitle = 'Настройки';
  static const theme = 'Тема';
  static const themeValue = 'Night Drive';
  static const themeSheetTitle = 'Тема оформления';
  static const themeNightDrive = 'Night Drive';
  static const themeNightDriveHint = 'Графит · cyan · amber (текущая)';
  static const themeSystem = 'Системная';
  static const themeSystemHint =
      'Следует системной схеме; пока всегда Night Drive';
  static const themeDayMetal = 'Day Metal';
  static const themeDayMetalHint = 'Скоро — светлая тема';
  static const themeClose = 'Готово';
  static const apiLimit = 'Лимит API';
  static const simBalance = 'Баланс SIM';
  static const simBalanceEmpty = 'Нет данных от StarLine';
  static const simBalanceDemoHint = 'Демо-данные';
  static const devices = 'Устройства';
  static const about = 'О приложении';
  static const aboutValue = 'Sexy Starline MVP · owner-only';
  static const logout = 'Выйти из сессии';

  // 429
  static const rateLimitBadge = 'HTTP 429';
  static const rateLimitTitle = 'Лимит\nзапросов';
  static const rateLimitBody =
      'Достигнут дневной лимит StarLine Open API (~1000).\nПоказываем кэш. Обновление — завтра или реже.';
  static const rateLimitCta = 'Понятно, работать с кэшем';

  // Misc
  static const menuDevices = 'Устройства';
  static const menuSettings = 'Настройки';
  static const commandPending = 'Команда отправлена…';
  static const commandOk = 'Готово';
  static const commandFail = 'Не удалось выполнить команду';
  static const captchaTitle = 'Подтверждение входа';
  static const captchaBody =
      'Введите код из SMS или captcha из ответа StarLine ID.';
  static const captchaSmsBody = 'Введите код из SMS, отправленного StarLine ID.';
  static const captchaHint = 'Код из SMS / captcha';
  static const continueLabel = 'Продолжить';
  static const resendCode = 'Отправить код ещё раз';
  static const resendCodeNow = 'Отправить код ещё раз';
  static const backToLogin = 'К экрану входа';
  static const budgetNearBanner =
      'Близко к лимиту API — опрос каждые ~3 мин. Тяните для обновления.';
  static const budgetHomeLabel = 'Бюджет API';
  static const demoCaptchaHint =
      'Демо: логин «captcha» или «sms» + любой пароль → экран подтверждения (код 1234).';
}
