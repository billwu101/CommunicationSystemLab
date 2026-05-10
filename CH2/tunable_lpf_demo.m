
% Tuneable (real-time) single-pole LPF with live plots
% y[n] = y[n-1] + alpha*(x[n]-y[n-1]), alpha = 1 - exp(-2*pi*fc/fs)

% Settings
fs   = 48000;               % sample rate (Hz)
T    = 0.1;                 % signal length (s)
t    = (0:1/fs:T-1/fs)';    % time vector

% Test input: DC + low tone + high tone + white noise
f1 = 300; f2 = 5000;        % two tones
x  = 0.3 + sin(2*pi*f1*t) + 0.6*sin(2*pi*f2*t) + 0.15*randn(size(t));

% Initial cutoff
fc0 = 1000;                 % Hz

% Figure & layout
f = figure('Name','Tunable LPF (single-pole)','Color','w','Position',[100 100 1000 700]);

ax1 = subplot(3,1,1); % time domain
ax2 = subplot(3,1,2); % magnitude response
ax3 = subplot(3,1,3); % spectra

% % UI: cutoff slider (log scale) + readout
% uicontrol(f,'Style','text','String','Cutoff (Hz)','Units','normalized',...
%     'Position',[0.80 0.94 0.15 0.035],'BackgroundColor','w','FontWeight','bold');
% sld = uicontrol(f,'Style','slider','Units','normalized','Position',[0.80 0.91 0.15 0.03],...
%     'Min',10,'Max',fs/2*0.95,'Value',fc0,'Callback',@~(o,~)refreshPlots());
% set(sld,'SliderStep',[0.005 0.05]); % finer control
% txt = uicontrol(f,'Style','text','Units','normalized','Position',[0.80 0.87 0.15 0.03],...
%     'String','', 'BackgroundColor','w');

% Pre-create lines for faster updates
ln_in  = plot(ax1, t, x, 'y', 'LineWidth',0.8); hold(ax1,'on');
ln_out = plot(ax1, t, zeros(size(t)), 'b', 'LineWidth',1.2);
grid(ax1,'on'); xlabel(ax1,'Time (s)'); ylabel(ax1,'Amplitude');
title(ax1,'Time Domain: input (gray) vs LPF output (blue)');

Nw = 4096;
[Hw, w] = deal([], []);
ln_mag = plot(ax2, [0 1], [0 0], 'LineWidth',1.3); grid(ax2,'on');
xlabel(ax2,'Frequency (Hz)'); ylabel(ax2,'|H(e^{j\omega})| (dB)');
title(ax2,'Theoretical Magnitude Response (single-pole)');

% Spectra
nfft = 2^nextpow2(length(t));
ff   = fs*(0:(nfft/2))/nfft;
Xmag = abs(fft(x, nfft))/length(x);
ln_X = plot(ax3, ff, 20*log10(Xmag(1:nfft/2+1)+1e-12), 'Color',[.5 .5 .5]); hold(ax3,'on');
ln_Y = plot(ax3, ff, zeros(size(ff)), 'b', 'LineWidth',1.2);
grid(ax3,'on'); xlabel(ax3,'Frequency (Hz)'); ylabel(ax3,'Magnitude (dBFS)');
title(ax3,'Amplitude Spectrum: input (gray) vs LPF output (blue)');

% refreshPlots(); % initial render
% 
% % Nested: compute LPF and refresh all plots
% function refreshPlots()
%     fc = max(10, min(get(sld,'Value'), fs/2*0.95));
%     set(txt,'String',sprintf('fc = %.1f Hz', fc));
% 
%     % Convert fc -> alpha
%     alpha = 1 - exp(-2*pi*fc/fs);
% 
%     % Filter (causal, single pass)
%     y = zeros(size(x));
%     y(1) = alpha*x(1);
%     for n=2:numel(x)
%         y(n) = y(n-1) + alpha*(x(n)-y(n-1));
%     end
% 
%     % Update time-domain output
%     set(ln_out, 'YData', y);
% 
%     % Update theoretical magnitude response of single-pole LPF:
%     % H(e^jw) = alpha / (1 - (1-alpha) e^{-jw}), w = 2*pi*f/fs
%     Nw = 4096;
%     fgrid = linspace(1e-3, fs/2, Nw);
%     w     = 2*pi*fgrid/fs;
%     z     = exp(-1j*w);
%     H     = alpha ./ (1 - (1-alpha).*z);
%     set(ln_mag, 'XData', fgrid, 'YData', 20*log10(abs(H)+1e-12));
%     xlim(ax2,[1 fs/2]); ylim(ax2,[-80 5]);
% 
%     % Update spectra
%     Ymag = abs(fft(y, nfft))/length(y);
%     set(ln_Y, 'XData', ff, 'YData', 20*log10(Ymag(1:nfft/2+1)+1e-12));
%     ylim(ax3,[-120 10]); xlim(ax3,[1 fs/2]);
% 
%     % Annotate cutoff on plots
%     addVLine(ax2, fc);
%     addVLine(ax3, fc);
%     drawnow;
% end
% 
% % Helper: vertical line at fc
% function addVLine(ax, f0)
%     % remove prior lines with tag
%     delete(findall(ax,'Tag','vline_fc'));
%     yl = ylim(ax);
%     line(ax, [f0 f0], yl, 'LineStyle','--', 'Color',[0 0 0], 'LineWidth',1, 'Tag','vline_fc');
% end

