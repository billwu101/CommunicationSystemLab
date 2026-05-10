close all; clear; clc;

% Parameters
Fs = 1e5;          % Sampling frequency [Hz]
Ts = 1 / Fs;          % Sampling period
L  = 1e3;          % Signal length
t  = (0:L-1)*Ts;     % Time vector

% Generate square wave of 50 Hz
f0 = 1e4;                  
x  = square(2*pi*f0*t);

% Compute FFT
Y = fft(x);

% Two-sided spectrum
P2 = abs(Y/L);

% Single-sided spectrum
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

% Frequency axis
f = (0 : (L/2)) * (Fs / L);


% Plot the square wave
figure;
subplot(1,2,1);
plot(t, x); % plot only first 200 samples
title('Square Wave in Time Domain ' + string(f0) + 'Hz');
xlabel('Time (s)');
ylabel('Amplitude');
xlim([0,10 * (1 / f0)]);
ylim([-2,2]);
grid on;

% Plot single-sided amplitude spectrum
subplot(1,2,2);
%stem(f, P1,'filled');
plot(f, P1 , 'LineWidth',1.5);
title('Single-Sided Amplitude Spectrum of Square Wave');
xlabel('Frequency (Hz)');
ylabel('|P1(f)|');
%xlim([0,Fs / 4]);
grid on;



%%
close all; clear; clc;

% Parameters
Fs = 1e6;               % Sampling frequency
T  = 1/Fs;              % Sampling period
Period  = 20;           % Signal length
%t  = (0:L-1)*T;        % Time vector       t = 0:T:L*T
f0 = 5e3;   
t = 0:(1 / Fs):Period / f0;
               
x  = square(2*pi*f0*t);

% Plot the square wave
figure;
plot(t, x); 
title('Square Wave in Time Domain');
xlabel('Time (s)');
ylabel('Amplitude');
xlim([0,20 * (1 / f0)]);
ylim([-2,2]);
grid on;

% Compute FFT
Y = fft(x);

% Two-sided spectrum
%P2 = abs(Y/L);
P2 = abs(Y);

% Single-sided spectrum
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

% Frequency axis
%f = Fs*(0:(L/2))/L;
f = 0:Fs:10 * f0;

% Plot single-sided amplitude spectrum
figure;
stem(f, P1,'filled');
title('Single-Sided Amplitude Spectrum of Square Wave');
xlabel('Frequency (Hz)');
ylabel('|P1(f)|');
grid on;
