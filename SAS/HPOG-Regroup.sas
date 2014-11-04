*******************10/16/2014*************************************;
proc import out=work.hpog
	datafile="C:\Users\xchai\Desktop\HPOG_ClassStudents_Adj.xlsx"
	dbms=xlsx;
	getnames=yes;
run;

**** sort by descending TIME withing each subject****;
Proc sort data=work.hpog out=work.hpog_sort;
	by case_ descending TIME;
run;
****delete duplicates, keep the the latest record for each subject***;
proc sort data=work.hpog_sort out=work.hpog_nodu nodupkey equals;
 by case_;
run;

************Logistic Model on modified EB_avg and EH_avg**************;
data hpog_logistic;
	set work.hpog_nodu;
	EB_avg=mean(of EB1-EB4,EB6,EB8,EB10,EB11,EB12,EB13,EB15,EB16,EB17,EB18,EB19,EB22,EB23,EB24,EB25,EB26);
	EH_avg=mean(of EH3-EH6,EH11,EH15,EH17,EH18,EH19,EH20,EH21,EH22,EH23,EH24);

	if STATUS=0 then y=1;
		else y=0; n=1; 

proc genmod data = hpog_logistic; 
model y/n = EB_avg EH_avg/ dist=bin link=logit; 
run;

****Add 'datediff' to work.hpog_nodu****;
proc sql;
	create table merge as
		select * from work.hpog_nodu A
		inner join
			(select case_,max(DATE)-min(DATE)as datediff
			from work.hpog
			group by case_) B
		on A.case_ = B.case_ ;
quit;
*********CPH 10/16/14*********************;
data work.CPH10_16_14;
	set merge;
	EB_avg=mean(of EB1-EB4,EB6,EB8,EB10,EB11,EB12,EB13,EB15,EB16,EB17,EB18,EB19,EB22,EB23,EB24,EB25,EB26);
	EH_avg=mean(of EH3-EH6,EH11,EH15,EH17,EH18,EH19,EH20,EH21,EH22,EH23,EH24);
	
	if STATUS=0 then STATUS_NEW=1; 
	else STATUS_NEW=0;
run;
proc phreg data=work.CPH10_16_14 plots=survival;
	model datediff*STATUS_NEW(0)=EB_avg EH_avg;
run;
*******************END 10-16-14 X.CHAI******************************;
**********Logistic Model on multiple EB_avg and EH_avg groups******;
data hpog_logistic;
	set work.hpog_nodu;
	EB1_avg=mean(of EB10-EB13);
	EB2_avg=mean(of EB15-EB17);
	EB3_avg=mean(EB6,EB18,EB19);
	EB4_avg=mean(of EB1-EB4,EB8);
	EB5_avg=mean(of EB22-EB26);
	EH1_avg=mean(of EH3-EH6);
	EH2_avg=mean(EH11,EH15);
	EH3_avg=mean(of EH17-EH20);
	EH4_avg=mean(of EH21-EH24);
	
	if STATUS=0 then y=1;
		else y=0; n=1; 

proc genmod data = hpog_logistic; 
model y/n = EB1_avg EB2_avg EB3_avg EB4_avg EB5_avg EH1_avg EH2_avg EH3_avg EH4_avg/ dist=bin link=logit; 
run;
****Add 'datediff' to work.hpog_nodu****;
proc sql;
	create table merge as
		select * from work.hpog_nodu A
		inner join
			(select case_,max(DATE)-min(DATE)as datediff
			from work.hpog
			group by case_) B
		on A.case_ = B.case_ ;
quit;

*********CPH 10/16/14*********************;
data work.CPH10_16_14;
	set merge;
	EB1_avg=mean(of EB10-EB13);
	EB2_avg=mean(of EB15-EB17);
	EB3_avg=mean(EB6,EB18,EB19);
	EB4_avg=mean(of EB1-EB4,EB8);
	EB5_avg=mean(of EB22-EB26);
	EH1_avg=mean(of EH3-EH6);
	EH2_avg=mean(EH11,EH15);
	EH3_avg=mean(of EH17-EH20);
	EH4_avg=mean(of EH21-EH24);
	
	if STATUS=0 then STATUS_NEW=1; 
	else STATUS_NEW=0;
run;
proc phreg data=work.CPH10_16_14 plots=survival;
	model datediff*STATUS_NEW(0)=EB1_avg EB2_avg EB3_avg EB4_avg EB5_avg EH1_avg EH2_avg EH3_avg EH4_avg;
run;
*******************END 10-16-14 X.CHAI******************************;
