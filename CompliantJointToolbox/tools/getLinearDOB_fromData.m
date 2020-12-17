% GETLINEARDOB_FROMDATA Estimate linear disturbance observer transfer
% functions from experimental data.
%
%   [Pc, Q_td, Q_ff, PQ_td, PQ_ff] = getLinearDOB_fromData(jointObj, t, u, y, id_Np, id_Nz, f_c_FF, f_c_DOB [, DOB_order, roi])
%
%  This function calculates the estimated closed-loop transfer function
%  Pc, low-pass Q-filters, and the inverted models for a DOB with premulti-
%  plication control scheme. This is the experimental data version, that
%  takes input-output data of the plant to approximate a plant model.
%  This function returns the estimated closed-loop transfer function
%  Pc, DOB filter Q_td, feed-forward filter Q_ff, DOB plant inversion +
%  filter PQ_td, and feed-forward plant inversion + filter PQ_ff.
%
% Inputs::
%   jointObj: Joint object
%   t: Time data vector
%   u: Input data vector
%   y: Output data vector
%   id_Np: Number of poles in model identification
%   id_Nz: Number of zeroes in model identification
%   f_c_FF: Feed-forward Q-filter cut-off frequency in [Hz]
%   f_c_DOB: DOB Q-filter cut-off frequency in [Hz]
%   DOB_order: DOB order (>= relative order of plant, i.e. id_Np-id_Nz)
%   roi: Frequency range of interest in [Hz], sets x limits in produced plots (default [0.1,100])
%
% Outputs::
%   Pc: Estimated closed-loop transfer function
%   Q_td: DOB Q-filter
%   Q_ff: Feed-forward Q-filter
%   PQ_td: Inverted plant + DOB Q-filter
%   PQ_ff: Inverted plant + Feed-forward Q-filter
%
% Notes::
%
%
% Examples::
%
%
% Author::
%  Joern Malzahn
%  Wesley Roozing
%
% See also getLinearDOB, getObserver, getKalman.

% Copyright (C) 2016, by Joern Malzahn, Wesley Roozing
%
% This file is part of the Compliant Joint Toolbox (CJT).
%
% CJT is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% CJT is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
% License for more details.
%
% You should have received a copy of the GNU General Public License
% along with CJT. If not, see <http://www.gnu.org/licenses/>.
%
% For more information on the toolbox and contact to the authors visit
% <https://github.com/geez0x1/CompliantJointToolbox>

function [Pc, Q_td, Q_ff, PQ_td, PQ_ff] = getLinearDOB_fromData(jointObj, t, u, y, id_Np, id_Nz, f_c_FF, f_c_DOB, DOB_order, roi)
    %% Default parameters
    if (~exist('id_Np', 'var') || isequal(id_Np,[]))
        id_Np   = 4;        % Model number of poles []
    end
    if (~exist('id_Nz', 'var') || isequal(id_Nz,[]))
        id_Nz   = 1;        % Model number of zeros []
    end
    if (~exist('f_c_FF', 'var') || isequal(f_c_FF,[]))
        f_c_FF  = 40;       % Feed-forward cutoff frequency [Hz]
    end
    if (~exist('f_c_DOB', 'var') || isequal(f_c_DOB,[]))
        f_c_DOB = 60;       % DOB cutoff frequency [Hz]
    end
    if (~exist('DOB_order', 'var') || isequal(DOB_order,[]))
        DOB_order = id_Np - id_Nz; % Minimum order by default
    end
    if (DOB_order < id_Np - id_Nz)
        error('DOB order needs to be equal to or larger than the relative order of the plant.');
    end
    if (~exist('roi', 'var') || isequal(roi,[]))
        roi = [0.1, 100];	% Region of interest [[Hz], [Hz]]
    end
    
    % Bode options
    bodeOpt = bodeoptions;
    bodeOpt.FreqUnits = 'Hz';


    %% Get variables
    
    % Cut-off frequencies
    omega_c_FF      = 2 * pi * f_c_FF;  % Feed-forward (model inv) LPF cutoff frequency [rad/s]
    omega_c_DOB     = 2 * pi * f_c_DOB; % DOB cutoff frequency [rad/s]

    % Resample data to obtain uniform sampling for tfest()
    Ts      = jointObj.Ts;      % Sampling time [s]
    t_RS    = t(1):Ts:t(end);   % Resampled time
    u       = interp1(t, u, t_RS)';
    y       = interp1(t, y, t_RS)';
    t       = t_RS';

    % Plot bode plot of original data
    [f, mag_db, phase] = bode_tuy(t, u, y);

    
    %% Identification

    % Generate iddata object of data
    d = iddata(y, u, [], 'SamplingInstants', t);

    % Identify transfer function Pc
    Options             = tfestOptions;
    Options.Display     = 'on';
    Options.InitMethod  = 'all';
    Pc                  = tfest(d, id_Np, id_Nz, Options);

    % Get magnitude and phase of Pc over f
    [mag_Pc, phase_Pc]  = bode(Pc, 2*pi*f);
    mag_db_Pc           = mag2db(mag_Pc(:));
    phase_Pc            = phase_Pc(:);


    %% Plot original data and Pc approximation
    figure();
    
    % Magnitude
    subplot(2,1,1);
    semilogx(f,mag_db); hold on;
    semilogx(f,mag_db_Pc, 'r');
    grid on
    xlim(roi);
    ylabel('Magnitude [dB]');
    legend('Data', 'Model');

    % Phase
    subplot(2,1,2);
    semilogx(f,phase); hold on;
    semilogx(f,phase_Pc, 'r');
    grid on;
    xlim(roi);
    xlabel('Frequency [Hz]');
    ylabel('Phase [deg]');


    %% Design low-pass Butterworth filters

    % Q_td
    [a, b] = butter(DOB_order, omega_c_DOB, 's');
    Q_td = tf(a,b);

    % Q_ff
    [a, b] = butter(DOB_order, omega_c_FF, 's');
    Q_ff = tf(a,b);

    % Pc^-1 * Q_td
    PQ_td = inv(Pc) * Q_td;

    % Pc^-1 * Q_ff
    PQ_ff = inv(Pc) * Q_ff;


    %% Show Bode plots of results
    figure(); hold on;
    bode(Pc, bodeOpt);
    bode(inv(Pc), bodeOpt);
    bode(Q_td, bodeOpt);
    bode(Q_ff, bodeOpt);
    bode(PQ_td, bodeOpt);
    bode(PQ_ff, bodeOpt);
    xlim(roi);
    grid on;
    legend('P_c', 'P_c^{-1}', 'Q_{td}', 'Q_{ff}', 'PQ_{td}', 'PQ_{ff}');
    
    
end
