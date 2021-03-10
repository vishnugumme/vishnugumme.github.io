#!/usr/bin/python3

"""
Creating the Audio dataset from the new_recording and class name provided by the user

"""


from pydub import AudioSegment
from pydub.utils import make_chunks
from pydub.silence import split_on_silence
from pydub.playback import play
import os
import wave
import pylab
import shutil
from stft_plot1 import plotstft
import glob
from tqdm import tqdm
#import matlab.engine
import matplotlib.pyplot as plt
import scipy.io as io
from scipy.io import wavfile, savemat
from scipy.fftpack import fft,fftfreq
import numpy as np
import random
import playsound
"""
# 3 string @input : To just print in one row with some space
"""
def print_row(filename, status, file_type):
    print (" %-45s %-15s %15s" % (filename, status, file_type))


"""
Directory @input: Full path of thre Directory where .wav files are present
"""
def fftplot_wavfile(Directory):
    original_rec_array=glob.glob(Directory + "*.wav" );
    #print(type(original_rec_array))
    for original_rec_names in original_rec_array:
        input_file=original_rec_names;
        #print(input_file)
        samplerate, data = wavfile.read(input_file)
        samples = data.shape[0]
        #plt.plot(data[:200])
        datafft = fft(data)
        fftabs = abs(datafft)
        freqs = fftfreq(samples,1/samplerate)
        #plt.plot(freqs,fftabs)
        plt.xlim( [10, samplerate/2])
        plt.xscale( 'log' )
        plt.grid( True )
        plt.xlabel( 'Frequency (Hz)')
        plt.plot(freqs[:int(freqs.size/2)],fftabs[:int(freqs.size/2)])
        plt.savefig(os.path.splitext(input_file)[0]+'FFT.png');
    plt.close()



