import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="audio-player"
export default class extends Controller {
  static targets = [
    "audio", "loading", "controls",
    "playButton", "playIcon", "pauseIcon",
    "progressBar", "progress",
    "currentTime", "duration",
    "volumeSlider", "volumeIcon", "muteIcon"
  ]

  connect() {
    this.isPlaying = false
    this.isMuted = false
  }

  loaded() {
    this.loadingTarget.classList.add("hidden")
    this.controlsTarget.classList.remove("hidden")
    this.durationTarget.textContent = this.formatTime(this.audioTarget.duration)
  }

  togglePlay() {
    if (this.isPlaying) {
      this.audioTarget.pause()
      this.playIconTarget.classList.remove("hidden")
      this.pauseIconTarget.classList.add("hidden")
    } else {
      this.audioTarget.play()
      this.playIconTarget.classList.add("hidden")
      this.pauseIconTarget.classList.remove("hidden")
    }
    this.isPlaying = !this.isPlaying
  }

  updateProgress() {
    const percent = (this.audioTarget.currentTime / this.audioTarget.duration) * 100
    this.progressTarget.style.width = `${percent}%`
    this.currentTimeTarget.textContent = this.formatTime(this.audioTarget.currentTime)
  }

  seek(event) {
    const rect = this.progressBarTarget.getBoundingClientRect()
    const percent = (event.clientX - rect.left) / rect.width
    this.audioTarget.currentTime = percent * this.audioTarget.duration
  }

  ended() {
    this.isPlaying = false
    this.playIconTarget.classList.remove("hidden")
    this.pauseIconTarget.classList.add("hidden")
    this.audioTarget.currentTime = 0
  }

  changeVolume() {
    const volume = this.volumeSliderTarget.value / 100
    this.audioTarget.volume = volume

    if (volume === 0) {
      this.showMuteIcon()
    } else {
      this.showVolumeIcon()
    }
  }

  toggleMute() {
    this.isMuted = !this.isMuted
    this.audioTarget.muted = this.isMuted

    if (this.isMuted) {
      this.showMuteIcon()
    } else {
      this.showVolumeIcon()
    }
  }

  showMuteIcon() {
    this.volumeIconTarget.classList.add("hidden")
    this.muteIconTarget.classList.remove("hidden")
  }

  showVolumeIcon() {
    this.volumeIconTarget.classList.remove("hidden")
    this.muteIconTarget.classList.add("hidden")
  }

  formatTime(seconds) {
    if (isNaN(seconds)) return "0:00"

    const mins = Math.floor(seconds / 60)
    const secs = Math.floor(seconds % 60)
    return `${mins}:${secs.toString().padStart(2, "0")}`
  }
}
