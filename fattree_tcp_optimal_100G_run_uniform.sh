julia --project=. src/Tempus.jl fattree4_uniform_1000_5000_empiric_tcp.json optimal > ./tempus_out/fattree4_uniform_1000_5000_empiric_tcp_optimal.txt

julia --project=. src/Tempus.jl fattree8_uniform_1000_5000_empiric_tcp.json optimal > ./tempus_out/fattree8_uniform_1000_5000_empiric_tcp_optimal.txt

julia --project=. src/Tempus.jl fattree16_uniform_1000_5000_empiric_tcp.json optimal > ./tempus_out/fattree16_uniform_1000_5000_empiric_tcp_optimal.txt

julia --project=. src/Tempus.jl fattree32_uniform_1000_5000_empiric_tcp.json optimal > ./tempus_out/fattree32_uniform_1000_5000_empiric_tcp_optimal.txt