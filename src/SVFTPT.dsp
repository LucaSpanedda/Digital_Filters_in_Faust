// Vadim Zavalishin's SVF TPT filter (Topology Preserving Transform)
SVFTPT(Q, cf, x) = loop ~ si.bus(2) : (! , ! , _ , _ , _ , _ , _)
    with {
        g = tan(cf * ma.PI * ma.T);
        R = 1.0 / (2.0 * Q);
        G1 = 1.0 / (1.0 + 2.0 * R * g + g * g);
        G2 = 2.0 * R + g;
        loop(s1, s2) = u1 , u2 , lp , hp , bp * 2.0 * R , x - bp * 4.0 * R , bp
            with {
                hp = (x - s1 * G2 - s2) * G1;
                v1 = hp * g;
                bp = s1 + v1;
                v2 = bp * g;
                lp = s2 + v2;
                u1 = v1 + bp;
                u2 = v2 + lp;
            };
    };

// HP - LP SVF 
LPSVFTPT(Q, cf, x) = SVFTPT(Q, cf, x) : (_ , ! , ! , ! , !);
HPSVFTPT(Q, cf, x) = SVFTPT(Q, cf, x) : (! , _ , ! , ! , !);

// Normalized Bandpass SVF 
BPSVFTPT(Q, cf, x) = SVFTPT(Q, cf, x) : (! , ! , _ , ! , !);

NotchSVFTPT(Q, cf, x) = x - BPSVF(Q, cf, x);
APSVFTPT(Q, cf, x) = SVFTPT(Q, cf, x) : (! , ! , ! , _ , !);
PeakingSVFTPT(Q, cf, x) = LPSVF(Q, cf, x) - HPSVF(Q, cf, x);
BP2SVFTPT(Q, cf, x) = SVFTPT(Q, cf, x) : (! , ! , ! , ! , _);

// Bandpass Bandwidth SVF (danger = division for 0)
BPBWSVFTPT(BW, CF, x) = BPSVF((CF / BW), CF, x);