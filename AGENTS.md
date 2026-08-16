# AGENTS.md

## Project Overview
Personal finance asset tracker built with Rails 8. Tracks assets across multiple sources and currencies (BRL/USD), records historical snapshots, and plots net worth evolution with Chart.js.

## Tech Stack
- **Backend:** Ruby 3.4.10, Rails 8.1, PostgreSQL
- **Frontend:** Tailwind CSS, Hotwire (Turbo + Stimulus), Chart.js via Importmaps
- **Testing:** RSpec, FactoryBot, Shoulda Matchers

## Git Workflow
- Each feature is implemented on a **separate branch** (e.g. `phase/1-models-and-migrations`)
- Open a **Pull Request** against `main` for manual review and merge
- Never commit directly to `main`
- Branch naming: `phase/N-description` or `feature/description`

## Commit Style
- One logical change per commit
- Commit messages: imperative mood, lowercase, no period
  - `add migration for assets table`
  - `implement dashboard service with specs`
  - `fix chart tooltip rendering`
- Group related files in the same commit

## Code Conventions
- Follow existing code style in the file being edited
- Use Rails conventions (singular model names, plural table names)
- Prefer scopes over class methods for query logic
- Use `dependent:` option on all `has_many` associations
- **All monetary values stored as integers (cents).** Amounts: cents (e.g., 100000 = R$1.000,00). Rates: value * 10000 (e.g., 51762 = 5.1762). Use `RATE_SCALE = 10_000` constant.
- No comments unless explicitly requested

## Testing Requirements
- Write specs for all models, services, and controllers
- Use FactoryBot traits for variations (e.g. `:usd`, `:brl`, `:illiquid`)
- Use VCR cassettes for external API calls (preferred over mocking)
- To record new cassettes, temporarily add `record: :all` to `spec/support/vcr.rb`, run the specs, then remove the option
- Avoid manually editing VCR cassettes unless mocking something hard to replicate (e.g. API failures)
- Run `bundle exec rspec` before committing — all tests must pass
- Run `bin/rubocop` — no new offenses allowed
- Run `bin/rubocop -A` to auto-correct style issues

## Planning
- Write implementation plans to `plan.md` before starting work
- Plans should be self-contained — any agent can implement with no context
- Include: data models, gems/libraries, architecture decisions, implementation phases
- Each phase should map to a separate branch and PR

## File Structure
- Models: `app/models/`
- Services: `app/services/`
- Controllers: `app/controllers/`
- Views: `app/views/`
- JS controllers: `app/javascript/controllers/`
- Specs: `spec/models/`, `spec/services/`, `spec/requests/`
- Factories: `spec/factories/`

## Database
- Use PostgreSQL-specific features when appropriate
- Always add indexes for foreign keys and frequently queried columns
- Use unique constraints for business keys (e.g. `[:snapshot_id, :asset_id]`)
- Run `bin/rails db:prepare` to set up database

## Important Notes
- Base currency is always BRL (Reais)
- USD assets require a `dollar_rate` field for conversion
- `liquid` boolean on Asset controls "Total Líquido" calculation
- Exchange rates are cached in `ExchangeRate` model to avoid repeat API calls
- Chart.js is loaded via importmaps, not npm/webpack
