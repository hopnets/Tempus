module Tempus

using Logging
import JSON
import CSV
using DataStructures
using Random
using Dates

using Distributions
import Distributions: cdf, pdf, logpdf, minimum, maximum, quantile, convolve
using StatsBase
using EmpiricalDistributions
import EmpiricalDistributions: _linear_interpol, _ratio

using Graphs
import Graphs: weights
using MetaGraphsNext

using QuadGK # Numerical integration
using Roots

include("TopologyGraphs.jl")
include("Direct.jl")
include("StateTrees.jl")
include("Exploration.jl")

function _linear_interpol(x_lo::Real, x_hi::Real, y_lo::Real, y_hi::Real, x::Real)
    T = promote_type(typeof(y_lo), typeof(y_hi), typeof(x))
    w_hi = T(_ratio(x - x_lo, x_hi - x_lo))
    w_lo = one(w_hi) - w_hi
    y = y_lo * w_lo + y_hi * w_hi
    # Original assertion might fail in the case of float rounding error
    # @assert y_lo <= y <= y_hi 
    !(y_lo < y) && @assert isapprox(y_lo, y)
    !(y < y_hi) && @assert isapprox(y, y_hi)
    y
end

function main()
    @info now() ARGS

    if size(ARGS)[1] < 2
        @error "File name and optimization level are mandatory: julia --project=. src/Tempus.jl example.json optimal"
        return 1
    end

    json::String = open("topology/" * ARGS[1]) do file
        read(file, String)
    end
    topology_config::Dict{String, Any} = JSON.parse(json)

    json2::String = open("config.json") do file
        read(file, String)
    end
    run_config::Dict{String, Any} = JSON.parse(json2)

    opt = ARGS[2]

    if opt != "optimal" && opt != "base" && opt != "paths" && opt!= "ecs"
        @error "Unknown opt!!"
        return
    end

    latency_threshold::Float64 = size(ARGS)[1] >= 3 ? parse(Float64, ARGS[3]) : run_config["latency_threshold"]
    #default of runtime is 3h which is 10800000ms
    runtime::UInt = size(ARGS)[1] >= 4 ? parse(UInt, ARGS[4]) : run_config["runtime"]
    # default of accuracy is (1-10^(-8)
    accuracy::Float64 = size(ARGS)[1] >= 5 ? parse(Float64, ARGS[5]) : run_config["accuracy"]
    func_accuracy::Float64 = size(ARGS)[1] >= 6 ? parse(Float64, ARGS[6]) : run_config["func_accuracy"]
    temp_accuracy::Float64 = size(ARGS)[1] >= 7 ? parse(Float64, ARGS[7]) : run_config["temp_accuracy"]

    println("ARGS: ", ARGS, "\n\n")

    @info now() "Run information: " floor(Int, runtime) accuracy topology_config["intent"]["src"] topology_config["intent"]["dst"] latency_threshold opt temp_accuracy
    println("Run information: runtime(ms), accuracy, src, dst, latency threshold(ns), opt, temp_accuracy")
    println(runtime, ", ", accuracy, ", ", topology_config["intent"]["src"], ", ", 
    topology_config["intent"]["dst"], ", ", latency_threshold, ", ", opt, ", ", temp_accuracy, "\n\n")

    tg::TopologyGraph = TopologyGraph(topology_config["routers"], topology_config["links"])
    # @info ne(tg) / 2

    prob::Float64 = explore(tg, Symbol(topology_config["intent"]["src"]), Symbol(topology_config["intent"]["dst"]), latency_threshold, opt, accuracy, runtime, func_accuracy, temp_accuracy, run_config)
    @info now() "P_T: " prob
    println("P_T: ", prob, "\n\n")
end

if !isinteractive()
    main()
end

end # module