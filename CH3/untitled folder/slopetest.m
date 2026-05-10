clear; clc; close all;

fs = 1e3;              % sampling rate [Hz]
fc = 60;               % cosine frequency [Hz]
numCycles = 10;        % number of cycles

% Given: fs, fc, numCycles
T = numCycles / fc;
t = 0 : 1/fs : T - 1/fs;
x = cos(2*pi*fc*t);

Ts = 1/fs;
slope = gradient(x, Ts);   % numerical slope (dx/dt)

% Noise tolerance (hysteresis) around zero to avoid chattering
epsZ = 1e-3;       % amplitude deadband around 0
minSlope = 10;     % minimal |slope| to accept an edge (adjust if needed)

% Rising zero-crossings (negative -> positive with positive slope)
risingIdx = find( x(1:end-1) <= -epsZ & x(2:end) >= +epsZ & slope(2:end) > +minSlope ) + 1;

% Falling zero-crossings (positive -> negative with negative slope)
fallingIdx = find( x(1:end-1) >= +epsZ & x(2:end) <= -epsZ & slope(2:end) < -minSlope ) + 1;

% Detected cycle count (use rising edges)
numDetectedCycles = numel(risingIdx);

fprintf('Rising edges (cycles) detected: %d\n', numDetectedCycles);
