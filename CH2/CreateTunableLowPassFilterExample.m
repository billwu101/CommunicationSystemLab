%[text] # Tunable Low-Pass Filter
%[text] In this example, you will create a low-pass filter with one tunable parameter *a*:
%[text]{"align":"center"} $F = \\frac{a}{{s + a}}$
%[text] Since the numerator and denominator coefficients of a `tunableTF` block are independent, you cannot use `tunableTF` to represent `F`. Instead, construct `F` using the tunable real parameter object `realp`.
%[text] Create a real tunable parameter with an initial value of `10`.
a = realp('a',10) %[output:7420a403]
%%
%[text] Use `tf` to create the tunable low-pass filter `F`.
numerator = a;
denominator = [1,a];
F = tf(numerator,denominator) %[output:371b24e8]
%[text] `F` is a `genss` object which has the tunable parameter `a` in its `Blocks` property. You can connect `F` with other tunable or numeric models to create more complex control system models. For an example, see [Control System with Tunable Components](docid:control_ug.bsws4w1).
%[text] *Copyright 2012 The MathWorks, Inc.*

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline","rightPanelPercent":40}
%---
%[output:7420a403]
%   data: {"dataType":"textualVariable","outputData":{"name":"a","value":"       Name: 'a'\n      Value: 10\n    Minimum: -Inf\n    Maximum: Inf\n       Free: 1\n\nReal scalar parameter.\n"}}
%---
%[output:371b24e8]
%   data: {"dataType":"text","outputData":{"text":"Generalized continuous-time state-space model with 1 outputs, 1 inputs, 1 states, and the following blocks:\n  a: Scalar parameter, 2 occurrences.\n<a href=\"matlab:disp(char([10 32 32 32 32 32 32 32 32 32 32 32 66 108 111 99 107 115 58 32 91 49 215 49 32 115 116 114 117 99 116 93 10 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 65 58 32 91 49 215 49 32 103 101 110 109 97 116 93 10 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 66 58 32 49 10 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 67 58 32 91 49 215 49 32 103 101 110 109 97 116 93 10 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 68 58 32 48 10 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 69 58 32 91 93 10 32 32 32 32 32 32 32 32 83 116 97 116 101 78 97 109 101 58 32 123 39 39 125 10 32 32 32 32 32 32 32 32 83 116 97 116 101 85 110 105 116 58 32 123 39 39 125 10 32 32 32 32 73 110 116 101 114 110 97 108 68 101 108 97 121 58 32 91 48 215 49 32 100 111 117 98 108 101 93 10 32 32 32 32 32 32 32 73 110 112 117 116 68 101 108 97 121 58 32 48 10 32 32 32 32 32 32 79 117 116 112 117 116 68 101 108 97 121 58 32 48 10 32 32 32 32 32 32 32 32 73 110 112 117 116 78 97 109 101 58 32 123 39 39 125 10 32 32 32 32 32 32 32 32 73 110 112 117 116 85 110 105 116 58 32 123 39 39 125 10 32 32 32 32 32 32 32 73 110 112 117 116 71 114 111 117 112 58 32 91 49 215 49 32 115 116 114 117 99 116 93 10 32 32 32 32 32 32 32 79 117 116 112 117 116 78 97 109 101 58 32 123 39 39 125 10 32 32 32 32 32 32 32 79 117 116 112 117 116 85 110 105 116 58 32 123 39 39 125 10 32 32 32 32 32 32 79 117 116 112 117 116 71 114 111 117 112 58 32 91 49 215 49 32 115 116 114 117 99 116 93 10 32 32 32 32 32 32 32 32 32 32 32 32 78 111 116 101 115 58 32 91 48 215 49 32 115 116 114 105 110 103 93 10 32 32 32 32 32 32 32 32 32 85 115 101 114 68 97 116 97 58 32 91 93 10 32 32 32 32 32 32 32 32 32 32 32 32 32 78 97 109 101 58 32 39 39 10 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 84 115 58 32 48 10 32 32 32 32 32 32 32 32 32 84 105 109 101 85 110 105 116 58 32 39 115 101 99 111 110 100 115 39 10 32 32 32 32 32 83 97 109 112 108 105 110 103 71 114 105 100 58 32 91 49 215 49 32 115 116 114 117 99 116 93 10]))\">Model Properties<\/a>\n\nType \"ss(F)\" to see the current value and \"F.Blocks\" to interact with the blocks.\n","truncated":false}}
%---
