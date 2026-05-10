

s = tf('s');         % define Laplace variable
a = 2;               % pole location
F = a / (s + a);     % transfer function


bode(F);
title('Bode Plot of 1st-Order LPF');
grid on;
