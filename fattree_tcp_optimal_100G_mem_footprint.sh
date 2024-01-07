
/usr/bin/time -o /mnt/data/tempus_out/fattree8_empiric_random_empiric_tcp_base_mem_footprint.txt -v julia --project=. src/Tempus.jl fattree8_empiric_random_empiric_tcp_100G.json base

/usr/bin/time -o /mnt/data/tempus_out/fattree8_empiric_random_empiric_tcp_paths_mem_footprint.txt -v julia --project=. src/Tempus.jl fattree8_empiric_random_empiric_tcp_100G.json paths

/usr/bin/time -o /mnt/data/tempus_out/fattree8_empiric_random_empiric_tcp_ecs_mem_footprint.txt -v julia --project=. src/Tempus.jl fattree8_empiric_random_empiric_tcp_100G.json ecs

/usr/bin/time -o /mnt/data/tempus_out/fattree8_empiric_random_empiric_tcp_optimal_mem_footprint.txt -v julia --project=. src/Tempus.jl fattree8_empiric_random_empiric_tcp_100G.json optimal


/usr/bin/time -o /mnt/data/tempus_out/fattree16_empiric_random_empiric_tcp_base_mem_footprint.txt -v julia --project=. src/Tempus.jl fattree16_empiric_random_empiric_tcp_100G.json base

/usr/bin/time -o /mnt/data/tempus_out/fattree16_empiric_random_empiric_tcp_paths_mem_footprint.txt -v julia --project=. src/Tempus.jl fattree16_empiric_random_empiric_tcp_100G.json paths

/usr/bin/time -o /mnt/data/tempus_out/fattree16_empiric_random_empiric_tcp_ecs_mem_footprint.txt -v julia --project=. src/Tempus.jl fattree16_empiric_random_empiric_tcp_100G.json ecs

/usr/bin/time -o /mnt/data/tempus_out/fattree16_empiric_random_empiric_tcp_optimal_mem_footprint.txt -v julia --project=. src/Tempus.jl fattree16_empiric_random_empiric_tcp_100G.json optimal


/usr/bin/time -o /mnt/data/tempus_out/fattree32_empiric_random_empiric_tcp_base_mem_footprint.txt -v julia --project=. src/Tempus.jl fattree32_empiric_random_empiric_tcp_100G.json base

/usr/bin/time -o /mnt/data/tempus_out/fattree32_empiric_random_empiric_tcp_paths_mem_footprint.txt -v julia --project=. src/Tempus.jl fattree32_empiric_random_empiric_tcp_100G.json paths

/usr/bin/time -o /mnt/data/tempus_out/fattree32_empiric_random_empiric_tcp_ecs_mem_footprint.txt -v julia --project=. src/Tempus.jl fattree32_empiric_random_empiric_tcp_100G.json ecs

/usr/bin/time -o /mnt/data/tempus_out/fattree32_empiric_random_empiric_tcp_optimal_mem_footprint.txt -v julia --project=. src/Tempus.jl fattree32_empiric_random_empiric_tcp_100G.json optimal