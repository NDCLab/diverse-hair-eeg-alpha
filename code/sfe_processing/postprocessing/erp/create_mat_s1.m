%
% Modified on 2026/06 to process SFE dataset for DHEEG comparison analyses
%
% This script was created by George Buzzell for the NDC Lab EEG Training
% Workshop on 02/22. This script uses parts of the "set up" structure from
% the MADE preprocessing pipeline (Debnath, Buzzell, et. al., 2020)
% Modified further for preprocessing READ flanker
clear % clear matlab workspace
clc % clear matlab command window

%% Setting up other things

%Location of MADE and ADJUSTED-ADJUST scripts
% addpath(genpath([main_dir filesep 'MADE-EEG-preprocessing-pipeline']));% enter the path of the EEGLAB folder in this line
addpath(genpath('/home/data/NDClab/tools/lab-devOps/scripts/MADE_pipeline_standard/eeg_preprocessing'));% enter the path of the folder in this line

%Location of "EEG
% addpath(genpath([main_dir filesep 'eeglab13_4_4b']));% enter the path of the EEGLAB folder in this line
addpath(genpath('/home/data/NDClab/tools/lab-devOps/scripts/MADE_pipeline_standard/eeglab13_4_4b'));% enter the path of the EEGLAB folder in this line

%remove path to octave functions inside matlab to prevent errors when
% rmpath([main_dir filesep 'eeglab13_4_4b' filesep 'functions' filesep 'octavefunc' filesep 'signal'])
rmpath(['/home/data/NDClab/tools/lab-devOps/scripts/MADE_pipeline_standard/eeglab13_4_4b' filesep 'functions' filesep 'octavefunc' filesep 'signal'])

%% setup; run this section before any other section below

%location of analysis folder
analysis_dir = '/home/data/NDClab/analyses/diverse-hair-eeg-alpha';

%location of dataset folder
dataset_dir = '/home/data/NDClab/datasets/diverse-hair-eeg-dataset';
summary_csv_path = '/home/data/NDClab/datasets/social-flanker-eeg-dataset/derivatives/behavior/beh_all.csv';

% Setting up other things

% 1. Enter the path of the folder that has the data to be analyzed
data_location = [dataset_dir filesep 'derivatives' filesep 'preprocessed' filesep 'sfe_derivatives'];

% 2. Enter the path of the folder where you want to save the postprocessing outputs
output_location = [analysis_dir filesep 'derivatives'];

% %specify parameters of data to process

%modifying above, to account for files named differently
%specify parameters of data to process
task = 'flanker';
procStage = 'processed_data';
visitFileName = 's1_r1_e1';

% Read files to analyses
% Example file name: sub-160015_eeg_processed_data_s1-r1-e1.set
datafile_info=dir([data_location filesep 'sub-*' filesep 'eeg' filesep 'sub-*' procStage '_*' '.set']);
datafile_info=datafile_info(~ismember({datafile_info.name},{'.', '..', '.DS_Store'}));
datafile_names={datafile_info.name};
datafile_paths={datafile_info.folder};
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

%% Count trials
% switch to output directory
cd(output_location);

% %create variable names for count trials output and write to disk
% outputHeader = {'id, s_resp_incon_error, s_resp_incon_corr, ns_resp_incon_error, ns_resp_incon_corr'};
% dlmwrite(strcat('thrive_trialCounts_respOnly', date, '.csv'), outputHeader, 'delimiter', '', '-append');

diary(sprintf('erp_log_%s.log', datestr(now, 'mm_dd_yyyy_HH_MM_SS')))

