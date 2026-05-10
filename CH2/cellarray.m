clc;clear;

fc = 1e3;

fs   = 100*fc;               % sample rate for discrete-time test
Ts   = 1/fs;

f_list = [0.2*fc, 5*fc];
tC = cell(numel(f_list),1);
xC = cell(numel(f_list),1);
yC = cell(numel(f_list),1);

for i = 1:numel(f_list)
    Ti = 50 / f_list(i);
    tC{i} = 0:Ts:Ti;
    xC{i} = 0.5 + sin(2*pi*f_list(i)*tC{i});  % 單一頻率 + DC
end
