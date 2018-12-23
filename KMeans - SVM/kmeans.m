classdef kmeans
    
    methods (Static)
        
        function [y_pred, C, ss, it] = train(X, k, C, maxIt)
            n = size(X, 1);
            d = size(X, 2);
            
            y_pred = zeros(n, 1);
            
            for it = 1 : maxIt
                
                % Calculating Eucledian Distance Matrix from each centroid.
                distMat = zeros(n, k);
                for i = 1 : k
                    distMat(:, i) = kmeans.calcDist(X, C(i, :));
                end
                
                % Assigning clusters to each data point.
                [~, newYPred] = min(distMat, [], 2);
                
                % Recompute centers of each cluster.
                C = zeros(k, d);
                counts = zeros(k, 1);
                for i = 1 : n
                    label = newYPred(i);
                    C(label, :) = C(label, :) + X(i, :);
                    counts(label) = counts(label) + 1;
                end
                
                for i = 1 : k
                    C(i, :) = C(i, :) / counts(i);
                end
                
                % Checking for convergence
                if sum(newYPred == y_pred) == n
                    break;
                end
                
                y_pred = newYPred;
            end
            
            % Calculating Total sum of squares
            ss = kmeans.calcSS(X, y_pred, C, k);
        end
    
        function ss = calcSS(X, y, C, k)
            ss = 0;
            for i = 1 : k
                X_K = X((y == i),:);
                ss = ss + sum(kmeans.calcDist(X_K, C(i, :)));
            end
        end

        function dist = calcDist(X, c)
            dist = sum((X - c).^2, 2);
        end
        
        function p = calcP(y, y_pred)
            n = size(y, 1);
            
            p = zeros(3,1);

            tp1 = 0;
            tp2 = 0;
            
            p(1, 1) = 0;
            p(2, 1) = 0;
            
            % Calculating P1 and P2
            
            for i = 1 : n-1
                for j = i+1 : n
                    if y(i) == y(j)
                        tp1 = tp1 + 1;
                        if y_pred(i) == y_pred(j)
                            p(1, 1) = p(1, 1) + 1;
                        end
                    else
                        tp2 = tp2 + 1;
                        if y_pred(i) ~= y_pred(j)
                            p(2, 1) = p(2, 1) + 1;
                        end
                    end
                end
            end
            
            p(1, 1) = p(1, 1) / tp1;
            p(2, 1) = p(2, 1) / tp2;
            
            % Calculating P3
            p(3, 1) = (p(1, 1) + p(2, 1))/2.0;
        end
    end
end