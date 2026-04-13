class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_current_theme

  private

  def set_current_theme
    @current_theme = if ThemesController::AVAILABLE_THEMES.include?(cookies[:theme])
                       cookies[:theme]
                     else
                       "default"
                     end
  end
end
