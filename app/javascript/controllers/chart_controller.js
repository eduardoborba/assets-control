import { Controller } from "@hotwired/stimulus"
import { Chart, registerables } from "chart.js"
Chart.register(...registerables)

export default class extends Controller {
  static targets = ["lineChart", "categoryChart", "currencyChart"]
  static values = { data: Object }

  connect() {
    this.charts = []
    this.renderLineChart()
    this.renderCategoryChart()
    this.renderCurrencyChart()
  }

  disconnect() {
    this.charts.forEach(chart => chart.destroy())
  }

  renderLineChart() {
    if (!this.hasLineChartTarget || !this.dataValue.dates) return

    const data = this.dataValue
    const datasets = [
      {
        label: "Total",
        data: data.totals,
        borderColor: "#2563eb",
        backgroundColor: "rgba(37, 99, 235, 0.1)",
        fill: true,
        tension: 0.3
      },
      {
        label: "Total Líquido",
        data: data.liquid_totals,
        borderColor: "#16a34a",
        backgroundColor: "rgba(22, 163, 74, 0.1)",
        fill: true,
        tension: 0.3
      }
    ]

    if (data.by_asset) {
      data.by_asset.forEach(asset => {
        datasets.push({
          label: asset.label,
          data: asset.data,
          borderColor: asset.borderColor,
          borderDash: [5, 5],
          tension: 0.3,
          hidden: true
        })
      })
    }

    const chart = new Chart(this.lineChartTarget, {
      type: "line",
      data: { labels: data.dates, datasets },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          tooltip: {
            callbacks: {
              label: (context) => {
                const value = context.parsed.y
                return `${context.dataset.label}: R$ ${value.toLocaleString("pt-BR", { minimumFractionDigits: 2 })}`
              }
            }
          }
        },
        scales: {
          y: {
            ticks: {
              callback: (value) => `R$ ${(value / 1000).toFixed(0)}k`
            }
          }
        }
      }
    })
    this.charts.push(chart)
  }

  renderCategoryChart() {
    if (!this.hasCategoryChartTarget || !this.dataValue.by_category) return

    const data = this.dataValue.by_category
    const labels = Object.keys(data)
    const values = Object.values(data)

    const chart = new Chart(this.categoryChartTarget, {
      type: "doughnut",
      data: {
        labels: labels,
        datasets: [{
          data: values,
          backgroundColor: [
            "#2563eb", "#16a34a", "#ea580c", "#9333ea",
            "#dc2626", "#0891b2", "#ca8a04", "#be185d", "#6b7280"
          ]
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          tooltip: {
            callbacks: {
              label: (context) => {
                const value = context.parsed
                return `${context.label}: R$ ${value.toLocaleString("pt-BR", { minimumFractionDigits: 2 })}`
              }
            }
          }
        }
      }
    })
    this.charts.push(chart)
  }

  renderCurrencyChart() {
    if (!this.hasCurrencyChartTarget || !this.dataValue.by_currency) return

    const data = this.dataValue.by_currency
    const labels = Object.keys(data)
    const values = Object.values(data)

    const chart = new Chart(this.currencyChartTarget, {
      type: "doughnut",
      data: {
        labels: labels,
        datasets: [{
          data: values,
          backgroundColor: ["#2563eb", "#16a34a"]
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          tooltip: {
            callbacks: {
              label: (context) => {
                const value = context.parsed
                return `${context.label}: R$ ${value.toLocaleString("pt-BR", { minimumFractionDigits: 2 })}`
              }
            }
          }
        }
      }
    })
    this.charts.push(chart)
  }
}
