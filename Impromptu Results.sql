select excp_id,max(bus_proc_DT) as 'bus_proc_DT'
INTO #BASE
FROM Reverse_DW.DBO.HUD_ASGN_EXCP_EDW 
WHERE B.EXCP_ID IN ('529042',
'529040',
'529039',
'529038',
'529036',
'529034',
'529033',
'529032',
'529031',
'529027',
'529026',
'529025',
'529460',
'529024',
'529022',
'529021',
'529020',
'529018',
'529016',
'529014',
'529013',
'529012',
'529011',
'529010',
'529009',
'529008',
'528892',
'529007',
'528653',
'529005',
'529003',
'529000',
'528998',
'489463',
'528997',
'528996',
'528995',
'528994',
'528993',
'529122',
'528990',
'528989',
'528988',
'528987',
'489550',
'528986',
'528985',
'528970',
'528984',
'528982',
'528981',
'528980',
'528979',
'528978',
'528977',
'528975',
'489385',
'489082',
'529377',
'528972',
'528971',
'520902',
'528432',
'528431',
'528429',
'528335',
'520892',
'529121',
'528591',
'529118',
'529117',
'529115',
'529113',
'529112',
'529111',
'529110',
'529109',
'529108',
'528466',
'528465',
'528463',
'528462',
'528459',
'528448',
'528447',
'528446',
'528445',
'528444',
'528443',
'528442',
'528441',
'520921',
'528433',
'528439',
'528437',
'528436',
'528435',
'528434',
'529106',
'529105',
'529103',
'529102',
'529101',
'529099',
'529097',
'529096',
'529095',
'529093',
'529092',
'529091',
'529090',
'529089',
'529088',
'520842',
'528507',
'528506',
'529087',
'529086',
'529085',
'529083',
'528513',
'528512',
'529076',
'529075',
'528593',
'529074',
'528612',
'528617',
'529073',
'529072',
'528487',
'528476',
'529070',
'528967',
'529069',
'528943',
'528945',
'529067',
'529065',
'529064',
'529063',
'528960',
'528962',
'529062',
'528964',
'529061',
'529060',
'529059',
'529057',
'529056',
'525611',
'529053',
'529048',
'529044',
'528818',
'528817',
'528816',
'528815',
'528814',
'528813',
'528811',
'528809',
'528808',
'528807',
'528806',
'528805',
'528804',
'528803',
'528725',
'528801',
'528798',
'528797',
'528795',
'528794',
'528793',
'528792',
'528791',
'528789',
'528788',
'528787',
'528786',
'528917',
'528785',
'528783',
'528782',
'528781',
'528927',
'529280',
'528779',
'528776',
'528774',
'520627',
'528772',
'528771',
'528386',
'528770',
'528769',
'528768',
'528767',
'528766',
'528765',
'528764',
'528387',
'528763',
'528762',
'529167',
'528760',
'528759',
'528758',
'529165',
'489179',
'488836',
'528394',
'528891',
'520718',
'520717',
'528396',
'520711',
'528888',
'528887',
'528886',
'528885',
'488829',
'528884',
'489015',
'528882',
'528881',
'528880',
'528879',
'528878',
'528877',
'525731',
'528398',
'528875',
'528874',
'528873',
'528872',
'528871',
'528870',
'528869',
'528868',
'528400',
'528867',
'528866',
'528865',
'528864',
'529123',
'528863',
'528862',
'528861',
'528860',
'528859',
'528857',
'528856',
'520684',
'488904',
'528854',
'528853',
'528852',
'528851',
'528850',
'488985',
'528848',
'488742',
'489154',
'528847',
'528842',
'528837',
'528836',
'528834',
'528833',
'528832',
'488905',
'528831',
'528830',
'528388',
'528828',
'528825',
'528824',
'528823',
'528822',
'528390',
'528820',
'528819',
'528956',
'528955',
'529219',
'528944',
'489495',
'528391',
'528952',
'528951',
'528402',
'488844',
'529326',
'488749',
'488779',
'528957',
'528421',
'489080',
'528961',
'528963',
'528403',
'489207',
'528419',
'528420',
'489475',
'489162',
'488769',
'529430',
'529451',
'489403',
'488966',
'488646',
'528968',
'488941',
'528422',
'488778',
'529135',
'528966',
'488902',
'489022',
'489571',
'528404',
'489497',
'528949',
'528947',
'489523',
'528406',
'528939',
'529394',
'529337',
'528410',
'528942',
'528411',
'528941',
'528412',
'528935',
'528934',
'528937',
'528936',
'528933',
'528413',
'528932',
'528931',
'528924',
'528923',
'528930',
'528929',
'528414',
'528928',
'528926',
'528415',
'528914',
'528913',
'528916',
'529355',
'528919',
'528920',
'528921',
'528922',
'488910',
'528907',
'528906',
'528905',
'528903',
'528901',
'528900',
'528899',
'528898',
'528897',
'528896',
'528895',
'528416',
'528894',
'528893',
'529150',
'528417',
'528418',
'528755',
'489515',
'528909',
'528911',
'528910',
'528482',
'528481',
'529251',
'488714',
'528427',
'528480',
'489012',
'528479',
'528478',
'489118',
'488713',
'529466',
'489513',
'489555',
'489263',
'489481',
'528486',
'529283',
'528485',
'528484',
'488953',
'528488',
'528495',
'528494',
'528490',
'489507',
'529320',
'489023',
'489163',
'489057',
'489048',
'488845',
'489427',
'489056',
'489070',
'489559',
'528469',
'528468',
'528467',
'529543',
'489447',
'528475',
'528474',
'489480',
'529240',
'528472',
'528471',
'528470',
'489059',
'489058',
'489339',
'529081',
'529080',
'488983',
'529079',
'489563',
'529077',
'529228',
'528590',
'528428',
'528514',
'528423',
'528424',
'528510',
'489531',
'528425',
'528508',
'528504',
'489514',
'528505',
'528501',
'528502',
'528499',
'528498',
'533501',
'528607',
'528426',
'528605',
'528604',
'528603',
'528602',
'528601',
'528600',
'528599',
'528610',
'528609',
'528608',
'528615',
'529380',
'528614',
'528613',
'528628',
'520969',
'528627',
'528626',
'528624',
'528623',
'528620',
'528619',
'528618',
'528652',
'528650',
'528649',
'528648',
'528647',
'528645',
'528644',
'528643',
'528640',
'528639',
'528638',
'528637',
'528636',
'528633',
'528380',
'528631',
'528692',
'528691',
'528690',
'528689',
'528688',
'528687',
'528686',
'528685',
'528681',
'528680',
'528678',
'528677',
'528381',
'528382',
'528676',
'528383',
'528675',
'528674',
'528673',
'528672',
'528384',
'528671',
'521014',
'528668',
'528667',
'528385',
'528666',
'528664',
'528663',
'528661',
'528660',
'528658',
'528657',
'528656',
'528655',
'528700',
'528699',
'528698',
'528697',
'528696',
'528695',
'528693',
'528654',
'528708',
'528742',
'528706',
'489533',
'489532',
'528704',
'489579',
'488711',
'488777',
'489228',
'489229',
'488756',
'528720',
'528719',
'528718',
'528723',
'528722',
'528721',
'528709',
'528717',
'528716',
'528715',
'528714',
'528713',
'528339',
'528712',
'528711',
'528703',
'528702',
'528735',
'528733',
'489581',
'528731',
'529252',
'489535',
'528622',
'528724',
'528340',
'528341',
'528342',
'528749',
'528748',
'529273',
'528343',
'528747',
'528746',
'489011',
'489041',
'528744',
'528743',
'488923',
'489394',
'528754',
'528753',
'528344',
'528751',
'528750',
'489580',
'528346',
'528727',
'489486',
'489095',
'528347',
'488879',
'528739',
'528348',
'528349',
'489009',
'528737',
'528350',
'528378',
'528377',
'528376',
'528375',
'529130',
'528374',
'528373',
'528372',
'528371',
'528370',
'528369',
'528367',
'528353',
'528365',
'528364',
'528363',
'528362',
'528361',
'528360',
'528359',
'528357',
'528354',
'528356',
'528355',
'529029',
'529023',
'529004',
'529001',
'528999',
'529247',
'529107',
'529100',
'529094',
'528401',
'528606',
'528497',
'529058',
'529055',
'528799',
'528701',
'528777',
'529433',
'528889',
'528845',
'528835',
'528826',
'528965',
'528969',
'529364',
'529274',
'526698',
'529124',
'489556',
'529216',
'528509',
'489578',
'488807',
'529382',
'528625',
'528662',
'528659',
'529242',
'529266',
'529160',
'529276',
'528358',
'529041',
'529435',
'529457',
'529037',
'529465',
'529750',
'529579',
'529035',
'529028',
'529608',
'529376',
'529019',
'529402',
'529017',
'529503',
'529015',
'529328',
'529493',
'529450',
'529473',
'529540',
'529006',
'529306',
'529350',
'529403',
'529546',
'529425',
'529327',
'529374',
'529378',
'528992',
'529275',
'529292',
'529277',
'529311',
'529288',
'528976',
'529317',
'528974',
'529454',
'529244',
'529300',
'529367',
'529299',
'529307',
'529220',
'529448',
'529497',
'529353',
'529439',
'529475',
'529342',
'529225',
'528430',
'529730',
'529120',
'529119',
'529554',
'529811',
'529804',
'529116',
'529114',
'529464',
'529343',
'529269',
'529365',
'528461',
'529616',
'528440',
'528438',
'529555',
'529104',
'529587',
'529541',
'529653',
'529542',
'529578',
'529098',
'529636',
'529600',
'529389',
'528621',
'529391',
'528503',
'529222',
'529372',
'529084',
'529082',
'529484',
'529230',
'528496',
'529071',
'529068',
'528940',
'528938',
'529617',
'529066',
'529458',
'529142',
'529303',
'529357',
'529358',
'529267',
'528511',
'529581',
'529047',
'529531',
'529505',
'528812',
'532721',
'528810',
'529533',
'529509',
'529545',
'529256',
'529536',
'528802',
'528800',
'528796',
'528790',
'489458',
'489371',
'528925',
'529564',
'529472',
'528784',
'528780',
'529271',
'528775',
'529249',
'528773',
'529270',
'529529',
'529386',
'529562',
'529346',
'529302',
'529379',
'489540',
'529388',
'489510',
'529356',
'529305',
'529560',
'529334',
'529218',
'528757',
'529383',
'489347',
'528393',
'529429',
'489267',
'529396',
'529662',
'489421',
'489400',
'528395',
'528890',
'459901',
'528397',
'529434',
'528883',
'529226',
'528876',
'528399',
'529406',
'528855',
'529713',
'529370',
'528849',
'489419',
'528846',
'528844',
'528840',
'529714',
'529640',
'529308',
'529527',
'489450',
'529449',
'529371',
'528829',
'528389',
'528821',
'529535',
'529392',
'529290',
'529498',
'489160',
'489186',
'529238',
'529511',
'529453',
'528953',
'528392',
'489353',
'489456',
'529508',
'529399',
'529387',
'489352',
'529262',
'529375',
'529437',
'529395',
'529481',
'489161',
'489272',
'489206',
'529363',
'528959',
'529324',
'489457',
'529157',
'529344',
'529254',
'489426',
'529338',
'489585',
'529397',
'489549',
'529366',
'529163',
'489524',
'529329',
'529369',
'529393',
'529489',
'529431',
'529436',
'529341',
'528409',
'529405',
'529621',
'529683',
'529738',
'528915',
'528918',
'529428',
'529758',
'489381',
'528908',
'529258',
'528904',
'529432',
'529771',
'489346',
'529501',
'489451',
'528756',
'529236',
'529459',
'529474',
'488715',
'489375',
'529469',
'529361',
'529440',
'529245',
'529438',
'529463',
'529287',
'529272',
'529330',
'529447',
'489341',
'529442',
'529390',
'529468',
'529291',
'529478',
'529488',
'529500',
'528483',
'529553',
'529360',
'529268',
'528492',
'529352',
'528491',
'529407',
'528489',
'489448',
'529381',
'529261',
'489298',
'529211',
'529286',
'489498',
'529427',
'529253',
'489428',
'529340',
'529212',
'489460',
'489132',
'529241',
'529339',
'529293',
'529471',
'528473',
'489340',
'529462',
'529147',
'489374',
'529685',
'520839',
'529257',
'529502',
'529444',
'529250',
'529470',
'529404',
'529319',
'529259',
'529229',
'529332',
'529243',
'529296',
'529335',
'529234',
'529331',
'528500',
'529323',
'529499',
'529400',
'529401',
'529336',
'529321',
'529515',
'529210',
'528611',
'529384',
'529279',
'528616',
'529315',
'529373',
'529787',
'528629',
'529362',
'529385',
'529443',
'528651',
'528646',
'528642',
'528635',
'528684',
'528682',
'528670',
'529138',
'529398',
'529875',
'529162',
'528694',
'529333',
'529482',
'529304',
'529492',
'528707',
'529551',
'529573',
'529235',
'529310',
'529351',
'529264',
'529255',
'529408',
'529227',
'529313',
'529550',
'529298',
'529295',
'529446',
'529441',
'529461',
'529260',
'529301',
'529359',
'528736',
'528734',
'528732',
'529294',
'529284',
'529491',
'529285',
'529549',
'529314',
'529510',
'529248',
'529297',
'529584',
'529322',
'529345',
'528745',
'529237',
'529278',
'489488',
'529141',
'529149',
'529445',
'489473',
'489511',
'528338',
'528337',
'529504',
'529289',
'529567',
'528752',
'529518',
'529565',
'528345',
'529224',
'528729',
'529476',
'528728',
'529632',
'528726',
'528730',
'528740',
'529452',
'528741',
'489557',
'529590',
'529368',
'529223',
'529239',
'528738',
'529534',
'529623',
'489260',
'529354',
'529347',
'529548',
'529348',
'529233',
'529325',
'529231',
'529349',
'529312',
'529490',
'529517',
'529779',
'528368',
'528366',
'529467',
'521102',
'529745',
'529601',
'529603')

