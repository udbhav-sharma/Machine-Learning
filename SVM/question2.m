%=============== Question 2.1, 2.2, 2.3, 2.4, 2.5 ===============%

data = load('q2_1_data.mat');

X_train = data.trD;
y_train = data.trLb;

X_val = data.valD;
y_val = data.valLb;

C = [0.1, 10];
tol = 0.00001;

for c = C
    fprintf("----------Training on C = [%f]------------\n", c);
    
    [w, b, obj, nSV, ~] = svm(X_train, y_train, c, tol);

    y_train_pred = getPrediction(X_train, w, b);
    accuracy_train = getAccuracy(y_train, y_train_pred);
    fprintf("Training accuracy: [%f] Objective Value: [%f] Support Vectors: [%d]\n", accuracy_train, obj, nSV);
    disp("Training Confusion Matrix - ");
    disp(confusionmat(y_train, y_train_pred));

    y_val_pred = getPrediction(X_val, w, b);
    accuracy_val = getAccuracy(y_val, y_val_pred);
    fprintf("Validation accuracy: [%f]\n", accuracy_val);
    disp("Validation Confusion Matrix - ");
    disp(confusionmat(y_val, y_val_pred));
end

function [y_pred] = getPrediction(X, w, b)
    y_pred = (X' * w) + b;
    y_pred(y_pred >= 0) = 1;
    y_pred(y_pred < 0) = -1;
end

% Referred: https://stackoverflow.com/questions/25535051/how-can-i-efficiently-find-the-accuracy-of-a-classifier
function [acc] = getAccuracy(y, y_pred)
    n = numel(y);
    acc = 100 * (sum(y == y_pred) / n);
end