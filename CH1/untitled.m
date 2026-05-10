
clc;close all;clear;

fs = 1000;                          % sampling rate (Hz)
t  = (0:1/fs:1).';
x  = cos(2*pi*50*t) .* (1+0.5*cos(2*pi*2*t));  % AM test signal

z  = hilbert(x);                    % analytic signal: x + j*H{x}
env = abs(z);                       % envelope
phi = angle(z);                     % instantaneous phase (radians)
f_inst = [NaN; diff(unwrap(phi))] * fs/(2*pi);  % inst. frequency (Hz)

% Plot
figure;
subplot(3,1,1); plot(t,x,t,env,'LineWidth',1); grid on; legend('x','envelope');
subplot(3,1,2); plot(t,phi); grid on; ylabel('phase (rad)');
subplot(3,1,3); plot(t,f_inst); grid on; ylabel('f_{inst} (Hz)'); xlabel('time (s)');
