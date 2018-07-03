% dynamic expression
% only one eye is tracked
% screen = 39 cm width, screen resolution 1920*1080, 120 Hz
% video size: 576*760, 30fp
% Clear Matlab/Octave window:

%%
'Preference', 'SkipSyncTests', 1

ScreenX=34;
ScreenY=28;
PixelX=1080;
PixelY=900;
% setting the size of the stimuli at a distance of 60cm
% scale=3;
% pixel --> aller regarder la r?solution de l'?cran ex: 1400 x900
% sur le Mac Book Air Screen X= 28.8; Screen Y= 18
% scale= (3*18/28)*(1400/900);
scale=(3*ScreenY/ScreenX)*(PixelX/PixelY);


clear all;
clc;
ex=4;% happy
Screen('Preference', 'SkipSyncTests', 1);
% setup experiment

practicerun = str2double(input('is it a practise run (1) or a real experiment (2)?: ','s'));
if practicerun==2
    subInitials = input('participant''s name: ','s');
    subage = input('participant''s age: ','s');
    subgender = input('participant''s gender: (1 Female 2 Male) ','s');
    newexp = str2double(input('is it a new participant (1) or a continue participant (2)?: ','s'));
    % eyetracking = str2double(input('enter 1 to use eyetracker: ','s'));
    eyetracking = 0;
    
    filename = sprintf('%s',subInitials);
    % create text file for data and parameters recording
    datatxt=[filename '_g' subgender '_a' subage '_DyExp_beh.txt'];
else
    % eyetracking = str2double(input('enter 1 to use eyetracker: ','s'));
    eyetracking = 0;
    newexp=1;
    filename='pracseq';
    datatxt=[filename '_DyExp_beh.txt'];
end

Nblock=2;
Ntrial=8;% 8*2 item in total per block
Nexpall=Nblock*Ntrial;
if newexp==1
    randseq=randperm(Nexpall);
    ii2=0;
    save([filename,'.mat'],'ii2','randseq') %saves the index and the scumble of 1:2*6*8 in a pracseq.mat
else
    try
        load([filename,'.mat']);
    catch
        randseq=randperm(Nexpall);
        ii2=0;
        save([filename,'.mat'],'ii2','randseq')
    end
end

distdrift=50000;
seuildrift=75;
drifthres=200;
% video scale
fps1=30; % refresh rate for the movie

% load videos
folder=cd;
% VideoMatns=load('JOV2013ExpressionStimuli-3.mat');
% VideoMatns=rmfield(VideoMatns,'randomsequences');


    load('VideoMatnd.mat')
    load('VideoMatns.mat')


expressions=fieldnames(VideoMatns);
type={'Static','Dynamics'}; %list of types
orientation={'Straight','Inverted'}; %list of orientation
itemall=fieldnames(VideoMatns.Anger); %list of actors


Nrep=Ntrial;
ii=0;
clear exptable;


     for itype=1:length(type)
         for iori=1:length(orientation)
            for iitem=1:length(itemall)
            ii=ii+1;
            exptable(ii,1)=type(itype);
            exptable(ii,2)=orientation(iori);
            exptable(ii,3)=itemall(iitem);
            end
         end
     end


for ie=1:length(expressions),  for ia=1:length(itemall)
    allvideo.(expressions{ie}).Static.Straight.(itemall{ia})=VideoMatns.(expressions{ie}).(itemall{ia});
    for ic=1:30
    allvideo.(expressions{ie}).Static.Inverted.(itemall{ia})(:,:,ic)=flipud(squeeze(VideoMatns.(expressions{ie}).(itemall{ia})(:,:,ic)));
    end
    allvideo.(expressions{ie}).Dynamics.Straight.(itemall{ia})=VideoMatnd.(expressions{ie}).(itemall{ia});
    for ic=1:30
    allvideo.(expressions{ie}).Dynamics.Inverted.(itemall{ia})(:,:,ic)=flipud(squeeze(VideoMatnd.(expressions{ie}).(itemall{ia})(:,:,ic)));
    end
end,end

listGen   =[{'Static.Straight'  }    {'Static.Straight'}
            {'Static.Straight'  }    {'Static.Straight'}
            {'Static.Inverted'  }    {'Static.Straight'}
            {'Static.Inverted'  }    {'Static.Straight'}
            {'Dynamics.Straight'}    {'Static.Straight'}
            {'Dynamics.Straight'}    {'Static.Straight'}
            {'Dynamics.Inverted'}    {'Static.Straight'}
            {'Dynamics.Inverted'}    {'Static.Straight'}];
        
