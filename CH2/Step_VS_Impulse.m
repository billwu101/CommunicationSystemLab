clc; clear;

% Define transfer function G(s) = 1/(s+1)
num = 1;
den = [1 1];
sys = tf(num, den);

% Time vector
t = 0:1e-3:10;

% Step and impulse responses
[y_step, t_step] = step(sys, t);
[y_imp,  t_imp]  = impulse(sys, t);

% Plot together
figure;
plot(t_step, y_step, 'y', 'LineWidth', 2); hold on;
plot(t_imp,  y_imp,  'g', 'LineWidth', 2);
grid on;
xlabel('Time (s)');
ylabel('Response');
title('Step vs Impulse Response of G(s) = 1/(s+1)');
legend('Step Response (1 - e^{-t})', 'Impulse Response (e^{-t})');

