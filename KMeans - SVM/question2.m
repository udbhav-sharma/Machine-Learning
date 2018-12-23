X_train = load('../digit/digit.txt');
y_train = load('../digit/labels.txt');

% ============ Q - 2.5.1, 2.5.2 ============ %
K = [2, 4, 6];
maxIt = 20;

for k = K
    C = X_train(1:k,:);
    [y_pred, ~, ss, it] = kmeans.train(X_train, k, C, maxIt);
    p = kmeans.calcP(y_train, y_pred);
    fprintf("For K: [%d] SS: [%f] p1: [%f] p2: [%f] p3: [%f] iteration: [%d]\n", k, ss, p(1), p(2), p(3), it);
end

% ============ Q - 2.5.3, 2.5.4 ============ %
maxIt = 20;
m = 10;

K = 1:10;
SS = zeros(length(K), 1);
P = zeros(length(K), 3);

for i = 1 : m
    for k = K        
        perm = randperm(size(X_train, 1));
        C = X_train(perm(1:k),:);
        
        [y_pred, ~, ss, it] = kmeans.train(X_train, k, C, maxIt);
        p = kmeans.calcP(y_train, y_pred);
        
        fprintf("For i: [%d] K: [%d] SS: [%f] p1: [%f] p2: [%f] p3: [%f] iteration: [%d]\n", i, k, ss, p(1), p(2), p(3), it);
        
        SS(k) = SS(k) + ss; 
        P(k,:) = P(k,:) + p';
    end
end

SS = SS ./ m;
P = P ./ m;

figure
plot(K, SS);
title('Total sum of squares Plot');
xlabel('K');
ylabel('Total sum of squares');

figure
plot(K, P(:, 1));
hold on

plot(K, P(:, 2));
hold on

plot(K, P(:, 3));

title('p1, p2, p3 vs K Plot');
xlabel('K');
ylabel('P values');
legend('p1','p2','p3')
hold off

