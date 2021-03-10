refs=16000; 
[audio_data,fs] = audioread('audiofile.mp3');
 audio_data = resample(audio_data,refs,fs); %Resampling incoming data
 delete('audiofile.h');
 header_export('audiofile.h','audioval',audio_data(:,2)');
