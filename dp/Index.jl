module Index
using GenieFramework

@genietools

@app begin
  @in selected_ticker = ""
  @out tickers = ["AAPL", "GOOGL"]
end

@methods """
filterFn: async function(val, update) {
  if (val === '') {
    update(() => {
      this.options = []
    })
    return
  }
    
  async update(() => {
    options.value = await fetch(`/api/search/ticker/\${val}`)
  })
}
"""

function ui()
  row([
    select(
      :selected_ticker,
      options=:tickers,
      useinput=true,
      inputdebounce=500,
      clearable=true,
      label="Ticker",
      var"@filter"="filterFn", #"v-on:filter"
    ),
  ])
end
end