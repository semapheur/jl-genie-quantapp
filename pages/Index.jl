module Index

using GenieFramework

@genietools

@app begin
  @out stocks = Vector{Dict{String,String}}()
  @in selected_stock = ""

  @onchange selected_stock begin
    println(selected_stock)
  end
end

@methods """
filterFn: async function(val, update, abort) {
  if (val.length < 2) {
    abort()
    return
  }
  
  options = await fetch(
    `/api/search/ticker/stock/\${val}`,
    {
      headers: {
        'Accept': 'application/json'
      }
    }
  ).then(response => response.json())
  update(() => this.stocks = options)
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
      var"@filter"="filterFn",
    ),
    p("{{selected_stock}}"),
  ])
end
end