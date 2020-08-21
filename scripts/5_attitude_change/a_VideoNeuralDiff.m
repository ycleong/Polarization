%% videoByvideo
% Step 1. 
clear all

addpath(genpath('../9_NIFTI_tools'));
addpath(genpath('../9_help_scripts'));

dirs.fMRI = '../../data/fmri/movie_data/';
dirs.roi = '../../data/fmri/masks/roi/';
dirs.bids = '../../Polarization';
dirs.roi_tc = '../../data/fmri/roi_tc/';

roi = 'DMPFC';

%% Get group assignments
subjects=[1004, 1005, 1006, 1007, 1008, 1009, 1011, 1012, 1014, 1015, 1016, 1017, 1018, 1019, 1020, 1021, 1022, 1023, 1024, ...
    1026, 1027, 1028, 1029, 1030, 1031, 1032, 1033, 1034, 1035, 1036, 1037, 1038, 1039, 1040, 1041, 1042, 1043, 1044];    

nSub = length(subjects);

participants_file = tdfread(fullfile(dirs.bids,'participants.tsv'));
participants_file.l_index = participants_file.ImmScore < median(participants_file.ImmScore);
participants_file.r_index = participants_file.ImmScore > median(participants_file.ImmScore);

l_id = cellstr(participants_file.participant_id(participants_file.l_index,:));
r_id = cellstr(participants_file.participant_id(participants_file.r_index,:));
all_id = cellstr(participants_file.participant_id);

left = subjects(ismember(all_id,l_id));
right = subjects(ismember(all_id,r_id));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Calculate Liberal and Conservative Similarity
load(fullfile(dirs.roi_tc,roi,sprintf('%s.mat', roi)));   
load('../../data/semantic_categories/movie_duration.mat');

%% Compute timecourse of differences (1062 resolution)

% Subject Indices
left_sub = ismember(subjects,left);
right_sub = ismember(subjects,right);

% Initialize output:
% Subject, Movie, Liberal Sim, Conservative Sim 
VideoNeural = []; 

for s = 1:nSub

    for m = 1:24
       
        this_sub = subjects(s);
        this_movie = m;
        
        % Subject Indices
        left_sub = ismember(subjects,left);
        right_sub = ismember(subjects,right);
        
        left_sub(s) = 0;
        right_sub(s) = 0;

        % Get movie similarity
        m_start = cum_stim_duration(m); 
        m_end =  cum_stim_duration(m+1); 
        
        sub_tc = roi_tc(m_start:m_end,s);
        liberal_tc = mean(roi_tc(m_start:m_end,left_sub),2);        
        conservative_tc = mean(roi_tc(m_start:m_end,right_sub),2);    
        
        liberal_sim = corr(sub_tc, liberal_tc);
        conservative_sim = corr(sub_tc, conservative_tc);

        this_data = [this_sub,this_movie,liberal_sim,conservative_sim];
        
        VideoNeural = [VideoNeural; this_data];
    end

end

VideoNeural(:,5) = VideoNeural(:,3) - VideoNeural(:,4);

csvwrite(fullfile(dirs.roi_tc,roi,sprintf('%s_VideoNeuralDiff.csv', roi)), VideoNeural);