include("../../lib/Morningstar.jl")

using SQLite, .Morningstar

function seed()
  df = stock_tickers()
  db = SQLite.DB("../../db/dev.sqlite")
  SQLite.load!(df, db, "stocks")
end