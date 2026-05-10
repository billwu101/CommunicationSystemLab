%% RC filter demo: low-pass & high-pass + plots
clear; close all; clc;

% Parameters
R  = 10e3;           % Ohms
C  = 10e-9;           % Farads
fc = 1/(2*pi*R*C);   % Cutoff frequency (Hz)
fprintf('Cutoff fc = %.3f kHz\n', fc/1e3);

% --- Analog transfer functions (Laplace) ---
s = tf('s');
Hlp = 1/(1 + s*R*C);       % RC low-pass
Hhp = (s*R*C)/(1 + s*R*C); % RC high-pass


% --- Time-domain: filter a test sine + DC offset ---
fs   = 10e6;               % sample rate for discrete-time test
Ts   = 1/fs;

f_list = [1e3, 1.5e3 ,3e3,5e3];
tC = cell(numel(f_list),1);
xC = cell(numel(f_list),1);
yC = cell(numel(f_list),1);


% Discretize the analog filters (bilinear / Tustin)
Hlp_z = c2d(Hlp, Ts, 'tustin');
Hhp_z = c2d(Hhp, Ts, 'tustin');             %%

figure('Name','Discrete-time: Filtering demo');

for i = 1:length(f_list)

    Ti = 50 / f_list(i);
    tC{i} = 0:Ts:Ti;

    xC{i} = sin(2* pi * f_list(i) * tC{i});         % Comparator output for each reference voltage
    yC{i} = lsim(Hlp_z, xC{i}, tC{i});

    subplot(length(f_list),1,i);
    plot(tC{i}, xC{i}, 'y', 'LineWidth',1.2); hold on;
    plot(tC{i}, yC{i}, 'c','LineWidth',1.2);
    grid on;
    ylabel('Voltage'); 
    title(['Input Signal vs Output f = ' num2str(f_list(i) / 1e3) 'kHz']);
    legend('Input' , 'Output');
    xlim([0,20 / f_list(i)]);

end

%x = sin(2*pi*f1*tN);

%yHP = lsim(Hhp_z, x, tN);                   %%

% subplot(3,1,3);
% plot(tN, yHP, 'LineWidth',1.2); grid on;
% ylabel('y_{HP}[n]'); xlabel('Time (s)');
% title('High-pass output (keeps high f, removes DC)');

%% Bode-magnitude plot (analog)
w = logspace(log10(2*pi*fc/50), log10(2*pi*fc*50), 800); % rad/s

[magLP,phaseLP] = bode(Hlp, w);  magLP = squeeze(magLP); phaseLP = squeeze(phaseLP);
[magHP,phaseHP] = bode(Hhp, w);  magHP = squeeze(magHP); phaseHP = squeeze(phaseHP);

figure('Name','Analog RC: Frequency Response');
subplot(2,1,1);
semilogx(w/(2*pi), 20*log10(magLP), 'LineWidth',1.4); hold on;
semilogx(w/(2*pi), 20*log10(magHP), 'LineWidth',1.4);
grid on; xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
title(sprintf('Analog RC (R=%.0fΩ, C=%.0eF)  –  fc ≈ %.2f Hz', R, C, fc));
legend('Low-pass','High-pass','Location','SouthWest');

subplot(2,1,2);
semilogx(w/(2*pi), phaseLP, 'LineWidth',1.4); hold on;
semilogx(w/(2*pi), phaseHP, 'LineWidth',1.4);
grid on; xlabel('Frequency (Hz)'); ylabel('Phase (deg)');
legend('Low-pass','High-pass','Location','SouthWest');

%% --- Time-domain: step response (analog) ---
t = linspace(0, 5/(2*pi*fc), 2000);  % ~ several time constants
figure('Name','Analog RC: Step Response');
lsimplot(Hlp, ones(size(t)), t, 'b'); hold on;
lsimplot(Hhp, ones(size(t)), t, 'r');
grid on; xlabel('Time (s)'); ylabel('Amplitude');
title('Step response'); legend('Low-pass','High-pass');



%% --- Discrete frequency response (for the bilinear-discretized filters) ---
[Hlp_w, w_d] = freqz(Hlp_z.num{:}, Hlp_z.den{:}, 1024, fs);
[Hhp_w, ~  ] = freqz(Hhp_z.num{:}, Hhp_z.den{:}, 1024, fs);

figure('Name','Discrete-time: Frequency Response (bilinear)');
subplot(2,1,1);
plot(w_d, 20*log10(abs(Hlp_w)), 'LineWidth',1.3); hold on;
plot(w_d, 20*log10(abs(Hhp_w)), 'LineWidth',1.3);
grid on; xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
title('freqz of discretized RC'); legend('LP (Tustin)','HP (Tustin)');

subplot(2,1,2);
plot(w_d, angle(Hlp_w)*180/pi, 'LineWidth',1.3); hold on;
plot(w_d, angle(Hhp_w)*180/pi, 'LineWidth',1.3);
grid on; xlabel('Frequency (Hz)'); ylabel('Phase (deg)');
legend('LP (Tustin)','HP (Tustin)');
