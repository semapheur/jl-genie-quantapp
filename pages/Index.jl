module Index

using GenieFramework

@genietools

tickers = [
  Dict("label" => "ABB Ltd ADR (ABBNY) - PINX", "value" => "0P00000016_USD"),
  Dict("label" => "ACADIA Pharmaceuticals Inc (ACAD) - XNAS", "value" => "0P0000001A_USD"),
  Dict(
    "label" => "Advanced Emissions Solutions Inc (ADES) - XNAS",
    "value" => "0P0000001K_USD",
  ),
  Dict("label" => "ASML Holding NV ADR (ASML) - XNAS", "value" => "0P0000002X_USD"),
  Dict("label" => "AUO Corp ADR (AUOTY) - PINX", "value" => "0P00000039_USD"),
  Dict("label" => "AXA SA ADR (AXAHY) - PINX", "value" => "0P0000003E_USD"),
  Dict("label" => "Acadia Realty Trust (AKR) - XNYS", "value" => "0P00000046_USD"),
  Dict("label" => "Adams Resources & Energy Inc (AE) - XASE", "value" => "0P0000005B_USD"),
  Dict(
    "label" => "Addvantage Technologies Group Inc (AEY) - XNAS",
    "value" => "0P0000005E_USD",
  ),
  Dict("label" => "Adobe Inc (ADBE) - XNAS", "value" => "0P0000005M_USD"),
]

@app begin
  @out stocks = tickers
  @in selected_stock = ""
end

@methods """
fetchOptions: async function(query) {
  if (query.length < 2) {
    return
  }
  
  this.options = await fetch(
    `/api/search/ticker/stock/\${query}`,
    {
      headers: {
        'Accept': 'application/json'
      }
    }
  ).then(response => response.json())
},
filterFn: async function(val, update, abort) {
  if (val.length < 2) {
    abort()
    return
  }

  update(() => {
    console.log(this.options)
    this.options = this.options
  })
}
"""

function ui()
  row([
    select(
      :selected_stock,
      options=:stocks,
      optionlabel="label",
      optionvalue="value",
      useinput=true,
      inputdebounce=500,
      clearable=true,
      label="Ticker",
      var"@input-value"="fetchOptions",
      var"@filter"="filterFn",
    ),
  ])
end
end