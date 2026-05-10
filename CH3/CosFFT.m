% DC signal and its FFT (discrete-time demo)
clear; close all; clc ;

% Parameters
fs = 1e5;              % sampling rate [Hz]
%N  = 256;               % number of samples (power of 2 is convenient)
numCycles = 10;
% Time signal: constant (DC)

fc = 5e3;
%t = (0 : N-1) / fs;
t = 0 : 1/fs : 1e-2 - (1/fs);     % time axis(duration [s]()

% T = numCycles / fc;          % total signal duration
% t = 0 : 1/fs : T - 1/fs;     % time vector

% count = 0;
% index = 2 / fs;
% 
% while count < numCycles
%     if cos(2*pi*fc * (index - (1 / fs))) >= 0 && cos(2*pi*fc * index) < 0
%         count = count + 1;
%     end
%     index = index + (1 / fs);
% end
% 
% while (cos(2*pi*fc * index) - cos(2*pi*fc * (index - (1 / fs)))) >= 0
%     index = index + (1 / fs);
% 
% end

%t = 0 : 1/fs : index;     % time vector

% count = 0;
% for k = 2:length(t)
%     if x(k-1) <= 0 && x(k) > 0   % rising zero-crossing
%         count = count + 1;
%     end
% end
% 
% count

x = cos(2 * pi * fc * t);

% FFT
X   = fft(x);                                       % raw FFT
N = length(X);

f   = (-N / 2 : (N / 2) - 1) * (fs / N);            % frequency axis (Hz)
mag = abs(fftshift(X)) / N;                         % magnitude spectrum (normalized)

% Plot
figure('Name','DC signal and FFT');
subplot(1,2,1);
plot(t, x, 'LineWidth', 2);grid on;hold on;
xlabel('t (s)'); ylabel('x(t)'); title('Time domain: Cos ' + string(fc/1e3) + 'K');
ylim([-1.5 , 1.5]);
xlim([0 , 5 * (1 / fc)]);


subplot(1,2,2);
stem(f, mag, 'filled'); hold on; grid on;
%plot(f , mag , 'LineWidth',1.5); hold on; grid on;
xlabel('f (Hz)'); ylabel('|X(f)| (normalized)');
title('Frequency domain:');
xlim([-fs/10 fs/10]);
