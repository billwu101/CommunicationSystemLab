% FM modulation timeline demo
clear; clc; close all;

% 1) Parameters
Fs   = 1e6;                         % sample rate (Hz)
T    = 0.05;                        % duration (s)
t    = (0: 1 / Fs :T - 1/Fs)';      % time axis
fc   = 20e3;                        % carrier (Hz)
fmsg = 2e3;                         % message tone (Hz)
delta_f = 5e3;                      % peak frequency deviation (Hz)

% Message (normalize to |m(t)|<=1 so Δf is respected)
m = sin(2*pi*fmsg * t);        % try other shapes to see different timelines
%m = square(2*pi*fmsg*t);        % try other shapes to see different timelines

% 2) FM modulation (from first principles)
% s(t) = cos(2π f_c t + 2π k_f ∫ m(τ)dτ), where k_f (Hz per unit amp) = Δf
kf   = delta_f;                                 % Hz / (unit amplitude)
phi  = 2*pi*fc*t + 2*pi*kf * cumsum(m) / Fs;   % discrete-time integral via cumsum/Fs
s    = cos(phi);

X   = fft(m);                                       % raw FFT
N = length(X);
f1   = (-N / 2 : (N / 2) - 1) * (Fs / N);            % frequency axis (Hz)
mag1 = abs(fftshift(X)) / N;                         % magnitude spectrum (normalized)

X   = fft(s);                                       % raw FFT
N = length(X);
f   = (-N / 2 : (N / 2) - 1) * (Fs / N);            % frequency axis (Hz)
mag = abs(fftshift(X)) / N;                         % magnitude spectrum (normalized)



% %Ground-truth instantaneous frequency (timeline): f_i(t) = f_c + kf*m(t)
% fi_true = fc + kf*m;
% 
% %3) Estimate instantaneous frequency from the signal (for plotting)
% %Use analytic signal phase derivative
% theta   = unwrap(angle(hilbert(s)));       % instantaneous phase (rad)
% fi_est  = [diff(theta); 0] * Fs/(2*pi);      % dθ/dt / (2π)
% 
% % 4) Plots: message, waveform (zoom), instantaneous frequency timeline, spectrogram
% figure('Name','FM Modulation Timeline');
% 
% subplot(4,1,1);
% plot(t, m, 'LineWidth', 1);
% xlim([0 5e-3]);
% grid on; xlabel('Time (s)'); ylabel('m(t)');
% title('Message');
% 
% subplot(4,1,2);
% plot(t, s, 'LineWidth', 1);
% xlim([0 5e-3]); % zoom first 5 ms to see carrier
% grid on; xlabel('Time (s)'); ylabel('s(t)');
% title('FM Waveform (zoomed)');
% 
% subplot(4,1,3);
% plot(t, fi_true, 'LineWidth', 1.2); hold on;
% plot(t, fi_est,  '--', 'LineWidth', 1);
% grid on; xlabel('Time (s)'); ylabel('Frequency (Hz)');
% legend('True f_i(t) = f_c + k_f m(t)', 'Estimated f_i(t)', 'Location','best');
% title('Instantaneous Frequency Timeline');
% 
% subplot(4,1,4);
% % Spectrogram shows frequency content over time (another "timeline" view)
% window   = 1024; noverlap = 768; nfft = 4096;
% spectrogram(s, window, noverlap, nfft, Fs, 'yaxis');
% ylim([0 40]); colorbar; title('Spectrogram (kHz)'); % y-axis in kHz
% ylabel('kHz');

% 5) Demodulation (two ways)

% (A) DIY arctangent/phase-derivative FM demod
% Remove carrier term (2π f_c t), then differentiate phase and scale back to m(t)
theta   = unwrap(angle(hilbert(s)));       % instantaneous phase (rad)
phi_base = theta - 2*pi*fc*t;             % residual phase due to modulation
dphi_dt  = [diff(phi_base); 0] * Fs;        % time derivative (rad/s)
m_hat_A  = dphi_dt / (2*pi*kf);           % ≈ m(t) + HF residuals
% Optional cleanup: lowpass around a few*fmsg
m_hat_A  = lowpass(m_hat_A, 2*fmsg, Fs);  % requires Signal Processing Toolbox

% (B) Toolbox one-liner (Communications Toolbox)
% fmmod/fmdemod use Δf directly
y_mod    = fmmod(m, fc, Fs, delta_f);
m_hat_B  = fmdemod(y_mod, fc, Fs, delta_f);

figure('Name','FM Demod');
plot(t, m, 'LineWidth', 1.2); hold on;
plot(t, m_hat_A, '--', 'LineWidth', 1);
%plot(t, m_hat_B, ':', 'LineWidth', 1.2);
xlim([0 5e-3]);
%ylim([0 5e-3]);
grid on; xlabel('Time (s)'); ylabel('Amplitude');
legend('Original m(t)', 'Demod DIY', 'Demod fmdemod', 'Location','best');
title('FM Demodulation Comparison');

figure('Name','FM FFT');
subplot(1,2,1);
plot(t, m, 'LineWidth', 1);
xlim([0 5e-3]);
grid on; xlabel('Time (s)'); ylabel('m(t)');
title('Message');
subplot(1,2,2);
stem(f1, mag1, 'filled'); hold on; grid on;
%plot(f , mag , 'LineWidth',1.5); hold on; grid on;
xlabel('f (Hz)'); ylabel('|X(f)| (normalized)');
title('Frequency domain:');
xlim([-Fs/200 Fs/200]);

figure('Name','FM FFT');
subplot(1,2,1);
plot(t, s, 'LineWidth', 1);
xlim([0 2e-3]); % zoom first 5 ms to see carrier
grid on; xlabel('Time (s)'); ylabel('s(t)');
title('FM Waveform (zoomed)');
subplot(1,2,2);
stem(f, mag, 'filled'); hold on; grid on;
%plot(f , mag , 'LineWidth',1.5); hold on; grid on;
xlabel('f (Hz)'); ylabel('|X(f)| (normalized)');
title('Frequency domain:');
xlim([-Fs/20 Fs/20]);


% 6) Quick notes
% • Modulation index β = Δf / fmsg (for a single-tone message).
% • Increase Δf for wider deviation (larger β), or change m(t) to see different timelines.
% • fi_true is the "timeline" you usually want to visualize: carrier wandering around f_c.
% • For voice/audio FM, replace m with an audio vector normalized to [-1,1].
