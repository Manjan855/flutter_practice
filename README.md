# flutter_practice — Vehicle Booking (Flutter)

A vehicle-rental demo app built with Clean Architecture, Firebase auth, an
offline-first catalogue, Nepali payment gateways (Khalti / eSewa) and PDF
receipts.

|                     |                                                              |
| ------------------- | ------------------------------------------------------------ |
| Package name        | `flutter_practice` (folder is `flutter_application_1`)        |
| State management    | Riverpod 3                                                   |
| Routing             | `go_router` with an auth guard                                |
| Error handling      | `dartz` — `Either<Failures, T>` (no exceptions cross layers)  |
| Auth                | Firebase (email/password, Google, Facebook)                  |
| Local storage       | `sqflite` catalogue cache                                    |
| Payments            | Khalti ePayment, eSewa v2                                     |
| Tests               | 30 passing (`flutter test`)                                  |
| Analyzer            | 0 issues (`flutter analyze`)                                 |

---

## Quick start

```bash
flutter pub get
flutter run
```

That is enough — `.env` ships with safe development defaults, so a fresh clone
builds and runs with no extra setup.

### Run against your own backend

```bash
flutter run --dart-define=API_BASE_URL=http://<your-ip>:8000
```

### Run on a physical Android device

There is no hosted API behind this app, so a local seed server stands in for it:

```bash
# terminal 1 — serves GET /vehicles with 8 sample vehicles on 0.0.0.0:8000
dart run tool/seed_backend.dart

# terminal 2 — launch on the connected device
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

**Use `127.0.0.1`, not your LAN IP.** On Windows the firewall may hold inbound
`Block` rules for `dartvm.exe` (the process that serves port 8000), so a phone
on the same Wi-Fi will time out against `http://<pc-ip>:8000` even though the
server is listening. Tunnel the port through adb instead — this needs no admin
rights and no firewall changes:

```bash
adb reverse tcp:8000 tcp:8000   # device localhost:8000 -> host :8000
adb reverse --list              # verify
```

If you would rather use the LAN address (so devices without an adb connection
work too), add an inbound allow rule for TCP 8000 from an elevated shell:

```powershell
New-NetFirewallRule -DisplayName "Flutter seed backend" -Direction Inbound `
  -Protocol TCP -LocalPort 8000 -Action Allow -Profile Private
