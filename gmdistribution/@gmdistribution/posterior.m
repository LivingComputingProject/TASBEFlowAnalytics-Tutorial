        % Posterior probabilities of components
      function c = posterior (obj,X)
        X = checkX (obj, X, 'posterior');
        p_x_l = componentProb (obj, X);
        c = bsxfun(@rdivide, p_x_l, sum (p_x_l, 2));
      end

        
