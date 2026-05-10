close all; clear; clc;

% Parameters
fs  = 10e3;          % sampling rate [Hz]
T   = 1;             % duration [s]
f0  = 1234;          % cosine frequency [Hz]
A   = 1.0;           % amplitude
phi = 0;             % phase [rad]

% Time-domain signal
t = (0:1/fs:T-1/fs).';          % column vector time base
x = A*cos(2*pi*f0*t + phi);

% (Optional) window to reduce spectral leakage
w = hann(numel(x));             % try rectwin, hamming, blackman, etc.
xw = x .* w;

% FFT (zero-pad to next power of two for nicer grid)
N  = numel(xw);
Nf = 2^nextpow2(N);
X  = fft(xw, Nf);

% Build single-sided spectrum
f = (0:Nf/2)' * (fs/Nf);        % freq axis [Hz]
X1 = X(1:Nf/2+1);

% Correct amplitude for window and single-sided scaling
W0 = sum(w)/N;                  % coherent gain of window
S  = (2/N) * abs(X1) / W0;      % single-sided amplitude spectrum

% Plot amplitude spectrum
figure('Name', 'Cosine FFT (Amplitude)');
stem(f, S, 'Marker', 'none'); grid on;
xlim([0 fs/2]);
xlabel('Frequency (Hz)'); ylabel('Amplitude');
title(sprintf('Single-Sided Amplitude Spectrum | f_0 = %g Hz, fs = %g Hz', f0, fs));

%% Optional: dB magnitude spectrum
SdB = 20*log10(max(S, eps));
figure('Name', 'Cosine FFT (dB)');
plot(f, SdB); grid on;
xlim([0 fs/2]);
ylabel('Magnitude (dB)'); xlabel('Frequency (Hz)');
title('Single-Sided Magnitude Spectrum (dB)');

% (Optional) show phase near the tone
[~, k0] = min(abs(f - f0));
Xph = angle(X1(k0));
fprintf('Peak near %.1f Hz at bin %d: |X| ≈ %.5f, phase ≈ %.3f rad\n', f(k0), k0, S(k0), Xph);
