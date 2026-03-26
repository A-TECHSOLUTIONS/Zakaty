<div align="center">

# ☪️ Zakaty — Full Platform Rewrite Plan

**Flutter Mobile · React Web · ASP.NET Core 8 API · Free SaaS**

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Mobile-Flutter-blue?logo=flutter)](https://flutter.dev)
[![React](https://img.shields.io/badge/Web-React%2018-61DAFB?logo=react)](https://react.dev)
[![ASP.NET Core](https://img.shields.io/badge/API-ASP.NET%20Core%208-512BD4?logo=dotnet)](https://dotnet.microsoft.com)
[![PostgreSQL](https://img.shields.io/badge/DB-PostgreSQL-336791?logo=postgresql)](https://www.postgresql.org)

> Zakaty is a **free SaaS platform** that helps Muslims calculate and track Zakat obligations across money, gold, silver, crops, and business assets — available as a **Flutter mobile app**, a **React web platform**, and a **public/private REST API**.

</div>

---

## 📐 Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                         CLIENTS                             │
│   ┌──────────────────────┐   ┌────────────────────────┐    │
│   │   Flutter Mobile App │   │    React Web Platform  │    │
│   │   (Android / iOS)    │   │  (Public + Dashboard)  │    │
│   └──────────┬───────────┘   └───────────┬────────────┘    │
└──────────────┼───────────────────────────┼─────────────────┘
               └──────────────┬────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    ASP.NET Core 8 API                       │
│  ┌───────────────┐  ┌───────────────┐  ┌────────────────┐  │
│  │  Public API   │  │  Private API  │  │  Admin API     │  │
│  │  /api/v1/pub  │  │  /api/v1/     │  │  /api/v1/admin │  │
│  └───────────────┘  └───────────────┘  └────────────────┘  │
│  ┌──────────────┐   ┌─────────────┐   ┌─────────────────┐  │
│  │  PostgreSQL  │   │    Redis    │   │  Blob Storage   │  │
│  │  (main DB)   │   │  (cache)    │   │  (PDFs/media)   │  │
│  └──────────────┘   └─────────────┘   └─────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 🗂️ Repository Structure (Monorepo)

```
Zakaty/
├── apps/
│   ├── mobile/            ← Flutter app (Android + iOS)
│   ├── web/               ← React 18 + TypeScript (Vite)
│   └── api/               ← ASP.NET Core 8 Web API
├── packages/
│   ├── zakat-core/        ← Shared Dart business-logic package
│   └── zakat-js-sdk/      ← TypeScript SDK for third-party developers
├── infra/                 ← Terraform / Azure Bicep IaC
├── scripts/               ← Developer utility scripts
├── .github/workflows/     ← CI/CD pipelines
└── docs/                  ← API reference, architecture docs
```

---

## 📱 Mobile App — Flutter (`apps/mobile/`)

### Tech Stack

| Concern | Package |
|---|---|
| State management | `flutter_bloc` |
| Navigation | `go_router` |
| HTTP client | `dio` |
| Local storage | `flutter_secure_storage` + `hive` |
| Localization | `flutter_localizations` + `intl` |
| Push notifications | `firebase_messaging` |
| Analytics | `firebase_analytics` |
| PDF export | `pdf` + `printing` |
| Monetization (future) | `in_app_purchase` |

### Screen Map

```
screens/
├── onboarding/        SplashScreen · OnboardingScreen · LanguageSelectScreen
├── auth/              LoginScreen · RegisterScreen · ForgotPasswordScreen
├── dashboard/         DashboardScreen (total due, category cards)
├── zakat/             MoneyZakatScreen · GoldZakatScreen · SilverZakatScreen
│                      CropsZakatScreen · BusinessZakatScreen
├── history/           ZakatHistoryScreen (past calculations, PDF export)
├── prices/            LivePricesScreen (gold/silver live rates)
├── settings/          SettingsScreen
└── about/             AboutScreen
```

### Key Features
- **RTL-first design** — Arabic as default layout, full LTR support
- **Offline-first** — all calculations work without internet, sync on reconnect
- **Dark / Light mode** — respects system preference
- **PDF export** — generate Zakat summary as a shareable PDF
- **Nisab widget** — reusable widget showing current threshold status

---

## 🌐 Web Platform — React (`apps/web/`)

### Tech Stack

| Concern | Library |
|---|---|
| Framework | React 18 + TypeScript |
| Build tool | Vite |
| Routing | React Router v6 |
| Global state | Zustand |
| Server state | TanStack Query (React Query) |
| UI components | shadcn/ui + Tailwind CSS |
| Forms | React Hook Form + Zod |
| Charts | Recharts |
| i18n | i18next + react-i18next |
| PDF generation | `@react-pdf/renderer` |
| Testing | Vitest + React Testing Library |
| E2E testing | Playwright |

### Page Map

```
src/pages/
├── public/         /  (landing) · /calculator · /about · /api-docs · /pricing
│                   /login · /register
└── app/            /dashboard · /calculate/* · /history · /api-keys · /settings
└── admin/          /admin/users · /admin/analytics · /admin/prices
```

---

## 🔌 API — ASP.NET Core 8 (`apps/api/`)

### Tech Stack

| Concern | Technology |
|---|---|
| ORM | Entity Framework Core 8 + PostgreSQL |
| Auth | ASP.NET Core Identity + JWT + API Keys |
| Caching | Redis (`IDistributedCache`) |
| API Docs | Swashbuckle (Swagger UI) + Scalar |
| Validation | FluentValidation |
| Background jobs | Hangfire (price sync) |
| Rate limiting | ASP.NET Core built-in middleware |
| Logging | Serilog → Azure Application Insights |

### Public Endpoints (no auth)

```http
GET  /api/v1/public/nisab        Current Nisab thresholds
GET  /api/v1/public/prices       Gold & silver spot prices
POST /api/v1/public/calculate    Anonymous calculation (rate-limited)
GET  /api/v1/public/health       Health check
```

### Private Endpoints (JWT or API Key)

```http
POST   /api/v1/auth/register
POST   /api/v1/auth/login
POST   /api/v1/auth/refresh-token
POST   /api/v1/auth/logout

POST   /api/v1/zakat/calculate
GET    /api/v1/zakat/history
GET    /api/v1/zakat/history/{id}
DELETE /api/v1/zakat/history/{id}

GET    /api/v1/user/profile
PUT    /api/v1/user/profile
GET    /api/v1/user/api-keys
POST   /api/v1/user/api-keys
DELETE /api/v1/user/api-keys/{id}

GET    /api/v1/subscription/plan
```

### Core Domain Models

| Entity | Key Fields |
|---|---|
| `User` | Id, Email, PasswordHash, PreferredCurrency, Language, Plan |
| `ZakatCalculation` | Id, UserId, Date, CategoryType, Inputs (JSONB), ZakatDue |
| `Price` | Id, AssetType (Gold/Silver), PricePerGram, Currency, FetchedAt |
| `ApiKey` | Id, UserId, KeyHash, Name, Scopes, LastUsedAt, IsActive |
| `Subscription` | Id, UserId, Plan (Free/Premium), StartDate, EndDate |

---

## 💰 SaaS Monetization Model

| Feature | 🆓 Free | ⭐ Premium ($4.99/mo) |
|---|---|---|
| Zakat calculations | Unlimited anonymous | Unlimited + saved |
| Calculation history | — | 5 years rolling |
| API access | 100 req/day | 10,000 req/day |
| PDF export | — | ✅ |
| Multiple profiles (family) | — | Up to 10 |
| Live gold/silver prices | Delayed 24 h | Real-time |
| Custom Nisab currency | — | ✅ |
| White-label embed widget | — | ✅ |
| Priority support | — | ✅ |

> **Future revenue streams:** premium subscriptions, Islamic finance institution API licensing, Zakat distribution partner integrations.

---

## 🔐 Authentication & Security

- **JWT** access tokens (15 min) + refresh tokens (30 days)
- **OAuth2** social login: Google, Apple (required for iOS)
- **API Key** authentication for server-to-server / third-party use
- **Rate limiting** via ASP.NET Core middleware per plan tier
- **Row-level isolation** — users can only access their own data

---

## ☁️ Infrastructure & DevOps

### Cloud (Azure)

| Resource | Purpose |
|---|---|
| Azure Container Apps | API hosting |
| Azure Static Web Apps | React web hosting |
| Azure Database for PostgreSQL | Main database |
| Azure Cache for Redis | Caching layer |
| Azure Blob Storage | PDF / media storage |
| Azure Key Vault | Secrets management |
| Azure Application Insights | Monitoring & logging |

### CI/CD (GitHub Actions)

```
.github/workflows/
├── mobile-ci.yml     Flutter test + build APK/IPA on PR
├── web-ci.yml        React lint + test + build on PR
├── api-ci.yml        .NET build + test + Docker push on PR
├── mobile-cd.yml     Deploy to Play Store / App Store on tag
├── web-cd.yml        Deploy to Azure Static Web Apps on main
└── api-cd.yml        Deploy to Azure Container Apps on main
```

---

## 🗺️ Implementation Roadmap

### Phase 1 — Foundation (Weeks 1–3)
- [ ] Initialize monorepo structure
- [ ] Scaffold Flutter app (`flutter create`)
- [ ] Scaffold React app (`npm create vite@latest`)
- [ ] Scaffold ASP.NET Core 8 API (`dotnet new webapi`)
- [ ] Set up PostgreSQL schema with EF Core migrations
- [ ] Implement JWT authentication (register / login / refresh)
- [ ] Port core Zakat business logic (Dart package + C# API)

### Phase 2 — Core Features (Weeks 4–7)
- [ ] Flutter: All Zakat calculation screens (Money, Gold, Silver, Crops, Business)
- [ ] Flutter: Dashboard + calculation history screen
- [ ] React: Public anonymous calculator page
- [ ] React: Authenticated user dashboard
- [ ] API: Public + private Zakat calculation endpoints
- [ ] API: Gold/silver price background job (Hangfire)
- [ ] API: Calculation history CRUD endpoints

### Phase 3 — SaaS Layer (Weeks 8–10)
- [ ] User registration + profile management
- [ ] API key generation and management
- [ ] Subscription / plan gating (free tier enforcement)
- [ ] React: Pricing page + upgrade flow
- [ ] Flutter: Premium feature gates (soft paywall UI)
- [ ] Rate limiting middleware on API

### Phase 4 — Polish & Localization (Weeks 11–13)
- [ ] Arabic (RTL) + English localization in Flutter and React
- [ ] PDF export in Flutter (`pdf` package) and React (`@react-pdf/renderer`)
- [ ] Dark mode support in Flutter
- [ ] Responsive design in React (mobile, tablet, desktop)
- [ ] Onboarding flow in Flutter (3-step intro)
- [ ] Marketing landing page in React

### Phase 5 — Testing & QA (Weeks 13–15)
- [ ] Flutter unit + widget tests (`flutter_test`)
- [ ] React unit tests (Vitest + React Testing Library)
- [ ] API integration tests (WebApplicationFactory)
- [ ] Business logic test coverage ≥ 90%
- [ ] End-to-end tests (Playwright for web)

### Phase 6 — Deployment (Weeks 15–16)
- [ ] Docker images for API
- [ ] Infrastructure as Code (Terraform / Azure Bicep)
- [ ] GitHub Actions CI/CD pipelines
- [ ] Deploy API to Azure Container Apps
- [ ] Deploy React to Azure Static Web Apps
- [ ] Submit Flutter app to Google Play (beta)
- [ ] Submit Flutter app to Apple App Store (beta)

---

## 🔄 Migration from Current Codebase

| Current | Action |
|---|---|
| `Zakaty.MobileAppService` (ASP.NET Core 2) | Upgrade to ASP.NET Core 8, retain domain logic |
| `Zakaty` (Xamarin.Forms) | **Delete** — rebuild from scratch in Flutter |
| `Zakaty.Android`, `Zakaty.iOS`, `Zakaty.UWP` | **Delete** — Flutter handles all platforms |
| `Calculator.cs` | Port to Dart (Flutter) + equivalent C# service (API) |
| `IDataStore<T>` / `MockDataStore` | Replace with BLoC + Repository in Flutter; EF Core in API |

---

## 🛠️ Developer Tooling

| Role | Recommended Tool |
|---|---|
| Flutter | VS Code + Flutter extension, or Android Studio |
| React | VS Code + ESLint + Prettier |
| API | VS Code + C# Dev Kit, or JetBrains Rider |
| API design | Swagger UI / Scalar (auto-generated from code) |
| Database | pgAdmin or TablePlus |
| Secrets | `.env` locally, Azure Key Vault in production |

---

## 🚀 Getting Started (Development)

```sh
# 1. Clone the repository
git clone https://github.com/A-TECHSOLUTIONS/Zakaty.git
cd Zakaty

# 2. Start the API (requires .NET 8 SDK + PostgreSQL)
cd apps/api
dotnet restore && dotnet run

# 3. Start the React web app (requires Node 20+)
cd apps/web
npm install && npm run dev

# 4. Start the Flutter app (requires Flutter 3.x)
cd apps/mobile
flutter pub get && flutter run
```

---

## 📋 Creating GitHub Issues

All 39 plan issues can be created automatically with the [GitHub CLI](https://cli.github.com).

### macOS / Linux / WSL

```sh
gh auth login          # one-time setup
bash scripts/create-issues.sh
```

### Windows (PowerShell / pwsh)

```powershell
# Install GitHub CLI if not already present
winget install GitHub.cli

gh auth login          # one-time setup

# Run from the repository root
pwsh -ExecutionPolicy Bypass -File scripts\create-issues.ps1
# or, from inside a PowerShell session:
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\create-issues.ps1
```

Both scripts are equivalent — they create the same 39 issues with identical labels across all 6 phases.

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/my-feature`
3. Commit your changes: `git commit -m 'feat: add my feature'`
4. Push to the branch: `git push origin feature/my-feature`
5. Open a Pull Request

Please follow [Conventional Commits](https://www.conventionalcommits.org/) for commit messages.

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

## 📬 Contact

- **Organization:** [A-TECHSOLUTIONS](https://github.com/A-TECHSOLUTIONS)
- **Homepage:** [atechdz.com](https://atechdz.com)
