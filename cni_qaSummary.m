%% Draft 

%% Open a channel to the cni Flywheel instaqnce
cni = scitran('cni');

%% Get the QA project information

qaProject = cni.lookup('cni/qa');

% This gets a partial download of the session information.  To get the full
% download
qaSessions = qaProject.sessions();

%%
id = qaSessions{end-12}.id
thisSession = cni.fw.get(id);

an = thisSession.analyses();

thisA = cni.fw.get('60f7348b20c8ff1669df479f');

qaFiles = thisA.files;
stPrint(qaFiles,'name')
qaFiles{8}.download('thisresult.json');
result = jsonread('thisresult.json');

%% Scratch

% How to get a single, full project by search.
tmp = cni.search('project','project label exact','qa','fw',true);
qaProject = tmp{1};

% Find the sessions created after a certain date.
sessions = qaProject.sessions.find('created>2021-04-15');

%% Could we search for qa project sessions with a recent date?

% I guess so!  We must 'fw' true it takes a lot longer but we get back
% everything.  If we do not, then we get a good summary.  Might be enough.
qaSessions = cni.search('session',...
    'project label exact','qa',...
    'session after time','now-26w',...
    'container',true);
size(qaSessions)

%%
qaAcq = qaSessions{12}.acquisitions();
stPrint(qaAcq,'label');
qaAnalyses = qaSessions{12}.analyses();
stPrint(qaAnalyses,'label');

%%
qaFiles    = qaSessions{12}.files;
qaAnalyses = qaSessions{12}.analyses();
qaAnalyses = stSelect(qaAnalyses,'label','cni-tsnr');

thisFile = stSelect(qaAnalyses{1}.files,'name','result')
thisFile{1}.download('result.json');
qaData = jsonread('result.json');
qaData.created = qaAnalyses{1}.created;

%%
% Find which acquisition has the input file from the analyses
% The acquisition label should be the same when we plot the snr or sfnr.
thisA = qaAnalyses{1};
fileid = thisA.inputs{1}.id;
tmp = cni.search('acquisition','fileid',fileid,'container',true);
thisAcq = tmp{1};
thisAcq.label
thisAcq.created

qaData.acquisition = thisAcq;


%% Find all the analyses with a 'cni-tsnr' in the label



%% This would be all sessions in the project.

% qaSessions = qaProject.sessions();


%% END