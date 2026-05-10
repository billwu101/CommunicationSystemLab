% DC signal and its FFT (discrete-time demo)
clear; close all; clc ;

% Parameters
fs = 1e3;              % sampling rate [Hz]
%N  = 256;               % number of samples (power of 2 is convenient)
numCycles = 10;
tau  = 2e-2; 
Tobs = 1;
A = 1;
% Time signal: constant (DC)

fc = 50;
%t = (0 : N-1) / fs;
t = (-Tobs/2 : 1/fs : Tobs/2 - 1/fs);

% T = numCycles / fc;          % total signal duration
% t = 0 : 1/fs : T - 1/fs;     % time vector

x = A * double(abs(t) <= tau/2);

% FFT
X   = fft(ifftshift(x));                               % raw FFT
N = length(X);

f   = (-N / 2 : (N / 2) - 1) * (fs / N);    % frequency axis (Hz)
mag = real(fftshift(X)) / N;                 % magnitude spectrum (normalized)

% Plot
figure('Name','DC signal and FFT');
subplot(1,2,1);
plot(t, x, 'LineWidth', 2);grid on;hold on;
xlabel('t (s)'); ylabel('x(t)'); title('Time domain');
ylim([-1.5 , 1.5]);
xlim([t(1) , t(end)]);


subplot(1,2,2);
%stem(f, mag, 'filled'); hold on; grid on;
plot(f , mag , 'LineWidth',1.5); hold on; grid on;
xlabel('f (Hz)'); ylabel('|X(f)| (normalized)');
title('Frequency domain');
xlim([-fs/2 fs/2]);
