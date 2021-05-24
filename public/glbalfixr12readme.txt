
GL Balances Corruption Fix Script
---------------------------------
The GL Balances Corruption Fix script allows customers to safely detect
and/or fix corrupt actual balance data in their gl_balances table.  It 
is intended to resolve balance issues introduced through sql*plus updates,
concurrency problems, account type changes, retained earnings account
changes, or any other issue that would require fixes in the gl_balances 
table.    

This version of the GL Balances Corruption Fix script is designed for
release 12 only.  This script is not intended to work with release 11.0, 
release 11i, release 10.7, or any other release of Oracle Applications other 
than release 12.  

The GL Balances Corruption Fix script is not intended to diagnose the 
cause of the corruption.  If such diagnosis is necessary, it is strongly 
recommended that it either be done before using this script to fix 
balances, or that the backup of the gl_balances table made before running 
this script be retained until after the root cause analysis is completed.  
When this script is used to fix balances in the gl_balances table, it 
updates the table in such a way that data necessary to diagnose the 
cause of the problem may be overwritten or lost.

The GL Balances Corruption Fix script assumes that your journal entry
information is accurate.  In its detection of balance corruption, it 
compares the gl_balances table with your journal entries tables, and 
reports any discrepancies.  In its correction of balance corruption, it 
fixes the gl_balances table to match the information in your journal
entries tables.  If it is suspected that your journal entry information 
is incorrect or incomplete, then any problems with your journal entry
information should be resolved before running this script, to avoid
having the problems propagated into the gl_balances table.  

The GL Balances Corruption Fix script assumes that your summary template
account hierarchies are accurate.  When fixing balance corruption, it
makes fixes to any summary accounts based upon the associated detail
account fixes and the current account hierarchy.  If your current
account hierarchy is inaccurate or if your summary accounts have
balances inconsistent with the detail balances, then the issue needs to 
be resolved separately, generally by dropping and recreating the summary
template.   

The GL Balances Corruption Fix script only fixes issues in the 
gl_balances table.  It does not fix issues in gl_daily_balances, in
gl_code_combinations, in gl_period_statuses, in gl_je_batches, 
in gl_je_headers, in gl_je_lines, in gl_account_hierarchies, etc.  

Before running the GL Balance Corruption Fix script to fix gl_balances
data, you should backup your gl_balances table.  You should also make
sure that the following Oracle General Ledger concurrent programs 
are prevented from running while the script is running:  Posting,
Open Period, Translation, Add/Delete Summary Templates, and
Program - Incremental Add/Delete Summary Templates.  These programs 
can be safely run for ledgers other than the one being 
corrected, but it is generally easier and safer to block them out 
completely.  Note that many programs submit Posting, so it isn't 
sufficient to just prevent access to the Post Journals form.  Backing 
up the gl_balances table and blocking out the concurrent programs is 
unnecessary if you are only running the GL Balances Corruption Fix 
script in report only mode, and are not asking it to fix any
corruption found.

You should prevent users from reserving funds while the GL Balance
Corruption Fix script is running.  Funds reservation done while the GL
Balance Corruption Fix script is running may be inaccurate, and may
allow funds to be overspent.  

The GL Balances Corruption Fix script can safely be run without the 
assistance of Oracle Support Services.  However, we recommend involving 
Oracle Support Services in any corruption fix that necessitates using 
the GL Balances Corruption Fix script, especially if it is the first
time you have used the script.

Note that the performance of the GL Balances Corruption Fix script
depends upon both the number of balances to be verified as well as
the number of balances to be fixed.  Even if there is no or minimal
data that needs to be fixed, the script may take a long time to run
if run for a large range of accounts or a large number of periods. 
To improve performance, please make sure that your GL schema has
been analyzed shortly before running this script.  

If you need to kill the GL Balances Corruption Fix script, it can be 
done safely.  All of the work done will be rolled back.  


Types of Corruption Resolved
----------------------------
The GL Balances Corruption Fix script is designed to fix all types
of corruption encountered in the gl_balances table.  Specifically,
it can detect and fix the following:

