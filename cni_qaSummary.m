%% Draft 

%% Open a channel to the cni Flywheel instaqnce
cni = scitran('cni');

%% Get the QA project information
%{
qaProject = cni.lookup('cni/qa');

% This gets a partial download of the session information.  To get the full
% download
qaSessions = qaProject.sessions();

%%
id = qaSessions{end-12}.id;
thisSession = cni.fw.get(id);

an = thisSession.analyses();

thisA = cni.fw.get('60f7348b20c8ff1669df479f');

qaFiles = thisA.files;
stPrint(qaFiles,'name')
qaFiles{8}.download('thisresult.json');
result = jsonread('thisresult.json');
%}
%% The logical flow

% How to get a single, full project by search.
tmp = cni.search('project','project label exact','qa','container',true);
qaProject = tmp{1};

% Find the sessions created after a certain date.
qaSessions = qaProject.sessions.find('created>2021-06-15');

%% Could we search for qa project sessions with a recent date?

% I guess so!  We must 'fw' true it takes a lot longer but we get back
% everything.  If we do not, then we get a good summary.  Might be enough.
%{
qaSessions = cni.search('session',...
    'project label exact','qa',...
    'session after time','now-26w',...
    'container',true);
size(qaSessions)
%}

%%  For each session, we can find the acquisitions and analyses this way

ss = 12;
% We will loop on these to get all the snr and sfnr data
qaAcq = qaSessions{ss}.acquisitions();
stPrint(qaAcq,'label');

qaAnalyses = qaSessions{ss}.analyses();
stPrint(qaAnalyses,'label');

%% Find all the analyses with a 'cni-tsnr' in the label
qaFiles    = qaSessions{ss}.files;
qaAnalyses = qaSessions{ss}.analyses();
qaAnalyses = stSelect(qaAnalyses,'label','cni-tsnr');

% Find the result file
thisFile = stSelect(qaAnalyses{1}.files,'name','result');

% Download the file and read its contents
thisFile{1}.download('result.json');
qaData = jsonread('result.json');
qaData.created = qaAnalyses{1}.created;

%% Find which acquisition has the input file from the analyses

% The acquisition label should be the same when we plot the snr or sfnr.
thisA = qaAnalyses{1};
fileid = thisA.inputs{1}.id;
tmp = cni.search('acquisition','fileid',fileid,'container',true);
thisAcq = tmp{1};
thisAcq.label
qaData.acquisition = thisAcq.label;

%% Now we could pull out the variables we want
%
% Say we want the snr for all the acquisitions with a label
% or the sfnr.  

%% This would be all sessions in the project.

% qaSessions = qaProject.sessions();


%% END