import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pdf-viewer"
// Uses PDF.js for rendering - loads dynamically
export default class extends Controller {
  static targets = ["loading", "container", "error", "currentPage", "totalPages", "zoomLevel"]
  static values = { url: String }

  async connect() {
    this.currentPage = 1
    this.scale = 1.5
    this.pdfDoc = null

    if (this.urlValue) {
      await this.loadPdf()
    }
  }

  async loadPdf() {
    try {
      // Dynamically load PDF.js from CDN
      if (!window.pdfjsLib) {
        await this.loadPdfJs()
      }

      window.pdfjsLib.GlobalWorkerOptions.workerSrc =
        "https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.worker.min.js"

      this.pdfDoc = await window.pdfjsLib.getDocument(this.urlValue).promise
      this.totalPagesTarget.textContent = this.pdfDoc.numPages

      this.loadingTarget.classList.add("hidden")
      this.containerTarget.classList.remove("hidden")

      await this.renderAllPages()
    } catch (error) {
      console.error("PDF load error:", error)
      this.loadingTarget.classList.add("hidden")
      this.errorTarget.classList.remove("hidden")
    }
  }

  async loadPdfJs() {
    return new Promise((resolve, reject) => {
      const script = document.createElement("script")
      script.src = "https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.min.js"
      script.onload = resolve
      script.onerror = reject
      document.head.appendChild(script)
    })
  }

  async renderAllPages() {
    this.containerTarget.innerHTML = ""

    for (let pageNum = 1; pageNum <= this.pdfDoc.numPages; pageNum++) {
      const page = await this.pdfDoc.getPage(pageNum)
      const viewport = page.getViewport({ scale: this.scale * 2 }) // 2x for quality

      const canvas = document.createElement("canvas")
      canvas.className = "shadow-lg"
      canvas.style.width = `${viewport.width / 2}px`
      canvas.style.height = `${viewport.height / 2}px`
      canvas.width = viewport.width
      canvas.height = viewport.height

      const context = canvas.getContext("2d")
      await page.render({ canvasContext: context, viewport: viewport }).promise

      this.containerTarget.appendChild(canvas)
    }
  }

  previousPage() {
    if (this.currentPage > 1) {
      this.currentPage--
      this.currentPageTarget.textContent = this.currentPage
      this.scrollToPage(this.currentPage)
    }
  }

  nextPage() {
    if (this.pdfDoc && this.currentPage < this.pdfDoc.numPages) {
      this.currentPage++
      this.currentPageTarget.textContent = this.currentPage
      this.scrollToPage(this.currentPage)
    }
  }

  scrollToPage(pageNum) {
    const canvases = this.containerTarget.querySelectorAll("canvas")
    if (canvases[pageNum - 1]) {
      canvases[pageNum - 1].scrollIntoView({ behavior: "smooth", block: "start" })
    }
  }

  async zoomIn() {
    if (this.scale < 3) {
      this.scale += 0.25
      this.updateZoomLevel()
      await this.renderAllPages()
    }
  }

  async zoomOut() {
    if (this.scale > 0.5) {
      this.scale -= 0.25
      this.updateZoomLevel()
      await this.renderAllPages()
    }
  }

  updateZoomLevel() {
    this.zoomLevelTarget.textContent = `${Math.round(this.scale * 100)}%`
  }
}
