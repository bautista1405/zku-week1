# ZKU - W1 Assignment

### Week 1 - https://docs.zku.academy/zku/week-1-intro-to-zkp/w1-assignment

### Here are the questions from the week 1 assignment, some of which I managed to answer

## Part 1 - Theoretical background of zk-SNARKs and zk-STARKS

### 1. Explain in 2-4 sentences why SNARK requires a trusted setup while STARK doesn’t.

SNARKs require a trusted setup to become `non-interactive`, usign a CRS model to implement some common parameters between prover and verifier thus they can talk to each other with the protocol.

STARKs don't require a trusted setup because they implement the `ROM (Random Oracle Dodel)`, using hash functions as random oracles for security purposes.

### 2. Name two more differences between SNARK and STARK proofs.

1. STARKs are secure against quantum attacks while SNARKs are not.
2. STARKs have far larger proof sizes than SNARKs, which means that verifying STARKs takes more time than SNARKs and also leads to STARKs requiring more gas.



## Part 2 - Getting started with circom and snarkjs

### 1. Fork the Week 1 repo and go into the Q2 directory. Install all the node dependencies. In the contracts/circuits folder, you will find HelloWorld.circom. Run the bash script scripts/compile-HelloWorld.sh to compile the circuit. Answer the following questions (word answers should go into the PDF file):

### a. What does the circuit in `HelloWorld.circom` do ?

This circuit template checks that `c` is the multiplication of `a` and `b`.

### b. Lines 7-12 of `compile-HelloWorld.sh` download a file called `powersOfTau28_hez_final_10.ptau` for Phase 1 trusted setup. What is a Powers of Tau ceremony? Explain why this is important in the setup of zk-SNARK applications.

The Powers of Tau ceremony is a multi-party computation (MPC) protocol for zk-SNARKs. This is important because it's used to generate initial parameters for the trusted setup.
       The ceremony ensures the security of the initial parameters with its multi-party computation used to create them. The main idea behind Powers of Tau is that by having multiple participants contribute randomness to the generation of the parameters, it becomes much more difficult for any individual machine/node, or group to tamper with them or compromise the entire security of the system.
       The ceremony proceeds in turns, one turn for each participant, and the result of each computation is added to a public transcript, so that the entire protocol can be publicly verified. As long as one participant successfully destroys their randomness when they’re finished, the resulting parameters are secure.

### c. Line 24 of `compile-HelloWorld.sh` makes a random entropy contribution as a Phase 2 trusted setup. How are Phase 1 and Phase 2 trusted setup ceremonies different from each other?

The trusted setup is done in two steps or phases. The first phase, does not depend on the program and is called `Powers of Tau`. The second phase is circuit-specific, so it should be done separately for each different program. 
       In short, the first ceremony generates most of the random toxic waste, independently of the circuit to be used, which enables re-usability of the `Powers of Tau`. The second phase generates the proving and verification keys together with all phase 2 contributions.


### 2. In this question, you will learn about an important restriction on circom circuits:

### a. In the empty scripts/compile-Multiplier3-groth16.sh, create a script to compile contracts/circuits/Multiplier3.circom and create a verifier contract modeling after compile-HelloWorld.sh.

        Done.

### b. Try to run compile-Multiplier3-groth16.sh. You should encounter an error[T3001] with the circuit as is. Explain what the error means and how it arises.

        I got the following error in the console: 

            error[T3001]: Non quadratic constraints are not allowed!
            ┌─ "Multiplier3.circom":14:4
            │
            14 │    d <== a * b * c;
            │    ^^^^^^^^^^^^^^^ found here
            │
            = call trace:
                ->Multiplier3

To understand this error we need to go through Circom's constraints generation, which accepts a certain type of expressions:
       - Constant values: only a constant value is allowed.
       - Linear expression: an expression where only addition is used. It can also be written using multiplication of variables by constants. For instance, the expression 2*x + 3*y + 2 is allowed, as it is equivalent to x + x + y + y + y + 2.
       - Quadratic expression: it is obtained by allowing a multiplication between two linear expressions and addition of a linear expression: A*B - C, where A, B and C are linear expressions. For instance, (2*x + 3*y + 2) * (x+y) + 6*x + y – 2.
       - Non quadratic expressions: any arithmetic expression which is not of the previous kind.

To go deeper, check https://docs.circom.io/circom-language/constraint-generation/  


### c. Modify Multiplier3.circom to perform a multiplication of three input signals under the restrictions of circom.

        Done.

    
