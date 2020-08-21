function [x_t,x_amp,sym_phase] = phase_rand_corr_mat(x,permutation)

% function [truecorr, pvals, nullcorrs] = PHASE_RAND_CORR(x,y,nscram, tail)
%
% This function calculates the correlation between 
%     [1] a phase-scrambled version of each column of 'x'
% and 
%     [2] the intact vector 'y'
% to produce a distribution of null correlations in which we have controlled
% for the power spectrum (and thus temporal autocorrelation) of the input time-series.
%
% INPUT
% x =        [Nsamp by K] matrix, each of whose K columns will be phase-scrambled,
%             and correlated against the vector input 'y'.
% y =        [Nsamp by 1] input vector [will be left intact]
% Nscram =   [integer] number of phase-scramble correlation value to compute (default: 1000)
% tail =     flag indicating distributional tail to examine for stats:
%            -1 --> left-tail, 0 --> two-tail, +1 --> right-tailed
%
% OUTPUT
% truecorr = [1 by K] vector of Pearson correlation between intact 'x' and intact 'y'
% pvals =    [1 by K] vector of corresponding p-values for the values of truecorr
%                  based on comparison with null distributions 
% nullcorrs = [Nscram by K] matrix of "null" Pearson correlations between
%                   phase-scrambled columns of 'x and intact y
%
% permutation : 1-perform phase permutation, 0-generate random variable
% TODO: 
%   implement some tapering to avoid high-freq artifacts in the fft
%   (but the procedure could be potentially probematic)
%   
%
% Author: CJ Honey
% Version: 0.1, April 2010  (phase_scram_corr_Nvs1)
% Version: 0.2, March 2011    -- fixed bug with zero-th phase component;
%                             -- randomizes rather than scrambles phase 
%                             based on feedback from Jochen Weber
% modify Erez 2013




[Nsamp K] = size(x);  %extract number of samples and number of signals

% convert x and y to column vectors if necessary


% x = x - repmat(mean(x,1), Nsamp,1);  %remove the mean of each column of X
% x = x./sqrt(repmat(dot(x,x), Nsamp, 1)/(Nsamp-1)); %divide by the standard deviation of each column

%transform the vectors-to-be-scrambled to the frequency domain
Fx = fft(x); 
% identify indices of positive and negative frequency components of the fft
% we need to know these so that we can symmetrize phase of neg and pos freq
if mod(Nsamp,2) == 0
    posfreqs = 2:(Nsamp/2);
    negfreqs = Nsamp : -1 : (Nsamp/2)+2;
else
    posfreqs = 2:(Nsamp+1)/2;
    negfreqs = Nsamp : -1 : (Nsamp+1)/2 + 1;
end

x_amp = abs(Fx);  %get the amplitude of the Fourier components
x_phase = atan2(imag(Fx), real(Fx)); %get the phases of the Fourier components [NB: must use 'atan2', not 'atan' to get the sign of the angle right]
J = sqrt(-1);  %define the vertical vector in the complex plane

% rand_phase = zeros(Nsamp,K);  %will cotnain the randomized phases for each input channel on each bootstrap
sym_phase = x_phase;%zeros(Nsamp,K);   %will contain symmetrized randomized phases for each bootstrap



%     [tmp,rp] = sort(rand(Nsamp,K)); %generate a set of column vectors each of which is a separate random permutation
%     
%     for k = 1:K   %this step could be sped up; we loop through and permute each column separately
%         rand_phase(:,k) = x_phase(rp(:,k),k);
%     end
    if permutation  
%         [tmp,rp] = sort(rand(Nsamp,K));
        [tmp,rp] = sort(rand(Nsamp,1));
        x_phase=x_phase(rp,:);
        new_phase=x_phase(1:length(posfreqs),:);
    else
%         for y=1:K
%             new_phase(:,y)=2*pi*rand(length(posfreqs),1);
%         end
           new_phase=2*pi*rand(length(posfreqs),K);
%         tmp_name=['rand_' getenv('SGE_TASK_ID') ];
%         output_mat=fullfile(pathout, tmp_name);
%         save (output_mat, 'new_phase');
    end
    

    sym_phase(posfreqs,:) = sym_phase(posfreqs,:)+new_phase;
    sym_phase(negfreqs,:) = sym_phase(negfreqs,:)-new_phase;
    
    z = x_amp.*exp(J.*sym_phase); %generate (symmetric)-phase-scrambled Fourier components
    x_t = real(ifft(z)); %invert the fft to generate a phase-scrambled version of x
    