and cast(bus_proc_DT as datE) = cast('4/1/2020' as date)



SELECT A.loan_nbr,mca_percent,excp_id,doc_desc,excp_sts_desc,b.bus_proc_dt FROM Reverse_DW.DBO.HUD_ASGN_EXCP_EDW B
LEFT JOIN (SELECT Loan_Nbr, mca_percent FROM  REVERSE_dw.[dbo].[RM_CHAMPION_MASTER_TBL_VW]('2020-04-01',20200401)) A
ON A.LOAN_NBR = B.Loan_nbr
WHERE B.EXCP_ID IN ('529042',
'529040',
'529039',
'529038',
'529036',
'529034',
'529033',
'529032',
'529031',
'529027',
'529026',
'529025',
'529460',
'529024',
'529022',
'529021',
'529020',
'529018',
'529016',
'529014',
'529013',
'529012',
'529011',
'529010',
'529009',
'529008',
'528892',
'529007',
'528653',
'529005',
'529003',
'529000',
'528998',
'489463',
'528997',
'528996',
'528995',
'528994',
'528993',
'529122',
'528990',
'528989',
'528988',
'528987',
'489550',
'528986',
'528985',
'528970',
'528984',
'528982',
'528981',
'528980',
'528979',
'528978',
'528977',
'528975',
'489385',
'489082',
'529377',
'528972',
'528971',
'520902',
'528432',
'528431',
'528429',
'528335',
'520892',
'529121',
'528591',
'529118',
'529117',
'529115',
'529113',
'529112',
'529111',
'529110',
'529109',
'529108',
'528466',
'528465',
'528463',
'528462',
'528459',
'528448',
'528447',
'528446',
'528445',
'528444',
'528443',
'528442',
'528441',
'520921',
'528433',
'528439',
'528437',
'528436',
'528435',
'528434',
'529106',
'529105',
'529103',
'529102',
'529101',
'529099',
'529097',
'529096',
'529095',
'529093',
'529092',
'529091',
'529090',
'529089',
'529088',
'520842',
'528507',
'528506',
'529087',
'529086',
'529085',
'529083',
'528513',
'528512',
'529076',
'529075',
'528593',
'529074',
'528612',
'528617',
'529073',
'529072',
'528487',
'528476',
'529070',
'528967',
'529069',
'528943',
'528945',
'529067',
'529065',
'529064',
'529063',
'528960',
'528962',
'529062',
'528964',
'529061',
'529060',
'529059',
'529057',
'529056',
'525611',
'529053',
'529048',
'529044',
'528818',
'528817',
'528816',
'528815',
'528814',
'528813',
'528811',
'528809',
'528808',
'528807',
'528806',
'528805',
'528804',
'528803',
'528725',
'528801',
'528798',
'528797',
'528795',
'528794',
'528793',
'528792',
'528791',
'528789',
'528788',
'528787',
'528786',
'528917',
'528785',
'528783',
'528782',
'528781',
'528927',
'529280',
'528779',
'528776',
'528774',
'520627',
'528772',
'528771',
'528386',
'528770',
'528769',
'528768',
'528767',
'528766',
'528765',
'528764',
'528387',
'528763',
'528762',
'529167',
'528760',
'528759',
'528758',
'529165',
'489179',
'488836',
'528394',
'528891',
'520718',
'520717',
'528396',
'520711',
'528888',
'528887',
'528886',
'528885',
'488829',
'528884',
'489015',
'528882',
'528881',
'528880',
'528879',
'528878',
'528877',
'525731',
'528398',
'528875',
'528874',
'528873',
'528872',
'528871',
'528870',
'528869',
'528868',
'528400',
'528867',
'528866',
'528865',
'528864',
'529123',
'528863',
'528862',
'528861',
'528860',
'528859',
'528857',
'528856',
'520684',
'488904',
'528854',
'528853',
'528852',
'528851',
'528850',
'488985',
'528848',
'488742',
'489154',
'528847',
'528842',
'528837',
'528836',
'528834',
'528833',
'528832',
'488905',
'528831',
'528830',
'528388',
'528828',
'528825',
'528824',
'528823',
'528822',
'528390',
'528820',
'528819',
'528956',
'528955',
'529219',
'528944',
'489495',
'528391',
'528952',
'528951',
'528402',
'488844',
'529326',
'488749',
'488779',
'528957',
'528421',
'489080',
'528961',
'528963',
'528403',
'489207',
'528419',
'528420',
'489475',
'489162',
'488769',
'529430',
'529451',
'489403',
'488966',
'488646',
'528968',
'488941',
'528422',
'488778',
'529135',
'528966',
'488902',
'489022',
'489571',
'528404',
'489497',
'528949',
'528947',
'489523',
'528406',
'528939',
'529394',
'529337',
'528410',
'528942',
'528411',
'528941',
'528412',
'528935',
'528934',
'528937',
'528936',
'528933',
'528413',
'528932',
'528931',
'528924',
'528923',
'528930',
'528929',
'528414',
'528928',
'528926',
'528415',
'528914',
'528913',
'528916',
'529355',
'528919',
'528920',
'528921',
'528922',
'488910',
'528907',
'528906',
'528905',
'528903',
'528901',
'528900',
'528899',
'528898',
'528897',
'528896',
'528895',
'528416',
'528894',
'528893',
'529150',
'528417',
'528418',
'528755',
'489515',
'528909',
'528911',
'528910',
'528482',
'528481',
'529251',
'488714',
'528427',
'528480',
'489012',
'528479',
'528478',
'489118',
'488713',
'529466',
'489513',
'489555',
'489263',
'489481',
'528486',
'529283',
'528485',
'528484',
'488953',
'528488',
'528495',
'528494',
'528490',
'489507',
'529320',
'489023',
'489163',
'489057',
'489048',
'488845',
'489427',
'489056',
'489070',
'489559',
'528469',
'528468',
'528467',
'529543',
'489447',
'528475',
'528474',
'489480',
'529240',
'528472',
'528471',
'528470',
'489059',
'489058',
'489339',
'529081',
'529080',
'488983',
'529079',
'489563',
'529077',
'529228',
'528590',
'528428',
'528514',
'528423',
'528424',
'528510',
'489531',
'528425',
'528508',
'528504',
'489514',
'528505',
'528501',
'528502',
'528499',
'528498',
'533501',
'528607',
'528426',
'528605',
'528604',
'528603',
'528602',
'528601',
'528600',
'528599',
'528610',
'528609',
'528608',
'528615',
'529380',
'528614',
'528613',
'528628',
'520969',
'528627',
'528626',
'528624',
'528623',
'528620',
'528619',
'528618',
'528652',
'528650',
'528649',
'528648',
'528647',
'528645',
'528644',
'528643',
'528640',
'528639',
'528638',
'528637',
'528636',
'528633',
'528380',
'528631',
'528692',
'528691',
'528690',
'528689',
'528688',
'528687',
'528686',
'528685',
'528681',
'528680',
'528678',
'528677',
'528381',
'528382',
'528676',
'528383',
'528675',
'528674',
'528673',
'528672',
'528384',
'528671',
'521014',
'528668',
'528667',
'528385',
'528666',
'528664',
'528663',
'528661',
'528660',
'528658',
'528657',
'528656',
'528655',
'528700',
'528699',
'528698',
'528697',
'528696',
'528695',
'528693',
'528654',
'528708',
'528742',
'528706',
'489533',
'489532',
'528704',
'489579',
'488711',
'488777',
'489228',
'489229',
'488756',
'528720',
'528719',
'528718',
'528723',
'528722',
'528721',
'528709',
'528717',
'528716',
'528715',
'528714',
'528713',
'528339',
'528712',
'528711',
'528703',
'528702',
'528735',
'528733',
'489581',
'528731',
'529252',
'489535',
'528622',
'528724',
'528340',
'528341',
'528342',
'528749',
'528748',
'529273',
'528343',
'528747',
'528746',
'489011',
'489041',
'528744',
'528743',
'488923',
'489394',
'528754',
'528753',
'528344',
'528751',
'528750',
'489580',
'528346',
'528727',
'489486',
'489095',
'528347',
'488879',
'528739',
'528348',
'528349',
'489009',
'528737',
'528350',
'528378',
'528377',
'528376',
'528375',
'529130',
'528374',
'528373',
'528372',
'528371',
'528370',
'528369',
'528367',
'528353',
'528365',
'528364',
'528363',
'528362',
'528361',
'528360',
'528359',
'528357',
'528354',
'528356',
'528355',
'529029',
'529023',
'529004',
'529001',
'528999',
'529247',
'529107',
'529100',
'529094',
'528401',
'528606',
'528497',
'529058',
'529055',
'528799',
'528701',
'528777',
'529433',
'528889',
'528845',
'528835',
'528826',
'528965',
'528969',
'529364',
'529274',
'526698',
'529124',
'489556',
'529216',
'528509',
'489578',
'488807',
'529382',
'528625',
'528662',
'528659',
'529242',
'529266',
'529160',
'529276',
'528358',
'529041',
'529435',
'529457',
'529037',
'529465',
'529750',
'529579',
'529035',
'529028',
'529608',
'529376',
'529019',
'529402',
'529017',
'529503',
'529015',
'529328',
'529493',
'529450',
'529473',
'529540',
'529006',
'529306',
'529350',
'529403',
'529546',
'529425',
'529327',
'529374',
'529378',
'528992',
'529275',
'529292',
'529277',
'529311',
'529288',
'528976',
'529317',
'528974',
'529454',
'529244',
'529300',
'529367',
'529299',
'529307',
'529220',
'529448',
'529497',
'529353',
'529439',
'529475',
'529342',
'529225',
'528430',
'529730',
'529120',
'529119',
'529554',
'529811',
'529804',
'529116',
'529114',
'529464',
'529343',
'529269',
'529365',
'528461',
'529616',
'528440',
'528438',
'529555',
'529104',
'529587',
'529541',
'529653',
'529542',
'529578',
'529098',
'529636',
'529600',
'529389',
'528621',
'529391',
'528503',
'529222',
'529372',
'529084',
'529082',
'529484',
'529230',
'528496',
'529071',
'529068',
'528940',
'528938',
'529617',
'529066',
'529458',
'529142',
'529303',
'529357',
'529358',
'529267',
'528511',
'529581',
'529047',
'529531',
'529505',
'528812',
'532721',
'528810',
'529533',
'529509',
'529545',
'529256',
'529536',
'528802',
'528800',
'528796',
'528790',
'489458',
'489371',
'528925',
'529564',
'529472',
'528784',
'528780',
'529271',
'528775',
'529249',
'528773',
'529270',
'529529',
'529386',
'529562',
'529346',
'529302',
'529379',
'489540',
'529388',
'489510',
'529356',
'529305',
'529560',
'529334',
'529218',
'528757',
'529383',
'489347',
'528393',
'529429',
'489267',
'529396',
'529662',
'489421',
'489400',
'528395',
'528890',
'459901',
'528397',
'529434',
'528883',
'529226',
'528876',
'528399',
'529406',
'528855',
'529713',
'529370',
'528849',
'489419',
'528846',
'528844',
'528840',
'529714',
'529640',
'529308',
'529527',
'489450',
'529449',
'529371',
'528829',
'528389',
'528821',
'529535',
'529392',
'529290',
'529498',
'489160',
'489186',
'529238',
'529511',
'529453',
'528953',
'528392',
'489353',
'489456',
'529508',
'529399',
'529387',
'489352',
'529262',
'529375',
'529437',
'529395',
'529481',
'489161',
'489272',
'489206',
'529363',
'528959',
'529324',
'489457',
'529157',
'529344',
'529254',
'489426',
'529338',
'489585',
'529397',
'489549',
'529366',
'529163',
'489524',
'529329',
'529369',
'529393',
'529489',
'529431',
'529436',
'529341',
'528409',
'529405',
'529621',
'529683',
'529738',
'528915',
'528918',
'529428',
'529758',
'489381',
'528908',
'529258',
'528904',
'529432',
'529771',
'489346',
'529501',
'489451',
'528756',
'529236',
'529459',
'529474',
'488715',
'489375',
'529469',
'529361',
'529440',
'529245',
'529438',
'529463',
'529287',
'529272',
'529330',
'529447',
'489341',
'529442',
'529390',
'529468',
'529291',
'529478',
'529488',
'529500',
'528483',
'529553',
'529360',
'529268',
'528492',
'529352',
'528491',
'529407',
'528489',
'489448',
'529381',
'529261',
'489298',
'529211',
'529286',
'489498',
'529427',
'529253',
'489428',
'529340',
'529212',
'489460',
'489132',
'529241',
'529339',
'529293',
'529471',
'528473',
'489340',
'529462',
'529147',
'489374',
'529685',
'520839',
'529257',
'529502',
'529444',
'529250',
'529470',
'529404',
'529319',
'529259',
'529229',
'529332',
'529243',
'529296',
'529335',
'529234',
'529331',
'528500',
'529323',
'529499',
'529400',
'529401',
'529336',
'529321',
'529515',
'529210',
'528611',
'529384',
'529279',
'528616',
'529315',
'529373',
'529787',
'528629',
'529362',
'529385',
'529443',
'528651',
'528646',
'528642',
'528635',
'528684',
'528682',
'528670',
'529138',
'529398',
'529875',
'529162',
'528694',
'529333',
'529482',
'529304',
'529492',
'528707',
'529551',
'529573',
'529235',
'529310',
'529351',
'529264',
'529255',
'529408',
'529227',
'529313',
'529550',
'529298',
'529295',
'529446',
'529441',
'529461',
'529260',
'529301',
'529359',
'528736',
'528734',
'528732',
'529294',
'529284',
'529491',
'529285',
'529549',
'529314',
'529510',
'529248',
'529297',
'529584',
'529322',
'529345',
'528745',
'529237',
'529278',
'489488',
'529141',
'529149',
'529445',
'489473',
'489511',
'528338',
'528337',
'529504',
'529289',
'529567',
'528752',
'529518',
'529565',
'528345',
'529224',
'528729',
'529476',
'528728',
'529632',
'528726',
'528730',
'528740',
'529452',
'528741',
'489557',
'529590',
'529368',
'529223',
'529239',
'528738',
'529534',
'529623',
'489260',
'529354',
'529347',
'529548',
'529348',
'529233',
'529325',
'529231',
'529349',
'529312',
'529490',
'529517',
'529779',
'528368',
'528366',
'529467',
'521102',
'529745',
'529601',
'529603')

and cast(bus_proc_DT as datE) <= cast('4/1/2020' as date)

SELECT A.loan_nbr,mca_percent,excp_id,doc_desc,excp_sts_desc,b.bus_proc_dt FROM Reverse_DW.DBO.HUD_ASGN_EXCP_EDW B
LEFT JOIN (SELECT Loan_Nbr, mca_percent FROM  REVERSE_dw.[dbo].[RM_CHAMPION_MASTER_TBL_VW]('2020-04-01',20200401)) A
ON A.LOAN_NBR = B.Loan_nbr
