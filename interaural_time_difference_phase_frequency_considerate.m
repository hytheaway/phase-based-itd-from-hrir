s = sofaread("D1_48K_24bit_256tap_FIR_SOFA.sofa");
f0 = 750; % center frequency
q = 500; % bandwidth around f0
phaseUnwrap = true; % bool for strictly wrapped phase (which would be false)

% IR = s.Data.IR;
% fs = s.Data.SamplingRate;
% pos = s.SourcePosition;

IR = s.Numerator;
fs = s.SamplingRate;
pos = s.SourcePosition;

azDeg = pos(:,1);
if size(pos, 2) >= 2
    elDeg = pos(:, 2);
else
    elDeg = zeros(size(azDeg));
end


totalElev = 1e-3;
% idxHor = abs(pos(:,2)) < totalElev;
idxHor = abs(elDeg) < totalElev;
IRh = IR(idxHor, :, :);
% posH = pos(idxHor, :);
% azDeg = posH(:, 1);
azH = azDeg(idxHor);

% [azDeg, sortIdx] = sort(azDeg);
[azH, sortIdx] = sort(azH);
IRh = IRh(sortIdx, :, :);

[Mh, ~, N] = size(IRh);

Nfft = 2^nextpow2(N);
f = (0:Nfft-1).' * (fs/Nfft);

fMin = max(f0 - q, 0);
fMax = min(f0 + q, fs/2);
bandIdx = (f >= fMin) & (f <= fMax);
if ~any(bandIdx)
    error ('No fft bins found in this band. Adjust to center freq. or bandwidth.');
end

H_L = zeros(Mh, Nfft);
H_R = zeros(Mh, Nfft);

for m = 1:Mh
    hl = squeeze(IRh(m,1,:));
    hr = squeeze(IRh(m,2,:));
    H_L(m,:) = fft(hl, Nfft);
    H_R(m,:) = fft(hr, Nfft);
end

% positive freq only
H_L_band = H_L(:, bandIdx);
H_R_band = H_R(:, bandIdx);
fBand = f(bandIdx);

% interaural phase difference for each azi and freq bin
phi_L = angle(H_L_band);
phi_R = angle(H_R_band);
phiIPD = phi_L - phi_R;

% wrap phase to be bounded [-pi, pi]
phiIPD = atan2(sin(phiIPD), cos(phiIPD));

if phaseUnwrap
    for m = 1:Mh
        phiIPD(m,:) = unwrap(phiIPD(m,:));
    end
end

% convert phase diff to itd 
% ITD(f, theta) = phiIPD(f, theta) / (2*pi*f)

fMat = repmat(fBand.', Mh, 1);
ITD_mat = phiIPD ./ (2*pi*fMat);

% average ITD across band
ITD_phase = mean(ITD_mat, 2, 'omitnan');

% compute broadband onset ITD
try
    ITD_onset = interauralTimeDifference(s);
    ITD_onset_h = ITD_onset(idxHor);
    ITD_onset_h = ITD_onset_h(sortIdx);
catch
    haveOnset = false;
end

% plot
figure;
% plot(azDeg, ITD_phase*1e6, 'b-o', 'LineWidth',1.5); hold on;
plot(azH, ITD_phase*1e6, 'b-o', 'LineWidth',1.5); hold on;
if haveOnset
    plot(azH, ITD_onset_h*1e6, 'r--', 'LineWidth',1.2);
    legend('Phase derived ITD', 'Onset ITD (MATLAB)', 'Location', 'Best');
else
    legend('Phase derived ITD', 'Location', 'Best')
end
% plot(azDeg, ITD_onset_h*1e6, 'r--', 'LineWidth',1.2);
[itd, azi] = interauralTimeDifference(s);
plot(azH, (itd*10^6));
xlabel('Azimuth (deg)');
ylabel('ITD (\mus)');
title(sprintf('Phase derived vs. onset ITD (%.0f Hz \\pm %.0f Hz)', f0, q));
grid on;