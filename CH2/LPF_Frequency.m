%% Tunable LPF demo (MATLAB)
clear; close all; clc

Fs  = 1e6;                % Sampling rate (Hz)
T   = 3;                    % Duration (s)
t   = (0:1/Fs:T-1/Fs).';    % Time vector

% Test signal: 500 Hz + 3 kHz + white noise
%x = 0.8*sin(2*pi*500*t) + 0.4*sin(2*pi*3000*t) + 0.1*randn(size(t));

x = 0.8*sin(2*pi*10e3*t) ;

% Choose a few cutoff frequencies to compare (Hz)
fc_list = [800, 1500, 3000];
Q = 1/sqrt(2); % Butterworth damping

%% Plot frequency responses for several cutoffs
figure('Name','LPF Frequency Responses');
hold on; grid on
for fc = fc_list
    [b,a] = biquadLPF(fc, Q, Fs);
    [H,w] = freqz(b,a,2048,Fs);
    plot(w, 20*log10(abs(H)), 'DisplayName', sprintf('fc = %d Hz', fc));
end
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Tunable 2nd-Order LPF – Magnitude Response');
legend('show','Location','southwest');

%% Filter the signal with one chosen cutoff (tune here)
fc = 1500;                   % <<< try 800 / 1500 / 3000 (or any value < Fs/2)
[b,a] = biquadLPF(fc, Q, Fs);
y = filter(b,a,x);

xlim_V = 0.003;

% Plot time-domain before/after
figure('Name','Time-Domain Signal');
subplot(2,1,1);
plot(t, x); 
ylim([-1 1]);
xlim([0 xlim_V]); % zoom first 30 ms
title('Input signal (zoom)');
ylabel('Amplitude');
grid on;

subplot(2,1,2);
plot(t, y); grid on
xlim([0 xlim_V]);
title(sprintf('Filtered output (fc = %d Hz)', fc));
xlabel('Time (s)'); ylabel('Amplitude');

%% Spectra before/after
NFFT = 2^nextpow2(length(x));
X = fft(x, NFFT);  Y = fft(y, NFFT);
f = (0:NFFT-1)*(Fs/NFFT);

figure('Name','Spectra');
plot(f, 20*log10(abs(X)+1e-12), 'DisplayName','Input'); hold on; grid on
plot(f, 20*log10(abs(Y)+1e-12), 'DisplayName',sprintf('Output (fc=%d Hz)',fc));
xlim([0 8000]);  % up to 8 kHz for clarity
ylim([-120 20]);
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
title('Input vs Output Spectrum');
legend('show','Location','southwest');

%% OPTIONAL: show "tunable over time" by switching fc each second
edges = round(linspace(1, numel(x)+1, numel(fc_list)+1));
y_blk = zeros(size(x));
zi = [];  % filter states (initialize empty)
for k = 1:numel(fc_list)
    idx = edges(k):(edges(k+1)-1);
    [b,a] = biquadLPF(fc_list(k), Q, Fs);  % retune
    if isempty(zi)
        [y_blk(idx), zi] = filter(b, a, x(idx));
    else
        [y_blk(idx), zi] = filter(b, a, x(idx), zi); % carry states across changes
    end
end

figure('Name','Time-Varying Tuning (Blockwise)');
plot(t, y_blk); grid on
title(sprintf('Output with fc changing each second: [%s] Hz', num2str(fc_list)));
xlabel('Time (s)'); ylabel('Amplitude'); xlim([0 0.06])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper: 2nd-order low-pass biquad (RBJ cookbook; Butterworth if Q=1/sqrt(2))
function [b,a] = biquadLPF(fc, Q, Fs)
    fc = max(1, min(fc, 0.49*Fs));      % clamp to (0, Nyquist)
    w0 = 2*pi*fc/Fs;
    cw = cos(w0);  sw = sin(w0);
    alpha = sw/(2*Q);

    b0 = (1 - cw)/2;
    b1 = 1 - cw;
    b2 = (1 - cw)/2;
    a0 = 1 + alpha;
    a1 = -2*cw;
    a2 = 1 - alpha;

    % normalize
    b = [b0 b1 b2] / a0;
    a = [1  a1/a0  a2/a0];
end
