# Sexy Starline

Flutter MVP для владельца StarLine: статус охраны, команды, карта, журнал событий.  
Дизайн: **Night Drive** (графит `#0B0E12`, cyan `#3DDBD9`, amber `#F0A04B`).  
Стек: Riverpod · go_router · dio · flutter_secure_storage · Drift · flutter_map.

> Секреты `AppId` / `AppSecret` **никогда** не коммитятся. Без credentials приложение стартует в **демо-режиме** (mock).

## Требования

- Flutter 3.35+ / Dart 3.9+
- iOS 13+ / Android 7+ (API 24+)

## Быстрый старт (демо)

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

На экране логина нажмите **«Продолжить в демо»** или войдите любым логином — без `STARLINE_APP_*` клиент использует mock.

Демо captcha / SMS (Night Drive UI):

| Логин | Пароль | Код |
|-------|--------|-----|
| `captcha` | любой | `1234` или `star` |
| `sms` | любой | `1234` |

## Реальный StarLine Open API

Передайте credentials через `--dart-define` (или CI secrets):

```bash
flutter run \
  --dart-define=STARLINE_APP_ID=your_app_id \
  --dart-define=STARLINE_APP_SECRET=your_app_secret
```

Опционально:

| Define | Назначение | Default |
|--------|------------|---------|
| `STARLINE_DEMO=true` | Принудительный mock | `false` |
| `STARLINE_SLID_BASE` | SLID host | `https://id.starline.ru` |
| `STARLINE_API_BASE` | WebAPI host | `https://developer.starline.ru` |

См. также [`.env.example`](./.env.example) — шаблон для локальных env (не для коммита значений).

## Архитектура

```
lib/
  presentation/   # экраны, виджеты, shell (bottom nav)
  application/    # Riverpod controllers (auth, home)
  domain/         # Device, DeviceState, Event, Command, Session
  data/
    remote/       # StarlineApiClient (SLID → slnet + WebAPI)
    local/        # SecureSessionStore, Drift AppDatabase
    repositories/ # кэш + budget + rate-limit
    mock/         # демо-каталог
  core/           # theme Night Drive, router, Env, RU strings
```

### Auth / API

Цепочка как в официальных скриптах NPO / pystarline:

1. `GET /apiV3/application/getCode/` → `desc.code` (`secret=md5(appSecret)`)
2. `GET /apiV3/application/getToken/` → `desc.token` (`secret=md5(appSecret+code)`)
3. `POST /apiV3/user/login/?token=…` (form: `login`, `pass=sha1`) → `desc.user_token`; captcha/SMS при необходимости
4. `POST /json/v2/auth.slid` `{slid_token}` → cookie `slnet` + `user_id`
5. WebAPI: `Cookie: slnet=…` (Dio interceptor)
6. HTTP **429** → UI «Лимит запросов» + Drift/memory cache; **401** → re-login
7. Offline авто — first-class статус на Home
8. Captcha / SMS: отдельный экран «Подтверждение входа» (4 слота, resend с таймером)

Парсеры вынесены в `StarlineMappers` (покрыты unit-тестами).

### Бюджет запросов (~1000 / сутки)

Open API лимит: **~1000 req/user/day**. Клиент честно учитывает расход и не обещает realtime.

| Триггер | Поведение |
|---------|-----------|
| Foreground Home | Авто-poll **120 с** (диапазон политики **90–180 с**) |
| Близко к лимиту (≥80%) | Интервал тянется до **180 с** + amber-баннер |
| Остаток ≤50 или 1000/1000 | Авто-poll стоп; pull-to-refresh / команды по ситуации |
| Pull-to-refresh | Force refresh активного устройства (1 req) |
| Resume приложения | Refresh, если снимок старше интервала |
| HTTP 429 | Экран «Лимит запросов», работа с кэшем Drift/memory |
| Счётчик | Drift `api_usage` по календарному дню; Home / Settings показывают `~N / 1000` |

Целевой спокойный день (1 авто): порядка **100–300 req**. Poll только **активного** устройства.

Реализация: `PollPolicy` + `HomeController` timer / lifecycle; `AppDatabase.incrementRequestCount` на каждый WebAPI/SLID вызов.

### Навигация

`Splash` → `Login` → [`Captcha` / SMS] → `Devices` → Shell (`Home` / `Map` / `Events`)  
Settings / Devices — из overflow Home.

### Команды (`set_param`)

Тело как в Home Assistant / pystarline: `{"type": "<name>", "<name>": 0|1}`

