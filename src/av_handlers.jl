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
  CSV.File(resp) |> DataFrame
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
  _resp_todataframe(respo)
end

# Fundamentals Handlers
function preprocess(f::A where A <: AVFundamental, params)
  _params_force_json(params)
end

function postprocess(f::A where A <: AVFundamental, resp)
  r = _resp_tostring(resp) |> JSON.parse
  
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
  _resp_todataframe(respo)
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
  _resp_todataframe(respo)
end

function preprocess(f::EARNINGS_CALENDAR, params)
  params = _params_no_datatype(params)

  if "horizon" in keys(params)
    @argcheck params["horizon"] in ["3month", "6month", "12month"]
  end

  params
end

function postprocess(f::EARNINGS_CALENDAR, resp)
  _resp_todataframe(respo)
end

function preprocess(f::IPO_CALENDAR, params)
  _params_no_datatype(params)
end

function postprocess(f::IPO_CALENDAR, resp)
  _resp_todataframe(respo)
end

