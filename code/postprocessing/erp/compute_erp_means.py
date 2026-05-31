import mne
import io
import numpy as np
import scipy.io
import pandas as pd
from glob import glob
import datetime
import time
import h5py

session = "s1_r1"
laplacian = False

dataset_path = "C:\Users\cknowlto\temp\diverse-hair-eeg-dataset\"
analysis_path = "C:\Users\cknowlto\temp\diverse-hair-eeg-alpha\"

outputHeader = [
    'id',
    'ERN_soc', 'CRN_soc', 'ERN_nonsoc', 'CRN_nonsoc',
    'ERN_min_CRN_diff_soc', 'ERN_min_CRN_diff_nonsoc',
    # 'PE_error_soc', 'PE_corr_soc', 'PE_error_nonsoc', 'PE_corr_nonsoc',
    # 'PE_err_min_corr_diff_soc', 'PE_err_min_corr_diff_nonsoc'
]

output_data = pd.DataFrame()

clustCell= [
    [i-1 for i in [1, 4]], #2 electrodes in the SEP set up that are placed over MFC
    # [i-1 for i in [17, 49, 50, 19, 18]],
]

timeCell = [
    [0, 100], # ERN cluster
    # [300, 500], # PE cluster
]

if laplacian:
    #path_to_mat = glob(f"{analysis_path}/derivatives/preprocessed/erp_check/{session}/dheeg_Resp_erps_csd_min_6t_*2025*.mat")[0]
else:
    path_to_mat = glob(f"{analysis_path}/derivatives/dheeg_flanker_Resp_erps_min_6t_05_24_2026_21_19_54.mat")[0] #latest file; computed on "checked" data
    #path_to_mat = glob(f"{analysis_path}/derivatives/preprocessed/erp_check/{session}/dheeg_Resp_erps_min_6t_02_11_2025_15_17_33.mat")[0]

path_to_eeg = glob(f"{dataset_path}/derivatives/preprocessed/sub-290005/eeg/sub-290005_flanker_eeg_filtered_data_s1_r1_e1.set")[0]

mat = scipy.io.loadmat(path_to_mat)
allData = mat['erpDat_data']

# take IDs from EEG (all people > 6 trials)
sub_from_eeg = [int(mat["erpDat_subIds"][i].item()[0]) for i in range(len(mat["erpDat_subIds"]))] 

EEG = mne.io.read_epochs_eeglab(path_to_eeg, verbose=False)

EEG_times = EEG.times * 1000
startTime = -400
endTime = -200

startIdx = np.argmin(np.abs(EEG_times-startTime)) # get start index for baseline
endIdx = np.argmin(np.abs(EEG_times-endTime)) # get end index for baseline

allBase = np.squeeze(np.mean(allData[:, :, :, startIdx:endIdx+1], 3))
allBase = np.mean(allData[:, :, :, startIdx:endIdx+1], 3)
newData = np.zeros_like(allData)

for i in range(allData.shape[3]):
    newData[:, :, :, i] = allData[:, :, :, i] - allBase # baseline correction

# %round EEG.times to nearest whole ms to make easier to work with
# EEG.times = round(EEG.times);

output_data[outputHeader[0]] = sub_from_eeg

# initialize index var at 1 because i=0 is the column for subject ids
i = 1
for comp in range(len(clustCell)):

    cluster= clustCell[comp]
    times = timeCell[comp]

    compStartTime = times[0] # in ms
    compEndTime = times[1] # in ms

    compStartIdx = np.argmin(np.abs(EEG_times-compStartTime))
    compEndIdx = np.argmin(np.abs(EEG_times-compEndTime))

    resp_incon_error_avgTime = np.mean(newData[:, 0:1, :, compStartIdx:compEndIdx+1], 3)
    resp_incon_corr_avgTime = np.mean(newData[:, 1:2, :, compStartIdx:compEndIdx+1], 3)

    # average cluster of interest
    resp_incon_error_avgTimeClust = np.mean(s_resp_incon_error_avgTime[:, :, cluster], 2)
    resp_incon_corr_avgTimeClust = np.mean(s_resp_incon_corr_avgTime[:, :, cluster], 2)

    # compute difference score
    resp_incon_error_avgTimeClust_diff = resp_incon_error_avgTimeClust - resp_incon_corr_avgTimeClust

    output_data[outputHeader[i]] = resp_incon_error_avgTimeClust
    output_data[outputHeader[i+1]] = resp_incon_corr_avgTimeClust
    output_data[outputHeader[i+2]] = resp_incon_error_avgTimeClust_diff
    i+=3

output_data
output_data = output_data.iloc[:, :5]
if laplacian:
    output_data.columns = [i + "_laplacian" if i != "id" else i for i in output_data.columns]
output_data = output_data.rename({"id": "sub"}, axis=1)

if laplacian:
    output_data.to_csv("{analysis_path}/derivatives/csv/{session}/dheeg_erp_laplacian.csv", index=False)
else:
    output_data.to_csv(f"{analysis_path}/derivatives/csv/{session}/dheeg_erp.csv", index=False)
