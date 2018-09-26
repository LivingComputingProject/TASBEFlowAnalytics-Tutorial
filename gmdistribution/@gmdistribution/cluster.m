       % Construct clusters from Gaussian mixture distribution
      function [idx,nlogl,P,logpdf,M] = cluster (obj,X)
        X = checkX (obj, X, 'cluster');
        [p_x_l, M] = componentProb (obj, X);
        [~, idx] = max (p_x_l, [], 2);
        if (nargout >= 2)
          PDF = sum (p_x_l, 2);
          logpdf = log (PDF);
          nlogl = -sum (logpdf);
          if (nargout >= 3)
            P = bsxfun (@rdivide, p_x_l, PDF);
          end
        end
      end

        
