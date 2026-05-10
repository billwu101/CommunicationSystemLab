% Signed FFT of a rectangular pulse that matches AT*sinc(fT)
clear; close all; clc;

A  = 1;
T  = 1e-3;          % pulse width [s]
fs = 1e5;           % sampling rate [Hz]
N  = 2^14;          % FFT length (power of 2)
dt = 1/fs;

% Time grid centered at 0 (for constructing x only)
t = (-N/2:N/2-1)/fs;

% Rect pulse (exactly centered and T is integer multiple of dt)
x = A * (abs(t) <= T/2);

% *** Key line: move time-zero sample to index 1 before FFT ***

Xf = fftshift( fft( ifftshift(x), N ) ) * dt;
%Xf = fftshift( fft( ifftshift(x)) );


% Frequency axis (Hz)
f = (-N/2:N/2-1) * (fs/N);

% Theory: MATLAB sinc(u) = sin(pi*u)/(pi*u)
X_theory = A*T * sinc(f*T);

% Plot signed spectrum (real, should overlay theory)
figure;
plot(f/1e3, real(Xf), 'LineWidth', 1.6); hold on;
plot(f/1e3, X_theory, '--', 'LineWidth', 1.2);
grid on; xlim([-10/T 10/T]/1e3);
xlabel('Frequency (kHz)'); ylabel('X(f)');
title('Signed spectrum = A T sinc(fT)');
legend('FFT (real part)', 'A T sinc(fT)', 'Location','best');
