clear; clc; close all;

% Parameters
fs = 1e6;            % Sampling frequency (Hz)
fc = 100;             % Cutoff frequency (Hz)
N = 50;               % Filter order

% Design FIR Low-pass filter
b = fir1(N, fc/(fs/2));  % Normalized cutoff frequency (0-1)

% Get impulse response
imp = [1; zeros(0.1e3,1)]; % Unit impulse (length 101)
h = filter(b,1,imp);     % Impulse response

% Plot impulse response
stem(0:length(h)-1, h, 'filled');
xlabel('n'); ylabel('h[n]');
title('FIR Low-pass Filter Impulse Response');
grid on;

%%
% Parameters

clear; clc; close all;

fs = 1000;       % Sampling frequency
fc = 100;        % Cutoff frequency
N = 4;           % Filter order

% Design Butterworth LPF
[b,a] = butter(N, fc/(fs/2));

% Impulse response
imp = [1; zeros(100,1)];
h = filter(b,a,imp);

% Plot
stem(0:length(h)-1, h, 'filled');
xlabel('n'); ylabel('h[n]');
title('Butterworth LPF Impulse Response');
grid on;
