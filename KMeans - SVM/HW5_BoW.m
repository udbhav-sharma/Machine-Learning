classdef HW5_BoW    
% Practical for Visual Bag-of-Words representation    
% Use SVM, instead of Least-Squares SVM as for MPP_BoW
% By: Minh Hoai Nguyen (minhhoai@cs.stonybrook.edu)
% Created: 18-Dec-2015
% Last modified: 16-Oct-2018    
    
    methods (Static)
        function main()
            scales = [8, 16, 32, 64];
            normH = 16;
            normW = 16;
            bowCs = HW5_BoW.learnDictionary(scales, normH, normW);
                        
            [trIds, trLbs] = ml_load('../bigbangtheory/train.mat',  'imIds', 'lbs');             
            tstIds = ml_load('../bigbangtheory/test.mat', 'imIds'); 
                        
            trD  = HW5_BoW.cmpFeatVecs(trIds, scales, normH, normW, bowCs);
            tstD = HW5_BoW.cmpFeatVecs(tstIds, scales, normH, normW, bowCs);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Write code for training svm and prediction here            %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            save('featVecs','trD','tstD');
            
%             load('featVecs', 'trD', 'tstD');
            
%             C = [-5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
%             G = [-5, -4, -3, -2, -1, 0, 1, 2, 3];
            
            % RBF Kernel using default Params
            model = svmtrain(trLbs, trD', '-s 0 -v 5');
            
            % Tuning RBF Kernel
%             for g = G
%                 newG = 2^g;
%                 for c = C
%                     newC = 2^c;
%                     fprintf("[%f],[%f]", newC, newG);
%                     options = sprintf('-s 0 -c %f -g %f -v 5 -q', newC, newG);
%                     svmtrain(trLbs, trD', options);
%                 end
%             end

            % RBF Kernel based on best params
            model = svmtrain(trLbs, trD', '-s 0 -c 100 -g 25 -v 5');
            
            % Chi Square Kernel
            
%             for g = G
%                 %newG = 2^g;
%                 newG = g;
%                 [trainK, ~] = cmpExpX2Kernel(trD', tstD', newG);
%                 for c = C
%                     %newC = 2^c;
%                     newC = c;
%                     fprintf("[%f],[%f],", newC, newG);
%                     options = sprintf('-t 4 -c %f -v 5 -q', newC);
%                     svmtrain(trLbs, [(1:size(trainK, 1))', trainK], options);
%                 end
%             end
            
            [trainK, testK] = cmpExpX2Kernel(trD', tstD', 0.7);
            options = sprintf('-t 4 -c %f -q', 64);
            model = svmtrain(trLbs, [(1:size(trainK, 1))', trainK], options);
            [predClass, ~, ~] = svmpredict(ones(size(testK, 1), 1), [(1:size(testK, 1))', testK], model);
            csvwrite("submission.csv", [tstIds', predClass]);
        end
                
        function bowCs = learnDictionary(scales, normH, normW)
            % Number of random patches to build a visual dictionary
            % Should be around 1 million for a robust result
            % We set to a small number her to speed up the process. 
            nPatch2Sample = 100000;
            
            % load train ids
            trIds = ml_load('../bigbangtheory/train.mat', 'imIds'); 
            nPatchPerImScale = ceil(nPatch2Sample/length(trIds)/length(scales));
                        
            randWins = cell(length(scales), length(trIds)); % to store random patches
            for i=1:length(trIds)
                ml_progressBar(i, length(trIds), 'Randomly sample image patches');
                im = imread(sprintf('../bigbangtheory/%06d.jpg', trIds(i)));
                im = double(rgb2gray(im));  
                for j=1:length(scales)
                    scale = scales(j);
                    winSz = [scale, scale];
                    stepSz = winSz/2; % stepSz is set to half the window size here. 
                    
                    % ML_SlideWin is a class for efficient sliding window 
                    swObj = ML_SlideWin(im, winSz, stepSz);
                    
                    % Randomly sample some patches
                    randWins_ji = swObj.getRandomSamples(nPatchPerImScale);
                    
                    % resize all the patches to have a standard size
                    randWins_ji = reshape(randWins_ji, [scale, scale, size(randWins_ji,2)]);                    
                    randWins{j,i} = imresize(randWins_ji, [normH, normW]);
                end
            end
            randWins = cat(3, randWins{:});
            randWins = reshape(randWins, [normH*normW, size(randWins,3)]);
                                    
            fprintf('Learn a visual dictionary using k-means\n');
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Use your K-means implementation here                       %
            % to learn visual vocabulary                                 %
            % Input: randWinds contains your data points                 %
            % Output: bowCs: centroids from k-means, one column for each centroid  
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            k = 1000;
            
            perm = randperm(size(randWins, 2));
            bowCs = randWins(:, perm(1:k));
            
            [~, bowCs, ~, ~] = kmeans.train(randWins', k, bowCs', 20);
            bowCs = bowCs';
        end
                
        function D = cmpFeatVecs(imIds, scales, normH, normW, bowCs)
            n = length(imIds);
            D = cell(1, n);
            startT = tic;
            for i=1:n
                ml_progressBar(i, n, 'Computing feature vectors', startT);
                im = imread(sprintf('../bigbangtheory/%06d.jpg', imIds(i)));                                
                bowIds = HW5_BoW.cmpBowIds(im, scales, normH, normW, bowCs);                
                feat = hist(bowIds, 1:size(bowCs,2));
                D{i} = feat(:);
            end
            D = cat(2, D{:});
            D = double(D);
            D = D./repmat(sum(D,1), size(D,1),1);
        end        
        
        % bowCs: d*k matrix, with d = normH*normW, k: number of clusters
        % scales: sizes to densely extract the patches. 
        % normH, normW: normalized height and width oMf patches
        function bowIds = cmpBowIds(im, scales, normH, normW, bowCs)
            im = double(rgb2gray(im));
            bowIds = cell(length(scales),1);
            for j=1:length(scales)
                scale = scales(j);
                winSz = [scale, scale];
                stepSz = winSz/2; % stepSz is set to half the window size here.
                
                % ML_SlideWin is a class for efficient sliding window
                swObj = ML_SlideWin(im, winSz, stepSz);
                nBatch = swObj.getNBatch();
                
                for u=1:nBatch
                    wins = swObj.getBatch(u);
                    
                    % resize all the patches to have a standard size
                    wins = reshape(wins, [scale, scale, size(wins,2)]);                    
                    wins = imresize(wins, [normH, normW]);
                    wins = reshape(wins, [normH*normW, size(wins,3)]);
                    
                    % Get squared distance between windows and centroids
                    dist2 = ml_sqrDist(bowCs, wins); % dist2: k*n matrix, 
                    
                    % bowId: is the index of cluster closest to a patch
                    [~, bowIds{j,u}] = min(dist2, [], 1);                     
                end                
            end
            bowIds = cat(2, bowIds{:});
        end
        
    end    
end

