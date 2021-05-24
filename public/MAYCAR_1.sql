set define off;
  update apps.xx_ar_ap_coef_cm05
                 set coef = 1
                 where coef= 0;
				 --1Rows
/
EXIT