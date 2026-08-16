import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.querySelectorAll("input[data-currency]").forEach(input => {
      input.dataset.rawValue = input.value
      this.formatDisplay(input)

      input.addEventListener("focus", () => this.onFocus(input))
      input.addEventListener("blur", () => this.onBlur(input))
      input.addEventListener("paste", (e) => this.onPaste(e, input))
    })

    this.element.addEventListener("submit", () => this.onSubmit())
  }

  formatDisplay(input) {
    const raw = input.dataset.rawValue || input.value
    if (!raw) return

    const cents = parseInt(raw, 10)
    if (isNaN(cents)) return

    const isRate = input.dataset.dollarRate !== undefined
    const divisor = isRate ? 10000 : 100
    const decimals = isRate ? 4 : 2

    const formatted = (cents / divisor).toLocaleString("pt-BR", {
      minimumFractionDigits: decimals,
      maximumFractionDigits: decimals
    })
    input.value = formatted
  }

  onFocus(input) {
    const isRate = input.dataset.dollarRate !== undefined
    const divisor = isRate ? 10000 : 100
    const decimals = isRate ? 4 : 2
    const raw = input.dataset.rawValue

    if (raw) {
      const value = parseInt(raw, 10) / divisor
      input.value = value.toLocaleString("pt-BR", {
        minimumFractionDigits: decimals,
        maximumFractionDigits: decimals
      })
    }
  }

  onPaste(e, input) {
    e.preventDefault()
    const text = e.clipboardData.getData("text")
    input.value = text
    this.parseAndStore(input)
    this.formatDisplay(input)
  }

  onBlur(input) {
    this.parseAndStore(input)
    this.formatDisplay(input)
  }

  parseAndStore(input) {
    const isRate = input.dataset.dollarRate !== undefined
    const multiplier = isRate ? 10000 : 100

    let raw = input.value
    raw = raw.replace(/[^0-9.,]/g, "")

    if (raw.includes(",") && raw.includes(".")) {
      raw = raw.replace(/\./g, "").replace(",", ".")
    } else if (raw.includes(",")) {
      raw = raw.replace(",", ".")
    }

    const num = parseFloat(raw)

    if (!isNaN(num)) {
      input.dataset.rawValue = Math.round(num * multiplier)
    }
  }

  onSubmit() {
    this.element.querySelectorAll("input[data-currency]").forEach(input => {
      input.value = input.dataset.rawValue || "0"
    })
  }

  prefill() {
    fetch("/snapshots/prefill")
      .then(response => response.json())
      .then(data => {
        data.forEach(entry => {
          const amountInput = this.element.querySelector(`[data-asset-id="${entry.asset_id}"][data-currency]:not([data-dollar-rate])`)
          if (amountInput) {
            amountInput.dataset.rawValue = entry.amount
            this.formatDisplay(amountInput)
          }

          const rateInput = this.element.querySelector(`[data-asset-id="${entry.asset_id}"][data-dollar-rate]`)
          if (rateInput && entry.dollar_rate) {
            rateInput.dataset.rawValue = entry.dollar_rate
            this.formatDisplay(rateInput)
          }
        })
      })
  }

  fetchRate() {
    const dateInput = this.element.querySelector('[name="snapshot[taken_on]"]')
    const status = document.getElementById("rate-status")

    if (!dateInput.value) return

    status.textContent = "Buscando cotação..."

    fetch(`/snapshots/fetch_rate?date=${dateInput.value}`)
      .then(response => response.json())
      .then(data => {
        if (data.rate) {
          this.element.querySelectorAll("[data-dollar-rate]").forEach(input => {
            input.dataset.rawValue = data.rate
            this.formatDisplay(input)
          })
          status.textContent = `Cotação: ${(data.rate / 10000).toLocaleString("pt-BR", { minimumFractionDigits: 4, maximumFractionDigits: 4 })}`
        } else {
          status.textContent = "Cotação não encontrada"
        }
      })
  }
}
