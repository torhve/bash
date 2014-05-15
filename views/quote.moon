import Widget from require "lapis.html"


class Quote extends require "widgets.base"
  content: =>
    @render_errors!
    @render_messages!
    @render_quote @quote



