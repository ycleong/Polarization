%% Calculate Between vs. Within-Group ISFC - voxelwise 
% Load roitc for allsubjects
% Compute average left and 

clear all

addpath(genpath('../9_NIFTI_tools'));
addpath(genpath('../9_help_scripts'));

dirs.fMRI = '../../data/fmri/movie_data/';
dirs.roi = '../../data/fmri/masks/roi/';
dirs.bids = '../../Polarization';
dirs.roitc = '../../data/fmri/roi_tc/';
dirs.semantic = '../../data/semantic_categories';
dirs.output = '../../data/fmri/ISFC/';

roi = 'DMPFC';

computeISFC = 0;
sign_flipping = 0;
save_maps = 1;

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


%% Load roitc
tc_path = fullfile(dirs.roitc,roi,sprintf('%s.mat', roi));
load(tc_path); 

load(fullfile(dirs.fMRI,'video_average','sum_allvideos_left.mat'))
left_videos = sum_allvideos;
leftvoxelSub = groupvoxelSub;

load(fullfile(dirs.fMRI,'video_average','sum_allvideos_right.mat'))
right_videos = sum_allvideos;
rightvoxelSub = groupvoxelSub;

between_groupISFC = NaN(nSub, length(right_videos));
within_groupISFC = NaN(nSub, length(right_videos));

%% Compute ISFC
if computeISFC
    for s = 1:nSub
        % Identify left vs. right subjects, exclude current subject
        left_sub = ismember(subjects,left);
        right_sub = ismember(subjects,right);
        left_sub(s) = 0;
        right_sub(s) = 0;
        
        % this_subject's ROI timecourse
        this_tc = squeeze(roi_tc(:,s));
        
        % this_subject's fulldata
        sub = num2str(subjects(s));
        fprintf('Running Subject %s \n', sub);
        
        load(fullfile(dirs.fMRI,sub,'allvideos.mat'))
        
        data = zeros(length(keptvox),datasize(4));
        data(keptvox,:) = allvideos;
        data = data(allkeptvox,:);
        
        % Is this subject liberal or conservative?
        if sum(ismember(left,subjects(s)))             % Liberal
            
            % Get average_tcs
            n_minus_one = left_videos - data;
            temp = keptvox(allkeptvox);
            denom = leftvoxelSub - temp;
            temp_left = n_minus_one./denom;
            
            temp_right = right_videos./rightvoxelSub;

            % Within-group ISFC 
            within_groupISFC(s,:) = corr(this_tc,temp_left'); 
            
            % Between-group ISFC first
            between_groupISFC(s,:) = corr(this_tc,temp_right');
            
        else
            % Get average_tcs
            n_minus_one = right_videos - data;
            temp = keptvox(allkeptvox);
            denom = rightvoxelSub - temp;
            temp_right = n_minus_one./denom;
            
            temp_left = left_videos./leftvoxelSub;

            % Within-group ISFC 
            within_groupISFC(s,:) = corr(this_tc,temp_right'); 
            
            % Between-group ISFC first
            between_groupISFC(s,:) = corr(this_tc,temp_left');
        end
    end
    
    withinbetween_ISFC = within_groupISFC - between_groupISFC;
    
    output_path = fullfile(dirs.output,roi,'WithinBetweenISFC.mat');
    save(output_path,'within_groupISFC','between_groupISFC','withinbetween_ISFC');
end

%% Run permutation stats
if sign_flipping
    filepath = fullfile(dirs.output,roi,'WithinBetweenISFC.mat');
    load(filepath); 
    
    [h p ci stats] = ttest(withinbetween_ISFC);
    
    true_t = stats.tstat';
    t_stat_count = zeros(sum(allkeptvox),1);

    n_iteration = 10000;
   
    for i = 1:n_iteration
        
        if mod(i,1000)==0
            fprintf('Iteration %i \n',i);
        end

        sign_flips = ((rand(nSub,1) > 0.5) * 2 - 1)';
        fake_withinbetween = sign_flips .* withinbetween_ISFC';

        [h p ci stats] = ttest(fake_withinbetween');
        
        fake_t = stats.tstat';
        
        diff_t = single(fake_t > true_t);
        diff_t(isnan(true_t)) = NaN;
        
        t_stat_count = t_stat_count + diff_t;
        
    end
    
    p_value = (t_stat_count + 1)/i;

    output_path = fullfile(dirs.output,roi,'WithinBetweenISFC_signflipped.mat');
    save(output_path,'p_value','allkeptvox');
    
end

%% save_maps
if save_maps
    
    % Load standard mask
    nii = load_nii('../../data/fmri/masks/standard/2mmTo3mm.nii');
    nii.hdr.dime.datatype = 64;
    nii.hdr.dime.glmax = 1;
    nii.hdr.dime.glmax = -1;
    
    % Load data
    filepath = fullfile(dirs.output,roi,'WithinBetweenISFC.mat');
    load(filepath);
    
    data = zeros(length(allkeptvox),1);
    data(allkeptvox) = nanmean(withinbetween_ISFC);
    nii.img = data;
    nii.img(isnan(nii.img)) = 0;
    
    save_nii(nii,fullfile('../../data/fmri/maps/ISFC','within_between_rdiff.nii'));
    
    % Load data
    filepath = fullfile(dirs.output,roi,'WithinBetweenISFC_signflipped.mat');
    load(filepath);
    
    data = zeros(length(allkeptvox),1);
    data(allkeptvox) = 1-p_value;
    nii.img = data;
    nii.img(isnan(nii.img)) = 0;
    
    save_nii(nii,fullfile('../../data/fmri/maps/ISFC','within_between_signflipped.nii'));
    
    % Save z-map
    z = @(p) -sqrt(2) * erfcinv(p*2);
    p_value(p_value == 0) = 0.0001;
    z_value = z(1-p_value);
    z_data = zeros(length(allkeptvox),1);
    z_data(allkeptvox) = z_value;
    
    nii.img = z_data;
    nii.img(isnan(nii.img)) = 0;
    
    save_nii(nii,fullfile('../../data/fmri/maps/ISFC','within_between_perm_z.nii'));
            
end