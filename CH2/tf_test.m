clear; clc;

a = realp('a',10);

numerator = a;
denominator = [1,a];
F = tf(numerator,denominator);


% Time vector
t = 0:1e-3:1;

[y_imp,  t_imp]  = impulse(F, t);

% figure;
% 
% plot(t_imp,  y_imp,  'g', 'LineWidth', 2);
% grid on;
% xlabel('Time (s)');
% ylabel('Response');
% title('Step vs Impulse Response of G(s) = 1/(s+1)');

% --- Time-domain: filter a test sine + DC offset ---
fs   = 100e6;               % sample rate for discrete-time test
Ts   = 1/fs;

f_list = [1e3, 50e3 ,100e3];
tC = cell(numel(f_list),1);
xC = cell(numel(f_list),1);
yC = cell(numel(f_list),1);

figure('Name','Discrete-time: Filtering demo');

for i = 1:length(f_list)

    Ti = 50 / f_list(i);
    tC{i} = 0:Ts:Ti;

    xC{i} = sin(2* pi * f_list(i) * tC{i});         % Comparator output for each reference voltage
    %yC{i} = lsim(FIR, xC{i}, tC{i});
    yC{i} = filter(FIR, xC{i});

    subplot(length(f_list),1,i);
    plot(tC{i}, xC{i}, 'y', 'LineWidth',1.2); hold on;
    plot(tC{i}, yC{i}, 'c','LineWidth',1.2);
    grid on;
    ylabel('Voltage'); 
    title(['Input Signal vs Output f = ' num2str(f_list(i) / 1e3) 'kHz']);
    legend('Input' , 'Output');
    xlim([0,20 / f_list(i)]);

end