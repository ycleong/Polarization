%% break_brain
% Break the brain into 10 pieces so that all subjects can be loaded at once
% for faster computation

clear all
dirs.fMRI = '../../data/fmri/movie_data/';
dirs.output = '../../data/fmri/break_brain/';

addpath(genpath('../9_NIFTI_tools'));
addpath(genpath('../9_help_scripts'));

%% Get group assignments
subjects=[1004, 1005, 1006, 1007, 1008, 1009, 1011, 1012, 1014, 1015, 1016, 1017, 1018, 1019, 1020, 1021, 1022, 1023, 1024, ...
    1026, 1027, 1028, 1029, 1030, 1031, 1032, 1033, 1034, 1035, 1036, 1037, 1038, 1039, 1040, 1041, 1042, 1043, 1044];   

nSub = length(subjects);

% Load video average
load(fullfile(dirs.fMRI,'video_average','sum_allvideos.mat'),'allkeptvox');
 
for s = 1:length(subjects)
   
    sub = num2str(subjects(s));
    fprintf('Running Subject %s \n', sub);
    
    % make subj folder
    if ~exist(fullfile(dirs.output,sub))
        mkdir(fullfile(dirs.output,sub));
    end
        
    % Load this subject's data
    load(fullfile(dirs.fMRI,sub,'allvideos.mat'))
    
    % Convert it back to long form
    data = NaN(length(keptvox),datasize(4));
    data(keptvox,:) = allvideos;
    
    % Convert it to allkept vox
    allkept_data = data(allkeptvox,:);
    
    % Break it up into 10 pieces
    for p = 1:10
        clear data
        
        % index
        start_indx = (p-1)*6025+1;
        end_indx = p * 6025;
        if end_indx > sum(allkeptvox)
            end_indx = sum(allkeptvox); 
        end
                
        this_indx = zeros(sum(allkeptvox), 1);
        this_indx(start_indx:end_indx,1) = 1;
        this_indx = logical(this_indx);

        data = allkept_data(this_indx,:);
        
        save(fullfile(dirs.output,sub,sprintf('p%i.mat',p)),'data','allkeptvox','this_indx');
    end    
end
      

    