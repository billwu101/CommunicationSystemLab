% FM modulation + spectrum + demod (toolbox-free and toolbox versions)
clear; close all; clc;

% -------------------- Parameters --------------------
Fs      = 1e6;           % Sample rate [Hz]  (keep >> carrier + deviation)
Ts      = 1/Fs;
T       = 0.01;          % Signal duration [s]
t       = (0:round(T*Fs)-1).' * Ts;

fc      = 100e3;         % Carrier [Hz]
Am      = 1.0;           % Message amplitude (peak)
fm      = 1e3;           % Message tone [Hz]
fdev    = 50e3;          % Peak frequency deviation [Hz]
Ac      = 1.0;           % Carrier amplitude

SNRdB   = 40;            % Additive noise SNR (dB) for the RF waveform

% Tip: Carson's rule bandwidth ≈ 2*(fdev + fm). With these numbers: ~102 kHz.

% -------------------- Baseband message --------------------
m = Am * cos(2*pi*fm*t);            % Example: single-tone message
% You can try a multi-tone or arbitrary message, e.g.:
% m = 0.6*cos(2*pi*fm*t) + 0.3*cos(2*pi*(3*fm)*t);

% -------------------- FM modulation (manual) --------------------
% FM: s(t)=Ac*cos(2π fc t + 2π kf ∫ m(τ)dτ ), where kf = fdev/Am (Hz per unit)
kf      = fdev / max(Am, eps);      % Hz / unit-amplitude
phi     = 2*pi*fc*t + 2*pi*kf * cumsum(m)*Ts;  % instantaneous phase
s_fm    = Ac * cos(phi);

% Optionally add AWGN at the RF:
s_fm_noisy = awgn(s_fm, SNRdB, 'measured');

% -------------------- FM modulation (Communications Toolbox) ----
% If you have the toolbox:
hasComm = exist('fmmod','file')==2 && exist('fmdemod','file')==2;
if hasComm
    s_fm_tb = fmmod(m, fc, Fs, fdev, 0);  % 0 = initial phase
end




% -------------------- Plot time domain --------------------------
figure('Name','Time domain');
subplot(3,1,1);
plot(t(1:2000)*1e3, m(1:2000), 'LineWidth',1); grid on;
xlabel('Time [ms]'); ylabel('m(t)');
title('Message (first 2 ms)');

subplot(3,1,2);
plot(t(1:2000)*1e3, s_fm(1:2000), 'LineWidth',1); grid on;
xlabel('Time [ms]'); ylabel('s_{FM}(t)');
title('FM waveform (clean, first 2 ms)');

subplot(3,1,3);
plot(t(1:2000)*1e3, s_fm_noisy(1:2000), 'LineWidth',1); grid on;
xlabel('Time [ms]'); ylabel('s_{FM}(t)+noise');
title(sprintf('FM waveform with AWGN (SNR=%g dB)', SNRdB));

% -------------------- Spectrum (FFT) ----------------------------
[f1, S1] = magSpecDB(s_fm, Fs);
[f2, S2] = magSpecDB(s_fm_noisy, Fs);

figure('Name','RF spectrum');
plot(f1/1e3, S1, 'LineWidth',1); grid on; hold on;
plot(f2/1e3, S2, '--', 'LineWidth',1);
xlim([fc-4*(fdev+fm) fc+4*(fdev+fm)]/1e3);   % zoom around carrier
xlabel('Frequency [kHz]'); ylabel('Magnitude [dB]');
legend('Clean FM','FM + noise');
title('FM RF magnitude spectrum (Hann-windowed, amplitude-corrected)');

% -------------------- Demodulation (toolbox-free) ---------------
% Method: analytic signal -> instantaneous phase -> differentiate.
% 1) Build analytic signal a(t) via Hilbert transform
a = hilbert(s_fm_noisy);            % complex envelope of the RF
% 2) Instantaneous phase and frequency
phi_inst = unwrap(angle(a));
% derivative of phase gives angular frequency: dphi/dt [rad/s]
omega    = [0; diff(phi_inst)] * Fs; % rad/s
f_inst   = omega / (2*pi);           % Hz

% 3) Remove carrier and scale back to message using kf: f_inst ≈ fc + kf*m(t)
m_rec    = (f_inst - fc) / kf;

% Optional: low-pass filter to clean residual HF noise
% Design a simple FIR LPF around, say, 2*fm cutoff:
lp = designfilt('lowpassfir', 'PassbandFrequency', 2*fm, 'StopbandFrequency', 4*fm, ...
    'PassbandRipple', 0.5, 'StopbandAttenuation', 60, 'SampleRate', Fs);
m_rec_f  = filtfilt(lp, m_rec);

% -------------------- Demodulation (Communications Toolbox) -----
if hasComm
    m_rec_tb = fmdemod(s_fm_noisy, fc, Fs, fdev);
end

% -------------------- Compare message vs. recovered --------------
Nshow = 4000;
tt    = t(1:Nshow);

figure('Name','Demod comparison');
plot(tt*1e3, m(1:Nshow), 'LineWidth',1); grid on; hold on;
plot(tt*1e3, m_rec_f(1:Nshow), '--', 'LineWidth',1);
if hasComm
    plot(tt*1e3, m_rec_tb(1:Nshow), ':', 'LineWidth',1);
end
xlabel('Time [ms]'); ylabel('Amplitude');
if hasComm
    legend('Original m(t)','Recovered (Hilbert/phase)','Recovered (fmdemod)');
else
    legend('Original m(t)','Recovered (Hilbert/phase)');
end
title('FM demodulation comparison');

%% -------------------- Notes / tips --------------------
% 1) Sampling: ensure Fs >> fc + fdev. A safe quick rule is Fs >= 8~10 * (fc + fdev).
% 2) Carson's rule for occupied bandwidth: BT ≈ 2*(fdev + fm_max).
% 3) If using wide fdev or higher fc, raise Fs (or move to complex baseband).
% 4) For arbitrary message m(t), keep |m|<=Am so that peak deviation≈fdev.
% 5) The Hilbert method is simple but sensitive to noise; a limiter-discriminator
%    (atan2(diff(I*Q*), etc.) or a PLL) can outperform it at low SNR.

% -------------------- FFT helper (magnitude spectrum) -----------
function [f, Sdb] = magSpecDB(x, Fs)
    N   = numel(x);
    win = hann(N);
    xw  = x(:) .* win;
    X   = fft(xw, 2^nextpow2(N));
    NFFT= numel(X);
    X   = X(1:NFFT/2+1);
    % Coherent gain of Hann window:
    CG  = sum(win)/N;
    % Single-sided magnitude, amplitude-corrected:
    Mag = abs(X)/ (N * CG) * 2;      % *2 for single-sided (except DC/Nyq)
    f   = (0:NFFT/2)' * (Fs/NFFT);
    Sdb = 20*log10(Mag + 1e-15);
end