for subject=1:length(datafile_names)

    EEG=[];

    fprintf('\n\n\n*** Processing subject %d (%s) ***\n\n\n', subject, datafile_names{subject});

    %load in raw data that is alread in eeglab (.set) format)
    EEG = pop_loadset( 'filename', datafile_names{subject}, 'filepath', datafile_paths{subject});
    EEG = eeg_checkset(EEG);

    %convert subject name to number
    %note:would be nice to modify line below to not be hard-coded for finding
    %location of subject id. eg, use some combination of strtok instead
    subIdNum = str2double(datafile_names{subject}(5:11));

    %remove all the non-stim-locking markers (should have done already...)
    EEG = pop_selectevent( EEG, 'latency','-.1 <= .1','deleteevents','on');
    EEG = eeg_checkset( EEG );

    %count how many of each event type (combination of event types) of
    %interest are present (pulling all conditions but for this comparison only interested in nonsocial data)
    resp_incon_error_ns = length(find( (strcmp({EEG.event.observation}, "ns")) & (strcmp({EEG.event.eventType}, "resp")) & (strcmp({EEG.event.congruency}, "i")) & ([EEG.event.accuracy] == 0) & ([EEG.event.responded] == 1) & ([EEG.event.validRt] == 1) & ([EEG.event.extraResponse] == 0) ));
    resp_incon_corr_ns = length(find( (strcmp({EEG.event.observation}, "ns")) & (strcmp({EEG.event.eventType}, "resp")) & (strcmp({EEG.event.congruency}, "i")) & ([EEG.event.accuracy] == 1) & ([EEG.event.responded] == 1) & ([EEG.event.validRt] == 1) & ([EEG.event.extraResponse] == 0)   ));
    stim_incon_corr_ns = length(find( (strcmp({EEG.event.observation}, "ns")) & (strcmp({EEG.event.eventType}, "stim")) & (strcmp({EEG.event.congruency}, "i")) & ([EEG.event.accuracy] == 1) & ([EEG.event.responded] == 1) & ([EEG.event.validRt] == 1) & ([EEG.event.extraResponse] == 0)   ));
    stim_con_corr_ns = length(find( (strcmp({EEG.event.observation}, "ns")) & (strcmp({EEG.event.eventType}, "stim")) & (strcmp({EEG.event.congruency}, "c")) & ([EEG.event.accuracy] == 1) & ([EEG.event.responded] == 1) & ([EEG.event.validRt] == 1) & ([EEG.event.extraResponse] == 0)   ));
    resp_incon_error_s = length(find( (strcmp({EEG.event.observation}, "s")) & (strcmp({EEG.event.eventType}, "resp")) & (strcmp({EEG.event.congruency}, "i")) & ([EEG.event.accuracy] == 0) & ([EEG.event.responded] == 1) & ([EEG.event.validRt] == 1) & ([EEG.event.extraResponse] == 0) ));
    resp_incon_corr_s = length(find( (strcmp({EEG.event.observation}, "s")) & (strcmp({EEG.event.eventType}, "resp")) & (strcmp({EEG.event.congruency}, "i")) & ([EEG.event.accuracy] == 1) & ([EEG.event.responded] == 1) & ([EEG.event.validRt] == 1) & ([EEG.event.extraResponse] == 0)   ));
    stim_incon_corr_s = length(find( (strcmp({EEG.event.observation}, "s")) & (strcmp({EEG.event.eventType}, "stim")) & (strcmp({EEG.event.congruency}, "i")) & ([EEG.event.accuracy] == 1) & ([EEG.event.responded] == 1) & ([EEG.event.validRt] == 1) & ([EEG.event.extraResponse] == 0)   ));
    stim_con_corr_s = length(find( (strcmp({EEG.event.observation}, "s")) & (strcmp({EEG.event.eventType}, "stim")) & (strcmp({EEG.event.congruency}, "c")) & ([EEG.event.accuracy] == 1) & ([EEG.event.responded] == 1) & ([EEG.event.validRt] == 1) & ([EEG.event.extraResponse] == 0)   ));

    %Create the trial counts table for trial counts
    counts_table=table({datafile_names{subject}}, {resp_incon_error_ns}, {resp_incon_corr_ns}, {stim_incon_corr_ns}, {stim_con_corr_ns}, {resp_incon_error_s}, {resp_incon_corr_s}, {stim_incon_corr_s}, {stim_con_corr_s});

    %create variable names for count trials output and write to disk
    counts_table.Properties.VariableNames = {'fileName', 'resp_incon_error_ns', 'resp_incon_corr_ns', 'stim_incon_corr_ns', 'stim_con_corr_ns', 'resp_incon_error_s', 'resp_incon_corr_s', 'stim_incon_corr_s', 'stim_con_corr_s'};

    %write/append table to disk
    writetable(counts_table, [output_location filesep 'sfe_trialCounts_RespAndStim_', date, '.csv'], "WriteMode", "append");

