// import Standard Faust library 
// https://github.com/grame-cncm/faustlibraries/ 
import("stdfaust.lib");

opLP(g, x0) = filter ~ _ 
    with{
        G1 = g;
        G2 = 1 - g;
        filter(x1) = x00
            with{
                x00 = x0 * G2 + x1 * G1;
            };
        };
        
process = no.noise : opLP(0.99);