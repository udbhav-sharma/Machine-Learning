% Training Ridge Regression for different values of lambda using LOOCV.

% Initialization.
lambda = [0.5, 0.6, 0.65,  0.7, 0.8];

cvErrsRmse = zeros(length(lambda), 1);

trErrsRmse = zeros(length(lambda), 1);

valErrsRmse = zeros(length(lambda), 1);

% Loading training set and labels.
disp("Loading Training Data");
X = csvread("trainData.csv",0,0);
X = X(:,2:end);

disp("Loading Training Data Labels");
y = csvread("trainLabels.csv",0,0);
y = y(:,2:end);

disp("Loading Validation Data");
X_val = csvread("valData.csv",0,0);
X_val = X_val(:,2:end);

disp("Loading Validation Data Labels");
y_val = csvread("valLabels.csv",0,0);
y_val = y_val(:,2:end);

% Iterating over lambda vector and training Ridge Regression for each
% lambda.
for i = 1:length(lambda)
    fprintf("-------Training for lambda: %8.3f----------\n", lambda(i));
    [w, b, obj, cvErrs] = ridgeReg(X', y, lambda(i));
    
    % Root Mean Square cross validation errors for a given lambda.
    cvErrsRmse(i) = sqrt(mean(cvErrs.^2));
    
    % Predicting labels for training data for a given lambda.
    y_pred = (X * w) + (ones(size(X,1),1).*b);

    % Root Mean square training errors for a lambda.
    trErrsRmse(i) = sqrt(mean((y_pred - y).^2));
    
    % Predicting labels for validation data for a given lambda.
    y_val_pred = (X_val * w) + (ones(size(X_val,1),1).*b);
    
    % Root Mean Square validation errors for a lambda.
    valErrsRmse(i) = sqrt(mean((y_val_pred - y_val).^2));
    
    % Regularization for given lambda and w.
    regularization = lambda(i) * (w' * w);
    
    % Sum of square training errors for a given lambda.
    sumOfSqErr = sum((y_pred - y).^2);
        
    fprintf("Objective: [%f] trErrRmse: [%f] valErrRmse: [%f] " ...
        + "cvErrsRmse: [%f] sumOfSqErr: [%f] regularization: [%f]\n", ...
        obj, trErrsRmse(i), valErrsRmse(i), ...
        cvErrsRmse(i), sumOfSqErr, regularization);
 end

%Plotting graph
figure

semilogx(lambda, trErrsRmse);
hold on;
semilogx(lambda, valErrsRmse);
hold on;
semilogx(lambda, cvErrsRmse);

xlabel('Log of lambda values');
ylabel('Errors'); 
legend({'y = Training RMSE','y = Validation RMSE','y = LOOCV RMSE'}, ...
    'Location','southeast');
