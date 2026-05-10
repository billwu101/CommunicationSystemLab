%%

close all; clear; clc;

% Parameters
fs = 1e3;             % sampling frequency [Hz]
T  = 1;                % duration [s]
f0 = 50e0;               % cosine frequency [Hz]

t = 0 : 1/fs : T - (1/fs);     % time axis
x = cos(2*pi*f0*t);    % cosine wave

% FFT
Y = fft(x);
N = length(Y);

% Frequency axis for two-sided spectrum
f = (-N/2:N/2-1)*(fs/N);

% Two-sided magnitude (normalized)
magY = abs(fftshift(Y))/N;

% Plot
figure;
stem(f, magY, 'LineWidth',1.5);
grid on;
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('Two-Sided Magnitude Spectrum of cos()');



