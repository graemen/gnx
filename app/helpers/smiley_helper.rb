module SmileyHelper
  SMILEYS = {
    "::)" => "rolleyes.gif",
    ":)" => "smiley.gif",
    ":l" => "tongue.gif",
    ":-[" => "embarassed.gif",
    ":-X" => "lipsealed.gif",
    ":-\\" => "undecided.gif",
    ";)" => "wink.gif",
    ":D" => "cheesy.gif",
    ";D" => "grin.gif",
    "=:(" => "angry.gif",
    ":(" => "sad.gif",
    ":o" => "shocked.gif",
    "8)" => "cool.gif",
    ":#" => "mad.gif",
    ":-*" => "kiss.gif",
    ":'(" => "cry.gif",
    "???" => "huh.gif",
    ":green" => "green.gif",
    ":tdown" => "thumbdown.gif",
    ":tup" => "thumbup.gif",
    ":gun" => "gun.gif",
    ":drink" => "drink.gif",
    ":bounce" => "bounce.gif",
    ":biggun" => "biggun.gif",
    ":eatme" => "eatme.gif",
    ":vomit" => "vomit.gif",
    ":spliff" => "spliff.gif",
    ":tongue" => "grimace.gif",
    ":pig" => "pig.gif",
    ":pray" => "pray.gif",
    ":babygun" => "babygun.gif",
    ":ninja" => "ninja.gif"
  }.freeze

  def smilize(text)
    return "" if text.blank?
    result = text.dup
    # Process longer codes first to avoid partial matches (e.g. ::) before :))
    SMILEYS.sort_by { |code, _| -code.length }.each do |code, filename|
      img_tag = "<img src=\"/smileys/#{filename}\" alt=\"#{ERB::Util.html_escape(code)}\">"
      result.gsub!(code, img_tag)
    end
    result
  end
end
