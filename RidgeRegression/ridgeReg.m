function [w, b, obj, cvErrs] = ridgeReg(X, y, lambda)
    % Creating a copy of X to work on.
    X = repmat(X, 1);
    
    % Total number of input observations.
    n = size(X,2);
    
    % Adding one to each observation in X.
    X = [X; ones(1,n)];
    
    % Total number of input features.
    k = size(X,1);
    
    % Initializing Identity matrix with zeros in last column and row.
    I = [[eye(k-1); zeros(1,k-1)] zeros(k,1)];
    
    % Calculating C inverse.
    C = (X * X') + (lambda * I);
    C_inv = pinv(C);
    
    % Calculating d.
    d = X * y;
    
    % Calculating w using closed form solution.
    w = C_inv * d;
    
    cvErrs = zeros(n, 1);
    for i = 1:n
        x_i = X(:,i);
        
        % Calculating cvErr for ith training set.
        cvErr = ((w' * x_i) - y(i))/(1 - (x_i' * C_inv * x_i));
        cvErrs(i) = cvErr;
    end
    
    % Extracting bias from w.
    b = w(k);
    w = w(1:k-1, :);
    
    % Objective value calculation.
    obj = (lambda * (w' * w)) + sum(((X' * [w;b]) - y).^2);
end