listGen=[listGen;listGen];
    
for i=1:16
    rind=randperm(6);
    actlist(i,1:2)=rind(1:2);
end
    
for i=1:16
    listGen(i,1)=strcat(listGen(i,1),'.',itemall(actlist(i,1)));
    if mod(i,2)==0
    listGen(i,2)=strcat(listGen(i,2),'.',itemall(actlist(i,2)));
    else
    listGen(i,2)=strcat(listGen(i,2), '.',itemall(actlist(i,1)));
    end
end
%created a cell struct with all the 96 combo of express and actors in order (twice any)
load Mask.mat
% check for Opengl compatibility, abort otherwise:
AssertOpenGL;

% Reseed the random-number generator for each expt.
rand('state',sum(100*clock));
%% EyeLink Stuff
    screenNumber=max(Screen('Screens')); %select the screen
    [mainw, wRect]=Screen('OpenWindow', screenNumber, 0,[],32,2); %open the experiment pn the most right screen, 0,[],32,2 ?
    ifi=Screen('GetFlipInterval', mainw); %0.0197= 50.6896 Hz
    waitframe=round(1/fps1/ifi);% at refresh rate 60HZ=0.0167
    % hide mouse cursor
    HideCursor; %opposite of
    ShowCursor;

%%
% set screen
Screen('FillRect', mainw, [255/2 255/2 255/2 0]);% black screen (actually grey)
Screen('Flip', mainw);
% % second screen for optimal synchronization purpose.
% white=WhiteIndex(1);
% [w2, wRect2]=Screen('OpenWindow',1, white);%%% ,[0 0 800 600]

%% reaction key
% Make sure keyboard mapping is the same on all supported operating systems
% Apple MacOS/X, MS-Windows and GNU/Linux:
KbName('UnifyKeyNames');


breakcode=KbName('q');% breakkey

% screen size
screenx=0.5*wRect(3);
screeny=0.5*wRect(4);

%% introduction
instru_v = ['The experiment is about to start...'];
% Write instruction message for subject, nicely centered in the
% middle of the display, in white color. As usual, the special
% character '\n' introduces a line-break:
Screen('TextSize', mainw, 50);
DrawFormattedText(mainw, instru_v, 'center', 'center', WhiteIndex(mainw));
Screen('Flip', mainw);

% Wait for mouse click:
GetClicks(mainw);

% Clear screen to background color (our 'white' as set at the
% beginning):
Screen('Flip', mainw);

% Wait a second before starting trial
WaitSecs(1.000);

%% main experiment
while ii2<Nexpall
    ii2=ii2+1;
    %         DrawFormattedText(w2, num2str(itrial), 'center', 'center', BlackIndex(w2));
    %         Screen('Flip', w2);
    po=randperm(16);
    [KeyIsDown, vert, KeyCode]=KbCheck;
    Screen('TextSize', mainw, 50);
    DrawFormattedText(mainw, '+', 'center', 'center', WhiteIndex(mainw)); % fixation
    [VBLTimestamp startrt2] = Screen('Flip', mainw); %startrt2 is when the cross is shown
    
        while (GetSecs - startrt2)<0.3 %----------------------------------------------------------presentation of cross for 0.3s
            [KeyIsDown, endrt2, KeyCode]=KbCheck;
        end
 
    if KeyCode(breakcode)==1
        break
    end
    eval(['videotmp=allvideo.' expressions{ex} '.' listGen{po(ii2),1} ';']) %expressions in order but actors random

    %     if exptype==2
%         videotmp=videotmp(:,:,randperm(30));
%     end
    videotmp(mask==0)=255/2;
    
    % load first frame
