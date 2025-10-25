import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="image-preview"
export default class extends Controller {
  static values = { thumbClasses: [String] };
  static targets = ["file_field", "label"];

  connect() {}

  preview() {
    const file = this.file_fieldTarget.files[0];
    if (file) {
      const previewNode = document.createElement("div");
      previewNode.classList.add(
        ...this.thumbClassesValue,
        "p-2",
        "bg-gray-100",
        "rounded-lg"
      );
      const imageNode = document.createElement("img");
      imageNode.src = URL.createObjectURL(file);
      imageNode.classList.add("w-full", "h-full", "rounded-lg", "object-cover");
      imageNode.alt = "preview image";

      previewNode.appendChild(imageNode);
      this.labelTarget.replaceChildren(previewNode);
    }
  }
}
