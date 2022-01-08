__IN DEVELOPMENT__

# AlphaVantage.jl

Personal API wrapper for AlphaVantage.

# Setup

__Install Package__

```julia
pkg> add https://github.com/Matthew-Amos/AlphaVantage.jl.git
```

__AlphaVantage API Access__

Visit
[alphavantage.co/support/#api-key](https://www.alphavantage.co/support/#api-key)
for a free API key.

__API Key Environment Variable__

For your respective system, define the environment variable
`ALPHA_VANTAGE_API_KEY`. For example, in linux add the following to
.bashrc:

```bash
export ALPHA_VANTAGE_API_KEY="your_key_here"
```

If an environment variable is not set you can manually specify it as described
below.

# Use

```julia
using AlphaVantage
```

__Instantiating Client__

```julia
# API key set in environment variable
client = AlphaVantageClient()

# API key not in environment variable
client = AlphaVantageClient("your_key_here")
client = AlphaVantageClient(;key="your_key_here")
```

__Making API Calls__

API calls are made via `Base.get(c::AlphaVantageClient, f::AVFunction,
p::Dict{String})`.

- All request parameters should be represented in a `Dict{String}`. For
  example, `Dict("symbol" => "IBM")`.
- Every API endpoint function has a corresponding data type. For instance, the
  _TIME_SERIES_INTRADAY_ function is represented with the
`TIME_SERIES_INTRADAY` data type. These structs have no fields and have a 1:1
naming convention. You do not need to specify the _function_ API parameter in
the parameter dictionary as this is handled automatically.
- You also do not need to specify the _apicall_ parameter in the dictionary as
  this is also inserted automatically.


```julia
# TIME_SERIES_MONTHLY_ADJUSTED call
p = Dict("symbol" => "AAPL")
ts = get(client, TIME_SERIES_MONTHLY_ADJUSTED, p)

# Note that the structs don't need to be instantiated, but for clarity,
# this will also work:
# ts = get(client, TIME_SERIES_MONTHLY_ADJUSTED(), p) 
```

# Default Pre and Post Processing

Sensible defaults will be imposed on your parameter dictionary as well as the
returned results. If desired, this behavior can be altered by overriding
appropriate methods of the following functions.

__`preprocess(f::A where A <: AVFunction, params)`__

Returns a modified _params_ `Dict`.

__`postprocess(f::A where A <: AVFunction, resp)`__

Returns a modified _resp_. Initially, _resp_ will be a `Vector{UInt8}` copy
from the HTTP response body.

# Response Formats

- __Time Series:__ `DataFrame`
- __Financial Statements:__ `Dict("annual" => DataFrame, "quarterly" =>
  DataFrame)`
- Others not yet implemented.

