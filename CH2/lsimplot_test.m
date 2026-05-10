clc;clear;
% 建立一個傳遞函數
sys = tf(1, [1 1]);  % H(s) = 1 / (s+1)

% 定義時間與輸入
t = 0:0.01:10;
u = sin(t);

% 繪製系統響應

figure('Name','1');

[y, t_out, x] = lsim(sys, u, t);  % Simulated response
plot(t_out,u , 'Color', [0.5 0.5 0.5]); hold on;
plot(t_out, y,'c');
xlabel('Time (s)');
ylabel('Response');
title('System Response to Sinusoidal Input');
ylim([-1 1]);  % Set y-axis limits to display y = 1 ~ -1
grid on;

figure('Name','2');

lsimplot(sys, u, t);

grid on;
