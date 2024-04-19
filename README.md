# Digital Filters in Faust

## Delay Lines

in FAUST the ```_``` represent a signal input.
A function with one input that goes directly to the output is written as follows: ```process = _;```.

```process = _;``` is the main function in Faust (the compiler's output function)

Delay lines in Faust are divided into the following categories:

```mem``` - indicates a single sample delay.

```@``` - indicates a number of variable delay samples.
(ex. ```_ @ 44100```), so for example a signal with 44100 samples of delay is written like: ```process = _ @ 44100;```

in a ```function(x) = x;``` a definition like: ```function(x) = x - x';``` indicates any input and: ```'``` a sample of delay, ```''``` as two samples, etc.
So ```x - x'``` is the first derivate of the signal.

Through delay lines, 
we can create a Dirac impulse, which represents 
our minimum DSP unit, namely the single sample
by putting a number 1 and subtracting the same value from it
but doing it at a delayed sample.

Example:
```
 // import Standard Faust library 
 // https://github.com/grame-cncm/faustlibraries/ 
 import("stdfaust.lib"); 
  
 // Dirac Impulse with delay lines - Impulse at Compile Time 
 dirac = 1 - 1'; 
 process = dirac, dirac; 
```
or something like:
```
 // import Standard Faust library 
 // https://github.com/grame-cncm/faustlibraries/ 
 import("stdfaust.lib"); 
  
 // Dirac Impulse with delay lines - Impulse at Compile Time 
 dirac(x) = x - x'; 
 process = dirac(1) <: _, _; 
```
These two are the same thing.

## Some Methods for Implementing Recursive Circuits in the Faust Language

Now we will illustrate 3 main methods for Implementing Recursive Circuits in the Faust Language:

- Writing the code line with internal recursion:
  
  in this way the tilde ```~``` operator sends the signal
  output to itself, to the first available input
  creating a feedback circuit.
  One way to force the operator to point to a certain point
  in the code, is to put parentheses ```()```, in this way ```~```
  will point to the input before the parenthesis. An example with an operator ```%``` in the feedback: ```process = 0.001 : (_ + _) ~ _ % 1;```
- A second method consists of using with{} .
  
  You can define a function in which are passed
  the various arguments of the function that control
  the parameters of the code,
  and say that that function is equal to
  exit from the with, with ```~ _```
  
  Example:
```
 // import Standard Faust library 
 // https://github.com/grame-cncm/faustlibraries/ 
 import("stdfaust.lib"); 

//where out ~ _ returns to itself.
function_with(input1, input2) = out ~ _
       	with{  
        		section1 = 2 * input1;
        		section2(argument1) = argument1 * section1 + input2;
        		out = section2;
        	};
        	
process = function_with(0.40, 2);
```

Moreover, with in Faust allows declaring variables
that are not pointed to from outside the code but only
from the belonging function; in this case
the function to which with belongs is "function_with".

- A third method is to use the letrec environment.
  
  with this method we can write a signal
  recursively, similar to how
  recurrence equations are written.
  ```
   // import Standard Faust library  
   // https://github.com/grame-cncm/faustlibraries
   import("stdfaust.lib"); 
   
   // letrec function 
   lowpass(cf, x) = y 
   // letrec definition 
   	letrec { 
    		'y = b0 * x - a1 * y; 
    	} 
    	// inside the letrec function 
    with { 
         b0 = 1 + a1; 
         a1 = exp(-w(cf)) * -1; 
         w(f) = 2 * ma.PI * f / ma.SR; 
    }; 
    
    // Output of the letrec function 
    process = lowpass(100, no.noise) <: si.bus(2); 
    ```
    

## Conversion of Milliseconds to Samples and Vice Versa

### Conversion from Milliseconds to Samples

Function for Conversion from Milliseconds to Samples:
we input the time in milliseconds,
and the function gives us the value in samples.

For example, if we have a sampling frequency 
of 48,000 samples per second, 
it means that 1000ms (1 second) is represented
by 48,000 parts, and therefore a single unit
of time like 1 ms. Corresponds digitally to 48 samples.

For this reason, we divide the sampling frequency
by 1000ms, resulting in a total number of samples
that corresponds to 1 ms. in the digital world at 
a certain sampling frequency.

And then we multiply the result of this operation
by the total number of milliseconds we want to obtain as 
a representation in samples.
If we multiply *10. For example, we will get
480 samples at a sampling frequency 
of 48,000 samples per second.

### Conversion from Samples to Milliseconds

Function for Conversion from Samples to Milliseconds:
we input a total number of samples,
of which we need to know the overall duration
in milliseconds based on our sampling frequency.

We know that a sampling frequency
corresponds to a set of values that express 
together the duration of 1 second (1000 ms).

It means, for example,
that at a sampling frequency of 48,000
samples per second, 
1000 milliseconds are represented by 48,000 parts.
So if we divide our 1000ms. / 
into the 48,000 parts which are the samples of our system,
we would get the duration in milliseconds of a single sample
at that sampling frequency,
in this case therefore: 
1000 / 48,000 = 0.02ms. 
And so the duration in milliseconds of a single sample at 48,000
samples per second, is 0.02 milliseconds.
If we multiply the obtained number *
a total number of samples, we will get the time in milliseconds
of those samples for that sampling frequency used.

Obviously, as can be deduced from the considerations,
as the sampling frequency increases,
the temporal duration of a single sample decreases,
and thus a greater definition.

## Phase Alignment of Feedback

In the digital domain, the feedback of a 
delay line, when applied, costs by default one sample delay.
Feedback = 1 Sample

At the moment I decide therefore to put
inside the feedback a number
of delay samples,
we can take for example 10 samples
in our delay line, it means that,
The direct signal will come out for delay samples at:

input in the delay signal --> output from the delay 10samp

1st Feedback:
output from the delay at 10samp + 1 feedback = 
input in the delay 11samp --> output from the delay 21samp

2nd Feedback:
output from the delay at 21samp + 1 feedback = 
input in the delay 22samp --> output from the delay 32samp

3rd Feedback:
output from the delay at 32samp + 1 feedback = 
input in the delay 33samp --> output from the delay 43samp

and so on...

we can therefore notice immediately that we will not have
the correct delay value required inside the same,
because of the sample delay that occurs at the moment
when I decide to create a feedback circuit.
if we use the method of subtracting one sample from the delay line,
we will have this result:

input in the delay signal --> -1, output from the delay 9samp

1st Feedback:
output from the delay at 9samp + 1 feedback = 
input in the delay 10samp --> -1, output from the delay 19samp

2nd Feedback:
output from the delay at 19samp + 1 feedback = 
input in the delay 20samp --> -1, output from the delay 29samp

3rd Feedback:
output from the delay at 29samp + 1 feedback = 
input in the delay 30samp --> -1, output from the delay 39samp

and so on...

we can therefore notice that with this method,
compared to the previous one we will have as input to the delay line
always the number of delay samples required.
But we notice that from the first output of the delayed signal
subtracting -1 we have one sample delay
less than we would like.
To realign everything, we just need to add one sample delay
to the overall output of the circuit, thus having from the first output:

input in the delay signal --> -1, output from the delay 9samp +1 = 10out

1st Feedback:
output from the delay at 9samp + 1 feedback = 
input in the delay 10samp --> -1, output from the delay 19samp +1 = 20out

and so on...

Let's proceed with an implementation:
```
// import Standard Faust library  
// https://github.com/grame-cncm/faustlibraries/  
import("stdfaust.lib"); 
  
sampdel = ma.SR;  
// sample rate - ma.SR 
  
process =   _ :  
            // input signal goes in 
            +~ @(sampdel -1) *(0.8)  
            // delay line with feedback: +~ 
            : mem 
            // output goes to a single sample delay 
            <: si.bus(2); 
```


## Digital Filters

### ONEZERO FILTER (1st Order FIR)

```_``` represents the input signal, (```_``` denotes the signal)
    it is then split into two parallel paths ```<:``` 
    one delayed by one sample ```_'``` (```'``` denotes one sample delay)
    and one without delay, ```_``` (```,``` denotes transition to the second path)
    they are then summed into a single signal ```:> _ ;```
    the delayed signal has a feedforward amplitude control ```* feedforward```
    there is a general amplitude control ```* outgain```
    on the output function onezeroout
    
```
 // import Standard Faust library 
 // https://github.com/grame-cncm/faustlibraries/ 
 import("stdfaust.lib"); 
  
  
 // (G,x) = x=input, G=give amplitude 0-1(open-close) to the delayed signal 
 OZF(G,x) = (x:mem*G), x :> +; 
  
 // out 
 process = OZF(0.1); 
```

### ONEPOLE FILTER (1st Order IIR)

```+ ~``` is the summation, and the feedback 
    of the arguments inside parentheses ```()_``` represents the input signal, (```_``` denotes the signal)
    delayed by one sample ```_``` (automatically in the feedback)
    which enters : into the gain control of the ```feedback * 1-feedback```
    the same feedback controls the input amplification
    of the signal not injected into the feedback
    there is a general amplitude control ```* outgain```
    on the output function onezeroout

```
// import Standard Faust library 
// https://github.com/grame-cncm/faustlibraries/ 
import("stdfaust.lib");

// (g) = give amplitude 1-0(open-close) for the lowpass cut
opf(g, x) = x * g : + ~ (_ : * (1 - g));
process = _ : opf(0.1);
```

and OPF with a Frequency Cut transfer function:

```
// import Standard Faust library 
// https://github.com/grame-cncm/faustlibraries/ 
import("stdfaust.lib"); 
  
 // (G)  = give amplitude 1-0 (open-close) for the lowpass cut 
 // (CF) = Frequency Cut in HZ 
 OPF(CF,x) = OPFFBcircuit ~ _  
     with{ 
         g(x) = x / (1.0 + x); 
         G = g(tan(CF * ma.PI / ma.SR)); 
         OPFFBcircuit(y) = x * G + (y * (1 - G)); 
         }; 
  
 process = _ : OPF(20000) <: si.bus(2);
```
same OPF with Formulae expressed in Seconds

```
// import Standard Faust library 
// https://github.com/grame-cncm/faustlibraries/ 
import("stdfaust.lib"); 
  
 // (G)  = give amplitude 1-0 (open-close) for the lowpass cut 
 // (T) = Frequency in Seconds
 OPF(T, x) = OPFFBcircuit ~ _  
     with{ 
         g(x) = x / (1.0 + x); 
         G = g(tan((1 / T) * ma.PI / ma.SR)); 
         OPFFBcircuit(y) = x * G + (y * (1 - G)); 
         }; 
  
 process = _ : OPF(10) <: si.bus(2);
```

### ONEPOLE Topology Preserving Transforms (TPT)

TPT version of the One-Pole Filter by Vadim Zavalishin
reference: 
https://www.native-instruments.de/fileadmin/redaktion_upload/pdf/KeepTopology.pdf

the topology-preserving transform approach, can be considered as
a generalization of bilinear transform, zero-delay feedback and trapezoidal integration methods. This results in digital filters having nice amplitude and phase
responses, nice time-varying behavior and plenty of options for nonlinearities

```
// import Standard Faust library 
 // https://github.com/grame-cncm/faustlibraries/ 
 import("stdfaust.lib"); 
  
 OnepoleTPT(CF,x) = circuit ~ _ : ! , _ 
     with { 
         g = tan(CF * ma.PI / ma.SR); 
         G = g / (1.0 + g); 
         circuit(sig) = u , lp 
             with { 
                 v = (x - sig) * G; 
                 u = v + lp; 
                 lp = v + sig; 
             }; 
     }; 
  
 // out 
 process = OnepoleTPT(100);
```


### FEEDFORWARD COMB FILTER (Nth Order FIR)

```_``` represents the input signal, (```_``` denotes the signal)
    it is then split into two parallel paths ```<:``` 
    one delayed by ```@(delaysamples)``` samples
    (thus value to be passed externally)
    and one without delay, ```_``` (```,``` denotes transition to the second path)
    they are then summed into a single signal ```:> _ ;```

the delayed signal has a feedforward amplitude control ```* feedforward```

there is a general amplitude control ```* outgain```
on the output function onezeroout

```
// import Standard Faust library 
// https://github.com/grame-cncm/faustlibraries/ 
import("stdfaust.lib"); 
  
 // (t,g) = delay time in samples, filter gain 0-1 
 ffcf(t, g, x) = (x@(t) * g), x :> +; 
 process = _ * .1 : ffcf(100, 1); 
```

### FEEDBACK COMB FILTER (Nth Order IIR)

```+ ~``` is the summation, and the feedback 
	of the arguments inside parentheses ```()
    _``` represents the input signal, (```_``` denotes the signal)
    delayed by ```@(delaysamples)``` samples 
    (thus value to be passed externally)
    which enters : into the gain control of the feedback, ```* feedback```

In the feedback, one sample of delay is already present by default,
hence ```delaysamples-1```.

there is a general amplitude control ```* outgain```
on the output function combfeedbout

```
// import Standard Faust library 
 // https://github.com/grame-cncm/faustlibraries/ 
 import("stdfaust.lib"); 
  
 // Feedback Comb Filter. FBComb(Del,G,signal)  
 // (Del, G) = DEL=delay time in samples. G=feedback gain 0-1 
 fbcf(del, g, x) = loop ~ _  
     with { 
         loop(y) = x + y@(del - 1) * g; 
     }; 
  
 process = _ * .1 : fbcf(4480, .9); 
```

### Lowpass FEEDBACK COMB FILTER (Nth Order IIR)

similar to the comb filter, but within the feedback,
    following the feedback enters the signal : into the onepole.
    The onepole is a lowpass where the cutoff 
    frequency can be controlled between 0. and 1. 
    In the feedback, one sample of delay is already present by default,
    hence ```delaysamples-1```.

```
// import Standard Faust library 
// https://github.com/grame-cncm/faustlibraries/ 
import("stdfaust.lib"); 
  
 // LPFBC(Del, FCut) = give: delay samps, -feedback gain 0-1-, lowpass Freq.Cut HZ 
 lpfbcf(del, cf, x) = loop ~ _ : !, _ 
     with { 
         onepole(CF, x) = loop ~ _  
             with{ 
                 g(x) = x / (1.0 + x); 
                 G = tan(CF * ma.PI / ma.SR):g; 
                 loop(y) = x * G + (y * (1 - G)); 
             }; 
         loop(y) = x + y@(del - 1) <: onepole(cf), _; 
     }; 
 process = _ * .1 : lpfbcf(2000, 10000);
```

### ALLPASS FILTER

from the sum of a comb IIR and a comb FIR in opposition of phase, emerge a recursive delay unit that preserve the phase of the input signal.  (```+``` transitions : to a cable ```_``` and a split ```<:```
        then ```@delay``` and gain, in ```feedback ~``` to the initial sum.
        filtergain controls the amplitude of the two gain states, 
        which in the filter are the same value but positive and negative,
        one side ```* -filtergain``` and one side ```* +filtergain```.
        In the feedback, one sample of delay is already present by default,
        hence ```delaysamples-1```.
        To maintain the delay threshold of the value delaysamples,
        a mem delay (of the subtracted sample) is added
        at the end.
        
```
// import Standard Faust library 
// https://github.com/grame-cncm/faustlibraries/ 
import("stdfaust.lib"); 
  
 // (t, g) = give: delay in samples, feedback gain 0-1 
 apf(del, g, x) = x : (+ : _ <: @(del-1), *(g)) ~ *(-g) : mem, _ : + : _; 
 process = _ * .1 <: apf(100, .5); 
```

### MODULATED ALLPASS FILTER

Allpass Filter with Time-Variant delay

```
// import Standard Faust library 
// https://github.com/grame-cncm/faustlibraries/ 
import("stdfaust.lib"); 
  
 // Modulated Allpass filter 
 ModAPF(delsamples, samplesmod, freqmod, apcoeff) = ( + : _ <:  
     delayMod(delsamples, samplesmod, freqmod), 
     * (apcoeff))~ * (-apcoeff) : mem, _ : + : _ 
     with{ 
         delayMod(samples, samplesMod, freqMod, x) = delay 
         with{ 
             unipolarMod(f, samples) = ((os.osc(f) + 1) / 2) * samples; 
             delay = x : de.fdelay(samples, samples - unipolarMod(freqMod, samplesMod)); 
         }; 
     }; 
 process = 1-1' : +@(ma.SR/100) ~ _ <: _, ModAPF(1000, 500, .12, .5); 
```

### STATE VARIABLE FILTER (SVF)

State variable filters are second-order RC active filters consisting of two identical op-amp integrators with each one acting as a first-order, single-pole low pass filter, a summing amplifier around which we can set the filters gain and its damping feedback network. The output signals from all three op-amp stages are fed back to the input allowing us to define the state of the circuit.

The state variable filter is a type of multiple-feedback filter circuit that can produce all three filter responses, Low Pass, High Pass and Band Pass simultaneously from the same single active filter design, and derivation like Notch, Peak, Allpass...

### Robert Bristow Johnson's SVF Bandpass

This filter transfer functions were derived from analog prototypes (that
are shown below for each EQ filter type) and had been digitized using the
Bilinear Transform by Robert Bristow-Johnson: https://webaudio.github.io/Audio-EQ-Cookbook/audio-eq-cookbook.html

```
// import Standard Faust library 
// https://github.com/grame-cncm/faustlibraries/ 
import("stdfaust.lib"); 

// Robert Bristow-Johnson's Biquad Filter - Direct Form 1
BPBiquad(g, q, f) = biquadFilter : _ * g
    with{
        biquadFilter = _ <: _, (mem  <: (_, mem)) : (_ * a0, _ * a1, _ * a2) :> _ : 
                            ((_, _) :> _) ~ (_ <: (_, mem) : (_ * -b1, _ * -b2) :> _);
        F = max(ma.EPSILON, min(20000,  f));
        Q = max(ma.EPSILON, min(ma.MAX, q));
        K = tan(ma.PI * F / ma.SR);
        norm = 1 / (1 + K / Q + K * K);
        a0 = K / Q * norm;
        a1 = 0;
        a2 = -a0;
        b1 = 2 * (K * K - 1) * norm;
        b2 = (1 - K / Q + K * K) * norm;
    };

process = _ : BPBiquad(4, 10000, 4000);
```

### Vadim Zavalishin's SVF TPT

```
s// import Standard Faust library 
// https://github.com/grame-cncm/faustlibraries/ 
import("stdfaust.lib"); 

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
process = BPSVFTPT(1, 1000);

NotchSVFTPT(Q, cf, x) = x - BPSVF(Q, cf, x);
APSVFTPT(Q, cf, x) = SVFTPT(Q, cf, x) : (! , ! , ! , _ , !);
PeakingSVFTPT(Q, cf, x) = LPSVF(Q, cf, x) - HPSVF(Q, cf, x);
BP2SVFTPT(Q, cf, x) = SVFTPT(Q, cf, x) : (! , ! , ! , ! , _);
```
