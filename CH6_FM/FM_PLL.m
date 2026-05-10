%% ===================== FM signal (for test) =====================
Fs   = 1e6;                 % 取樣率 (Hz)
T    = 5e-3;                % 模擬時間 (s)
t    = (0:1/Fs:T-1/Fs).';   % 時間向量
fc   = 100e3;               % 載波 (Hz)
fm   = 2e3;                 % 訊號頻率 (Hz)
Am   = 1;                   % 訊號振幅
Ac   = 1;                   % 載波振幅
df   = 5e3;                 % 頻率偏移 Δf (Hz)  --> β = Δf / fm = 5
kf   = df/Am;               % 頻率靈敏度 k_f (Hz / 振幅)

m    = Am*cos(2*pi*fm*t);   % 基帶訊號
phi  = 2*pi*fc*t + 2*pi*kf*cumtrapz(t, m);   % FM 相位
s    = Ac*cos(phi);         % FM 訊號（實數）

% ============== PLL parameters (2nd-order type-II) ==============
% 你只需要調這兩個：loop_bw（迴路帶寬，約略對齊基帶最高頻率）與 zeta（阻尼）
fm_max   = 2e3;                       % 假設基帶上限 ~2 kHz
loop_bw  = 2*pi*(3*fm_max)/Fs;        % 規範化（弧度/樣本），可試 2~4 倍 fm_max/Fs
zeta     = 0.707;                     % 阻尼係數（~0.7 較穩）

% 由常見數位 PLL 設計式求出二階迴路的係數（GNU Radio 等常用）
denom = 1 + 2*zeta*loop_bw + loop_bw^2;
Kp    = (4*zeta*loop_bw) / denom;     % 比例項（proportional）
Ki    = (4*loop_bw^2)    / denom;     % 積分項（integrator）

% ============== NCO / Phase Detector / Loop Filter ==============
N      = numel(t);
theta  = 0;                            % NCO 當前相位（rad）
omega  = 2*pi*fc/Fs;                   % NCO 當前角速度（rad/樣本），初始在 fc
omega0 = 2*pi*fc/Fs;                   % NCO 自由振盪角速度（常數）

% 一階 I/Q 低通（濾掉 2*fc 雙頻項），截止抓寬一點即可
lp_fc  = 2.5*fm_max;                   % I/Q 低通截止（Hz）
a_lp   = exp(-2*pi*lp_fc/Fs);          % 一階 IIR 係數：y = a*y + (1-a)*x
I_lp   = 0; Q_lp = 0;

% 紀錄
m_hat  = zeros(N,1);                   % 還原的 m(t)（經比例換算）
freq_vco_Hz = zeros(N,1);              % VCO 即時頻率（Hz），debug 用

for n = 1:N
    % --- 產生 NCO 正交載波 ---
    c = cos(theta);
    sN= sin(theta);
    
    % --- 相位比較器（正交乘法 + atan2），等效 arctan PD ---
    I = s(n) * c;
    Q = -s(n)* sN;                     % 注意負號，讓 (Q/I) → phase error 符號正確
    
    % --- 去掉 2*fc 成分（簡單一階低通） ---
    I_lp = a_lp*I_lp + (1-a_lp)*I;
    Q_lp = a_lp*Q_lp + (1-a_lp)*Q;
    
    % --- 相位誤差（-pi~pi）---
    e = atan2(Q_lp, I_lp);             % 近似 e ≈ θ_in - θ_vco
    
    % --- 二階 PLL：PI 迴路濾波器 + NCO ---
    omega = omega + Ki*e;              % 積分作用（調頻）
    theta = theta + omega + Kp*e;      % 比例 + 積分（調相）
    
    % 相位包回 (-pi,pi]
    theta = mod(theta + pi, 2*pi) - pi;
    
    % --- 取出 VCO 頻率當作 FM 解調（除以 kf）---
    f_vco = omega * Fs/(2*pi);         % rad/樣本 -> Hz
    freq_vco_Hz(n) = f_vco;
    m_hat(n) = (f_vco - fc) / kf;      % (f_vco - fc) ≈ kf * m(t)
end

% 簡單後處理（去 DC、平滑一點）
m_hat = m_hat - mean(m_hat(round(0.2*N):end));  % 去掉穩態 DC
[b,a] = butter(2, (2.5*fm)/ (Fs/2));            % 小低通（可視需要）
m_hat = filtfilt(b,a,m_hat);

% ====================== Quick sanity check ======================
figure; 
subplot(3,1,1);
plot(t(1:4000), s(1:4000));
%xlim([0 1e-3]);
title('FM input (time snippet)'); xlabel('t (s)'); ylabel('s(t)');

subplot(3,1,2);
plot(t, m, 'LineWidth',1.2); hold on;
plot(t, m_hat, '--'); grid on;
title('Recovered m(t) by PLL'); xlabel('t (s)'); ylabel('amplitude');
legend('true m(t)','PLL \hat{m}(t)');

subplot(3,1,3);
plot(t, freq_vco_Hz - fc); grid on;
title('VCO frequency deviation (Hz)'); xlabel('t (s)'); ylabel('\Delta f (Hz)');

figure; 
plot(t, m, 'LineWidth',1.2); hold on;
plot(t, m_hat, '--'); grid on;
title('Recovered m(t) by PLL'); xlabel('t (s)'); ylabel('amplitude');
legend('true m(t)','PLL \hat{m}(t)');