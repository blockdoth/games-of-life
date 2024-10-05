# time python ./python/main.py < config
# time pypy ./python/main.py < config
# time cc ./c/main.c -l raylib -o ./c/main && ./c/main < config
rustc -o ./rust/main ./rust/main.rs --extern raylib=
