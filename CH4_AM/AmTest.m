%% AM (with DC) and AM (suppressed carrier) + FFT demo
clear; clc; close all;

% ---------- Parameters ----------
fs  = 200e3;            % Sample rate [Hz]
N   = 2^16;             % Samples (power of two for FFT speed)
t   = (0:N-1)/fs;       % Time vector
Ac  = 1;                % Carrier amplitude
fc  = 20e3;             % Carrier frequency [Hz]
fm  = 1e3;              % Message (tone) frequency [Hz]
mu  = 0.6;              % Modulation index (keep |mu|<=1 to avoid overmod)

% ---------- Signals ----------
m   = cos(2*pi*fm*t);                               % Message (unit amplitude)
c   = cos(2*pi*fc*t);                               % Carrier

s_tc  = Ac*(1 + mu*m).*c;                           % DSB-TC (AM with carrier/DC)
s_sc  = Ac*(mu*m).*c;                               % DSB-SC (suppressed carrier)
s_dc  = Ac*(1 + mu*1.0).*c;                         % AM of a DC message (= scaled carrier)

% ---------- Helper: FFT magnitude (properly amplitude-calibrated) ----------
% Returns f (centered) and |X| normalized to tone amplitude units.
magfft = @(x,fs) deal( ...
    linspace(-fs/2, fs/2, numel(x)), ...            % freq axis (fftshifted)
    abs(fftshift(fft(x)))./numel(x) * 2 );          % simple 2/N norm (for peaks)

% ---------- View 1: RF-centered spectra (around fc) ----------
[f_tc,  X_tc ] = magfft(s_tc, fs);
[f_sc,  X_sc ] = magfft(s_sc, fs);
[f_car, X_car] = magfft(s_dc, fs);

% ---------- View 2: Mix down to baseband for readability ----------
lo = exp(-1j*2*pi*fc*t);                            % complex mixer to shift fc -> 0
bb_tc = s_tc .* lo;                                 % basebanded AM with carrier
bb_sc = s_sc .* lo;                                 % basebanded AM SC
bb_car= s_dc .* lo;                                 % basebanded pure carrier

[f_bb_tc,  X_bb_tc ] = magfft(bb_tc, fs);
[f_bb_sc,  X_bb_sc ] = magfft(bb_sc, fs);
[f_bb_car, X_bb_car] = magfft(bb_car, fs);

% ---------- Plots ----------
Tview = 5e-3; idx = t<=Tview;                       % show first 5 ms in time plots

figure('Name','AM Time Domain','Color','w');
subplot(3,1,1); plot(t(idx)*1e3, s_tc(idx)); grid on;
title(sprintf('DSB-TC (AM with carrier)  \\mu=%.2f,  fc=%g Hz,  fm=%g Hz', mu, fc, fm));
xlabel('Time [ms]'); ylabel('Amplitude');

subplot(3,1,2); plot(t(idx)*1e3, s_sc(idx)); grid on;
title('DSB-SC (suppressed carrier)'); xlabel('Time [ms]'); ylabel('Amplitude');

subplot(3,1,3); plot(t(idx)*1e3, s_dc(idx)); grid on;
title('AM of a DC message (just a scaled carrier)'); xlabel('Time [ms]'); ylabel('Amplitude');

% RF-centered spectra (shows lines near ±fc)
figure('Name','AM Spectra (RF-centered)','Color','w');
subplot(3,1,1); plot(f_tc/1e3, X_tc); xlim([fc-5*fm, fc+5*fm]/1e3); grid on;
title('DSB-TC spectrum (around f_c)'); xlabel('Frequency [kHz]'); ylabel('|X(f)|');

subplot(3,1,2); plot(f_sc/1e3, X_sc); xlim([fc-5*fm, fc+5*fm]/1e3); grid on;
title('DSB-SC spectrum (around f_c)'); xlabel('Frequency [kHz]'); ylabel('|X(f)|');

subplot(3,1,3); plot(f_car/1e3, X_car); xlim([fc-2*fm, fc+2*fm]/1e3); grid on;
title('DC message (carrier only)'); xlabel('Frequency [kHz]'); ylabel('|X(f)|');

% Baseband spectra (carrier -> 0 Hz; sidebands at ±fm)
zoom_win = 6*fm;
figure('Name','AM Spectra (Basebanded)','Color','w');
subplot(3,1,1); plot(f_bb_tc/1e3, X_bb_tc); xlim([-zoom_win, zoom_win]/1e3); grid on;
title('DSB-TC baseband view (carrier at 0, sidebands at ±f_m)'); xlabel('Frequency [kHz]'); ylabel('|X(f)|');

subplot(3,1,2); plot(f_bb_sc/1e3, X_bb_sc); xlim([-zoom_win, zoom_win]/1e3); grid on;
title('DSB-SC baseband view (no carrier at 0)'); xlabel('Frequency [kHz]'); ylabel('|X(f)|');

subplot(3,1,3); plot(f_bb_car/1e3, X_bb_car); xlim([-zoom_win, zoom_win]/1e3); grid on;
title('DC message baseband view (single line at 0 Hz)'); xlabel('Frequency [kHz]'); ylabel('|X(f)|');

% ---------- Tips ----------
% (1) Sideband/carrier ratio for a single-tone AM:
%     In DSB-TC, each sideband ≈ (mu/2) of the carrier (voltage).
% (2) To reduce spectral leakage, you can window:
%     w = hann(N).';  [f, X] = magfft(x.*w, fs);    % (adjust amplitude if needed)
% (3) To label dynamically, use sprintf or [] concatenation, not numeric addition:
%     title(sprintf('Time domain (f_s = %.0f Hz)', fs));
