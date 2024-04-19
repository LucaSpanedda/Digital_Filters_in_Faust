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