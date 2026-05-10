% pulse_modulation_demo.m
% ----------------------
% 產生並示範四種脈衝調變：PAM / PWM / PPM / PCM（NRZ-L）
% 調整下列參數即可改出圖形/波形

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


% 顯示視窗（只截一小段，圖會比較清楚）
show_window_T = 2 / fm;       

% ===== Time and message =====
t  = 0 : Ts : Tobs - Ts;
m  = Amsg * sin(2*pi*fm*t);             % 原始訊號（範圍約 [-1,1]）
mn = (m + 1)/2;                         % 轉為 [0,1]，方便做比較/定位

% ====== PAM (Pulse Amplitude Modulation) ======
% 在每個 Tp 的固定位置打一個寬度為 tau_pam 的方波，方波的"振幅"依訊號而變

% ====== PAM：從已產生的 m(t) 直接取樣，不重算 cos/sin ======
n_period = floor(t/Tp);                 % 週期編號 n（與原本相同）
pulse_gate = (mod(t,Tp) < tau_pam);     % 固定位置之窄脈衝（與原本相同）

% --- A) 於每個週期「起點」取樣（edge-aligned） ---
idx_samp = 1 + floor((n_period.*Tp)/Ts);     % 對應到 m(t) 的索引
idx_samp = max(1, min(numel(m), idx_samp));  % 夾限避免越界
pam_env  = (m(idx_samp) + 1)/2;              % 直接用 m 取樣，不重算

% % --- B) 於每個週期「脈衝中心」取樣（視覺更貼合包絡；擇一使用） ---
% t_samp  = n_period.*Tp + tau_pam/2;
% idx_samp = 1 + round(t_samp/Ts);
% idx_samp = max(1, min(numel(m), idx_samp));
% pam_env  = (m(idx_samp) + 1)/2;

pam = pam_env .* pulse_gate;

% ====== PWM (Pulse Width Modulation) ======
% 每個週期內做一個 0→1 的 ramp，訊號大小決定"寬度"
ramp01 = mod(t,Tp)/Tp;         % 每個週期內的 0~1 斜坡
pwm    = double(ramp01 < mn);  % 比較：小於訊號值的區間為 1，即寬度隨 m(t) 改變

% ====== PPM (Pulse Position Modulation) ======
% 每個週期只打一個窄脈衝，但"位置"依訊號而變
pos_in_period = ((Amsg * sin(2*pi*fm*(n_period * Tp)) + 1) / 2) * Tp;       % 位置 = m[n] 映射到 [0,Tp]
tau_ppm = min(tau_ppm, 0.5*Tp);                                             % 安全限幅
t_in_period  = mod(t,Tp);
ppm = double((t_in_period >= pos_in_period) & (t_in_period < pos_in_period+tau_ppm));

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
figure('Name','Pulse Modulation Demo');

%X = t(win);

subplot(5,1,1);
plot(t(win)*1e3, m(win),'LineWidth',1);
grid on; xlabel('Time (ms)'); ylabel('m(t)');
title('Message (analog)');

subplot(5,1,2);
plot(t(win)*1e3, pam(win),'LineWidth',1);hold on;
%plot(t(win)*1e3, pam_env(win),'LineWidth',1);hold on;
grid on; xlabel('Time (ms)'); ylabel('Amplitude');
title('PAM (amplitude of pulses carries message)');

subplot(5,1,3);
%plot(t(win)*1e3, pwm(win),'y','LineWidth',1); hold on;
plot(t(win)*1e3, pwm(win),'LineWidth',1); hold on;
%plot(t(win)*1e3, ramp01(win),'LineWidth',1);
grid on; xlabel('Time (ms)'); ylabel('Level');
title('PWM (pulse width carries message)');

subplot(5,1,4);
plot(t(win)*1e3, ppm(win),'LineWidth',1);hold on;
%plot(t(win)*1e3, pos_in_period(win),'LineWidth',1);
grid on; xlabel('Time (ms)'); ylabel('Level');
title('PPM (pulse position carries message)');

subplot(5,1,5);
plot(t_pcm*1e3, pcm_nrz,'LineWidth',1);
xlim([0, show_window_T*1e3]); grid on;
xlabel('Time (ms)'); ylabel('Level');
title(sprintf('PCM (NRZ-L), %d-bit quantization', Nb));

figure('Name','PAM');

subplot(2,1,1);
plot(t(win)*1e3, mn(win),'LineWidth',1);hold on;
plot(t(win)*1e3, pam_env(win),'LineWidth',1);hold on;
grid on; xlabel('Time (ms)'); ylabel('m(t)');
title('Message (analog)');
grid on; xlabel('Time (ms)'); ylabel('Level');
title('PAM (amplitude of pulses carries message)');

subplot(2,1,2);
plot(t(win)*1e3, mn(win),'LineWidth',1);hold on;
plot(t(win)*1e3, pam(win),'LineWidth',1);hold on;
grid on; xlabel('Time (ms)'); ylabel('Level');
ylim([0 1.1]);  


figure('Name','PWM');

subplot(2,1,1);
plot(t(win)*1e3, mn(win),'LineWidth',1);hold on;
plot(t(win)*1e3, ramp01(win),'LineWidth',1);
%pwm_5 = pwm ./ 2;
%plot(t(win)*1e3, pwm_5(win),'LineWidth',1); hold on
grid on; xlabel('Time (ms)'); ylabel('m(t)');
title('Message (analog)');
grid on; xlabel('Time (ms)'); ylabel('Level');
title('PWM (pulse width carries message)');

subplot(2,1,2);
%plot(t(win)*1e3, pwm(win),'y','LineWidth',1); hold on;
plot(t(win)*1e3, pwm(win),'LineWidth',1); hold on
grid on; xlabel('Time (ms)'); ylabel('Level');
ylim([0 1.1]);  

figure('Name','PPM');

subplot(2,1,1);
plot(t(win)*1e3, mn(win),'LineWidth',1);hold on;
%plot(t(win)*1e3, ramp01(win),'LineWidth',1);
grid on; xlabel('Time (ms)'); ylabel('m(t)');
title('Message (analog)');
grid on; xlabel('Time (ms)'); ylabel('Level');
title('PPM (pulse position carries message)');

subplot(2,1,2);
%plot(t(win)*1e3, pwm(win),'y','LineWidth',1); hold on;
plot(t(win)*1e3, ppm(win),'LineWidth',1);hold on;
grid on; xlabel('Time (ms)'); ylabel('Level');
ylim([0 1.1]);  