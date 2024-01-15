julia --project=. src/Tempus.jl Latnet_uniform_10000_100000_empiric_tcp_100G.json optimal > ./tempus_out/Latnet_uniform_10000_100000_empiric_tcp_optimal.txt

julia --project=. src/Tempus.jl Highwinds_uniform_10000_100000_empiric_tcp_100G.json optimal > ./tempus_out/Highwinds_uniform_10000_100000_empiric_tcp_optimal.txt

julia --project=. src/Tempus.jl AttMpls_uniform_10000_100000_empiric_tcp_100G.json optimal > ./tempus_out/AttMpls_uniform_10000_100000_empiric_tcp_optimal.txt

julia --project=. src/Tempus.jl Uninett2010_uniform_10000_100000_empiric_tcp_100G.json optimal > ./tempus_out/Uninett2010_uniform_10000_100000_empiric_tcp_optimal.txt

julia --project=. src/Tempus.jl GtsCe_uniform_10000_100000_empiric_tcp_100G.json optimal > ./tempus_out/GtsCe_uniform_10000_100000_empiric_tcp_optimal.txt