%% generate voxel RDM

clear all

addpath(genpath('../9_NIFTI_tools'));
addpath(genpath('../9_help_scripts'));

dirs.mask = '../../data/fmri/masks';
dirs.fMRI = '../../data/fmri/break_brain/';

n_parcel = 10;

subjects=[1004, 1005, 1006, 1007, 1008, 1009, 1011, 1012, 1014, 1015, 1016, 1017, 1018, 1019, 1020, 1021, 1022, 1023, 1024, ...
    1026, 1027, 1028, 1029, 1030, 1031, 1032, 1033, 1034, 1035, 1036, 1037, 1038, 1039, 1040, 1041, 1042, 1043, 1044];   

nSub = length(subjects);

ioffdiag = logical(triu(ones(nSub,nSub),1));


AllRDM_neural = [];

for p = 1:n_parcel

    clear roi_tc;
    clear RDM_neural;
    
    for s = 1:nSub
        fprintf('Loading data: Subject %i, Piece = %i \n',subjects(s), p);
        load(fullfile(dirs.fMRI,num2str(subjects(s)),sprintf('p%i.mat',p)));
        
        roi_tc(s,:,:) = data;  
    end    
    
    for v = 1:size(data,1)
        this_roi_tc = squeeze(roi_tc(:,v,:));
        
        sq_RDM = squareform(pdist(this_roi_tc,'correlation'));
        
        RDM_neural(v,:) = sq_RDM(ioffdiag);
    end
    
    AllRDM_neural = [AllRDM_neural; RDM_neural];
    
end

%% save mean tc
save_file = fullfile(sprintf('../../data/fmri/RSA'),'voxel_rdm.mat');
save(save_file,'AllRDM_neural');
