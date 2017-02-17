% -----------------------------------------------------------------------------
% The following is a MATLAB implementation of the standard gradient descent
% minimization of the image entropy cost function. The below algorithm
% implements the technique described analytically in 'tech_report.pdf'.
%
% @param B [K * N array] pulse history formatted as a 1D array of length `K * N`
% array where `K` refers to the number of pulses in the aperture and `N` refers
% to the number of pixels in either the 2D or 3D image. The array should be
% formatted such that the `i`th set of `K` elements correspond to the
% contributions to pixel `i`.  E.g. the first `K` elements represent each
% pulse's contribution to pixel 0.
%
% @param K [Integer] number of pulses to form `B`
%
% @param gradFunc [function_handle] Function handle use to compute the gradient
% of H. This parameter can be one of `grad_h_mex` or `gradH`. Note that the
% former can be linked against a C++ or a CUDA object file.
%
% @return focusedImage [Array] X by Y (by Z) focused image
% @return minEntropy [Float] entropy of focused `B`
% @return origEntropy [Float] entropy of unfocused image
% -----------------------------------------------------------------------------
% TODO: `delta` should be a parameter to gradFunc
function [ focusedImage, minEntropy, origEntropy ] = minimizeEntropy( B, K, gradFunc )
  addpath('utility');

  s                 = 100;     % Step size parameter for gradient descent
  convergenceThresh = 0.01;    % Difference after which iteration "converges"

  l                 = 2; % First iteration is all 0s, so start at iteration 2
  minIdx            = 1;
  minEntropy        = Inf;

  % Holds array of potentially minimizing phase offsets (guessing zero
  % initially). 50 is an arbitrary guess for the number of iterations
  phi_offsets = zeros(50, K);

  origEntropy = H(computeZ(phi_offsets(l, :), B));

  while (1) % phi_offsets(1) = 0
    phi_offsets(l, :) = phi_offsets(l - 1, :) - s * gradFunc(phi_offsets(l - 1, :), B);

    focusedImage = computeZ(phi_offsets(l, :), B);
    tempEntropy = H(focusedImage);
    
    fprintf('tempEntropy = %d, minEntropy = %d\n', tempEntropy, minEntropy);

    if (minEntropy < tempEntropy)
        s = s / 2;

        fprintf('Reducing step size to %d\n', s);

        if (s < convergenceThresh)
          fprintf('s is below threshold so breaking');
          break;
        end
    else
        if (minEntropy - tempEntropy < convergenceThresh) 
          fprintf('%d - %d = %d < 0.001\n', minEntropy, tempEntropy, minEntropy - tempEntropy);
          break; % if decreases in entropy are small
        end

        minIdx = l;
        minEntropy = tempEntropy;
        l = l + 1;
    end
  end
end

