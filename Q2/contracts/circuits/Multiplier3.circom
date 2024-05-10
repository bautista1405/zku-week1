pragma circom 2.0.0;

// [assignment] Modify the circuit below to perform a multiplication of three signals

template Multiplier2(){
   //Declaration of signals
   signal input in1;
   signal input in2;
   signal output out <== in1 * in2;
}

//This circuit multiplies in1, in2, and in3.
template Multiplier3() {
   //Declaration of signals and components.
   // As expected, we first declare three input signals in1, in2, in3, and an output signal out and two instances of Multiplier2. 
   // Instantiations of templates are done using the keyword component. We need an instance mult1 to multiply in1 and in2. In order to assign 
   // the values of the input signals of mult1 we use the dot notation ".". Once mult1.in1 and mult1.in2 have their values set, then the value 
   // of mult1.out is computed. This value can be now used to set the input value of mult2 of the second instance of Multiplier2 to multiply 
   // in1*in2 and in3 obtaining the final result in1*in2*in3.

   signal input in1;
   signal input in2;
   signal input in3;
   signal output out;
   component mult1 = Multiplier2();
   component mult2 = Multiplier2();

   //Statements.
   mult1.in1 <== in1;
   mult1.in2 <== in2;
   mult2.in1 <== mult1.out;
   mult2.in2 <== in3;
   out <== mult2.out;
}

//Finally, every execution starts from an initial main component defined as follows
component main {public [in1,in2,in3]} = Multiplier3();
