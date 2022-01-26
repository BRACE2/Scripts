function [freqdmpSRIM,modeshapeSRIM,RMSEpredSRIM] = SRIM(dati, dato, config)
%%% Description of the Methodology:
% More information on SRIM algorithm can be found in Sections 3.4.4 & 3.4.5 of (Arici & Mosalam, 2006).
% Equations below refer to this report. SRIM is a MIMO SI method that is based on state space identification
% using least squares and consists of the following steps:
% 1. Data pre-processing (baseline correction, filtering & decimation). Same as in OKID-ERA-DC.
% 2. Represent the ouput vector in terms of input and state vectors, Eq. (3.57), which is broken into these 6 steps:
% 2a. Determine output (y) & input (u) vectors [Eqs. 3.58 & 3.60].
% 2b. Compute the correlation terms & the coefficient matrix (Eqs. 3.68 & 3.69).
% 2c. Obtain observability matrix using full or partial decomposition (Eqs. 3.72 & 3.74).
% 2d. Use the observability matrix to compute system matrices A, B & C, in which modal information is embedded.
% 2e. Obtain the modal information from matrices A, B & C.
% 2f. Spatial & temporal validation of the identified modes.
% 2g. Back calculate (estimate) the output accelerations with the state-space system &
%     check against the actual output accelerations.
% Notes: Computation of B & D matrices take very long time (not possible to get a result until now)
% becuase of the excessive matrix operations in lines 944-950. Matrices B & D are not needed for computation of
% periods, damping ratios, or mode shapes. However, they are needed for part of step 2f and the entire step 2g.
% Therefore, these steps are not pursued. Relevant compuations are left commented out for now in case we find
% efficient ways of computing these later.
%%KKKKK
% Lines between these can be commented. But for now they are uncommented for testing
%%KKKKK
%%%

% Modelparameters
dn = config.dn;
to = config.to;
dt = to;
%v  = config.eig_v;
p = config.p;         % # steps used for the identification. Referred to as the prediction horizon in literature
n1 = config.orm;      % Order of the model. # of computed and plotted modes depend on orm.

%For orm = 2, one mode is found, for orm = 4, two modes are found.
%For case 1, one mode is transverse & the other is torsion.
%For all other cases, the second mode is a higher mode.
%Sometimes higher orm still gives fewer modes, e.g. orm = 8 for case 1 gives
%three modes, but one of them is invalid according to the EMAC & MPC criteria.
%same orm in OKID-ERA-DC is used. It can be changed if needed.

% Important output variables:
%  1. freqdampSRIM variable is a matrix that includes the information of identified
%     frequencies, damping ratios & validation of the modes with MPC & EMAC criteria.
%     Each row of freqdamp corresponds to a mode. Columns are as follows:
%     1)frequency, 2)damping ratio, 3)order index, 4)condition number, 5)MPC.
%     If values in columns 5 is > 0.5, identified mode is valid.
%  2. modeshapeSRIM stores the mode shape information for identified modes.
%  3. RMSEpredSRIM: root mean square error of the predicted output from
%     identified parameters with respect to the actual output (currently
%     commented out).
%
%% 2a. Compute y (output) and u (input) vectors (Eqs. 3.58 & 3.60)

% Note that main Step 2 develops Eq. 3.57. Therefore, it is not part of the code.
% Accordingly, the code continues with Step 2a to compute the output & input vectors.

% Calculate the usable size of the data matrix
%dn = size(dat,1)/div;       % total # time steps after decimating
nsizS = dn-1-p+2;

temsiz = size(dato);
temsizi = size(dati);
m = temsiz(2);              % # of columns of dato = number of output channels
l = temsiz(1);              % # of rows of dato = # of rows of dati = # of acceleration samples per channel
r = temsizi(2);             % # of columns of dati = number of input channels
ypS = zeros(r*p,nsizS);     % r is the number of input channels (computed with OKID-ERA-DC)
%p is the number of steps used for the identification. It is an input parameter of SRIM
upS = zeros(r*p,nsizS);

% Compute y (output) & u (input) vectors (Eqs. 3.58 & 3.60)
for b = 1:p
    ypS((b-1)*m+1:b*m,1:nsizS) = dato((b-1)+1:nsizS+(b-1), :)';
    upS((b-1)*r+1:b*r,1:nsizS) = dati((b-1)+1:nsizS+(b-1), :)';
end

%% 2b. Compute the correlation terms and the coefficient matrix (Eqs. 3.68 & 3.69).

