julia --project=. src/Tempus.jl Latnet_empiric_wiley_empiric_tcp_100G.json paths > ./tempus_out/Latnet_empiric_wiley_empiric_tcp_paths.txt

julia --project=. src/Tempus.jl Highwinds_empiric_wiley_empiric_tcp_100G.json paths > ./tempus_out/Highwinds_empiric_wiley_empiric_tcp_paths.txt

julia --project=. src/Tempus.jl AttMpls_empiric_wiley_empiric_tcp_100G.json paths > ./tempus_out/AttMpls_empiric_wiley_empiric_tcp_paths.txt

julia --project=. src/Tempus.jl Uninett2010_empiric_wiley_empiric_tcp_100G.json paths > ./tempus_out/Uninett2010_empiric_wiley_empiric_tcp_paths.txt

julia --project=. src/Tempus.jl GtsCe_empiric_wiley_empiric_tcp_100G.json paths > ./tempus_out/GtsCe_empiric_wiley_empiric_tcp_paths.txt