end

%% pull resp-locked erp mat file

%read in behavioral data for participants
behavior_info = readtable(summary_csv_path);

%specify min number of trials per condition (if file contains less than
%this number for ANY condition, then they will be skipped for ALL conditions
minTrials = 6;

%specify min accuracy per condition (if file contains less than
%this number for ANY condition, then they will be skipped for ALL conditions
acc_cutoff = .6;

%initialize participant counter variable (used for indexing into large mat
%file that data is saved into)
pIdx = 1;

%initialize matrices to hold erp data, corresponding sub ids, and the
%analytic sme measurement
erpDat_data = [];
erpDat_subIds = [];
aSME = [];

% loop through each participant in the study
for subject = 1:length(datafile_names)

    %initialize numTrials for this participant/file
    numTrials = [];

    % extract participant number
    subNumText = datafile_names{subject}(5:10);

    %find row in behavior file corresponding to this participant
    behavior_id_match_idxs = find(behavior_info{:,'subject'} == str2num(subNumText));

    %if participant has low accuracy in either condition, skip that
    %participant for ALL conditions
    if (behavior_info{behavior_id_match_idxs,'acc_all_nonsocial'} < acc_cutoff) % social data not being used so only removing this criteria for the data being used (i.e., nonsocial / alone)
        continue
    end
     
    %if (behavior_info{behavior_id_match_idxs,'6_or_more_err'} == 0) all participants have > 60% behavioral accuracy
        %continue
    %end
    %load the original data set
    EEG = pop_loadset( 'filename', datafile_names{subject}, 'filepath', datafile_paths{subject});
    EEG = eeg_checkset( EEG );

    %remove all the non-stim-locking markers (should have done already...)
    EEG = pop_selectevent( EEG, 'latency','-.1 <= .1','deleteevents','on');
    EEG = eeg_checkset( EEG );

    %count trials for each condition of interest and store in numTrials vector
    % subset of only nonsocial data, social data is not being used at all
    numTrials(1) = length(find( (strcmp({EEG.event.observation}, "ns")) & (strcmp({EEG.event.eventType}, "resp")) & (strcmp({EEG.event.congruency}, "i")) & ([EEG.event.accuracy] == 0) & ([EEG.event.responded] == 1) & ([EEG.event.validRt] == 1) & ([EEG.event.extraResponse] == 0) ));
    numTrials(2) = length(find( (strcmp({EEG.event.observation}, "ns")) & (strcmp({EEG.event.eventType}, "resp")) & (strcmp({EEG.event.congruency}, "i")) & ([EEG.event.accuracy] == 1) & ([EEG.event.responded] == 1) & ([EEG.event.validRt] == 1) & ([EEG.event.extraResponse] == 0) ));
    %logical test if the number of trials for each condition (numTrials vector)
    %are NOTE all >= minTrials. If statement is true, then participant/file
    %is skipped and for loop over files continues to next file
    if ~(sum(numTrials >= minTrials) == length(numTrials))
        continue
    end

    % loop through conditions of interest for this file (combo of event types)
    %
    % specify number of conditions using a seperate conditionNums var, so
    % that it can be referenced below when iterating idx counters (to only
    %iterate when c == length(conditionNums);
    conditionNums = 1:2;
    %
    for c = conditionNums
        %only pulling ns conditions, social is not being used
        if (c==1) % ns error
            observation = 'ns';
            eventType = 'resp';
            congruency = 'i';
            accuracy = 0;
            responded = 1;
            validRt = 1;
            extraResponse = 0;
        elseif (c==2) % ns correct
            observation = 'ns';
            eventType = 'resp';
            congruency = 'i';
            accuracy = 1;
            responded = 1;
            validRt = 1;
            extraResponse = 0;
        end

        %select combintion of event types of interest based on vars above
        EEG1 = pop_selectevent( EEG, 'latency', '-1<=1', 'eventType', eventType, 'congruency', congruency, 'accuracy', accuracy, 'responded', responded, 'validRt', validRt, 'extraResponse', extraResponse, 'deleteevents', 'on', 'deleteepochs', 'on', 'invertepochs', 'off');
        EEG1 = eeg_checkset(EEG1);

        % Average across epoch dimension
        % this all Channel ERP only needs to be computed once
        % per condition
        meanEpochs = mean(EEG1.data, 3);

        % Analytic SME (aSME) for the mean-amplitude score
        measStart = 0; measEnd = 100;
        baseStart = -400; baseEnd = -200;
        
        t = round(EEG1.times);
        [~,mS]=min(abs(t-measStart)); [~,mE]=min(abs(t-measEnd));
        [~,bS]=min(abs(t-baseStart)); [~,bE]=min(abs(t-baseEnd));
        win = mS:mE; baseWin = bS:bE;
        
        channels = [1 33]; %2 frontal electrodes avaliable in SEP set up so we use the same two equals from the SFE dataset
        d  = EEG1.data - mean(EEG1.data(:,baseWin,:), 2); %baseline correction
        dd = squeeze(mean(d(channels,:,:), 1));
        sc = mean(dd(win,:), 1);
        aSME(pIdx,c) = std(sc) / sqrt(numel(sc));

        %store data for this condition in array
        erpDat_data(pIdx,c,:,:)= meanEpochs;

        %store participant number for corresponding row in erpdat
        erpDat_subIds{pIdx,1} = datafile_names{subject}(5:10);

        %iterate idx counter IMPORTANT: ONLY ITERATE COUNTER WHEN
        %ON LAST CONDITION
        if c == length(conditionNums)%if this is the last condition of condition loop
            pIdx = pIdx + 1;
        end
        %end loop through conditions
    end
    %end loop through participants
end

%save the erps and subject list
save(sprintf('sfe_flanker_Resp_erps_min_6t_%s.mat', datestr(now, 'mm_dd_yyyy_HH_MM_SS')), 'erpDat_data', 'erpDat_subIds', 'aSME')

%% Plot electrode layout with aSME channels highlighted

% Load any subject's EEG just to get the channel location structure
EEG_tmp = pop_loadset('filename', datafile_names{1}, 'filepath', datafile_paths{1});
EEG_tmp = eeg_checkset(EEG_tmp);

% Channels used for aSME
aSME_channels = [1 33];

% Plot blank topoplot (all zeros, no colorbar)
figure;
topoplot(zeros(1, EEG_tmp.nbchan), EEG_tmp.chanlocs, ...
    'style', 'blank', ...
    'electrodes', 'on', ...
    'emarker', {'.', 'k', 8, 1});  % all electrodes as small black dots

hold on;

% Overlay red dots at aSME channel locations
for ch = aSME_channels
    topoplot(zeros(1, EEG_tmp.nbchan), EEG_tmp.chanlocs, ...
        'style', 'blank', ...
        'electrodes', 'on', ...
        'emarker2', {ch, 'o', 'r', 12, 2});  % red circle at target channel
end

title('Electrode layout — aSME channels (red)');

% Save figure
saveas(gcf, [output_location filesep 'sfe_aSME_electrode_topo.png']);