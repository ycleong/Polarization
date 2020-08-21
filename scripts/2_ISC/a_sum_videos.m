%% sum_videos
% Concatenate data and add up all timecourses to facilitate computation of n-1 average

clear all

dirs.fMRI = '../../data/fmri/movie_data/';

addpath(genpath('../9_help_scripts'));
addpath(genpath('../9_NIFTI_tools'));   % nifti_toolbox, download from: 
                                                   %   https://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image

subjects=[1004, 1005, 1006, 1007, 1008, 1009, 1011, 1012, 1014, 1015, 1016, 1017, 1018, 1019, 1020, 1021, 1022, 1023, 1024, ...
    1026, 1027, 1028, 1029, 1030, 1031, 1032, 1033, 1034, 1035, 1036, 1037, 1038, 1039, 1040, 1041, 1042, 1043, 1044];    

nSub = length(subjects);

% Script settings:
concat = 1;
summed_avg = 1;

%% Create concatenated data 
if concat
    for s = 1:nSub

        sub = num2str(subjects(s));

        fprintf('Running Subject %s \n', sub);
        
        allvideos = [];
        allkeptvox = ones(271633,1);

        for v = 1:24
            % load fmri data
            thisFMRI_path = fullfile(dirs.fMRI,sub,sprintf('video%i.mat',v)); 
            load(thisFMRI_path);
            
            movie_data = zscore(movie_data,0,2);
            
            data = zeros(length(keptvox),datasize(4));

            data(keptvox,:) = movie_data;
            
            allvideos = [allvideos data];
            allkeptvox = allkeptvox & keptvox;
            
        end    
        keptvox = allkeptvox;
        
        % zscore each subject
        allvideos = zscore(allvideos,0,2);
        
        % reduce space
        allvideos = allvideos(keptvox,:);
        
        % change to singles to save space and loading time
        allvideos = single(allvideos);

        datasize(4) = size(allvideos,2);
        
        save(fullfile(dirs.fMRI,sub,'allvideos.mat'),'allvideos','datasize','keptvox');
        
        disp(size(allvideos))
             
    end
end

%% Create summed average 
if summed_avg
    sum_allvideos = zeros(271633,1);
    allkeptvox = zeros(271633,1);
    sub_list = [];

    for s = 1:nSub
        
        sub = num2str(subjects(s));
        fprintf('Running Subject %s \n', sub);
        

        load(fullfile(dirs.fMRI,sub,'allvideos.mat'))
        data = zeros(length(keptvox),datasize(4));
        data(keptvox,:) = allvideos;
        
        sum_allvideos = sum_allvideos + data;
        allkeptvox = allkeptvox + keptvox;
        sub_list = [sub_list subjects(s)];
           
    end
    voxelSub = allkeptvox;
    allkeptvox = allkeptvox > (0.7 * nSub);
    voxelSub = voxelSub(allkeptvox);
    
    sum_allvideos = sum_allvideos(allkeptvox,:);  
    sum_allvideos = single(sum_allvideos);  
    
    save(fullfile(dirs.fMRI,'video_average','sum_allvideos.mat'),'sum_allvideos','allkeptvox','voxelSub','datasize');  
end
