module StockTicker
using DataFrames
using GenieFramework
using SQLite

function search(limit=10)
  db = SQLite.DB("db/tickers.db")
  con = DBInterface

  sql = """
    SELECT 
      company || " (" || ticker || ") - " || exchange AS label,
      id || "_" || currency AS value
    FROM stocks WHERE label LIKE :keyword
    LIMIT $limit
  """
  options = DataFrame(con.execute(db, sql, (keyword = "%$(params(:query))%")))
  SQLite.close(db)
  Genie.Renderer.Json.json([Dict(zip(names(options), row)) for row in eachrow(options)])
end

end