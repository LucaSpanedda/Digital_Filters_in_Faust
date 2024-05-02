// Zavalishin Onepole TPT Filter
// TPT version of the One-Pole Filter by Vadim Zavalishin
// reference : (by Will Pirkle)
// http://www.willpirkle.com/Downloads/AN-4VirtualAnalogFilters.2.0.pdf
onePoleTPT(cf, x) = loop ~ _ : ! , si.bus(3)
    with {
        g = tan(cf * ma.PI * ma.T);
        G = g / (1.0 + g);
        loop(s) = u , lp , hp , ap
            with {
            v = (x - s) * G; u = v + lp; lp = v + s; hp = x - lp; ap = lp - hp;
            };
    };

// Lowpass  TPT
LPTPT(cf, x) = onePoleTPT(cf, x) : (_ , ! , !);

// Highpass TPT
HPTPT(cf, x) = onePoleTPT(cf, x) : (! , _ , !);

// Allpass TPT
APTPT(cf, x) = onePoleTPT(cf, x) : (!, !, _);