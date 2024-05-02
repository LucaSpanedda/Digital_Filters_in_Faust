// import Standard Faust library 
// https://github.com/grame-cncm/faustlibraries/ 
import("stdfaust.lib");

opLPSec(sec, x0) = filter ~ _
    with{ 
        FC = 1 / sec;
        G = tan(FC * ma.PI / ma.SR);
        K = G / (1 + G);
        L = 1 / (1 + G);
        filter(x1) = x00
            with{
                x00 = x0 * K + x1 * L;
            };
        };

process = 1 : opLPSec(1);