| UI | param |
|----|--------|
| Поставить / снять охрану | `arm` 1/0 |
| Тихая охрана | `arm_quiet` 1/0 |
| Запуск / стоп | `ign` 1/0 |
| Сигнал | `poke` 1 |
| Паника / сервис | `panic` / `valet` |
| Webasto / доп. канал | `webasto` / `out` 1/0 |

- Disarm — явный confirm; Start — hold ≥1.2 с; Webasto/AUX on — confirm
- `CommandGate` / `CommandPipeline` гейтят по `controls`/`functions` (comfort — только при явном capability)
- Клиентские геозоны: локальный CRUD + круги на карте; алерты по GPS из Home-poll (**0** доп. req к StarLine)

## Экраны MVP

Login · Devices · Home (статус + команды) · Map · Events · Settings · confirm sheets · 429 · offline

## Тесты

```bash
flutter test
flutter analyze
```

## Идентификаторы / Store prep

Канонические defaults (ещё **не** зарегистрированы в Play / App Store — placeholders до вашей публикации):

| Платформа | Поле | Значение |
|-----------|------|----------|
| Общее | Display name | `Sexy Starline` |
| Общее | Версия | `pubspec.yaml` → `0.1.0+1` (`versionName`/`CFBundleShortVersionString` = `0.1.0`, `versionCode`/`CFBundleVersion` = `1`) |
| Android | `applicationId` / `namespace` | `ru.sexystarline.app` |
| iOS | `PRODUCT_BUNDLE_IDENTIFIER` | `ru.sexystarline.app` |
| iOS tests | Bundle id | `ru.sexystarline.app.RunnerTests` |

Иконки: Night Drive placeholders (графит + cyan diamond BrandMark) — Android adaptive (`mipmap-anydpi-v26`) + legacy mipmaps; iOS `AppIcon.appiconset`. Мастера: [`assets/branding/`](./assets/branding/). Splash: графит `#0B0E12` + mark (Android `launch_background`, iOS `LaunchScreen`).

**Не** публикуем в Play / App Store из этого репо без явного согласия владельца. Credentials Apple/Google **не** хранятся и **не** выдумываются.

### Локальная сборка APK (Android)

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# Debug / unsigned-style local release (debug keystore, если нет key.properties)
flutter build apk --release

# С реальных StarLine credentials (опционально):
flutter build apk --release \
  --dart-define=STARLINE_APP_ID=your_app_id \
  --dart-define=STARLINE_APP_SECRET=your_app_secret
```

Артефакт: `build/app/outputs/flutter-apk/app-release.apk`.

App Bundle для Play (когда будете готовы сами):

```bash
flutter build appbundle --release
```

Подпись release (вы должны поставить сами):

1. Создайте upload keystore (`keytool -genkey …`) — файл `.jks` / `.keystore` **не** коммитить.
2. `cp android/key.properties.example android/key.properties` и заполните пути/пароли.
3. `android/key.properties`, `*.jks`, `*.keystore` уже в `.gitignore`.

Без `key.properties` release подписывается **debug**-ключом (удобно для локальной проверки; для Play нужен ваш upload key).

### Локальная сборка IPA (iOS)

Нужны **macOS + Xcode** и ваш Apple Developer аккаунт (мы его не создаём и не подставляем):

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter build ipa --release \
  --dart-define=STARLINE_APP_ID=your_app_id \
  --dart-define=STARLINE_APP_SECRET=your_app_secret
```

Либо откройте `ios/Runner.xcworkspace` в Xcode → Signing & Capabilities → выберите Team / provisioning.

Артефакт: `build/ios/ipa/*.ipa` (или Archive в Organizer).

### Что пользователь должен поставить позже (секреты / сертификаты)

| Секрет | Где | Примечание |
|--------|-----|------------|
| `STARLINE_APP_ID` / `STARLINE_APP_SECRET` | `--dart-define` или CI secrets | Уже выданы StarLine; **не** в git |
| Android upload keystore + `android/key.properties` | Локально / CI | Для Play upload; см. `key.properties.example` |
| Play Console аккаунт / service account | У владельца | Только при явной публикации |
| Apple Developer Team ID, distribution cert, provisioning profile | Keychain / Xcode / CI | Bundle id `ru.sexystarline.app` должен быть зарегистрирован у вас |
| App Store Connect API key (опционально для CI) | CI secrets | Не коммитить |
| Push (FCM / APNs) | После MVP | Не в этом prep |

## Лицензия / политика API

Owner-only, некоммерческий StarLine Open API (~1000 req/сутки).  
Публикация «для всех владельцев» может потребовать отдельный договор со StarLine.  
Публикация в App Store / Google Play — **только** после явного согласия владельца.
