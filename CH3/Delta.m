%% Centered impulse-train ↔ impulse-train (t=0 in the middle)
clear; close all; clc;

fs = 1e3;           % sampling rate [Hz]

T0 = 0.01;          % period [s]
f0 = 1/T0;

N  = 20000;         % multiple of (T0*fs)
dt = 1/fs;
L  = round(T0*fs);  % samples per period (here 10)

% --- centered time axis: n = -N/2 ... N/2-1 ---
n = -N/2 : (N/2) - 1;
t = n * dt;

% impulse train with unit area per impulse (height = 1/dt = fs)
%x = double(mod(n, L) == 0) * fs;     % 1 at multiples of L, else 0
x = double(mod(n, L) == 0);     % 1 at multiples of L, else 0

% --- FFT with proper shifts for centered time signal ---
X = fftshift( fft( ifftshift(x) ) ) * dt;
f = (-N / 2:(N / 2) - 1) * (fs / N);

% theoretical line spectrum (for overlay)
% k = (-N / 2:(N / 2)-1);
% periodBins = N / L;
% mask = (mod(k, periodBins) == 0);
% X_theory = zeros(size(f)); X_theory(mask) = f0;

% --- plots ---
figure('Name','Centered impulse train and its FT');

subplot(1,2,1);
stem(t*1e3, x, '.'); grid on
xlim( [-5*T0, 5*T0] * 1e3 )
ylim([-2,2]);
xlabel('t (ms)'); ylabel('x(t)');
title('Time domain');

subplot(1,2,2);
stem(f, abs(X)); hold on
%stem(f(mask), X_theory(mask), 'r', 'filled'); grid on
xlim([-5*f0 5*f0]); ylim([0 1.2*f0]);
ylim([-1,3]);
grid on;
xlabel('f (Hz)'); ylabel('|X(f)|');
legend('|X(f)| from FFT','f_0 \cdot \sum \delta(f-nf_0)','Location','north');
title('Frequency domain (two-sided, centered)');
