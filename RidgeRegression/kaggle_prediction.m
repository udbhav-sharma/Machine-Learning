% Loading training set and labels.
disp("Loading Training Data");
X = csvread("trainData.csv",0,0);
X = X(:,2:end);

disp("Loading Validation Data");
X_val = csvread("valData.csv",0,0);
X_val = X_val(:,2:end);

disp("Loading Training Data Labels");
y = csvread("trainLabels.csv",0,0);
y = y(:,2:end);

disp("Loading Validation Data Labels");
y_val = csvread("valLabels.csv",0,0);
y_val = y_val(:,2:end);

% Training on both training and validation data.
X = [X;X_val];
y = [y;y_val];

% lambda value to get better results.
lambda = 0.68;
outputFileName = "predTestLabels.csv";

disp("Training ridge regression");
[w, b, ~, ~] = ridgeReg(X', y, lambda);

disp("Loading Test Data");
X = csvread("testData.csv",0,0);
id = X(:,1);
X = X(:,2:end);

X = [X, ones(size(X,1),1)];
w = [w;b];

disp("Predicting values");
y_pred = (X * w);

disp("Writing prediction to file: " + outputFileName);
csvwrite(outputFileName, [id, y_pred]);