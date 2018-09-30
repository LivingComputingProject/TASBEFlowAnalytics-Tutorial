      % Probability density of (row of) X *and* component l
      % Second argument is an array of the Mahalonis distances
      function [p_x_l, M] = componentProb (obj, X)
        [r_X c_X] = size(X); %num of rows and cols in X
        M     = zeros (r_X, obj.NumComponents);
        dets  = zeros (1, obj.NumComponents);   % sqrt(determinant)
        if (obj.SharedCovariance)
          if (obj.DiagonalCovariance)
            r = diag (sqrt(obj.Sigma));
          else
            r = chol (obj.Sigma);
          end
        end
        for i = 1:obj.NumComponents
          dev = bsxfun (@minus, X, obj.mu(i,:));
          if (~obj.SharedCovariance)
            if (obj.DiagonalCovariance)
                r = diag (sqrt (obj.Sigma(:,:,i)));
            else
                r = chol (obj.Sigma(:,:,i));
            end
          end
          M(:,i) = sumsq (dev / r, 2);
          dets(i) = prod (diag (r));
        end
        p_x_l = exp (-M/2);
        coeff = obj.PComponents ./ ((2*pi)^(obj.NumVariables/2).*dets);
        p_x_l = bsxfun (@times, p_x_l, coeff);
      end
