module App
using GenieFramework

@genietools
include("pages/Index.jl")
include("api/StockTicker.jl")

Stipple.Layout.add_script("https://cdn.tailwindcss.com")

@page("/", Index.ui, model = Index)
route("/api/search/ticker/stock/:query::String", StockTicker.search, method=GET)
end