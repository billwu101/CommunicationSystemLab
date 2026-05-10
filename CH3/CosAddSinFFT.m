% DC signal and its FFT (discrete-time demo)
clear; close all; clc ;

% Parameters
fs = 1e5;              % sampling rate [Hz]
%N  = 256;               % number of samples (power of 2 is convenient)
numCycles = 10;
% Time signal: constant (DC)

fsin = 2e3;
fcos = 10e3;
%t = (0 : N-1) / fs;
t = 0 : 1/fs : 1e-1 - (1/fs);     % time axis(duration [s]()

% T = numCycles / fc;          % total signal duration
% t = 0 : 1/fs : T - 1/fs;     % time vector

% count = 0;
% index = 2 / fs;
% 
% while count < numCycles
%     if cos(2*pi*fc * (index - (1 / fs))) >= 0 && cos(2*pi*fc * index) < 0
%         count = count + 1;
%     end
%     index = index + (1 / fs);
% end
% 
% while (cos(2*pi*fc * index) - cos(2*pi*fc * (index - (1 / fs)))) >= 0
%     index = index + (1 / fs);
% 
% end

%t = 0 : 1/fs : index;     % time vector

% count = 0;
% for k = 2:length(t)
%     if x(k-1) <= 0 && x(k) > 0   % rising zero-crossing
%         count = count + 1;
%     end
% end
% 
% count

xcos = cos(2 * pi * fcos * t);
xsin = sin(2 * pi * fsin * t);

x = xcos .* xsin;

% FFT
X   = fft(x);                                       % raw FFT
N = length(X);

f   = (-N / 2 : (N / 2) - 1) * (fs / N);            % frequency axis (Hz)
mag = abs(fftshift(X)) / N;                         % magnitude spectrum (normalized)

% Plot
figure('Name','DC signal and FFT');
subplot(1,3,1);
plot(t, x, 'LineWidth', 2);grid on;hold on;
xlabel('t (s)'); ylabel('x(t)'); title('Time domain:');
ylim([-1.5 , 1.5]);
xlim([0 , 3 * (1 / fsin)]);


subplot(1,3,2);
stem(f, mag, 'filled'); hold on; grid on;
%plot(f , mag , 'LineWidth',1.5); hold on; grid on;
xlabel('f (Hz)'); ylabel('|X(f)| (normalized)');
title('Frequency domain:');
xlim([-fs/5 fs/5]);

subplot(1,3,3);
window   = 1024; noverlap = 768; nfft = 4096;
spectrogram(x, window, noverlap, nfft, fs, 'yaxis');
%colorbar; 
title('Spectrogram (kHz)'); % y-axis in kHz
ylabel('kHz');