(The text in parenthesis is the text that shows up in the report
when this problem is detected.)

  1. Period to Date Balances (Bad PTD Amount)
     The GL Balances Corruption Fix script verifies that your period 
     to date balances match your posted journal lines.  It checks
     and fixes your foreign entered, functional, and statistical 
     actual period to date balances.  
 
  2. Quarter to Date Balances (Bad QTD Amount)
     The GL Balances Corruption Fix script verifies that your 
     opening quarter to date balances match the closing quarter to
     date balances for the prior period, assuming it is in the
     same quarter.  Note that this check checks opening balances,
     not the total quarter to date balance.  The period to date
     portion of the total quarter to date balance is checked by the
     period to date balances check above.  The script checks and 
     fixes your foreign entered, functional, and statistical 
     actual opening quarter to date balances.  

  3. Year to Date Balances (Bad YTD Amount)
     The GL Balances Corruption Fix script verifies that your 
     opening year to date balances match the closing year to
     date balances for the prior period, assuming it is in the
     same year or is a balance sheet account.  Note that this 
     check checks opening balances, not the total year to date 
     balance.  The period to date portion of the total year to 
     date balance is checked by the period to date balances check 
     above.  The script checks and fixes your foreign entered, 
     functional, and statistical actual opening year to date balances.  

  4. Retained Earnings Balances (Bad YTD Amount)
     The GL Balances Corruption Fix script verifies that your retained
     earnings opening balances are correct at the beginning of each year, 
     given your retained earnings ending balances for the prior year 
     and the balances of your income statement accounts at the end of 
     the prior year.  It checks and fixes your foreign entered, 
     functional, and statistical actual retained earnings balances. 
 
     Note that retained earnings balances are only checked if the 
     account range specified when running the GL Balances Corruption
     Fix script either contains the retained earnings account or contains
     an income statement account.

  5. Project to Date Balances (Bad PJTD Amount)
     The GL Balances Corruption Fix script verifies that your 
     opening project to date balances match the closing project to
     date balances for the prior period.  Note that this check checks 
     opening balances, not the total project to date balance.  The 
     period to date portion of the total project to date balance 
     is checked by the period to date balances check above.  The 
     script checks and fixes your foreign entered, functional, 
     and statistical actual opening project to date balances.  

  6. Duplicate Balances (Duplicate Row)
     The GL Balances Corruption Fix script checks for actual rows that 
     violate the primary key of the gl_balances table, by having
     the same values for all of the columns in the primary key as
     some other row.  It deletes all but one of these duplicates.  If
     necessary, it will then correct the balances of the remaining row.

     Note that the GL Balances Corruption Fix script, when run
     in report only mode, may produce unusual output in the report
     when it encounters duplicates.  It will report the duplicates
     correctly, but if one or both of the duplicates have other 
     problems, say if they have incorrect period to date balances,
     then these problems will also be reported.  If both duplicates
     have the problem, then the problem will be reported twice.  If
     one duplicate has the problem, then it will be reported once
     even though the other duplicate doesn't have the problem.  

     Also, if the duplicates are for an income statement account, then 
     the retained earnings calculation may double count the 
     contribution of that account for the purposes of the report. 
     
     When the GL Balance Corruption Fix script is run to fix balances,
     not just report on them, then these problems shouldn't occur.  All
     but one of the duplicates will be deleted before the rest of the
     analysis occurs, so the retained earnings calculations will be
     correct.  If the duplicate row that was retained has other 
     problems, for example an incorrect period to date balance, then this
     will also be corrected and reported on.       

  7. Extra Balances (Extra Row)
     The GL Balances script checks for actual rows in gl_balances that
     are for a period that is not opened, closed, or permanently closed.  
     It reports on and deletes these rows.  