```

> `adb reverse` must be re-run every time the device reconnects.

### Run tests / analyzer

```bash
flutter analyze          # expect: No issues found!
flutter test             # expect: All tests passed
```

---

## Configuration

Every value resolves through the same three-layer precedence:

1. `--dart-define` compile-time flag — wins for CI / release builds
2. `.env` file — wins for local development
3. Built-in development default — last resort, app still starts

Nothing in `lib/features/**` hardcodes a URL or a key; everything reads
`AppConfig` (`lib/core/config/app_config.dart`).

| Key                 | Purpose                             | Default                                  |
| ------------------- | ----------------------------------- | ---------------------------------------- |
| `API_BASE_URL`      | Base URL of the products API        | `http://192.168.18.237:8000`               |
| `KHALTI_PUBLIC_KEY` | Khalti public key                   | *(empty → Khalti disabled in the UI)*     |
| `KHALTI_BASE_URL`   | Khalti API root                     | `https://aapi.khalti.com/api/v2`          |
| `ESEWA_SECRET_KEY`  | eSewa signing secret                | eSewa's public RC/test secret             |
| `ESEWA_PRODUCT_CODE`| eSewa product code                  | `EPAYTEST`                                |
| `ESEWA_USE_DEV_MODE`| `true` = RC gateway                 | `true`                                    |
| `FACEBOOK_APP_ID`   | Facebook App ID                     | `1741378883552772` (your app)              |
| `FACEBOOK_CLIENT_TOKEN` | Facebook Client Token           | matches `values/strings.xml`              |
| `ENABLE_HTTP_LOGGING` | `LogInterceptor` response bodies  | `false`                                   |

See `.env.example` for the full annotated list.

### Why these files are committed

Flutter can only read files listed under `flutter:` → `assets:` in
`pubspec.yaml`, and a missing asset **fails the build**. Likewise
`AndroidManifest.xml` hard-references `@string/facebook_app_id` and
`@string/facebook_client_token`, so `values/strings.xml` must exist on a fresh
clone.

That is why `.env`, `values/strings.xml` and `.env.example` are all committed.
None of them hold a genuine secret:

- Facebook App ID / Client Token are public-by-design (they ship inside every
  app binary — they only restrict *which* app may call the API).
- `ESEWA_SECRET_KEY` is eSewa's publicly documented RC/test secret.
- `API_BASE_URL` is a development address.

Genuinely sensitive material stays git-ignored:

- `android/app/google-services.json` — Firebase
- `ios/Runner/GoogleService-Info.plist` — Firebase
- `android/key.properties`, `*.jks`, `*.keystore` — signing keys

and production values are injected at build time with `--dart-define`, which
always wins over `.env`.

---

## Feature flags you must opt into

### Facebook login

`AndroidManifest.xml` references `@string/facebook_app_id` and
`@string/facebook_client_token`, which live in
`android/app/src/main/res/values/strings.xml` alongside the same values in
`.env` and `ios/Runner/Info.plist` (all three are kept in sync).

The values configured by default point at the Facebook app this project was
developed against. To use your own, replace them in all three places.

`AuthRepositoryImpl.signInWithFacebook` fails fast with an actionable message
if `FACEBOOK_APP_ID` / `FACEBOOK_CLIENT_TOKEN` are ever blanked out — no
native SDK call is attempted.

### Khalti

Set `KHALTI_PUBLIC_KEY` in `.env`. Until then the checkout screen disables the
Khalti button and explains what is missing instead of failing obscurely.

Environment is chosen automatically: a key starting with `live_` runs against
Khalti production, anything else runs against `test`.

### eSewa

Works out of the box against the RC/test gateway. Switch to production with
`ESEWA_USE_DEV_MODE=false` plus a live `ESEWA_SECRET_KEY`.

### iOS Google Sign-In

`ios/Runner/Info.plist` declares `CFBundleURLSchemes` with the reversed iOS
OAuth client ID from `lib/firebase_options.dart`. **This has not been verified
on a device** — iOS builds require macOS. See "Known gaps" below.

---

## Architecture

```
lib/
├── app_theme/                    # text styles, theming
├── core/
│   ├── config/app_config.dart    # 3-layer config resolution (single source of truth)
│   ├── database/app_database.dart# sqflite schema
│   ├── errors/failures.dart      # Failures: Server / Auth / Cache
│   ├── network/dio_client.dart   # Dio factories (products API + Khalti)
│   ├── network/khalti_service.dart
│   └── router/app_router.dart    # AppRoute constants + GoRouter + guards
├── features/
│   ├── auth/
│   │   ├── data/                 # repository impl, mappers
│   │   ├── domain/               # entities + repository contract
│   │   └── presentation/         # login, sign-up screens, providers
│   └── products/
│       ├── data/                 # remote + local datasources, model, repository impl
│       ├── domain/               # entities + repository contract
│       └── presentation/         # list, payment, eSewa screens, receipt services
├── models/                       # UserModels (KYC payload)
└── screens/                      # app shell: home (dashboard), KYC review
```

**Rules the codebase follows**

- Presentation depends only on `domain` contracts, never on `data`.
- Repositories return `Either<Failures, T>`; the UI must fold both branches.
- Navigate with `AppRoute` constants, never raw strings.
  (Raw strings were the cause of the `/products` and `/esewa-payment` 404s.)
- Routes that need an object read `state.extra`; if it is missing they show a
  recovery screen instead of throwing.

### Routes

| Path            | Screen             | Payload               |
| --------------- | ------------------ | --------------------- |
| `/login`        | `LoginScreen`      | —                     |
| `/signup`       | `SignUpScreen`     | —                     |
| `/home`         | `HomeScreen`       | —                     |
| `/kyc`          | `KycScreen`        | `UserModels`          |
| `/product`      | `ProductListScreen`| —                     |
| `/payment`      | `PaymentScreen`    | `ProductEntity`       |
| `/esewascreen`  | `EsewaPaymentScreen` | `ProductEntity`     |

Unknown locations render a "Page not found" screen with a route home.

### Payment flow

```
ProductListScreen  ──tap──▶  PaymentScreen (vehicle in `extra`)
                              ├─ Pay with Khalti  ─▶ /payment/initialize/ ─▶ Khalti checkout SDK
                              └─ Pay with eSewa   ─▶ EsewaPaymentScreen
                                                   └─ on success: decode base64 response,
                                                      save receipt PDF, open print/share sheet
```

Receipts are produced by `ReceiptGenerator` (pure PDF) and persisted by
`ReceiptSaver` (`getApplicationCacheDirectory()` + `Printing.layoutPdf`).

---

## Tests

```
test/
├── features/auth/data/auth_repository_impl_test.dart
│     signIn success / wrong-password, signUp (+display-name path),
│     Facebook not-configured guard, mapAuthError coverage
└── features/products/
    ├── data/models/product_model_test.dart
    │     JSON coercion, missing-id rejection, sqflite row round trip
    └── data/repositories/product_repository_impl_test.dart
          happy path + cache write, offline cache fallback,
          network failure with empty cache, HTTP 500, unexpected error
```

---

## Known gaps

- **iOS is unverified.** This project is developed on Windows, where iOS
  cannot be built. `Info.plist` changes are best-effort.
- **Payment is client-side.** Both gateways are initialised from the app. For
  production, proxy `/payment/initialize/` through your own backend
  (`KHALTI_BASE_URL` lets you point at it) so keys never ship in the binary,
  and verify server-side before fulfilling a booking.
- **No automated UI/integration tests.** Unit coverage is repository- and
  model-level.
- **Practice scratch code is intentionally retained** in `lib/screens/`
  (`main_screen.dart`, `display_screen.dart`, `product_screen.dart`,
  `error_screen.dart`, `facebook_login.dart`), `lib/buttons/` and
  `lib/new_class.dart`. It is unreachable from the router and kept as a
  learning reference.
