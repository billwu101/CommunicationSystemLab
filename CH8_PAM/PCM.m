clear; clc; close all;

% ===== Parameters =====
Fs      = 1e6;               % 連續時間模擬取樣率 (Hz)
Ts      = 1/Fs;
fm      = 50;                % 訊號(類比message)頻率 (Hz)
Amsg    = 1;                 % 訊號振幅 (±1 範圍)
Tobs    = 0.12;              % 觀察時間 (s)
%Tobs    = 0.5;

Fp      = 1e3;               % 脈衝重複頻率 (pulse repetition frequency, Hz)
Tp      = 1/Fp;              % 脈衝週期
tau_pam = 0.20 * Tp;         % PAM 脈衝寬度
tau_ppm = 0.02 * Tp;         % PPM 單脈衝寬度（短）
Nb      = 3;                 % PCM 量化位元數（例：3 bits 對應 8 階）

show_window_T = 2 / fm;     

% ===== Time and message =====
t  = 0 : Ts : Tobs - Ts;
m  = Amsg * sin(2*pi*fm*t);             % 原始訊號（範圍約 [-1,1]）
mn = (m + 1)/2;                         % 轉為 [0,1]，方便做比較/定位

% ====== PCM (Pulse Code Modulation, NRZ-L 線碼) ======
% 1) 取樣（每 Tp 一次） 2) 量化（Nb bits） 3) 編碼成位元串並以 NRZ-L 送出
tn_samp  = 0:Tp:(Tobs-Tp);                      % 取樣時刻
m_samp   = Amsg*sin(2*pi*fm*tn_samp);          % 每個週期取一個 sample
L        = 2^Nb;
q_index  = round( (m_samp+1)/2 * (L-1) );      % 量化到 0..L-1（midrise 類）
% 轉位元（MSB first）
bits_mat = dec2bin(q_index, Nb) - '0';         % size: [Nsamp x Nb]
bitstream= reshape(bits_mat.', 1, []);         % 逐列展平
Tb       = Tp / Nb;                            % 一個取樣對應 Nb bits → 每 bit 時長
spb      = max(1, round(Tb*Fs));               % 每 bit 對應的樣本數
pcm_nrz  = repelem(bitstream, spb);            % NRZ-L 方波（0→0V, 1→1V）
t_pcm    = (0:length(pcm_nrz)-1) / Fs;


% ====== Plot ======
win = t <= show_window_T;        % 截前幾個週期讓圖更清楚
figure('Name','PCM');

subplot(2,1,1);
plot(t(win)*1e3, mn(win),'LineWidth',1);hold on;
%plot(t(win)*1e3, ramp01(win),'LineWidth',1);
grid on; xlabel('Time (ms)'); ylabel('m(t)');
title('Message (analog)');
grid on; xlabel('Time (ms)'); ylabel('Level');
title('PCM (NRZ-L), %d-bit quantization');

subplot(2,1,2);
plot(t_pcm*1e3, pcm_nrz,'LineWidth',1);
xlim([0, show_window_T*1e3]); grid on;
xlabel('Time (ms)'); ylabel('Level');
%title(sprintf('PCM (NRZ-L), %d-bit quantization', Nb));
ylim([0 1.1]);  