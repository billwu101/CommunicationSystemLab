%% Rectangular pulse FFT demo
clear; close all; clc;

% ----- Signal settings -----
A    = 1;          % pulse amplitude
tau  = 10e-3;      % pulse width (s)
fs   = 100e3;      % sampling rate (Hz)
Tobs = 0.1;        % total observation time (s)  (longer -> finer df)

t = (-Tobs/2 : 1/fs : Tobs/2-1/fs).';   % time vector centered at 0
N = numel(t);

% Make a rectangular pulse centered at t=0
% If you have Signal Processing Toolbox, you can use: x = A*rectpuls(t, tau);
x = A * double(abs(t) <= tau/2);

% ----- FFT -----
% Zero-padding (optional) to densify the frequency grid (doesn't add info)
Nzp = 8*N;                       % try 1*N (no padding), 4*N, 8*N, etc.
Xf  = fftshift(fft(x, Nzp))/N;   % normalize by N (unitary-ish)
f   = (-Nzp/2:Nzp/2-1).' * (fs/Nzp);   % frequency axis (Hz)

% ----- Analytical continuous-time spectrum (for comparison) -----
% For a continuous-time rect of width tau and amplitude A:
% X_ct(f) = A * tau * sinc(f*tau), where MATLAB sinc(z) = sin(pi*z)/(pi*z)
Xct = A * tau * sinc(f * tau);

% ----- Plots -----
figure('Name','Rectangular pulse and FFT');

subplot(3,1,1);
plot(t*1e3, x, 'LineWidth', 1.2);
grid on; xlabel('Time (ms)'); ylabel('x(t)');
title(sprintf('Rectangular pulse: A=%.2f, \\tau=%.2f ms, fs=%.0f Hz', A, tau*1e3, fs));

subplot(3,1,2);
plot(f/1e3, abs(Xf), 'LineWidth', 1.2); hold on;
plot(f/1e3, abs(Xct), '--', 'LineWidth', 1.1); hold off;
grid on; xlabel('Frequency (kHz)'); ylabel('|X(f)| (scaled)');
legend('FFT (discrete, N-normalized)','Analytical A\tau·sinc(f\tau)','Location','best');
title('Magnitude spectrum (linear)');

subplot(3,1,3);
% dB plot (avoid log of zero)
epsv = 1e-12;
plot(f/1e3, 20*log10(abs(Xf)+epsv), 'LineWidth', 1.2); hold on;
plot(f/1e3, 20*log10(abs(Xct)+epsv), '--', 'LineWidth', 1.1); hold off;
grid on; xlabel('Frequency (kHz)'); ylabel('Magnitude (dB)');
title('Magnitude spectrum (dB)');

% ----- Reference markers: mainlobe width -----
% For a rect of width tau, the first zeros occur at f = ±1/tau (Hz)
fzero = 1/tau;
disp(['First spectral zeros at ± ', num2str(fzero/1e3), ' kHz (expected).']);
