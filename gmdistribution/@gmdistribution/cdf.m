       % Cumulative distribution function for Gaussian mixture distribution
      function c = cdf (obj, X)
        X = checkX (obj, X, 'cdf');
        p_x_l = zeros (rows (X), obj.NumComponents);
        if (obj.SharedCovariance)
          if (obj.DiagonalCovariance)
            sig = diag (obj.Sigma);
          else
            sig = obj.Sigma;
          end
        end
        for i = 1:obj.NumComponents
          if (~obj.SharedCovariance)
            if (obj.DiagonalCovariance)
              sig = diag (obj.Sigma(:,:,i));
            else
              sig = obj.Sigma(:,:,i);
            end
          end
          p_x_l(:,i) = mvncdf (X,obj.mu(i,:),sig)*obj.PComponents(i);
        end
        c = sum (p_x_l, 2);
      end

