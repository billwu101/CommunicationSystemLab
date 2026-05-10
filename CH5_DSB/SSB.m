%% AM modulation variants + FFT (two-sided, properly scaled)
clear; close all; clc;

% ---------------- Parameters ----------------
Ac   = 1;           % Carrier amplitude
mu   = 0.6;         % Modulation index for DSB-TC (0 <= mu <= 1 to avoid overmodulation)
fm   = 1e3;         % Message frequency [Hz]
fc   = 20e3;        % Carrier frequency [Hz]

% Choose duration T so fm and fc complete integer cycles (coherent sampling)
T    = 10e-3;       % 10 ms -> fm has 10 cycles, fc has 200 cycles
fs   = 200e3;       % Sample rate [Hz]
N    = round(T*fs); % # of samples (integer)
t    = (0:N-1)/fs - T/2;  % Centered time axis so t=0 is in the middle

% Optional: larger FFT for prettier lines (doesn't change amplitudes)
Nfft = 2^nextpow2(8*N);

% ---------------- Baseband message ----------------
% Single-tone message normalized to [-1,1]
m = cos(2*pi*fm*t);

% ---------------- AM signals ----------------
% 1) DSB with Transmitted Carrier (conventional AM): s = Ac*(1 + mu*m)*cos(2πf_c t)
s_tc  = Ac*(1 + mu*m).*cos(2*pi*fc*t);

% 2) DSB Suppressed Carrier: s = Ac*mu*m*cos(2πf_c t)  (carrier removed)
s_sc  = Ac*mu*m.*cos(2*pi*fc*t);

% 3) SSB (generate with Hilbert transform)
mh    = imag(hilbert(m));                           % Quadrature of message
s_usb = Ac*( m.*cos(2*pi*fc*t) - mh.*sin(2*pi*fc*t)); % Upper sideband only
s_lsb = Ac*( m.*cos(2*pi*fc*t) + mh.*sin(2*pi*fc*t)); % Lower sideband only

% ---------------- FFT helper ----------------
[f, Mmag]    = spectrum2sided(m,     fs, Nfft); %#ok<ASGLU>  % (not plotted; for reference)
[f, STCmag]  = spectrum2sided(s_tc,  fs, Nfft);
[~, SSCmag]  = spectrum2sided(s_sc,  fs, Nfft);
[~, SUSBmag] = spectrum2sided(s_usb, fs, Nfft);
[~, SLSBmag] = spectrum2sided(s_lsb, fs, Nfft);

% ---------------- Plots: time domain ----------------
figure('Name','AM Time-Domain');
subplot(3,1,1);
plot(t*1e3, s_tc, 'LineWidth', 1.1); grid on;
xlabel('Time [ms]'); ylabel('Amplitude'); title('DSB-TC (Conventional AM)');
xlim(1e3*[-2/fm, 2/fm]); % show a few message periods around t=0

subplot(3,1,2);
plot(t*1e3, s_sc, 'LineWidth', 1.1); grid on;
xlabel('Time [ms]'); ylabel('Amplitude'); title('DSB-SC');
xlim(1e3*[-2/fm, 2/fm]);

subplot(3,1,3);
plot(t*1e3, s_usb, 'LineWidth', 1.1); grid on;
hold on; plot(t*1e3, s_lsb, '--', 'LineWidth', 1.1);
xlabel('Time [ms]'); ylabel('Amplitude'); title('SSB (USB solid, LSB dashed)');
xlim(1e3*[-2/fm, 2/fm]);

% ---------------- Plots: spectra (two-sided FFT) ----------------
figure('Name','AM Spectra (Two-Sided FFT)');

% subplot(2,2,1);
% plot(f/1e3, STCmag, 'LineWidth', 1.1); grid on;
% xlabel('Frequency [kHz]'); ylabel('|S(f)| (two-sided)');
% title('DSB-TC: Carrier at f_c, sidebands at f_c \pm f_m');
% xlim([(fc-3*fm)/1e3, (fc+3*fm)/1e3]); % zoom around carrier

subplot(3,1,1);
plot(f/1e3, SSCmag, 'LineWidth', 1.1); grid on;
xlabel('Frequency [kHz]'); ylabel('|S(f)| (two-sided)');
title('DSB-SC: Sidebands only (no carrier)');
%xlim([(fc-3*fm)/1e3, (fc+3*fm)/1e3]);
xlim([-(fc+3*fm)/1e3 (fc+3*fm)/1e3]);

subplot(3,1,2);
plot(f/1e3, SUSBmag, 'LineWidth', 1.1); grid on;
xlabel('Frequency [kHz]'); ylabel('|S(f)| (two-sided)');
title('SSB-USB: Only upper sideband at f_c+f_m');
%xlim([(fc-1*fm)/1e3, (fc+4*fm)/1e3]);
xlim([-(fc+3*fm)/1e3 (fc+3*fm)/1e3]);

subplot(3,1,3);
plot(f/1e3, SLSBmag, 'LineWidth', 1.1); grid on;
xlabel('Frequency [kHz]'); ylabel('|S(f)| (two-sided)');
title('SSB-LSB: Only lower sideband at f_c-f_m');
%xlim([(fc-4*fm)/1e3, (fc+1*fm)/1e3]);
xlim([-(fc+3*fm)/1e3 (fc+3*fm)/1e3]);

sgtitle('AM Variants and Their Two-Sided FFTs');

% ---------------- Helper (local function) ----------------
function [f, Xmag] = spectrum2sided(x, fs, Nfft)
    % Two-sided, fftshifted spectrum with correct amplitude scaling.
    % A cosine of amplitude A at f0 shows peaks of A/2 at +/- f0.
    if nargin < 3, Nfft = numel(x); end
    X    = fftshift(fft(x, Nfft));
    Xmag = abs(X)/Nfft;                % two-sided amplitude
    f    = (-Nfft/2:Nfft/2-1)*(fs/Nfft);
end
