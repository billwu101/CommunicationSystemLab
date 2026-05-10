clc;   close all;
clear;

% Parameters
fs = 1e6;            % Sampling frequency (Hz)
t = 0:1/fs:0.0025;    
f = 1e3;              % Frequency of sine wave (Hz)
A = 2;               % Amplitude of sine wave
Vref = [-2 0 1];          % Reference voltage

% Input signal (sine wave)
Vin = A * sin(2*pi*f*t);

% Comparator output
Vout = zeros(length(t), length(Vref));  % Initialize output matrix for each reference voltage

for i = 1:length(Vref)
    Vout(:, i) = double(Vin > Vref(i)) * 5;  % Comparator output for each reference voltage
end

figure('Name','Compare');

% Plot comparator output
for i = 1:length(Vref)
    
    subplot(length(Vref), 1, i); % Create a subplot for each reference voltage
    plot(t*1e3, Vin, 'y','LineWidth',1.2);hold on;
    plot(t*1e3, Vout(:, i),'c' ,'LineWidth', 1.2); % Plot each column of Vout
    yline(Vref(i),'g--','LineWidth',1); % Reference line
    xlabel('Time (ms)'); ylabel('Voltage (V)');
    title(['Input Signal and Output Signal for Vref = ' num2str(Vref(i))]);
    legend('Input Signal','Output Signal','Vref');
    ylim([-3 6]);
    grid on;
    
end



