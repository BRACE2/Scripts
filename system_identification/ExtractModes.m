function [freqdmp, modeshape, sj1, v, d] = ExtractModes(dt, A, B, C, D)
n = size(A,1);
m = size(C,1);

[v, d] = eig(A);        % eigenvectors (d) & eiegenvalues (v) of the matrix A
cnd = condeig(A);       % condeig(A): gives a vector of condition numbers for the eigenvalues of A
kit = log(diag(d));     % logarithm of the eigenvalues

% a) Determination of modal frequencies (Eqs. 3.46 & 3.39)
sj1 = kit./dt;          % dt is the time step
freq1 = ((sj1.*conj(sj1)).^0.5)/(2*pi);

% selection of proper roots
if freq1(1,1) == freq1(2,1)
    freq1(1,2) = 1;
end
if freq1(n,1) == freq1(n-1,1)
    freq1(n,2) = 1;
end
for hw = 2:n-1
    if freq1(hw,1) == freq1(hw+1,1) | freq1(hw,1) == freq1(hw-1,1);
        freq1(hw,2) = 1;
    end
end
% b) Determination of damping ratios (Eqs. 3.46 & 3.39)
damp1 = -(real(sj1))./(2*pi*freq1);
% Represent the identified frequency & damping information of the proper roots in a matrix
koun = 1;
for lk = 1:2:n                         % from 1 to the model order, n
    if freq1(lk,2) == 1                % 1 indicates that it is a proper root
        freqdmp(koun,1) = freq1(lk);   % first column: identified frequency
        freqdmp(koun,2) = damp1(lk);   % second column: identified damping ratio
        freqdmp(koun,3) = lk;          % third column: model order index (1:n)
        freqdmp(koun,4) = cnd(lk);     % condition number of the eigenvalue
        koun = koun+1;
    end
end

% c) Determination of mode shapes
modes_raw = C*v;              % mode shapes (Eq. 3.40), v is the eigenvectors of matrix A

kss = size(freqdmp,1);

%extract mode shapes from mod corresponding to a frequency
for q = 1:kss
    modeshape(1:m,q) = modes_raw(1:m,freqdmp(q,3));
end

for q = 1:kss
    [mit, om] = max(abs(real(modeshape(:,q))));
    modeshape(:,q) = real(modeshape(:,q))*1/mit*sign(real(modeshape(om,q)));
end

