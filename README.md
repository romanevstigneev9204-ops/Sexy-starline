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

Цепочка как в официальных скриптах NPO / pystarline:

1. `GET /apiV3/application/getCode/` → `desc.code` (`secret=md5(appSecret)`)
2. `GET /apiV3/application/getToken/` → `desc.token` (`secret=md5(appSecret+code)`)
3. `POST /apiV3/user/login/?token=…` (form: `login`, `pass=sha1`) → `desc.user_token`; captcha/SMS при необходимости
4. `POST /json/v2/auth.slid` `{slid_token}` → cookie `slnet` + `user_id`
5. WebAPI: `Cookie: slnet=…` (Dio interceptor)
6. HTTP **429** → UI «Лимит запросов» + Drift/memory cache; **401** → re-login
7. Offline авто — first-class статус на Home

Парсеры вынесены в `StarlineMappers` (покрыты unit-тестами).

### Навигация

`Splash` → `Login` → [`Captcha`] → `Devices` → Shell (`Home` / `Map` / `Events`)  
Settings / Devices — из overflow Home.

### Команды (`set_param`)

Тело как в Home Assistant / pystarline: `{"type": "<name>", "<name>": 0|1}`

| UI | param |
|----|--------|
| Поставить / снять охрану | `arm` 1/0 |
| Запуск / стоп | `ign` 1/0 |
| Сигнал | `poke` 1 |

- Disarm — явный confirm; Start — hold ≥1.2 с
- `CommandGate` / `CommandPipeline` гейтят по `controls`/`functions`

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
