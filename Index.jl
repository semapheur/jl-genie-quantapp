module Index

using GenieFramework

@genietools

tickers = [
  "AAPL",
  "TSLA",
  "MSFT",
  "A",
  "AAL",
  "AAP",
  "ABBV",
  "ABC",
  "ABMD",
  "ABT",
  "ACN",
  "ADBE",
  "ADI",
  "ADM",
  "ADP",
  "ADSK",
  "AEE",
  "AEP",
  "AES",
  "AFL",
  "AIG",
  "AIZ",
  "AJG",
  "AKAM",
  "ALB",
  "ALGN",
  "ALK",
  "ALL",
  "ALLE",
  "ALXN",
  "AMAT",
  "AMCR",
  "AMD",
  "AME",
  "AMGN",
  "AMP",
  "AMT",
  "AMZN",
  "ANET",
  "ANSS",
  "ANTM",
  "AON",
  "AOS",
  "APA",
  "APD",
  "APH",
  "APTV",
  "ARE",
  "ATO",
  "ATVI",
  "AVB",
  "AVGO",
  "AVY",
  "AWK",
  "AXP",
  "AZO",
  "BA",
  "BAC",
  "BAX",
  "BBY",
  "BDX",
  "BEN",
  "BF.B",
  "BIIB",
  "BIO",
  "BK",
  "BKNG",
  "BKR",
  "BLK",
  "BLL",
  "BMY",
  "BR",
  "BRK.B",
  "BSX",
  "BWA",
  "BXP",
  "C",
  "CAG",
  "CAH",
  "CARR",
  "CAT",
  "CB",
  "CBOE",
  "CBRE",
  "CCI",
  "CCL",
  "CDNS",
  "CDW",
  "CE",
  "CERN",
  "CF",
  "CFG",
  "CHD",
  "CHRW",
  "CHTR",
  "CI",
  "CINF",
  "CL",
  "CLX",
  "CMA",
]

test = [Dict("label" => "Apple Inc", "value" => "AAPL")]

@app begin
  @out stocks = Vector{Dict{String,String}}()
  @in selected_stock = ""
end

@methods """
filterFn: function(val, update) {
  if (val === '') {
    update(() => {
      this.options = []
    })
    return
  }

  console.log(this)
  
  update(() => {
    const needle = val.toLowerCase()
    this.options = stocks.filter(v => v.toLowerCase().indexOf(needle) > -1)
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
      var"@filter"="filterFn", #"v-on:filter"
    ),
  ])
end
end