        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Check format of argument X
      function X = checkX (obj, X, name)
        if (columns (X) ~= obj.NumVariables)
          if (columns (X) == 1 && rows (X) == obj.NumVariables)
            X = X';
          else
            error ('gmdistribution.%s: X has %d columns instead of %d\n', ...
                   name, columns (X), obj.NumVariables);
          end
        end
      end
