import Widget from require "lapis.html"


class Random extends require "widgets.base"
  content: =>
    for quote in *@paginator\get_page @pagenum
      @render_quote quote
    @paginate @paginator



