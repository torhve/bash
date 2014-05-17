import Widget from require "lapis.html"

class Tag extends require "widgets.base"
  content: =>
    div class: "body", ->
      h2 ->
        text 'All quotes with tag ', ->
        i ->
          text @tag

      for quote in *@paginator\get_page @pagenum
        @render_quote quote
      @paginate(@paginator)
