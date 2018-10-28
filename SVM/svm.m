function [w, b, obj, nSV, alpha] = svm(X, y, C, tol)

    d = size(X, 1);
    n = size(X, 2);

    % Required as somehow quadprog breaks without this for Kaggle data
    X = double(X);
    y = double(y);
    
    % Initializing quadprog variables
    H = (X' * X) .* (y * y');
    f = -1 * ones(n, 1);
    A = [];
    b = [];
    Aeq = y';
    beq = zeros(1, 1);
    lb = zeros(n, 1);
    ub = C * ones(n, 1);

    % Calculating alpha
    alpha = quadprog(H, f, A, b, Aeq, beq, lb, ub);
    
    % Calculating support vector
    nSV = size(find(alpha > tol), 1);

    % Calculating w
    w = zeros(d, 1);
    for i = 1 : n
        w = w + ((alpha(i) * y(i)) * X(:, i));
    end

    % Calculating bias
    b = 0;
    for i = 1 : n
        if alpha(i) > tol && alpha(i) < (C - tol)
            b = y(i) - (X(:, i)' * w);
        end
    end
    
    % Calculating Objective value
    alphaYX = sum(((alpha .* y) .* X'), 1);
    obj = sum(alpha) - (0.5 * norm(alphaYX) * norm(alphaYX));
    
end