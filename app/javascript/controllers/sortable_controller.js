import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  connect() {
    Sortable.create(this.element, {
      animation: 150,
      handle: ".drag-handle",
      ghostClass: "opacity-50",
      onEnd: (event) => this.reorder(event)
    })
  }

  reorder(event) {
    const ids = Array.from(this.element.children).map((el) => el.dataset.id)

    fetch("/financial_assets/reorder", {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify({ asset_ids: ids })
    })
  }
}
