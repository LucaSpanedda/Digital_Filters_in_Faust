// import Standard Faust library 
// https://github.com/grame-cncm/faustlibraries/ 
import("stdfaust.lib");

dcblocker(zeroG, poleG) = fir : op
    with{
        fir(x0) = filter ~ _ : (!, _)
            with{
                G1 = zeroG;
                filter(x1) = x00, x11
                    with{
                        x00 = x0;
                        x11 = x0 - x1 * G1;
                    };
                };
        op(x0) = filter ~ _ 
            with{
                G2 = poleG;
                filter(x1) = x00
                    with{
                        x00 = x0 + x1 * G2;
                    };
                };
    }; 
process = os.osc(100) + 1 <: dcblocker(1, 0.995), _, fi.dcblocker, _;