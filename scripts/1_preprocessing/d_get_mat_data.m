%% get_mat_data
% Get data into .mat files for faster analysis
%   Loads in .nii data
%   Restrict to mcutoff > 3000
%   Save .mat file 

clear all

dirs.mask = '../../data/fmri/masks/standard';
dirs.fMRI = '../../data/fmri/glm/transformed_data';
dirs.result = '../../data/fmri/glm/transformed_mat';
addpath(genpath('../../scripts/9_NIFTI_tools'));   % nifti_toolbox, download from: 
                                                   %   https://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image

subjects=[1004, 1005, 1006, 1007, 1008, 1009, 1011, 1012, 1014, 1015, 1016, 1017, 1018, 1019, 1020, 1021, 1022, 1023, 1024, ...
   1026, 1027, 1028, 1029, 1030, 1031, 1032, 1033, 1034, 1035, 1036, 1037, 1038, 1039, 1040, 1041, 1042, 1043, 1044];

mcutoff = 3000;

nSub = length(subjects);

for s = 1:nSub
    
    sub = num2str(subjects(s));
    
    fprintf('Running Subject %s \n', sub);
    
    % Make output directory if it doesn't exit
    savepath = fullfile(dirs.result,sub);
    if ~exist(savepath), mkdir(savepath); end
    
    for r = 1:4
        thisFMRI_path = fullfile(dirs.fMRI,sub,sprintf('run%i.nii',r)); 
        
        % unzip file
        gunzip(sprintf('%s.gz',thisFMRI_path));
        
        % load file into matlab
        nii = load_nii(thisFMRI_path);
        data = nii.img;
        datasize = size(data);
        nii.img = [];
        data = single(reshape(data,[(size(data,1)*size(data,2)*size(data,3)),size(data,4)]));
        mdata = mean(data,2);
        keptvox = mdata>mcutoff;
        data = zscore(data')'; % zscore the data across time
        
        fprintf('keptvox = %0.3f \n', mean(keptvox));
        
        % only keep voxels that exceed threshold
        small_data = data(keptvox,:);
                
        % save file
        save(fullfile(savepath,sprintf('run%i.mat',r)),'small_data','datasize','keptvox');
        
        % delete zipped file to save space
        delete(thisFMRI_path)
    
    end
end
