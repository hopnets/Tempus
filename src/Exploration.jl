function explore(tg::AbstractGraph, src::Symbol, dst::Symbol, threshold::Real, opt::String, accuracy::Float64, runtime::UInt, func_accuracy::Float64, temp_accuracy::Float64, run_config::Dict{String, Any})::Float64
    @info now() "Begin exploring"
    start = now()

    # If src and dst are the same node
    src == dst && return 1.0

    # Create state tree and exploration queue
    e = PriorityQueue{State, Float64}(Base.Order.Reverse)
    # Create the perfect state as the initial state
    perfect = State([], [])
    e[perfect] = get_p_state(tg, perfect)
    # Prepare for functional state exploration
    tgcopy = deepcopy(tg)

    # Probabilities
    p_explored = 0.0
    p_property = 0.0
    # Cache for consolidation and memoization
    p_paths_temporals = Dict{Set{Vector{Symbol}}, Float64}()
    p_path_temporals = Dict{Vector{Symbol}, Float64}()

    # Logging variable
    # Equivalence classes
    cnt_fec = 0 # number of functional equivalence classes
    cnt_fec_unreachable = 0 # number of equivalence classes that violate reachability
    cnt_tec = 0
    # Path
    cnt_path = 0
    # Convolution
    cnt_conv::UInt = 0
    # cnt_nconv::UInt = 0
    # Analytic: in an optimized run, how much EC, path, and convolution is actually pruned?
    # The value of these variables might not make sense for consolidation-only and baseline version
    cnt_analytic_tec = Dict{Set{Vector{Symbol}}, Int}() # Does not include unreachable state
    cnt_analytic_path = Dict{Vector{Symbol}, Int}() # Not covered by consolidation

    #optimizations
    cache_paths = (opt == "optimal" || opt == "paths")
    cache_ecs = (opt == "optimal" || opt == "ecs")

    @info now() "optimization info:" cache_paths cache_ecs

    
    # Duration
    dur_functional = zero(now())
    dur_temporal = zero(now())
    # dur_path = Dict{Vector{Symbol}, Millisecond}()
    
    # cnt_links = Dict{Tuple{Symbol, Symbol}, Int}()
    # Explore functional state
    # Timeout: either inaccuracy or hours passed
    test_cnt::Int = 0
    while !isempty(e) && p_explored < accuracy && (dur_functional.value + dur_temporal.value) < runtime
        # println("----------------------------------------")
        # println("FUNCITONAL....")
        start_functional = now()
        cnt_fec += 1

        l = dequeue!(e)

        # Disable links of this current state
        offlinks::Vector{Tuple{Symbol, Symbol}} = get_disabled(l)
        offlinksdata = Dict{Tuple{Symbol, Symbol}, Tuple{Real, Distribution, Distribution, UInt}}()
        for (u, v) in offlinks
            offlinksdata[(u, v)] = tgcopy[u, v]
            rem_edge!(tgcopy, code_for(tgcopy, u), code_for(tgcopy, v))
            offlinksdata[(v, u)] = tgcopy[v, u]
            rem_edge!(tgcopy, code_for(tgcopy, v), code_for(tgcopy, u))
        end
        # println("offlinks: ", keys(offlinksdata))

        # Based on the current network state, compute hot edges based on ECMP
        converged_paths = dijkstra_mg_allpaths(tgcopy, src, dst)
        hot_edges = allpaths_to_unique_links(converged_paths)
        force_enabled_links::Vector{Tuple{Symbol, Symbol}} = get_enabled(l)
        hot_edges_new = filter(x -> !((x[1], x[2]) in force_enabled_links || (x[2], x[1]) in force_enabled_links), hot_edges)
        # println("locked: ", get_enabled(l))
        # println("\n\n")
        # println("disabled: ", get_disabled(l))
        # println("\n\n")
        # println(converged_paths)
        # println("\n\n")
        # println(hot_edges_new)
        # println("\n\n-------------------------------------\n\n")
        # println("converged paths: ", converged_paths)
        # println("forced enabled: ", force_enabled_links)
        # println("hot edges: ", hot_edges)
        # println("new hot edges are ", hot_edges_new)
        

        # Enqueue new state based on (new) hot edges, with its p_state as prioritization
        e_temp = PriorityQueue{State, Float64}(Base.Order.Reverse)
        # println(length(e_temp))
        for i in 1:length(hot_edges_new)
            # NOTE: this is slightly different from NetDice's p_state, since it doesn't contain the shortest paths probability
            #SEPEHR: I don't get this, why are we adding one by one to hot_edges
            s = State([get_enabled(l); hot_edges_new[1:i-1]], [get_disabled(l); hot_edges_new[i]], 1)
            p_state = get_p_state(tg, s)
            e_temp[s] = p_state
        end
        # println(length(e_temp))

        # Get functional probability
        hot_edges_new_prob = !isempty(hot_edges_new) ? prod([1 - first(tgcopy[u, v]) for (u, v) in hot_edges_new]) : 1.0
        p_paths_functional = !isempty(hot_edges) ? hot_edges_new_prob : 0.0
        
        # println("hot_edges_new_prob: ", hot_edges_new_prob)
        # println("p_paths_functional: ", p_paths_functional)

        # Update the explored probability
        # p_explored is about how much of the tree we have explored not the value used as P_F or for P_T
        # its just here to make sure accuracy is held
        m_p_state::Float64 = get_p_state(tg, l)
        newly_explored::Float64 = !isempty(hot_edges) ? m_p_state * p_paths_functional : m_p_state
        p_explored += newly_explored
        @debug p_explored, length(e)
        # println("len(e): ", length(e))
        # println("hot edges: ", hot_edges)
        # println("m_p_state: ", m_p_state)
        # println("p_paths_functional: ", p_paths_functional)
        # println("P_F_E: ", newly_explored)
        # println("p_explored: ", p_explored)
        # println("-----------------------")

        # Restore disabled links for next state exploration
        for (key, val) in offlinksdata
            tgcopy[key[1], key[2]] = val
        end

        # TEMPORAL VERIFICATION
        start_temporal = now()
        dur_functional += start_temporal - start_functional

        # Check if the path is even functional
        if isempty(converged_paths)
            cnt_fec_unreachable += 1 
            continue
        end

        # println("TEMPORAL...")

        # If p_paths_temporal has not been computed before, compute the temporal probability of the EC
        converged_paths_set = Set{Vector{Symbol}}(converged_paths)

        # Compute p_paths_temporal from weighted p_path_temporal
        p_paths_temporal = 0.0

        if !haskey(p_paths_temporals, converged_paths_set)
            # Compute probability of each path being taken
            weights = ecmpprob(converged_paths)
            # println("weights is ", weights)
            # println("\n\n")
            

            # Logging variable
            # start_conv = now()

            for path in converged_paths
                # If p_path_temporal has not been computed before, do convolutions
                if !haskey(p_path_temporals, path)
                    # Start timing
                    # start_conv2 = now()

                    # Do convolution
                    d, lcnt_conv = pathdist_unopt(path, tg)
                    
                    # NOTE: THRESHOLD SHOULD BE IN THE SAME UNIT AS OUR DISTS
                    m_cdf = cdf(d, threshold)
                    p_paths_temporal += weights[path] * m_cdf
                    
                    if cache_paths
                        # Check temporal property based on path latency distribution d
                        # For now, it's just bounded reachability
                        p_path_temporals[path] = m_cdf
                    end
                    
                    # Logs
                    # Analytic
                    cnt_analytic_path[path] = 1
                    # Empiric
                    cnt_path += 1
                    cnt_conv += lcnt_conv
                    # cnt_nconv += lcnt_nconv
                    # dur_path[path] = now() - start_conv2
                    @debug "Path", cnt_path
                else 
                    # Compute the weighted average of each path's probability based on load balancing scheme
                    p_paths_temporal += weights[path] * p_path_temporals[path]
                    cnt_analytic_path[path] += 1
                end

                # (opt == "base" || opt == "cons") && delete!(p_path_temporals, path)

            end

            if cache_ecs
                p_paths_temporals[converged_paths_set] = p_paths_temporal
            end
            cnt_analytic_tec[converged_paths_set] = 1

            # Logs
            cnt_tec += 1
        else
            # If p_paths_temporal has been computed before, then just use that
            p_paths_temporal = p_paths_temporals[converged_paths_set]
            cnt_analytic_tec[converged_paths_set] += 1
        end
        # opt == "base" && delete!(p_paths_temporals, converged_paths_set)

        # Compute the combined probability of this EC
        curr_property = m_p_state * p_paths_functional * p_paths_temporal
        p_property += curr_property

        # println("p_paths_functional: ", p_paths_functional)
        # println("p_paths_temporal: ", p_paths_temporal)
        # println("P_T_E is ", curr_property)


        # Logs
        dur_temporal += now() - start_temporal

        if (curr_property <= (1-temp_accuracy) || newly_explored <= (1-func_accuracy))
            # println("skipping...")
            continue
        end

        # println(length(e))
        for item in e_temp
            e[item.first] = item.second

            # Memory limit: prune the size of e
            if run_config["e_size_thresh"] > 0 && length(e) > run_config["e_size_thresh"]
                la = last(e.xs)
                delete!(e, first(la))
                # @debug "Delete", last(la)
            end
        end


        # println("----------------------------------------")
        # test_cnt += 1
        # if (test_cnt) >= 3
        #     return
        # end
    end

    # Count your blessings: 
    # How many paths are duplicated with the choice of topology and src-dst pair?
    # cnt_conv::Int = cnt_nconv + cnt_aconv
    # if opt == "optimal"
    #     # cnt_dup_path = Dict{Vector{Symbol}, Int}()
    #     # cnt_dup_conv = 0
    #     # Base = sum cnt_analytic_path * dur_path 
    #     # Cons = for every equivclass, for every path, sum dur_path
    #     # Conv = sum dur_path

    #     # Optimized
    #     cnt_path_opt = length(cnt_analytic_path)
    #     cnt_conv_opt = 0
    #     for path in keys(cnt_analytic_path)
    #         cnt_conv_opt += 2 * (length(path) - 1) - 1
    #     end

    #     # Consolidation only (no memoization)
    #     cnt_path_cons = 0
    #     cnt_conv_cons = 0
    #     for eqclass in keys(cnt_analytic_tec)
    #         cnt_path_cons += length(eqclass)
    #         for path in eqclass
    #             cnt_conv_cons += 2 * (length(path) - 1) - 1
    #         end
    #     end

    #     # Baseline (no consolidation and memoization)
    #     cnt_path_base = 0
    #     cnt_conv_base = 0
    #     for (eqclass, cnt) in cnt_analytic_tec
    #         cnt_path_base += cnt * length(eqclass)
    #         for path in eqclass
    #             cnt_conv_base += cnt * (2 * (length(path) - 1) - 1)
    #         end
    #     end
    #     # for path in keys(cnt_analytic_path)
    #     #     cnt_conv_base += cnt_analytic_path[path] * (2 * (length(path) - 1) - 1)
    #     # end

    #     # # Introduced by failing memoization
    #     # for path in keys(cnt_analytic_path)
    #     #     cnt_dup_path[path] = cnt_analytic_path[path]
    #     #     cnt_dup_conv += cnt_analytic_path[path] * (2 * (length(path) - 1) - 1)
    #     # end
    #     # cnt_path_cons = sum(values(cnt_dup_path))
    #     # cnt_conv_cons = cnt_dup_conv

    #     # # Introduced by failing consolidation
    #     # for eqclass in keys(cnt_analytic_tec)
    #     #     for path in eqclass
    #     #         cnt_dup_path[path] += cnt_analytic_tec[eqclass]
    #     #         cnt_dup_conv += cnt_analytic_tec[eqclass] * (2 * (length(path) - 1) - 1)
    #     #     end
    #     # end

    #     # cnt_path_base = sum(values(cnt_dup_path))
    #     # cnt_conv_base = cnt_dup_conv

    #     # cnt_path_conv = length(cnt_dup_path)

    #     # @info "EC: $(length(cnt_analytic_tec)), $(sum(values(cnt_analytic_tec)) + cnt_fec_unreachable)" # cnt_analytic_tec doesn't count the unreachable eqclass
    #     @info "Path: $cnt_path_opt, $cnt_path_cons, $cnt_path_base"
    #     @info "Conv: $cnt_conv_opt, $cnt_conv_cons, $cnt_conv_base"
    # end

    # Print some debug status
    # Time 
    # time_conv = sum(values(dur_path))
    # time_cons = zero(now())
    # for ec in keys(p_paths_temporals)
    #     time_cons += sum([dur_path[path] for path in ec])
    # end
    # time_base = sum([cnt_analytic_path[path] * dur_path[path] for path in keys(cnt_analytic_path)])

    # cnt_conv::UInt = cnt_nconv + cnt_aconv
    # @info "$(time_conv.value), $(time_cons.value), $(time_base.value)"

    p_explored < accuracy && (dur_functional.value + dur_temporal.value) < runtime

    if (dur_functional.value + dur_temporal.value) >= runtime
        @info "Runtime threshold was reached!" (dur_functional.value + dur_temporal.value)
        println("Runtime threshold was reached!\n\n")
    end

    if p_explored >= accuracy
        @info "Accuracy threshold was hit!" p_explored
        println("Accuracy threshold was hit!\n\n")
    end

    @info "$(replace(ARGS[1], r".json$"=>"") * opt), $(nv(tg)), $(UInt(ne(tg) / 2)), $(dur_functional.value), $(dur_temporal.value), $cnt_fec, $cnt_fec_unreachable, $cnt_tec, $cnt_path, $cnt_conv"
    println("Final results: num_nodes, num_edges, functional_time(ms), temporal_time(ms), # ECs, # unreachable ECs, # EC acces during temporal, # paths, # convolutions")
    println(nv(tg), ", ", UInt(ne(tg) / 2), ", ", dur_functional.value, ", ", dur_temporal.value, ", ", 
    cnt_fec, ", ", cnt_fec_unreachable, ", ", cnt_tec, ", ", cnt_path, ", ", cnt_conv, "\n\n")

    # # Logging variable
    # cnt_tec = 0
    # cnt_path = 0
    # cnt_aconv::UInt = 0
    # cnt_nconv::UInt = 0
    # # dur_cons_total = 0
    # cnt_links = Dict{Tuple{Symbol, Symbol}, Int}()
    # dur_conv_total = zero(now())

    # for x in map(y -> label_for(st, y), vertices(st))
    #     isempty(st[x].converged_paths) && continue

    #     # If p_paths_temporal has not been computed before, re-explore state
    #     if !haskey(p_paths_temporals, Set{Vector{Symbol}}(st[x].converged_paths))
    #         # Compute probability of each path being taken
    #         weights = ecmpprob(st[x].converged_paths)

    #         # Compute p_paths_temporal from weighted p_path_temporal
    #         p_paths_temporal = 0.0

    #         # Logging variable
    #         start_conv = now()

    #         for path in st[x].converged_paths
    #             # If p_path_temporal has not been computed before, do convolutions
    #             if !haskey(p_path_temporals, path)
    #                 # Do convolution
    #                 d, lcnt_aconv, lcnt_nconv = pathdist_unopt(path, tg)
                    
    #                 # Check temporal property based on path latency distribution d
    #                 # For now, it's just bounded reachability
    #                 p_path_temporals[path] = cdf(d, threshold)
                    
    #                 # Logs
    #                 cnt_aconv += lcnt_aconv
    #                 cnt_nconv += lcnt_nconv
    #                 # println(cnt_aconv + cnt_nconv)
    #                 cnt_path += 1
    #                 @debug cnt_path
    #             end

    #             # Count your blessings
    #             for link in path_to_links(path)
    #                 if haskey(cnt_links, link)
    #                     cnt_links[link] += 1
    #                 else 
    #                     cnt_links[link] = 1
    #                 end
    #             end

    #             p_paths_temporal += weights[path] * p_path_temporals[path]


    #             (opt == "base" || opt == "cons") && delete!(p_path_temporals, path)
    #         end

    #         p_paths_temporals[Set{Vector{Symbol}}(st[x].converged_paths)] = p_paths_temporal

    #         # Logging
    #         cnt_tec += 1
    #         dur_conv_total += now() - start_conv
    #         if dur_conv_total.value > 7200000
    #             break
    #         end    
    #     end

    #     # Count your blessings
    #     for path in st[x].converged_paths
    #         for link in path_to_links(path)
    #             if haskey(cnt_links, link)
    #                 cnt_links[link] += 1
    #             else 
    #                 cnt_links[link] = 1
    #             end
    #         end
    #     end
        
    #     # If p_paths_temporal has been computed before, then just use that
    #     st[x].p_paths_temporal = p_paths_temporals[Set{Vector{Symbol}}(st[x].converged_paths)]
    #     opt == "base" && delete!(p_paths_temporals, Set{Vector{Symbol}}(st[x].converged_paths))
    # end
    # start_cdf = now()
    # dur_cons_total = (start_cdf - start_temporal) - dur_conv_total
    # # println(dur_cons_total, dur_conv_total)
    @info now() "Finish exploring"
    return p_property