% Compute the correlation terms (Eq. 3.68)
Ryy = ypS*ypS'/nsizS;
Ruu = upS*upS'/nsizS;
Ruy = upS*ypS'/nsizS;

%Compute the correlation matrix (Eq. 3.69)
Rhh = Ryy - Ruy'*(Ruu\Ruy);

%% 2c. Obtain observability matrix using full or partial decomposition (Eqs. 3.72 & 3.74).

% Obtain observability matrix using full or partial decomposition.
% Full decomposition is used for the rest of the computations.
% Partial decomposition equations are available. They are commented out.

% Full Decomposition Method
[un1,s1,uo1] = svd(Rhh,0);               % Eq. 3.74
Op1 = un1(:,1:n1);                       % Eq. 3.72

% Partial Decomposition Method
%%KKKKK
[un2,s2,uo2] = svd(Rhh(:,1:(p-1)*m),0);
Op2 = un2(:,1:n1);
%%KKKKK

%% 2d. Use the observability matrix to compute system matrices A, B & C, in which modal information is embedded.

% Determine the system matrices A & C (1 & 2 indicate the ones corresponding
% to full & partial decomposition, respectively. 2 is commented out)
A1 = lsqminnorm(Op1(1:(p-1)*m,:), Op1(m+1:p*m,:));
%%KKKKK
%A2 = lsqminnorm(Op2(1:(p-1)*m,:), Op2(m+1:p*m,:));
%%KKKKK
C1 = Op1(1:m,:);
%%KKKKK
%C2 = Op2(1:m,:);
%%KKKKK

%% Note: A2 & C2 not used herein

% Computation of system matrices B & D
% Note that these computations are commented out as it is not possible to compute B & D
% because of excessive computation time

% Output Error Minimization
% Setting up the fi matrix
%%KKKKK
fi = zeros(m*nsizS, n1+m*r+n1*r);
A_p = A1;
CA_powers = zeros(m, size(A1,2), 1+nsizS);
CA_powers(:,:,1) = C1*A_p;
for pwr = 1:nsizS
    A_p = A1*A_p;
    CA_powers(:,:,pwr+1) =  C1*A_p;
end

%
% First block column of fi
fi(1:m,1:n1) = C1;
for df = 2:nsizS
    fi((df-1)*m+1:df*m,1:n1) = CA_powers(:,:,df-1);
end
%
% Second block column of fi
Imm = speye(m,m);
for df = 1:nsizS
    fi((df-1)*m+1:df*m,n1+1:n1+m*r) = kron(dati(df,:),Imm);
end
%
% Third block column of fi
In1n1 = speye(n1,n1);
cc = n1+m*r+1;
dd = n1+m*r+n1*r;
fi3 = zeros(m, dd-cc+1, nsizS-1);

parfor df = 2:nsizS
    a = (df-1)*m+1;
    b = df*m;
    fi3(:,:,df) = block_3(df, m, CA_powers, dati, n1, r, C1);
end

for df = 2:nsizS
    a = (df-1)*m+1;
    b = df*m;
    fi(a:b,cc:dd) = fi3(:, :, df);
end

%
dattemp = dato(1:nsizS,:)';
y = dattemp(:);
%
teta = lsqminnorm(fi,y);

x0 = teta(1:n1);
dcol = teta(n1+1:n1+m*r);
bcol = teta(n1+m*r+1:n1+m*r+n1*r);
%
n = n1;
D = zeros(m,r);
B = zeros(n,r);
% Obtain D
for wq = 1:r
    D(:,wq) = dcol((wq-1)*m+1:wq*m);
end
%
for ww = 1:r
    B(:,ww) = bcol((ww-1)*n+1:ww*n);
end
%%KKKKK

%% 2e. Obtain the modal information from the system matrices A & C
% This includes determination of: a) modal frequencies, b) damping ratios & c) mode shapes
[freqdmpSRIM, modeshapeSRIM, sj1S, vS] = ExtractModes(dt, A1, B, C1, D);
% c) Determination of mode shapes
mod = C1*vS;                % mode shapes (Eq. 3.40), v is the eigenvectors of matrix A
%%KKKKK
%inm = v\B;                 % initial modal contribution
%%KKKKK

kss = size(freqdmpSRIM,1);

%% 2f. Validation Analysis

% Two criteria are used for selection of identified genuine modes, in terms of spatial & temporal consistency.
% a) Modal Phase Collinearity (MPC) testing spatial consistency of identification results.
%    Modes having MPC value above 0.5 (mpc parameter below) are considered as genuine modal quantities.
% b) Extended Modal Amplitude Coherence (EMAC), evaluates temporal consistency of the identification results.
%    Both output EMAC & input EMAC can be computed. Input EMAC requires the controllability matrix.
%    Because the controllability matrix is not estimated by all considered SI methods,
%    this criterion is computed, but not used.
%    Modes with output EMAC values < 0.5 are considered spurious & therefore not reported.

