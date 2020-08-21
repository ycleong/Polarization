%% within_between roi
% Plot within-between group similarity separately for A1, V1, DMPFC

clear all

addpath(genpath('../9_NIFTI_tools'));
addpath(genpath('../9_help_scripts'));

dirs.fMRI = '../../data/fmri/movie_data/';
dirs.roi = '../../data/fmri/masks/roi/';
dirs.bids = '../../Polarization';

rois = {'DMPFC','A1','V1'};

extract_roi_WB = 1;
output_To_R = 1;

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

%% Extract roi activity 
if extract_roi_WB
    
   load(fullfile(dirs.fMRI,'video_average','within_between.mat')); 

   for r = 1:length(rois)
        roi = rois{r};

        % Load mask
        mask_struc = load_nii(fullfile(dirs.roi,sprintf('%s.nii',roi)));
        mask_4d = mask_struc.img;
        mask_dimensions = size(mask_struc.img);
        mask = logical(reshape(mask_4d,[mask_dimensions(1)*mask_dimensions(2)*mask_dimensions(3),1]));
        
        % Get Within
        within_Brain = zeros(length(allkeptvox),38);
        within_Brain(allkeptvox,:) = within_group;
        within_ROI = nanmean(within_Brain(mask,:));
        
        % Get Between
        between_Brain = zeros(length(allkeptvox),38);
        between_Brain(allkeptvox,:) = between_group;
        between_ROI = nanmean(between_Brain(mask,:));
        
        % Get Within-Between
        within_between_Brain = zeros(length(allkeptvox),38);
        within_between_Brain(allkeptvox,:) = within_between;
        within_between_ROI = nanmean(within_between_Brain(mask,:));
        
        save(fullfile(dirs.fMRI,'wb_roi',sprintf('WB_%s.mat',roi)),'within_ROI','between_ROI','within_between_ROI','allkeptvox','datasize');  
   end
end

%% output_To_R
if output_To_R 
    
    % SUBJECT, % ROI, WITHIN, BETWEEN
    csv_file = fopen(fullfile(dirs.fMRI,'wb_roi','WB_regional.csv'),'w+');
    
    fprintf(csv_file,'Subject,orientation,roi,within,between\n');
    
    for r = 1:length(rois)
        roi = rois{r};
        
        load(fullfile(dirs.fMRI,'wb_roi',sprintf('WB_%s.mat',roi)));
        
        for s = 1:length(subjects)
            
            if sum(subjects(s) == left)
                orientation = 'Liberal';
            else
                orientation = 'Conservative';
            end
            
            fprintf(csv_file,'%i,%s,%s,%0.4f,%0.4f\n', subjects(s), orientation, roi, within_ROI(1,s),between_ROI(1,s));
            
        end
        
        
    end
        
    fclose(csv_file);
    
end