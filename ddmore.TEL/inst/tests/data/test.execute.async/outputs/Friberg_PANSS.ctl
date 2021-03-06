; Script generated by the pharmML2Nmtran Converter v.0.1.0
; Source	: PharmML 0.6.0
; Target	: NMTRAN 7.3.0
; Model 	: Friberg_PANSS
; Dated 	: Tue Aug 11 12:28:27 BST 2015

$PROBLEM "Friberg_PANSS.mdl - generated by MDL2PharmML v.6.0"

$INPUT  ID TIME DV STUD DDUR HOSP US AUC MDV
$DATA "PANSS_Friberg2009_simdata_2.csv" IGNORE=@

$PRED 
PAN0_II = THETA(1)
PAN0_III = THETA(2)
PAN0_CHRON = THETA(3)
TVPMAX = THETA(4)
PMAX_PHASEIII = THETA(5)
TP = THETA(6)
POW = THETA(7)
POP_AUC50 = THETA(8)
EMAX = THETA(9)
THETA_HOSP = THETA(10)
THETA_US = THETA(11)
POP_ERROR = THETA(12)

ETA_PAN0 = ETA(1)
ETA_PMAX = ETA(2)
ETA_AUC50 = ETA(3)
ETA_W = ETA(4)

IF (DDUR.GT.2) THEN
	DDU = 1 
ELSE
	DDU = 0 
ENDIF
 

IF (STUD.GT.30) THEN
	PHASE = 1 
ELSE
	PHASE = 0 
ENDIF
 

IF (PHASE.EQ.0) THEN
	POP_PAN0 = PAN0_II*(1+PAN0_CHRON*DDU) 
ELSE
	POP_PAN0 = PAN0_III*(1+PAN0_CHRON*DDU) 
ENDIF
 

POP_PMAX = TVPMAX*(1+PMAX_PHASEIII*PHASE) 
IF (HOSP.EQ.0) THEN
	CHOSP = (1+THETA_HOSP) 
ELSE
	CHOSP = 1 
ENDIF
 

POP_W = CHOSP*POP_ERROR*(1+THETA_US*US) 

MU_1 = POP_PAN0 ;
PAN0 = MU_1 + ETA(1);

MU_2 = POP_PMAX ;
PMAX = MU_2 + ETA(2);

MU_3 = LOG(POP_AUC50);
AUC50 = EXP(MU_3 + ETA(3));

W = POP_W*EXP(ETA_W) ;
PMOD = PMAX*(1-EXP(-(TIME/TP)**POW))
IF (TIME.GT.42) THEN
	FT = 1 
ELSE
	FT = TIME/42 
ENDIF
 
EFF = EMAX*AUC/(AUC50+AUC)*FT
IF (TIME.GT.0.AND.AUC.GT.0) THEN
	EMOD = EFF 
ELSE
	EMOD = 0 
ENDIF
 
PANSS_TOTAL = PAN0*(1-PMOD)*(1-EMOD)

IPRED = PANSS_TOTAL
W = W
Y = IPRED+W*EPS(1)
IRES = DV - IPRED
IWRES = IRES/W

$THETA 
(94.0 )	;PAN0_II
(90.5 )	;PAN0_III
(-0.0339 )	;PAN0_CHRON
(0.0859 )	;TVPMAX
(0.688 )	;PMAX_PHASEIII
( 0.0 , 13.2 )	;TP
( 0.0 , 1.24 )	;POW
(82.0 )	;POP_AUC50
(0.191 )	;EMAX
(-0.145 )	;THETA_HOSP
(0.623 )	;THETA_US
(3.52 )	;POP_ERROR

$OMEGA 
(167.0 )	;OMEGA_PAN0
(0.0249 )	;OMEGA_PMAX
(21.7 )	;OMEGA_AUC50
(0.196 )	;OMEGA_W

$SIGMA 
1.0 FIX	;eps


$EST METHOD=COND INTER MAXEVALS=9999 PRINT=10 NOABORT
$COV 

$TABLE  ID TIME STUD DDUR HOSP US AUC MDV PRED IPRED RES IRES WRES IWRES Y DV NOAPPEND NOPRINT FILE=sdtab

$TABLE  ID PAN0 PMAX AUC50 W ETA_PAN0 ETA_PMAX ETA_AUC50 ETA_W NOAPPEND NOPRINT FILE=patab

$TABLE  ID HOSP US NOAPPEND NOPRINT FILE=catab

$TABLE  ID STUD DDUR AUC NOAPPEND NOPRINT FILE=cotab


