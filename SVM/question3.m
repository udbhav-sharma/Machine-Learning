%================= 3.4.1 ==================%
[trD, trLb, ~, ~, ~, ~] = HW4_Utils.getPosAndRandomNeg();

C = 10;
tol = 0.0001;
[w, b, ~, ~, ~] = svm(trD, trLb, C, tol);

HW4_Utils.genRsltFile(w, b, "val", "rsltFile");
[ap, ~, ~] = HW4_Utils.cmpAP("rsltFile", "val");


%================= 3.4.2, 3.4.3 and 3.4.4 ===============%
% Hard Mining Algorithm
[trD, trLb, valD, valLb, trRegs, valRegs] = HW4_Utils.getPosAndRandomNeg();

PosD = trD(:, trLb == 1);
PosLb = trLb(trLb == 1);

NegD = trD(:, trLb == -1);
NegLb = trLb(trLb == -1);

m = 1000;
C = 10;
tol = 0.0001;
overlapThreshold = 0.1;
maxIterations = 10;

apMat = zeros(maxIterations, 1);
objMat = zeros(maxIterations, 1);

load(sprintf('%s/%sAnno.mat', HW4_Utils.dataDir, "train"), 'ubAnno');

[w, b, ~, ~, alpha] = svm(trD, trLb, C, tol);
for i = 1 : maxIterations
    
    % Removing Negative Non Support vectors from the data.
    idx = find((alpha < tol) & (trLb == -1));
    trD(:, idx) = [];
    trLb(idx, :) = [];
    
    newNegD = [];
    for j = 1 : 93
        im = sprintf('%s/trainIms/%04d.jpg', HW4_Utils.dataDir, j);
        im = imread(im);
        
        rect = HW4_Utils.detect(im, w, b);
        % rectNeg = rect(:, (rect(5,:) < 0));
        
        total_pos = sum(rect(end,:)>0);
        rectNeg = rect(:, 1:total_pos + 10);
                
        % Prune rectangles that are not within image boundaries.
        [imH, imW, ~] = size(im);
        rectNeg = rectNeg(:, rectNeg(3, :) < imW);
        rectNeg = rectNeg(:, rectNeg(4, :) < imH);
        
        % Prune rectangles where overlap is more than threshold.
        rectNeg = rectNeg(1:4, :);
        ubs = ubAnno{j};
        
        for k = 1 : size(ubs, 2)
            overlap = HW4_Utils.rectOverlap(rectNeg, ubs(:, k));                    
            rectNeg = rectNeg(:, overlap < overlapThreshold);
        end
        
        % Feature extraction.
        for k = 1 : size(rectNeg, 2)
            tmp = rectNeg(:, k);
            imReg = im(tmp(2):tmp(4), tmp(1):tmp(3),:);
            imReg = imresize(imReg, HW4_Utils.normImSz);
            
            feature = HW4_Utils.cmpFeat(rgb2gray(imReg));
            feature = HW4_Utils.l2Norm(feature);
            newNegD = [newNegD, feature];
        end
        
        if size(newNegD, 2) > m
            break;
        end
    end
    
    trD = [trD, newNegD];
    trLb = [trLb; -1 * ones(size(newNegD, 2), 1)];
    
    [w, b, obj, ~, alpha] = svm(trD, trLb, C, tol);
    
    HW4_Utils.genRsltFile(w, b, "val", "mining_val");
    [ap, ~, ~] = HW4_Utils.cmpAP("mining_val", "val");
    
    apMat(i) = ap;
    objMat(i) = obj;
end

disp("Objective Values:");
disp(objMat);

disp("Average Precision Values:");
disp(apMat);

iterations = 1 : maxIterations;
iterations = iterations(:);

figure
plot(iterations, objMat);
title('Objective Values Plot');
xlabel('Iteration');
ylabel('Objective Values');

figure
plot(iterations, apMat);
title('APs Plot');
xlabel('Iteration');
ylabel('APs');