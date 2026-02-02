import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="favorite-toggle"
// Provides visual feedback when toggling favorites
export default class extends Controller {
  static targets = ["button", "icon"]

  connect() {
    // Turbo handles the actual toggle via turbo_stream
  }

  toggle(event) {
    // Add loading state
    this.buttonTarget.disabled = true
    this.iconTarget.classList.add("animate-pulse")
  }

  // Called after Turbo Stream replaces the element
  disconnect() {
    // Cleanup if needed
  }
}
