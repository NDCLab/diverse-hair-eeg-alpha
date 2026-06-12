%
% This script was created by George Buzzell for the NDC Lab EEG Training
% Workshop on 02/22. This script uses parts of the "set up" structure from
% the MADE preprocessing pipeline (Debnath, Buzzell, et. al., 2020)

clear % clear matlab workspace
clc % clear matlab command window

%% setup; run this section before any other section below

% MUST EDIT THIS
%running in "EEG_training" folder on your computer
main_dir = 'C:\Users\cknowlto\temp\diverse-hair-eeg-dataset';

% Setting up other things

%Location of MADE and ADJUSTED-ADJUST scripts
addpath(genpath('C:\Users\cknowlto\temp\eeg_preprocessing'));% enter the path of the EEGLAB folder in this line
addpath(genpath('C:\Users\cknowlto\temp\erplab13.00'));

%Location of "EEG
addpath(genpath('C:\Users\cknowlto\temp\eeglab13_4_4b'));% enter the path of the EEGLAB folder in this line

%remove path to octave functions inside matlab to prevent errors when
rmpath(['C:\Users\cknowlto\temp' filesep 'eeglab13_4_4b' filesep 'functions' filesep 'octavefunc' filesep 'signal'])

% 1. Enter the path of the folder that has the data to be analyzed
data_location = ['C:\Users\cknowlto\temp\diverse-hair-eeg-dataset\derivatives\preprocessed\erp'];

% 2. Enter the path of the folder where you want to save the postprocessing outputs
output_location = ['C:\Users\cknowlto\temp\diverse-hair-eeg-alpha\derivatives\erp'];

% 3. Enter the path of the channel location file
channel_locations = ['C:\Users\cknowlto\temp\CACS-128-X7-FIXED-no-cap-9elec-only.bvef'];

% 4. Markers
stimulus_markers = {'11', '12', '21', '22'};     
respose_markers = {'111', '112', '121', '122','211', '212', '221', '222'};     

% Read files to analyses
datafile_names=dir(data_location);
datafile_names=datafile_names(~ismember({datafile_names.name},{'.', '..', '.DS_Store'}));
datafile_names={datafile_names.name};
[filepath,name,ext] = fileparts(char(datafile_names{1}));

% Check whether EEGLAB and all necessary plugins are in Matlab path.
if exist('eeglab','file')==0
    error(['Please make sure EEGLAB is on your Matlab path. Please see EEGLAB' ...
        'wiki page for download and instalation instructions']);
end

% Create output folders to save data
if exist(output_location, 'dir') == 0
    mkdir(output_location)
end

%% Plot ERPs!!

%load the mat file that has the erps and subject list
load('C:\Users\cknowlto\temp\diverse-hair-eeg-alpha\derivatives\dheeg_flanker_Resp_erps_min_6t_05_24_2026_21_19_54.mat')

%make a copy/rename the erp matrix 
allData = erpDat_data;

%load in one of the participants EEGLAB-formatted data; this is to load
%parameters needed for plotting (sampling rate, chanlocs, etc).
EEG = pop_loadset( 'filename', datafile_names{2}, 'filepath', data_location);
EEG = eeg_checkset(EEG);

%round EEG.times to nearest whole ms to make easier to work with
EEG.times = round(EEG.times);

%setup for baseline correcting the ERP data (always done before plotting or extracting
%erps, not done to the data previously to allow use of different baselines
%as a function of review comments)
startTime = -400; %(in ms)
endTime = -200 ; %(in ms)

%find closest values in (rounded) EEG.times to the specified start/stop
[temp,startIdx] = min(abs(EEG.times-startTime));
[temp2,endIdx] = min(abs(EEG.times-endTime));

%baseline corrections
Range = startIdx:endIdx;
allBase = squeeze(mean(allData(:,:,:,Range),4));
allBase = mean(allData(:,:,:,Range),4);

for i=1:size(allData,4)
    newData(:,:,:,i) = allData(:,:,:,i) - allBase;
end

%select channel(s) to plot: frontocentral cluster
chan = (newData(:,:,[1 4],:)); % SEP recorded only 2 out of 4 electrodes we typically use for midfrontal cluster, which is 1 and 33 in our typical montage
chan = mean(chan,3);

%pull out four conditions of interest for all subs
resp_error = chan(:,1,:,:);
resp_correct = chan(:,2,:,:);

%average across subs
resp_errorMean = squeeze(mean(resp_error,1));
resp_correctMean = squeeze(mean(resp_correct,1));

%label for plot and define colors for plot
blue = [0  0 1];
red = [1 0 0];

