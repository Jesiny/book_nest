import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chat"
export default class extends Controller {
  static targets = ["input", "list"]
  static values = { url: String }

  async send(event) {
    event.preventDefault()
    if (!this.urlValue) return
    const message = this.inputTarget?.value || ''
    if (!message.trim()) return

    this._append("user", message)
    this.inputTarget.value = ''

    const res = await fetch(this.urlValue, {
      method: 'POST',
      headers: this._headers(),
      body: new URLSearchParams({ message })
    })
    if (!res.ok) return
    const data = await res.json()
    if (data.reply) this._append("assistant", data.reply)
  }

  _append(role, text) {
    if (!this.hasListTarget) return
    const li = document.createElement('li')
    li.className = role === 'user' ? 'text-right' : 'text-left'
    li.textContent = text
    this.listTarget.appendChild(li)
  }

  _headers() {
    const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    return { 'Accept': 'application/json', 'X-CSRF-Token': token, 'Content-Type': 'application/x-www-form-urlencoded' }
  }
}
