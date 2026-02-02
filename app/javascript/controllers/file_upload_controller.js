import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="file-upload"
export default class extends Controller {
  static targets = [
    "fileInput",
    "dropzone",
    "dropzoneInner",
    "preview",
    "fileList",
    "totalSize",
    "submitButton",
    "folderPath",
    "typeFiles",
    "typeFolder",
    "instructions"
  ]

  connect() {
    this.files = []
  }

  toggleUploadType(event) {
    const isFolder = event.target.value === "folder"

    if (isFolder) {
      this.fileInputTarget.setAttribute("webkitdirectory", "")
      this.fileInputTarget.setAttribute("directory", "")
      this.instructionsTarget.textContent = "Select a folder to upload all its contents."
    } else {
      this.fileInputTarget.removeAttribute("webkitdirectory")
      this.fileInputTarget.removeAttribute("directory")
      this.instructionsTarget.textContent = "Upload any file type. Maximum 100MB per file."
    }

    // Clear current selection
    this.fileInputTarget.value = ""
    this.clearPreview()
  }

  filesSelected(event) {
    this.files = Array.from(event.target.files)
    this.updatePreview()
  }

  dragover(event) {
    event.preventDefault()
  }

  dragenter(event) {
    event.preventDefault()
    this.dropzoneInnerTarget.classList.add("border-indigo-500", "bg-indigo-50")
  }

  dragleave(event) {
    event.preventDefault()
    this.dropzoneInnerTarget.classList.remove("border-indigo-500", "bg-indigo-50")
  }

  drop(event) {
    event.preventDefault()
    this.dropzoneInnerTarget.classList.remove("border-indigo-500", "bg-indigo-50")

    const droppedFiles = event.dataTransfer.files
    if (droppedFiles.length > 0) {
      // Create a new DataTransfer to set on the file input
      const dataTransfer = new DataTransfer()
      for (const file of droppedFiles) {
        dataTransfer.items.add(file)
      }
      this.fileInputTarget.files = dataTransfer.files
      this.files = Array.from(droppedFiles)
      this.updatePreview()
    }
  }

  updatePreview() {
    if (this.files.length === 0) {
      this.clearPreview()
      return
    }

    this.previewTarget.classList.remove("hidden")
    this.submitButtonTarget.disabled = false

    // Build file list
    let html = ""
    let totalSize = 0

    this.files.forEach((file, index) => {
      totalSize += file.size
      html += `
        <li class="px-4 py-3 flex items-center justify-between text-sm">
          <div class="flex items-center min-w-0 flex-1">
            <svg class="w-5 h-5 text-gray-400 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
            <span class="ml-2 truncate">${this.escapeHtml(file.name)}</span>
          </div>
          <span class="text-gray-500 ml-2">${this.formatFileSize(file.size)}</span>
        </li>
      `
    })

    this.fileListTarget.innerHTML = html
    this.totalSizeTarget.textContent = `${this.files.length} file(s) selected (${this.formatFileSize(totalSize)} total)`
  }

  clearPreview() {
    this.previewTarget.classList.add("hidden")
    this.fileListTarget.innerHTML = ""
    this.totalSizeTarget.textContent = ""
    this.submitButtonTarget.disabled = true
    this.files = []
  }

  formatFileSize(bytes) {
    if (bytes === 0) return "0 Bytes"
    const k = 1024
    const sizes = ["Bytes", "KB", "MB", "GB"]
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + " " + sizes[i]
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
