% DC signal and its FFT (discrete-time demo)
clear; close all; clc

% Parameters
fs = 1000;              % sampling rate [Hz]
N  = 1024;              % number of samples (power of 2 is convenient)
A  = 1;                 % DC amplitude

% Time signal: constant (DC)
t  = (0:N-1)/fs;
x = zeros(1,N);
powtwo = 2 ^ 6;
x(1 : N / powtwo)  = A * ones(1,N / powtwo);

% FFT
X   = fft(x);                   % raw FFT
Xn  = X / N;                    % normalized so DC magnitude = A
f   = (-N/2:N/2-1)*(fs/N);      % frequency axis (Hz)
mag = abs(fftshift(Xn));        % magnitude spectrum (normalized)


% Plot
figure('Name','DC signal and FFT');
subplot(1,2,1);
plot(t, x, 'LineWidth', 1.5);
xlabel('t (s)'); ylabel('x(t)'); title('Time domain');
grid on; xlim([t(1) t(end)]); ylim([A-0.2 A+0.2]);

subplot(1,2,2);
%stem(f, mag, 'filled'); hold on; grid on;
plot(f , mag , 'LineWidth',1.5); hold on; grid on;
xlabel('f (Hz)'); ylabel('|X(f)| (normalized)');
title('Frequency domain');
xlim([-fs/2 fs/2]);
