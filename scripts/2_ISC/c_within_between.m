%% within_between
% Calculate within - between ISC

clear all

dirs.fMRI = '../../data/fmri/movie_data/';
dirs.bids = '../../Polarization';

addpath(genpath('../9_NIFTI_tools'));
addpath(genpath('../9_help_scripts'));

subjects=[1004, 1005, 1006, 1007, 1008, 1009, 1011, 1012, 1014, 1015, 1016, 1017, 1018, 1019, 1020, 1021, 1022, 1023, 1024, ...
    1026, 1027, 1028, 1029, 1030, 1031, 1032, 1033, 1034, 1035, 1036, 1037, 1038, 1039, 1040, 1041, 1042, 1043, 1044];    

nSub = length(subjects);

%% Get group assignments
participants_file = tdfread(fullfile(dirs.bids,'participants.tsv'));
participants_file.l_index = participants_file.ImmScore < median(participants_file.ImmScore);
participants_file.r_index = participants_file.ImmScore > median(participants_file.ImmScore);

l_id = cellstr(participants_file.participant_id(participants_file.l_index,:));
r_id = cellstr(participants_file.participant_id(participants_file.r_index,:));
all_id = cellstr(participants_file.participant_id);

left = subjects(ismember(all_id,l_id));
right = subjects(ismember(all_id,r_id));

% Script settings:
summed_avg_bygroup = 0;
one2avg_bygroup = 0;
sign_flipping = 0;
save_maps = 1;

%% Summed average by group
if summed_avg_bygroup
    
    load(fullfile(dirs.fMRI,'video_average','sum_allvideos.mat'),'allkeptvox');
        
    % Left
    sum_allvideos = zeros(271633,1);
    groupvoxelSub = zeros(271633,1);
    sub_list = [];

    for s = 1:length(left)
        
        sub = num2str(left(s));
        fprintf('Running Subject %s \n', sub);
        
        load(fullfile(dirs.fMRI,sub,'allvideos.mat'))
       
        data = zeros(length(keptvox),datasize(4));
        data(keptvox,:) = allvideos;
        
        groupvoxelSub = groupvoxelSub + keptvox;
        
        sum_allvideos = sum_allvideos + data;
        sub_list = [sub_list subjects(s)];
           
    end
       
    sum_allvideos = sum_allvideos(allkeptvox,:);
    sum_allvideos = single(sum_allvideos);
    groupvoxelSub = groupvoxelSub(allkeptvox);
    
    save(fullfile(dirs.fMRI,'video_average','sum_allvideos_left.mat'),'sum_allvideos','allkeptvox','groupvoxelSub','datasize');

    % Right
    sum_allvideos = zeros(271633,1);
    sub_list = [];
    groupvoxelSub = zeros(271633,1);

    for s = 1:length(right)
        
        sub = num2str(right(s));
        fprintf('Running Subject %s \n', sub);
        
        load(fullfile(dirs.fMRI,sub,'allvideos.mat'))
        
        data = zeros(length(keptvox),datasize(4));
        data(keptvox,:) = allvideos;
        
        sum_allvideos = sum_allvideos + data;
        sum_allvideos = single(sum_allvideos);
        sub_list = [sub_list subjects(s)];
        
        groupvoxelSub = groupvoxelSub + keptvox;
           
    end
       
    sum_allvideos = sum_allvideos(allkeptvox,:);
    sum_allvideos = single(sum_allvideos);
    
    groupvoxelSub = groupvoxelSub(allkeptvox);
    
    save(fullfile(dirs.fMRI,'video_average','sum_allvideos_right.mat'),'sum_allvideos','groupvoxelSub','allkeptvox','datasize');  
end


