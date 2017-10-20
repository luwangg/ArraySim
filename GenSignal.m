function [ waveformArray, waveformSignal, steeringVector] = GenSignal(sysPara, hArray)
% /*!
%  *  @brief     This function generate the target signal.
%  *  @details   . 
%  *  @param[out] waveformArray, NxM complex doulbe. array response, i.e. signal waveform response at each antenna. N is the number of samples(snaps). M is the number of channel
%  *  @param[out] waveformSignal, Nx1 complex doulbe. signal waveform. N is the number of samples(snaps).
%  *  @param[out] steeringVector, Mx1 complex doulbe. steeringVector of the array according to the input signal.M is the number of channel
%  *  @param[in] sysPara, 1x1 struct, which contains the following field:
%       see get used field for detail.
%  *  @param[in] hArray, 1x1 antenna array system object.
%  *  @pre       .
%  *  @bug       Null
%  *  @warning   Null
%  *  @author    Collus Wang
%  *  @version   1.0
%  *  @date      2017.05.25.
%  *  @copyright Collus Wang all rights reserved.
%  * @remark   { revision history: V1.0, 2017.05.25. Collus Wang,  first draft }
%  * @remark   { revision history: V1.1, 2017.06.22. Collus Wang,  support 16QAM and 64QAM }
%  * @remark   { revision history: V1.2, 2017.07.12. Collus Wang, steering vector calculation can include element response.}
%  * @remark   { revision history: V1.3, 2017.10.18. Collus Wang and Wayne Zhang, add CustomPilot TargetSigType case.}
%  * @remark   { revision history: V1.4, 2017.10.20. Wayne Zhang, fix bug in 'custompilot' case: first target should not cirshift.}
%  */

%% get used field
TargetSigType = sysPara.TargetSigType;      % valid value = {'QPSK', '16QAM', '64QAM', 'CustomPilot'}
NumTarget = sysPara.NumTarget;              % 
TargetAngle = sysPara.TargetAngle;          % incoming wave direction in degree, [azimuth; elevation]. The azimuth angle must be between �C180 and 180 degrees, and the elevation angle must be between �C90 and 90 degrees.
FreqCenter = sysPara.FreqCenter;
Duration = sysPara.Duration;
SymbolRate = sysPara.SymbolRate;
NumElements = getNumElements(hArray);
LenWaveform = sysPara.LenWaveform;
TargetPower = sysPara.TargetPower;
StvIncludeElementResponse = sysPara.StvIncludeElementResponse;

%% Flags
GlobalDebugPlot = sysPara.GlobalDebugPlot;
FlagDebugPlot = true && GlobalDebugPlot;
figureStartNum = 3000;

