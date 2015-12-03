function  FtTrial2EcoMat(ft_DataStruct,trl)

EEG = [];
EEG.data = cell2mat(ft_DataStruct.trial);
EEG.labels = ft_DataStruct.label;
EEG.type = 'EEG';
EEG.nbchan = ft_DataStruct.hdr.nChans;
EEG.points = size(EEG.data,2);
EEG.srate = ft_DataStruct.hdr.Fs;
EEG.labeltype = 'standard';
EEG.unit = 'uV';
StartSample = 1;
EventTime = zeros(size(trl,1),1);
for iTrial = 1:size(trl,1)
    
    EventTime(iTrial) = StartSample - trl(iTrial,3);
    
    StartSample = StartSample + (trl(iTrial,2)- trl(iTrial,1)+1);
end

EEG.event.name = 'stimulation';
EEG.event.time = EventTime;

save EcoMat.mat EEG;

end