Limitations and Warnings
------------------------
  1. The GL Balances Corruption Fix script assumes that your journal entry
     information is accurate.  In its detection of balance corruption, it 
     compares the gl_balances table with your journal entries tables, and 
     reports any discrepancies.  In its correction of balance corruption, it 
     fixes the gl_balances table to match the information in your journal
     entries tables.  If it is suspected that your journal entry information 
     is incorrect or incomplete, then any problems with your journal entry
     information should be resolved before running this script, to avoid
     having the problems being propagated into the gl_balances table.  

  2. The GL Balances Corruption Fix script assumes that your summary 
     template account hierarchies are accurate.  When fixing balance 
     corruption, it makes fixes to any summary accounts based upon the 
     associated detail account fixes and the current account hierarchy.  
     If your current account hierarchy is inaccurate or if your summary 
     accounts have balances inconsistent with the detail balances, then 
     the issue needs to be resolved separately, generally by dropping and 
     recreating the summary template.   

  3. The GL Balances Corruption Fix script only works on actual balances.
     It does not fix problems with budget or encumbrance balances.
 
  4. The GL Balances Corruption Fix script only fixes issues in the 
     gl_balances table.  It does not fix issues in gl_daily_balances, in
     gl_code_combinations, in gl_period_statuses, in gl_je_batches, 
     in gl_je_headers, in gl_je_lines, in gl_account_hierarchies, etc.  

  5. The GL Balances Corruption Fix script does not fix daily balances.
     Customers who maintain daily balances can run this script, but need
     to be aware that it will only fix their gl_balances table, not their
     gl_daily_balances table.

  6. The GL Balances Corruption Fix script does not maintain budgetary
     dr and budgetary cr balances.  Customers who use the budgetary
     dr and budgetary cr account types cannot use this script.  The
     script will error out if it detects that the customer is using
     budgetary dr and/or budgetary cr account types.

  7. The GL Balances Corruption Fix script does not maintain functional
     entered balances.  Customers who have the maintenance of functional
     entered balances turned on (aka who have the 
     track_entered_func_curr_flag column set to 'Y' in gl_ledgers),
     cannot use this script.  The script will error out if it detects
     that the maintenance of entered functional balances is turned on.

  8. The GL Balance Corruption Fix script expects that each year has
     the same number of periods.  If after the specified start period,
     some years have more periods than others, the script will error
     out.   

  9. The GL Balances Corruption Fix script cannot be run for the first
     period ever defined in your calendar.  It can be run for the first
     opened period for your ledger, but there must be a period 
     defined, though potentially not opened, that is before this period.
     The script will error out if it is run for the first period in your
     calendar.  

 10. The GL Balances Corruption Fix script cannot be run for periods for
     which journals have been purged.  The script will error out if it
     is run for periods in which journals have been purged.

 11. The GL Balances Corruption Fix script cannot be run for periods for
     which balances have been purged.  It also cannot be run for a 
     period where the period immediately prior to that period has had
     balances purged. The script will error out if it is run for periods 
     that satisfy these criteria.

 12. The GL Balances Corruption Fix script will use the current retained
     earnings account defined for your ledger.  If you have 
     changed retained earnings accounts, then the script may move balances
     from your old retained earnings account to the current one.  The
     script will do this for all fiscal years where the period immediately
     following the fiscal year (aka the first period of the next year)
     is equal to or later than the start period specified when the 
     script was started.

     For example, if your fiscal year starts in January, and you specify
     a start period of jan-04 when running the GL Balances Corruption
     Fix program, then the balances for 2003, 2004, etc would be moved
     to the new retained earnings account, but the balances for 2002,
     2001, etc would be left with the old retained earnings account.

 13. The GL Balances Corruption Fix script will attempt to retrieve all 
     retained earnings accounts that have balancing segment values that
     fall into the specified account range, even if the balancing
     segment value has never been posted to and does not have balances
     that need to be fixed.  If the appropriate retained earnings
     account does not exist, the script will attempt to create it.  The
     script will fail to run if the account cannot be created.  If
     the account does exist, it will be used even if it is disabled,
     out of date, or secured.

 14. The GL Balances Corruption Fix script will use the current account
     type for each account.  If an account was treated as an income
     statement account for some years and a balance sheet account for
     others, the balances for the account will be changed to be 
     consistently treated as the current account type for all of the
     years processed by the script.  The script will do this for all 
     fiscal years where the period immediately following the fiscal 
     year (aka the first period of the next year) is equal to or later 
     than the start period specified when the script was started.

     For example, if your fiscal year starts in January, and you specify
     a start period of jan-04 when running the GL Balances Corruption
     Fix program, then the balances for 2003, 2004, etc would be moved
     to the new account type, but the balances for 2002, 2001, etc 
     would be left with the old account type.

 15. The GL Balances Corruption Fix script doesn't recalculate 
     translations.  After running the script, you may need to rerun
     translation to get up to date translated balances.

 16. The GL Balances Corruption Fix script will rollback any sql*plus
     updates to the gl_balances table that result in actual balances 
     that don't match journals.  It will do this even if the updates 
     were intentional; for example to seed opening balances.  It will 
     only do this for periods equal to or after the start period 
     specified when running the script.  