%% Gen. signal
waveformSignal = zeros(LenWaveform, NumTarget);
switch lower(TargetSigType)
    case 'qpsk'
        BitPerSym = 2;
        numBit = round(Duration*SymbolRate*BitPerSym*NumTarget);
        txBits = randi([0, 1], numBit,1);
        % bits map to constellations
        symbols = SymbolMap(txBits, 'QPSK');
        waveformSignal = reshape(symbols, [],NumTarget);
    case '16qam'
        BitPerSym = 4;
        numBit = round(Duration*SymbolRate*BitPerSym*NumTarget);
        txBits = randi([0, 1], numBit,1);
        % bits map to constellations
        symbols = SymbolMap(txBits, '16QAM');
        waveformSignal = reshape(symbols, [],NumTarget);
    case '64qam'
        BitPerSym = 6;
        numBit = round(Duration*SymbolRate*BitPerSym*NumTarget);
        txBits = randi([0, 1], numBit,1);
        % bits map to constellations
        symbols = SymbolMap(txBits, '64QAM');
        waveformSignal = reshape(symbols, [],NumTarget);
    case 'custompilot'
		% The pilot waveform below is inherited from CSMA RS with oversampling of 2. Waveform begins at CP/2.
        pilotSignal = [0.597750197628676 + 0.899287820462048i,0.832619582099781 + 0.131116226113365i,0.791277450536945 - 0.870126619551477i,0.00511199813821906 - 0.812875746714423i,-0.798163847058874 - 0.597925131295389i,-0.832866975663762 - 0.838791622717269i,-0.586766442514103 - 0.799582096855205i,-0.833370426379568 + 0.0146346813542591i,-0.818914680331913 + 0.792434692124505i,0.0385749092847886 + 0.822980859313228i,0.732202685437865 + 0.657215980004006i,0.923622193220723 + 0.700993451335220i,0.806820371797992 + 0.714344198108465i,-0.109820602127619 + 0.699557220994909i,-0.886386230493411 + 0.678510982596137i,-0.134397997564108 + 0.795011669235930i,0.875863014400597 + 0.846858771129085i,0.806596527013989 - 0.0794641122889465i,0.632225031870510 - 0.973562879403500i,0.758091986539724 + 0.00242797049319710i,0.649466857913873 + 1.00972746024489i,0.780072996585994 - 0.0146729892893962i,0.886578954548940 - 0.941910343383084i,-0.122462658277827 - 0.110029687756464i,-0.949398457264446 + 0.855163324627926i,0.00846865711721725 + 0.813260313752596i,0.933265080733581 + 0.593814839863572i,0.127440458315457 + 0.844338769244911i,-0.868352809497298 + 0.809490755568833i,-0.810260021395785 - 0.0331278753277856i,-0.599168354605588 - 0.737707031737225i,-0.838247501269642 - 0.921166022311540i,-0.801456028123654 - 0.812228990335624i,0.0181892026778493 + 0.117982423842039i,0.790508039425551 + 0.899555635428278i,0.820821416287692 + 0.108559853196637i,0.666522921358200 - 0.820436640360084i,0.690938920087664 - 0.901465701765124i,0.722256991775696 - 0.800254604492219i,0.699560065102030 + 0.0765486180798176i,0.657002000301320 + 0.967092004484677i,0.827567025800378 + 0.0116597453063136i,0.806727490498474 - 0.968213386836347i,-0.0120666932797497 - 0.0953131836281251i,-0.759048227460663 + 0.854771564796316i,-0.909834246311703 + 0.800809053434673i,-0.808331502893841 + 0.660959449088361i,0.0996902644864311 + 0.720721359720704i,0.949635363363849 + 0.717178160636984i,0.0138969199672255 + 0.678862316188488i,-0.962342218189525 + 0.721276787761700i,-0.106235036280923 + 0.710363646654112i,0.863180354503709 + 0.645666366765890i,0.796416658153411 + 0.833104261708592i,0.654747571290877 + 0.798918407063083i,0.732687940429815 - 0.00477696231943516i,0.700630933252572 - 0.754427088881499i,0.690988451307054 - 0.925251582190004i,0.731021341740936 - 0.754276350143574i,0.685667367539991 - 0.00339781102125576i,0.702592609812637 + 0.802593096957289i,0.735115910923013 + 0.826265606137574i,0.641047239274157 + 0.653105781391609i,0.815528729836338 + 0.703449622244404i,0.865591648333791 + 0.705284991785995i,-0.128494484414280 + 0.711742797952292i,-0.890215774119824 + 0.665483591373724i,-0.110045614756338 + 0.801678300081658i,0.805970919406834 + 0.868023022098378i,0.926497016698030 - 0.116752916333887i,0.740007653878974 - 0.915572368888130i,0.0244712664854036 - 0.0834060447578302i,-0.811357446922529 + 0.796911805903784i,-0.831856464403881 + 0.913241486641951i,-0.634018921859194 + 0.811687234321449i,-0.727398098085583 - 0.106322678535725i,-0.707211644484950 - 0.897878821667900i,-0.685332331721207 - 0.121261351185662i,-0.734444181609135 + 0.815593972765416i,-0.685034356805976 + 0.919423437878867i,-0.714746786872397 + 0.741071921347597i,-0.716658180777503 + 0.0300397438164480i,-0.644199417713915 - 0.813967869348111i,-0.826296847560404 - 0.833470538950206i,-0.795389845875613 - 0.633404271660588i,-0.00542826285000829 - 0.728101773942665i,0.794219764268299 - 0.710151854309453i,0.835957951282220 - 0.680207863267152i,0.605165417325606 - 0.736145190298302i,0.803830676594888 - 0.687490527715160i,0.863713694890480 - 0.699876373248363i,-0.112929867542636 - 0.737252973013286i,-0.938129932169607 - 0.640646661597657i,-0.0170473374245001 - 0.812365842063228i,0.997312615314229 - 0.862319640022937i,0.0214115322897759 + 0.117854110855414i,-1.01838398498400 + 0.898872298858942i,0.00535939170220030 + 0.105093171027573i,1.00740022986943 - 0.850201569717520i,-0.0188745887383731 - 0.817361800630935i,-0.989187017656964 - 0.652336277460795i,0.00278129610853988 - 0.713823262310870i,0.955776450883752 - 0.714746786872397i,0.100100056566987 - 0.688936187364462i,-0.876883099825346 - 0.673513461269261i,-0.773324542966187 - 0.811107937239366i,-0.668316811346884 - 0.794445408278086i,-0.733001842344920 - 0.0234013133867066i,-0.631377590566783 + 0.820748451731350i,-0.831173922450478 + 0.815221894433541i,-0.803154932905969 + 0.598951528440691i,0.0131366463784466 + 0.832024879300903i,0.735906180292048 + 0.796631058098380i,0.943775820686637 - 0.00357565522726951i,0.749294515298662 - 0.788056585726458i,-0.00499311446058607 - 0.838639134820122i,-0.737779833102237 - 0.607351067145900i,-0.951975950336194 - 0.797795809451591i,-0.743903130233326 - 0.866499050982776i,0.00808409007904414 + 0.111096796748040i,0.751356220253577 + 0.942759888593662i,0.926597129268668 + 0.0107652736169457i,0.786153694798999 - 0.993956883886621i,-0.0800989169982213 - 0.0199940730564594i,-0.956933599651893 + 1.00757516353614i,-0.0228571919390786 + 0.00623148245630531i,1.02350984462880 - 1.01437950769088i,-0.0138220324389705 + 0.0146135474505797i,-0.948995868500514 + 1.00749311116895i,-0.0990301034682904 - 0.0265488867368607i,0.843763707572375 - 0.950566868122202i,0.820284361352370 - 0.0842004038765598i,0.598789527613151 + 0.809326650834442i,0.831609070839900 + 0.895787201244015i,0.852940639859090 + 0.798692763053295i,-0.122003334977882 - 0.0714394640487189i,-0.880625733534922 - 0.956563930842221i,-0.133212004894899 - 0.0305909317763828i,0.864244621972332 + 1.02548949721652i,0.821888525279268 - 0.00893504692946981i,0.582300157667146 - 1.01044414992577i,0.853896916288968 + 0.0251626689263745i,0.794635285871404 + 0.940348501944160i,-0.0211046968869782 + 0.0989706616294739i,-0.736784685161636 - 0.855028550830224i,-0.934421552367619 - 0.801324974466315i,-0.752787310069662 - 0.643989460186091i,0.00366633848891637 - 0.743375482411386i,0.795918669050615 - 0.664397232883164i,0.824842327423534 - 0.771463074855881i,0.649373976614355 - 0.882904264654734i,0.711742797952292 + 0.108393232274876i,0.673491370247324 + 0.971918985597381i,0.788213684396734 - 0.0300991856552645i,0.818160120327704 - 0.935386747033754i,0.00764894168962190 - 0.103072148507813i,-0.823391794111192 + 0.796507113233001i,-0.795731272092887 + 0.931840481400356i,-0.656154558997593 + 0.738733428882527i,-0.730883070051205 + 0.0213114197191376i,-0.651734560101362 - 0.751336140319071i,-0.801034066063392 - 0.957087948474413i,-0.864162569605137 - 0.723460426494562i,0.110530294365149 - 0.0179730505366983i,0.904413680106844 + 0.750933551555139i,0.104198699338206 + 0.951540801946772i,-0.853402447412920 + 0.718064647976684i,-0.811821720615600 + 0.0327433082896124i,-0.657193888982068 - 0.805970919406834i,-0.713704378633237 - 0.849194710231305i,-0.703004449578752 - 0.570112967833708i,-0.704785258703641 - 0.845656115907589i,-0.674249952426396 - 0.807269339332069i,-0.794336193794834 + 0.0340817888559700i,-0.847363492194718 + 0.724630508101876i,0.0795024202240836 + 0.940535201278152i,0.967301962012500 + 0.758846345222371i,0.00532108376706310 - 0.0170191370085140i,-1.01942331496848 - 0.746741207756127i,0.0225380831201690 - 0.924307579281247i,0.956130340392041 - 0.787273066063239i,0.0773742186213774 + 0.0808409007904413i,-0.799274400478222 + 0.953612892085396i,-0.902085192051443 + 0.0254817777452841i,-0.800513601613559 - 1.03150469066323i,0.0791267136734779 + 0.0241432971789265i,0.944131017064489 + 0.952858332081187i,0.0396573326993212 + 0.0832464903483755i,-1.02348490714465 - 0.791737247003344i,-0.00282244815079745 - 0.918879316431239i,1.03161050480192 - 0.745619825404457i,-0.0457415341622837 - 0.0253628940676512i,-0.945593851122181 + 0.796688172981428i,-0.0751535397817638 + 0.852401725420276i,0.777823275621812 + 0.582879784004642i,0.931155095339833 + 0.822564000720365i,0.762426049910208 + 0.869677744836819i,-0.0140311180678146 - 0.138768011910108i,-0.738483589943952 - 0.877754643238441i,-0.939474108667022 - 0.120626546476387i,-0.807389169203165 + 0.841802031012310i,0.126620742887862 + 0.843707005542480i,0.878690262991077 + 0.594042494960791i,0.128910292875284 + 0.815281336272357i,-0.806149968067829 + 0.868790514941760i,-0.943516153706544 - 0.131941826654925i,-0.727723467751735 - 0.940386372267482i,-0.0271083226074448 + 0.00489300188994777i,0.755727519894165 + 0.937340348304288i,0.952375831797323 + 0.126582434952725i,0.720213262848436 - 0.859273616059743i,0.0288696781471126 - 0.823881347383043i,-0.789753479421342 - 0.594299480994699i,-0.868947406104230 - 0.831965437462087i,-0.576303094947128 - 0.862213825884245i,-0.815556930252325 + 0.140154229720594i,-0.881001806884568 + 0.883460129220734i,0.152718554235426 + 0.109579224944085i,0.887450497962035 - 0.795790423552113i,0.0899949439681823 - 0.942330161037335i,-0.790156068185274 - 0.741684467639352i,-0.931214537178649 - 0.00652945737153563i,-0.790969846979382 + 0.751511073985784i,0.0941866327977319 + 0.940991680470977i,0.894985640349482 + 0.785209257201472i,0.137488973182566 - 0.0927762400767222i,-0.870007532235740 - 0.896996356503062i,-0.820818572180571 - 0.135793075862162i,-0.602876057273472 + 0.882893435722411i,-0.822254802520882 + 0.797667496464966i,-0.848712529643608 + 0.648759326415749i,0.109519783105269 + 0.740168467222415i,0.951666159451935 + 0.647117536516480i,-0.00177362895577977 + 0.798278126263717i,-0.965105483259884 + 0.820805566614397i,-0.0879144796096048 - 0.00786793793789321i,0.813965858260680 - 0.811733520272174i,0.891229235172851 - 0.795872536705783i,0.818253001627222 - 0.665921203998767i,-0.0937867513366027 - 0.716619872842366i,-0.923498095394534 - 0.656400282941886i,-0.0963742762392546 - 0.811239291232835i,0.820036062683584 - 0.818432050288217i,0.888254299124905 + 0.0156423485070192i,0.813695939387598 + 0.766691195074232i,-0.0845578206306066 + 0.896397831042766i,-0.969569664199989 + 0.813563176677329i,0.00270356447316448 - 0.0940341449005840i,0.956815780868228 - 0.964870588247913i,0.0990895453071070 + 0.00546234837995900i,-0.815219910503201 + 0.965530163045753i,-0.900439876082288 + 0.0838158368383867i,-0.750778697822933 - 0.800703479206876i,-0.0333468715760570 - 0.905057283992268i,0.824146354115401 - 0.808911129231337i,0.820362092987746 + 0.0940935867394005i,0.597750197628676 + 0.899287820462048i,0.832619582099781 + 0.131116226113365i,0.791277450536945 - 0.870126619551477i,0.00511199813821906 - 0.812875746714423i,-0.798163847058874 - 0.597925131295389i,-0.832866975663762 - 0.838791622717269i,-0.586766442514103 - 0.799582096855205i,-0.833370426379568 + 0.0146346813542591i,-0.818914680331913 + 0.792434692124505i,0.0385749092847886 + 0.822980859313228i,0.732202685437865 + 0.657215980004006i,0.923622193220723 + 0.700993451335220i,0.806820371797992 + 0.714344198108465i,-0.109820602127619 + 0.699557220994909i,-0.886386230493411 + 0.678510982596137i,-0.134397997564108 + 0.795011669235930i,0.875863014400597 + 0.846858771129085i,0.806596527013989 - 0.0794641122889465i,0.632225031870510 - 0.973562879403500i,0.758091986539724 + 0.00242797049319710i,0.649466857913873 + 1.00972746024489i,0.780072996585994 - 0.0146729892893962i,0.886578954548940 - 0.941910343383084i,-0.122462658277827 - 0.110029687756464i,-0.949398457264446 + 0.855163324627926i,0.00846865711721725 + 0.813260313752596i,0.933265080733581 + 0.593814839863572i,0.127440458315457 + 0.844338769244911i,-0.868352809497298 + 0.809490755568833i,-0.810260021395785 - 0.0331278753277856i,-0.599168354605588 - 0.737707031737225i,-0.838247501269642 - 0.921166022311540i,-0.801456028123654 - 0.812228990335624i,0.0181892026778493 + 0.117982423842039i,0.790508039425551 + 0.899555635428278i,0.820821416287692 + 0.108559853196637i,0.666522921358200 - 0.820436640360084i,0.690938920087664 - 0.901465701765124i,0.722256991775696 - 0.800254604492219i,0.699560065102030 + 0.0765486180798176i,0.657002000301320 + 0.967092004484677i,0.827567025800378 + 0.0116597453063136i,0.806727490498474 - 0.968213386836347i,-0.0120666932797497 - 0.0953131836281251i,-0.759048227460663 + 0.854771564796316i,-0.909834246311703 + 0.800809053434673i,-0.808331502893841 + 0.660959449088361i,0.0996902644864311 + 0.720721359720704i,0.949635363363849 + 0.717178160636984i,0.0138969199672255 + 0.678862316188488i,-0.962342218189525 + 0.721276787761700i,-0.106235036280923 + 0.710363646654112i,0.863180354503709 + 0.645666366765890i,0.796416658153411 + 0.833104261708592i,0.654747571290877 + 0.798918407063083i,0.732687940429815 - 0.00477696231943516i,0.700630933252572 - 0.754427088881499i,0.690988451307054 - 0.925251582190004i,0.731021341740936 - 0.754276350143574i,0.685667367539991 - 0.00339781102125576i,0.702592609812637 + 0.802593096957289i,0.735115910923013 + 0.826265606137574i,0.641047239274157 + 0.653105781391609i,0.815528729836338 + 0.703449622244404i,0.865591648333791 + 0.705284991785995i,-0.128494484414280 + 0.711742797952292i,-0.890215774119824 + 0.665483591373724i,-0.110045614756338 + 0.801678300081658i,0.805970919406834 + 0.868023022098378i,0.926497016698030 - 0.116752916333887i,0.740007653878974 - 0.915572368888130i,0.0244712664854036 - 0.0834060447578302i,-0.811357446922529 + 0.796911805903784i,-0.831856464403881 + 0.913241486641951i,-0.634018921859194 + 0.811687234321449i,-0.727398098085583 - 0.106322678535725i,-0.707211644484950 - 0.897878821667900i,-0.685332331721207 - 0.121261351185662i,-0.734444181609135 + 0.815593972765416i,-0.685034356805976 + 0.919423437878867i,-0.714746786872397 + 0.741071921347597i,-0.716658180777503 + 0.0300397438164480i,-0.644199417713915 - 0.813967869348111i,-0.826296847560404 - 0.833470538950206i,-0.795389845875613 - 0.633404271660588i,-0.00542826285000829 - 0.728101773942665i,0.794219764268299 - 0.710151854309453i,0.835957951282220 - 0.680207863267152i,0.605165417325606 - 0.736145190298302i,0.803830676594888 - 0.687490527715160i,0.863713694890480 - 0.699876373248363i,-0.112929867542636 - 0.737252973013286i,-0.938129932169607 - 0.640646661597657i,-0.0170473374245001 - 0.812365842063228i,0.997312615314229 - 0.862319640022937i,0.0214115322897759 + 0.117854110855414i,-1.01838398498400 + 0.898872298858942i,0.00535939170220030 + 0.105093171027573i,1.00740022986943 - 0.850201569717520i,-0.0188745887383731 - 0.817361800630935i,-0.989187017656964 - 0.652336277460795i,0.00278129610853988 - 0.713823262310870i,0.955776450883752 - 0.714746786872397i,0.100100056566987 - 0.688936187364462i,-0.876883099825346 - 0.673513461269261i,-0.773324542966187 - 0.811107937239366i,-0.668316811346884 - 0.794445408278086i,-0.733001842344920 - 0.0234013133867066i,-0.631377590566783 + 0.820748451731350i,-0.831173922450478 + 0.815221894433541i,-0.803154932905969 + 0.598951528440691i,0.0131366463784466 + 0.832024879300903i,0.735906180292048 + 0.796631058098380i,0.943775820686637 - 0.00357565522726951i,0.749294515298662 - 0.788056585726458i,-0.00499311446058607 - 0.838639134820122i,-0.737779833102237 - 0.607351067145900i,-0.951975950336194 - 0.797795809451591i,-0.743903130233326 - 0.866499050982776i,0.00808409007904414 + 0.111096796748040i,0.751356220253577 + 0.942759888593662i,0.926597129268668 + 0.0107652736169457i,0.786153694798999 - 0.993956883886621i,-0.0800989169982213 - 0.0199940730564594i,-0.956933599651893 + 1.00757516353614i,-0.0228571919390786 + 0.00623148245630531i,1.02350984462880 - 1.01437950769088i,-0.0138220324389705 + 0.0146135474505797i,-0.948995868500514 + 1.00749311116895i,-0.0990301034682904 - 0.0265488867368607i,0.843763707572375 - 0.950566868122202i,0.820284361352370 - 0.0842004038765598i,0.598789527613151 + 0.809326650834442i,0.831609070839900 + 0.895787201244015i,0.852940639859090 + 0.798692763053295i,-0.122003334977882 - 0.0714394640487189i,-0.880625733534922 - 0.956563930842221i,-0.133212004894899 - 0.0305909317763828i,0.864244621972332 + 1.02548949721652i,0.821888525279268 - 0.00893504692946981i,0.582300157667146 - 1.01044414992577i,0.853896916288968 + 0.0251626689263745i,0.794635285871404 + 0.940348501944160i,-0.0211046968869782 + 0.0989706616294739i,-0.736784685161636 - 0.855028550830224i,-0.934421552367619 - 0.801324974466315i,-0.752787310069662 - 0.643989460186091i,0.00366633848891637 - 0.743375482411386i,0.795918669050615 - 0.664397232883164i,0.824842327423534 - 0.771463074855881i,0.649373976614355 - 0.882904264654734i,0.711742797952292 + 0.108393232274876i,0.673491370247324 + 0.971918985597381i,0.788213684396734 - 0.0300991856552645i,0.818160120327704 - 0.935386747033754i,0.00764894168962190 - 0.103072148507813i,-0.823391794111192 + 0.796507113233001i,-0.795731272092887 + 0.931840481400356i,-0.656154558997593 + 0.738733428882527i,-0.730883070051205 + 0.0213114197191376i,-0.651734560101362 - 0.751336140319071i,-0.801034066063392 - 0.957087948474413i,-0.864162569605137 - 0.723460426494562i,0.110530294365149 - 0.0179730505366983i,0.904413680106844 + 0.750933551555139i,0.104198699338206 + 0.951540801946772i,-0.853402447412920 + 0.718064647976684i,-0.811821720615600 + 0.0327433082896124i,-0.657193888982068 - 0.805970919406834i,-0.713704378633237 - 0.849194710231305i,-0.703004449578752 - 0.570112967833708i,-0.704785258703641 - 0.845656115907589i,-0.674249952426396 - 0.807269339332069i,-0.794336193794834 + 0.0340817888559700i,-0.847363492194718 + 0.724630508101876i,0.0795024202240836 + 0.940535201278152i,0.967301962012500 + 0.758846345222371i,0.00532108376706310 - 0.0170191370085140i,-1.01942331496848 - 0.746741207756127i,0.0225380831201690 - 0.924307579281247i,0.956130340392041 - 0.787273066063239i,0.0773742186213774 + 0.0808409007904413i,-0.799274400478222 + 0.953612892085396i,-0.902085192051443 + 0.0254817777452841i,-0.800513601613559 - 1.03150469066323i,0.0791267136734779 + 0.0241432971789265i,0.944131017064489 + 0.952858332081187i,0.0396573326993212 + 0.0832464903483755i,-1.02348490714465 - 0.791737247003344i,-0.00282244815079745 - 0.918879316431239i,1.03161050480192 - 0.745619825404457i,-0.0457415341622837 - 0.0253628940676512i,-0.945593851122181 + 0.796688172981428i,-0.0751535397817638 + 0.852401725420276i,0.777823275621812 + 0.582879784004642i,0.931155095339833 + 0.822564000720365i,0.762426049910208 + 0.869677744836819i,-0.0140311180678146 - 0.138768011910108i,-0.738483589943952 - 0.877754643238441i,-0.939474108667022 - 0.120626546476387i,-0.807389169203165 + 0.841802031012310i,0.126620742887862 + 0.843707005542480i,0.878690262991077 + 0.594042494960791i,0.128910292875284 + 0.815281336272357i,-0.806149968067829 + 0.868790514941760i,-0.943516153706544 - 0.131941826654925i,-0.727723467751735 - 0.940386372267482i,-0.0271083226074448 + 0.00489300188994777i,0.755727519894165 + 0.937340348304288i,0.952375831797323 + 0.126582434952725i,0.720213262848436 - 0.859273616059743i,0.0288696781471126 - 0.823881347383043i,-0.789753479421342 - 0.594299480994699i,-0.868947406104230 - 0.831965437462087i,-0.576303094947128 - 0.862213825884245i,-0.815556930252325 + 0.140154229720594i,-0.881001806884568 + 0.883460129220734i,0.152718554235426 + 0.109579224944085i,0.887450497962035 - 0.795790423552113i,0.0899949439681823 - 0.942330161037335i,-0.790156068185274 - 0.741684467639352i,-0.931214537178649 - 0.00652945737153563i,-0.790969846979382 + 0.751511073985784i,0.0941866327977319 + 0.940991680470977i,0.894985640349482 + 0.785209257201472i,0.137488973182566 - 0.0927762400767222i,-0.870007532235740 - 0.896996356503062i,-0.820818572180571 - 0.135793075862162i,-0.602876057273472 + 0.882893435722411i,-0.822254802520882 + 0.797667496464966i,-0.848712529643608 + 0.648759326415749i,0.109519783105269 + 0.740168467222415i,0.951666159451935 + 0.647117536516480i,-0.00177362895577977 + 0.798278126263717i,-0.965105483259884 + 0.820805566614397i,-0.0879144796096048 - 0.00786793793789321i,0.813965858260680 - 0.811733520272174i,0.891229235172851 - 0.795872536705783i,0.818253001627222 - 0.665921203998767i,-0.0937867513366027 - 0.716619872842366i,-0.923498095394534 - 0.656400282941886i,-0.0963742762392546 - 0.811239291232835i,0.820036062683584 - 0.818432050288217i,0.888254299124905 + 0.0156423485070192i,0.813695939387598 + 0.766691195074232i,-0.0845578206306066 + 0.896397831042766i,-0.969569664199989 + 0.813563176677329i,0.00270356447316448 - 0.0940341449005840i,0.956815780868228 - 0.964870588247913i,0.0990895453071070 + 0.00546234837995900i,-0.815219910503201 + 0.965530163045753i,-0.900439876082288 + 0.0838158368383867i,-0.750778697822933 - 0.800703479206876i,-0.0333468715760570 - 0.905057283992268i,0.824146354115401 - 0.808911129231337i,0.820362092987746 + 0.0940935867394005i].';
        lenPilot = length(pilotSignal);	% for mulitple-target case, cyclic shift the RS.
        lenPilotCircShift = lenPilot/8;
        waveformSignal = zeros(lenPilot, NumTarget);
        for idx = 1:NumTarget
            waveformSignal(:,idx) = circshift(pilotSignal, lenPilotCircShift*(idx-1));
        end
    otherwise
        error('Unsupported signal type.')
