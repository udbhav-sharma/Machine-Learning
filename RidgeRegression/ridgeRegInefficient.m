function [w, b, obj, cvErrs] = ridgeRegInefficient(X, y, lambda)
    n = size(X,2);
    X = [X; ones(1,n)];
    k = size(X,1);
    cvErrs = zeros(n, 1);
    W = zeros(k, n);
    I = [[eye(k-1);zeros(1,k-1)] zeros(k,1)];
    
    for i = 1:n
        x_i = X(:,i);
        
        X_i = getXI(X, i);
        
        y_i = getYI(y, i);
                
        C = (X_i * X_i') + (lambda * I);
        
        d = X_i * y_i;
        
        w_i = pinv(C) * d;
        cvErr = abs((w_i' * x_i) - y(i));
        
        W(:,i) = w_i;
        cvErrs(i) = cvErr;
    end
    
    [~, j] = min(cvErrs);
    w = W(1:k-1, j);
    b = W(k,j);
    obj = (lambda * (w' * w)) + sum(((X' * [w;b]) - y).^2);
end

function [X_i] = getXI(X, i)
    X_i = [];
    if i ~= 1
        X_i = X(:,1:i-1);
    end

    if i ~= size(X,2)
        X_i = [X_i, X(:,i+1:end)];
    end
end

function [y_i] = getYI(y, i)
    y_i = [];
    if i ~= 1
        y_i = y(1:i-1,:);
    end

    if i ~= size(y,1)
        y_i = [y_i; y(i+1:end,:)];
    end
end