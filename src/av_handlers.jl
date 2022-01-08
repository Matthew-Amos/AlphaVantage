"""
The internal mechanics for handling API calls are to dispatch information to
`preprocess` and `postprocess` functions based on data types found in "av_types.jl".

    `preprocess` acts upon a Dict of query parameters.

    `postprocess` transforms a successful API result, beginning with a Vector{UInt8}.
"""

# TODO: preprocessor - parameter validations, datatype preferences
# TODO: postprocessor - sinks

# Utilities
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

# General Handlers
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

# Time Series Handlers
function preprocess(f::A where A <: AVTimeSeries, params=Dict{String, Any}())
  _params_force_csv(params)
end

function postprocess(f::A where A <: AVTimeSeries, resp)
  CSV.File(resp) |> DataFrame
end
