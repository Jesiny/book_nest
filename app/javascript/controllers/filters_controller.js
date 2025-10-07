import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="filters"
export default class extends Controller {
  static targets = ["query", "status", "rating", "list", "item"];

  filter() {
    const q = (this.queryTarget?.value || "").toLowerCase();
    const status = this.statusTarget?.value || "";
    const minRating = parseFloat(this.ratingTarget?.value || "0");

    this.itemTargets.forEach((element) => {
      const title = (element.dataset.title || "").toLowerCase();
      const itemStatus = element.dataset.status || "";
      const itemRating = parseFloat(element.dataset.rating || "0");

      const matchesQuery = !q || title.includes(q);
      const matchesStatus = !status || status === itemStatus;
      const matchesRating = isNaN(minRating) || itemRating >= minRating;

      element.classList.toggle(
        "hidden",
        !(matchesQuery && matchesStatus && matchesRating)
      );
    });
  }
}
