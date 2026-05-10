%% Bandpass signal demo: s(t) = m(t) * cos(2π f_c t)
clear; clc;

%---------- Parameters ----------
Fs  = 100e3;        % sample rate [Hz]
Ts  = 1/Fs;
T   = 0.02;         % total time [s]
t   = (-T/2:Ts:T/2-Ts).';  % time axis centered at 0
N   = numel(t);
f   = (-N/2:N/2-1).' * (Fs/N);   % frequency axis (fftshifted)

W   = 1e3;          % (one-sided) baseband bandwidth ~ 1 kHz
fc  = 10e3;         % carrier frequency [Hz]

%---------- Baseband m(t) ----------
% A triangular spectrum corresponds (up to scaling) to sinc^2 in time.
% This makes m(t) smooth and band-limited like your drawing.
m = sinc(W*t).^2;             % sinc(x) in MATLAB = sin(pi*x)/(pi*x)

% Optional: scale to unit peak
m = m / max(abs(m));

%---------- Carrier and modulation ----------
c = cos(2*pi*fc*t);           % carrier
s = m .* c;                   % modulated (bandpass) signal

%---------- Spectra ----------
M = fftshift(fft(m))/N;       % baseband spectrum (complex)
S = fftshift(fft(s))/N;       % modulated spectrum
Mag = @(X) abs(X);            % magnitude helper

%---------- Plots ----------
figure('Color','w','Position',[100 100 1100 700]);

% Time domain: m(t)
subplot(2,2,1);
plot(t*1e3, m, 'LineWidth',1.2);
grid on; xlabel('Time (ms)'); ylabel('Amplitude');
title('Baseband m(t)');

% Time domain: s(t)
subplot(2,2,2);
plot(t*1e3, s, 'LineWidth',1.0); hold on;
plot(t*1e3, m, 'k--','LineWidth',0.8); % show envelope for intuition
grid on; xlabel('Time (ms)'); ylabel('Amplitude');
title(sprintf('Bandpass s(t) = m(t) cos(2\\pi f_c t),  f_c = %.0f Hz',fc));
legend('s(t)','m(t) (envelope)','Location','best');

% Frequency domain: |M(f)|
subplot(2,2,3);
plot(f/1e3, Mag(M)/max(Mag(M)), 'LineWidth',1.2);
grid on; xlabel('Frequency (kHz)'); ylabel('Normalized |M(f)|');
title('Baseband spectrum |M(f)|');
xlim([-4*W 4*W]/1e3); % zoom around DC
% annotate approximate bandwidth
hold on; ylm = ylim; 
plot([ -W  -W]/1e3, ylm, 'r:'); 
plot([  W   W]/1e3, ylm, 'r:'); 
text(0, 0.9, sprintf('~%.0f Hz one-sided BW',W), 'HorizontalAlignment','center','Color','r');

% Frequency domain: |S(f)|
subplot(2,2,4);
plot(f/1e3, Mag(S)/max(Mag(S)), 'LineWidth',1.2);
grid on; xlabel('Frequency (kHz)'); ylabel('Normalized |S(f)|');
title('|S(f)| = 1/2 [M(f-f_c) + M(f+f_c)]');
xlim([(-fc-4*W) (fc+4*W)]/1e3);
% annotate sidebands at ±fc
hold on; ylm = ylim;
plot([ (fc-W) (fc-W) ]/1e3, ylm, 'r:');
plot([ (fc+W) (fc+W) ]/1e3, ylm, 'r:');
plot([-(fc-W) -(fc-W)]/1e3, ylm, 'r:');
plot([-(fc+W) -(fc+W)]/1e3, ylm, 'r:');
text(fc/1e3, 0.9, '+f_c', 'HorizontalAlignment','center','Color','r');
text(-fc/1e3, 0.9, '-f_c', 'HorizontalAlignment','center','Color','r');

sgtitle('Bandpass modulation demo (DSB-SC)');
