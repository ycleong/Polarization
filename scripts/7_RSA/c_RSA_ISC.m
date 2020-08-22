%% make pre_scan_RDM
clear all

dirs.bids = '../../Polarization';

addpath(genpath('../9_NIFTI_tools'));
addpath(genpath('../9_help_scripts'));

subjects=[1004, 1005, 1006, 1007, 1008, 1009, 1011, 1012, 1014, 1015, 1016, 1017, 1018, 1019, 1020, 1021, 1022, 1023, 1024, ...
    1026, 1027, 1028, 1029, 1030, 1031, 1032, 1033, 1034, 1035, 1036, 1037, 1038, 1039, 1040, 1041, 1042, 1043, 1044];    

nSub = length(subjects);

participants_file = tdfread(fullfile(dirs.bids,'participants.tsv'));
ImmScore = participants_file.ImmScore;
RDM_behav = squareform(pdist(ImmScore));

% Vectorize RDM
ioffdiag = logical(triu(ones(size(RDM_behav)),1));
RDM_behav_vector = RDM_behav(ioffdiag);

opts.run_corr = 1;
opts.run_stats = 1;
opts.save_maps = 1;

%% Neural Data
if opts.run_corr
    load(fullfile(sprintf('../../data/fmri/RSA'),'voxel_rdm.mat'));
    
    [rho(:,1),rho(:,2)] = corr(AllRDM_neural',RDM_behav_vector, 'Tail','right','Rows','pairwise');    
    rho = rho(:,1);
    
    if opts.run_stats
        
        n_iteration = 10000;
        r_count = zeros(length(rho),1);
        
        for iteration = 1:n_iteration
 
            shuffle_order = randperm(38);
            
            fake_RDM_behav = RDM_behav(shuffle_order, shuffle_order);
            fake_RDM_behav = fake_RDM_behav(ioffdiag);
            
            fake_rho = corr(AllRDM_neural',fake_RDM_behav, 'Tail','right','Rows','pairwise');
            diff_r = rho < fake_rho;
            
            r_count = r_count + diff_r;
            
            if ~mod(iteration, 100)
                fprintf('Iteration %i \n', iteration);
                
                save(fullfile('../../data/fmri/RSA','voxel_rdm_permstats.mat'),'rho','r_count','iteration');
            end
        end
    end
end

if opts.save_maps
    %% Save maps
    load('../../data/fmri/RSA','voxel_rdm_permstats.mat');
    
    p_value = (r_count + 1)/iteration;
    p_value(p_value > 1) = 1;

    % Load standard mask
    load(fullfile(sprintf('../../data/fmri/masks/standard'),'allkeptvox.mat'));
    nii = load_nii('../../data/fmri/masks/standard/2mmTo3mm.nii');
    nii.hdr.dime.datatype = 64;
    nii.hdr.dime.glmax = 1;
    nii.hdr.dime.glmax = -1;

    data = zeros(length(allkeptvox),1);
    data(allkeptvox) = p_value;
    nii.img = data;
    nii.img(isnan(nii.img)) = 0;

    save_nii(nii,fullfile('../../data/fmri/maps/RSA_ISC','voxel_RDM_p.nii'));

    data = zeros(length(allkeptvox),1);
    data(allkeptvox) = 1-p_value;
    nii.img = data;
    nii.img(isnan(nii.img)) = 0;

    save_nii(nii,fullfile('../../data/fmri/maps/RSA_ISC','voxel_RDM_invp.nii'));
 
end