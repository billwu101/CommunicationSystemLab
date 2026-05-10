clear; close all;
% ---------------- Demodulation ----------------
% Goal: recover m(t) ~ cos(2π f_m t) from each AM variant.
% Filters use zero-phase IIR (lowpass) for clean waveforms.

fc_lp = 2.5*fm;                   % LPF cutoff a bit above fm
lp_opts = {'Steepness',0.95,'StopbandAttenuation',80};

% ---- 1) DSB-TC (conventional AM) : Envelope detection ----
% Ideal analytic-envelope method
env_tc   = abs(hilbert(s_tc));    % ≈ Ac*(1 + mu*m)
m_hat_tc = (env_tc/Ac - 1)/mu;    % remove DC and scale to match m

% Practical rectifier + LPF (alternative; uncomment if you want to compare)
% env_rect  = lowpass(abs(s_tc), fc_lp, fs, lp_opts{:});
% m_hat_tcR = (env_rect/Ac - 1)/mu;

% ---- 2) DSB-SC : Coherent (product) detection ----
% Multiply by synchronized LO and LPF. Using 2*cos gives unity gain after LPF.
lo       = cos(2*pi*fc*t);
bb_sc    = s_sc .* (2*lo);                  % baseband + 2fc terms
bb_sc_lp = lowpass(bb_sc, fc_lp, fs, lp_opts{:});
m_hat_sc = bb_sc_lp / (Ac*mu);              % normalize to m

% ---- 3) SSB (USB/LSB) : Coherent (product) detection ----
% For both USB and LSB generated via Hilbert method, mixing by 2*cos()
% and lowpass yields Ac*m in baseband. Then divide by Ac.
bb_usb    = s_usb .* (2*lo);
bb_lsb    = s_lsb .* (2*lo);
m_hat_usb = lowpass(bb_usb, fc_lp, fs, lp_opts{:}) / Ac;
m_hat_lsb = lowpass(bb_lsb, fc_lp, fs, lp_opts{:}) / Ac;

% ---------------- Plots: demodulated vs original ----------------
figure('Name','AM Demodulation (Recovered Baseband)');

subplot(4,1,1);
plot(t*1e3, m_hat_tc, 'LineWidth', 1.1); grid on; hold on;
plot(t*1e3, m, '--', 'LineWidth', 1.0);
xlabel('Time [ms]'); ylabel('Amplitude');
title('Recovered m(t) from DSB-TC (Envelope)');
legend('m\_hat','m','Location','best');
xlim(1e3*[-2/fm, 2/fm]);

subplot(4,1,2);
plot(t*1e3, m_hat_sc, 'LineWidth', 1.1); grid on; hold on;
plot(t*1e3, m, '--', 'LineWidth', 1.0);
xlabel('Time [ms]'); ylabel('Amplitude');
title('Recovered m(t) from DSB-SC (Coherent)');
legend('m\_hat','m','Location','best');
xlim(1e3*[-2/fm, 2/fm]);

subplot(4,1,3);
plot(t*1e3, m_hat_usb, 'LineWidth', 1.1); grid on; hold on;
plot(t*1e3, m, '--', 'LineWidth', 1.0);
xlabel('Time [ms]'); ylabel('Amplitude');
title('Recovered m(t) from SSB-USB (Coherent)');
legend('m\_hat','m','Location','best');
xlim(1e3*[-2/fm, 2/fm]);

subplot(4,1,4);
plot(t*1e3, m_hat_lsb, 'LineWidth', 1.1); grid on; hold on;
plot(t*1e3, m, '--', 'LineWidth', 1.0);
xlabel('Time [ms]'); ylabel('Amplitude');
title('Recovered m(t) from SSB-LSB (Coherent)');
legend('m\_hat','m','Location','best');
xlim(1e3*[-2/fm, 2/fm]);

sgtitle('AM Demodulation: Envelope (DSB-TC) and Coherent (DSB-SC/SSB)');

% ---------------- Quick accuracy check ----------------
fprintf('Max |m_hat_tc - m|    = %.3e\n', max(abs(m_hat_tc - m)));
fprintf('Max |m_hat_sc - m|    = %.3e\n', max(abs(m_hat_sc - m)));
fprintf('Max |m_hat_usb - m|   = %.3e\n', max(abs(m_hat_usb - m)));
fprintf('Max |m_hat_lsb - m|   = %.3e\n', max(abs(m_hat_lsb - m)));
% fprintf('Max |m_hat_tcR - m|   = %.3e (rectifier path)\n', max(abs(m_hat_tcR - m)));
