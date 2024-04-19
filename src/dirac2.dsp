 // import Standard Faust library 
 // https://github.com/grame-cncm/faustlibraries/ 
 import("stdfaust.lib"); 
  
 // Dirac Impulse with delay lines - Impulse at Compile Time 
 dirac(x) = x - x'; 
 process = dirac(1) <: _, _; 