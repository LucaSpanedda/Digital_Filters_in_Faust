import("stdfaust.lib");

// Robert Bristow-Johnson's Biquad Filter - Direct Form 1
// https://webaudio.github.io/Audio-EQ-Cookbook/audio-eq-cookbook.html
biquadFilter(a0, a1, a2, b1, b2) = biquadFilter
    with{
        biquadFilter =  _ <: _, (mem  <: (_, mem)) : (_ * a0, _ * a1, _ * a2) :> _ : 
                        ((_, _) :> _) ~ (_ <: (_, mem) : (_ * -b1, _ * -b2) :> _);
    };

A = pow(10, dbGain / 40);
omega(x) = (2 * ma.PI * x) / ma.SR;
sn(x) = sin(omega(x));
cs(x) = cos(omega(x)); 
alpha(cf, q) = sin(omega(cf)) / (2 * q);

LPF = a0, a1, a2, b1, b2, _
with{
    cf = 100;
    q = 0.707;
    b0 = (1 + alpha(cf, q));
    a0 = ((1 - cs(cf)) / 2) / b0;
    a1 = (1 - cs(cf)) / b0;
    a2 = ((1 - cs(cf)) / 2) / b0;
    b1 = (-2 * cs(cf)) / b0;
    b2 = (1 - alpha(cf, q)) / b0;
};

HPF = a0, a1, a2, b1, b2, _
with{
    cf = 10000;
    q = 0.007;
    b0 = (1 + alpha(cf, q));
    a0 = ((1 + cs(cf)) / 2) / b0;
    a1 = (-1 * (1 + cs(cf))) / b0;
    a2 = ((1 + cs(cf)) / 2) / b0;
    b1 = (-2 * cs(cf)) / b0;
    b2 = (1 - alpha(cf, q)) / b0;
};


BPF = a0, a1, a2, b1, b2, _
with{
    cf = 10000;
    q = 1000;
    b0 = 1 + alpha(cf, q);
    a0 = alpha(cf, q) / b0;
    a1 = 0;
    a2 = - alpha(cf, q) / b0;
    b1 = (-2 * cs(cf)) / b0;
    b2 = (1 - alpha(cf, q)) / b0;
};

NOTCH = a0, a1, a2, b1, b2, _
with{
    cf = 10000;
    q = 0.1;
    b0 = 1 + alpha(cf, q);
    a0 = 1 / b0;
    a1 = (-2 * cs(cf)) / b0;
    a2 = 1 / b0;
    b1 = (-2 * cs(cf)) / b0;
    b2 = (1 - alpha(cf, q)) / b0;
};

PEAK = a0, a1, a2, b1, b2, _
with{
    cf = 10000;
    q = 100;
    A = 10;
    b0 = 1 + (alpha(cf, q) / A);
    a0 = (1 + (alpha(cf, q) * A)) / b0;
    a1 = (-2 * cs(cf)) / b0;
    a2 = (1 - (alpha(cf, q) * A)) / b0;
    b1 = (-2 * cs(cf)) / b0;
    b2 = (1 - (alpha(cf, q) / A)) / b0;
};

LSH = _ : biquadFilter(b0, b1, b2, 0, a1, a2)
with{
        b0 = A * ((A + 1) - (A - 1) * cs + beta * sn);
        b1 = 2 * A * ((A - 1) - (A + 1) * cs);
        b2 = A * ((A + 1) - (A - 1) * cs - beta * sn);
        a0 = (A + 1) + (A - 1) * cs + beta * sn;
        a1 = -2 * ((A - 1) + (A + 1) * cs);
        a2 = (A + 1) + (A - 1) * cs - beta * sn;
};

HSH = _ : biquadFilter(b0, b1, b2, 0, a1, a2)
with{
        b0 = A * ((A + 1) + (A - 1) * cs + beta * sn);
        b1 = -2 * A * ((A - 1) + (A + 1) * cs);
        b2 = A * ((A + 1) + (A - 1) * cs - beta * sn);
        a0 = (A + 1) - (A - 1) * cs + beta * sn;
        a1 = 2 * ((A - 1) - (A + 1) * cs);
        a2 = (A + 1) - (A - 1) * cs - beta * sn;
};

biquad(a0, a1, a2, b1, b2, x) = fir :  + 
                                       ~ iir
      with {
           fir = a0 * x + a1 * x' + a2 * x'';
           iir(fb) = -b1 * fb - b2 * fb';
      };

process = no.noise : BPF <: biquadFilter, biquad;
