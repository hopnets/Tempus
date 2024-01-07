mkdir /mnt/data/tempus_out

julia --project=. src/Tempus.jl Latnet_empiric_wiley_empiric_dctcp_100G.json paths > /mnt/data/tempus_out/Latnet_empiric_wiley_empiric_dctcp_paths.txt

julia --project=. src/Tempus.jl Highwinds_empiric_wiley_empiric_dctcp_100G.json paths > /mnt/data/tempus_out/Highwinds_empiric_wiley_empiric_dctcp_paths.txt

julia --project=. src/Tempus.jl AttMpls_empiric_wiley_empiric_dctcp_100G.json paths > /mnt/data/tempus_out/AttMpls_empiric_wiley_empiric_dctcp_paths.txt

julia --project=. src/Tempus.jl Uninett2010_empiric_wiley_empiric_dctcp_100G.json paths > /mnt/data/tempus_out/Uninett2010_empiric_wiley_empiric_dctcp_paths.txt

julia --project=. src/Tempus.jl GtsCe_empiric_wiley_empiric_dctcp_100G.json paths > /mnt/data/tempus_out/GtsCe_empiric_wiley_empiric_dctcp_paths.txt