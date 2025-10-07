import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="image-preview"
export default class extends Controller {
  static targets = ["input", "preview"]

  preview() {
    const file = this.inputTarget?.files?.[0]
    if (!file) return
    const reader = new FileReader()
    reader.onload = (e) => {
      if (this.hasPreviewTarget) {
        this.previewTarget.src = e.target.result
        this.previewTarget.classList.remove('hidden')
      }
    }
    reader.readAsDataURL(file)
  }
}
