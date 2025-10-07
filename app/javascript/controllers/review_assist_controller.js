import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="review-assist"
export default class extends Controller {
  static targets = ["textarea"]
  static values = { url: String }

  async fetchSuggestion(event) {
    event.preventDefault()
    if (!this.urlValue) return
    const res = await fetch(this.urlValue, { method: 'POST', headers: this._headers() })
    if (!res.ok) return
    const data = await res.json()
    if (this.hasTextareaTarget && data.suggestion) {
      this.textareaTarget.value = data.suggestion
    }
  }

  _headers() {
    const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    return { 'Accept': 'application/json', 'X-CSRF-Token': token }
  }
}