end

function dijkstra_mg_allpaths(g::AbstractGraph, src::Symbol, dst::Symbol)::Vector{Vector{Symbol}}
    dj = dijkstra_shortest_paths(g, code_for(g, src), allpaths=true)
    paths_code = enumerate_all_paths(dj.predecessors, code_for(g, src), code_for(g, dst))
    return [[label_for(g, x) for x in path_code] for path_code in paths_code]
end

function enumerate_all_paths(preds::Vector{Vector{Int}}, src::Int, v::Int, allpaths::Vector{Vector{Int}})::Vector{Vector{Int}}
    # Base case
    if preds[v] == Int[] && v == src
        return [[v; allpath] for allpath in allpaths]
    end

    # DFS recursive case
    new_allpaths = []
    for parent in preds[v]
        push!(new_allpaths, enumerate_all_paths(preds, src, parent, [[v; allpath] for allpath in allpaths])...)
    end
    return new_allpaths
end

enumerate_all_paths(preds::Vector{Vector{Int}}, src::Int, v::Int) = enumerate_all_paths(preds, src, v, Vector{Int}[Int[]])

function path_to_links(path::Vector{Symbol})::Vector{Tuple{Symbol, Symbol}}
    return [(path[i], path[i+1]) for i in 1:length(path)-1]