Setting up your environment
---------------------------
Before the GL Balances Corruption Fix script can run successfully
against your environment, the objects that it needs need to be
installed in your database.  This can be done as follows:

  1. Uncompress the provided file.

  2. Run glqblfix.sql against your apps account. Glqblfix.sql will 
     create all of the necessary temporary tables and will analyze 
     the new tables.  

     Glqblfix.sql will request the name of your gl account, your 
     gl password, the name of your apps account, and your apps 
     password.

     Please note that if one or more of the necessary objects already 
     exists, glqblfix.sql will produce error messages, and then
     continue on with the next object.  These error messages are expected
     and can be ignored. 

     Example
     ------- 
     sqlplus apps/apps @glqblfix.sql

  3. Run glublfxs.pls against your apps account.  Glublfxs.pls will
     create the specification for the gl_balance_fix package.  

     Glublfxs.pls should not produce any errors when run.  If it 
     produces errors, then you may need to contact Oracle Support 
     Services to get them resolved.  

     Example
     ------- 
     sqlplus apps/apps @glublfxs.pls

  4. Run glublfxb.pls against your apps account.  Glublfxb.pls will
     create the body for the gl_balance_fix package.  

     Glublfxb.pls should not produce any errors when run.  If it 
     produces errors, then you may need to contact Oracle Support 
     Services to get them resolved.  

     Example
     ------- 
     sqlplus apps/apps @glublfxb.pls

  5. Verify that the gl_balance_fix package exists in your database
     and has successfully compiled.


