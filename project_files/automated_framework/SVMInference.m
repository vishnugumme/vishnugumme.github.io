function[trainresult,crossresult] = SVMInference(Q_train,Q_test,alpha,bias,yindex,ycrossindex,M,N,Ncross) 

    %fprintf('Evaluating Performance on Training set\n');
    errordist = zeros(1,M);
    error = 0;
    etotal = zeros(1,M);
    confusionTrain = zeros(M,M);

    result = Q_train*alpha + ones(N,1)*bias;

    for k = 1:N,
       [maxval,ind] = max(result(k,:));
       etotal(yindex(k)) = etotal(yindex(k)) + 1;
       confusionTrain(ind,yindex(k)) = confusionTrain(ind,yindex(k)) + 1;
       if ind ~= yindex(k),
          error = error + 1;
          errordist(yindex(k)) = errordist(yindex(k)) + 1;
       end;
    end;
    %fprintf('Multi-class Train Error = %d percent \n',ceil((error/N)*100));
    for i = 1:M,
       %fprintf('Class %d: Total Data = %d; Error = %d percent \n',i,etotal(i),floor((errordist(i)/(etotal(i)+1e-9))*100));
    end;
    trainresult = ceil((error/N)*100);
    clear result resultmargin;

    % Now print the confusion matrix after normalization
    confusionTrain = confusionTrain./(ones(M,1)*(etotal+1e-9))*100;
    %fprintf('Training Confusion Matrix\n');
    floor(confusionTrain);


    %------------------------------------------------------------------
    % Below is the script to evaluate the performance on validation set
    %------------------------------------------------------------------
    %fprintf('Evaluating Performance on Cross-validation set\n');
    errordist = zeros(1,M);
    error = 0;
    etotalcross = zeros(1,M);
    confusionCross = zeros(M,M);

    result = Q_test*alpha + ones(Ncross,1)*bias;

    for k = 1:Ncross,
       [maxval,ind] = max(result(k,:));
       etotalcross(ycrossindex(k)) = etotalcross(ycrossindex(k)) + 1;
       confusionCross(ind,ycrossindex(k)) = confusionCross(ind,ycrossindex(k)) + 1;
       if ind ~= ycrossindex(k),
          error = error + 1;
          errordist(ycrossindex(k)) = errordist(ycrossindex(k)) + 1;
       end;
    end;
    %fprintf('Multi-class Cross-validation Error = %d percent \n',ceil((error/Ncross)*100));
    for i = 1:M,
       %fprintf('Class %d: Total Data = %d; Error = %d percent \n',i,etotalcross(i),floor((errordist(i)/(etotalcross(i)+1e-9))*100));
    end;
    crossresult = ceil((error/Ncross)*100);
    clear result resultmargin;

    % Now print the confusion matrix after normalization
    confusionCross = confusionCross./(ones(M,1)*(etotalcross+1e-9))*100;
    %fprintf('Cross-validation Confusion Matrix\n');
    floor(confusionCross);
    
end
