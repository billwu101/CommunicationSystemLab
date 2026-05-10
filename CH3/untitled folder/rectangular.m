% Rectangular pulse FFT in MATLAB
clear; close all; clc;

% Parameters
A  = 1;       % amplitude
T  = 1e-3;    % pulse width [s]
fs = 1e5;     % sampling frequency [Hz]
N  = 2^14;    % FFT length (power of 2 recommended)

% Time vector
t = (-N/2:N/2-1)/fs;  

% Rectangular pulse
x = A * (abs(t) <= T/2);   % rect(t/T)

% FFT
Xf = fftshift(fft(ifftshift(x), N));
f  = (-N/2:N/2-1)*(fs/N);  % frequency axis
mag = real(Xf)/fs;          % normalize magnitude

% Plot time domain
figure;
subplot(2,1,1);
plot(t*1e3, x,'LineWidth',1.5);
xlabel('Time (ms)'); ylabel('Amplitude');
title('Rectangular Pulse x(t)');
grid on; xlim([-3*T 3*T]*1e3);

% Plot frequency domain
subplot(2,1,2);
plot(f/1e3, mag,'LineWidth',1.5);
xlabel('Frequency (kHz)'); ylabel('|X(f)|');
title('Magnitude Spectrum of Rectangular Pulse');
grid on; xlim([-10/T 10/T]/1e3);
