// import Standard Faust library 
// https://github.com/grame-cncm/faustlibraries/ 
import("stdfaust.lib"); 

// Robert Bristow-Johnson's Biquad Filter - Direct Form 1
// https://webaudio.github.io/Audio-EQ-Cookbook/audio-eq-cookbook.html
biquadFilter(a0, a1, a2, b1, b2) = biquadFilter
    with{
        biquadFilter =  _ <: _, (mem  <: (_, mem)) : (_ * a0, _ * a1, _ * a2) :> _ : 
                        ((_, _) :> _) ~ (_ <: (_, mem) : (_ * -b1, _ * -b2) :> _);
    };


// Robert Bristow-Johnson's Biquad Filter - Coefficents

// Functions for the filter
// Angular Frequency formula
omega(x) = (2 * ma.PI * x) / ma.SR;
// Angular Frequency in the sine domain
sn(x) = sin(omega(x));
// Angular Frequency in the cosine domain
cs(x) = cos(omega(x)); 
// Alpha
alpha(cf, q) = sin(omega(cf)) / (2 * q);

// Lowpass Filter
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

// Highpass filter
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

// Bandpass Filter
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

// Notch filter
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

// Peaking EQ filter
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

// Low Shelf Filter
LSF = a0, a1, a2, b1, b2, _
with{
    cf = 10000;
    q = 1;
    //dbGain 20;
    A  = pow(10, -20 /40);
    beta = sqrt(A + A);
    b0 = (A + 1) + (A - 1) * cs(cf) + beta * alpha(cf, q);
    a0 = (A * ((A + 1) - (A - 1) * cs(cf) + beta * alpha(cf, q))) /b0;
    a1 = (2 * A * ((A - 1) - (A + 1) * cs(cf))) / b0;
    a2 = (A * ((A + 1) - (A - 1) * cs(cf) - beta * alpha(cf, q))) /b0;
    b1 = (-2 * ((A - 1) + (A + 1) * cs(cf))) / b0;
    b2 = ((A + 1) + (A - 1) * cs(cf) - beta * alpha(cf, q)) / b0;
};

// High Shelf Filter
HSF = a0, a1, a2, b1, b2, _
with{
    cf = 10000;
    q = 1;
    //dbGain 20;
    A  = pow(10, -20 /40);
    beta = sqrt(A + A);
    b0 = (A + 1) - (A - 1) * cs(cf) + beta * alpha(cf, q);
    a0 = (A * ((A + 1) + (A - 1) * cs(cf) + beta * alpha(cf, q))) /b0;
    a1 = (2 * A * ((A - 1) + (A + 1) * cs(cf))) / b0;
    a2 = (A * ((A + 1) + (A - 1) * cs(cf) - beta * alpha(cf, q))) /b0;
    b1 = (2 * ((A - 1) - (A + 1) * cs(cf))) / b0;
    b2 = ((A + 1) - (A - 1) * cs(cf) - beta * alpha(cf, q)) / b0;
};

process = no.noise : HSF : biquadFilter;
