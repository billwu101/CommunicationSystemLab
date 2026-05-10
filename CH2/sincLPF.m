close all; clear; clc;

% 輸入音檔

fs   = 1e6;               % sample rate for discrete-time test
Ts   = 1/fs;
fc = 1.5e3;

f_list = [1e3, 1.5e3 ,3e3,5e3];


tC = cell(numel(f_list),1);
xC = cell(numel(f_list),1);
yC = cell(numel(f_list),1);

% figure;
% 
% [hL wL] = freqz(Lowpass,128) ;
% 
% subplot(411);plot(wL/pi*4000,20*log10(abs(hL)),'-*');axis([0,4000,-60,5]);
% title('lowpass filter');

figure('Name','Discrete-time: Filtering demo');

for i = 1:length(f_list)

    Ti = 50 / f_list(i);
    tC{i} = 0:Ts:Ti;

    xC{i} = sin(2* pi * f_list(i) * tC{i});         % Comparator output for each reference voltage
    
    n = -fc / 2:fc / 2;
    
    h = 2*fc/fs * sinc(2*fc/fs * n);
    
    %yC{i} = filter(Lowpass, xC{i});
    %yC{i} = lsim(Hlp_z, xC{i}, tC{i});
    yC{i} = conv(xC{i}, h, 'same');

    subplot(length(f_list),1,i);
    plot(tC{i}, xC{i}, 'y', 'LineWidth',1.2); hold on;
    plot(tC{i}, yC{i}, 'c','LineWidth',1.2);
    grid on;
    ylabel('Voltage');
    title(['Input Signal vs Output f = ' num2str(f_list(i) / 1e3) 'kHz']);
    legend('Input' , 'Output');
    xlim([0,20 / f_list(i)]);

end