Running the Script
------------------
To run the GL Balances Corruption Fix script, you need to do the 
following:

  1. Read this entire document first.

  2. Back up your gl_balances table if you are going to use the 
     script to fix balances, not just to report

  3. Take the necessary steps to make sure the Posting,
     Open Period, Translation, Add/Delete Summary Templates, and
     Program - Incremental Add/Delete Summary Templates programs don't 
     run while the GL Balances Corruption Fix script is running.
     These programs can be safely run for ledgers other 
     than the one being corrected, but it is generally easier 
     and safer to block them out completely.  Note that many programs 
     submit Posting, so it isn't sufficient to just prevent access to 
     the Post Journals form. 

  4. Take the necessary steps to make sure funds aren't reserved while
     the GL Balance Corruption Fix script is running.  Funds
     reservation done while the GL Balance Corruption Fix script is 
     running may be inaccurate, and may allow funds to be overspent. 
     
  5. The report that results from running this script will be dumped
     out to your screen.  Make sure that you are running the report
     in such a way that you can handle a potentially many page report
     with a page width of 132 characters being dumped out to your
     screen.

  6. Start the script by running it using sql*plus against the apps 
     account.

     sqlplus apps/apps @glbalfix.sql

  7. The program will ask you to confirm that you have read this
     documentation and have backed up the gl_balances table.  Press
     *Return* to confirm this.

  8. When prompted, enter the name of the ledger for which 
     balances are to be checked and/or fixed.  Note that case 
     and punctuation is important; you want to enter the name 
     exactly as it appears in the ledgers form.

  9. When prompted, enter the period to start fixing or checking 
     balances from.  Balances will be checked and/or fixed from this 
     period through the latest opened period.  Balances before this 
     period will not be checked and/or fixed, though the ending 
     balances of the period immediately before this one will be used 
     to verify the opening balances for this period.  

 10. When prompted, enter the low and high range of accounts that the 
     program is to run for.  You can either leave both of these values 
     empty, in which case the program will run for all accounts, or you 
     can specify a low and high account for the range, in which case 
     only accounts within that range will be processed.  If you specify 
     a value for the low account, you must also specify a value for the
     high account, and vica versa.  If you specify values for the 
     low and high accounts, you must specify values for each segment,
     as well as the necessary delimiters.  For example, you might
     specify a value for the low account of 01-000-1100-0000-000 and
     a value for the high account of 01-200-2100-0000-ZZZ.

 11. When prompted, enter the user name of the user who is executing this 
     program.  This should be the user name as used in logging into 
     applications. Any inserts or updates on gl_balances will be
     stamped with this user.  

 12. When prompted, enter whether you want to run this script in report
     only mode.  Entering a value of 'N' runs the report in fix mode,
     in which it fixes the balances.  Entering any other value for
     this parameter will cause the script to run in report only mode. 
     It will produce a report indicating the problems with the 
     gl_balances table, but it will not resolve these problems.    
 
 13. Once the report runs, review the results.

 14. If desired, once the results have been reviewed, run Translation
     to do any necessary corrections to your translated balances.  


Example Run
-----------
sqlplus apps/apps @glbalfix.sql

SQL*Plus: Release 8.0.6.0.0 - Production on Fri Jun 2 16:06:22 2006

(c) Copyright 1999 Oracle Corporation.  All rights reserved.


Connected to:
Oracle9i Enterprise Edition Release 9.2.0.7.0 - Production
With the Partitioning, Oracle Label Security, OLAP and Oracle Data Mining options
JServer Release 9.2.0.7.0 - Production


This is the GL Balances datafix corruption script.  Please review
the documentation thoroughly before running this script.  Please
also backup your gl_balances table before running this script
unless you are going to run it in reporting mode only.

Press RETURN to continue.


Ledger: Vision Operations (USA)
Start period: Jan-01
Account range low: 08-000-1000-0000-000
Account range high: 08-000-8000-0000-000
User: OPERATIONS
Report only (Y/N): Y


No bad balances found.

Disconnected from Oracle9i Enterprise Edition Release 9.2.0.7.0 - Production
With the Partitioning, Oracle Label Security, OLAP and Oracle Data Mining options
JServer Release 9.2.0.7.0 - Production


Reviewing the Report
--------------------
When the GL Balances Corruption Fix script has completed, it will 
display either 'No bad balances found.' which indicates that it found 
no corruption, or it will display an error message if it found an 
error (the errors are discussed in a later section), or it will display 
a report that indicates the detected balance corruption.

An example of such a report is as follows:


						   Balance Corruption Fix Results			       Date: 02-JUN-06 16:34
													       Page:		   1

Ledger: Vision Operations (USA)
Start Period: Jan-01
Account Low: 08-000-1000-0000-000
Account High: 08-000-8000-0000-000


Account 							  Currency   Period	     Problem
----------------------------------------------------------------- ---------- --------------- -------------------------
New Dr			    New Cr			New Converted Dr	    New Converted Dr
--------------------------- --------------------------- --------------------------- ---------------------------
Old Dr			    Old Cr			Old Converted Dr	    Old Converted Dr
--------------------------- --------------------------- --------------------------- ---------------------------
08-000-1110-0000-000						  CAD	     Nov-04	     Bad PTD Amount
		      0.00			  0.00			      0.00			  0.00
		      0.00		      1,000.00			      0.00		      1,200.00

08-000-1110-0000-000						  USD	     Nov-04	     Bad PTD Amount
		      0.00			  0.00
		      0.00		      1,200.00

