# EdgeData = (failprob, latencydist, ospfweight)
tgweightfunction = x -> last(x)
const TopologyGraph = typeof(MetaGraph(DiGraph(), label_type=Symbol, edge_data_type=Tuple{Real, Distribution, Distribution, UInt}, weight_function=tgweightfunction));

function TopologyGraph(routers::Vector{Any}, links::Vector{Any})::TopologyGraph
    # edge_data_type = (failprob, transmission delay dist, queueing delay dist, weight)
    @info now() "Creating the topology graph."
    tg::TopologyGraph = MetaGraph(DiGraph(), label_type=Symbol, edge_data_type=Tuple{Real, Distribution, Distribution, UInt}, weight_function=tgweightfunction)

    # Make the nodes
    @info now() "Giving the node description; label => nothing"
    for router::Dict{String, Any} in routers
        tg[Symbol(router["name"])] = nothing
    end

    # Make the links
    @info "Giving edge description; (label, label) => data"
    for link::Dict{String, Any} in links
        # TODO: include src and dst link
        if link["u"] == "src" || link["v"] == "src" || link["u"] == "dst" || link["v"] == "dst"
            continue
        end

        # link dist is a univarient dis Gamma (1, 1)
        linkdist = gendist(link["delayModel"])
        uvdist = gendist(getdelaymodel(routers, link["u"], link["v"]))
        tg[Symbol(link["u"]), Symbol(link["v"])] = (link["failProb"], linkdist, uvdist, link["w_uv"])
        vudist = gendist(getdelaymodel(routers, link["v"], link["u"]))
        tg[Symbol(link["v"]), Symbol(link["u"])] = (link["failProb"], linkdist, vudist, link["w_vu"])
        # Link failure should nullify both connections
    end
    @info now() "Returning the topology graph"
    return tg
end

function getdelaymodel(routers::Vector{Any}, u, v::String)::Dict{String, Any}
    routeroutQ = filter(x -> x["name"] == u, routers)[1]["outQdelayModel"]
    return filter(x -> x["to"] == v, routeroutQ)[1]["delayModel"]
end

function gendist(delaymodel::Dict{String, Any})::Distribution
    if delaymodel["delayType"] == "Empiric"
        # map a univareint dist to empirical results
        samples = CSV.File("topology/" * delaymodel["args"][1])["sample"]
        d = UvBinnedDist(fit(Histogram, samples))
        return d
    else 
        # map a univarient list to the delaymodel (e.g., Gamma)
        args = Tuple(parse.(Float64, split(delaymodel["args"][1], ',')))
        # args = Tuple(delaymodel["args"])
        rawdist = eval(Meta.parse(delaymodel["delayType"] * string(args)))
        # Truncate to disallow negative delay
        if cdf(rawdist, 0.0) > 0.0 
            rawdist = truncated(rawdist; lower=0.0)
        end
    
        # Empiric
        dist = UvBinnedDist(fit(Histogram, rand(rawdist, 100)))
        return dist
    end
end