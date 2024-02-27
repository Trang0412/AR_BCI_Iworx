header = 'iwxDAQ\x64\iwxDAQ.h'; % url for header
dll = 'iwxDAQ\x64\iwxDAQ.dll'; % url for .dll
loadlibrary(dll, header);

logfile = 'iworx.log';
bRet = calllib('iwxDAQ', 'OpenIworxDevice', logfile);

% FindHardware
[bRet, model_number, name_buffer, sn_buffer] = calllib('iwxDAQ', 'FindHardware', 0, blanks(1000), 1000, blanks(1000), 1000); % bufferSize  should be  atleast 16 bytes long
%calllib('iwxDAQ', 'FindHardware', model_number_pointer, name_buffer_pointer, 1000, sn_buffer_pointer, 1000); % bufferSize  should be  atleast 16 bytes long

% find the current directory so we can make sure that the file are in the correct place
currentFolder = pwd;

fout = fopen('output_file.m', 'w');

iRet = calllib('iwxDAQ', 'LoadConfiguration', 'ECG_circulation_test.iwxset'); % Load a settings file that has been created with LabScribe

% Get current sampling speed and num of channels
[bRet, speed, num_channels_recorded] = calllib('iwxDAQ', 'GetCurrentSamplingInfo', 0, 0);

% Optional get some other parameters 

[bRet, max_speed, min_speed, simultaneous_sampling] = calllib('iwxDAQ', 'GetSamplingSpeed', 0, 0, 0);
[bRet, analog_input_channels, analog_output_channels, digital_input_bits, digital_output_bits] = calllib('iwxDAQ', 'GetNumChannels', 0, 0, 0, 0);

% Done reading optional parameters

% Start Acquisition
iRet = calllib('iwxDAQ', 'StartAcq', speed * single(num_channels_recorded)); % setup internal buffer for 1 second worth of data. 
pts_recorded = 0;
% Read Data and save it to file
fprintf(fout, 'Channels = [');
for i = 0:9
	[iRet, num_samples_per_ch, trig_index, trig_string, data] = calllib('iwxDAQ', 'ReadDataFromDevice', 1000, 0, blanks(256), 256, zeros(1, 10000), 1000);
	pts_recorded = pts_recorded + num_samples_per_ch * num_channels_recorded;
	% Save data to file
	m = 1;
	for j = 0:(pts_recorded-1)
		for k = 0:(num_channels_recorded-1)
            fprintf(fout, ' %f', data(m));
			m = m + 1;
		end
		fprintf(fout, ';');
	end
	pause(0.1);
end
fprintf(fout, '];\nChannels = Channels.'';\n');
fprintf(fout, 'plot(Channels);\ntitle(''All Channels'');\n');
for i = 1:(num_channels_recorded)
	fprintf(fout, 'pause;\nplot(Channels(:, %d));\ntitle(''Channel %d'');\n', i, i);
end
% Stop Acquisition
calllib('iwxDAQ', 'StopAcq');

% Close the iWorx Device
calllib('iwxDAQ', 'CloseIworxDevice');

% Unload the library
unloadlibrary iwxDAQ;