import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="folder-tree"
// Simple controller for folder tree interactions
export default class extends Controller {
  connect() {
    // Future: Add expand/collapse functionality for folders
  }

  toggleFolder(event) {
    const folderId = event.currentTarget.dataset.folderId
    const filesContainer = document.getElementById(`folder-files-${folderId}`)

    if (filesContainer) {
      filesContainer.classList.toggle("hidden")

      // Toggle chevron icon
      const chevron = event.currentTarget.querySelector(".chevron-icon")
      if (chevron) {
        chevron.classList.toggle("rotate-90")
      }
    }
  }
}
