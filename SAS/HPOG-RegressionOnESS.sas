**************************10-29-14 X.CHAI*****************************;
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

Proc print data=work.hpog_nodu (obs=10);
run;

***logistic model  10-29-14 X.CHAI*****;
data pss_logistic;
	set hpog_nodu;
	EB_avg=mean(of EB1-EB27);
	EH_avg=mean(of EH1-EH27);
	PSS=((EH_avg-9.0753972)/1.1463460)-
	((EB_avg-1.6595476)/0.8076345);
	if STATUS=0 then y=1;
		else y=0; n=1; 
/*Normalizing EH and EB*/;
proc means data=pss_logistic;
var EB_avg EH_avg;
run;
proc genmod data = pss_logistic; 
model y/n = PSS/ dist=bin link=logit; 
run;
**************END logistic model  10-29-14 X.CHAI**************;

**************ESS as dependent var  10-29-14 X.CHAI*************;
data hpog_ESS;
	set hpog_nodu;
	select;/*create first independent var*/
 		when (Employed=1 and PayBills=1 and Welfare=0)
			newvar=1;
		otherwise
			newvar=0;
 	end;
	select (STATUS);/*create second indep var--drop*/
		when(0) drop=1;
		otherwise drop=0;
	end;
	ESS_avg=mean(of SS1-SS15);
 proc print data=hpog_ESS (obs=10);
 var case_ Employed PayBills Welfare newvar STATUS drop ESS_avg;
 run;

*****regression of ESS on two indep vars*******;
ods graphics on;
proc reg data=hpog_ESS;
model ESS_avg= newvar drop;
run;
ods graphics off;

*****logistic regression of DROPOUT on ESS*******;
data ess_logistic;
set hpog_nodu;
ESS_avg=mean(of SS1-SS15);
if STATUS=0 then y=1;
		else y=0; n=1;
proc genmod data = ess_logistic; 
model y/n = ESS_avg/ dist=bin link=logit; 
run;
***********************END 10-29-2014  X.CHAI**********;
