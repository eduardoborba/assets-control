# Assets Control

Assets Control is a Ruby on Rails application designed to easily track financial assets across multiple sources (banks, brokerages, crypto wallets, real estate, etc.) and currencies. It maintains historical snapshots so you can track net worth evolution and portfolio distribution over time with interactive charts.

---

## Key Features

- **Multi-Currency Asset Management:** Track assets in USD, EUR, BRL, and other currencies.
- **Historical Snapshots:** Record balance updates at point-in-time intervals without overwriting past data.
- **Visual Analytics:** Interactive line and bar charts (powered by Chart.js) showing net worth growth, asset breakdown by category, and source allocation.
- **Spreadsheet-style Fast Entry:** Enter new snapshot balances pre-filled from prior entries.
- **Base Currency Conversion:** View total net worth normalized into a chosen base currency.

---

## Tech Stack

- **Framework:** Ruby on Rails 8
- **Language:** Ruby 3.4.10
- **Database:** PostgreSQL
- **Frontend / UI:** Tailwind CSS, Hotwire (Turbo & Stimulus), Chart.js (via Importmaps)
- **Testing:** RSpec, FactoryBot

---

## Prerequisites

- Ruby `3.4.10`
- PostgreSQL server running locally or accessible via configuration

---

## Getting Started

1. **Clone the repository:**
   ```bash
   git clone git@github.com:eduardoborba/assets-control.git
   cd assets-control
   ```

2. **Install dependencies:**
   ```bash
   bundle install
   ```

3. **Database Setup:**
   Ensure PostgreSQL is running, then prepare the database:
   ```bash
   bin/rails db:prepare
   ```

4. **Start the Development Server:**
   ```bash
   bin/dev
   ```
   Or using standard Rails server:
   ```bash
   bin/rails s
   ```
   Open `http://localhost:3000` in your browser.

---

## Running Tests

Execute the RSpec test suite with:
```bash
bundle exec rspec
```
