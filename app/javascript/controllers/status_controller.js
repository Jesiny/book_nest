import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="status"
export default class extends Controller {
  static values = { url: String }

  async change(event) {
    if (!this.urlValue) return
    const status = event.currentTarget.value
    try {
      await fetch(this.urlValue, {
        method: "PATCH",
        headers: this._headers(),
        body: JSON.stringify({ book: { status } })
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
