clear all; clc;
files_pos = dir('audiofiles/*.*');
data_pos = convertCharsToStrings(sprintf('%f',zeros(length(files_pos)-2)));
refs=8000; 

for i=2:length(files_pos)
    if (i<3)
        continue;
    end
    filename_pos = strcat('./audiofiles/',files_pos(i).name);
    [path,file_name,ext]=fileparts(files_pos(i).name);
    header_fil=strcat(file_name,'.h');
    header_file=strcat('./audio_headers/',header_fil);
    data_pos(1,i-2) = convertCharsToStrings(filename_pos);
    header_obj= audioinfo(data_pos(1,i-2));
    [audio_data,fs] = audioread(data_pos(1,i-2));

    if (header_obj.NumChannels==1)
        
        audio_data = resample(audio_data,refs,fs); %Resampling incoming data

    else
        audio_data = resample(audio_data(:,1),refs,fs); %Resampling incoming data
    end
    delete(header_file); 
    header_export(header_file,'audioval',audio_data');
end
