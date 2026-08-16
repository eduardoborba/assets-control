# Implementation Plan: Assets Control

## 1. Executive Overview
Assets Control is a Rails 8 application designed to solve personal financial tracking across multiple accounts, sources, and currencies. Unlike static spreadsheets where balance updates overwrite past values, Assets Control tracks **point-in-time snapshots** and **asset entries (valuations)**. This preserves full historical records, allowing users to analyze net worth evolution over time and explore asset allocations using interactive charts.

---

## 2. Architecture & Design Decisions

- **Framework:** Ruby on Rails 8.1+ with Ruby 3.4+
- **Frontend Stack:**
  - Tailwind CSS (via `tailwindcss-rails`) for clean, responsive UI.
  - Hotwire (Turbo & Stimulus) for fast, reactive UI without SPA complexity.
  - **Chart.js** imported via Importmaps (`config/importmap.rb`) connected to a reusable Stimulus controller (`chart_controller.js`).
- **Database:** PostgreSQL (`pg`) with strict foreign keys, numerical precision for financial figures, and indexes on lookup/timestamp columns.
- **Snapshot Pattern:**
  - An `Asset` represents a financial account or item (e.g., "Chase Checking", "Fidelity Brokerage", "Bitcoin Wallet", "Apartment").
  - A `Snapshot` represents a historical point in time (e.g., `2026-01-31`).
  - An `AssetEntry` (or Valuation) links an `Asset` to a `Snapshot` with an `amount` and its native `currency`.
  - When entering a new snapshot, the UI pre-populates default values from the previous snapshot so the user can quickly update numbers (mimicking spreadsheet workflow).
- **Currency Conversion:**
  - Assets can be in USD, EUR, BRL, GBP, CAD, etc.
  - An `ExchangeRate` model stores historical or cached rate pairs (e.g., USD -> BRL = 5.20 on a given date).
  - A `CurrencyConverter` service normalizes all asset values into the user's selected **Base Currency** for consolidated reporting and chart plotting.

---

## 3. Data Models & Database Schema

### 3.1 `assets` Table
Represents tracked financial holdings.
- `id` (primary key)
- `name` (string, required): e.g., "Chase Savings"
- `category` (string / enum, required): `cash`, `stocks`, `crypto`, `real_estate`, `pension`, `other`
- `source` (string, optional): e.g., "Chase Bank", "Binance", "Interactive Brokers"
- `currency` (string, required, length 3): e.g., "USD", "EUR", "BRL"
- `archived` (boolean, default: false): To hide deprecated assets without deleting historical data.
- `created_at`, `updated_at` (timestamps)

*Indexes:*
- `index_assets_on_category`
- `index_assets_on_archived`

### 3.2 `snapshots` Table
Represents a specific date/checkpoint for net worth tracking.
- `id` (primary key)
- `snapshot_date` (date, required, unique)
- `notes` (text, optional): e.g., "End of January 2026 update"
- `created_at`, `updated_at` (timestamps)

*Indexes:*
- `index_snapshots_on_snapshot_date` (unique)

### 3.3 `asset_entries` Table
Represents the valuation of a single asset on a specific snapshot date.
- `id` (primary key)
- `snapshot_id` (foreign_key to `snapshots`, required)
- `asset_id` (foreign_key to `assets`, required)
- `amount` (decimal, precision: 15, scale: 2, required, default: 0.00)
- `currency` (string, length 3, required): Inherited default from Asset, allows override if needed.
- `created_at`, `updated_at` (timestamps)

*Indexes & Constraints:*
- `unique index on [:snapshot_id, :asset_id]` (One entry per asset per snapshot date)
- `index_asset_entries_on_asset_id`

### 3.4 `exchange_rates` Table
Stores exchange rates relative to base rates on given dates.
- `id` (primary key)
- `date` (date, required)
- `from_currency` (string, length 3, required)
- `to_currency` (string, length 3, required)
- `rate` (decimal, precision: 12, scale: 6, required)
- `created_at`, `updated_at` (timestamps)

*Indexes & Constraints:*
- `unique index on [:date, :from_currency, :to_currency]`

---

## 4. Dependencies & Gems / JS Libraries

### Gems
- `rails` (~> 8.1)
- `pg` (~> 1.1)
- `tailwindcss-rails` (Tailwind CSS styling)
- `importmap-rails` (ESM module loader)
- `turbo-rails` & `stimulus-rails` (Hotwire UX)
- `money` or custom lightweight currency conversion module (lightweight custom service using `ExchangeRate` model is preferred to keep dependencies minimal).
- `rspec-rails`, `factory_bot_rails`, `shoulda-matchers` (Testing suite)