end

function allpaths_to_unique_links(allpaths::Vector{Vector{Symbol}})::Vector{Tuple{Symbol, Symbol}}
    links::Vector{Tuple{Symbol, Symbol}} = []
    for path in allpaths
        push!(links, path_to_links(path)...)
    end
    return unique(links)
end

# Given a list of paths, what is the probability that a path would be chosen given random choice at a node?
function ecmpprob(paths::Vector{Vector{Symbol}})::Dict{Vector{Symbol}, Float64}
    probs = Dict{Vector{Symbol}, Float64}()
    # Count the links with unique src 
    uniquelinks = allpaths_to_unique_links(paths)

    # prob = product of 1 / count
    for path in paths
        links = path_to_links(path)
        prob = 1.0
        for link in links
            # Count the unique links with the same src 
            prob /= count(x -> first(x) == first(link), uniquelinks)
        end
        probs[path] = prob
    end

    return probs
end

# Given a path and topology graph, what is the latency distribution of that path
function pathdist_unopt(path::Vector{Symbol}, tg::TopologyGraph)::Tuple{Distribution, UInt}
    lcnt_conv = 0
    
    links = path_to_links(path)
    d = nothing

    for link in links
        if d == nothing 
            d = convolve(tg[link[1], link[2]][2], tg[link[1], link[2]][3])
            lcnt_conv += 1
        else
            # println(typeof(d), typeof(tg[link[1], link[2]][2]))
            d = convolve(d, tg[link[1], link[2]][2])
            d = convolve(d, tg[link[1], link[2]][3])
            lcnt_conv += 2
        end
    end

    return (d, lcnt_conv)
