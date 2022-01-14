% Trapezoidal filter (adopted from Don Clyde and Shakhzod Takhirov shaking table input development file)

function [accel,tfilt] = trapfilter(a,dt,fil)

% Inputs
% a: raw acceleration (cm/s2)
% dt: time step (sec)
% fil: [fhcut,fhcor,flcor,flcut]
% fhcut: high pass filter cutoff (Hz)
% fhcor: high pass filter corner (Hz)
% flcor: low pass filter corner (Hz)
% flcut: low pass filter corner (Hz)

% Outputs
% accel: filtered acceleration
% tfilt: corresponding time vector

x = a;
% format bank
fhcut = fil(1);
fhcor = fil(2);
flcor = fil(3);
flcut = fil(4);
% If the acceleration data is in a format written by rows of more than one column 
% then convert to a single column vector.

d = size(x);
x = reshape(x',[d(1)*d(2),1]);

npts = length(x);
npts = floor(npts/2)*2;
x = x(1:npts);

% convert to frequency domain
%
fd = fft(x);
%
% Highpass filter
%
nfcut = ceil(fhcut*dt*npts);
nfcor = ceil(fhcor*dt*npts);
flat = npts -2*nfcor;
tran = nfcor - nfcut;
if tran == 0
   flt = [zeros(1,nfcut),ones(1,flat),zeros(1,nfcut)];
   else
   flt = [zeros(1,nfcut),linspace(0,1,tran),ones(1,flat),linspace(1,0,tran),zeros(1,nfcut)];
end
flt = flt';
fd = fd.*flt;
%
% Lowpass filter
%
nfcor = ceil(flcor*dt*npts);
nfcut = ceil(flcut*dt*npts);
flat = npts -2*nfcut;
tran = nfcut - nfcor;
if tran == 0
   flt = [ones(1,nfcor),zeros(1,flat),ones(1,nfcor)];
   else
   flt = [ones(1,nfcor),linspace(1,0,tran),zeros(1,flat),linspace(0,1,tran),ones(1,nfcor)];
end
flt = flt';
fd = fd.*flt;
%
% Compute acceleration in time domain and compute the corresponding time
% vector
%
a = ifft(fd);
accel = real(a);
%accel = nwin.*a;
tfilt = linspace(0,npts*dt,npts);