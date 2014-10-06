**************************10-05-14 X.CHAI*****************************;
proc import out=work.hpog
	datafile="C:\Users\xchai\Desktop\HPOG_ClassStudents_Adj.xlsx"
	dbms=xlsx;
	getnames=yes;
	mixed=yes;
run;
**** sort by descending TIME withing each subject****;
Proc sort data=work.hpog out=work.hpog_sort;
	by case_ descending TIME;
run;
****delete duplicates, keep the the latest record for each subject***;
proc sort data=work.hpog_sort out=work.hpog_nodu nodupkey equals;
 by case_;
run;
*****Logistic model 10-03-14 X.CHAI*****;
data hpog_logistic;
	set work.hpog_nodu;
	EB_avg=mean(of EB1-EB27);
	EH_avg=mean(of EH1-EH27);
	SS_avg=mean(of SS1-SS14);
	R_avg=mean(of R1-R2);
	SEF_avg=mean(of SEF1-SEF8);

		if STATUS=0 then y=1;
		else y=0; n=1; 

proc genmod data = hpog_logistic; 
model y/n = EB_avg EH_avg SS_avg R_avg SEF_avg/ dist=bin link=logit; 
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
/*proc print data=merge (obs=7);
var case_ TIME datediff;
run;*/

***********CPH 10-05-14 X.CHAI********************;
data work.CPH10_05_14;
	set merge;
	EB_avg=mean(of EB1-EB27);
	EH_avg=mean(of EH1-EH27);
	SS_avg=mean(of SS1-SS14);
	R_avg=mean(of R1-R2);
	SEF_avg=mean(of SEF1-SEF8);
	if STATUS=0 then STATUS_NEW=1; 
	else STATUS_NEW=0;
run;
proc phreg data=work.CPH10_05_14 plots=survival;
	model datediff*STATUS_NEW(0)=EB_avg EH_avg SS_avg R_avg SEF_avg;
run;
*******************END 10-05-14 X.CHAI******************************;

	