%% One to average analysis by group
if one2avg_bygroup
   
    load(fullfile(dirs.fMRI,'video_average','sum_allvideos_left.mat'))
    left_videos = sum_allvideos;
    leftvoxelSub = groupvoxelSub;
        
    load(fullfile(dirs.fMRI,'video_average','sum_allvideos_right.mat'))
    right_videos = sum_allvideos;
    rightvoxelSub = groupvoxelSub;

    within_group = NaN(length(sum_allvideos),nSub);
    between_group = NaN(length(sum_allvideos),nSub);
    
    clear sum_allvideos
    
    for s = 1:nSub
        
        % load subject
        sub = num2str(subjects(s));
        fprintf('Running Subject %s \n', sub);
        
        load(fullfile(dirs.fMRI,sub,'allvideos.mat'))

        data = zeros(length(keptvox),datasize(4));
        data(keptvox,:) = allvideos;
        data = data(allkeptvox,:);
                
        if sum(subjects(s) == left)
            n_minus_one = left_videos - data;
            
            % divide by number of subjects
            temp = keptvox(allkeptvox);
            denom = leftvoxelSub - temp;
            temp_left = n_minus_one./denom;
            
            temp_right = right_videos./rightvoxelSub;
                     
            % within_group
            within_group(:,s) = corr_col(data,temp_left,2);
            between_group(:,s) = corr_col(data,temp_right,2);
            
        elseif sum(subjects(s) == right)
            
            n_minus_one = right_videos - data;
            
            % divide by number of subjects
            temp = keptvox(allkeptvox);
            denom = rightvoxelSub - temp;
            temp_right = n_minus_one./denom;
            
            temp_left = left_videos./leftvoxelSub;
            
            % within_group
            within_group(:,s) = corr_col(data,temp_right,2);
            between_group(:,s) = corr_col(data,temp_left,2);
            
        end

    end
    
    within_between = within_group - between_group;
   
    save(fullfile(dirs.fMRI,'video_average','within_between.mat'),'within_group','between_group','within_between','allkeptvox','datasize');  

end

%% sign flipping
if sign_flipping
    load(fullfile(dirs.fMRI,'video_average','within_between.mat')); 
    
    [h p ci stats] = ttest(within_between');
    
    true_t = stats.tstat';
    t_stat_count = zeros(sum(allkeptvox),1);

    n_iteration = 10000;
   
    for i = 1:n_iteration
        
        if mod(i,1000)==0
            fprintf('Iteration %i \n',i);
        end

        sign_flips = ((rand(nSub,1) > 0.5) * 2 - 1)';
        fake_withinbetween = sign_flips .* within_between;

        [h p ci stats] = ttest(fake_withinbetween');
        
        fake_t = stats.tstat';
        
        diff_t = single(fake_t > true_t);
        diff_t(isnan(true_t)) = NaN;
        
        t_stat_count = t_stat_count + diff_t;
        
    end
    
    p_value = (t_stat_count + 1)/i;

    output_path = fullfile(dirs.fMRI,'video_average','within_between_pmap.mat');
    save(output_path,'p_value','allkeptvox');
    
end

%% save maps
if save_maps
    
    % Load standard mask
    nii = load_nii('../../data/fmri/masks/standard/2mmTo3mm.nii');
    nii.hdr.dime.datatype = 64;
    nii.hdr.dime.glmax = 1;
    nii.hdr.dime.glmax = -1;
    
    % within-between
    load(fullfile(dirs.fMRI,'video_average','within_between.mat'));
    
    data = zeros(length(allkeptvox),1);
    data(allkeptvox) = nanmean(within_between,2);
    nii.img = data;
    nii.img(isnan(nii.img)) = 0;
    
    save_nii(nii,fullfile('../../data/fmri/maps/within_between','within_between_rdiff.nii'));
                 
    % sign flipping map
    load(fullfile(dirs.fMRI,'video_average','within_between_pmap.mat'));
    data = zeros(length(allkeptvox),1);
    data(allkeptvox) = 1-p_value;
    nii.img = data;
    nii.img(isnan(nii.img)) = 0;
    
    save_nii(nii,fullfile('../../data/fmri/maps/within_between',sprintf('within_between_signflip_p.nii')));
    
    % z_map
    z = @(p) -sqrt(2) * erfcinv(p*2);
    inv_p = 1-p_value;
    inv_p(inv_p <= 0) = 0.0001;
    inv_p = z(inv_p);
    z_data = data;
    z_data(allkeptvox) = inv_p;
    
    nii.img = z_data;
    nii.img(isnan(nii.img)) = 0;
    
    save_nii(nii,fullfile('../../data/fmri/maps/within_between','within_between_perm_z.nii'));
    
    % Load Brain Mask
    data = zeros(length(allkeptvox),1);
    data(allkeptvox) = 1;
    
    nii.img = data;
    nii.img(isnan(nii.img)) = 0;
    
    save_nii(nii,fullfile('../../data/fmri/masks/standard','allkeptvox.nii'));
    
end
    