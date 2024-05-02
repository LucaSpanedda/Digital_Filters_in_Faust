// import Standard Faust library 
// https://github.com/grame-cncm/faustlibraries/ 
import("stdfaust.lib");

// Robert Bristow-Johnson's Biquad Filter - Direct Form 1
// https://webaudio.github.io/Audio-EQ-Cookbook/audio-eq-cookbook.html
biquadFilter(b0, b1, b2, a0, a1, a2) = biquadFilter
    with{
        biquadFilter =  _ <: _, (mem  <: (_, mem)) : (_ * a0, _ * a1, _ * a2) :> _ : 
                        ((_, _) :> _) ~ (_ <: (_, mem) : (_ * -b1, _ * -b2) :> _);
    };

// LPF: Low-Pass Filter
LPFCoeffs(f0, Q) = (b0, b1, b2, a0, a1, a2)
with{
    w0 = 2 * ma.PI * f0 / ma.SR; 
    alpha = sin(w0) / (2 * Q);
    b0 = (1 - cos(w0)) / 2; 
    b1 = 1 - cos(w0);
    b2 = (1 - cos(w0)) / 2;
    a0 = 1 + alpha;
    a1 = -2 * cos(w0);
    a2 = 1 - alpha;
};

// HPF: High-Pass Filter
HPFCoeffs(f0, Q) = (b0, b1, b2, a0, a1, a2) 
with{
    w0 = 2 * ma.PI * f0 / ma.SR;
    alpha = sin(w0) / (2 * Q);
    b0 = (1 + cos(w0)) / 2;
    b1 = -(1 + cos(w0));
    b2 = (1 + cos(w0)) / 2;
    a0 = 1 + alpha;
    a1 = -2 * cos(w0);
    a2 = 1 - alpha;
};

// BPF: Band-Pass Filter
BPFCoeffs(f0, Q) = (b0, b1, b2, a0, a1, a2) 
with{
    w0 = 2 * ma.PI * f0 / ma.SR;
    alpha = sin(w0) / (2 * Q);
    b0 = sin(w0) / 2;
    b1 = 0;
    b2 = - (sin(w0) / 2);
    a0 = 1 + alpha;
    a1 = - 2 * cos(w0);
    a2 = 1 - alpha;
};

// BPF (with constant 0 dB peak gain)
BPFCoeffs0dB(f0, Q) = (b0, b1, b2, a0, a1, a2) 
with{
    w0 = 2 * ma.PI * f0 / ma.SR;
    alpha = sin(w0) / (2 * Q);
    b0 = alpha;
    b1 = 0;
    b2 = -alpha;
    a0 = 1 + alpha;
    a1 = -2 * cos(w0);
    a2 = 1 - alpha;
};

// Notch Filter
NotchCoeffs(f0, Q) = (b0, b1, b2, a0, a1, a2) 
with{
    w0 = 2 * ma.PI * f0 / ma.SR;
    alpha = sin(w0) / (2 * Q);
    b0 = 1;
    b1 = -2 * cos(w0);
    b2 = 1;
    a0 = 1 + alpha;
    a1 = -2 * cos(w0);
    a2 = 1 - alpha;
};

// All-Pass Filter
APFCoeffs(f0, Q) = (b0, b1, b2, a0, a1, a2) 
with{
    w0 = 2 * ma.PI * f0 / ma.SR;
    alpha = sin(w0) / (2 * Q);
    b0 = 1 - alpha;
    b1 = -2 * cos(w0);
    b2 = 1 + alpha;
    a0 = 1 + alpha;
    a1 = -2 * cos(w0);
    a2 = 1 - alpha;
};

// Peaking EQ Filter
PeakingEQCoeffs(f0, Q, dBgain) = (b0, b1, b2, a0, a1, a2) 
with{
    w0 = 2 * ma.PI * f0 / ma.SR;
    A = 10 ^ (dBgain / 40);
    alpha = sin(w0) / (2 * Q);
    b0 = 1 + alpha * A;
    b1 = -2 * cos(w0);
    b2 = 1 - alpha * A;
    a0 = 1 + alpha / A;
    a1 = -2 * cos(w0);
    a2 = 1 - alpha / A;
};

// Low Shelf Filter
LowShelfCoeffs(f0, S, dBgain) = (b0, b1, b2, a0, a1, a2) 
with{
    w0 = 2 * ma.PI * f0 / ma.SR;
    A = sqrt(10 ^ (dBgain / 20));
    alpha = sin(w0) / 2 * sqrt((A + 1 / A) * (1 / S - 1) + 2);
    b0 = A * ((A + 1) - (A - 1) * cos(w0) + 2 * sqrt(A) * alpha);
    b1 = 2 * A * ((A - 1) - (A + 1) * cos(w0));
    b2 = A * ((A + 1) - (A - 1) * cos(w0) - 2 * sqrt(A) * alpha);
    a0 = (A + 1) + (A - 1) * cos(w0) + 2 * sqrt(A) * alpha;
    a1 = -2 * ((A - 1) + (A + 1) * cos(w0));
    a2 = (A + 1) + (A - 1) * cos(w0) - 2 * sqrt(A) * alpha;
};

// High Shelf Filter
HighShelfCoeffs(f0, S, dBgain) = (b0, b1, b2, a0, a1, a2) 
with{
    w0 = 2 * ma.PI * f0 / ma.SR;
    A = sqrt(10 ^ (dBgain / 20));
    alpha = sin(w0) / 2 * sqrt((A + 1 / A) * (1 / S - 1) + 2);
    b0 = A * ((A + 1) + (A - 1) * cos(w0) + 2 * sqrt(A) * alpha);
    b1 = -2 * A * ((A - 1) + (A + 1) * cos(w0));
    b2 = A * ((A + 1) + (A - 1) * cos(w0) - 2 * sqrt(A) * alpha);
    a0 = (A + 1) - (A - 1) * cos(w0) + 2 * sqrt(A) * alpha;
    a1 = 2 * ((A - 1) - (A + 1) * cos(w0));
    a2 = (A + 1) - (A - 1) * cos(w0) - 2 * sqrt(A) * alpha;
};