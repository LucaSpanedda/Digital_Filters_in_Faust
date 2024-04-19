// import Standard Faust library 
// https://github.com/grame-cncm/faustlibraries/ 
import("stdfaust.lib");

// (g) = give amplitude 1-0(open-close) for the lowpass cut
opf(g, x) = x * g : + ~ (_ : * (1 - g));
process = _ : opf(0.1);