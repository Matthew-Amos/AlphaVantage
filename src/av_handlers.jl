"""
The internal mechanics for handling API calls are to dispatch information to
`preprocess` and `postprocess` functions based on data types found in "av_types.jl".

    `preprocess` acts upon a Dict of query parameters.

    `postprocess` transforms a successful API result, beginning with a Vector{UInt8}.
"""

# Utilities
"Ensure 'datatype' parameter is json or csv"
function _params_datatype(d)
  dt = get(d, "datatype", "json")
  @argcheck dt in ["json", "csv"]
  d["datatype"] = dt
  d
end

"Overrides datatype to json"
function _params_force_json(d)
  d["datatype"] = "json"
  d
end

"Overrides datatype to csv"
function _params_force_csv(d)
  d["datatype"] = "csv"
  d
end

"Removes datatype parameter"
function _params_no_datatype(d)
  delete!(d, "datatype")
  d
end

"Converts response to a string"
function _resp_tostring(resp)
  String(resp)
end

"Converts a response to a dataframe"
function _resp_todataframe(resp)
  resp |> CSV.File |> DataFrame
end

"Converts a response to parsed JSON"
function _resp_tojson(resp)
  resp |> _resp_tostring |> JSON.parse
end

# General Handlers
"Preprocesses API query parameters"
function preprocess(f::A where A <: AVFunction, params)
  params = _params_datatype(params)
  params
end

"Postprocesses API response"
function postprocess(f::A where A <: AVFunction, resp)
  resp = _resp_tostring(resp)
  resp
end

# Time Series Handlers
function preprocess(f::A where A <: AVTimeSeries, params)
  _params_force_csv(params)
end

function postprocess(f::A where A <: AVTimeSeries, resp)
  _resp_todataframe(resp)
end

# Fundamentals Handlers
function preprocess(f::A where A <: AVFundamental, params)
  _params_force_json(params)
end

function postprocess(f::A where A <: AVFundamental, resp)
  r = _resp_tojson(resp)

  if !all(["symbol", "annualReports", "quarterlyReports"] in keys(r))
    @warn "unexpected key structure in JSON response"
    return r
  end

  rep_a = vcat(DataFrame.(r["annualReports"])...)
  rep_q = vcat(DataFrame.(r["quarterlyReports"])...)
  rep_a[:, :symbol] .= r["symbol"]
  rep_q[:, :symbol] .= r["symbol"]

  return Dict("annual" => rep_a, "quarterly" => rep_q)
end

function preprocess(f::OVERVIEW, params)
  _params_no_datatype(params)
end

function postprocess(f::OVERVIEW, resp)
  _resp_todataframe(resp)
end

function preprocess(f::LISTING_STATUS, params)
  params = _params_no_datatype(params)

  if "date" in keys(params)
    if typeof(params["date"]) == Dates.Date
      params["date"] = string(params["date"])
    end

    if typeof(params["date"]) == String
      @assert !isnothing(match(r"[0-9]{4}-[0-9]{2}-[0-9]{2}", params["date"]))
    else
      @warn "date parameter should be a string in YYYY-MM-DD format"
    end
  end

  if "state" in keys(params)
    @argcheck params["state"] in ["active", "delisted"]
  end

  params
end

function postprocess(f::LISTING_STATUS, resp)
  _resp_todataframe(resp)
end

function preprocess(f::EARNINGS_CALENDAR, params)
  params = _params_no_datatype(params)

  if "horizon" in keys(params)
    @argcheck params["horizon"] in ["3month", "6month", "12month"]
  end

  params
end

function postprocess(f::EARNINGS_CALENDAR, resp)
  _resp_todataframe(resp)
end

function preprocess(f::IPO_CALENDAR, params)
  _params_no_datatype(params)
end

function postprocess(f::IPO_CALENDAR, resp)
  _resp_todataframe(resp)
end

# Currency Handlers
function preprocess(f::A where A <: AVCurrency, params)
  if "interval" in keys(params)
    @argcheck params["interval"] in ["1min", "5min", "15min", "30min", "60min"]
  end

  if "outputsize" in keys(params)
    @argcheck params["outputsize"] in ["compact", "full"]
  end

  _params_force_csv(params)
end

function postprocess(f::A where A <: AVCurrency, resp)
  _resp_todataframe(resp)
end

function preprocess(f::CURRENCY_EXCHANGE_RATE, params)
  _params_no_datatype(params)
end

function postprocess(f::CURRENCY_EXCHANGE_RATE, resp)
  _resp_tojson(resp)
end

function preprocess(f::AVC_PRICE, params)
  _params_no_datatype(params)
end

function postprocess(f::AVC_PRICE, resp)
  _resp_tojson(resp)
end

function preprocess(f::DIGITAL_CURRENCY_DAILY, params)
  _params_no_datatype(params)
end

function postprocess(f::DIGITAL_CURRENCY_DAILY, resp)
  r = _resp_tojson(resp)
  data_key = sort(collect(keys(r)))[2]

  function kdf(d, v, i)
    ki = collect(keys(d[v]))[i]
    df = DataFrame(d[v][ki])
    df[:, :T] .= ki
    df
  end

  ts = vcat([kdf(r, data_key, i) for i in 1:length(keys(r[data_key]))]...)
  ts
end

function preprocess(f::DIGITAL_CURRENCY_WEEKLY, params)
  preprocess(DIGITAL_CURRENCY_DAILY, params)
end

function postprocess(f::DIGITAL_CURRENCY_WEEKLY, resp)
  postprocess(DIGITAL_CURRENCY_DAILY, resp)
end

function preprocess(f::DIGITAL_CURRENCY_MONTHLY, params)
  preprocess(DIGITAL_CURRENCY_DAILY, params)
end

function postprocess(f::DIGITAL_CURRENCY_MONTHLY, resp)
  postprocess(DIGITAL_CURRENCY_DAILY, resp)
end

# Economic Indicator Handlers
function preprocess(f::A where A <: AVEconomicIndicator, params)
  if "interval" in keys(params)
    @argcheck params["interval"] in ["daily", "weekly", "monthly", "semiannual", "quarterly", "annual"]
  end

  if "maturity" in keys(params)
    @argcheck params["maturity"] in ["3month", "5year", "10year", "30year"]
  end

  _params_force_csv(params)
end

function postprocess(f::A where A <: AVEconomicIndicator, resp)
  _resp_todataframe(resp)
end

# Technical Indicator Handlers
function preprocess(f::A where A <: AVTechnicalIndicator, params)
  if "interval" in keys(params)
    @argcheck params["interval"] in ["1min", "5min", "15min", "30min", "60min", "daily", "weekly", "monthly"]
  end

  if "time_period" in keys(params)
    is_int = typeof(params["time_period"]) <: Int
    @assert is_int
    if is_int
      @assert sign(params["time_period"]) == 1
    end
  end

  _params_force_csv(params)
end

function postprocess(f::A where A <: AVTechnicalIndicator, resp)
  _resp_todataframe(resp)
end
