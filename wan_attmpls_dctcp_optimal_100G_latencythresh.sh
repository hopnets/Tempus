mkdir /mnt/data/tempus_out

julia --project=. src/Tempus.jl AttMpls_empiric_wiley_empiric_dctcp_100G.json optimal 100 > /mnt/data/tempus_out/AttMpls_empiric_wiley_empiric_dctcp_latencythresh_100.txt

julia --project=. src/Tempus.jl AttMpls_empiric_wiley_empiric_dctcp_100G.json optimal 1000 > /mnt/data/tempus_out/AttMpls_empiric_wiley_empiric_dctcp_latencythresh_1000.txt

julia --project=. src/Tempus.jl AttMpls_empiric_wiley_empiric_dctcp_100G.json optimal 10000 > /mnt/data/tempus_out/AttMpls_empiric_wiley_empiric_dctcp_latencythresh_10000.txt

julia --project=. src/Tempus.jl AttMpls_empiric_wiley_empiric_dctcp_100G.json optimal 100000 > /mnt/data/tempus_out/AttMpls_empiric_wiley_empiric_dctcp_latencythresh_100000.txt

julia --project=. src/Tempus.jl AttMpls_empiric_wiley_empiric_dctcp_100G.json optimal 1000000 > /mnt/data/tempus_out/AttMpls_empiric_wiley_empiric_dctcp_latencythresh_1000000.txt

julia --project=. src/Tempus.jl AttMpls_empiric_wiley_empiric_dctcp_100G.json optimal 10000000 > /mnt/data/tempus_out/AttMpls_empiric_wiley_empiric_dctcp_latencythresh_10000000.txt

julia --project=. src/Tempus.jl AttMpls_empiric_wiley_empiric_dctcp_100G.json optimal 100000000 > /mnt/data/tempus_out/AttMpls_empiric_wiley_empiric_dctcp_latencythresh_100000000.txt