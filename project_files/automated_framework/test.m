
%% Training Configurations
clear all; clc;




%dataset_size=100;
%{
dataset_size=input("Enter Training dataset_size= ");
fs=input("sampling_frequency = ");
frq_low= input("lower frequency = ");
frq_high= input("Higher frequency = ");
filt_prn = input("Enter total number of filters for processing = ");
nstrt= input("Enter start index of the filters for feature extraction =  ");
nend= input("Enter end index of the filters for feature extraction = ");
%}
%dataset=118;

load('variables.mat');
dataset=min_samples;
fs=8000;
frq_low=200;
frq_high=4000;
xlow = log10((frq_low/165.4)+1) / 2.1 ;
xhigh = log10((frq_high/165.4)+1) / 2.1 ;
%fprintf("x_low = %f \nx_high = %f\n",xlow,xhigh);
filt_prn=30;
nstrt=2;
nend=30;

dur = 1;
npoints = floor(fs*dur)    ;        % stimulus length
delete('*.h');
%delete('*.mat');

%%Extracting the classes data and prepare *.mat files for the training.
folders = dir('*_clean_clips_dir');
neg_classes= length(folders) - 1;
neg_class_size= floor(double(dataset)/neg_classes);
dataset_size=neg_class_size * neg_classes;

%extra_samples=mod(dataset_size,neg_classes); 
%%
for i = 1:length(folders)
	class_folder{i}=folders(i).name;
	class_folders{i}=strcat(folders(i).name,'/');
    	class_folders{i}=strcat('./',class_folders{i});
	classes_names{i}=extractBefore(folders(i).name,"_clean_clips_dir");
end
%%

fprintf("*Training of SVM model : \n\n1. Dataset:\n\n");
print_row("   Positive_Samples","Negative_Samples"," ");
%fprintf("Flow(Hz)\tFhigh=%10s\tFs=%10s\n",string(frq_low),string(frq_high),string(fs));
print_row(string(dataset_size),string(dataset_size)," ");fprintf("\n");
fprintf("\n\n2. Filter Parameters:\n\n");
print_row("Flow(Hz)","Fhigh(Hz)","Fs(Hz)")
print_row(string(frq_low),string(frq_high),string(fs));fprintf("\n");
print_row("Total_Filters","Start_Index","End_Index")
%fprintf("Total Filters=%10s\tStartIndex=%10s\tEndIndex=%10s\n",string(filt_prn),string(nstrt),string(nend));
print_row(string(filt_prn),string(nstrt),string(nend));fprintf("\n\n3. Results:\n\n");
print_row("ClassName","TrainError","TestError");
for j = 1:length(class_folder)

	files_pos = dir(class_folders{j}); % check if it is correct
    	%fprintf("Size=%d",size(files_pos.name));
	label_pos=ones(1,dataset_size);label_neg=zeros(1,dataset_size);
	
	data_pos = convertCharsToStrings(sprintf('%f',zeros(dataset_size)));
	data_neg = convertCharsToStrings(sprintf('%f',ones(dataset_size)));
	
	%Positive Samples
	for i=2:(dataset_size+2)
    		if (i<3)
        		continue;
    		end
    		filename_pos = strcat(class_folders{j},files_pos(i).name);
		%fprintf("file:%s\n",files_pos(i).name);
    		data_pos(1,i-2) = convertCharsToStrings(filename_pos);
	end

	%Get negative samples
	m=0;
	for cls = 1:length(classes_names)
		if (cls ~= j)
				
			for k=2:(neg_class_size+2)
    				files_neg=dir(class_folders{cls});
				if (k<3)
        				continue;
    			end
				
    				filename_neg = strcat(class_folders{cls},files_neg(k).name);
    				data_neg(1,(k-2+(m*neg_class_size))) = convertCharsToStrings(filename_neg);
% 				if(cls==length(classes_names)) % Taking extra samples from last class 
% 					for ext_files=1:extra_samples
% 		    				filename_neg = strcat(class_folders{cls},files_neg(k+ext_files).name);
%     						data_neg(1,(k-2+(m*neg_class_size)+ext_files)) = convertCharsToStrings(filename_neg);
% 					end			
% 				end
			end
			m=m+1;
		end
	end
	
	%classes_names{j}


	fl_pos = vertcat(data_pos,label_pos);
	fl_neg = vertcat(data_neg,label_neg);
	data_train = horzcat(fl_pos,fl_neg);
	data_train = data_train';
	%class_files=data_train;
    	class_files = data_train(randperm(size(data_train,1)),:);
    	assignin('base',classes_names{j},class_files);
	mat_file=strcat(classes_names{j},'.mat');
	save(mat_file,classes_names{j});
	

%% Training of every class
    	%fprintf("\n%15s\t\t\t",classes_names{j});
    	%load(mat_file);
    	data_files=eval(classes_names{j});
	species=data_files;
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
%%    
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
	        audio_data = 32767 * audio_data;
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
	%        audio_data = resample(audio_data,refs,fs);
        	audio_data = 32767 * audio_data;
        	fs = refs;
        	Q_test(file,:) =  BM_IHC(audio_data,fs,xlow,xhigh,Ntem,Nstart,Nend);    
    	end

%%%%%%%%%%%%%%%%%% End of Testing Data CAR processing %%%%%%%%%%%%%%%%%%%%

%% SVM training using growth transform and export parameters
    	[alpha,bias,inpB] = SVMTrain(trainx,Ytrain,crossx,Ycross,Ntem,Q_train,Q_test);
    	alpha_class=strcat("alpha_",classes_names{j});
    	bias_class=strcat("bias_",classes_names{j});
    	alpha_filename = strcat(alpha_class,'.h');
    	bias_filename = strcat(bias_class,'.h');
    	file_name1 = convertCharsToStrings(alpha_filename);
    	file_name2 = convertCharsToStrings(bias_filename);
    	header_export(file_name1,alpha_class,alpha);
    	header_export(file_name2,bias_class,bias);
        
        if j==1
            filter_coeff(fs,xlow,xhigh,Ntem,Nstart,Nend);
            car_export("CAR.h",Ntem,Nstart,Nend,xlow,xhigh,fs);
        end
%------------------------------------------------------------------
%% Below is the script to evaluate the performance on training and testing set
%------------------------------------------------------------------

    	[trainresult,crossresult] = SVMInference(Q_train,Q_test,alpha,bias,yindex,ycrossindex,M,N,Ncross);
	print_row(classes_names{j},string(trainresult),string(crossresult));
end
fprintf('\n');





