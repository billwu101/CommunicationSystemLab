% Time domain plot (DC signal)
t = -5:0.01:5;          % time axis
x_t = 5 * ones(size(t));    % DC signal

figure;
subplot(1,2,1);
plot(t, x_t, 'LineWidth', 2);
xlabel('t'); ylabel('x(t)');
title('Time Domain: DC signal');
grid on;

% Frequency domain plot (delta function at f=0)
f = -5:0.01:5;          
X_f = zeros(size(f));
[~, idx] = min(abs(f)); % index closest to f=0
X_f(idx) = 1;           % represent delta as spike

subplot(1,2,2);
stem(f, X_f, 'y', 'LineWidth', 2);
xlabel('f'); ylabel('X(f)');
title('Frequency Domain: δ(f)');
grid on;
xlim([-5 5]);
