Data = csvread("machine-learning-ex1_ex1_ex1data1.txt");
X = Data(:,1);
y = Data(:,2);

plot(X,y, 'rx', 'MarkerSize', 10);

%[w, b, obj, cvErrs] = ridgeRegInefficient(X', y, 0.1);
[w, b, obj, cvErrs] = ridgeReg(X', y, 0.1);

disp("w = " + w + " b = " + b + " obj = " + obj);

y_pred = (X * w) + (ones(size(X,1),1).*b);

hold on; % keep previous plot visible
plot(X, y_pred, '-')