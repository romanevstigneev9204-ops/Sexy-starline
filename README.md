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

1. `getCode` → `getToken` → `user/login` (SHA1 пароля) → `auth.slid` → cookie `slnet`
2. WebAPI ходит с `Cookie: slnet=…` через Dio interceptor
3. Пользовательские токены — только `flutter_secure_storage`
4. HTTP **429** → UI «Лимит запросов» + работа с кэшем
5. Offline авто — first-class статус на Home (не путать с ошибкой сети app)

### Навигация

`Splash` → `Login` → [`Captcha`] → `Devices` → Shell (`Home` / `Map` / `Events`)  
Settings / Devices — из overflow Home.

### Команды

- `arm` / `disarm` / `start` / `stop` / `horn`
- Disarm — явный confirm; Start — hold ≥1.2 с
- Гейт по `controls` / `functions` устройства

## Экраны MVP

Login · Devices · Home (статус + команды) · Map · Events · Settings · confirm sheets · 429 · offline

## Тесты

```bash
flutter test
flutter analyze
```

## Лицензия / политика API

Owner-only, некоммерческий StarLine Open API (~1000 req/сутки).  
Публикация «для всех владельцев» может потребовать отдельный договор со StarLine.
