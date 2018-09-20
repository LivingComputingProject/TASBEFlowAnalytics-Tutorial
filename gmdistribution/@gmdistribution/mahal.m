       % Mahalanobis distance to component means
      function D = mahal (obj,X)
        X = checkX (obj, X, 'mahal');
        [~, D] = componentProb (obj,X);
      end
        