end

function pathdist(path::Vector{Symbol}, tg::TopologyGraph)::Tuple{Distribution, UInt, UInt}
    lcnt_aconv = 0
    lcnt_nconv = 0
    
    links = path_to_links(path)
    g = Dict{DataType, Distribution}()

    # Group similar distribution
    # TODO: whitelist instead of relying on type
    # TODO: smarter convolution between exponential and gamma
    for link in links
        t = tg[link[1], link[2]][2]
        if !haskey(g, typeof(t))
            g[typeof(t)] = t
        else
            g[typeof(t)] = convolve(t, g[typeof(t)])
            lcnt_aconv += 1
        end

        t = tg[link[1], link[2]][3]
        if !haskey(g, typeof(t))
            g[typeof(t)] = t
        else
            g[typeof(t)] = convolve(t, g[typeof(t)])
            lcnt_aconv += 1
        end
    end

    # analytically convolve each group
    a = values(g)
    # for group in values(g)
    #     d = nothing
    #     for dist in group 
    #         if d == nothing 
    #             d = dist
    #         else
    #             d = convolve(d, dist)
    #             lcnt_aconv += 1
    #         end
    #     end

    #     if typeof(d) == DirectDistribution{Float64}
    #         pushfirst!(a, d)
    #     else 
    #         push!(a, d)
    #     end
    # end

    # numerically convolve 
    d = nothing
    for dist in a
        if d == nothing 
            d = dist
        else
            d = convolve(d, dist)
            lcnt_nconv += 1
        end
    end

    return (d, lcnt_aconv, lcnt_nconv)
end