import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tree"
// Handles expandable/collapsible tree navigation
export default class extends Controller {
  static targets = ["item", "children"]

  connect() {
    // Initialize all items as collapsed
    this.childrenTargets.forEach(children => {
      children.classList.add("hidden")
    })
  }

  toggle(event) {
    const item = event.currentTarget
    const children = item.nextElementSibling

    if (children && children.dataset.treeTarget === "children") {
      children.classList.toggle("hidden")

      // Update the expand/collapse icon
      const icon = item.querySelector("[data-icon]")
      if (icon) {
        icon.classList.toggle("rotate-90")
      }
    }
  }
}
