import multiprocessing
from functools import partial

import numpy as np
from tqdm import tqdm
import jax
import jax.numpy as jnp

import os
# after importing numpy, reset the CPU affinity of the parent process so
# that it will use all cores
os.system("taskset -p 0xff %d" % os.getpid())


linsolve = np.linalg.solve
lsqminnorm = lambda *args: np.linalg.lstsq(*args, rcond=None)[0]

def _srim(dati, dato, config):
#%% Description of the Methodology:
# More information on SRIM algorithm can be found in Sections 3.4.4 & 3.4.5 of (Arici & Mosalam, 2006).
# Equations below refer to this report. SRIM is a MIMO SI method that is based on state space identification
# using least squares and consists of the following steps:
#
# 2a. Determine output (y) & input (u) vectors [Eqs. 3.58 & 3.60].
# 2b. Compute the correlation terms & the coefficient matrix (Eqs. 3.68 & 3.69).
# 2c. Obtain observability matrix using full or partial decomposition (Eqs. 3.72 & 3.74).
# 2d. Use the observability matrix to compute system matrices A, B & C, in which modal information is embedded.
# 2e. Obtain the modal information from matrices A, B & C.
# 2f. Spatial & temporal validation of the identified modes.
# 2g. Back calculate (estimate) the output accelerations with the state-space system &
#     check against the actual output accelerations.
#
# Notes: Computation of B & D matrices take very long time (not possible to get a result until now)
# becuase of the excessive matrix operations in lines 944-950. Matrices B & D are not needed for computation of
# periods, damping ratios, or mode shapes. However, they are needed for part of step 2f and the entire step 2g.
# Therefore, these steps are not pursued. Relevant compuations are left commented out for now in case we find
# efficient ways of computing these later.
#
# For orm = 2, one mode is found, for orm = 4, two modes are found.
# For case 1, one mode is transverse & the other is torsion.
# For all other cases, the second mode is a higher mode.
# Sometimes higher orm still gives fewer modes, e.g. orm = 8 for case 1 gives
# three modes, but one of them is invalid according to the EMAC & MPC criteria.
# same orm in OKID-ERA-DC is used. It can be changed if needed.
#
# Important output variables:
#  1. freqdampSRIM variable is a matrix that includes the information of identified
#     frequencies, damping ratios & validation of the modes with MPC & EMAC criteria.
#     Each row of freqdamp corresponds to a mode. Columns are as follows:
#     1)frequency, 2)damping ratio, 3)order index, 4)condition number, 5)MPC.
#     If values in columns 5 is > 0.5, identified mode is valid.
#  2. modeshapeSRIM stores the mode shape information for identified modes.
#  3. RMSEpredSRIM: root mean square error of the predicted output from
#     identified parameters with respect to the actual output (currently
#     commented out).
#

    dn = config.dn
    to = config.to
    dt = to
    p = config.p          # # steps used for the identification. Referred to as the prediction horizon in literature
    n1 = config.orm       # Order of the model. # of computed and plotted modes depend on orm.


#% 2a. Compute y (output) and u (input) vectors (Eqs. 3.58 & 3.60)

# Note that main Step 2 develops Eq. 3.57. Therefore, it is not part of the code.
# Accordingly, the code continues with Step 2a to compute the output & input vectors.

# Calculate the usable size of the data matrix
#dn = size(dat,1)/div;       % total # time steps after decimating
    nsizS = dn-1-p+2

    l,m = dato.shape
    _,r = dati.shape

    ypS = np.zeros((r*p,nsizS))     # r is the number of input channels (computed with OKID-ERA-DC)
#p is the number of steps used for the identification. It is an input parameter of SRIM
    upS = np.zeros((r*p,nsizS))

# Compute y (output) & u (input) vectors (Eqs. 3.58 & 3.60)
    for b in range(p):
        ypS[b*m:(b+1)*m,:nsizS+1] = dato[b:nsizS+b, :].T
        upS[b*r:(b+1)*r,:nsizS+1] = dati[b:nsizS+b, :].T


#% 2b. Compute the correlation terms and the coefficient matrix (Eqs. 3.68 & 3.69).

# Compute the correlation terms (Eq. 3.68)
    Ryy = ypS@ypS.T/nsizS
    Ruu = upS@upS.T/nsizS
    Ruy = upS@ypS.T/nsizS

#Compute the correlation matrix (Eq. 3.69)
    Rhh = Ryy - Ruy.T*linsolve(Ruu,Ruy)

#% 2c. Obtain observability matrix using full or partial decomposition (Eqs. 3.72 & 3.74).

# Obtain observability matrix using full or partial decomposition.
# Full decomposition is used for the rest of the computations.
# Partial decomposition equations are available. They are commented out.

# Full Decomposition Method
    un1,*_ = np.linalg.svd(Rhh,0)                  # Eq. 3.74
    Op1 = un1[:,:n1]                         # Eq. 3.72

#% 2d. Use the observability matrix to compute system matrices A, B & C, in which modal information is embedded.

