mkdir tempus_out

julia -e 'using Pkg; Pkg.add("JSON"); Pkg.add("CSV"); Pkg.add("DataStructures"); Pkg.add("Distributions"); Pkg.add("EmpiricalDistributions"); Pkg.add("Graphs"); Pkg.add("MetaGraphsNext"); Pkg.add("Roots");'