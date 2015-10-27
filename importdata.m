
%环境变量设置
CntFolderName = 'CntFiles';
SubjectName = 'zkd';
ExpDate = '20151021';
ExpName = 'A1';
WhichExp = 3;
if ~exist(CurrentCntPath,'var')
    CurrentCntPath = [];
end

CntPath = [CntFolderName,filesep,SubjectName,filesep,ExpDate,filesep,ExpName,'-',num2str(WhichExp),'.cnt'];
if strcmp(CntPath,CurrentCntPath)


end

%首次读取并以'fcdc_matbin'格式保存
header = ft_read_header(CntPath);
data = ft_read_data(CntPath, 'header', header);
event = ft_read_event(CntPath);

ft_write_data('data.bin', data, 'header', header, 'dataformat','fcdc_matbin');

save event.mat event;

clear header data event;

%读入数据
cfg = [];
cfg.datafile = 'data.bin';
cfg.headerfile   = 'data.mat';
data_raw = ft_preprocessing(cfg);


%滤波(50,100,150Hz陷波)
cfg.dftfilter = 'yes';
cfg.dftfreq = [50,100,150];
data_notched =  ft_preprocessing(cfg);






z = num2cell(zeros(1,20));
[event(8:6:122).value]= z{:};


cfg=[];
cfg.event=event;
cfg.trialdef.prestim =1;
cfg.trialdef.poststim =6;
cfg.trialdef.eventtype='stimtype';
cfg.trialdef.eventvalue=1:20;
cfg.dataset='A1-1.cnt';


cfg=ft_definetrial(cfg);


data_raw = ft_preprocessing(cfg);


cfg.viewmode='vertical';
cfg=ft_databrowser(cfg);


cfg.method ='summary';
% cfg.alim=5e-5;
ft_rejectvisual(cfg,data_raw)
