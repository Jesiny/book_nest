import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="rating"
export default class extends Controller {
  static targets = ["input"]
  static values = { url: String }

  connect() {
    // no-op
  }

  stepNormalize(event) {
    const input = this.hasInputTarget ? this.inputTarget : event.currentTarget
    const value = parseFloat(input.value)
    if (isNaN(value)) return
    // Snap to nearest 0.5 within 0..5
    let snapped = Math.round(value * 2) / 2
    snapped = Math.max(0, Math.min(5, snapped))
    if (snapped !== value) input.value = snapped
  }

  async save(event) {
    if (!this.urlValue) return
    const input = this.hasInputTarget ? this.inputTarget : event.currentTarget
    const rating = input.value
    try {
      await fetch(this.urlValue, {
        method: "PATCH",
        headers: this._headers(),
        body: JSON.stringify({ book: { rating } })
      })
    } catch (e) {
      // silent fail
    }
  }

  _headers() {
    const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'X-CSRF-Token': token
    }
  }
}