%plot the two response-related erps
figure;
hold on
plot(EEG.times, resp_errorMean, 'color', red, 'LineWidth', 2.5);
plot(EEG.times, resp_correctMean, 'color', blue, 'LineWidth', 2.5);
title(sprintf('Error vs. Correct Incongruent Trials'), 'FontSize', 30);
legendHandle = legend('Error', 'Correct');
set(legendHandle, 'box', 'off', 'FontSize', 26);
hold off;

% set parameters
plotStartTime = -400; %(in ms)
plotEndTime = 600 ; %(in ms)
set(gcf, 'Color', [1 1 1]);
set(gca, 'YLim', [-10 20]);
set(gca, 'XLim', [plotStartTime plotEndTime]);
set(gca, 'FontSize', 20);
set(get(gca, 'YLabel'), 'String', 'Amplitude in  \muV', 'FontSize', 26);
set(get(gca, 'XLabel'), 'String', 'Time Relative to Response (ms)', 'FontSize', 26);
set(gca, 'Box', 'off');
set(gcf, 'Position', [0 0 1440 900]);
grid on;
saveas(gcf, 'erpDat_dheeg_p_13_baseline_-400_-200_chans_1_4.png');

%% Plot topos!!

%load the mat file that has the erps and subject list
load('C:\Users\cknowlto\temp\diverse-hair-eeg-alpha\derivatives\dheeg_flanker_Resp_erps_min_6t_05_24_2026_21_19_54.mat')

%make a copy/rename the erp matrix 
allData = erpDat_data;

%load in one of the participants EEGLAB-formatted data; this is to load
%parameters needed for plotting (sampling rate, chanlocs, etc).
EEG = pop_loadset( 'filename', datafile_names{2}, 'filepath', data_location);
EEG = eeg_checkset(EEG);
eeglab redraw

%round EEG.times to nearest whole ms to make easier to work with
EEG.times = round(EEG.times);

%setup for baseline correcting the ERP data (always done before plotting or extracting
%erps, not done to the data previously to allow use of different baselines
%as a function of review comments)
startTime = -400; %(in ms)
endTime = -200 ; %(in ms)

%find closest values in (rounded) EEG.times to the specified start/stop
[temp,startIdx] = min(abs(EEG.times-startTime));
[temp2,endIdx] = min(abs(EEG.times-endTime));

%baseline corrections
Range = startIdx:endIdx;
allBase = squeeze(mean(allData(:,:,:,Range),4));
allBase = mean(allData(:,:,:,Range),4);

for i=1:size(allData,4)
    newData(:,:,:,i) = allData(:,:,:,i) - allBase;
end

%start and end time range for component of interest
compStartTime = 0; %(in ms)
compEndTime = 100 ; %(in ms)

%find closest values in (rounded) EEG.times to the specified start/stop
[temp,compStartIdx] = min(abs(EEG.times-compStartTime));
[temp2,compEndIdx] = min(abs(EEG.times-compEndTime));

%idxs of time range to plot topo for
compRange = compStartIdx:compEndIdx;

%pull out four conditions of interest for all subs
resp_error = mean(newData(:,1,:,compRange),4);
resp_corr = mean(newData(:,2,:,compRange),4);

%average across subs
resp_errorMean = squeeze(mean(resp_error,1));
resp_corrMean = squeeze(mean(resp_corr,1));

%compute difference topo
resp_errorMean_diff = resp_errorMean - resp_corrMean;

%plot topos
figure
topoplot(resp_errorMean, EEG.chanlocs, 'maplimits', [-3 3], 'electrodes', 'on', 'gridscale', 300, 'plotrad', .6)
set(get(gca, 'title'), 'String', 'Error (0-100 ms)', 'FontSize', 20);

cbar = colorbar;
cbar.Label.String = 'Amplitude (mV)';
cbar.Label.FontSize = 14;
set(cbar, 'FontSize', 12);
saveas(gcf, 'erpDat_topo_p_8_baseline_-400_-200_error.png');

figure
topoplot(resp_corrMean, EEG.chanlocs, 'maplimits', [-4 4], 'electrodes', 'on', 'gridscale', 300)
set(get(gca, 'title'), 'String', 'Correct (0-100 ms)', 'FontSize', 20);

cbar = colorbar;
cbar.Label.String = 'Amplitude (mV)';
cbar.Label.FontSize = 14;
set(cbar, 'FontSize', 12);
saveas(gcf, 'erpDat_topo_p_8_baseline_-400_-200_correct.png');

figure
topoplot(resp_errorMean_diff, EEG.chanlocs, 'maplimits', [-4 4], 'electrodes', 'on', 'gridscale', 300)
set(get(gca, 'title'), 'String', 'Error minus Correct (0-100 ms)', 'FontSize', 20);

cbar = colorbar;
cbar.Label.String = 'Amplitude (mV)';
cbar.Label.FontSize = 14;
set(cbar, 'FontSize', 12);
saveas(gcf, 'erpDat_topo_p_8_baseline_-400_-200_error_diff_correct.png');