if __name__ == "__main__":
    #Remove the old workspace files
    os.system("./clean.sh");

    #Get to know the number and name of the classes the user provided
    classes=[]
    for filename in glob.glob("*_original_rec_dir"):
        classes.append(filename.split('_')[0])

    #Proceed with recordings of every class provided by user
    print("\n*Creating the datset for %d classes : " % len(classes));
    min_samples=10000;
    for class_name in classes:
        print("#CLASS :");
        total_samples=0;

        #Build workspace with folders corresponding to each class provided
        clips_dir=class_name+"_clips_dir/";
        clean_clips_dir=class_name+"_clean_clips_dir/";
        clean_rec_dir=class_name+ "_cleaned_rec_dir/";
        original_rec_dir=class_name + "_original_rec_dir/";
        #print(original_rec_dir);
        fftplot_wavfile(original_rec_dir);
        if os.path.isdir(clips_dir):
            shutil.rmtree(clips_dir)
        os.mkdir(clips_dir)

        if os.path.isdir(clean_clips_dir):
            shutil.rmtree(clean_clips_dir)
        os.mkdir(clean_clips_dir)

        if os.path.isdir(clean_rec_dir):
            shutil.rmtree(clean_rec_dir)
        os.mkdir(clean_rec_dir)
        #Proceed with the every recordings of the particular class
        original_rec_array=glob.glob(original_rec_dir + "*.wav" );
        for original_rec_names in tqdm(original_rec_array,class_name):
            input_file=original_rec_names;
            audio = AudioSegment.from_file(input_file , "wav")
            plotstft(audiopath=input_file,plotpath=os.path.splitext(input_file)[0]+'_Spect.png');
            myaudio=audio[500:] #Removing first 0.5 sec of the data which is not desirable
            combined_sound = AudioSegment.empty()

            #Remove the silent/noisy part of the recording 
            if class_name =="noise":
                combined_sound=myaudio;
                head,input_file = os.path.split(original_rec_names)


            else:
                chunks = split_on_silence(
                myaudio,

                # split on silences longer than 1000ms (1 sec)
                min_silence_len=200,#1/5KHZ splitting

                # anything under -16 dBFS is considered silence
                silence_thresh=-45,

                # keep 200 ms of leading/trailing silence
                keep_silence=0
                )
                for i, chunk in enumerate(chunks):
                    combined_sound += chunk
                head,input_file = os.path.split(original_rec_names)
                #print(original_rec_names)
                outfile=clean_rec_dir+input_file
                combined_sound.export(outfile,format='wav');
                plotstft(audiopath=outfile,plotpath=os.path.splitext(outfile)[0]+'_Spect.png');

            #Make samples of 1 sec and save it to the corresponding class folder
            new_recording=combined_sound[:((len(combined_sound)//1000)*1000)]
            chunk_length_ms = 1000 # pydub calculates in millisec
            chunks = make_chunks(new_recording, chunk_length_ms) #Make chunks of one sec
            total_samples=(2*len(chunks)-1)+total_samples;
            for i, chunk in enumerate(chunks):
                chunk_name = clips_dir+(os.path.splitext(input_file)[0])+"_{0}.wav".format(i)
                chunk.export(chunk_name, format="wav")

            #Make samples of 1 sec with overallping of 0.5 seconds and save it to the corresponding class folder
            duration=len(new_recording)
            new_recording1=new_recording[500:duration-500]
            chunks = make_chunks(new_recording1, chunk_length_ms) #Make chunks of one sec
            for i, chunk in enumerate(chunks):
                chunk_name = clips_dir+(os.path.splitext(input_file)[0])+"_ov{0}.wav".format(i)
                chunk.export(chunk_name, format="wav")


    #Show User results 
        print_row("\n\tClassName", "Status", "SampleSize");
        print_row("\n\t"+class_name ,"DONE",str(total_samples)+"\n\n");
        fftplot_wavfile(clean_rec_dir);

        DatasetSize=input("How many clean samples needed to extract :");
        clips_array=glob.glob(clips_dir + "*.wav" );
        done=True;
        random.shuffle(clips_array);
        clips_cnt=0;
        print("*Option 1 for play Clip \n\t2 for keep Clip\n\t3 for remove the clip \n\t4 for save all clips \n\t5 for help ")
        rest_all=0;
        for clip in clips_array:
            audio_clip = AudioSegment.from_file(clip , "wav")
            head,clip_name1=os.path.split(clip)
            print("\n*Clip ["+str(clips_cnt+1)+"] "+clip_name1);
            if rest_all==1:
                clip_name = clean_clips_dir+clip_name1;
                audio_clip.export(clip_name,format="wav");
                clips_cnt=clips_cnt+1;
                while_loop=False;
                print("\tSaved : "+ clip_name1)

            else:
                while_loop=True;
                print("\tPlaying : "+clip_name1)
                #play(audio_clip)
                playsound.playsound(clip)

            while(while_loop):
                option_input=input(" \n\tOption : ")
                if option_input=='1':
                    print("\tPlaying : "+clip_name1)
                    #play(audio_clip)
                    playsound.playsound(clip)
                elif option_input=='2':
                    clip_name = clean_clips_dir+clip_name1;
                    audio_clip.export(clip_name,format="wav");
                    clips_cnt=clips_cnt+1;
                    while_loop=False;
                    print("\tSaved : "+ clip_name1)
                elif option_input=='3':
                    while_loop=False;
                    print("\tRemoved : "+ clip_name1)
                elif option_input=='4':
                    clip_name = clean_clips_dir+clip_name1;
                    audio_clip.export(clip_name,format="wav");
                    clips_cnt=clips_cnt+1;
                    while_loop=False;
                    print("\tSaved : "+ clip_name1)
                    rest_all=1;
                elif option_input=='5':
                    print("\tOption 1 for play Clip \n\t\t2 for keep Clip\n\t\t3 for remove the clip \n\t\t4 for save all clips \n\t\t5 for help ")
                else:
                    print("\nInvalid Option !!\nEnter option 5 for help");

            if str(clips_cnt)==DatasetSize:
                print("\n*Completed aquiring " +str(clips_cnt)+" Clips of "+ class_name+" Class\n\n");
                break;

        #Find out the less count of the samples among all the classes and export to matlab script for the training
        min_samples=int(DatasetSize) if min_samples > int(DatasetSize) else min_samples;
        var={}
        var['min_samples']=min_samples;
        io.savemat("variables.mat",var);
