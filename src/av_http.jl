"""
This submodule contains the HTTP interface to the AlphaVantage API.

`AlphaVantageClient` owns the data needed to construct the GET request.

A `Base.get` method takes the above client, a data type parameter that inherits from
AVFunction (see av_types.jl), and a Dict of query parameters. It executes the HTTP request
as well as dispatches to appropriate preprocessor and postprocessor functions (see av_handlers.jl).
"""

# TODO: request retry

"Contains basic HTTP information for connecting to AlphaVantage API."
struct AlphaVantageClient
    scheme::String
    host::String
    key::String
end

"Retrieve API key from environment, user argument, or use the default demo key."
_api_key(k=get(ENV, ENV_VARIABLE_API_KEY, "")) = if k == "" DEFAULT_API_KEY else k end

AlphaVantageClient(;scheme=HTTP_SCHEME, host=HTTP_HOST, key=_api_key()) = AlphaVantageClient(scheme, host, key)

"Dynamically creates and evaluates an HTTP.URI call for a given API request."
function _create_uri(c::AlphaVantageClient, q::D where D <: Dict{String})
    string(eval( Expr(
        :call,
        [
            :(HTTP.URI),
            :($(Expr(:kw, :scheme, c.scheme))),
            :($(Expr(:kw, :host, c.host))),
            :($(Expr(:kw, :query, q)))
        ]
    ) ))
end

# `Base.get` method dispatching
function Base.get(c::AlphaVantageClient, params)
    req = HTTP.request("GET", _create_uri(c, params))
    
    if req.status != 200
        throw("HTTP request returned status code $(req.status)")
    end
    
    req.body
end

function Base.get(c::AlphaVantageClient, f::A where A <: AVFunction, params=Dict{String, Any}())
    params = preprocess(f, params)
    resp = get(c, params)
    resp = postprocess(f, resp)
    resp
end
