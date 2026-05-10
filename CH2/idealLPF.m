% Parameters
fs   = 1000;    % Sampling frequency (Hz)
N    = 1024;    % Number of frequency points
fc   = 100;     % Cutoff frequency (Hz)

f = linspace(-fs/2, fs/2, N);   % Frequency axis
H = double(abs(f) <= fc);       % Ideal LPF response (brick-wall)

% Plot frequency response
figure;
plot(f, H, 'LineWidth', 1.5);
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('Ideal Low-Pass Filter Frequency Response');
grid on;


% Time axis
n = -50:50;   % Truncated to finite length
h = 2*fc/fs * sinc(2*fc/fs * n);

% Plot impulse response
figure;
stem(n,h,'filled');
xlabel('n');
ylabel('h[n]');
title('Impulse Response of Ideal LPF (truncated sinc)');
grid on;

% Example input: sinusoid + noise
t = 0:1/fs:1;
x = sin(2*pi*30*t) + sin(2*pi*200*t); % 30 Hz (keep), 200 Hz (remove)

% Apply ideal LPF via convolution
y = conv(x, h, 'same');
%y = conv(x, h);

figure;
subplot(2,1,1); plot(t,x); title('Input signal');
subplot(2,1,2); plot(t,y); title('Output after Ideal LPF');

