mkdir /mnt/data/tempus_out

julia --project=. src/Tempus.jl fattree4_empiric_random_empiric_dctcp_100G.json paths > /mnt/data/tempus_out/fattree4_empiric_random_empiric_dctcp_paths.txt

julia --project=. src/Tempus.jl fattree6_empiric_random_empiric_dctcp_100G.json paths > /mnt/data/tempus_out/fattree6_empiric_random_empiric_dctcp_paths.txt

julia --project=. src/Tempus.jl fattree8_empiric_random_empiric_dctcp_100G.json paths > /mnt/data/tempus_out/fattree8_empiric_random_empiric_dctcp_paths.txt

julia --project=. src/Tempus.jl fattree10_empiric_random_empiric_dctcp_100G.json paths > /mnt/data/tempus_out/fattree10_empiric_random_empiric_dctcp_paths.txt

julia --project=. src/Tempus.jl fattree12_empiric_random_empiric_dctcp_100G.json paths > /mnt/data/tempus_out/fattree12_empiric_random_empiric_dctcp_paths.txt

julia --project=. src/Tempus.jl fattree14_empiric_random_empiric_dctcp_100G.json paths > /mnt/data/tempus_out/fattree14_empiric_random_empiric_dctcp_paths.txt

julia --project=. src/Tempus.jl fattree16_empiric_random_empiric_dctcp_100G.json paths > /mnt/data/tempus_out/fattree16_empiric_random_empiric_dctcp_paths.txt

julia --project=. src/Tempus.jl fattree24_empiric_random_empiric_dctcp_100G.json paths > /mnt/data/tempus_out/fattree24_empiric_random_empiric_dctcp_paths.txt

julia --project=. src/Tempus.jl fattree32_empiric_random_empiric_dctcp_100G.json paths > /mnt/data/tempus_out/fattree32_empiric_random_empiric_dctcp_paths.txt