module App
using GenieFramework

@genietools
include("pages/Index.jl")
include("api/StockTicker.jl")

@page("/", Index.ui, model = Index)
route("/api/search/ticker/stock/:query::String", StockTicker.search, method=GET)
end