# Determine the system matrices A & C (1 & 2 indicate the ones corresponding
# to full & partial decomposition, respectively. 2 is commented out)
    A1 = lsqminnorm(Op1[:(p-1)*m,:], Op1[m:p*m+1,:])
    #C1 = jnp.asarray(Op1[:m,:])
    C1 = Op1[:m,:]
#%KKKKK
# Partial Decomposition Method
    un2,*_ = np.linalg.svd(Rhh[:,:(p-1)*m+1],0)
#A2 = lsqminnorm(Op2(1:(p-1)*m,:), Op2(m+1:p*m,:))
    Op2 = un2[:,:n1]
#C2 = Op2(1:m,:)
#%KKKKK


# Computation of system matrices B & D
# Note that these computations are commented out as it is not possible to compute B & D
# because of excessive computation time

# Output Error Minimization
# Setting up the fi matrix
#%KKKKK
    fi  = np.zeros((m*nsizS, n1+m*r+n1*r))
    A_p = A1
    CA_powers = np.zeros((1+nsizS, m, A1.shape[1]))
    CA_powers[0, :, :] = C1@A_p
    for pwr in range(nsizS):
        A_p = A1@A_p
        CA_powers[pwr+1,:,:] =  C1@A_p
    #CA_powers = jnp.asarray(CA_powers)


#
# First block column of fi
    fi[:m,:n1] = C1
    for df in range(1,nsizS):
        fi[df*m:(df+1)*m,:n1] = CA_powers[df-1,:,:]

#
# Second block column of fi
    Imm = np.eye(m)
    for i in range(nsizS):
        fi[i*m:(i+1)*m,n1:n1+m*r] = np.kron(dati[i,:],Imm)

#
# Third block column of fi
    In1n1 = np.eye(n1)
    cc = n1+m*r+1
    dd = n1+m*r+n1*r
    #fi3 = np.zeros((nsizS, m, dd-cc+1))

    krn = np.array([np.kron(dati[i,:],In1n1) for i in range(nsizS)])

    with multiprocessing.Pool(6) as pool:
        for res,df in tqdm(
                pool.imap_unordered(
                    partial(block_3,CA_powers=CA_powers,m=m,C1=C1,krn=krn),#,out=fi[:,cc-1:dd]),
                    range(nsizS),
                    200
                ),
                total = nsizS
            ):
            fi[df*m:(df+1)*m,cc-1:dd] = res


    dattemp = dato[:nsizS,:].T
    y = dattemp.flatten()

    teta = lsqminnorm(fi,y)

    x0 = teta[:n1]
    dcol = teta[n1:n1+m*r]
    bcol = teta[n1+m*r:n1+m*r+n1*r]
#
    n = n1
    D = np.zeros((m,r))
    B = np.zeros((n,r))
# Obtain D
    for wq in range(r):
        D[:,wq] = dcol[wq*m:(wq+1)*m]

    for ww in range(r):
        B[:,ww] = bcol[ww*n:(ww+1)*n]

    return A1,B,C1,D
    #return locals()

#PY
# #% 2e. Obtain the modal information from the system matrices A & C
# # This includes determination of: a) modal frequencies, b) damping ratios & c) mode shapes
#     freqdmpSRIM, modeshapeSRIM, sj1S, vS = ExtractModes(dt, A1, B, C1, D)
# # c) Determination of mode shapes
#     mod = C1@vS                 # mode shapes (Eq. 3.40), v is the eigenvectors of matrix A
# 

#% 2f. Validation Analysis

# Two criteria are used for selection of identified genuine modes, in terms of spatial & temporal consistency.
# a) Modal Phase Collinearity (MPC) testing spatial consistency of identification results.
#    Modes having MPC value above 0.5 (mpc parameter below) are considered as genuine modal quantities.
# b) Extended Modal Amplitude Coherence (EMAC), evaluates temporal consistency of the identification results.
#    Both output EMAC & input EMAC can be computed. Input EMAC requires the controllability matrix.
#    Because the controllability matrix is not estimated by all considered SI methods,
#    this criterion is computed, but not used.
#    Modes with output EMAC values < 0.5 are considered spurious & therefore not reported.

# a) Modal Phase Collinearity (MPC) [Eqs. 3.85-3.87]
#Py
##    for q in range(n):
##        a = real(mod[:,q])
##        b = imag(mod[:,q])
##        sxx[:,q] = a.T*a
##        syy[:,q] = b.T*b
##        sxy[:,q] = a.T*b
##        nu[q] = (syy[:,q]-sxx[:,q])/(2*sxy[:,q])
##        lam[1,q] = (sxx[:,q]+syy[:,q])/2+sxy[:,q]*(nu(q)**2+1)**0.5
##        lam[2,q] = (sxx[:,q]+syy[:,q])/2-sxy[:,q]*(nu(q)**2+1)**0.5
##        mpc[q] = ((lam[0,q]-lam[1,q])/(lam[0,q]+lam[1,q]))**2


# b) Extended Modal Amplitude Coherence (EMAC)

# Only EMAC Output is computed as there is no Controllability Matrix

# Note that the computations are commented out as the matrix B is needed

