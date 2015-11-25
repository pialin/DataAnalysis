%实验数据选择
cd E:\Documents\Git\DataAnalysis\;

CntFolderName = 'CntFiles';
SubjectName = 'zkd';
ExpDate = '20151021';
ExpName = 'A1';
WhichExp = 3;

CntPath = [CntFolderName,filesep,SubjectName,filesep,ExpDate,filesep,ExpName,'-',num2str(WhichExp),'.cnt'];

cfg=[];

%数据集指定
cfg.dataset = CntPath;

%导联选择
cfg.channel = {'all','-HEO','-VEO','-EKG','-EMG','-M1','-M2','-CB1','-CB2'};
%重参考（共平均参考）
cfg.reref = 'yes';
cfg.refchannel = cfg.channel;

%100Hz低通滤波
cfg.lpfilter = 'yes';
cfg.lpfreq = 100;

%处理event
event = ft_read_event(CntPath);
zerocell = num2cell(zeros(1,20));
[event(7:6:121).value]= zerocell{:};
cfg.event = event;

%数据分段
cfg.trialdef.eventtype = 'trigger';
cfg.trialdef.eventvalue = 1:20;
cfg.trialdef.prestim = 1;
cfg.trialdef.poststim = 6; 
cfg.trialfun = 'ft_trialfun_general';

cfg = ft_definetrial(cfg); 

%50Hz陷波滤波

cfg.dftfilter = 'yes';
cfg.dftfreq = 50;
cfg.continuous = 'yes';
cfg.padtype = 'data';
cfg.padding = 10;

%detrend
cfg.detrend = 'yes';


%demean
cfg.demean='yes';
cfg.baselinewindow = [-1,0];


data1_AfterPreproc = ft_preprocessing(cfg);

cfg = [];

cfg.viewmode = 'vertical';
cfg.fontsize = 0.02;
cfg.blocksize = 10;

ft_databrowser(cfg,data1_AfterPreproc);


 
%用z阈值检测jump伪迹
cfg.artfctdef.zvalue.channel = cfg.channel;
cfg.artfctdef.zvalue.cutoff = 20;
cfg.artfctdef.zvalue.trlpadding = 0;
cfg.artfctdef.zvalue.artpadding = 0;
cfg.artfctdef.zvalue.fltpadding = 0;
 
% algorithmic parameters
cfg.artfctdef.zvalue.cumulative    = 'yes';
cfg.artfctdef.zvalue.medianfilter  = 'yes';
cfg.artfctdef.zvalue.medianfiltord = 9;
cfg.artfctdef.zvalue.absdiff       = 'yes';
 
% make the process interactive
cfg.artfctdef.zvalue.interactive = 'yes';
%  [cfg, artifact_Jump] =
 ft_artifact_zvalue(cfg);

