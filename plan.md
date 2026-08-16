# Assets Control — Implementation Plan

## Overview

A Rails 8 app that replaces a manual spreadsheet for tracking personal financial assets in BRL (Reais). The user currently tracks ~8 asset categories (some in USD, some in BRL) in a single spreadsheet row, but loses history on every update. This app records **versioned snapshots** with full history and plots net worth evolution over time with interactive charts.

---

## Gems & JS Libraries

Already in Gemfile (no changes):
- `rails ~> 8.1`, `pg`, `puma`
- `tailwindcss-rails` — UI styling
- `importmap-rails`, `turbo-rails`, `stimulus-rails` — Hotwire stack
- `rspec-rails`, `factory_bot_rails` — testing

New gems to add:
- None. Currency conversion is simple math (USD × rate = BRL), no gem needed.

JS libraries to pin via importmap:
- `chart.js` — line/bar/doughnut charts (`bin/importmap pin chart.js`)
- `@kurkle/color` — Chart.js dependency (`bin/importmap pin @kurkle/color`)

---

## Data Models

### `Asset`
A financial holding. Matches the user's spreadsheet rows.

| Column | Type | Notes |
|--------|------|-------|
| `name` | string | required. e.g. "ETFs gringos", "DOCS", "Carro" |
| `category` | string | required. enum: `stocks`, `fixed_income`, `real_estate`, `vehicle`, `insurance`, `bank_account`, `other` |
| `currency` | string(3) | required. ISO 4217: `USD` or `BRL` |
| `liquid` | boolean | required, default `true`. False for apartment/car (excluded from "Total Líquido") |
| `archived` | boolean | default `false`. Soft-delete without losing history |
| `position` | integer | for ordering assets in the UI (matches spreadsheet row order) |

### `Snapshot`
A point-in-time checkpoint. Represents one spreadsheet "update session."

| Column | Type | Notes |
|--------|------|-------|
| `taken_on` | date | required, unique. The date this snapshot represents |
| `notes` | text | optional |

### `AssetEntry`
The balance of one asset at one snapshot. One per asset per snapshot.

| Column | Type | Notes |
|--------|------|-------|
| `snapshot_id` | FK → snapshots | required |
| `asset_id` | FK → assets | required |
| `amount` | decimal(15,2) | required, default 0. Balance in the asset's native currency |
| `dollar_rate` | decimal(8,4) | optional. The USD→BRL exchange rate at this entry. Only used when `asset.currency == "USD"` |

Unique constraint: `[:snapshot_id, :asset_id]`.

**BRL is always computed** as `amount × dollar_rate` when USD, or just `amount` when BRL. No separate "value in reais" column needed — it's always derived.

---

## Services

### `EntryValueService`
Computes the BRL value of a single `AssetEntry`.
- If asset is BRL → returns `entry.amount`
- If asset is USD → returns `entry.amount * entry.dollar_rate`
- Used everywhere: dashboard totals, charts, asset detail views

### `DashboardService`
Given a base currency (always BRL):
- Returns an array of `{ date:, total:, liquid_total:, by_category: {} }` for each snapshot
- `total` = sum of all entries converted to BRL
- `liquid_total` = sum of only `asset.liquid == true` entries in BRL
- `by_category` = breakdown hash for doughnut chart data
- This is consumed by the chart Stimulus controller as JSON

---

## Routes

```
root          → dashboard#index
resources :assets
resources :snapshots
```

No API/JSON routes — everything is server-rendered HTML with Chart.js via Stimulus.

---

## Views

### Layout
- Top navbar: **Dashboard** | **Ativos** | **Snapshots**
- Tailwind CSS throughout, responsive

### Dashboard (`root`)
**Summary cards:**
- **Patrimônio Total** (total net worth in BRL)
- **Patrimônio Líquido** (liquid total, excluding apartment/car)
- **Variação** (change since last snapshot, $ and %)
- **Quantidade de Ativos** (number of assets)

**Charts:**
- **Evolução Patrimônio** — line chart, x-axis = snapshot dates, y-axis = total BRL. Two lines: total and liquid.
- **Por Categoria** — doughnut chart, segments = category breakdown
- **Por Moeda** — doughnut chart, segments = USD vs BRL assets

**Latest snapshot table:**
- Matches spreadsheet layout: Asset | Currency | Amount | Dollar Rate | Value (BRL) | %
- Row for Total and Total Líquido at bottom

### Assets Index
- Table: Name | Category | Currency | Liquid | Latest Amount | Actions
- Filters by category, currency, liquid/archived
- "New Asset" button

### Asset Detail (`/assets/:id`)
- Asset info card
- Line chart: this asset's BRL value over all snapshots
- Table: all entries for this asset (date, amount, rate, BRL value)

### Snapshot Form (`/snapshots/new`)
- Date picker for `taken_on`
- Notes text field
- Table with one row per active (non-archived) asset, ordered by `position`:
  - Asset name | Currency | Amount input | Dollar Rate input (only shown if USD)
- **"Preencher com último snapshot"** button: fetches latest entries via Turbo and pre-fills all fields
- Submit creates Snapshot + all AssetEntries in a transaction

### Snapshot List (`/snapshots`)
- Table: Date | Notes | Total | Liquid Total | Actions

---

## Seed Data

`db/seeds.rb` creates:
- 8 assets matching the user's spreadsheet:
  1. ETFs gringos (stocks, USD, liquid)
  2. DOCS (stocks, USD, liquid)
  3. Ações/FII (stocks, BRL, liquid)
  4. Conta corrente (bank_account, BRL, liquid)
  5. Renda fixa (fixed_income, BRL, liquid)
  6. Seguro Warren (insurance, BRL, liquid)
  7. Conta PJ (bank_account, BRL, liquid)
  8. Apartamento (real_estate, BRL, not liquid)
  9. Carro (vehicle, BRL, not liquid)
- 12 monthly snapshots (past 12 months, one per month)
- AssetEntry for every asset on every snapshot with realistic varying amounts
- Dollar rates ranging 4.80–5.50 BRL/USD

---

## Implementation Phases

### Phase 1: Models & Migrations
1. Generate migrations for `assets`, `snapshots`, `asset_entries`
2. Implement models with associations, validations, scopes, enums
3. Write model specs with factories

### Phase 2: Services
1. `EntryValueService` + specs
2. `DashboardService` + specs

### Phase 3: Assets CRUD
1. Controller, views, routes
2. Request specs

### Phase 4: Snapshots CRUD + Batch Entry
1. Controller with nested attributes for entries
2. Snapshot form with pre-fill from previous snapshot
3. Request specs

### Phase 5: Dashboard & Charts
1. Pin Chart.js via importmap
2. Build `chart_controller.js` Stimulus controller
3. Dashboard view with summary cards, line chart, doughnut charts
4. Per-asset chart on Asset#show

### Phase 6: Seed Data & Polish
1. Seed script with realistic data
2. Navigation layout, responsive design
3. Currency formatting helpers
4. Final review

---

## Verification

After each phase:
- `bundle exec rspec` — all tests pass
- `bin/rubocop` — no new offenses
- Manual: `bin/dev`, verify pages render, charts load without JS console errors
