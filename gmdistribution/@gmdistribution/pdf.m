        % Probability density function for Gaussian mixture distribution
      function c = pdf (obj,X)
        X = checkX (obj, X, 'pdf');
        p_x_l = componentProb (obj, X);
        c = sum (p_x_l, 2);
      end

        