end

amp = db2mag(TargetPower);
waveformSignal = waveformSignal*diag(amp);

if FlagDebugPlot
    figure(figureStartNum+0);clf;
    plot(waveformSignal,'o-');axis equal;
    title('waveformTx');
    fprintf('waveformTx RMS = %2.2f\n', rms(waveformSignal));
end

% waveformArray = collectPlaneWave( hArray, waveformSignal,  TargetAngle, FreqCenter);      % collectPlaneWave donot count for element response. use SteeringVector in future.    
hSteeringVector = phased.SteeringVector('SensorArray', hArray,...
    'PropagationSpeed', physconst('LightSpeed'),...
    'IncludeElementResponse', StvIncludeElementResponse,...
    'NumPhaseShifterBits', 0 ...    'EnablePolarization', false ...
    );
steeringVector = step(hSteeringVector, FreqCenter, TargetAngle);
steeringVector = steeringVector*diag(rms(steeringVector).^-1); % in case of IncludeElementResponse=true. Normalize to 1, but keep element response
waveformArray = waveformSignal*steeringVector.';

if FlagDebugPlot
    figure(figureStartNum+100);clf;
    plot(waveformArray(:,1),'o-');axis equal;
    title('waveformSig on the first sensor');
    fprintf('Signal waveform RMS on each anntenna:\n')
    for idxAntenna = 1:NumElements
        fprintf('\tChannel %d = %2.2f = %2.2fdB\n', idxAntenna, rms(waveformArray(:,idxAntenna)), mag2db(rms(waveformArray(:,idxAntenna))) );
    end
end
    
    
    
    
    
    
    
