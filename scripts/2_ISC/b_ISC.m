%% ISC
% Compute group ISC
    
clear all

dirs.fMRI = '../../data/fmri/movie_data/';

addpath(genpath('../9_NIFTI_tools'));
addpath(genpath('../9_help_scripts'));

subjects=[1004, 1005, 1006, 1007, 1008, 1009, 1011, 1012, 1014, 1015, 1016, 1017, 1018, 1019, 1020, 1021, 1022, 1023, 1024, ...
    1026, 1027, 1028, 1029, 1030, 1031, 1032, 1033, 1034, 1035, 1036, 1037, 1038, 1039, 1040, 1041, 1042, 1043, 1044];    

nSub = length(subjects);

% Script settings:
one2avg = 1;
shuffle_stats = 1;
save_maps = 1;

%% One to average
if one2avg
   load(fullfile(dirs.fMRI,'video_average','sum_allvideos.mat'));
   concat_corr_all = NaN(length(sum_allvideos),nSub);
   
   for s = 1:nSub
       
       sub = num2str(subjects(s));
       fprintf('Running Subject %s \n', sub);
       
       load(fullfile(dirs.fMRI,sub,'allvideos.mat'))

       
       data = NaN(length(keptvox),datasize(4));
       data(keptvox,:) = allvideos;
              
       data = data(allkeptvox,:);
       
       n_minus_one = sum_allvideos - data;
       
       % divide by number of subjects
       temp = keptvox(allkeptvox);
       denom = voxelSub - temp;
       n_minus_one = n_minus_one./denom;
       

       for v = 1:length(sum_allvideos)
           concat_corr_all(v,s) = corr(data(v,:)',n_minus_one(v,:)');
       end
       
   end
   
   concat_corr_all = single(concat_corr_all);   

   save(fullfile(dirs.fMRI,'video_average','concat_corr_all'),'concat_corr_all','allkeptvox','datasize');   

end

%% Shuffle stats
if shuffle_stats
    load(fullfile(dirs.fMRI,'video_average','concat_corr_all.mat'));
    true_mean = nanmean(concat_corr_all,2);
    
    r_count = zeros(length(concat_corr_all),1);
    
    for iteration = 1:10000
        
        fprintf('Iteration %i \n', iteration);
        
        sign_flip = (rand(size(concat_corr_all)) > 0.5) * 2 - 1;
        fake_concat_corr = sign_flip .* concat_corr_all;
        fake_mean = nanmean(fake_concat_corr,2);
        
        this_count = fake_mean > true_mean;
        r_count = r_count + this_count; 
        
    end
    
    save(fullfile(dirs.fMRI,'video_average','concat_corr_all.mat'),'concat_corr_all','allkeptvox','datasize','r_count','iteration');  
    
end

%% save maps
if save_maps
    
    %% Load concat_corr and save one2avg map
    load(fullfile(dirs.fMRI,'video_average','concat_corr_all.mat'));
    
    nii = load_nii('../../data/fmri/masks/standard/2mmTo3mm.nii');
    nii.hdr.dime.datatype = 64;
    nii.hdr.dime.glmax = 1;
    nii.hdr.dime.glmax = -1;
    
    data = zeros(length(allkeptvox),1);
    data(allkeptvox) = nanmean(concat_corr_all,2);
    
    nii.img = data;
    nii.img(isnan(nii.img)) = 0;
    
    save_nii(nii,fullfile('../../data/fmri/maps/one2avg','one2avg.nii'));
    
    %% Calculate p_value and run FDR correction (no masking)
    p_map = (r_count+1)/iteration;
    [h, crit_p] = fdr_bky(p_map, 0.001, 'yes');
    
    % Convert back to full space
    p_mask = zeros(length(allkeptvox),1);
    p_mask(allkeptvox) = h;
    
    nii.img(~p_mask) = 0;   
    save_nii(nii,fullfile('../../data/fmri/maps/one2avg','one2avg_rthresh.nii'));

end
    