08-000-5341-0000-000						  CAD	     Nov-04	     Bad PTD Amount
		      0.00			  0.00			      0.00			  0.00
		  1,000.00			  0.00			  1,200.00			  0.00

08-000-5341-0000-000						  USD	     Nov-04	     Bad PTD Amount
		      0.00			  0.00
		  1,200.00			  0.00


The heading of the report gives the ledger, the start period, and
the account range the report was run for, as well as giving the date and
time on which it was run.  This information is repeated on each page.

The body of the report details any corruption that was found.  It 
indicates the account, currency, and period in which the corruption
can be found, the type of corruption, the new (correct) balances and
the old (incorrect) balances.  

The types of corruption are Bad PTD Amount, Bad QTD Amount, Bad
YTD Amount, Bad PJTD Amount, Extra Row, and Duplicate Row.  They 
are described above in the "Type of Corruption Resolved" section.  
Note that bad retained earnings opening balances are reported as
Bad YTD Amount corruption.

Note that for QTD, YTD, and PJTD problems, the balances shown are
the opening QTD, YTD, and PJTD balances.  They don't include the 
current period activity, they only include the QTD, YTD, and PJTD 
impact from prior periods. 

The converted amount columns are only populated for foreign currency
balances with Bad PTD Amount or Bad YTD Amount corruption.

None of the amount columns are populated for Extra Row and Duplicate
Row corruption.

Note that one problem row is displayed for each problem detected in
each row in gl_balances.  However, multiple rows may be in reality
impacted by the same problem.   In the above case, a foreign currency 
transaction that impacted both the foreign currency (CAD) as well as 
the cumulative functional currency (USD) balances was deleted, so both 
sets of rows were impacted.  

Another example of this would be as follows:

Account 							  Currency   Period	     Problem
----------------------------------------------------------------- ---------- --------------- -------------------------
New Dr			    New Cr			New Converted Dr	    New Converted Dr
--------------------------- --------------------------- --------------------------- ---------------------------
Old Dr			    Old Cr			Old Converted Dr	    Old Converted Dr
--------------------------- --------------------------- --------------------------- ---------------------------
08-000-2110-0000-000						  USD	     Nov-04	     Bad PTD Amount
		      0.00			 50.00			      
		      0.00		          0.00			      

08-000-2110-0000-000						  USD	     Dec-04	     Bad QTD Amount
		      0.00			  0.00			      
		      0.00		         50.00			      

08-000-2110-0000-000						  USD	     Dec-04	     Bad YTD Amount
		      0.00			  0.00			      
		      0.00		         50.00			      

08-000-2110-0000-000						  USD	     Dec-04	     Bad PJTD Amount
		      0.00			  0.00			      
		      0.00		         50.00			      
  
In this case, the $50.00 amount never made it to the Nov-04 row in 
gl_balances, but it did impact the Dec-04 QTD, YTD, and PJTD balances.
So four errors are reported ... first the error that the $50 journal
line in Nov-04 doesn't have corresponding amounts in the gl_balances 
table, then the errors that the Dec-04 opening QTD, YTD, and PJTD 
balances don't match the Nov-04 ending QTD, YTD, and PJTD balances.  

When fixing gl_balances, the GL Balances Corruption Fix script would
net out these two issues, resulting in the Nov-04 PTD Cr balance
being changed to $50.00, while the Dec-04 QTD, YTD, and PJTD 
balances would be left alone, since the $50 rollforward from Nov-04 
and the -$50 reduction to fix the bad QTD, YTD, and PJTD would net out 
to zero.