### JavaScript Libraries
- `chart.js` (Pinned via importmaps: `bin/importmap pin chart.js/auto`)
- `@kurkle/color` (Dependency required by Chart.js if needed)

---

## 5. System Architecture & UI Controllers

```
                       ┌──────────────────────┐
                       │  DashboardController │
                       └──────────┬───────────┘
                                  │
          ┌───────────────────────┼────────────────────────┐
          ▼                       ▼                        ▼
┌───────────────────┐   ┌───────────────────┐    ┌────────────────────┐
│ AssetsController  │   │SnapshotsController│    │ SettingsController │
│ (CRUD Assets)     │   │(Batch Balance Entry│    │(Base Currency, Rates│
└───────────────────┘   └───────────────────┘    └────────────────────┘
```

### 5.1 Main Views
1. **Dashboard (`/` or `/dashboard`)**:
   - Summary cards: Total Net Worth (in base currency), Change since last snapshot ($ and %), Total Assets Count.
   - **Net Worth Evolution Line Chart**: Total portfolio value over historical snapshots.
   - **Breakdown Bar / Pie Charts**: Portfolio split by Asset Category and Asset Source.
   - Latest Snapshot Summary Table.
2. **Snapshots (`/snapshots`)**:
   - Snapshot list with dates and totals.
   - New Snapshot / Edit Snapshot form (`/snapshots/new` or `/snapshots/:id/edit`): Matrix form displaying all active Assets with input fields for `amount` for each asset. Button to pre-fill from the immediately preceding snapshot.
3. **Assets (`/assets`)**:
   - Asset listing table with filter by Category, Source, Currency, and status (Active/Archived).
   - New/Edit Asset modals or standalone views.
   - Asset detail view (`/assets/:id`): Historical line chart and entries table for that specific asset.

---

## 6. Detailed Implementation Phases

### Phase 1: Database Models & Migrations
1. Generate migrations for `assets`, `snapshots`, `asset_entries`, and `exchange_rates`.
2. Implement Model files (`Asset`, `Snapshot`, `AssetEntry`, `ExchangeRate`) with validations, scopes, and associations.
3. Write RSpec unit tests for models (`spec/models/...`).

### Phase 2: Core Services
1. Implement `CurrencyConverterService`:
   - Input: `amount`, `from_currency`, `to_currency`, `date`.
   - Fetches matching `ExchangeRate` or defaults to 1.0 if currencies match. Supports fallback or reverse rate lookup.
2. Implement `PortfolioCalculatorService`:
   - Calculates total net worth per snapshot in target base currency.
   - Generates time-series datasets for Chart.js (dates array, total values array, category breakdown arrays).

### Phase 3: Controllers & Views (Asset & Snapshot CRUD)
1. Build `AssetsController` (`index`, `new`, `create`, `edit`, `update`, `destroy`, `show`).
2. Build `SnapshotsController`:
   - `new` / `create`: Form accepts nested attributes or custom batch parameters for `asset_entries`.
   - Pre-fill action or helper that populates current asset amounts from latest snapshot.
3. Add seed data in `db/seeds.rb` with realistic sample assets, exchange rates, and snapshots over the past 12 months.

### Phase 4: Frontend & Charts Integration
1. Pin Chart.js: `bin/importmap pin chart.js/auto`
2. Implement Stimulus Controller `app/javascript/controllers/chart_controller.js`:
   - Reads chart config and data from HTML data attributes (`data-chart-type-value`, `data-chart-data-value`, `data-chart-options-value`).
   - Initializes and destroys Chart.js instance on Turbo page loads.
3. Create chart components/partials for Dashboard and Asset detail views.

### Phase 5: UI Polish & Styling
1. Design top navbar / navigation sidebar with Tailwind CSS.
2. Responsive layout for mobile and desktop screens.
3. Format currency values with proper locale and precision helpers (`number_to_currency`).

### Phase 6: Automated Testing & Verification
1. Model specs for all models and validations.
2. Service specs for `CurrencyConverterService` and `PortfolioCalculatorService`.
3. Request / Feature specs for Asset creation, Snapshot batch entry, and Dashboard loading.

---

## 7. Execution Checklist for Implementing Agents

- [ ] Execute database migrations: `bin/rails db:migrate`
- [ ] Run test suite after each phase: `bundle exec rspec`
- [ ] Verify JS importmaps and charts load without console errors on Turbo navigation.
- [ ] Ensure `rubocop` and linter checks pass before finalizing.
