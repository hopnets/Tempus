/usr/bin/time -o /mnt/data/tempus_out/Highwinds_empiric_wiley_empiric_tcp_base_mem_footprint.txt -v julia --project=. src/Tempus.jl Highwinds_empiric_wiley_empiric_tcp_100G.json base
/usr/bin/time -o /mnt/data/tempus_out/Highwinds_empiric_wiley_empiric_tcp_paths_mem_footprint.txt -v julia --project=. src/Tempus.jl Highwinds_empiric_wiley_empiric_tcp_100G.json paths
/usr/bin/time -o /mnt/data/tempus_out/Highwinds_empiric_wiley_empiric_tcp_ecs_mem_footprint.txt -v julia --project=. src/Tempus.jl Highwinds_empiric_wiley_empiric_tcp_100G.json ecs
/usr/bin/time -o /mnt/data/tempus_out/Highwinds_empiric_wiley_empiric_tcp_optimal_mem_footprint.txt -v julia --project=. src/Tempus.jl Highwinds_empiric_wiley_empiric_tcp_100G.json optimal


/usr/bin/time -o /mnt/data/tempus_out/AttMpls_empiric_wiley_empiric_tcp_base_mem_footprint.txt -v julia --project=. src/Tempus.jl AttMpls_empiric_wiley_empiric_tcp_100G.json base
/usr/bin/time -o /mnt/data/tempus_out/AttMpls_empiric_wiley_empiric_tcp_paths_mem_footprint.txt -v julia --project=. src/Tempus.jl AttMpls_empiric_wiley_empiric_tcp_100G.json paths
/usr/bin/time -o /mnt/data/tempus_out/AttMpls_empiric_wiley_empiric_tcp_ecs_mem_footprint.txt -v julia --project=. src/Tempus.jl AttMpls_empiric_wiley_empiric_tcp_100G.json ecs
/usr/bin/time -o /mnt/data/tempus_out/AttMpls_empiric_wiley_empiric_tcp_optimal_mem_footprint.txt -v julia --project=. src/Tempus.jl AttMpls_empiric_wiley_empiric_tcp_100G.json optimal


/usr/bin/time -o /mnt/data/tempus_out/Uninett2010_empiric_wiley_empiric_tcp_base_mem_footprint.txt -v julia --project=. src/Tempus.jl Uninett2010_empiric_wiley_empiric_tcp_100G.json base
/usr/bin/time -o /mnt/data/tempus_out/Uninett2010_empiric_wiley_empiric_tcp_paths_mem_footprint.txt -v julia --project=. src/Tempus.jl Uninett2010_empiric_wiley_empiric_tcp_100G.json paths
/usr/bin/time -o /mnt/data/tempus_out/Uninett2010_empiric_wiley_empiric_tcp_ecs_mem_footprint.txt -v julia --project=. src/Tempus.jl Uninett2010_empiric_wiley_empiric_tcp_100G.json ecs
/usr/bin/time -o /mnt/data/tempus_out/Uninett2010_empiric_wiley_empiric_tcp_optimal_mem_footprint.txt -v julia --project=. src/Tempus.jl Uninett2010_empiric_wiley_empiric_tcp_100G.json optimal

 