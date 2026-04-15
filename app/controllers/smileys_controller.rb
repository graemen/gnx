class SmileysController < ApplicationController
  include SmileyHelper

  def index
    @smileys = SmileyHelper::SMILEYS
  end
end
