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

