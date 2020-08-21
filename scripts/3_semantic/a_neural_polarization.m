%% Neural Polarization
% Extract DMPFC timecourse for each participant
% Compute neural polarization as the absolute difference between average conservative - average liberal tc

clear all

addpath(genpath('../9_NIFTI_tools'));
addpath(genpath('../9_help_scripts'));

dirs.fMRI = '../../data/fmri/movie_data/';
dirs.roi = '../../data/fmri/masks/roi/';
dirs.bids = '../../Polarization';
dirs.roi_tc = '../../data/fmri/roi_tc/';
dirs.semantic = '../../data/semantic_categories';
roi = 'DMPFC';

extract_roi_tc = 0;

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

%% Extract roi timecourse
if extract_roi_tc 
    
    % Load mask
    mask_struc = load_nii(fullfile(dirs.roi,sprintf('%s.nii',roi)));
    mask_4d = mask_struc.img;
    mask_dimensions = size(mask_struc.img);
    mask = logical(reshape(mask_4d,[mask_dimensions(1)*mask_dimensions(2)*mask_dimensions(3),1]));

    for s = 1:nSub

        % Load subject's data
        sub = num2str(subjects(s));
        fprintf('Running Subject %s \n', sub);
        load(fullfile(dirs.fMRI,sub,'allvideos.mat'))

        % Resize subject's data into whole brain
        data = zeros(length(keptvox),datasize(4));
        data(keptvox,:) = allvideos;

        % Mask data
        roi_tc(:,s) = mean(data(mask,:));
        subject_list(1,s) = subjects(s);

    end

    save(fullfile(dirs.roi_tc,roi,sprintf('%s.mat', roi)), 'roi_tc', 'subject_list');

end

%% Compute Neural polarization
% Initialize output:
% Movie x Time x Liberal x Conservative  
neu_pol = NaN(1062, 5);

load(fullfile(dirs.roi_tc,roi,sprintf('%s.mat', roi)));   
load(fullfile(dirs.semantic,'movie_duration.mat'));

% Subject Indices
left_sub = ismember(subjects,left);
right_sub = ismember(subjects,right);

% Calculate mean timecourse by group
neu_pol(:,3) = mean(roi_tc(:,left_sub),2);
neu_pol(:,4) = mean(roi_tc(:,right_sub),2);
neu_pol(:,5) = abs(neu_pol(:,3) - neu_pol(:,4));

% Calculate movie timing
t = 1;

for m = 1:24
    m_start = cum_stim_duration(m); 
    m_end =  cum_stim_duration(m+1); 

    mt = 1;
    
    while t <= m_end
        neu_pol(t,1) = m;
        neu_pol(t,2) = mt;
        t = t + 1;
        mt = mt + 1;
    end
      
end

neu_pol(:,2) = (neu_pol(:,2) - 1) * 2;

% Create final file
event_file = csvread(fullfile(dirs.semantic,'segment_info.csv'));
event_tr = event_file(:,1:2) / 2;

for t = 1:length(event_file)
    
    onset = event_tr(t,1) + 1;
    offset = event_tr(t,2);
    
    event_file(t,6) =  mean(neu_pol(onset:offset, 3));      
    event_file(t,7) =  mean(neu_pol(onset:offset, 4));   
end

event_file(:,8) = event_file(:,6) -  event_file(:,7);
event_file(:,9) = abs(event_file(:,6) -  event_file(:,7));

csvwrite(fullfile(dirs.roi_tc,roi,'neural_polarization.csv'), event_file);