import Widget from require "lapis.html"


class Top extends require "widgets.base"
  content: =>
    for quote in *@quotes
      @render_quote quote



