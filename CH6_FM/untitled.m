clear; close all; clc

% -------- Parameters --------
Fs   = 1e6;             % sample rate (Hz)  (>= 10x (fc + Δf) is safe)
T    = 0.02;              % signal length (s)
t    = (0:1/Fs:T-1/Fs).'; % time vector

fc   = 20e3;              % carrier (Hz)
fm   = 2e3;               % message tone (Hz)
Am   = 1;                 % message amplitude (unitless)
kf   = 5e3;               % frequency sensitivity (Hz per unit message)
% Δf (peak deviation) = kf*Am ; modulation index β = Δf/fm
Delta_f = kf*Am;
beta    = Delta_f/fm;

% -------- Message & FM modulation --------
m  = Am * sin(2*pi*fm*t);                       % message m(t)
phi = 2*pi*fc*t + 2*pi*(kf/Fs)*cumsum(m);     % phase = 2π fc t + 2π kf ∫ m(τ)dτ
s   = cos(phi);                                % FM passband signal

% -------- Check instantaneous frequency f_inst(t) --------
% theory: f_inst(t) = fc + kf*m(t)
inst_phase = unwrap(angle(hilbert(s)));       % analytic signal phase
f_inst     = [diff(inst_phase)/(2*pi)*Fs; NaN];

figure; plot(t, f_inst, 'LineWidth', 1); hold on
plot(t, fc + kf*m, '--', 'LineWidth', 1);
xlabel('Time (s)'); ylabel('Instantaneous frequency (Hz)');
legend('Estimated f_{inst}(t)', 'fc + k_f m(t)'); grid on
title(sprintf('FM check: fc=%g Hz, \\Deltaf=%g Hz, \\beta=%.2f', fc, Delta_f, beta));

% -------- FFT (single-sided amplitude spectrum) --------
x = s .* hann(length(s));                     % window to reduce leakage
Awin = sum(hann(length(s)))/length(s);        % amplitude correction for window
Nfft = 2^nextpow2(length(x));
X = fft(x, Nfft)/length(x)/Awin;
f = (0:Nfft-1)*(Fs/Nfft);

% keep one-sided
half = 1:floor(Nfft/2);
figure; plot(f(half), 2*abs(X(half)), 'LineWidth', 1); grid on
xlim([0, Fs/2]);
xlabel('Frequency (Hz)'); ylabel('Amplitude');
title('Single-sided amplitude spectrum of FM signal');

% -------- (Nice to see) Spectrogram --------
% figure;
% spectrogram(s, 1024, 768, 4096, Fs, 'yaxis'); title('Spectrogram of FM'); colormap default

% -------- Optional: baseband demod (no toolbox) --------
% Differentiate phase and remove DC: recovers ~m(t) up to scale kf
y_phase = unwrap(angle(hilbert(s)));
m_hat = [diff(y_phase); 0] * (Fs/(2*pi*kf)) - fc/kf;  % scale to ~m(t)
figure; plot(t, m, 'c',t, m_hat, 'y--'); grid on
xlabel('Time (s)'); ylabel('Amplitude');
legend('Original m(t)','Demodulated \approx m(t)'); title('FM demod via phase derivative');