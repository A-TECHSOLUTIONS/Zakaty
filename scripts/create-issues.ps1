#Requires -Version 5.1
# =============================================================================
# Zakaty — Create all GitHub Issues for the Platform Rewrite Plan
#
# Prerequisites:
#   - GitHub CLI (gh) installed and authenticated:
#       winget install GitHub.cli   # or https://cli.github.com
#       gh auth login
#
# Run from the repository root (one of these):
#   pwsh  -ExecutionPolicy Bypass -File scripts\create-issues.ps1
#   powershell -ExecutionPolicy Bypass -File scripts\create-issues.ps1
# =============================================================================

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Repo = "A-TECHSOLUTIONS/Zakaty"

Write-Host "Zakaty platform rewrite issues — $Repo" -ForegroundColor Cyan
Write-Host ""

# ---------------------------------------------------------------------------
# New-Issue  -Title  -Body  -Labels
# ---------------------------------------------------------------------------
function New-Issue {
    param(
        [string]   $Title,
        [string]   $Body,
        [string[]] $Labels
    )
    $labelArg = $Labels -join ","
    # Write body to a temp file to avoid quoting / length issues
    $tmp = [System.IO.Path]::GetTempFileName()
    [System.IO.File]::WriteAllText($tmp, $Body, [System.Text.Encoding]::UTF8)
    gh issue create `
        --repo  $Repo `
        --title $Title `
        --body-file $tmp `
        --label $labelArg | Out-Null
    Remove-Item $tmp -Force
    Write-Host "  [OK]  $Title" -ForegroundColor Green
}

