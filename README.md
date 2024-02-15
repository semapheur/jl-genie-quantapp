Run app
```julia
julia --project # -e 'using Pkg; Pkg.activate(\".\"); Pkg.instantiate(); Pkg.precompile()'
using GenieFramework, Genie.loadapp(), up()
```

Activate the evironment (in package mode)
```julia
activate .
instantiate
```

Create resource
```julia
using Genie
Genie.Generator.newresource("resource_name")

using SearchLight
SearchLight.Generator.newresource("resource_name")
```

Migrates table
```julia
#]pkg activate .
#]pkg instantiate

using SearchLight
using SearchLightSQLite

SearchLight.Configuration.load() |> SearchLight.connect
SearchLight.Migration.init()
SearchLight.Migration.status()
SearchLight.Migration.last_up()
```

Parse Vue to Julia
```julia
using StippleUI.StippleUIParser

parse_vue_html(html_string, indent=2) |> println

```