#%KKKKK
##PY
##    plin = Op1@vS                # Observability Matrix used for the output-EMAC
##    lamb = linsolve(vS,A1)*vS
##    bkh = linsolve(vS,B)
### Pick the last block row
##    pto = plin((p-1)*m+1:m*p,:)  # the identified value at T0
##    for ds in range(n):
##        ptop[:,ds] = mod[:,ds]*exp(sj1S(ds)*to*(p-1))
##
### Computation of rij
##    for qa in range(n):
##        for qz in range(m):
##            Rij(qa,qz) = min((abs(pto(qz,qa))/abs(ptop(qz,qa))),(abs(ptop(qz,qa))/abs(pto(qz,qa))))
##            Pij = angle(pto(qz,qa)/ptop(qz,qa))
##            Pijn(qa,qz) = Pij
##            if abs(Pij) <= pi/4:
##                Wij[qa,qz] = 1-abs(Pij)/(pi/4)
##            else:
##                Wij[qa,qz] = 0
##
##            emaco[qa,qz] = Rij[qa,qz]*Wij[qa,qz]
##
##
### Computation of final emac
##    for xc in range(n):
##        # Weight for emaco
##        sumo = 0.0
##        for la in range(m):
##            sumo = emaco(xc,la)*abs(mod(la,xc))**2+sumo
##        emacof[xc] = sumo/((mod[:,xc].T*mod[:,xc]))
##        emac[xc] = emaco[xc]
#%KKKKK

# Add the MPC to the matrix freqdampSRIM
#    for lih = 1:size(freqdmpSRIM,1)
#        freqdmpSRIM[lih,5] = emacof(freqdmpSRIM(lih,3))
#        freqdmpSRIM[lih,6] = mpc(freqdmpSRIM(lih,3))
#        if freqdmpSRIM[lih,5]>0.5 and freqdmpSRIM[lih,6]>0.5:
#            validationm = ' valid'
#        else:
#            validationm = ' not valid'
#
#        scroutput = strcat('Mode',num2str(lih), ...
#            ': Output EMAC =  ',num2str(freqdmpSRIM(lih,5)),...
#            ', MPC =  ',num2str(freqdmpSRIM(lih,6)),...
#            ' -->',' SRIM Identified Mode ',...
#            num2str(lih), ' is',validationm)
#        sprintf(scroutput)


#% 2g. Back calculate (estimate) output accelerations with state-space system &
#%     check against actual output accelerations

# Note that the computations are commented out as the matrix B is needed

# Prediction using state space model
#%KKKKK
##PY
##    ms1 = modstruc(A1,B,C1,D,zeros(n,m),x0)
##    th1 = ms2th(ms1,'d')
##    e,r = resid([dato dati],th1)
##    simy = idsim([dati],th1);                # simy represents the estimated accelerations
##
##    for i in range(m):
##        temsum = sum((dato[:,i]-simy[:,i]).**2)
##        Jm[i] = temsum/(sum(dato[:,i].**2));     # Root mean square error of estimated accelerations
##
##    RMSEpredSRIM = sum(Jm)/m
###%KKKKK
##    return freqdmpSRIM,modeshapeSRIM,RMSEpredSRIM

def block_3(df:int, CA_powers, m, C1, krn):
    #fi = out[df*m:(df+1)*m,:]
    #fi[:,:] = C1@krn[df-1]
    fi = C1@krn[df-1]
    for nmf in range(df-2):
        fi += CA_powers[df-nmf]@krn[nmf] #np.kron(dati[nmf,:],In1n1)
    return fi, df


def block_32(df:int, CA_powers, m, C1, krn):
    #fi = out[df*m:(df+1)*m,:]
    #fi[:,:] = C1@krn[df-1]
    fi = C1@krn[df-1]
    for nmf in range(df-2):
        fi += CA_powers[df-nmf]@krn[nmf] #np.kron(dati[nmf,:],In1n1)
    return jax.lax.reduce(
            (CA_powers,krn,range(df-2)), (C1@krn[df-1], 0),
            lambda x,y: (x[0]+y[0][df-x[1]], x[1]+1))

if __name__ == "__main__":
    import quakeio
    from pathlib import Path
    channels = [[17, 3, 20], [9, 7, 4]]
    data_dir = Path("RioDell_Petrolia_Processed_Data")
    first_input = quakeio.read(data_dir/f"CHAN{channels[0][0]:03d}.v2")
    npoints = len(first_input.accel.data)
    inputs, outputs = np.zeros((2,npoints,len(channels[0])))

    # Inputs
    inputs[:,0] = first_input.accel.data
    for i,inp in enumerate(channels[0][1:]):
        inputs[:,i+1] = quakeio.read(data_dir/f"CHAN{inp:03d}.V2").accel.data
    # Outputs
    for i,inp in enumerate(channels[1]):
        outputs[:,i] = quakeio.read(data_dir/f"CHAN{inp:03d}.V2").accel.data

    class T: pass
    config_srim = T()
    config_srim.p   =  5
    config_srim.to  = first_input.accel["time_step"]
    config_srim.dn  = npoints
    config_srim.orm =  4
    A,B,C,D = _srim(inputs, outputs, config_srim)
    #loc = _srim(inputs, outputs, config_srim)

