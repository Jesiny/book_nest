import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="rating"
export default class extends Controller {
  static targets = ["input", "star", "display"];
  static values = { url: String, readonly: Boolean };

  connect() {
    this.updateVisualState();
    this.updateDisplay();
  }

  updateVisualState() {
    const currentRating = this.getCurrentRating();

    this.starTargets.forEach((star, index) => {
      const starValue = index + 1;
      const svg = star.querySelector("svg");
      const path = svg.querySelector("path");
      const isFull = currentRating >= starValue;
      const isHalf = !isFull && currentRating >= starValue - 0.5;

      svg.classList.toggle("text-yellow-400", isFull || isHalf);
      svg.classList.toggle("text-gray-300", !isFull && !isHalf);

      path.setAttribute(
        "fill",
        isFull
          ? "currentColor"
          : isHalf
          ? `url(#half-star-gradient-${index})`
          : "none"
      );
    });
  }

  getCurrentRating() {
    const value = this.hasInputTarget
      ? this.inputTarget.value
      : this.element.dataset.rating;

    return parseFloat(value) || 0;
  }

  setRating(rating) {
    if (this.hasInputTarget) {
      this.inputTarget.value = rating;
    }
    this.updateVisualState();
    this.updateDisplay();
  }

  updateDisplay() {
    if (this.hasDisplayTarget) {
      const rating = this.getCurrentRating();
      this.displayTarget.textContent = `${rating}/5`;
    }
  }

  handleStarClick(event) {
    if (this.readonlyValue) return;

    const star = event.currentTarget;
    const value = this.starTargets.indexOf(star) + 1;
    const { left, width } = star.getBoundingClientRect();

    const isLeftHalf = event.clientX - left < width / 2;
    const rating = value - (isLeftHalf ? 0.5 : 0);

    this.setRating(rating);
  }
}
