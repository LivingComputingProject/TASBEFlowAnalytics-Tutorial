% Random numbers from Gaussian mixture distribution
function c = random (obj,n)

c = zeros (n, obj.NumVariables);
classes = randsample (obj.NumVariables, n, true, obj.PComponents);
if (obj.SharedCovariance)
  if (obj.DiagonalCovariance)
      sig = diag (obj.Sigma);
  else
      sig = obj.Sigma;
  end
end

for i = 1:obj.NumComponents
  idx = (classes == i);
  k = sum(idx);
  if k > 0
    if (~obj.SharedCovariance)
      if (obj.DiagonalCovariance)
          sig = diag (obj.Sigma(:,:,i));
      else
          sig = obj.Sigma(:,:,i);
      end
    end
            % [sig] forces [sig] not to have class 'diagonal',
            % since mvnrnd uses automatic broadcast,
            % which fails on structured matrices
    c(idx,:) = mvnrnd ([obj.mu(i,:)], [sig], k);
  end
end
