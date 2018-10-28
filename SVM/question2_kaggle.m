%============= Question 2.6 =============%

data = load('q2_2_data.mat');

X_train = [data.trD, data.valD];
y_train = [data.trLb; data.valLb];
X_test = data.tstD;

C = 0.0001;
tol = 0.00001;
uniqueLb = 10;

d = size(X_train, 1);
n = size(X_train, 2);

wMat = zeros(d, uniqueLb);
bMat = zeros(1, uniqueLb);

for i = 1:uniqueLb
    fprintf("----------Training classifier for class = [%f]------------\n", i);

    % Forming new Y for training
    y = zeros(n, 1);
    for j = 1:n
        if y_train(j) == i
            y(j) = 1;
        else
            y(j) = -1;
        end
    end

    % Training SVM
    [w, b, ~, ~, ~] = svm(X_train, y, C, tol);
    wMat(:,i) = w;
    bMat(:,i) = b;
end
    
y_pred = getPrediction(X_train, wMat, bMat);
accuracy_train = getAccuracy(y_train, y_pred);
fprintf("Training accuracy: [%f]\n", accuracy_train);

y_test_pred = getPrediction(X_test, wMat, bMat);

id = 1:size(X_test, 2);
id = id(:);
csvwrite("submission.csv", [id, y_test_pred]);

function [y_pred] = getPrediction(X, wMat, bMat)
    n = size(X, 2);
    uniqueLb = size(wMat,2);

    confidenceMat = zeros(n, uniqueLb);
    
    for i = 1 : uniqueLb
        w = wMat(:,i);
        b = bMat(:,i);
        
        confidenceMat(:,i) = ((X' * w) + b);
    end
    
    [~, y_pred] = max(confidenceMat, [], 2);
end

% Referred: https://stackoverflow.com/questions/25535051/how-can-i-efficiently-find-the-accuracy-of-a-classifier
function [acc] = getAccuracy(y, y_pred)
    n = numel(y);
    acc = 100 * (sum(y == y_pred) / n);
end
