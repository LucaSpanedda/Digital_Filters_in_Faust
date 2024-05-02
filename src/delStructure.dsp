// import Standard Faust library 
// https://github.com/grame-cncm/faustlibraries/ 
import("stdfaust.lib");

delStructure(x0) = filter ~ si.bus(3)
    with{
        filter(x1, x2, x3) = x00, x11, x22, x33
            with{
                x00 = x0;
                x11 = x1;
                x22 = x2;
                x33 = x3;
            };
        };

delOutput = delStructure : (!, !, !, _);

process = no.noise : delOutput;