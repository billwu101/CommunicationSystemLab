% DC signal and its FFT (discrete-time demo)
clear; close all; clc

% Parameters
fs = 1000;              % sampling rate [Hz]
N  = 1024;              % number of samples (power of 2 is convenient)
A  = 1;                 % DC amplitude

% Time signal: constant (DC)
t  = (0:N-1)/fs;
x  = A*ones(1,N);

% FFT
X   = fft(x);                   % raw FFT
Xn  = X / N;                    % normalized so DC magnitude = A
f   = (-N/2:N/2-1)*(fs/N);      % frequency axis (Hz)
mag = abs(fftshift(Xn));        % magnitude spectrum (normalized)

% Plot
figure('Name','DC signal and FFT');
subplot(1,2,1);
plot(t, x, 'LineWidth', 2);
xlabel('t (s)'); ylabel('x(t)'); title('Time domain: DC signal');
grid on; xlim([t(1) t(end)]); ylim([A-0.2 A+0.2]);

subplot(1,2,2);
stem(f, mag, 'filled'); hold on; grid on
xlabel('f (Hz)'); ylabel('|X(f)| (normalized)');
title('Frequency domain: \delta at f = 0');
xlim([-fs/2 fs/2]);

%% Emphasize the DC bin
[~,k0] = min(abs(f-0));
stem(f(k0), mag(k0), 'r', 'LineWidth', 2);
legend('FFT magnitude','DC bin','Location','best');
