**************************10-03-14 X.CHAI*****************************;
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
/*proc print data=work.hpog_nodu (obs=30);
run;*/

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
****calculate max-to-min date difference for each subject****;
proc sql;
	create table newdate as
select case_, max(DATE)format=date10., min(DATE) format=date10.,max(DATE)-min(DATE)as datediff
		from work.hpog
		group by case_;
quit;
****Add a new column 'datediff' onto the dataset****; 
data mergedatediff;
merge work.hpog_nodu newdate;
by case_;
run;

***********CPH 10-03-14 X.CHAI********************;
data work.hpog_CPH09_29_14;
	set mergedatediff;
	EB_avg=mean(of EB1-EB27);
	EH_avg=mean(of EH1-EH27);
	SS_avg=mean(of SS1-SS14);
	R_avg=mean(of R1-R2);
	SEF_avg=mean(of SEF1-SEF8);
	if STATUS=0 then STATUS_NEW=1; 
	else STATUS_NEW=0;
run;
proc phreg data=work.hpog_CPH09_29_14 plots=survival;
	model datediff*STATUS_NEW(0)=EB_avg EH_avg SS_avg R_avg SEF_avg;
run;
*******************END 10-03-14 X.CHAI******************************;


