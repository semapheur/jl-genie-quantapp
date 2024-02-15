module Index

using GenieFramework, PlotlyBase, DataFrames, Dates
using Main.Morningstar
#include("lib/morningstar.jl")

@genietools

function date_input(date_var::Symbol, label::String, mask="YYYY-MM-DD")
  textfield(
    label,
    date_var,
    clearable=true,
    filled=true,
    [
      icon(
        "event",
        class="cursor-pointer",
        [popupproxy([datepicker(date_var, label=label, todaybtn=true, mask=mask)])],
      ),
    ],
  )
end

_start_date = "2000-01-01"
_end_date = Dates.format(Dates.today(), "yyyy-mm-dd")

@app begin
  @out stocks = Vector{Dict{String,String}}()
  @in selected_stock = ""
  @in start_date = _start_date
  @in end_date = _end_date
  @out ohlcv = DataFrame(date=[], open=[], high=[], low=[], close=[], volume=[])
  @out plot_data = Vector{PlotlyBase.GenericTrace{Dict{Symbol,Any}}}()
  @out plot_layout = PlotlyBase.Layout(
    xaxis=attr(
      title="Date",
      rangeselector=attr(
        buttons=[
          attr(count=1, label="1m", step="month", stepmode="backward"),
          attr(count=6, label="6m", step="month", stepmode="backward"),
          attr(count=1, label="YTD", step="year", stepmode="todate"),
          attr(count=1, label="1y", step="year", stepmode="backward"),
          attr(step="all"),
        ],
      ),
    ),
    yaxis=attr(title="Close Price", range=[_start_date, _end_date]),
  )

  #Base.invokelatest(PlotlyBase.Layout{Dict{Symbol,Any}}, Dict{Symbol,Any}())

  @onchange selected_stock begin
    id, currency = split(selected_stock, "_")
    ohlcv = Morningstar.ohlcv(string(id), string(currency))
    plot_data = [scatter(x=ohlcv.date, y=ohlcv.close, mode="lines")]
    relayout!(
      plot_layout,
      xaxis_range=[ohlcv.date[1], ohlcv.date[end]],
      yaxis=attr(title="Close Price [$currency]", range=[ohlcv.close[1], ohlcv.close[end]]),
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
  htmldiv(
    class="h-full grid grid-cols-[1fr_3fr]",
    [
      htmldiv(
        class="h-full flex flex-col gap-2",
        [
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
          date_input(:start_date, "Start Date"),
          date_input(:end_date, "End Date"),
        ],
      ),
      plot(:plot_data, layout=:plot_layout, class="h-full", style="position:static"),
    ],
  )
end
end