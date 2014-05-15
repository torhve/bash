import Widget from require "lapis.html"


class Top extends require "widgets.base"
  content: =>
    for quote in *@paginator\get_page!
      @render_quote quote
    paginate(@paginator)