### 3. In the empty scripts/compile-Multiplier3-plonk.sh, create a script to compile circuit/Multiplier3.circom using PLONK in snarkjs. Add a _plonk suffix to the build folder and the output contract to distinguish the two sets of output.

### a. You will encounter an error zkey file is not groth16 if you just change snarkjs groth16 setup to snarkjs plonk setup. Resolve this error and answer the following question - How is the process of compiling with PLONK different from compiling with Groth16?

The difference is that Groth16 requires a trusted ceremony for each circuit. Plonk does not require it, it's enough with the Powers
        of Tau, which is universal.

We fix the error related to zkey file not being groth16 by removing these two lines from the initial groth16 script: <br/>

`snarkjs zkey contribute Multiplier3/circuit_0000.zkey Multiplier3/circuit_final.zkey --name="1st Contributor Name" -v -e="random text"`

`snarkjs zkey export verificationkey Multiplier3/circuit_final.zkey Multiplier3/verification_key.json`

And just using this one:
    `snarkjs plonk setup Multiplier3/Multiplier3.r1cs powersOfTau28_hez_final_10.ptau Multiplier3/circuit_final.zkey`

Note the keyword `plonk` at the beginning to use it as proving system and the final circuit file as zkey at the end.

### b. What are the practical differences between Groth16 and PLONK? Hint: compare and contrast the resulted contracts and running time of unit tests (see Q5 below) from the two protocols.

At a first look, the PLONK resulted contract is very much longer, so one would think that the running time of unit tests over it also will be longer than the one over Groth16 resulted contract.         

### 4. So far we have not tested our circuit yet. While you can verify your circuit in the terminal using snarkjs groth16 fullprove, you can also do so directly in a Node.js script. We will practice doing so by creating some unit tests to try out our verifier contract(s):

### a. Running npx hardhat test will prompt an error HH606. Before we can test our verifier contracts with hardhat, we must modify the solidity version. In scripts/bump-solidity.js, we have already written the regular expressions to modify HelloWorldVerifier.sol. Add script to bump-solidity.js to do the same for your new contract for Multiplier3.

        Done.

### b. You can now perform the unit tests for HelloWorldVerifier by running npm run test. Add inline comments to explain what each line in test/test.js is doing.

### c. In test/test.js, add the unit tests for Multiplier3 for both the Groth16 and PLONK versions. Include a screenshot of all the tests (for HelloWorld, Multiplier3 with Groth16, and Multiplier3 with PLONK) passing in your PDF file.


## Part 3 - Reading and designing circuits with circom

Though it will be nice if we write entirely innovative circuits for every project we create, we should also utilize existing circuit libraries to help us. In this question, you will be learning about two such libraries that you can import to create more complicated circuits. To start, go into the Q3 directory in Week 1 repo and run npm install in each project folder to install the dependencies.

### 1. circomlib is the official library of circuit templates released by iden3, the creator of Circom. One important template included is comparators.circom, which implements value comparisons between two numbers. The following questions will cover the use of this template in our own circuits:

### a. contracts/circuits/LessThan10.circom implements a circuit that verifies an input is less than 10 using the LessThan template. Study how the template is used in this circuit. What does the 32 in Line 9 stand for?

The LessThan template is used in this circuit to check if in < 10. The integer 32 is passed as argument to LessThan template, and needs to be at least the max bit count between input in and the number 10. We can assign this integer to be 64-bit as it is generic enough for an integer input.

Also, [this article](https://blog.trailofbits.com/2023/03/21/circomspect-static-analyzer-circom-more-passes/) can come in handy.

### b. What are the possible outputs for the LessThan template and what do they mean respectively? (If you cannot figure this out by reading the code alone, feel free to compile the circuit and test with different input values.)

The possible outputs for the LessThan template are 0 and 1:

            Signal input in = 15, which can be represented with 4 bits (1 1 1 1). 
            The LessThan circuit attempts to build the bit representation of the minimum integer that requires one (1) additional bit, which is 16 (represented with 5 bits: 1 0 0 0 0)
            The LessThan circuit will then add the result of (in - 10) to the 5-bit number. 
            If in - 10 < 0, then the most significant bit of 5-bit number will become 0.
            If in - 10 > 0, then the most significant bit of 5-bit number will remain 1.
            So signal output = 1 - the most significant bit of 5-bit number, which is either 0 (meaning in >= 10) or 1 (meaning in < 10).

### c. Proving a number is within a range without revealing the actual number could be useful in applications like proving our income when applying for a credit card. In contracts/circuits/RangeProof.circom, create a template (not circuit, so don’t add component main = ...) that uses GreaterEqThan and LessEqThan to perform a range proof.
