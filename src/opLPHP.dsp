// import Standard Faust library 
// https://github.com/grame-cncm/faustlibraries/ 
import("stdfaust.lib");

opLPHP(g, x0) = filter ~ _
    with{
        G1 = g * - 1;
        G2 = 1 - abs(g);
        filter(x1) = x00
            with{
                x00 = x0 * G2 + x1 * G1;
            };
        };
        
process = no.noise : opLPHP(hslider("G - LP / HP", 0, -1, 1, .00001));