% a) Modal Phase Collinearity (MPC) [Eqs. 3.85-3.87]
for q = 1:n
    a = real(mod(:,q));
    b = imag(mod(:,q));
    sxx(:,q) = a'*a;
    syy(:,q) = b'*b;
    sxy(:,q) = a'*b;
    nu(q) = (syy(:,q)-sxx(:,q))/(2*sxy(:,q));
    lam(1,q) = (sxx(:,q)+syy(:,q))/2+sxy(:,q)*(nu(q)^2+1)^0.5;
    lam(2,q) = (sxx(:,q)+syy(:,q))/2-sxy(:,q)*(nu(q)^2+1)^0.5;
    mpc(q) = ((lam(1,q)-lam(2,q))/(lam(1,q)+lam(2,q)))^2;
end

% b) Extended Modal Amplitude Coherence (EMAC)

% Only EMAC Output is computed as there is no Controllability Matrix

% Note that the computations are commented out as the matrix B is needed

%%KKKKK
plin = Op1*vS;     % Observability Matrix used for the output-EMAC
lamb = vS\A1*vS;
bkh = vS\B;
% Pick the last block row
pto = plin((p-1)*m+1:m*p,:); % the identified value at T0
for ds = 1:n
    ptop(:,ds) = mod(:,ds)*exp(sj1S(ds)*to*(p-1));
end
% Computation of rij
for qa = 1:n
    for qz = 1:m
        Rij(qa,qz) = min((abs(pto(qz,qa))/abs(ptop(qz,qa))),(abs(ptop(qz,qa))/abs(pto(qz,qa))));
        Pij = angle(pto(qz,qa)/ptop(qz,qa));
        Pijn(qa,qz) = Pij;
        if abs(Pij) <= pi/4
            Wij(qa,qz) = 1-abs(Pij)/(pi/4);
        else
            Wij(qa,qz) = 0;
        end
        emaco(qa,qz) = Rij(qa,qz)*Wij(qa,qz);
    end
end
% Computation of final emac
for xc = 1:n
    % Weight for emaco
    sumo = 0;
    for la = 1:m
        sumo = emaco(xc,la)*abs(mod(la,xc))^2+sumo;
    end
    emacof(xc) = sumo/((mod(:,xc)'*mod(:,xc)));
    emac(xc) = emaco(xc);
end
%%KKKKK

% Add the MPC to the matrix freqdampSRIM
for lih = 1:size(freqdmpSRIM,1)
    freqdmpSRIM(lih,5) = emacof(freqdmpSRIM(lih,3));
    freqdmpSRIM(lih,6) = mpc(freqdmpSRIM(lih,3));
    if freqdmpSRIM(lih,5)>0.5 && freqdmpSRIM(lih,6)>0.5
        validationm = ' valid';
    else
        validationm = ' not valid';
    end
    scroutput = strcat('Mode',num2str(lih), ...
        ': Output EMAC =  ',num2str(freqdmpSRIM(lih,5)),...
        ', MPC =  ',num2str(freqdmpSRIM(lih,6)),...
        ' -->',' SRIM Identified Mode ',...
        num2str(lih), ' is',validationm);
    sprintf(scroutput)
end

%% 2g. Back calculate (estimate) output accelerations with state-space system &
%%     check against actual output accelerations

% Note that the computations are commented out as the matrix B is needed

% Prediction using state space model
%%KKKKK
ms1 = modstruc(A1,B,C1,D,zeros(n,m),x0);
th1 = ms2th(ms1,'d');
[e,r] = resid([dato dati],th1);
[simy] = idsim([dati],th1);                % simy represents the estimated accelerations
%
for i = 1:m
    temsum = sum((dato(:,i)-simy(:,i)).^2);
    Jm(i) = temsum/(sum(dato(:,i).^2));     %Root mean square error of estimated accelerations
end

RMSEpredSRIM = sum(Jm)/m;
%%KKKKK

function fi = block_3(df, m, CA_powers, dati, n1, r, C1)
    In1n1 = speye(n1,n1);
    fi = C1*kron(dati(df-1,:),In1n1);
    for nmf = 1:df-2
        fi = fi + CA_powers(:,:,df-nmf-1)*kron(dati(nmf,:),In1n1);
    end

