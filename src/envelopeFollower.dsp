// import Standard Faust library 
// https://github.com/grame-cncm/faustlibraries/ 
import("stdfaust.lib");

envelopeFollower(period, x0) = filter ~ _
    with{ 
        limitZero = max(ma.EPSILON, period);
        G = (2.0 * ma.PI) * (1.0 / ma.SR);
        C = exp(- G / limitZero);
        filter(x1) = x00
            with{
                absX = abs(x0);
                x00 =  max(absX, x1 * C);
            };
        };
        
process = envelopeFollower(0.5);