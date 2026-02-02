import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="autocomplete"
export default class extends Controller {
  static targets = ["input", "results"]
  static values = { url: String }

  connect() {
    this.selectedIndex = -1
    this.debounceTimer = null

    // Close dropdown when clicking outside
    document.addEventListener("click", this.handleClickOutside.bind(this))
  }

  disconnect() {
    document.removeEventListener("click", this.handleClickOutside.bind(this))
  }

  search() {
    clearTimeout(this.debounceTimer)

    const query = this.inputTarget.value.trim()

    if (query.length < 2) {
      this.hideResults()
      return
    }

    this.debounceTimer = setTimeout(() => {
      this.fetchSuggestions(query)
    }, 200)
  }

  async fetchSuggestions(query) {
    try {
      const response = await fetch(`${this.urlValue}?q=${encodeURIComponent(query)}`)
      const suggestions = await response.json()

      if (suggestions.length > 0) {
        this.showResults(suggestions)
      } else {
        this.hideResults()
      }
    } catch (error) {
      console.error("Autocomplete error:", error)
      this.hideResults()
    }
  }

  showResults(suggestions) {
    this.selectedIndex = -1

    const html = suggestions.map((item, index) => `
      <div
        class="px-4 py-2 cursor-pointer hover:bg-gray-100 flex items-center"
        data-index="${index}"
        data-value="${this.escapeHtml(item.value)}"
        data-action="click->autocomplete#select mouseenter->autocomplete#highlight"
      >
        <span class="text-xs text-gray-400 w-12">${this.typeLabel(item.type)}</span>
        <span class="text-gray-900">${this.highlightMatch(item.value, this.inputTarget.value)}</span>
      </div>
    `).join("")

    this.resultsTarget.innerHTML = html
    this.resultsTarget.classList.remove("hidden")
  }

  hideResults() {
    this.resultsTarget.classList.add("hidden")
    this.resultsTarget.innerHTML = ""
    this.selectedIndex = -1
  }

  select(event) {
    const value = event.currentTarget.dataset.value
    this.inputTarget.value = value
    this.hideResults()
    this.inputTarget.form.submit()
  }

  highlight(event) {
    this.selectedIndex = parseInt(event.currentTarget.dataset.index)
    this.updateHighlight()
  }

  navigate(event) {
    const items = this.resultsTarget.querySelectorAll("[data-index]")

    if (items.length === 0) return

    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()
        this.selectedIndex = Math.min(this.selectedIndex + 1, items.length - 1)
        this.updateHighlight()
        break
      case "ArrowUp":
        event.preventDefault()
        this.selectedIndex = Math.max(this.selectedIndex - 1, 0)
        this.updateHighlight()
        break
      case "Enter":
        if (this.selectedIndex >= 0) {
          event.preventDefault()
          const selectedItem = items[this.selectedIndex]
          this.inputTarget.value = selectedItem.dataset.value
          this.hideResults()
          this.inputTarget.form.submit()
        }
        break
      case "Escape":
        this.hideResults()
        break
    }
  }

  updateHighlight() {
    const items = this.resultsTarget.querySelectorAll("[data-index]")
    items.forEach((item, index) => {
      if (index === this.selectedIndex) {
        item.classList.add("bg-gray-100")
      } else {
        item.classList.remove("bg-gray-100")
      }
    })
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hideResults()
    }
  }

  typeLabel(type) {
    const labels = {
      tag: "Tag",
      topic: "Topic",
      author: "Author"
    }
    return labels[type] || type
  }

  highlightMatch(text, query) {
    const regex = new RegExp(`(${this.escapeRegex(query)})`, "gi")
    return text.replace(regex, "<strong>$1</strong>")
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }

  escapeRegex(string) {
    return string.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")
  }
}
