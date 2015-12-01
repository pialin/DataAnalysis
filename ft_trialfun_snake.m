function [trl, event] = ft_trialfun_snake(cfg)

hdr = ft_read_header(cfg.dataset);
event = ft_read_event(cfg.dataset);
SelectedEvent = false(1, numel(event));

for iEvent=1:numel(event)
    SelectedEvent(iEvent) =  ismatch(event(iEvent).type, cfg.trialdef.eventtype) && ismatch(event(iEvent).value, cfg.trialdef.eventvalue);
end

% convert from boolean vector into a list of indices
SelectedEvent = find(SelectedEvent);
trl = [] ;

for iEvent= 1:numel(SelectedEvent)
  % catch empty fields in the event table and interpret them meaningfully
  if isempty(event(SelectedEvent(iEvent)).offset)
    % time axis has no offset relative to the event
    event(SelectedEvent(iEvent)).offset = 0;
  end
  if isempty(event(SelectedEvent(iEvent)).duration)
    % the event does not specify a duration
    event(SelectedEvent(iEvent)).duration = 0;
  end
  
  
  SampleBegin = event(SelectedEvent(iEvent)).sample;
  
  
  
  if iEvent ~= numel(SelectedEvent)
      SampleEnd  = event(SelectedEvent(iEvent+1)).sample-1;
  else
      SampleEnd  = event(end).sample-1;
  end
  
  NumSeg = fix((SampleEnd-SampleBegin)/(cfg.seglen*hdr.Fs));
  
  if NumSeg >= 1
      
      iSeg = (1:NumSeg)';
      
      trlbeg = SampleBegin + ((iSeg-1)*cfg.seglen*hdr.Fs);
      
      trlend = SampleBegin + (iSeg*cfg.seglen*hdr.Fs)-1;
      
      trloff = ones(NumSeg,1)*(event(SelectedEvent(iEvent)).offset);
      
      trlval = ones(NumSeg,1)*(event(SelectedEvent(iEvent)).value-200);
      
      trl = [trl ; trlbeg,trlend,trloff,trlval];
      
  end
end

%%
function s = ismatch(x, y)
if isempty(x) || isempty(y)
  s = false;
elseif ischar(x) && ischar(y)
  s = strcmp(x, y);
elseif isnumeric(x) && isnumeric(y)
  s = ismember(x, y);
elseif ischar(x) && iscell(y)
  y = y(strcmp(class(x), cellfun(@class, y, 'UniformOutput', false)));
  s = ismember(x, y);
elseif isnumeric(x) && iscell(y) && all(cellfun(@isnumeric, y))
  s = false;
  for iSelectedEvent=1:numel(y)
    s = s || ismember(x, y{iSelectedEvent});
  end
else
  s = false;
end