ScreenX=34;
ScreenY=28;
PixelX=1080;
PixelY=900;
% setting the size of the stimuli at a distance of 60cm
% scale=3;
% pixel --> aller regarder la r?solution de l'?cran ex: 1400 x900
% sur le Mac Book Air Screen X= 28.8; Screen Y= 18
% scale= (3*18/28)*(1400/900);
scale=(3*ScreenY/ScreenX)*(PixelX/PixelY);
[height1,width1,counts]=size(videotmp);
width2=width1*scale;
height2=height1*scale;
    

        r1=[screenx,screeny];
        cRect1=SetRect(r1(1)-width2/2, r1(2)-height2/2, r1(1)+width2/2, r1(2)+height2/2);

    
    debtrial=GetSecs;
    currenttime=debtrial;
    oldtime=debtrial;
    echantillon=0;
    tvbl = Screen('Flip', mainw);
    
    
    %% Playback loop: Runs until end of movie
    for iframe=1:counts
        imdata1=squeeze(videotmp(:,:,iframe));
        tex1=Screen('MakeTexture', mainw, imdata1);
        % Draw the new texture immediately to screen:
        Screen('DrawTexture', mainw, tex1, [], cRect1);
        %             % Draw border
        %             Screen('FrameRect', mainw, [255 255 255],cRect1, 5);
        % Update display:

            tvbl = Screen('Flip', mainw, tvbl + ifi*(waitframe-2)); 
  
        % Release texture:
        Screen('Close', tex1);
    end
    
    %%
    
    Screen('TextSize', mainw, 50);
    DrawFormattedText(mainw, '+', 'center', 'center', WhiteIndex(mainw)); % fixation
    [VBLTimestamp, startrt2] = Screen('Flip', mainw); %startrt2 is when the cross is shown
            while (GetSecs - startrt2)<0.3 %----------------------------------------------------------presentation of cross for 0.3s
            [KeyIsDown, endrt2, KeyCode]=KbCheck;
        end

 
    %% Playback loop: Runs until end of movie
        eval(['videotmp=allvideo.' expressions{ex} '.' listGen{po(ii2),2} ';']) %expressions in order but actors random

    %     if exptype==2
%         videotmp=videotmp(:,:,randperm(30));
%     end
    videotmp(mask==0)=255/2;
    
    % load first frame
ScreenX=34;
ScreenY=28;
PixelX=1080;
PixelY=900;
% setting the size of the stimuli at a distance of 60cm
% scale=3;
% pixel --> aller regarder la r?solution de l'?cran ex: 1400 x900
% sur le Mac Book Air Screen X= 28.8; Screen Y= 18
% scale= (3*18/28)*(1400/900);
scale=(3*ScreenY/ScreenX)*(PixelX/PixelY);
[height1,width1,counts]=size(videotmp);
width2=width1*scale;
height2=height1*scale;
    

        r1=[screenx,screeny];
        cRect1=SetRect(r1(1)-width2/2, r1(2)-height2/2, r1(1)+width2/2, r1(2)+height2/2);

    
    debtrial=GetSecs;
    currenttime=debtrial;
    oldtime=debtrial;
    echantillon=0;
    tvbl = Screen('Flip', mainw);
    
    
    for iframe=1:counts
        imdata1=squeeze(videotmp(:,:,iframe));
        tex1=Screen('MakeTexture', mainw, imdata1);
        % Draw the new texture immediately to screen:
        Screen('DrawTexture', mainw, tex1, [], cRect1);
        %             % Draw border
        %             Screen('FrameRect', mainw, [255 255 255],cRect1, 5);
        % Update display:

            tvbl = Screen('Flip', mainw, tvbl + ifi*(waitframe-2)); 
  
        % Release texture:
        Screen('Close', tex1);
    end
        Screen('TextSize', mainw, 50);
    DrawFormattedText(mainw, '+', 'center', 'center', WhiteIndex(mainw)); % fixation
    [VBLTimestamp, startrt2] = Screen('Flip', mainw); %startrt2 is when the cross is shown
        while (GetSecs - startrt2)<1 %----------------------------------------------------------presentation of cross for 1 extra s
            [KeyIsDown, endrt2, KeyCode]=KbCheck;
        end

    
    if practicerun==1 && ii2>15
        break
    end
    if ii2==Nexpall/2
        instru_v = ['The next block will start soon...'];
        % Write instruction message for subject, nicely centered in the
        % middle of the display, in white color. As usual, the special
        % character '\n' introduces a line-break:
        Screen('TextSize', mainw, 50);
        DrawFormattedText(mainw, instru_v, 'center', 'center', WhiteIndex(mainw));
        Screen('Flip', mainw);
        
        % Wait for mouse click:
        GetClicks(mainw);
        
        % Clear screen to background color (our 'white' as set at the
        % beginning):
        Screen('Flip', mainw);
        
        % Wait a second before starting trial
        WaitSecs(1.000);
    end
end

Screen('TextSize', mainw, 50);
KbCheck;
WaitSecs(0.1);
endword = ['Please wait...'];
% Write instruction message for subject, nicely centered in the
% middle of the display, in black color. As usual, the special
% character '\n' introduces a line-break:
DrawFormattedText(mainw, endword, 'center', 'center', WhiteIndex(mainw));

% Update the display to show the instruction text:
Screen('Flip', mainw);

% Wait 1 sec
WaitSecs(1);


fclose('all');
Screen('Closeall');
ShowCursor;