%% Calculate Between vs. Within-Group ISFC - voxelwise 
% Load roitc for allsubjects
% Compute average left and 
clear all

addpath(genpath('../9_NIFTI_tools'));
addpath(genpath('../9_help_scripts'));

dirs.fMRI = '../../data/fmri/break_brain/';
dirs.ISFC = '../../data/fmri/ISFC/';
dirs.output = '../../data/fmri/RSA/';
dirs.roitc = '../../data/fmri/roi_tc/';
dirs.data = '../../data';

roi = 'DMPFC';

computeISFC = 1;
computestats = 1;
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

%% Load DMPFC TC
tc_path = fullfile(dirs.roi_tc,roi,sprintf('%s.mat', roi));
load(tc_path); 
DMPFC_tc = roi_tc;
clear roi_tc

n_parcel = 10;

%% Behavioral Data
ImmScore = participants_file.ImmScore;
RDM_behav = squareform(pdist(ImmScore));

ISFC_r_allpieces = [];
ISFC_p_value = []; 
p_value = [];

ioffdiag = ~logical(diag(ones(nSub,1)));

if computeISFC
    
    for p = 1:n_parcel
        
        clear roi_tc
        
        % Load full data
        for s = 1:nSub
            fprintf('Loading data: Subject %i, Piece = %i \n',subjects(s), p);
            load(fullfile(dirs.fMRI,num2str(subjects(s)),sprintf('p%i.mat',p)));
            
            roi_tc(s,:,:) = data;
        end
        
        % ISFC_R = NaN(length(roi_tc),1);
        ISFC_RDM_vector = NaN(sum(ioffdiag(:)),length(roi_tc));

        % Compute ISFC matrix 
        for v = 1:length(roi_tc)
            
            this_v = squeeze(roi_tc(:,v,:))';
            
            ISFC_RDM = NaN(38,38);

            for s = 1:nSub
                ISFC_RDM(:,s) = 1-corr(this_v, squeeze(DMPFC_tc(:,s)));
            end
            
            ISFC_RDM_vector(:,v) = ISFC_RDM(ioffdiag);
            RDM_behav_vector = RDM_behav(ioffdiag);
                    
        end
        
        ISFC_R = corr(RDM_behav_vector,ISFC_RDM_vector,'Rows','pairwise')';
        
        if computestats
            
            r_count = zeros(length(ISFC_R),1);
            
            for iteration = 1:10000
                
                if ~mod(iteration,100)
                    fprintf('iteration %i \n',iteration)
                end
                
                shuffle_order = randperm(38);
                fake_RDM_behav = RDM_behav(shuffle_order, shuffle_order);
                fake_RDM_behav_vector = fake_RDM_behav(ioffdiag);
                
                fake_ISFC_R = corr(fake_RDM_behav_vector,ISFC_RDM_vector,'Rows','pairwise')';
                
                diff_r = ISFC_R < fake_ISFC_R;
                
                r_count = r_count + diff_r;
                   
            end
            
            clear p_value
            p_value = (r_count + 1)/iteration;
            ISFC_p_value = [ISFC_p_value; p_value];
            
        end
        
        ISFC_r_allpieces = [ISFC_r_allpieces; ISFC_R];

    end

    output_path = fullfile(dirs.output,roi,'ISFC_RSA_r.mat');
    save(output_path,'ISFC_r_allpieces','ISFC_p_value');
end

%% Save maps
if save_maps
    
    % Load standard mask
    nii = load_nii('../../data/fmri/masks/standard/2mmTo3mm.nii');
    nii.hdr.dime.datatype = 64;
    nii.hdr.dime.glmax = 1;
    nii.hdr.dime.glmax = -1;
    
    filepath = fullfile(dirs.ISFC,roi,'WithinBetweenISFC_signflipped.mat');
    load(filepath);
    
    % Load data
    filepath = fullfile(dirs.output,roi,'ISFC_continuous_r.mat');
    load(filepath);
    
    data = zeros(length(allkeptvox),1);
    data(allkeptvox) = ISFC_r_allpieces;
    nii.img = data;
    nii.img(isnan(nii.img)) = 0;
    
    save_nii(nii,fullfile('../../data/fmri/maps/RSA_ISFC/ISFC_continuous','ISFC_continuous_r.nii'));
  
    p_value = ISFC_p_value;
    
    % p_value
    p_value(p_value > 1) = 1;
    
    data = zeros(length(allkeptvox),1);
    data(allkeptvox) = 1-p_value;
    nii.img = data;
    nii.img(isnan(nii.img)) = 0;
    
    save_nii(nii,fullfile('../../data/fmri/maps/RSA_ISFC/ISFC_continuous','ISFC_continuous_p.nii'));
            
end