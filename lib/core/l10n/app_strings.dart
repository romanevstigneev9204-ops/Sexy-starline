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
      'Команда уйдет в StarLine. Убедитесь, что авто в безопасном месте.';
  static const startHold = 'Удерживайте, чтобы запустить';
  static const cancel = 'Отмена';

  // Map
  static const lastPoint = 'Последняя точка';
  static const refreshPosition = 'Обновить позицию';

  // Events
  static const eventsTitle = 'Журнал событий';
  static const filterAll = 'Все';
  static const filterAlarms = 'Тревоги';
  static const filterCommands = 'Команды';
  static const today = 'Сегодня';

  // Settings
  static const settingsTitle = 'Настройки';
  static const theme = 'Тема';
  static const themeValue = 'Системная (Night Drive / Day Metal)';
  static const apiLimit = 'Лимит API';
  static const devices = 'Устройства';
  static const about = 'О приложении';
  static const aboutValue = 'Sexy Starline MVP · owner-only';
  static const logout = 'Выйти из сессии';

  // 429
  static const rateLimitBadge = 'HTTP 429';
  static const rateLimitTitle = 'Лимит запросов';
  static const rateLimitBody =
      'Достигнут дневной лимит StarLine Open API (~1000). Показываем кэш. Обновление — завтра или реже.';
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
