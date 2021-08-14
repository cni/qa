%% Draft 

cni = scitran('cni');

qaProject = cni.lookup('cni/qa');
qaSessions = qaProject.sessions();
id = qaSessions{end-12}.id
thisSession = cni.fw.get(id);

an = thisSession.analyses();

thisA = cni.fw.get('60f7348b20c8ff1669df479f');

qaFiles = thisA.files;
stPrint(qaFiles,'name')
qaFiles{8}.download('thisresult.json');
result = jsonread('thisresult.json');

