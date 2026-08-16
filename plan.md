# Assets Control — Implementation Plan

## Overview

A Rails 8 app to track personal financial assets across multiple sources and currencies. Replaces a spreadsheet workflow by recording **versioned snapshots** of asset balances over time, with interactive charts showing net worth evolution.

Core problem this solves: every time you update a spreadsheet, the previous values are lost. Here, each update creates a new snapshot row while preserving all historical data.

---

## Gems & JS Libraries

Already in Gemfile (no new gems needed):
- `rails ~> 8.1`, `pg`, `puma`
- `tailwindcss-rails` — UI styling
- `importmap-rails`, `turbo-rails`, `stimulus-rails` — Hotwire stack
- `rspec-rails`, `factory_bot_rails` — testing

New gems to add:
- `money` — currency conversion helpers (wraps ISO 4217 rates)

JS libraries to pin via importmap:
- `chart.js` — line/bar/doughnut charts (`bin/importmap pin chart.js`)
- `@kurkle/color` — Chart.js dependency (`bin/importmap pin @kurkle/color`)

---

## Data Models

### `Asset`
Represents a financial account or holding.

| Column | Type | Notes |
|--------|------|-------|
| `name` | string | required. e.g. "Chase Checking", "Fidelity 401k" |
| `category` | string | required. enum: `cash`, `stocks`, `crypto`, `real_estate`, `other` |
| `source` | string | optional. e.g. "Chase Bank", "Binance" |
| `currency` | string(3) | required. ISO 4217 code: USD, EUR, BRL, etc. |
| `archived` | boolean | default false. Soft-deletes without losing history |

### `Snapshot`
A point-in-time checkpoint (one per update session).

| Column | Type | Notes |
|--------|------|-------|
| `snapshot_date` | date | required, unique. The date this snapshot represents |
| `notes` | text | optional |

### `AssetEntry`
Links an Asset to a Snapshot with a balance amount.

| Column | Type | Notes |
|--------|------|-------|
| `snapshot_id` | FK → snapshots | required |
| `asset_id` | FK → assets | required |
| `amount` | decimal(15,2) | required, default 0. Balance in the asset's native currency |
| `currency` | string(3) | required. Defaults to asset's currency but allows override |

Unique constraint: `[:snapshot_id, :asset_id]` — one entry per asset per snapshot.

### `ExchangeRate`
Historical exchange rate pairs for currency conversion.

| Column | Type | Notes |
|--------|------|-------|
| `date` | date | required |
| `from_currency` | string(3) | required. e.g. "USD" |
| `to_currency` | string(3) | required. e.g. "BRL" |
| `rate` | decimal(12,6) | required. 1 from_currency = rate to_currency |

Unique constraint: `[:date, :from_currency, :to_currency]`.

---

## Services

### `CurrencyConverterService`
- `call(amount:, from:, to:, date:)` → converted amount
- Looks up `ExchangeRate` for exact date, falls back to nearest earlier date
- Returns 1.0 if currencies match
- Uses `money` gem for formatting

### `DashboardService`
- Aggregates all snapshots into time-series data for Chart.js
- Returns: total net worth per snapshot date (in base currency), breakdown by category, breakdown by source
- Used by `DashboardController` to pass JSON datasets to Stimulus chart controller

---

## Routes & Controllers

```
root → DashboardController#index

resources :assets          # full CRUD + show (detail with per-asset chart)
resources :snapshots       # index, new, create, show, edit, update, destroy
```

### `DashboardController#index`
- Loads all snapshots ordered by date
- Computes total net worth per snapshot using `DashboardService`
- Renders summary cards (total net worth, change since last, asset count) and charts

### `AssetsController`
- Standard CRUD (`index`, `show`, `new`, `create`, `edit`, `update`, `destroy`)
- `show` includes a per-asset historical line chart and all its `AssetEntry` records

### `SnapshotsController`
- `new`: renders a form with one row per active `Asset`, pre-filled with the previous snapshot's amounts (mimics spreadsheet workflow)
- `create`: saves the `Snapshot` and batch-creates `AssetEntry` records via `accepts_nested_attributes_for`
- `show`: displays snapshot details and total value

---

## Views & Frontend

### Chart.js + Stimulus Integration
- Pin `chart.js` and `@kurkle/color` via importmap
- Create `app/javascript/controllers/chart_controller.js`:
  - Accepts `data-chart-type-value` (line, bar, doughnut)
  - Accepts `data-chart-data-value` (JSON string with labels + datasets)
  - Initializes/destroys Chart.js instance on Turbo navigate
- Chart partials reused across Dashboard and Asset#show

### Pages
1. **Dashboard** — summary cards (total net worth, delta, asset count) + line chart (net worth over time) + doughnut charts (by category, by source)
2. **Assets index** — table with columns: name, category, source, currency, latest amount, archived status. Filters by category/source.
3. **Asset detail** — asset info + line chart (this asset's history) + entries table
4. **Snapshot form** — table layout: asset name | currency | amount input. "Pre-fill from previous" button.
5. **Snapshot list** — date, notes, total value, link to detail

### Layout
- Tailwind CSS throughout
- Top navbar with links: Dashboard, Assets, Snapshots
- Responsive design (mobile-friendly)

---

## Seed Data

`db/seeds.rb` should create:
- ~8 assets across different categories and currencies (USD, EUR, BRL)
- ~12 monthly snapshots spanning the past year (one per month)
- AssetEntry for every asset on every snapshot, with realistic varying amounts
- ExchangeRate records for USD↔BRL and USD↔EUR pairs

---

## Implementation Phases

### Phase 1: Models & Migrations
1. Generate migrations for all 4 tables
2. Implement models with associations, validations, scopes
3. Write model specs with factories

### Phase 2: Services
1. `CurrencyConverterService` + specs
2. `DashboardService` + specs

### Phase 3: Controllers & Views
1. Assets CRUD (controller, views, request specs)
2. Snapshots CRUD with batch entry form
3. Seed data

### Phase 4: Charts & Dashboard
1. Pin Chart.js via importmap
2. Build `chart_controller.js` Stimulus controller
3. Dashboard view with summary cards and charts
4. Per-asset chart on Asset#show

### Phase 5: Polish
1. Navigation layout
2. Responsive design
3. Currency formatting helpers
4. Final review and cleanup

---

## Verification

After each phase:
- `bundle exec rspec` — all tests pass
- `bin/rubocop` — no new offenses
- Manual: start server with `bin/dev`, verify pages render, charts load without JS console errors
