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

% ====== Plot ======
win = t <= show_window_T;        % 截前幾個週期讓圖更清楚

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