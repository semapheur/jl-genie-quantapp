module Index

using GenieFramework, PlotlyBase, DataFrames, Dates
using Main.Morningstar
#include("lib/morningstar.jl")

@genietools

@app begin
  @out stocks = Vector{Dict{String,String}}()
  @in selected_stock = ""
  @in start_date = "2000-01-01"
  @in end_date = Dates.format(Dates.today(), "yyyy-mm-dd")
  @out ohlcv = DataFrame(date=[], open=[], high=[], low=[], close=[], volume=[])
  @out plot_data =
    Base.invokelatest(PlotlyBase.GenericTrace{Dict{Symbol,Any}}, Dict{Symbol,Any}())
  @out plot_layout = PlotlyBase.Layout()

  @onchange selected_stock begin
    id, currency = split(selected_stock, "_")
    ohlcv = Morningstar.ohlcv(string(id), string(currency))
    plot_data = scatter(x=ohlcv.date, y=ohlcv.close, mode="lines")
    plot_layout = PlotlyBase.Layout(
      xaxis=attr(title="Date"),
      yaxis=attr(title="Close Price [$currency]"),
    )
  end

  @onchange start_date, end_date begin
    relayout!(plot_layout, xaxis_range=[start_date, end_date])
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
  htmldiv([
    Genie.Renderer.Html.select(
      :selected_stock,
      options=:stocks,
      optionlabel="label",
      optionvalue="value",
      emitvalue=true,
      mapoptions=true,
      useinput=true,
      inputdebounce=500,
      clearable=true,
      label="Ticker",
      var"@filter"="filterFn",
    ),
    textfield(
      "Start date",
      :start_date,
      clearable=true,
      filled=true,
      [
        icon(
          "event",
          class="cursor-pointer",
          [popupproxy([datepicker(:start_date, label="Start Date", mask="YYYY-MM-DD")])],
        ),
      ],
    ),
    textfield(
      "End date",
      :end_date,
      clearable=true,
      filled=true,
      [
        icon(
          "event",
          class="cursor-pointer",
          [
            popupproxy([
              datepicker(:end_date, label="End Date", todaybtn=true, mask="YYYY-MM-DD"),
            ]),
          ],
        ),
      ],
    ),
    plot(:plot_data, layout=:plot_layout),
  ],)
end
end