Errors Reported
---------------
The following errors will be caught and reported by the GL Balances
Corruption Fix script:

  Error 1: The ledger name provided isn't a ledger name that 
  is defined on the system.

  This error occurs when the ledger name specified when running
  the GL Balances Corruption Fix script doesn't match the name of
  any of the ledgers defined on the system.  If you receive this 
  error, you may want to check the case and punctuation of the ledger 
  name you provided.  The ledger name should be entered 
  exactly as it appears in the Ledgers form.  The full name should 
  be entered, not the short name.

  Error 2: The Ledger has an accounted period type that doesn't 
  exist in the gl_period_types table.

  This error occurs when the ledger specified has an accounted
  period type that isn't defined.  This sort of data corruption should
  never occur.  If you see this error message, please contact Oracle
  Support Services.

  Error 3: The start period provided either doesn't exist, isn't 
  opened, or has a period number less than 1 or greater than the 
  maximum number of periods per year

  This error occurs when the start period specified when running the
  GL Balances Corruption Fix script is not valid in some way.  Either
  no period with that name has ever been defined for the calendar and
  accounted period type of the specified ledger, or the period
  hasn't been opened for the specified ledger, or the period
  number of the period is less than 1 or greater than the maximum
  number of periods per year for the accounted period type of the
  specified ledger.  If you receive this error, you should
  double check the start period name you provided.

  Error 4: The latest opened period for this ledger either 
  doesn't exist, isn't opened, or has a period number less than 1 or 
  greater than the maximum number of periods per year.

  This error occurs when the latest opened period of the specified
  ledger is not valid in some way.  Either no period with that 
  name has ever been defined for the calendar and accounted period 
  type of the specified ledger, or the period hasn't been 
  opened for the specified ledger, or the period number of the 
  period is less than 1 or greater than the maximum number of periods 
  per year for the accounted period type of the specified ledger.
  None of these should ever occur.  If you see this error message, 
  please contact Oracle Support Services.

  Error 5: The low value provided for the account range is invalid.

  This error occurs when an account range is specified, but the low
  value of the account range is not valid.  If you encounter this
  error, check to make sure that values are specified for all segments 
  and the correct delimiter is used to separate segment values. 

  Error 6: The high value provided for the account range is invalid.

  This error occurs when an account range is specified, but the high
  value of the account range is not valid.  If you encounter this
  error, check to make sure that values are specified for all segments 
  and the correct delimiter is used to separate segment values.   

  Error 7: Values were not specified for one or more segments in 
  the account range.

  This error occurs when an account ranges is specified, but values
  were not specified for one or more segments.  If you specify an
  account range, you must specify values for all segments.  If you
  encounter this error, verify that you have specified low and
  high values for all segments.

  Error 8: There exist undefined or unopened periods between the 
  start period and the latest opened period.

  This error occurs when there is either an unopened period between
  the specified start period and the latest opened period of the
  specified ledger, or when one or more periods within this
  range are undefined.  If you encounter this error, check and make
  sure that all period years within this range have periods defined
  for period number one through the maximum number of periods per
  year for the accounted period type of the specified ledger.  
  If all such periods are defined, with no gaps or extra periods and
  with the correct period type, then check to make sure that they are 
  all opened, closed, or permanently closed.  If you do find a missing 
  period or one that is not opened, then please contact Oracle Support 
  Services.  

  Error 9: There exists a period with an invalid period number 
  between the start period and the latest opened period.

  This error occurs when there is a period between the specified start 
  period and the latest opened period of the specified ledger
  with a period number less than 1 or greater than the maximum number 
  of periods per year for the accounted period type of the specified 
  ledger.  If you encounter this error, then please look for such
  a period.  If you do find one, then please contact Oracle Support
  Services.

  Error 10: The start period is the first period defined in this 
  calendar. 

  This error occurs when the specified start period is the very first 
  period defined in the calendar used by the specified ledger
  for the accounted period type used by the specified ledger.
  If you encounter this error, then please either choose a later period
  as the start period or define a period immediately before this period
  in the correct calendar and with the correct period type.

  Error 11: Tracking of entered functional currency balances is turned 
  on.

  This error occurs when tracking of entered functional currency 
  balances is on for the specified ledger.  If you encounter 
  this error, then you will need to use an alternative solution to 
  detect and fix any balance corruption.

  Error 12: Journals have been purged for the start period or for 
  periods after the start period.

  This error occurs when journals have been purged for the specified
  start period or for periods after it.  If you encounter this error, 
  you either need to choose a later period as the start period or use 
  an alternative solution to detect and fix any balance corruption.

  Error 13: Your chart of accounts contains budgetary dr or budgetary 
  cr accounts.

  This error occurs when the chart of accounts of the specified set
  of books contains accounts with an account type of budgetary dr
  or budgetary cr.  If you encounter this error, then you will need 
  to use an alternative solution to detect and fix any balance corruption.

  Error 14: Unable to retrieve segment values associated with your 
            retained earnings ccid 999.

  This error occurs when the retained earnings account associated with
  your ledger is undefined or invalid.  The code combination id
  of the retained earnings account that the GL Balances Corruption Fix
  script attempted to use is displayed in the error instead of the 999.  
  If you encounter this error, then you should go into the ledger 
  form and check your retained earnings account definition.  You may 
  need to fix it.

  Error 15: Flexfield creation failed with following error: 

  This error occurs when the GL Balances Corruption Fix script 
  attempted unsuccessfully to create a retained earnings account.  
  If you encounter this error, then please review the text of the
  attached message, and either resolve the issue, or create all
  necessary retained earnings account manually before running the
  program again.  

  Error 16: Balances have been purged for the period immediately 
  before the start period, for the start period, or for periods after 
  the start period.

  This error occurs when balances have been purged for the specified
  start period, for the period immediately before the specified start
  period, or for periods after it.  If you encounter this error, you 
  either need to choose a later period as the start period or use an 
  alternative solution to detect and fix any balance corruption.

  Error 17: The user name provided isn't a user name that is defined 
  on the system.
  
  This error occurs when the user name specified when running
  the GL Balances Corruption Fix script doesn't match the name of
  any of the users defined on the system.  If you receive this 
  error, you may want to check the case of the user name you provided.  
  The user name should be entered exactly as it appears in the Users form.

  Error 18: The posted status or period for one of your lines doesn't 
  match the information at batch or journal level.

  This error occurs when the posted status or the period for one or 
  more of your journal lines doesn't match the posted status or the
  period of the batch or journal that contains it.  If you encounter 
  this error, please contact Oracle Support Services.

  Error 19: There exists an opened period after the latest opened period.

  This error occurs when a period after the latest opened period of the
  specified ledger has a status of open, closed, or permanently 
  closed.  If you encounter this error, please contact Oracle Support 
  Services.


