% Input declaration: N and M.
N = 100;
M = (1:100)*100;

% Initializing with zeros for faster performance.
E = zeros(1, length(M));
V = zeros(1, length(M));
C = zeros(1, length(M));
H = zeros(1, length(M));

% Calculating E, V, C and H for each M.
for i = 1:length(M)
    [e, v, c, h] = question2(N, M(i));
    E(i) = e;
    V(i) = v;
    C(i) = c;
    H(i) = h;
end

% Plotting Graphs.
figure
plot(M,E);
title('E(X) vs M Plot');
xlabel('M');
ylabel('E(X)');

figure
plot(M,V);
title('V(X) vs M Plot');
xlabel('M');
ylabel('V(X)');

figure
plot(M,C);
title('C(X) vs M Plot');
xlabel('M');
ylabel('C(X)');

figure
plot(M,H);
title('H(X) vs M Plot');
xlabel('M');
ylabel('H(X)');

% Function to calculate E, V, C and H for given N and M.
function [E, V, C, H] = question2(N,M)
    X1 = datasample(1:N,M);
    X2 = datasample(1:N,M);
   
    X = zeros(1, length(M));
    for i = 1:M
        X(i) = (max(X1(i), X2(i)) - X1(i));
    end
    
    E = mean(X);
    V = var(X);
    C_Matrix = cov(X,X1);
    C = C_Matrix(1,2);
    
    P = calc_prob(X);
    
    % Referred <https://stackoverflow.com/questions/22074941/shannons-entropy-calculation>
    H = sum(-(P.*(log2(P))));
end

function [P] = calc_prob(X)
    M = length(X);
    X_U = unique(X);
    
    P = zeros(1, length(X_U));
    
    % Referred <https://www.mathworks.com/matlabcentral/answers/163997-compute-probability-of-each-element-in-each-column-of-a-m-x-n-matrix>
    for i = 1:length(X_U)
        P(i) = (sum(X(:) == X_U(i)))/M;
    end  
end