       % Display Gaussian mixture distribution object
      function c = disp (obj)
          fprintf('Gaussian mixture distribution with %d components in %d dimension(s)\n', obj.NumComponents, columns (obj.mu));
          for i = 1:obj.NumComponents
              fprintf('Clust %d: weight %d\n\tMean: ', i, obj.PComponents(i));
              fprintf('%g ', obj.mu(i,:));
              fprintf('\n');
              if (~obj.SharedCovariance)
                  fprintf('\tVariance:');
                  if (~obj.DiagonalCovariance)
                      if columns (obj.mu) > 1
                        fprintf('\n');
                      end
                      disp(squeeze(obj.Sigma(:,:,i)))
                  else
                      fprintf(' diag(');
                      fprintf('%g ', obj.Sigma(:,:,i));
                      fprintf(')\n');
                  end
              end
          end
          if (obj.SharedCovariance)
              fprintf('Shared variance\n');
              if (~obj.DiagonalCovariance)
                  obj.Sigma
              else
                  fprintf(' diag(');
                  fprintf('%g ', obj.Sigma);
                  fprintf(')\n');
              end
          end
          if (~isempty (obj.AIC))
              fprintf('AIC=%g BIC=%g NLogL=%g Iter=%d Cged=%d Reg=%g\n', ...
                  obj.AIC, obj.BIC, obj.NegativeLogLikelihood, ...
                  obj.NumIterations, obj.Converged, obj.RegularizationValue);
          end
      end

        
