%% Reading *.mp3 files from the directories and make it as string array with file and label.
clear all; clc;
%% Load the data
files_pos = dir('audiofiles/*.*');
% files_neg = dir('negative_samples/*.*');
% label_pos = ones(1,length(files_pos)-2);
% label_neg = zeros(1,length(files_neg)-2);


data_pos = convertCharsToStrings(sprintf('%f',zeros(length(files_pos)-2)));
% data_neg = convertCharsToStrings(sprintf('%f',ones(length(files_pos)-2)));



for i=2:length(files_pos)
    if (i<3)
        continue;
    end
    filename_pos = strcat('./audiofiles/',files_pos(i).name);
    data_pos(1,i-2) = convertCharsToStrings(filename_pos);
end


% 
% for j=2:length(files_neg)
%     if (j<3)
%         continue;
%     end
%     filename_neg = strcat('./negative_samples/',files_neg(j).name);
%     data_neg(1,j-2) = convertCharsToStrings(filename_neg);
% end
% fl_pos = vertcat(data_pos,label_pos);
% fl_neg = vertcat(data_neg,label_neg);
% data_train = horzcat(fl_pos,fl_neg);
% data_train = data_train';
% koala = data_train(randperm(size(data_train,1)),:);
% save('dingo.mat','koala');



