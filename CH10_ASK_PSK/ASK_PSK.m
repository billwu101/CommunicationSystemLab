% LAB10 數位調變：ASK / PSK / FSK
clear; clc; close all;

% 參數設定
Rb = 8e3;           % bit rate：2 kbps（可以改成 8.3e3 等）
Tb = 1/Rb;          % 一個 bit 的時間
Fs = 1e9;         % 取樣頻率（要遠大於載波頻率） 
Ts = 1/Fs;

bits = [1 0 0 1 1 0 1 0];   % 自訂 bit 串列（可以照講義改）

Nb = Fs/Rb;                 % 每個 bit 佔幾個 sample
t = (0:length(bits)*Nb-1)*Ts;   % 整體時間軸

% 產生 baseband NRZ (unipolar: 0 / 1)
% 如果 MATLAB 沒有 repelem，可以改用：m = kron(bits, ones(1, Nb));
m = repelem(bits, Nb);

% 載波設定（可依講義修改）
fc_ask = 100e3;     % ASK 載波頻率 100 kHz
fc_psk = 50e3;       % PSK 載波頻率 4 kHz
f1_fsk = 10e3;       % FSK：bit=1 時的頻率
f2_fsk = 100e3;      % FSK：bit=0 時的頻率

c_ask = cos(2*pi*fc_ask*t);
c_psk = cos(2*pi*fc_psk*t);

% 1. ASK（Amplitude Shift Keying）
% unipolar：位元 1 → 有載波，位元 0 → 0
s_ask = m .* c_ask;

% 2. PSK（BPSK：Phase Shift Keying）
% 先把 0/1 映射成 bipolar ±1
a_bp = 2*m - 1;         % 1 -> +1, 0 -> -1
s_psk = a_bp .* c_psk;  % 等價於相位 0 與 π 之間切換

% 3. FSK（Frequency Shift Keying）
s_fsk = zeros(size(t));

for k = 1:length(bits)
    idx = (k-1)*Nb + 1 : k*Nb;   % 此 bit 對應的 sample 範圍
    if bits(k) == 1
        s_fsk(idx) = cos(2*pi*f1_fsk*t(idx));   % bit=1 → 用 f1
    else
        s_fsk(idx) = cos(2*pi*f2_fsk*t(idx));   % bit=0 → 用 f2
    end
end


% 繪圖
t_ms = t * 1e3;    % 轉成毫秒方便觀看

figure;
subplot(4,1,1);
plot(t_ms, m, 'LineWidth', 1.2);
ylim([-0.2 1.2]);
ylabel('m(t)');
title('Baseband NRZ 訊號');
grid on;

subplot(4,1,2);
plot(t_ms, s_ask);
ylabel('s_{ASK}(t)');
title('ASK 波形');
grid on;

subplot(4,1,3);
plot(t_ms, s_psk);
ylabel('s_{PSK}(t)');
title('BPSK (PSK) 波形');
grid on;

subplot(4,1,4);
plot(t_ms, s_fsk);
ylabel('s_{FSK}(t)');
xlabel('Time (ms)');
title('FSK 波形');
grid on;




figure('Name',"ASK");

subplot(2,1,1);
plot(t_ms, m, 'LineWidth', 1.2);
ylim([-0.2 1.2]);
ylabel('m(t)');
title('Baseband NRZ 訊號');
grid on;

subplot(2,1,2);
plot(t_ms, s_ask);
ylabel('s_{ASK}(t)');
title('ASK 波形');
grid on;

figure('Name',"PSK");

subplot(2,1,1);
plot(t_ms, m, 'LineWidth', 1.2);
ylim([-0.2 1.2]);
ylabel('m(t)');
title('Baseband NRZ 訊號');
grid on;

subplot(2,1,2);
plot(t_ms, s_psk);
ylabel('s_{PSK}(t)');
title('BPSK (PSK) 波形');
grid on;

figure('Name',"FSK");

subplot(2,1,1);
plot(t_ms, m, 'LineWidth', 1.2);
ylim([-0.2 1.2]);
ylabel('m(t)');
title('Baseband NRZ 訊號');
grid on;

subplot(2,1,2);
plot(t_ms, s_fsk);
ylabel('s_{FSK}(t)');
xlabel('Time (ms)');
title('FSK 波形');
grid on;