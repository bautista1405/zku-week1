#!/bin/bash

# [assignment] create your own bash script to compile Multiplier3.circom using PLONK below

cd contracts/circuits

mkdir Multiplier3_plonk

echo "Compiling Multiplier3.circom..."

# compile circuit

circom Multiplier3.circom --r1cs --wasm --sym -o Multiplier3
snarkjs r1cs info Multiplier3/Multiplier3.r1cs

# use PLONK

snarkjs plonk setup Multiplier3/Multiplier3.r1cs powersOfTau28_hez_final_10.ptau Multiplier3/circuit_final.zkey

# generate solidity contract
snarkjs zkey export solidityverifier Multiplier3/circuit_final.zkey ../Multiplier3Verifier_plonk.sol

cd ../..
