function [gamma,epsilon,cvMse,minVal] = optimiseCSAPS(t,y,gammaRange,nfold,mcreps)
  
try
    
    gammaRange = (gammaRange-4)/4; % this is to make the GUI scaling easier [0:1:20] = [-1:0.25:4.00]

    avDist = median(t(2:end) - t(1:end-1));
    epsilon = avDist^3/16;     

    missing = isnan(y);
    y(missing) = [];
    t(missing) = [];


    len = length(t);

    if nfold == -1
        nfold = len; 
        mcreps = 1;
    end


    if len < 3
        % if QCs < 3 then we are wasting our time doing this.
        gamma = NaN;
        cvMse = NaN;
        minVal = NaN;
        epsilon = NaN;
    elseif len < 6
        % QCs <= 5 cannot effectively perform spline cross-valiadation
        % setting gamma to effectively produce a linear correction.
        gamma = max(gammaRange);
        cvMse = 0; %zeros(1,numel(gammaRange));
        minVal = 0;
        
    else
        cvMse = nan(numel(gammaRange),1);
        if mcreps == 1
            training = cvmatrix(len,nfold);
            test = ~training;
            for i = 1:numel(gammaRange)
                p = 1/(1+epsilon*10^(gammaRange(i)));
                ypred = nan(len,1);
                for j = 1:width(training)
                    ypred(test(:,j)) = csaps(t(training(:,j)),y(training(:,j)),p,t(test(:,j)));
                end
                cvMse(i) = (sum((y-ypred).^2))./len;
            end
            
        else
            for i = 1:numel(gammaRange)
                p = 1/(1+epsilon*10^(gammaRange(i)));
                regfr=@(Ttrain,Ytrain,Ttest)(csaps(Ttrain,Ytrain,p,Ttest));
                cvMse(i) = crossval('mse',t,y,'predfun',regfr,'kfold',nfold,'mcreps',mcreps);
            end
        end
        cvMse = smoothdata(cvMse,'gaussian',7);
        [minVal,idx] = min(cvMse);
        gamma = gammaRange(idx);
        gamma = (gamma*4)+4;
        
    end




catch
    gamma = NaN;
    cvMse = NaN;
    minVal = NaN;
    epsilon = NaN;
end

warning on   
end

function train = cvmatrix(len,nfold)
    grps = repmat((1:nfold)',ceil(len/nfold),1);
    grps = grps(1:len);
    train = ones(len,nfold);
    for i = 1:nfold
        test = grps == i;
        train(test,i) = 0;
    end
    train = logical(train);
end




