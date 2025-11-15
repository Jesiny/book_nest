import "@hotwired/turbo-rails";
import "./controllers";
import { initFlowbite } from "flowbite";

// Run once on initial page load
document.addEventListener("DOMContentLoaded", () => {
    initFlowbite();
  });
  

// Reinitialize Flowbite after Turbo navigates
document.addEventListener("turbo:load", () => {
  initFlowbite();
});

// Also handle turbo:frame-load for frame updates
document.addEventListener("turbo:frame-load", () => {
  initFlowbite();
});
