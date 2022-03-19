function [dati, dato, dn, dt_new] = PreOKID(dat, dt, div, inpchns, outchns)
%% 1. Data Pre-Processing
% Sampling Frequency and Nyquist Frequency
fo = 1/dt;
fn = fo/2;
d = size(dat,1);
% Data pre-processing consists of three actions:
% a) Baseline correction, b) Filtering, c) Decimating the data and downsampling

% Steps a and b are mostly needed when raw data is used from .V1 files and can be
% skipped when processed .V2 files are used. Here, both steps are currently commented out as
% already the processed data are used with .V2 files

% a) Baseline correction and removing the mean from the data using the function dtrend

%datnn = dtrend(dat);
datnn = dat;

% b) Filtering the data

%Below commands use a Type II Chebychev filter, but any other filter is also possible
% cutof = 10;
%[b,a] = cheby2(9,30,1/div-0.001);
%datnn= filter(b,a,datnn);

% c) Decimating the data
datn = datnn(1:div:d,:);    % decimating data by selecting every div-th point.
% Currebtly, div = 1, so all data is used.
dt_new = dt*div;            % sampling time increases due to decimating the data.
dn = d/div;                 % total number of time steps after decimating =
                            % total number of acceleration samples per channel

dati = datn(:,inpchns);     % accelerations at input channels after pre-processing,
                            % dati is a matrix with size dn x inpchns.
                            % # of rows is dn & # of columns is inpchns.
dato = datn(:,outchns);     % accelerations at output channels after pre-processing,
                            % dato is a matrix with size dn x outchns.
                            % # of rows is dn & # of columns is outchns.

