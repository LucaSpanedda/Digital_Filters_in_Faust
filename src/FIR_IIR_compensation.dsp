// import Standard Faust library 
// https://github.com/grame-cncm/faustlibraries/ 
import("stdfaust.lib"); 

// feedforward 3 samples = feedback 2 samples (+1 implicit samples)
//process = no.noise <: (_ + _@3), (_ (_ + _) ~ _@2);

// feedforward signal derivative * -1 = feedback pole position
//process = no.noise <: (_ + _@3), (_ * -1 + _@3), (_ (_ + _) ~ _@2);

// IIR into FIR with same pole/zero position have flat frequency response = FIR into IIR with same pole/zero position have flat frequency response
process = no.noise <: ((_ (_ + _) ~ _) <: (_ * -1 + _')), ((_ * -1 + _') : (_ (_ + _) ~ _));
