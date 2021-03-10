%function carihcsvm(filename)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%clear all; 
%close all;
%%%%%%%%%%%%%%%%Configuration for different data_set%%%%%%%%%%%%%%%
%%Calculating the x low and x hight

%fs = 16000.0      ;            % sample frequency
fs=input("sampling_frequency = ");
frq_low= input("lower frequency = ");
frq_high= input("Higher frequency = ");
xlow = log10((frq_low/165.4)+1) / 2.1 ;
xhigh = log10((frq_high/165.4)+1) / 2.1 ;
%xlow = 0.01;
%xhigh = 0.65;
fprintf("x_low = %f \nx_high = %f\n",xlow,xhigh);

filt_prn = input("Enter total number of filters for processing = ");
nstrt= input("Enter start index of the filters for feature extraction =  ");

nend= input("Enter end index of the filters for feature extraction = ");




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fs = 16000.0      ;            % sample frequency
dur = 1;
npoints = floor(fs*dur)    ;        % stimulus length
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load('koala.mat'); % The mat file is generated in Linux. It will 
                            % change for windows. Load the mat file once 
                            % to see what is the path.`
delete('*.h');
fprintf("\nSpecies Name\tTraining Error\tTesting Error\n");
for n = 1:4
    switch n
        case 1
            load('koala.mat');
            species=koala;
            fprintf("\nKoala\t\t");
        case 2
            load('dingo.mat');
            species=dingo;
            fprintf("\nDingo\t\t");
        case 3
            load('fox.mat');
            species=fox;
            fprintf("\nFox\t\t");
        case 4
            load('kangaroo.mat');
            species=kangaroo;
            fprintf("\nKangaroo\t");
    end
    
    yout1 = str2double(species(:,2));
    Yout1 = zeros(length(yout1),2);

    %One-Hot Encoding
    for i = 1:length(yout1)
        if(yout1(i))
            Yout1(i,1) = 1;
        else
            Yout1(i,2) = 1;
        end
    end

    total_samples = length(species);
    trdata_num = floor(0.7*total_samples);
    tedata_num = total_samples-trdata_num;

    %Generating the training and testing dataset
    trainx = species(1:trdata_num,1);
    Ytrain = Yout1(1:trdata_num,:);

    crossx = species(trdata_num+1:total_samples,1);
    Ycross = Yout1(trdata_num+1:total_samples,:);

    [N,D] = size(trainx);
    [Ny,M] = size(Ytrain);

    % Fitler Characteristics. Change these to impact the BM filters for fine 
    % tuning based on the dataset

    Nfilt = nend-nstrt+1; %Number of filters for feature extraction
    Ntem = filt_prn;  %Number of filters for processing
    Nstart = nstrt; %Start filter
    Nend = nend;  %End Filter

    if Nfilt ~= (Nend - Nstart + 1)
        error('Incorrect filter Numbers')
        
    end

    %xlow = 0.01;               %lowest frequency position along the cochlea
    %xhigh = 0.65;              %highest frequency position along the cochlea

    npoints = floor(fs);
    refs = fs;         % Resampled frequency       

    if Ny ~= N
        error('Training Data size neq labels');
    end

    [Ncross,D] = size(crossx);
    [Nycross,M] = size(Ycross);
    if Nycross ~= Ncross
        error('Cross-validation Data size neq labels');
    end

    for i = 1:N
        [val,yindex(i)] = max(Ytrain(i,:) + 1e-6*rand(1,M));
    end

    for i = 1:Ncross
        [val,ycrossindex(i)] = max(Ycross(i,:) + 1e-6*rand(1,M));
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Training Data CAR processing %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %fprintf("Training Data CAR processing\n");
    [L,Ntr] = size(trainx);
    Q_train = zeros(L,Nfilt);

    for file = 1:L  
        filename = trainx(file); % Mat files have individual 1 sec files
        [audio_data,fs] = audioread(filename);
%         audio_data = resample(audio_data,refs,fs); %Resampling incoming data
%         if file == 15
%             delete('test5.h');
%             header_export('test5.h','samples',audio_data(:,2)');
%             audiowrite('test5.wav',audio_data,refs);
%         end
        %audio_data = 32767 * audio_data;
        fs = refs;
        Q_train(file,:) =  BM_IHC(audio_data,fs,xlow,xhigh,Ntem,Nstart,Nend);     
    end
%%%%%%%%%%%%%%%% End of Training Data CAR processing %%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Testing Data CAR processing %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %fprintf("Testing Data CAR processing\n");
    [L,Nc] = size(crossx);
    Q_test = zeros(L,Nfilt);

    for file = 1:L
        filename = crossx(file);
        [audio_data,fs] = audioread(filename);
%         audio_data = resample(audio_data,refs,fs);
        %audio_data = 32767 * audio_data;
        fs = refs;
        Q_test(file,:) =  BM_IHC(audio_data,fs,xlow,xhigh,Ntem,Nstart,Nend);    
    end

%%%%%%%%%%%%%%%%%% End of Testing Data CAR processing %%%%%%%%%%%%%%%%%%%%


    % SVM training using growth transform
    [alpha,bias,inpB] = SVMTrain(trainx,Ytrain,crossx,Ycross,Ntem,Q_train,Q_test);
    class = ["alpha_koala","alpha_dingo","alpha_fox","alpha_kangaroo";"bias_koala","bias_dingo","bias_fox","bias_kangaroo"];
    filename1 = strcat(class,'.h');
    file_name = convertCharsToStrings(filename1);
    %delete('*.h');       
    %delete('bias.h');
    %delete('kernals.h');        
    header_export(file_name(1,n),class(1,n),alpha);
    header_export(file_name(2,n),class(2,n),bias);
    %header_export('kernals.h','kernals',Q_train(15,:));

%------------------------------------------------------------------
% Below is the script to evaluate the performance on training and testing set
%------------------------------------------------------------------

    [trainresult,crossresult] = SVMInference(Q_train,Q_test,alpha,bias,yindex,ycrossindex,M,N,Ncross);
    
    
    
    fprintf('%d\t%d',trainresult,crossresult);
end
    fprintf('\n');


        




            
