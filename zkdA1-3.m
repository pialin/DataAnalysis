
%环境变量设置
CntFolderName = 'CntFiles';
SubjectName = 'zkd';
ExpDate = '20151021';
ExpName = 'A1';
WhichExp = 3;

CntPath = [CntFolderName,filesep,SubjectName,filesep,ExpDate,filesep,ExpName,'-',num2str(WhichExp),'.cnt'];
%读入数据
cfg=[];
cfg.dataset = CntPath;
data_cnt =  ft_preprocessing(cfg);

   

%滤波(50,100,150Hz陷波)
cfg=[];
cfg.dftfilter = 'yes';
cfg.dftfreq = [50,100,150];
data_notched =  ft_preprocessing(cfg,data_cnt);

cfg=[];
cfg.viewmode = 'vertical';
cfg.channel = 'HEO';
ft_databrowser(cfg,data_notched);
ft_databrowser(cfg,data_cnt);

plot(data_cnt.trial{1}(1,1:5000));

hold on;
plot(data_notched.trial{1}(1,1:5000)-10,'r');





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
