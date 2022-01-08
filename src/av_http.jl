"""
This submodule contains the HTTP interface to the AlphaVantage API.

The `AlphaVantageClient` struct owns the data needed for the HTTP requests.

A `Base.get` method takes as arguments the above client, a data type parameter that inherits from
AVFunction (see av_types.jl), and a Dict of query parameters. It then executes the HTTP request
as well as dispatches to appropriate pre/postprocessor functions (see av_handlers.jl).
"""

"""
HTTP client for connecting to AlphaVantage API.

```
AlphaVantageClient(;scheme, host, key)
```

Appropriate defaults are set for `scheme` and `host` fields. You must provide an API key via a named parameter
or by creating an ALPHA_VANTAGE_API_KEY environment variable prior to launching your Julia session. See
https://www.alphavantage.co/support/#api-key to obtain an API key. If a key is not provided, the default is
to use "demo" which may have restricted support.
"""
struct AlphaVantageClient
  scheme::String
  host::String
  key::String
end

"Retrieve API key from environment, user argument, or use the default demo key."
_api_key(k=get(ENV, ENV_VARIABLE_API_KEY, "")) = if k == "" DEFAULT_API_KEY else k end

AlphaVantageClient(;scheme=HTTP_SCHEME, host=HTTP_HOST, key=_api_key()) = AlphaVantageClient(scheme, host, key)
AlphaVantageClient(k::String) = AlphaVantageClient(;key=k)

"Dynamically creates and evaluates an HTTP.URI call for a given API request."
_create_uri(c::AlphaVantageClient, q::D where D <: Dict{String}) = string(HTTP.URI(scheme=c.scheme, host=c.host, query=q))

# `Base.get` method dispatching
function Base.get(c::AlphaVantageClient, params)
  params["apikey"] = c.key
  req = HTTP.request("GET", _create_uri(c, params))
  
  if req.status != 200
      throw("HTTP request returned status code $(req.status)")
  end
  
  deepcopy(req.body)
end

function Base.get(c::AlphaVantageClient, f::A where A <: AVFunction, params=Dict{String, Any}())
  params["function"] = string(f)
  params = preprocess(f, params)
  resp = get(c, params)
  resp = postprocess(f, resp)
  resp
end

function Base.get(c::AlphaVantageClient, f::DataType, params=Dict{String, Any}())
  get(c, f(), params)
end
