class ThemesController < ApplicationController
  AVAILABLE_THEMES = %w[default retro soviet antiprism bluerush chemo fcukbook kovid].freeze

  def update
    theme = params[:theme]
    theme = "default" unless AVAILABLE_THEMES.include?(theme)
    cookies[:theme] = { value: theme, expires: 1.year.from_now }
    redirect_back fallback_location: root_path
  end
end