Fixing Concurrency Issues
-------------------------
The GL Balances Corruption Fix script should not be run at the same
time as the following programs: Posting, Open Period, Translation, 
Add/Delete Summary Templates, and Program - Incremental Add/Delete 
Summary Templates.  These programs can be safely run at the same
time for ledgers other than the one being corrected, but it 
is generally easier and safer to block them out completely.

If one of these programs is accidentally run at the same time as the
GL Balances Corruption Fix script and for the same ledger, then
depending upon which program it was, this can be resolved as follows:

  1. Posting
  If Posting and the GL Balances Corruption Fix script were accidentally 
  run at the same time for the same ledger, then rerun the
  GL Balances Corruption Fix script for the same set of parameters to
  detect and resolve any corruption.  Be aware that you may also need
  to drop and recreate your summary templates.  

  2. Open Period
  If Open Period and the GL Balances Corruption Fix script were 
  accidentally run at the same time for the same ledger, then 
  rerun the GL Balances Corruption Fix script for the same set of 
  parameters to detect and resolve any corruption.  Be aware that 
  you may also need to drop and recreate your summary templates.  

  3. Translation
  If Translation and the GL Balances Corruption Fix script were 
  accidentally run at the same time for the same ledger, then 
  you may need to purge and retranslate balances, starting from the 
  earliest period modified by both programs.  

  4. Add/Delete Summary Templates / Program - Incremental Add/Delete 
     Summary Templates
  If Add/Delete Summary Templates or Program - Incremental Add/Delete 
  Summary Templates and the GL Balances Corruption Fix script were
  accidentally run at the same time for the same ledger, then 
  you should drop and recreate any impacted summary templatessql.

