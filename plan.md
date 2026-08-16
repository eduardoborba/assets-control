# Assets Control — Implementation Plan

## Overview

Rails 8 app replacing a manual spreadsheet for tracking personal financial assets in BRL. Records versioned snapshots of asset balances over time and plots net worth evolution with interactive charts.

---

## Gems & JS Libraries

**Already in Gemfile:** `rails ~> 8.1`, `pg`, `tailwindcss-rails`, `importmap-rails`, `turbo-rails`, `stimulus-rails`, `rspec-rails`, `factory_bot_rails`

**To add:** None. USD→BRL conversion is `amount × dollar_rate`, no gem needed.

**External API:** [frankfurter.app](https://frankfurter.app) — free, no API key, uses ECB data. Supports historical rates by date. Used to auto-fetch USD→BRL rate on snapshot creation.

**JS to pin via importmap:**
- `chart.js` — `bin/importmap pin chart.js`
- `@kurkle/color` — `bin/importmap pin @kurkle/color`

---

## Data Models

### `Asset`
| Column | Type | Notes |
|--------|------|-------|
| `name` | string | required. "ETFs gringos", "Carro", etc. |
| `category` | string | enum: `stocks`, `fixed_income`, `real_estate`, `vehicle`, `insurance`, `bank_account`, `other` |
| `currency` | string(3) | required. `USD` or `BRL` |
| `liquid` | boolean | default `true`. False for Seguro Warren, Conta PJ, Apartamento, Carro |
| `archived` | boolean | default `false` |
| `position` | integer | ordering in UI (matches spreadsheet row order) |

### `Snapshot`
| Column | Type | Notes |
|--------|------|-------|
| `taken_on` | date | required, unique |
| `notes` | text | optional |

### `AssetEntry`
| Column | Type | Notes |
|--------|------|-------|
| `snapshot_id` | FK | required |
| `asset_id` | FK | required |
| `amount` | decimal(15,2) | required, default 0. Balance in asset's native currency |
| `dollar_rate` | decimal(8,4) | optional. USD→BRL rate at snapshot date. Auto-fetched, stored to avoid repeat API calls. |

Unique constraint: `[:snapshot_id, :asset_id]`.

BRL value is always derived: `amount × dollar_rate` if USD, or `amount` if BRL.

### `ExchangeRate`
Caches fetched rates so we never call the API twice for the same date.

| Column | Type | Notes |
|--------|------|-------|
| `base_currency` | string(3) | required. Always `USD` for this app |
| `quote_currency` | string(3) | required. Always `BRL` for this app |
| `rate` | decimal(8,4) | required. 1 USD = rate BRL |
| `fetched_on` | date | required, unique. The date this rate applies to |

Unique constraint: `[:base_currency, :quote_currency, :fetched_on]`.

---

## Services

### `ExchangeRateFetcher`
Fetches USD→BRL rate for a given date from frankfurter.app.
- `call(date:)` → rate (decimal)
- Checks `ExchangeRate` cache first — returns cached rate if exists
- If not cached, calls `https://api.frankfurter.app/YYYY-MM-DD?from=USD&to=BRL`
- Stores result in `ExchangeRate` record for future use
- Falls back to most recent cached rate if API fails
- Used when creating a new snapshot to pre-fill all USD asset dollar_rate fields

### `EntryValueService`
Computes BRL value of a single `AssetEntry`. Returns `entry.amount` if BRL, `entry.amount * entry.dollar_rate` if USD.

### `DashboardService`
Returns array of `{ date:, total:, liquid_total:, by_category: {} }` per snapshot. `total` = all entries in BRL. `liquid_total` = only `asset.liquid == true` entries. Used as JSON data for Chart.js.

---

## Routes

```
root          → dashboard#index
resources :assets
resources :snapshots
```

---

## Views

### Layout
Top navbar: **Dashboard** | **Ativos** | **Snapshots**. Tailwind CSS, responsive.

### Dashboard (`root`)
- **Cards:** Patrimônio Total, Patrimônio Líquido, Variação (Δ and %), Qtd Ativos
- **Line chart:** Total + Líquido over all snapshot dates
- **Doughnut charts:** By category, by currency (USD vs BRL)
- **Latest snapshot table:** Asset | Currency | Amount | Dollar Rate | BRL Value | % — with Total and Total Líquido rows

### Assets Index
Table: Name | Category | Currency | Liquid | Latest Amount | Actions. Filter by category/currency. New Asset button.

### Asset Detail (`/assets/:id`)
Info card + line chart (this asset's BRL history) + entries table.

### Snapshot Form (`/snapshots/new`)
Date picker, notes field, table with one row per active asset (ordered by `position`): Asset name | Currency | Amount input | Dollar Rate input (USD only). When user selects a date, `ExchangeRateFetcher` runs and pre-fills all USD dollar_rate fields with the fetched rate. **"Preencher com último snapshot"** button also pre-fills amounts from latest snapshot via Turbo. Submit creates Snapshot + all entries in a transaction.

### Snapshot List (`/snapshots`)
Date | Notes | Total | Liquid Total | Actions.

---

## Seed Data (`db/seeds.rb`)

9 assets matching spreadsheet:
1. ETFs gringos (stocks, USD, liquid)
2. DOCS (stocks, USD, liquid)
3. Ações/FII (stocks, BRL, liquid)
4. Conta corrente (bank_account, BRL, liquid)
5. Renda fixa (fixed_income, BRL, liquid)
6. Seguro Warren (insurance, BRL, **not liquid**)
7. Conta PJ (bank_account, BRL, **not liquid**)
8. Apartamento (real_estate, BRL, **not liquid**)
9. Carro (vehicle, BRL, **not liquid**)

12 monthly snapshots (past year). AssetEntry per asset per snapshot with realistic amounts. ExchangeRate records pre-seeded for each snapshot date (USD→BRL 4.80–5.50).

---

## Implementation Phases

Each phase is implemented on a **separate branch** (e.g. `phase/1-models-and-migrations`). After implementation, a **Pull Request** is opened against `main` for manual review and merge. Phases are sequential — each PR is based on the previous merged phase.

| Phase | Branch | PR Title | Description |
|-------|--------|----------|-------------|
| 1 | `phase/1-models-and-migrations` | "Phase 1: Models & Migrations" | Generate migrations, implement models (associations, validations, enums, scopes), model specs + factories |
| 2 | `phase/2-services` | "Phase 2: Services" | `ExchangeRateFetcher` + `EntryValueService` + `DashboardService` with specs |
| 3 | `phase/3-assets-crud` | "Phase 3: Assets CRUD" | Controller, views, routes, request specs |
| 4 | `phase/4-snapshots-crud` | "Phase 4: Snapshots CRUD + Batch Entry" | Controller with nested attributes, snapshot form with pre-fill from previous snapshot, request specs |
| 5 | `phase/5-dashboard-and-charts` | "Phase 5: Dashboard & Charts" | Pin Chart.js, build `chart_controller.js` Stimulus controller, dashboard with summary cards + charts, per-asset chart |
| 6 | `phase/6-seed-data-and-polish` | "Phase 6: Seed Data & Polish" | Seed script, navigation layout, responsive design, currency formatting, final review |

---

## Verification

After each phase: `bundle exec rspec` (tests pass), `bin/rubocop` (no offenses), manual check with `bin/dev` (pages render, charts load, no JS errors).
