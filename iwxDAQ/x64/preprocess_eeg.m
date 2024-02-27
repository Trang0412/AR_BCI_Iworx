% -Preprocess streaming EEG data 

% Usage
% Pre-process procedure

% Author: Le Thi Trang, CNE lab
% Date: Feb 26, 2024



function preprocess_eeg(data, fs)
    % bandpass filter from 2-57 Hz
    [b, a] = butter(6, [2 57]/(fs/2));
    data = filter(b, a, data);

end