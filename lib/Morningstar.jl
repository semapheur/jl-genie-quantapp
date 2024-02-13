module Morningstar

using Dates
using DataFrames, HTTP, JSON3, NamedTupleTools, StructTypes

import Base: @kwdef

export ohlvc, stock_tickers

@kwdef mutable struct ScreenerParams
  page::UInt = 1
  pageSize::UInt
  sortOrder::String = "Name asc"
  outputType::String = "json"
  version::UInt = 1
  languageId::String = "en-US"
  currencyId::String = "NOK"
  filters::String = ""
  filterDataPoints::String = ""
  term::String = ""
  securityDataPoints::String = ""
  universeIds::String = ""
  subUniverseId::String = ""
end

@kwdef mutable struct StockInfo
  Id::String = ""
  Ticker::String = ""
  Name::String = ""
  LegalName::String = ""
  ExchangeId::String = ""
  Currency::String = ""
  SectorName::String = ""
  IndustryName::String = ""
  ClosePrice::Float64 = 0.0
end

mutable struct StockResult
  total::UInt
  page::UInt
  pageSize::UInt
  rows::Vector{StockInfo}
  StockResult() = new()
end

StructTypes.StructType(::Type{StockInfo}) = StructTypes.Mutable()
StructTypes.StructType(::Type{StockResult}) = StructTypes.Mutable()

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

function ohlcv(id::String, currency::String, start_date::Date)
  params = (
    id="$(id)]3]0]",
    currencyId=currency,
    idtype="Morningstar",
    frequency="daily",
    startDate=Dates.format(start_date, "yyyy-mm-dd"),
    #end_date = Dates.format(end_date, "yyyy-mm-dd"),
    outputType="COMPACTJSON",
    applyTrackRecordExtension="true",
  )

  url = "https://tools.morningstar.no/api/rest.svc/timeseries_ohlcv/dr6pz9spfi"

  r = HTTP.get(url, headers=headers, query=params)
  ohlcv = JSON.parse(String(r.body))

  data =
    [(date=i[1], open=i[2], high=i[3], low=i[4], close=i[5], volume=i[6]) for i in ohlcv]

  df = DataFrame(data)
  df.date = Dates.unix2datetime.(df.date ./ 1000)

  return df
end

function screener_api(params::ScreenerParams)::StockResult
  url = "https://tools.morningstar.co.uk/api/rest.svc/dr6pz9spfi/security/screener"
  r = HTTP.get(url, headers=headers, query=ntfromstruct(params), timeout=60)
  return JSON3.read(String(r.body), StockResult)
end

function fallback(params::ScreenerParams, bound::UInt, price::Float64)::Vector{StockInfo}
  params.page = 1
  params.filters = "ClosePrice:LTE:$price"

  records::Vector{StockInfo} = []

  while price > 0 && length(records) < bound
    data = screener_api(params)
    append!(records, data.rows)
    price = Float64(data.rows[end].ClosePrice)
    params.filters = "ClosePrice:LTE:$price"
  end

  return records
end

function stock_tickers()
  page_size = UInt(50000)

  params = ScreenerParams(
    pageSize=page_size,
    sortOrder="ClosePrice desc",
    securityDataPoints=join(fieldnames(StockInfo), "|"),
    universeIds="E0WWE\$\$ALL",
  )

  records::Vector{StockInfo} = []
  data = screener_api(params)
  total = UInt(data.total)

  append!(records, data.rows)

  try
    if total > page_size
      pages = UInt(ceil(total / page_size))

      for p = 2:pages
        params.page = p
        data = screener_api(params)
        append!(records, data.rows)
      end
    end
  catch
    price = Float64(records[end].ClosePrice)
    append!(records, fallback(params, total, price))
  end

  df = DataFrame(records)
  filter!(:ClosePrice => x -> x > 0.0, df)
  select!(df, Not(:ClosePrice))
  rename!(
    df,
    Dict(
      :Id => :id,
      :Ticker => :ticker,
      :Name => :company,
      :LegalName => :legal_name,
      :ExchangeId => :exchange,
      :Currency => :currency,
      :SectorName => :sector,
      :IndustryName => :industry,
    ),
  )
  transform!(df, :exchange => (x -> replace.(x, r"^EX(\$+|TP\$+)" => "")) => :exchange)
  sort!(df, :id)

  return df
end

end