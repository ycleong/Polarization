%% get_movie data
% Saves each movie into separate .mat file 
%   3 TRs cropped in FSL, shifted by 2 TRs because of HRF (4 seconds)
%   So basically 3 - 2 + 1, hence no need to shift :D!

clear all

dirs.fMRI = '../../data/fmri/glm/transformed_mat';
dirs.bids = '../../Polarization';
dirs.result = '../../data/fmri/movie_data/';

addpath(genpath('../../scripts/9_NIFTI_tools'));   % nifti_toolbox, download from: 
                                                   %   https://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image

subjects=[1004, 1005, 1006, 1007, 1008, 1009, 1011, 1012, 1014, 1015, 1016, 1017, 1018, 1019, 1020, 1021, 1022, 1023, 1024, ...
    1026, 1027, 1028, 1029, 1030, 1031, 1032, 1033, 1034, 1035, 1036, 1037, 1038, 1039, 1040, 1041, 1042, 1043, 1044];                                                

nSub = length(subjects);


for s = 1:nSub
    
    sub = num2str(subjects(s));
    
    fprintf('Running Subject %s \n', sub);
    
    % Make output directory if it doesn't exit
    savepath = fullfile(dirs.result,sub);
    if ~exist(savepath), mkdir(savepath); end
    
    for r = 1:4
        % load fmri data
        thisFMRI_path = fullfile(dirs.fMRI,sub,sprintf('run%i.mat',r)); 
        load(thisFMRI_path);
        
        % load behavioral data
        thisEvent = tdfread(fullfile(dirs.bids,sprintf('sub-%s',sub),'func',sprintf('sub-%s_task-run%i_events.tsv',sub,r)));
                
        % Save video data
        for v = 1:6
            Stim = thisEvent.video(v);
            StimOn = round(thisEvent.onset(v)/2);
            StimOff = StimOn + round(thisEvent.duration(v)/2) - 1;
             
            movie_data = small_data(:,StimOn:StimOff);
            
            datasize(4) = size(movie_data,2);
            
            save(fullfile(savepath,sprintf('video%i.mat',Stim)),'movie_data','datasize','keptvox');  

        end
        
    end
end
