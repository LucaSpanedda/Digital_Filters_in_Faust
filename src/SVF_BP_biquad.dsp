// import Standard Faust library 
// https://github.com/grame-cncm/faustlibraries/ 
import("stdfaust.lib"); 

// Robert Bristow-Johnson's Biquad Filter - Direct Form 1
BPBiquad(g, q, f) = biquadFilter : _ * g
    with{
        biquadFilter = _ <: _, (mem  <: (_, mem)) : (_ * a0, _ * a1, _ * a2) :> _ : 
                            ((_, _) :> _) ~ (_ <: (_, mem) : (_ * -b1, _ * -b2) :> _);
        F = max(ma.EPSILON, min(20000,  f));
        Q = max(ma.EPSILON, min(ma.MAX, q));
        K = tan(ma.PI * F / ma.SR);
        norm = 1 / (1 + K / Q + K * K);
        a0 = K / Q * norm;
        a1 = 0;
        a2 = -a0;
        b1 = 2 * (K * K - 1) * norm;
        b2 = (1 - K / Q + K * K) * norm;
    };

process = _ : BPBiquad(4, 10000, 4000);