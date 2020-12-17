% GETLQR Calculate LQR controller gains
%
%   [ K_lqr, N ] = getLQR( jointObj, outputIdx, Q, R )
%
%  Calculate the LQR gains for the joint object jointObj with
%  controlled output outputIdx and state and input weighting Q and R,
%  respectively.
%
% Inputs:
%   jointObj: Joint object
%   outputIdx: Joint outputs to be controlled for reference
%   Q: State weights
%   R: Input weights
%
% Outputs:
%   K_lqr: Optimal LQR gain
%   N: Premultiplication matrix for reference
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
% See also getKalman, getObserver.

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

function [K_lqr, N] = getLQR(jointObj, outputIdx, Q, R)
    %% Parameters
    if (~exist('Q', 'var') || isequal(Q,[]))
        Q = diag([0 1000 0 0]);
    end
    if (~exist('R', 'var') || isequal(R,[]))
        R = 1e-6;
    end
    if (length(outputIdx) > 1)
        error('getLQR error: More than one output weight specified.');
    end
    
    % Shorthands
    sys     = jointObj.getStateSpace();
    A       = sys.A;
    B       = sys.B(:,1); % Use only the current input
    C       = sys.C;
    D       = sys.D(:,1); % Use only the current input
    
    % Get state-space model with current input
    sys     = ss(A, B, C, D);
    
    
    %% Check some dimensions
    if (size(Q) ~= size(A))
        error('getLQR error: size(Q) ~= size(A)');
    end
    if (length(R) ~= size(B,2))
        error('getLQR error: size(R) ~= size(B)');
    end

    
    %% Design LQR controller

    % Calculate LQR gain matrix K
    [K_lqr, ~, ~] = lqr(sys, Q, R);
    
    % Create system with outputs specified for reference
    Ac      = A;
    B       = B;
    Cc      = C(outputIdx,:);
    Dc      = D(outputIdx,1); % Use only the current input
    
    % Calculate reference input premultiplication N
    a       = [zeros(length(Bc),1); 1];
    N       = inv([Ac, Bc; Cc, Dc]) * a;
    N_x     = N(1:end-1);
    N_u     = N(end);
    N       = N_u + K_lqr * N_x;

end

