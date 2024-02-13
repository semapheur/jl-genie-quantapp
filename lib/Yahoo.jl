module Yahoo

using Dates
using DataFrames, HTTP, JSON

headers = Dict(
  "User-Agent" => "Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/112.0",
  "Accept" => "application/json, text/plain, */*",
  "Accept-Language" => "en-US,en;q=0.5",
  #"Accept-Encoding" => "gzip, deflate, br",
  #"DNT" => "1",
  #"Connection" => "keep-alive",
  #"Sec-Fetch-Dest" => "empty",
  #"Sec-Fetch-Mode" => "cors",
  #"Sec-Fetch-Site" => "same-site",
  #"Sec-GPC" => "1",
  #"Cache-Control" => "max-age=0",
)

function ohlcv(ticker::String, start_date::Date)
  start_stamp = Int(Dates.datetime2unix(DateTime(start_date)))
  end_stamp = Int(Dates.datetime2unix(DateTime(Dates.today())))
  params = (
    formatted="true",
    #crumb = "0/sHE2JwnVF",
    lang="en-US",
    region="US",
    includeAdjustedClose="true",
    interval="1d",
    period1=string(start_stamp),
    period2=string(end_stamp),
    events="div|split",
    corsDomain="finance.yahoo.com",
  )
  url = "https://query2.finance.yahoo.com/v8/finance/chart/$ticker"

  r = HTTP.get(url, headers=headers, query=params)
  data = JSON.parse(String(r.body))
  data = data["chart"]["result"][1]

  date = Date.(Dates.unix2datetime.(data["timestamp"]))
  ohlcv = data["indicators"]["quote"][1]

  df = DataFrame(
    date=date,
    open=ohlcv["open"],
    high=ohlcv["high"],
    low=ohlcv["low"],
    close=ohlcv["close"],
    volume=ohlcv["volume"],
  )
  return df
end

end