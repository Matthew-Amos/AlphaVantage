module AlphaVantage

using HTTP
# using JSON
# using DataFrames
# using Dates
using ArgCheck

# Constants
const HTTP_SCHEME = "https"
const HTTP_HOST = "alphavantage.co/query"
const ENV_VARIABLE_API_KEY = "ALPHA_VANTAGE_API_KEY"
const DEFAULT_API_KEY = "demo"

# Type hierarchy
abstract type AVFunction end
abstract type AVTimeSeries <: AVFunction end
abstract type AVFundamental <: AVFunction end
abstract type AVCurrency <: AVFunction end
abstract type AVEconomicIndicator <: AVFunction end
abstract type AVTechnicalIndicator <: AVFunction end

# Time series
struct TIME_SERIES_INTRADAY <: AVTimeSeries end
struct TIME_SERIES_INTRADAY_EXTENDED <: AVTimeSeries end
struct TIME_SERIES_DAILY <: AVTimeSeries end
struct TIME_SERIES_DAILY_ADJUSTED <: AVTimeSeries end
struct TIME_SERIES_WEEKLY <: AVTimeSeries end
struct TIME_SERIES_WEEKLY_ADJUSTED <: AVTimeSeries end
struct TIME_SERIES_MONTHLY <: AVTimeSeries end
struct TIME_SERIES_MONTHLY_ADJUSTED <: AVTimeSeries end
struct GLOBAL_QUOTE <: AVTimeSeries end
struct SYMBOL_SEARCH <: AVTimeSeries end

# Fundamentals
struct INCOME_STATEMENT <: AVFundamental end
struct BALANCE_SHEET <: AVFundamental end
struct CASH_FLOW <: AVFundamental end
struct EARNINGS <: AVFundamental end
struct OVERVIEW <: AVFundamental end
struct LISTING_STATUS <: AVFundamental end
struct EARNINGS_CALENDAR <: AVFundamental end
struct IPO_CALENDAR <: AVFundamental end

# Forex / Crypto
struct CURRENCY_EXCHANGE_RATE <: AVCurrency end
struct FX_INTRADAY <: AVCurrency end
struct FX_DAILY <: AVCurrency end
struct FX_WEEKLY <: AVCurrency end
struct FX_MONTHLY <: AVCurrency end
struct AVC_PRICE <: AVCurrency end
struct CRYPTO_INTRADAY <: AVCurrency end
struct DIGITAL_CURRENCY_DAILY <: AVCurrency end
struct DIGITAL_CURRENCY_WEEKLY <: AVCurrency end
struct DIGITAL_CURRENCY_MONTHLY <: AVCurrency end

# Economic Indicators
struct REAL_GDP <: AVEconomicIndicator end
struct REAL_GDP_PER_CAPITA <: AVEconomicIndicator end
struct TREASURY_YIELD <: AVEconomicIndicator end
struct FEDERAL_FUNDS_RATE <: AVEconomicIndicator end
struct INFLATION <: AVEconomicIndicator end
struct INFLATION_EXPECTATION <: AVEconomicIndicator end
struct CONSUMER_SENTIMENT <: AVEconomicIndicator end
struct RETAIL_SALES <: AVEconomicIndicator end
struct DURABLES <: AVEconomicIndicator end
struct UNEMPLOYMENT <: AVEconomicIndicator end
struct NONFARM_PAYROLL <: AVEconomicIndicator end

# Technical Indicators
struct SMA <: AVTechnicalIndicator end
struct EMA <: AVTechnicalIndicator end
struct WMA <: AVTechnicalIndicator end
struct DEMA <: AVTechnicalIndicator end
struct TEMA <: AVTechnicalIndicator end
struct TRIMA <: AVTechnicalIndicator end
struct KAMA <: AVTechnicalIndicator end
struct MAMA <: AVTechnicalIndicator end
struct VWAP <: AVTechnicalIndicator end
struct T3 <: AVTechnicalIndicator end
struct MACD <: AVTechnicalIndicator end
struct MACDEXT <: AVTechnicalIndicator end
struct STOCH <: AVTechnicalIndicator end
struct STOCHF <: AVTechnicalIndicator end
struct RSI <: AVTechnicalIndicator end
struct STOCHRSI <: AVTechnicalIndicator end
struct WILLR <: AVTechnicalIndicator end
struct ADX <: AVTechnicalIndicator end
struct ADXR <: AVTechnicalIndicator end
struct APO <: AVTechnicalIndicator end
struct PPO <: AVTechnicalIndicator end
struct MOM <: AVTechnicalIndicator end
struct BOP <: AVTechnicalIndicator end
struct CCI <: AVTechnicalIndicator end
struct CMO <: AVTechnicalIndicator end
struct ROC <: AVTechnicalIndicator end
struct ROCR <: AVTechnicalIndicator end
struct AROON <: AVTechnicalIndicator end
struct AROONOSC <: AVTechnicalIndicator end
struct MFI <: AVTechnicalIndicator end
struct TRIX <: AVTechnicalIndicator end
struct ULTOSC <: AVTechnicalIndicator end
struct DX <: AVTechnicalIndicator end
struct MINUS_DI <: AVTechnicalIndicator end
struct PLUS_DI <: AVTechnicalIndicator end
struct MINUS_DM <: AVTechnicalIndicator end
struct PLUS_DM <: AVTechnicalIndicator end
struct BBANDS <: AVTechnicalIndicator end
struct MIDPOINT <: AVTechnicalIndicator end
struct MIDPRICE <: AVTechnicalIndicator end
struct SAR <: AVTechnicalIndicator end
struct TRANGE <: AVTechnicalIndicator end
struct ATR <: AVTechnicalIndicator end
struct NATR <: AVTechnicalIndicator end
struct AD <: AVTechnicalIndicator end
struct ADOSC <: AVTechnicalIndicator end
struct OBV <: AVTechnicalIndicator end
struct HT_TRENDLINE <: AVTechnicalIndicator end
struct HT_SINE <: AVTechnicalIndicator end
struct HT_TRENDMODE <: AVTechnicalIndicator end
struct HT_DCPERIOD <: AVTechnicalIndicator end
struct HT_DCPHASE <: AVTechnicalIndicator end
struct HT_PHASOR <: AVTechnicalIndicator end

# API interface
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

# Type pipelines
"Ensure 'datatype' parameter is json or csv"
function _params_datatype(d::D where D <: Dict{String})
    dt = get(d, "datatype", "json")
    @argcheck dt in ["json", "csv"]
    d["datatype"] = dt
    d
end

"Overrides datatype to json"
function _params_force_json(d::D where D <: Dict{String})
    d["datatype"] = "json"
    d
end

"Overrides datatype to csv"
function _params_force_csv(d::D where D <: Dict{String})
    d["datatype"] = "csv"
    d
end

"Converts response to a string"
function _resp_tostring(resp)
    String(resp)
end

"Preprocesses API query parameters"
function preprocess(f::A where A <: AVFunction, params=Dict{String, Any}())
    params = _params_datatype(params)
    params
end

"Postprocesses API response"
function postprocess(f::A where A <: AVFunction, resp)
    resp = _resp_tostring(resp)
    resp
end

end # module
