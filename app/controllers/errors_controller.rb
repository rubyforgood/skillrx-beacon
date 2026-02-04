class ErrorsController < ApplicationController
  def not_found
    render status: :not_found
  end

  def audio_not_found
    render status: :not_found
  end

  def pdf_not_found
    render status: :not_found
  end

  def unsupported_browser
    render layout: false
  end
end