# ---------------------------------------------------------------------------
# Ensure-Label  -Name  -Color  -Description
# ---------------------------------------------------------------------------
function Ensure-Label {
    param([string]$Name, [string]$Color, [string]$Description)
    gh label create $Name `
        --color       $Color `
        --description $Description `
        --repo        $Repo 2>&1 | Out-Null
}

# ---------------------------------------------------------------------------
# Labels
# ---------------------------------------------------------------------------
Write-Host "Creating labels ..." -ForegroundColor Yellow
Ensure-Label "phase:1-foundation" "0075ca" "Phase 1 - Foundation"
Ensure-Label "phase:2-core" "e4e669" "Phase 2 - Core Features"
Ensure-Label "phase:3-saas" "d93f0b" "Phase 3 - SaaS Layer"
Ensure-Label "phase:4-polish" "bfd4f2" "Phase 4 - Polish and Localisation"
Ensure-Label "phase:5-testing" "0e8a16" "Phase 5 - Testing and QA"
Ensure-Label "phase:6-deploy" "5319e7" "Phase 6 - Deployment"
Ensure-Label "app:mobile" "1d76db" "Flutter mobile app"
Ensure-Label "app:web" "f9d0c4" "React web platform"
Ensure-Label "app:api" "c5def5" "ASP.NET Core API"
Ensure-Label "app:infra" "ededed" "Infrastructure and DevOps"
Ensure-Label "enhancement" "a2eeef" "New feature or request"
Write-Host ""

# ==========================================================================
# Phase 1 — Foundation
# ==========================================================================
Write-Host "Phase 1 — Foundation ..." -ForegroundColor Yellow

New-Issue `
    -Title  "[Phase 1] Initialize monorepo structure" `
    -Labels @("phase:1-foundation", "enhancement") `
    -Body   @"
## Overview
Set up the top-level monorepo folder structure as defined in the architecture plan.

## Tasks
- [ ] Create ``apps/mobile/``, ``apps/web/``, ``apps/api/`` directories
- [ ] Create ``packages/zakat-core/`` and ``packages/zakat-js-sdk/`` directories
- [ ] Create ``infra/``, ``scripts/``, ``docs/`` directories
- [ ] Add root ``.gitignore`` covering Flutter, Node.js, .NET, and Terraform artefacts
- [ ] Add ``README.md`` at the root linking to each sub-project

## Acceptance Criteria
- Repository has the agreed monorepo layout
- All sub-projects can be built independently
"@

New-Issue `
    -Title  "[Phase 1] Scaffold Flutter mobile app" `
    -Labels @("phase:1-foundation", "app:mobile", "enhancement") `
    -Body   @"
## Overview
Bootstrap the Flutter application under ``apps/mobile/``.

## Tasks
- [ ] Run ``flutter create apps/mobile --org com.atechsolutions --project-name zakaty``
- [ ] Add dependencies: ``flutter_bloc``, ``go_router``, ``dio``, ``flutter_secure_storage``, ``hive``, ``intl``, ``firebase_core``, ``firebase_analytics``, ``firebase_messaging``
- [ ] Configure Material 3 theme with brand colours
- [ ] Set up folder structure: ``lib/screens/``, ``lib/blocs/``, ``lib/repositories/``, ``lib/models/``, ``lib/widgets/``
- [ ] Configure ``go_router`` with placeholder routes for all screens
- [ ] Add flavours: ``development`` and ``production``

## Acceptance Criteria
- ``flutter run`` launches a blank app without errors
- All screen routes are registered (even if they show placeholder widgets)
"@

New-Issue `
    -Title  "[Phase 1] Scaffold React web app" `
    -Labels @("phase:1-foundation", "app:web", "enhancement") `
    -Body   @"
## Overview
Bootstrap the React 18 + TypeScript + Vite web application under ``apps/web/``.

## Tasks
- [ ] Run ``npm create vite@latest apps/web -- --template react-ts``
- [ ] Install dependencies: ``react-router-dom``, ``zustand``, ``@tanstack/react-query``, ``tailwindcss``, ``shadcn/ui``, ``react-hook-form``, ``zod``, ``recharts``, ``i18next``, ``react-i18next``
- [ ] Configure Tailwind CSS with custom design tokens
- [ ] Set up route structure: ``public/``, ``app/`` (auth-guarded), ``admin/``
- [ ] Add ``eslint`` + ``prettier`` configuration
- [ ] Add ``vitest`` + ``@testing-library/react`` for unit testing

## Acceptance Criteria
- ``npm run dev`` starts the dev server without errors
- All routes return placeholder pages
"@

New-Issue `
    -Title  "[Phase 1] Scaffold ASP.NET Core 8 API" `
    -Labels @("phase:1-foundation", "app:api", "enhancement") `
    -Body   @"
## Overview
Bootstrap the .NET 8 Web API under ``apps/api/``.

## Tasks
- [ ] Run ``dotnet new webapi -n Zakaty.Api -o apps/api``
- [ ] Add NuGet packages: ``Microsoft.EntityFrameworkCore``, ``Npgsql.EntityFrameworkCore.PostgreSQL``, ``Microsoft.AspNetCore.Identity.EntityFrameworkCore``, ``Microsoft.AspNetCore.Authentication.JwtBearer``, ``FluentValidation.AspNetCore``, ``Swashbuckle.AspNetCore``, ``Serilog.AspNetCore``, ``Hangfire.AspNetCore``, ``StackExchange.Redis``
- [ ] Configure Serilog for structured logging
- [ ] Add Swagger / Scalar UI at ``/swagger``
- [ ] Add health-check endpoint ``GET /api/v1/public/health``
- [ ] Configure CORS for React web app origins

## Acceptance Criteria
- ``dotnet run`` starts the API without errors
- Swagger UI loads at ``/swagger``
- Health-check endpoint returns 200
"@

New-Issue `
    -Title  "[Phase 1] Set up PostgreSQL schema with EF Core migrations" `
    -Labels @("phase:1-foundation", "app:api", "enhancement") `
    -Body   @"
## Overview
Define the database schema using EF Core code-first migrations.

## Domain Models
- ``User`` — Id, Email, PasswordHash, PreferredCurrency, Language, Plan
- ``ZakatCalculation`` — Id, UserId, Date, CategoryType, Inputs (JSONB), ZakatDue
- ``Price`` — Id, AssetType, PricePerGram, Currency, FetchedAt
- ``ApiKey`` — Id, UserId, KeyHash, Name, Scopes, LastUsedAt, IsActive
- ``Subscription`` — Id, UserId, Plan, StartDate, EndDate

## Tasks
- [ ] Define entity classes and ``AppDbContext``
- [ ] Configure relationships and indexes
- [ ] Create initial migration: ``dotnet ef migrations add InitialCreate``
- [ ] Add seed data for testing (Nisab values, sample prices)
- [ ] Document connection string configuration in ``README``

## Acceptance Criteria
- ``dotnet ef database update`` applies successfully on a fresh PostgreSQL instance
- All tables and indexes exist as designed
"@

New-Issue `
    -Title  "[Phase 1] Implement JWT authentication (register / login / refresh)" `
    -Labels @("phase:1-foundation", "app:api", "enhancement") `
    -Body   @"
## Overview
Add user registration, login, and JWT token refresh endpoints.

## Tasks
- [ ] ``POST /api/v1/auth/register`` — create user, return access + refresh tokens
- [ ] ``POST /api/v1/auth/login`` — validate credentials, return tokens
- [ ] ``POST /api/v1/auth/refresh-token`` — rotate refresh token, return new access token
- [ ] ``POST /api/v1/auth/logout`` — revoke refresh token
- [ ] Access token: 15-minute expiry (JWT)
- [ ] Refresh token: 30-day expiry (stored in DB, hashed)
- [ ] Add FluentValidation for all request DTOs
- [ ] Return standardised error responses (RFC 7807 ProblemDetails)

## Acceptance Criteria
- Full auth flow works end-to-end
- Expired / invalid tokens return 401
- Refresh token rotation prevents reuse
"@

New-Issue `
    -Title  "[Phase 1] Port core Zakat business logic (Dart + C#)" `
    -Labels @("phase:1-foundation", "app:mobile", "app:api", "enhancement") `
    -Body   @"
## Overview
Extract and port the existing Zakat calculation logic into both a shared Dart package (``packages/zakat-core``) and a C# service used by the API.

## Calculation Types
| Type | Formula |
|---|---|
| Money | ``amount × 2.5%`` |
| Gold | ``grams × price_per_gram × 2.5%`` (Nisab: 85 g) |
| Silver | ``grams × price_per_gram × 2.5%`` (Nisab: 595 g) |
| Crops (irrigated) | ``value × 10%`` |
| Crops (rain-fed) | ``value × 5%`` |
| Business | ``(assets - liabilities) × 2.5%`` |

## Tasks
- [ ] Create ``packages/zakat-core`` Dart package with pure calculation functions
- [ ] Write unit tests for every calculation type and edge case
- [ ] Create ``ZakatCalculatorService`` in the API with equivalent logic
- [ ] Ensure results match between Dart and C# implementations

## Acceptance Criteria
- All 6 calculation types produce correct results
- Edge cases (below Nisab, zero inputs) handled gracefully
- 100% unit test coverage of calculation logic
"@

# ==========================================================================
# Phase 2 — Core Features
# ==========================================================================
Write-Host "Phase 2 — Core Features ..." -ForegroundColor Yellow

New-Issue `
    -Title  "[Phase 2] Flutter: Zakat calculation screens (all 5 types)" `
    -Labels @("phase:2-core", "app:mobile", "enhancement") `
    -Body   @"
## Overview
Build all five Zakat calculator screens in the Flutter app.

## Screens
- [ ] ``MoneyZakatScreen`` — input: amount; output: zakat due, nisab status
- [ ] ``GoldZakatScreen`` — input: grams; pulls live gold price; output: zakat due
- [ ] ``SilverZakatScreen`` — input: grams; pulls live silver price; output: zakat due
- [ ] ``CropsZakatScreen`` — input: selling price, expenses, irrigation type
- [ ] ``BusinessZakatScreen`` — input: assets, liabilities

## Shared Requirements
- [ ] Each screen validates inputs with inline error messages
- [ ] Results panel shows calculation breakdown
- [ ] 'Save' button persists to history (requires auth); 'Share' generates PDF
- [ ] Consistent design system across all screens

## Acceptance Criteria
- All 5 screens functional on Android and iOS
- Correct zakat amounts calculated using ``zakat-core`` package
- Accessible with screen reader support
"@

New-Issue `
    -Title  "[Phase 2] Flutter: Dashboard and calculation history screen" `
    -Labels @("phase:2-core", "app:mobile", "enhancement") `
    -Body   @"
## Overview
Build the main dashboard and history screens.

## Tasks
- [ ] ``DashboardScreen``: summary card (total Zakat due this year), 5 category quick-action cards, recent calculations list
- [ ] ``ZakatHistoryScreen``: paginated list of past calculations, filter by date/type, pull-to-refresh
- [ ] Detail view for each saved calculation
- [ ] Delete calculation with confirmation dialog
- [ ] Export single calculation as PDF

## Acceptance Criteria
- Dashboard loads in < 1 second (cached data shown while refreshing)
- History list paginates correctly (20 items per page)
- Delete is confirmed before executing
"@

New-Issue `
    -Title  "[Phase 2] React: Public anonymous Zakat calculator page" `
    -Labels @("phase:2-core", "app:web", "enhancement") `
    -Body   @"
## Overview
Build the free, unauthenticated calculator on the public marketing site.

## Tasks
- [ ] Route: ``/calculator``
- [ ] Tab-based UI: Money / Gold / Silver / Crops / Business
- [ ] Uses the public API endpoint ``POST /api/v1/public/calculate``
- [ ] Results panel with calculation breakdown
- [ ] 'Create Account' CTA to save results
- [ ] SEO meta tags and structured data (JSON-LD)
- [ ] Fully responsive (mobile-first)

## Acceptance Criteria
- Works without login
- Calculations match API results
- Page scores ≥ 90 on Lighthouse (Performance + SEO)
"@

New-Issue `
    -Title  "[Phase 2] React: Authenticated user dashboard" `
    -Labels @("phase:2-core", "app:web", "enhancement") `
    -Body   @"
## Overview
Build the authenticated web dashboard for signed-in users.

## Tasks
- [ ] Route: ``/dashboard`` (auth-guarded)
- [ ] Summary widgets: total Zakat due (current year), by category chart (Recharts)
- [ ] Quick-calculate panel linking to each category
- [ ] Recent calculations table with links to detail pages
- [ ] Profile completion nudge for new users

## Acceptance Criteria
- Redirects unauthenticated users to ``/login``
- Data fetched via TanStack Query with loading + error states
- Charts render correctly on all screen sizes
"@

New-Issue `
    -Title  "[Phase 2] API: Public and private Zakat calculation endpoints" `
    -Labels @("phase:2-core", "app:api", "enhancement") `
    -Body   @"
## Overview
Implement the core Zakat calculation API endpoints.

## Endpoints
- [ ] ``POST /api/v1/public/calculate`` — anonymous, rate-limited (100/day per IP), returns calculation result (not saved)
- [ ] ``POST /api/v1/zakat/calculate`` — authenticated, saves result to DB, returns calculation + history entry
- [ ] Request body includes: ``categoryType``, ``inputs`` (category-specific JSON), ``currency``
- [ ] Response includes: ``zakatDue``, ``nisabStatus``, ``breakdown``, ``calculatedAt``
- [ ] Input validation via FluentValidation
- [ ] Swagger documentation with example requests/responses

## Acceptance Criteria
- Both endpoints return correct results for all 5 Zakat types
- Public endpoint enforces rate limit
- Private endpoint saves to ``ZakatCalculations`` table
"@

New-Issue `
    -Title  "[Phase 2] API: Gold and silver price background job (Hangfire)" `
    -Labels @("phase:2-core", "app:api", "enhancement") `
    -Body   @"
## Overview
Add a Hangfire recurring job that fetches current gold and silver spot prices and stores them in the database.

## Tasks
- [ ] Integrate a free metals price API (e.g., metals.live or GoldAPI.io free tier)
- [ ] ``PriceFetchJob`` runs every 6 hours
- [ ] Stores fetched prices in the ``Prices`` table with timestamp
- [ ] ``GET /api/v1/public/prices`` returns latest prices (24-hour delayed for free tier)
- [ ] ``GET /api/v1/prices/gold`` and ``/prices/silver`` return historical data for authenticated users
- [ ] Hangfire dashboard available at ``/hangfire`` (admin-only)

## Acceptance Criteria
- Job runs without errors on schedule
- Prices are stored correctly
- API endpoints return up-to-date prices
"@

New-Issue `
    -Title  "[Phase 2] API: Calculation history CRUD endpoints" `
    -Labels @("phase:2-core", "app:api", "enhancement") `
    -Body   @"
## Overview
Implement full CRUD for a user's saved Zakat calculation history.

## Endpoints
- [ ] ``GET /api/v1/zakat/history`` — paginated list (query: page, pageSize, dateFrom, dateTo, categoryType)
- [ ] ``GET /api/v1/zakat/history/{id}`` — single calculation detail
- [ ] ``DELETE /api/v1/zakat/history/{id}`` — soft-delete a record
- [ ] All endpoints return 404 if resource does not belong to the authenticated user

## Acceptance Criteria
- Pagination meta (totalCount, totalPages, currentPage) included in list response
- Row-level security enforced (users cannot access each other's data)
- Deleted records excluded from list but retrievable via admin API
"@

# ==========================================================================
# Phase 3 — SaaS Layer
# ==========================================================================
Write-Host "Phase 3 — SaaS Layer ..." -ForegroundColor Yellow

New-Issue `
    -Title  "[Phase 3] User profile management" `
    -Labels @("phase:3-saas", "app:mobile", "app:web", "app:api", "enhancement") `
    -Body   @"
## Overview
Build user profile endpoints and the corresponding UI in both Flutter and React.

## API Tasks
- [ ] ``GET /api/v1/user/profile`` — return current user's profile
- [ ] ``PUT /api/v1/user/profile`` — update display name, preferred currency, language, notification preferences

## Flutter Tasks
- [ ] ``SettingsScreen``: edit profile, change password, preferred language/currency

## React Tasks
- [ ] ``/settings`` page: profile form, change password, preferences

## Acceptance Criteria
- Profile updates reflected immediately in UI
- Password change requires current password confirmation
- Currency and language preference applied globally
"@

New-Issue `
    -Title  "[Phase 3] API key generation and management" `
    -Labels @("phase:3-saas", "app:web", "app:api", "enhancement") `
    -Body   @"
## Overview
Allow authenticated users to generate, list, and revoke API keys for server-to-server access.

## API Endpoints
- [ ] ``GET /api/v1/user/api-keys`` — list user's API keys (name, last used, scopes)
- [ ] ``POST /api/v1/user/api-keys`` — generate new key (store hashed, return plaintext once)
- [ ] ``DELETE /api/v1/user/api-keys/{id}`` — revoke key

## React UI (``/api-keys``)
- [ ] List existing keys with copy button
- [ ] Create new key modal (name + scope selection)
- [ ] Revoke key with confirmation
- [ ] Warning: plaintext key shown only once at creation

## Acceptance Criteria
- API key auth works on all private endpoints (``Authorization: ApiKey <key>``)
- Revoked keys rejected with 401
- Keys are stored as bcrypt hashes (never plaintext)
"@

New-Issue `
    -Title  "[Phase 3] Subscription plan gating (free tier enforcement)" `
    -Labels @("phase:3-saas", "app:mobile", "app:web", "app:api", "enhancement") `
    -Body   @"
## Overview
Implement plan-based feature gating across API, web, and mobile.

## Plan Definitions
| Feature | Free | Premium |
|---|---|---|
| API access | 100 req/day | 10,000 req/day |
| Calculation history | — | 5 years |
| PDF export | — | ✅ |
| Multiple profiles | — | Up to 10 |
| Real-time prices | Delayed 24h | ✅ |

## Tasks
- [ ] Add ``PlanAuthorizationService`` to API that checks user plan before allowing premium actions
- [ ] Return ``403 Forbidden`` with ``upgradeRequired: true`` for plan violations
- [ ] React: show upgrade CTA when a premium feature is accessed on free plan
- [ ] Flutter: show soft paywall sheet when a premium feature is tapped

## Acceptance Criteria
- Free tier limits enforced consistently on API and UI
- Users see clear, actionable upgrade prompts
"@

New-Issue `
    -Title  "[Phase 3] React: Pricing page and upgrade flow" `
    -Labels @("phase:3-saas", "app:web", "enhancement") `
    -Body   @"
## Overview
Build the public pricing page and the in-app upgrade flow.

## Tasks
- [ ] Route: ``/pricing`` (public)
- [ ] Feature comparison table (Free vs. Premium)
- [ ] Upgrade button links to payment flow (Stripe integration placeholder)
- [ ] Post-upgrade redirect to dashboard with confirmation banner
- [ ] ``/settings/subscription`` page shows current plan + upgrade option

## Acceptance Criteria
- Pricing page loads without auth
- Upgrade CTA visible on pages that require premium features
- Subscription status reflected immediately after upgrade
"@

New-Issue `
    -Title  "[Phase 3] Flutter: Premium feature gates (soft paywall)" `
    -Labels @("phase:3-saas", "app:mobile", "enhancement") `
    -Body   @"
## Overview
Add in-app upgrade prompts in Flutter for features that require a premium plan.

## Tasks
- [ ] Create reusable ``PremiumGateWidget`` that wraps premium content
- [ ] Show a bottom sheet with feature description and upgrade CTA
- [ ] Link to in-app purchase flow (``in_app_purchase`` package) or web checkout
- [ ] Restore purchases support (iOS/Android)

## Acceptance Criteria
- Premium features visually accessible but gated behind upgrade prompt
- Upgrade CTA opens correct purchase flow
- Existing premium users bypass gate immediately
"@

New-Issue `
    -Title  "[Phase 3] API: Rate limiting middleware" `
    -Labels @("phase:3-saas", "app:api", "enhancement") `
    -Body   @"
## Overview
Add per-plan rate limiting to all API endpoints.

## Limits
| Tier | Limit |
|---|---|
| Anonymous (public) | 100 requests / day / IP |
| Free authenticated | 500 requests / day |
| Premium | 10,000 requests / day |

## Tasks
- [ ] Use ASP.NET Core 8 built-in rate limiting middleware
- [ ] Apply ``FixedWindowRateLimiter`` per IP for public endpoints
- [ ] Apply ``SlidingWindowRateLimiter`` per user ID for authenticated endpoints
- [ ] Return ``429 Too Many Requests`` with ``Retry-After`` header
- [ ] Exempt health-check endpoint from rate limiting

## Acceptance Criteria
- Correct limits applied per tier
- 429 response includes human-readable message and ``Retry-After`` header
- Redis used as the distributed rate-limit store
"@

# ==========================================================================
# Phase 4 — Polish & Localisation
# ==========================================================================
Write-Host "Phase 4 — Polish & Localisation ..." -ForegroundColor Yellow

New-Issue `
    -Title  "[Phase 4] Arabic (RTL) + English localisation — Flutter" `
    -Labels @("phase:4-polish", "app:mobile", "enhancement") `
    -Body   @"
## Overview
Add full Arabic and English localisation to the Flutter app with proper RTL layout support.

## Tasks
- [ ] Add ``flutter_localizations`` and ``intl`` to ``pubspec.yaml``
- [ ] Create ``app_en.arb`` and ``app_ar.arb`` translation files for all UI strings
- [ ] Enable ``MaterialApp.localizationsDelegates`` and ``supportedLocales``
- [ ] Test all screens in RTL mode (Arabic)
- [ ] Add language selector to onboarding and settings
- [ ] Translate all Zakat calculation labels, instructions, and error messages

## Acceptance Criteria
- App switches between Arabic (RTL) and English (LTR) without restart
- No UI overflow or misalignment in RTL mode
- All strings translated (no hardcoded English text)
"@

New-Issue `
    -Title  "[Phase 4] Arabic + English localisation — React web" `
    -Labels @("phase:4-polish", "app:web", "enhancement") `
    -Body   @"
## Overview
Add i18n support to the React web platform with Arabic (RTL) and English (LTR).

## Tasks
- [ ] Configure ``i18next`` with ``react-i18next``
- [ ] Create ``public/locales/en/translation.json`` and ``public/locales/ar/translation.json``
- [ ] Add ``dir`` attribute toggle on ``<html>`` for RTL
- [ ] Update Tailwind config to support RTL classes (``rtl:`` prefix)
- [ ] Language switcher in navbar
- [ ] Translate all page content, labels, and error messages

## Acceptance Criteria
- Language switch triggers instant re-render
- Arabic layout is fully RTL with no visual regressions
- Language preference persisted in ``localStorage``
"@

New-Issue `
    -Title  "[Phase 4] PDF export — Flutter and React" `
    -Labels @("phase:4-polish", "app:mobile", "app:web", "enhancement") `
    -Body   @"
## Overview
Allow users to export their Zakat calculation as a formatted PDF.

## Flutter Tasks
- [ ] Add ``pdf`` and ``printing`` packages
- [ ] ``ZakatPdfGenerator`` creates a formatted PDF with: user name, calculation date, type, inputs, breakdown, total due
- [ ] Share sheet integration via ``share_plus``
- [ ] Download to device or share via any installed app

## React Tasks
- [ ] Add ``@react-pdf/renderer``
- [ ] ``ZakatPdfDocument`` React component with matching layout
- [ ] Download button on history detail page
- [ ] Server-side PDF generation as fallback (API endpoint)

## Acceptance Criteria
- PDF includes full calculation breakdown and branding
- File downloads correctly on web (Chrome, Safari, Firefox)
- PDF generates in < 2 seconds on mobile
"@

New-Issue `
    -Title  "[Phase 4] Dark mode support — Flutter" `
    -Labels @("phase:4-polish", "app:mobile", "enhancement") `
    -Body   @"
## Overview
Add system-aware dark mode to the Flutter app.

## Tasks
- [ ] Define ``ThemeData.light()`` and ``ThemeData.dark()`` using Material 3 colour schemes
- [ ] Use ``MediaQuery.platformBrightness`` to detect system preference
- [ ] Add manual override in settings (Light / Dark / System)
- [ ] Store preference in ``hive``
- [ ] Verify all custom widgets render correctly in dark mode

## Acceptance Criteria
- App follows system dark/light mode by default
- Manual override persists across restarts
- No white flash on launch in dark mode
"@

New-Issue `
    -Title  "[Phase 4] Responsive design — React web" `
    -Labels @("phase:4-polish", "app:web", "enhancement") `
    -Body   @"
## Overview
Ensure the React web platform is fully responsive across mobile, tablet, and desktop breakpoints.

## Tasks
- [ ] Audit all pages with Chrome DevTools at 375px, 768px, 1024px, 1440px
- [ ] Fix any layout issues (overflow, font sizes, spacing)
- [ ] Navigation: hamburger menu on mobile, sidebar on desktop
- [ ] Calculator inputs stack vertically on mobile
- [ ] Dashboard charts resize gracefully

## Acceptance Criteria
- No horizontal scroll on any page at 375px width
- All interactive elements meet 44px minimum touch target
- Lighthouse mobile score ≥ 90
"@

New-Issue `
    -Title  "[Phase 4] Flutter: Onboarding flow (3-step intro)" `
    -Labels @("phase:4-polish", "app:mobile", "enhancement") `
    -Body   @"
## Overview
Add a 3-step onboarding experience shown to new users on first launch.

## Steps
1. **Welcome** — 'What is Zakat?' brief explainer with illustration
2. **Features** — highlight key app capabilities
3. **Get Started** — Language selection + Sign Up / Continue as Guest CTA

## Tasks
- [ ] ``OnboardingScreen`` with ``PageView`` for step navigation
- [ ] Skip button on all steps
- [ ] Store 'onboarding complete' flag in ``hive``
- [ ] Illustration assets for each step
- [ ] Smooth page-turn animation

## Acceptance Criteria
- Onboarding shown only on first launch
- Skip navigates directly to login/home
- All illustrations load without flicker
"@

New-Issue `
    -Title  "[Phase 4] React: Marketing landing page" `
    -Labels @("phase:4-polish", "app:web", "enhancement") `
    -Body   @"
## Overview
Build the public marketing landing page at ``/``.

## Sections
- [ ] Hero section: headline, sub-headline, CTA (Try Calculator / Sign Up)
- [ ] Feature highlights: 5 Zakat types, history, API, multilingual
- [ ] How it works: 3-step explainer
- [ ] Pricing section (Free vs Premium)
- [ ] Testimonials / trust badges
- [ ] Footer: links, language toggle, social

## Technical Requirements
- [ ] Static-renderable (no auth dependencies)
- [ ] OpenGraph meta tags for social sharing
- [ ] Structured data (JSON-LD for SoftwareApplication)

## Acceptance Criteria
- Page loads in < 2 s on 3G (Lighthouse)
- Lighthouse Performance + SEO ≥ 90
- Fully accessible (WCAG 2.1 AA)
"@

# ==========================================================================
# Phase 5 — Testing & QA
# ==========================================================================
Write-Host "Phase 5 — Testing & QA ..." -ForegroundColor Yellow

New-Issue `
    -Title  "[Phase 5] Flutter: Unit and widget tests" `
    -Labels @("phase:5-testing", "app:mobile", "enhancement") `
    -Body   @"
## Overview
Add comprehensive unit and widget tests to the Flutter app.

## Scope
- [ ] Unit tests for all BLoC classes (``bloc_test``)
- [ ] Unit tests for repository classes with mocked HTTP responses (``mocktail``)
- [ ] Widget tests for all 5 calculation screens
- [ ] Widget tests for Dashboard and History screens
- [ ] Golden tests for key UI components

## Coverage Target
- Business logic (BLoC): ≥ 90%
- Repository layer: ≥ 80%
- Widget layer: ≥ 70%

## Acceptance Criteria
- ``flutter test`` passes with no failures
- Coverage report generated via ``flutter test --coverage``
"@

New-Issue `
    -Title  "[Phase 5] React: Unit tests (Vitest + React Testing Library)" `
    -Labels @("phase:5-testing", "app:web", "enhancement") `
    -Body   @"
## Overview
Add unit tests for React components, hooks, and utilities.

## Scope
- [ ] Tests for all calculator form components (validation, submission)
- [ ] Tests for Zustand store slices
- [ ] Tests for custom hooks (``useZakatCalculation``, ``useAuth``)
- [ ] Tests for utility functions (date formatting, currency formatting)
- [ ] Snapshot tests for key UI components

## Coverage Target: ≥ 80% statements

## Acceptance Criteria
- ``npm run test`` passes with no failures
- Coverage report available via ``npm run test:coverage``
"@

New-Issue `
    -Title  "[Phase 5] API: Integration tests (WebApplicationFactory)" `
    -Labels @("phase:5-testing", "app:api", "enhancement") `
    -Body   @"
## Overview
Add integration tests for all API endpoints using ``WebApplicationFactory<Program>``.

## Scope
- [ ] Auth flow (register, login, refresh, logout)
- [ ] Public calculate endpoint (valid inputs, invalid inputs, rate limit)
- [ ] Private calculate endpoint (authed, unauthenticated 401)
- [ ] History CRUD (create, read, delete; cross-user access blocked)
- [ ] API key creation and authentication
- [ ] Plan gating (free user accessing premium feature)

## Acceptance Criteria
- ``dotnet test`` passes with no failures
- Each endpoint covered by at least one happy-path and one error test
- Tests use an in-memory or test PostgreSQL database
"@

New-Issue `
    -Title  "[Phase 5] Business logic test coverage ≥ 90%" `
    -Labels @("phase:5-testing", "app:mobile", "app:api", "enhancement") `
    -Body   @"
## Overview
Audit and improve test coverage for all Zakat calculation business logic across Dart and C#.

## Tasks
- [ ] Run coverage reports: ``flutter test --coverage`` and ``dotnet test --collect:"XPlat Code Coverage"``
- [ ] Identify under-covered paths
- [ ] Add missing tests for edge cases: 0 input, exactly at Nisab, negative values, very large numbers
- [ ] Cross-validate Dart and C# results match for identical inputs

## Acceptance Criteria
- Business logic coverage ≥ 90% in both Dart and C#
- Dart and C# implementations return identical results for a shared test matrix
"@

New-Issue `
    -Title  "[Phase 5] End-to-end tests (Playwright — web)" `
    -Labels @("phase:5-testing", "app:web", "enhancement") `
    -Body   @"
## Overview
Add Playwright E2E tests for the React web platform covering critical user journeys.

## Test Scenarios
- [ ] Anonymous user: open calculator → enter gold amount → see result
- [ ] New user: register → log in → run authenticated calculation → view in history
- [ ] Authenticated user: generate API key → revoke API key
- [ ] Free user: attempt PDF export → see upgrade prompt
- [ ] Admin: update gold price

## Tasks
- [ ] Configure Playwright (``playwright.config.ts``)
- [ ] Add ``npm run test:e2e`` script
- [ ] Run against local dev server in CI

## Acceptance Criteria
- All 5 test scenarios pass in CI on Chrome and Firefox
- Tests run in < 3 minutes on GitHub Actions
"@

# ==========================================================================
# Phase 6 — Deployment
# ==========================================================================
Write-Host "Phase 6 — Deployment ..." -ForegroundColor Yellow

New-Issue `
    -Title  "[Phase 6] Docker image for API" `
    -Labels @("phase:6-deploy", "app:api", "app:infra", "enhancement") `
    -Body   @"
## Overview
Containerise the ASP.NET Core API for deployment on Azure Container Apps.

## Tasks
- [ ] Write ``apps/api/Dockerfile`` (multi-stage: build → runtime)
- [ ] Add ``.dockerignore``
- [ ] Add ``docker-compose.yml`` for local development (API + PostgreSQL + Redis)
- [ ] Publish image to GitHub Container Registry (GHCR) on main branch

## Acceptance Criteria
- ``docker build`` succeeds with no warnings
- ``docker-compose up`` starts full local stack
- Image size < 200 MB
- Container starts and passes health check within 30 seconds
"@

New-Issue `
    -Title  "[Phase 6] Infrastructure as Code (Terraform / Azure Bicep)" `
    -Labels @("phase:6-deploy", "app:infra", "enhancement") `
    -Body   @"
## Overview
Define all cloud infrastructure as code under ``infra/``.

## Resources to Define
- [ ] Azure Container Apps (API)
- [ ] Azure Static Web Apps (React)
- [ ] Azure Database for PostgreSQL Flexible Server
- [ ] Azure Cache for Redis
- [ ] Azure Blob Storage (PDF storage)
- [ ] Azure Key Vault (secrets)
- [ ] Azure Application Insights (monitoring)
- [ ] Networking: VNet, private endpoints

## Tasks
- [ ] Choose tool: Terraform or Azure Bicep (recommend Bicep for Azure-native)
- [ ] Create ``infra/main.bicep`` (or ``main.tf``)
- [ ] Parameterise for ``dev`` and ``prod`` environments
- [ ] Document deployment steps in ``infra/README.md``

## Acceptance Criteria
- ``az deployment group create`` deploys all resources without errors
- Parameters file for each environment (dev, prod)
"@

New-Issue `
    -Title  "[Phase 6] GitHub Actions CI/CD pipelines" `
    -Labels @("phase:6-deploy", "app:infra", "enhancement") `
    -Body   @"
## Overview
Set up GitHub Actions workflows for continuous integration and deployment.

## Workflows
- [ ] ``.github/workflows/mobile-ci.yml`` — Flutter test + build APK/IPA on PR
- [ ] ``.github/workflows/web-ci.yml`` — React lint + test + build on PR
- [ ] ``.github/workflows/api-ci.yml`` — .NET build + test + Docker push on PR
- [ ] ``.github/workflows/mobile-cd.yml`` — Deploy to Play Store / App Store on version tag
- [ ] ``.github/workflows/web-cd.yml`` — Deploy to Azure Static Web Apps on push to ``main``
- [ ] ``.github/workflows/api-cd.yml`` — Deploy to Azure Container Apps on push to ``main``

## Requirements
- All CI workflows must pass before merging a PR
- CD workflows use GitHub Environments with required reviewers for ``production``
- Secrets stored in GitHub repository secrets / environment secrets

## Acceptance Criteria
- PR checks run automatically and block merge on failure
- Push to ``main`` triggers deployment to staging
- Version tag triggers deployment to production
"@

New-Issue `
    -Title  "[Phase 6] Deploy API to Azure Container Apps" `
    -Labels @("phase:6-deploy", "app:api", "app:infra", "enhancement") `
    -Body   @"
## Overview
Deploy the containerised API to Azure Container Apps.

## Tasks
- [ ] Create Azure Container Apps environment via IaC (``infra/``)
- [ ] Configure environment variables via Azure Key Vault references
- [ ] Set up custom domain + TLS certificate
- [ ] Configure auto-scaling rules (min 1, max 10 replicas based on HTTP queue depth)
- [ ] Set up health probe on ``/api/v1/public/health``
- [ ] Configure Application Insights connection string

## Acceptance Criteria
- API reachable at ``https://api.zakaty.app`` (or staging equivalent)
- Health check returns 200
- Auto-scaling tested under load
"@

New-Issue `
    -Title  "[Phase 6] Deploy React to Azure Static Web Apps" `
    -Labels @("phase:6-deploy", "app:web", "app:infra", "enhancement") `
    -Body   @"
## Overview
Deploy the React web platform to Azure Static Web Apps.

## Tasks
- [ ] Create Azure Static Web App resource via IaC
- [ ] Configure build command: ``npm run build`` and output dir: ``dist``
- [ ] Set up custom domain + TLS
- [ ] Configure SPA routing (fallback to ``index.html``)
- [ ] Add environment-specific ``VITE_API_URL`` via GitHub Actions variables
- [ ] Configure Azure CDN for static assets caching

## Acceptance Criteria
- Web app live at ``https://zakaty.app`` (or staging equivalent)
- React Router navigation works (no 404 on direct URL access)
- Lighthouse Performance ≥ 90 in production
"@

New-Issue `
    -Title  "[Phase 6] Submit Flutter app to Google Play (beta)" `
    -Labels @("phase:6-deploy", "app:mobile", "app:infra", "enhancement") `
    -Body   @"
## Overview
Prepare and submit the Flutter app to Google Play Console as a beta release.

## Tasks
- [ ] Generate signed release APK / AAB (``flutter build appbundle --release``)
- [ ] Set up Google Play service account for CI/CD (``fastlane supply`` or ``gh-action-google-play``)
- [ ] Create store listing: title, description, screenshots (EN + AR), feature graphic
- [ ] Complete content rating questionnaire
- [ ] Configure Play Store internal → beta → production track promotion
- [ ] Privacy policy URL (required)

## Acceptance Criteria
- App passes Google Play review
- Available in beta track on Android 8.0+
- CI/CD deploys new builds to internal track automatically on version tag
"@

New-Issue `
    -Title  "[Phase 6] Submit Flutter app to Apple App Store (beta via TestFlight)" `
    -Labels @("phase:6-deploy", "app:mobile", "app:infra", "enhancement") `
    -Body   @"
## Overview
Prepare and submit the Flutter app to the Apple App Store via TestFlight.

## Tasks
- [ ] Configure signing: Apple Distribution certificate + provisioning profile
- [ ] Generate ``ExportOptions.plist`` for App Store distribution
- [ ] Set up ``fastlane match`` for code signing management in CI
- [ ] Create App Store Connect listing: title, description, screenshots (6.7", 5.5", iPad), privacy policy
- [ ] Submit to TestFlight for beta testing
- [ ] Address App Store Review Guidelines (especially 4.2 Minimum Functionality)

## Acceptance Criteria
- App passes App Store review
- Available via TestFlight on iOS 15.0+
- CI/CD deploys new builds to TestFlight automatically on version tag
"@

Write-Host ""
Write-Host "All issues created successfully!" -ForegroundColor Cyan
Write-Host "View them at: https://github.com/$Repo/issues" -ForegroundColor Cyan
