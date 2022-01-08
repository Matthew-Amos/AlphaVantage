module AlphaVantage

const HTTP_SCHEME = "https"
const HTTP_HOST = "alphavantage.co/query"
const ENV_VARIABLE_API_KEY = "ALPHA_VANTAGE_API_KEY"
const DEFAULT_API_KEY = "demo"

using HTTP
using ArgCheck

include("av_types.jl")
include("av_http.jl")
include("av_handlers.jl")

export
    AlphaVantageClient

end # module
