----------------------------------------------------------------------------------------------------
COMMENT ON TABLE XXSTN.XXSTN_DTL_ACCOUNTING_BOOK IS 'ACCOUNTING_BOOK (GL_LEDGERS) stores information about the ledgers defined in the Accounting Setup Manager and the ledger sets defined in the Ledger Set form. Each row includes the ledger or ledger set name, short name, description, ledger currency, calendar, period type, chart of accounts, and other information. Some columns in this table are not applicable for ledger sets. In this case, default values would be inserted into these columns for ledger sets.';
----------------------------------------------------------------------------------------------------
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_BOOK.accounting_book_id IS 'Accounting Book (LEDGER_ID)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_BOOK.chart_of_accounts_id IS 'Chart of Accounts (ID_FLEX_NUM)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_BOOK.segment_id IS 'Balancing segment value set ID (BAL_SEG_VALUE_SET_ID)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_BOOK.segment_column IS 'Balancing segment column name (BAL_SEG_COLUMN_NAME)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_BOOK.retained_account_reference_id IS 'Retained earnings by Accounting Reference (RET_EARN_CODE_COMBINATION_ID) column';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_BOOK.book_name IS 'Accounting Book name (Ledger name)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_BOOK.book_short_name IS 'Accounting Book short name (Ledger short name)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_BOOK.book_description IS 'Accounting Book Description (Ledger description)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_BOOK.currency_code IS 'Currency code (ISO 4217 three-letter)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_BOOK.book_category_code IS 'Accounting Book Category (PRIMARY, SECONDARY, ALC etc)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_BOOK.book_attributes IS 'The compiled values of any segment qualifier assigned to the segment value';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_BOOK.book_type_code IS 'Accounting Book type (''L'' for Ledger or ''S'' for Ledger Set)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_BOOK.book_legal_type_code IS 'Accounting Book legal type (Legal, management)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_BOOK.period_set_name IS 'Accounting calendar name';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_BOOK.accounted_period_type IS 'Accounting period type';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_BOOK.first_ledger_period_name IS 'First ledger accounting period name';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_BOOK.latest_opened_period_name IS 'Latest opened accounting period name';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_BOOK.latest_encumbrance_year IS 'Latest open year for encumbrances';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_BOOK.future_enterable_periods_limit IS 'Number of future enterable periods';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_BOOK.implicit_access_set_id IS 'Implicit access set ID';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_BOOK.last_update_date IS 'Indicates the date and time of the last update of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_BOOK.last_updated_by IS 'Indicates the user who last updated the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_BOOK.creation_date IS 'Indicates the date and time of the creation of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_BOOK.created_by IS 'Indicates the user who created the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_BOOK.last_update_login IS 'Indicates the session login associated to the user who last updated the row';
	

----------------------------------------------------------------------------------------------------
COMMENT ON TABLE XXSTN.XXSTN_DTL_ACCOUNTING_CALENDAR IS 'ACCOUNTING_CALENDAR (GL_PERIOD_SETS) stores the calendars you define using the Accounting Calendar form. Each row includes the name and description of your calendar.';
----------------------------------------------------------------------------------------------------
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_CALENDAR.calendar_id IS 'Calendar Identifier - Internal use only';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_CALENDAR.calendar_name IS 'Accounting calendar name';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_CALENDAR.calendar_description IS 'Accounting calendar description';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_CALENDAR.is_secure IS 'Enable definition access set security flag';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_CALENDAR.last_update_date IS 'Indicates the date and time of the last update of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_CALENDAR.last_updated_by IS 'Indicates the user who last updated the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_CALENDAR.creation_date IS 'Indicates the date and time of the creation of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_CALENDAR.created_by IS 'Indicates the user who created the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_CALENDAR.last_update_login IS 'Indicates the session login associated to the user who last updated the row';
	

----------------------------------------------------------------------------------------------------
COMMENT ON TABLE XXSTN.XXSTN_DTL_ACCOUNTING_PERIOD IS 'ACCOUNTING_PERIOD (GL_PERIOD_STATUSES) stores the statuses of your accounting periods. Each row includes the accounting period name and status. Many applications maintain their calendars in this table, so each row also includes the relevant application identifier. CLOSING_STATUS is either ''O'' for open, ''F'' for future enterable, ''C'' for closed, ''P'' for permanently closed, or ''N'' for never opened. Note that you cannot successfully open a period in your Oracle General Ledger application by changing a period''s status to ''O'' if it has never been opened before. You must use the Open and Close Periods form or programs to properly open a period.';
----------------------------------------------------------------------------------------------------
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_PERIOD.accounting_book_id IS 'Accounting Book (LEDGER_ID)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_PERIOD.application_id IS 'ERP Application Id';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_PERIOD.period_name IS 'Accounting period name (MMM-yy)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_PERIOD.start_date IS 'Date on which accounting period begins (dd-MMM-yy)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_PERIOD.end_date IS 'Date on which accounting period ends (dd-MMM-yy)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_PERIOD.effective_period_num IS 'Denormalized period number (period_year*10000 + period_num)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_PERIOD.closing_status IS 'Accounting period status (Open, Future, Closed, Permanently Closed, Never Opened)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_PERIOD.period_num IS 'Accounting period number (MM) month of the year';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_PERIOD.period_type IS 'Accounting period type (Month, Quarter, Year, Week or Custom)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_PERIOD.period_year IS 'Accounting period year (yyyy)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_PERIOD.year_start_date IS 'Date on which the year containing this accounting period starts (dd-MMM-yy)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_PERIOD.quarter_num IS 'Quarter number';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_PERIOD.quarter_start_date IS 'Date on which the quarter containing this accounting period starts (dd-MMM-yy)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_PERIOD.is_adjustment_period IS 'Calendar adjustment period flag';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_PERIOD.is_elimination_confirmed IS 'Elimination confirmed flag';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_PERIOD.migration_status_code IS 'Migration status';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_PERIOD.last_update_date IS 'Indicates the date and time of the last update of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_PERIOD.last_updated_by IS 'Indicates the user who last updated the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_PERIOD.creation_date IS 'Indicates the date and time of the creation of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_PERIOD.created_by IS 'Indicates the user who created the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_PERIOD.last_update_login IS 'Indicates the session login associated to the user who last updated the row';
	

----------------------------------------------------------------------------------------------------
COMMENT ON TABLE XXSTN.XXSTN_DTL_ACCOUNTING_REFERENCE IS 'ACCOUNTING_REFERENCE (GL_CODE_COMBINATIONS) stores valid account combinations for each Accounting Segment structure within General Ledger application. Associated with each account are certain codes and flags, including whether the account is enabled, whether detail posting or detail budgeting is allowed, and others. Summary accounts have IS_SUMMARY = ''Y'' and Detail accounts have IS_SUMMARY = ''N''.';
----------------------------------------------------------------------------------------------------
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_REFERENCE.accounting_reference_id IS 'Key combination of Segments (Company, Brand, Product, Account Unit, Cost Center, Intercompany, Business Unit, Future) or other combination, depending on Chart of Accounts setup (CODE_COMBINATION_ID)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_REFERENCE.chart_of_accounts_id IS 'Chart of Accounts';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_REFERENCE.accounting_reference IS 'Segment 1 to 8 concatenated (with padding)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_REFERENCE.segment1 IS 'Key segment';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_REFERENCE.segment2 IS 'Key segment';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_REFERENCE.segment3 IS 'Key segment';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_REFERENCE.segment4 IS 'Key segment';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_REFERENCE.segment5 IS 'Key segment';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_REFERENCE.segment6 IS 'Key segment';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_REFERENCE.segment7 IS 'Key segment';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_REFERENCE.segment8 IS 'Key segment';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_REFERENCE.is_enabled IS 'Enabled flag. If ''N'' disables the Accounting Reference regardless of end_date_active value';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_REFERENCE.start_date_active IS 'Date before which key segment combination is invalid';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_REFERENCE.end_date_active IS 'Date after which key segment combination is invalid';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_REFERENCE.is_summary IS 'Summary account flag ''Y'' for Summary and ''N'' for detail Accounts';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_REFERENCE.account_type IS 'Key segment combination type (''L'' for Liability, ''E'' for Equity, ''O'' for Operating Cost, ''A'' for Asset Management and ''R'' for Revenue)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_REFERENCE.is_control_account IS 'Global control account';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_REFERENCE.is_reconciliation IS 'Reconciliation descriptive segment segment';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_REFERENCE.is_budgeting_allowed IS 'Detail budgeting flag';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_REFERENCE.is_posting_allowed IS 'Detail posting flag';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_REFERENCE.is_budget_enforced IS 'Balance budget enforcement flag';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_REFERENCE.last_update_date IS 'Indicates the date and time of the last update of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_REFERENCE.last_updated_by IS 'Indicates the user who last updated the row';
		

----------------------------------------------------------------------------------------------------
COMMENT ON TABLE XXSTN.XXSTN_DTL_ACCOUNTING_SEGMENT IS 'ACCOUNTING_SEGMENT (FND_ID_FLEX_SEGMENTS) stores setup information about segments, as well as the correspondences between application table columns and the segments the columns are used for. Each row includes an application identifier, the application code, which identifies the segment usage, the structure number (ID_FLEX_NUM), the value set application identifier, the segment number (the segment''s sequence in the flexfield window), the name of the column the segment corresponds to (usually SEGMENTn, where n is an integer). Each row also includes the segment name, whether security is enabled for the segment, whether the segment is required, whether the segment is displayed, whether the segment is enabled (Y or N), display information about the segment such as prompts and display size, and the value set the segment uses.';
----------------------------------------------------------------------------------------------------
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_SEGMENT.segment_id IS 'Accounting Segment value set identifier (FLEX_VALUE_SET_ID)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_SEGMENT.chart_of_accounts_id IS 'Chart of Accounts (ID_FLEX_NUM)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_SEGMENT.segment_num IS 'Segment number of the Accounting Reference structure';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_SEGMENT.segment_column IS 'Segment column name (APPLICATION_COLUMN_NAME)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_SEGMENT.segment_name IS 'Segment name';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_SEGMENT.is_enabled IS 'Flag to indicate if the segment is enabled';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_SEGMENT.is_required IS 'Flag to indicate if a value must be entered for this segment';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_SEGMENT.is_secure IS 'Flag to indicate if security is enabled for the segment';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_SEGMENT.is_displayed IS 'Flag to indicate if the segment should be displayed';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_SEGMENT.display_size IS 'The display size of the segment';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_SEGMENT.last_update_date IS 'Indicates the date and time of the last update of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_SEGMENT.last_updated_by IS 'Indicates the user who last updated the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_SEGMENT.creation_date IS 'Indicates the date and time of the creation of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_SEGMENT.created_by IS 'Indicates the user who created the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNTING_SEGMENT.last_update_login IS 'Indicates the session login associated to the user who last updated the row';
	

----------------------------------------------------------------------------------------------------
COMMENT ON TABLE XXSTN.XXSTN_DTL_ACCOUNT_BALANCE IS 'ACCOUNT_BALANCE (GL_BALANCES) stores actual, budget, and encumbrance balances for detail and summary accounts. This table stores ledger currency, foreign currency, and statistical balances for each accounting period that has ever been opened.  DTL_ACCOUNT_BALANCE stores period activity for an account in the PERIOD_NET_DR and PERIOD_NET_CR columns. The table stores the period beginning balances in BEGIN_BALANCE_DR and BEGIN_BALANCE_CR. An account''s year-to-date balance is calculated as BEGIN_BALANCE_DR - BEGIN_BALANCE_CR + PERIOD_NET_DR - PERIOD_NET_CR. Detail and summary foreign currency balances that are the result of posted foreign currency journal entries have TRANSLATED_FLAG set to ''R'', to indicate that the row is a candidate for revaluation.';
----------------------------------------------------------------------------------------------------
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_BALANCE.accounting_book_id IS 'Accounting Book (LEDGER_ID)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_BALANCE.accounting_reference_id IS 'Key combination of Segments (Company, Brand, Product, Account Unit, Cost Center, Intercompany, Business Unit, Future) or other combination, depending on Chart of Accounts setup (CODE_COMBINATION_ID)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_BALANCE.currency_code IS 'Currency code (ISO 4217 three-letter)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_BALANCE.period_name IS 'Accounting period (MMM-yy)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_BALANCE.period_type IS 'Accounting period type';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_BALANCE.period_year IS 'Accounting period year';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_BALANCE.period_num IS 'Accounting period number is the month number of the year (MM)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_BALANCE.balance_type IS 'Balance type (ACTUAL_FLAG) ''A'' is Actual, ''B'' is Budget, or ''E'' is Encumbrance';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_BALANCE.is_translated IS 'Translated balance flag. ''N'' translation is out of date, ''Y'' is current, ''R'' is a candidate for revaluation. NULL for foreign currency';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_BALANCE.period_net_dr IS 'Period net debit balance';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_BALANCE.period_net_cr IS 'Period net credit balance';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_BALANCE.quarter_to_date_dr IS 'Quarter to date debit balance';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_BALANCE.quarter_to_date_cr IS 'Quarter to date credit balance';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_BALANCE.project_to_date_dr IS 'Accumulated project debit balance (life to date balance)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_BALANCE.project_to_date_cr IS 'Accumulated project credit balance';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_BALANCE.begin_balance_dr IS 'Beginning debit balance';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_BALANCE.begin_balance_cr IS 'Beginning credit balance';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_BALANCE.last_update_date IS 'Indicates the date and time of the last update of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_BALANCE.last_updated_by IS 'Indicates the user who last updated the row';
		

----------------------------------------------------------------------------------------------------
COMMENT ON TABLE XXSTN.XXSTN_DTL_ACCOUNT_UNIT IS 'ACCOUNT_UNIT (FND_FLEX_VALUES) stores valid values for key and descriptive flexfield segments for Account Unit (IFRS Compliance Account Unit). It is one of the Accounting Segment (FND_ID_FLEX_SEGMENTS) that composes the Accounting Reference (GL_CODE_COMBINATIONS) used in Accounting Books (GL_LEDGERS) and Chart of Accounts (FND_ID_FLEX_STRUCTURES). Each row includes the value (FLEX_VALUE) and its hierarchy level if applicable as well as the identifier of the value set the value belongs to. If ENABLED_FLAG contains ''N'', this value is currently invalid, regardless of the start and end dates. If ENABLED_FLAG contains ''Y'', the start and end dates indicate if this value is currently valid. SUMMARY_FLAG indicates if this value is a parent value that has child values.';
----------------------------------------------------------------------------------------------------
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_UNIT.account_unit_id IS 'Account Unit identifier (FLEX_VALUE_ID)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_UNIT.chart_of_accounts_id IS 'Chart of Accounts (ID_FLEX_NUM)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_UNIT.segment_id IS 'Accounting Segment value set identifier (FLEX_VALUE_SET_ID)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_UNIT.segment_num IS 'Segment number of the Accounting Reference structure';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_UNIT.segment_name IS 'Segment name';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_UNIT.category_name IS 'Category name (FLEX_VALUE_SET_NAME)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_UNIT.account_unit IS 'Account Unit segment value (FLEX_VALUE)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_UNIT.account_name_ptb IS 'Account Unit name in PTB Language (DESCRIPTION)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_UNIT.account_name_us IS 'Account Unit name in US Language (DESCRIPTION)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_UNIT.is_enabled IS 'Flag to indicate if the Account Unit is enabled. If ''N'', the Account Unit is currently invalid, regardless of the start and end dates';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_UNIT.start_date_active IS 'The date the Account Unit segment becomes active';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_UNIT.end_date_active IS 'The date the Account Unit segment expires';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_UNIT.is_summary IS 'Flag to indicate if the segment is a parent segment with child segment (when applies)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_UNIT.is_budgeting_allowed IS 'Indicates whether the segment allows budgeting';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_UNIT.is_posting_allowed IS 'Indicates whether the segment allows journal posting';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_UNIT.account_type IS 'Key segment combination type (''L'' for Liability, ''E'' for Equity, ''O'' for Operating Cost, ''A'' for Asset Management and ''R'' for Revenue)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_UNIT.is_third_party_control IS 'Indicates whether the segment is under third party control';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_UNIT.is_reconcile IS 'Indicates whether the segment is for reconciliation';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_UNIT.attribute1 IS 'Descriptive custom attribute for Brand segment (FLEXFIELD)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_UNIT.last_update_date IS 'Indicates the date and time of the last update of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_UNIT.last_updated_by IS 'Indicates the user who last updated the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_UNIT.creation_date IS 'Indicates the date and time of the creation of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_UNIT.created_by IS 'Indicates the user who created the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ACCOUNT_UNIT.last_update_login IS 'Indicates the session login associated to the user who last updated the row';
		

----------------------------------------------------------------------------------------------------
COMMENT ON TABLE XXSTN.XXSTN_DTL_APPLICATION IS 'Applications registered with Oracle Application Object Library.';
----------------------------------------------------------------------------------------------------
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_APPLICATION.application_id IS 'Application identifier';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_APPLICATION.application_short_name IS 'Application short name';    
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_APPLICATION.product_code IS 'Online help base application short name, if help content is shared with another application';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_APPLICATION.application_name_ptb IS 'Application name in PTB Language';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_APPLICATION.application_name_us IS 'Application name in PTB Language';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_APPLICATION.last_update_date IS 'Indicates the date and time of the last update of the row';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_APPLICATION.last_updated_by IS 'Indicates the user who last updated the row';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_APPLICATION.creation_date IS 'Indicates the date and time of the creation of the row';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_APPLICATION.created_by IS 'Indicates the user who created the row';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_APPLICATION.last_update_login IS 'Indicates the session login associated to the user who last updated the row';

----------------------------------------------------------------------------------------------------
COMMENT ON TABLE XXSTN.XXSTN_DTL_APPLICATION_USERS IS 'APPLICATION_USERS (FND_USER) stores information about application users. Each row includes the user''s username. Each row also contains information on when the user last signed on, start and end dates for when a username is valid and the fullname of the user. USER_ID is foreign keys for Standard who columns (LAST_UPDATED_BY, CREATED_BY and LAST_UPDATE_LOGIN).';
----------------------------------------------------------------------------------------------------
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_APPLICATION_USERS.user_id IS 'Application user identifier';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_APPLICATION_USERS.user_name IS 'Application username';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_APPLICATION_USERS.full_name IS 'Application user full name';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_APPLICATION_USERS.start_date IS 'The date the user name becomes active';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_APPLICATION_USERS.end_date IS 'The date the user name becomes inactive';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_APPLICATION_USERS.employee_id IS 'Identifier of employee to whom the application username is assigned';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_APPLICATION_USERS.email_address IS 'The Electronic mail address for the user';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_APPLICATION_USERS.customer_id IS 'Customer contact identifier. If the AOL user is a customer contact, this value is a foreign key to the corresponding customer contact.';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_APPLICATION_USERS.person_party_id IS 'External Identification number (PERSON_PARTY_ID) such as contractor_id';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_APPLICATION_USERS.last_update_date IS 'Indicates the date and time of the last update of the row';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_APPLICATION_USERS.last_updated_by IS 'Indicates the user who last updated the row';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_APPLICATION_USERS.creation_date IS 'Indicates the date and time of the creation of the row';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_APPLICATION_USERS.created_by IS 'Indicates the user who created the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_APPLICATION_USERS.last_update_login IS 'Indicates the session login associated to the user who last updated the row';

----------------------------------------------------------------------------------------------------
COMMENT ON TABLE XXSTN.XXSTN_DTL_BRAND IS 'BRAND (FND_FLEX_VALUES) stores valid values for key and descriptive flexfield segments for Brand. It is one of the Accounting Segment (FND_ID_FLEX_SEGMENTS) that composes the Accounting Reference (GL_CODE_COMBINATIONS) used in Accounting Books (GL_LEDGERS) and Chart of Accounts (FND_ID_FLEX_STRUCTURES). Each row includes the value (FLEX_VALUE) and its hierarchy level if applicable as well as the identifier of the value set the value belongs to. If ENABLED_FLAG contains ''N'', this value is currently invalid, regardless of the start and end dates. If ENABLED_FLAG contains ''Y'', the start and end dates indicate if this value is currently valid. SUMMARY_FLAG indicates if this value is a parent value that has child values.';
----------------------------------------------------------------------------------------------------
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_BRAND.brand_id IS 'Brand identifier (FLEX_VALUE_ID)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_BRAND.chart_of_accounts_id IS 'Chart of Accounts (ID_FLEX_NUM)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_BRAND.segment_id IS 'Accounting Segment value set identifier (FLEX_VALUE_SET_ID)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_BRAND.segment_num IS 'Segment number of the Accounting Reference structure';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_BRAND.segment_name IS 'Segment name';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_BRAND.category_name IS 'Category name (FLEX_VALUE_SET_NAME)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_BRAND.brand_code IS 'Brand segment value (FLEX_VALUE)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_BRAND.brand_name_ptb IS 'Brand name in PTB Language (DESCRIPTION)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_BRAND.brand_name_us IS 'Brand name in US Language (DESCRIPTION)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_BRAND.is_enabled IS 'Flag to indicate if the Brand is enabled. If ''N'', the Brand is currently invalid, regardless of the start and end dates';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_BRAND.start_date_active IS 'The date the Brand segment becomes active';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_BRAND.end_date_active IS 'The date the Brand segment expires';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_BRAND.is_summary IS 'Flag to indicate if the segment is a parent segment with child segment (when applies)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_BRAND.is_budgeting_allowed IS 'Indicates whether the segment allows budgeting';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_BRAND.is_posting_allowed IS 'Indicates whether the segment allows journal posting';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_BRAND.attribute1 IS 'Descriptive custom attribute for Brand segment (FLEXFIELD)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_BRAND.last_update_date IS 'Indicates the date and time of the last update of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_BRAND.last_updated_by IS 'Indicates the user who last updated the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_BRAND.creation_date IS 'Indicates the date and time of the creation of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_BRAND.created_by IS 'Indicates the user who created the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_BRAND.last_update_login IS 'Indicates the session login associated to the user who last updated the row';


		

----------------------------------------------------------------------------------------------------
COMMENT ON TABLE XXSTN.XXSTN_DTL_BUSINESS_UNIT IS 'BUSINESS_UNIT (FND_FLEX_VALUES) stores valid values for key and descriptive flexfield segments for Business Unit. It is one of the Accounting Segment (FND_ID_FLEX_SEGMENTS) that composes the Accounting Reference (GL_CODE_COMBINATIONS) used in Accounting Books (GL_LEDGERS) and Chart of Accounts (FND_ID_FLEX_STRUCTURES). Each row includes the value (FLEX_VALUE) and its hierarchy level if applicable as well as the identifier of the value set the value belongs to. If ENABLED_FLAG contains ''N'', this value is currently invalid, regardless of the start and end dates. If ENABLED_FLAG contains ''Y'', the start and end dates indicate if this value is currently valid. SUMMARY_FLAG indicates if this value is a parent value that has child values.';
----------------------------------------------------------------------------------------------------
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_BUSINESS_UNIT.business_unit_id IS 'Business Unit identifier (FLEX_VALUE_ID)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_BUSINESS_UNIT.chart_of_accounts_id IS 'Chart of Accounts (ID_FLEX_NUM)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_BUSINESS_UNIT.segment_id IS 'Accounting Segment value set identifier (FLEX_VALUE_SET_ID)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_BUSINESS_UNIT.segment_num IS 'Segment number of the Accounting Reference structure';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_BUSINESS_UNIT.segment_name IS 'Segment name';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_BUSINESS_UNIT.category_name IS 'Category name (FLEX_VALUE_SET_NAME)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_BUSINESS_UNIT.business_unit IS 'Business Unit segment value (FLEX_VALUE)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_BUSINESS_UNIT.business_unit_name_ptb IS 'Business Unit name in PTB Language (DESCRIPTION)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_BUSINESS_UNIT.business_unit_name_us IS 'Business Unit name in US Language (DESCRIPTION)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_BUSINESS_UNIT.is_enabled IS 'Flag to indicate if the Business Unit is enabled. If ''N'', the Business Unit is currently invalid, regardless of the start and end dates';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_BUSINESS_UNIT.start_date_active IS 'The date the Business Unit segment becomes active';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_BUSINESS_UNIT.end_date_active IS 'The date the Business Unit segment expires';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_BUSINESS_UNIT.is_summary IS 'Flag to indicate if the segment is a parent segment with child segment (when applies)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_BUSINESS_UNIT.is_budgeting_allowed IS 'Indicates whether the segment allows budgeting';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_BUSINESS_UNIT.is_posting_allowed IS 'Indicates whether the segment allows journal posting';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_BUSINESS_UNIT.last_update_date IS 'Indicates the date and time of the last update of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_BUSINESS_UNIT.last_updated_by IS 'Indicates the user who last updated the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_BUSINESS_UNIT.creation_date IS 'Indicates the date and time of the creation of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_BUSINESS_UNIT.created_by IS 'Indicates the user who created the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_BUSINESS_UNIT.last_update_login IS 'Indicates the session login associated to the user who last updated the row';


		

----------------------------------------------------------------------------------------------------
COMMENT ON TABLE XXSTN.XXSTN_DTL_CHART_OF_ACCOUNTS IS 'CHART_OF_ACCOUNTS (FND_ID_FLEX_STRUCTURES) stores structure information about Chart of Accounts, which contains (Book of Account and Accouting Segments). Each row includes the Application (APPLICATION_CODE and APPLICATION_ID) and the Chart of Accounts (CHART_OF_ACCOUNTS_ID), which together identify the structure, and the name and description of the structure. Each row also includes values that indicate whether the structure is currently frozen, whether rollup groups are frozen (IS_FROZEN_STRUCTURED_HIER), whether users can dynamically insert new combinations of segment values through the pop-up window, and whether should use segment cross-validation rules. Each row also contains information about shorthand name entry for this structure, including whether shorthand entry is enabled, the prompt for the shorthand window, and the length of the shorthand alias field in the shorthand window.';
----------------------------------------------------------------------------------------------------
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_CHART_OF_ACCOUNTS.chart_of_accounts_id IS 'Chart of Accounts (ID_FLEX_NUM)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_CHART_OF_ACCOUNTS.application_id IS 'ERP Application Id';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_CHART_OF_ACCOUNTS.application_code IS 'ERP Module Code (ID_FLEX_CODE)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_CHART_OF_ACCOUNTS.chart_of_accounts_name IS 'Structure name for Chart of Accounts (STRUCTURE_VIEW_NAME)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_CHART_OF_ACCOUNTS.chart_of_accounts_code IS 'Structure developer name for Chart of Accounts (ID_FLEX_STRUCTURE_CODE)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_CHART_OF_ACCOUNTS.is_enabled IS 'Enabled flag. ''Y'' for Valid. ''N'' disables the Chart of Accounts';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_CHART_OF_ACCOUNTS.concatenated_segment_delimiter IS 'The segment delimiter used to separate segments in concatenated segments (Accounting References)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_CHART_OF_ACCOUNTS.is_cross_segment_validation IS 'Flag to indicate whether the segments (Accounting References) should be validated by cross-validation rules';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_CHART_OF_ACCOUNTS.is_dynamic_inserts_allowed IS 'Flag to indicate whether users can insert new segments (Accounting References) dynamically';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_CHART_OF_ACCOUNTS.is_frozen_flex_definition IS 'Flag to indicate if the Chart of Accounts structure is frozen';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_CHART_OF_ACCOUNTS.is_frozen_structured_hierarchy IS 'Flag to indicate if the Chart of Accounts rollup group is frozen. If ''Y'' dynamic insert is OFF';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_CHART_OF_ACCOUNTS.is_shorthand_enabled IS 'Flag to indicate whether shorthand alias is enabled for the structure name';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_CHART_OF_ACCOUNTS.shorthand_length IS 'The display size of the shorthand alias field in the shorthand window';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_CHART_OF_ACCOUNTS.last_update_date IS 'Indicates the date and time of the last update of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_CHART_OF_ACCOUNTS.last_updated_by IS 'Indicates the user who last updated the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_CHART_OF_ACCOUNTS.creation_date IS 'Indicates the date and time of the creation of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_CHART_OF_ACCOUNTS.created_by IS 'Indicates the user who created the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_CHART_OF_ACCOUNTS.last_update_login IS 'Indicates the session login associated to the user who last updated the row';

		

----------------------------------------------------------------------------------------------------
COMMENT ON TABLE XXSTN.XXSTN_DTL_COMPANY IS 'COMPANY (FND_FLEX_VALUES) stores valid values for key and descriptive flexfield segments for Company. It is one of the Accounting Segment (FND_ID_FLEX_SEGMENTS) that composes the Accounting Reference (GL_CODE_COMBINATIONS) used in Accounting Books (GL_LEDGERS) and Chart of Accounts (FND_ID_FLEX_STRUCTURES). Each row includes the value (FLEX_VALUE) and its hierarchy level if applicable as well as the identifier of the value set the value belongs to. If ENABLED_FLAG contains ''N'', this value is currently invalid, regardless of the start and end dates. If ENABLED_FLAG contains ''Y'', the start and end dates indicate if this value is currently valid. SUMMARY_FLAG indicates if this value is a parent value that has child values.';
----------------------------------------------------------------------------------------------------
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COMPANY.company_id IS 'Company identifier (FLEX_VALUE_ID)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COMPANY.chart_of_accounts_id IS 'Chart of Accounts (ID_FLEX_NUM)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COMPANY.segment_id IS 'Accounting Segment value set identifier (FLEX_VALUE_SET_ID)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COMPANY.segment_num IS 'Segment number of the Accounting Reference structure';    
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COMPANY.segment_name IS 'Segment name';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COMPANY.category_name IS 'Category name (FLEX_VALUE_SET_NAME)';    
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COMPANY.company_code IS 'Company segment value (FLEX_VALUE)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COMPANY.company_name_ptb IS 'Company name in PTB Language (DESCRIPTION)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COMPANY.company_name_us IS 'Company name in US Language (DESCRIPTION)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COMPANY.is_enabled IS 'Flag to indicate if the Company is enabled. If ''N'', the Company is currently invalid, regardless of the start and end dates';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COMPANY.start_date_active IS 'The date the Company segment becomes active';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COMPANY.end_date_active IS 'The date the Company segment expires';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COMPANY.is_summary IS 'Flag to indicate if the segment is a parent segment with child segment (when applies)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COMPANY.is_budgeting_allowed IS 'Indicates whether the segment allows budgeting';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COMPANY.is_posting_allowed IS 'Indicates whether the segment allows journal posting';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COMPANY.attribute1 IS 'Descriptive custom attribute for Company segment (FLEXFIELD)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_COMPANY.last_update_date IS 'Indicates the date and time of the last update of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_COMPANY.last_updated_by IS 'Indicates the user who last updated the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_COMPANY.creation_date IS 'Indicates the date and time of the creation of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_COMPANY.created_by IS 'Indicates the user who created the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_COMPANY.last_update_login IS 'Indicates the session login associated to the user who last updated the row';
				

----------------------------------------------------------------------------------------------------
COMMENT ON TABLE XXSTN.XXSTN_DTL_COSIF_ACCOUNT IS 'PRODUCT (FND_FLEX_VALUES) stores valid values for key and descriptive flexfield segments for COSIF Account (COSIF Account maps each IFRS Compliance Account for BACEN Regulatory purposes). It is one of the Accounting Segment (FND_ID_FLEX_SEGMENTS) that composes the Accounting Reference (GL_CODE_COMBINATIONS) used in Accounting Books (GL_LEDGERS) and Chart of Accounts (FND_ID_FLEX_STRUCTURES). Each row includes the value (FLEX_VALUE) and its hierarchy level if applicable as well as the identifier of the value set the value belongs to. If ENABLED_FLAG contains ''N'', this value is currently invalid, regardless of the start and end dates. If ENABLED_FLAG contains ''Y'', the start and end dates indicate if this value is currently valid. SUMMARY_FLAG indicates if this value is a parent value that has child values.';
----------------------------------------------------------------------------------------------------
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COSIF_ACCOUNT.cosif_account_id IS 'COSIF Account identifier (FLEX_VALUE_ID)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COSIF_ACCOUNT.chart_of_accounts_id IS 'COSIF of Accounts (ID_FLEX_NUM)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COSIF_ACCOUNT.segment_id IS 'Accounting Segment value set identifier (FLEX_VALUE_SET_ID)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COSIF_ACCOUNT.segment_num IS 'Segment number of the Accounting Reference structure';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COSIF_ACCOUNT.segment_name IS 'Segment name';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COSIF_ACCOUNT.category_name IS 'Category name (FLEX_VALUE_SET_NAME)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COSIF_ACCOUNT.cosif_account_unit IS 'COSIF Account segment value (FLEX_VALUE)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COSIF_ACCOUNT.cosif_account_name_ptb IS 'COSIF Account name in PTB Language (DESCRIPTION)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COSIF_ACCOUNT.cosif_account_name_us IS 'COSIF Account name in US Language (DESCRIPTION)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COSIF_ACCOUNT.is_enabled IS 'Flag to indicate if the COSIF Account is enabled. If ''N'', the COSIF Account is currently invalid, regardless of the start and end dates';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COSIF_ACCOUNT.start_date_active IS 'The date the COSIF Account segment becomes active';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COSIF_ACCOUNT.end_date_active IS 'The date the COSIF Account segment expires';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COSIF_ACCOUNT.is_summary IS 'Flag to indicate if the segment is a parent segment with child segment (when applies)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COSIF_ACCOUNT.is_budgeting_allowed IS 'Indicates whether the segment allows budgeting';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COSIF_ACCOUNT.is_posting_allowed IS 'Indicates whether the segment allows journal posting';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COSIF_ACCOUNT.account_type IS 'Key segment combination type (''L'' for Liability, ''E'' for Equity, ''O'' for Operating Cost, ''A'' for Asset Management and ''R'' for Revenue)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COSIF_ACCOUNT.is_third_party_control IS 'Indicates whether the segment is under third party control';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COSIF_ACCOUNT.is_reconcile IS 'Indicates whether the segment is for reconciliation';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COSIF_ACCOUNT.attribute1 IS 'Descriptive custom attribute for Brand segment (FLEXFIELD)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_COSIF_ACCOUNT.last_update_date IS 'Indicates the date and time of the last update of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_COSIF_ACCOUNT.last_updated_by IS 'Indicates the user who last updated the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_COSIF_ACCOUNT.creation_date IS 'Indicates the date and time of the creation of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_COSIF_ACCOUNT.created_by IS 'Indicates the user who created the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_COSIF_ACCOUNT.last_update_login IS 'Indicates the session login associated to the user who last updated the row';
	

----------------------------------------------------------------------------------------------------
COMMENT ON TABLE XXSTN.XXSTN_DTL_COST_CENTER IS 'COST_CENTER (FND_FLEX_VALUES) stores valid values for key and descriptive flexfield segments for Cost Center. It is one of the Accounting Segment (FND_ID_FLEX_SEGMENTS) that composes the Accounting Reference (GL_CODE_COMBINATIONS) used in Accounting Books (GL_LEDGERS) and Chart of Accounts (FND_ID_FLEX_STRUCTURES). Each row includes the value (FLEX_VALUE) and its hierarchy level if applicable as well as the identifier of the value set the value belongs to. If ENABLED_FLAG contains ''N'', this value is currently invalid, regardless of the start and end dates. If ENABLED_FLAG contains ''Y'', the start and end dates indicate if this value is currently valid. SUMMARY_FLAG indicates if this value is a parent value that has child values.';
----------------------------------------------------------------------------------------------------
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COST_CENTER.cost_center_id IS 'Cost Center identifier (FLEX_VALUE_ID)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COST_CENTER.chart_of_accounts_id IS 'Chart of Accounts (ID_FLEX_NUM)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COST_CENTER.segment_id IS 'Accounting Segment value set identifier (FLEX_VALUE_SET_ID)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COST_CENTER.segment_num IS 'Segment number of the Accounting Reference structure';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COST_CENTER.segment_name IS 'Segment name';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COST_CENTER.category_name IS 'Category name (FLEX_VALUE_SET_NAME)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COST_CENTER.cost_center IS 'Cost Center segment value (FLEX_VALUE)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COST_CENTER.cost_center_name_ptb IS 'Cost Center name in PTB Language (DESCRIPTION)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COST_CENTER.cost_center_name_us IS 'Cost Center name in US Language (DESCRIPTION)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COST_CENTER.is_enabled IS 'Flag to indicate if the Cost Center is enabled. If ''N'', the Cost Center is currently invalid, regardless of the start and end dates';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COST_CENTER.start_date_active IS 'The date the Cost Center segment becomes active';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COST_CENTER.end_date_active IS 'The date the Cost Center segment expires';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COST_CENTER.is_summary IS 'Flag to indicate if the segment is a parent segment with child segment (when applies)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COST_CENTER.is_budgeting_allowed IS 'Indicates whether the segment allows budgeting';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COST_CENTER.is_posting_allowed IS 'Indicates whether the segment allows journal posting';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_COST_CENTER.attribute1 IS 'Descriptive custom attribute for Brand segment (FLEXFIELD)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_COST_CENTER.last_update_date IS 'Indicates the date and time of the last update of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_COST_CENTER.last_updated_by IS 'Indicates the user who last updated the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_COST_CENTER.creation_date IS 'Indicates the date and time of the creation of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_COST_CENTER.created_by IS 'Indicates the user who created the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_COST_CENTER.last_update_login IS 'Indicates the session login associated to the user who last updated the row';
		

----------------------------------------------------------------------------------------------------
COMMENT ON TABLE XXSTN.XXSTN_DTL_ESTABLISHMENT IS 'ESTABLISHMENT (XLE_REGISTRATIONS) stores the detailed registration information of Legal Entities and Establishments, such as registration number, place of registration, and legal address. (XLE_ENTITY_PROFILES) Party with the classification of Legal Entity and (XLE_ETB_PROFILES) party (HZ_PARTIES) with the classification of Establishment';
----------------------------------------------------------------------------------------------------
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ESTABLISHMENT.establishment_id IS 'Establishment Identifier';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ESTABLISHMENT.legal_entity_id IS 'Legal Entity Identifier. Foreign key to LEGAL_ENTITY (XLE_ENTITY_PROFILES).';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ESTABLISHMENT.main_location_id IS 'Location ID of the Main (Heardquarters) Registered Address. Foreign key to LOCATION (HR_LOCATIONS_ALL).';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ESTABLISHMENT.location_id IS 'Location ID of the Establishment Registered Address. Foreign key to LOCATION (HR_LOCATIONS_ALL).';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ESTABLISHMENT.ibge_code IS 'Municipal location code of the Establishment Registered Address.';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ESTABLISHMENT.country_code IS 'Country or Kingdom. (ISO 3166-1 alpha-2)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ESTABLISHMENT.currency_code IS 'Currency code (ISO 4217 three-letter)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ESTABLISHMENT.entity_status IS 'Party status flag. ''A'' Active, ''I'' Inactive.';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ESTABLISHMENT.company_code IS 'Company segment value (FLEX_VALUE) in (financials_system_params_all)';	
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ESTABLISHMENT.federal_tax_document IS 'Federal registration code used for Legal Entity';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ESTABLISHMENT.main_registration_number IS 'Main Registration number (Headquarters) against Federal TAX regime.';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ESTABLISHMENT.registration_number IS 'Registration number against Federal TAX regime.';	
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ESTABLISHMENT.state_tax_document IS 'State registration code used for Legal Entity';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ESTABLISHMENT.state_registration IS 'Registration number against State TAX regime.';		
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ESTABLISHMENT.municipal_tax_document IS 'Municipal registration code used for Legal Entity';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ESTABLISHMENT.municipal_registration IS 'Registration number against Municipal TAX regime.';		
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ESTABLISHMENT.is_main_establishment IS 'Main Establishment Flag. Legal reporting unit selected by user to be the main legal reporting unit (Headquarters). Indicates whether the Establishment is or had been a headquarters between MAIN_EFFECTIVE_FROM and MAIN_EFFECTIVE_TO dates.';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ESTABLISHMENT.main_effective_from IS 'Main legal reporting unit (Headquarters) effective start date.';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ESTABLISHMENT.main_effective_to IS 'Main legal reporting unit (Headquarters) effective end date.';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ESTABLISHMENT.effective_from IS 'Effective start date of the legal entity.';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ESTABLISHMENT.effective_to IS 'Effective end date of the legal entity.';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ESTABLISHMENT.registered_name IS 'Registered Name';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ESTABLISHMENT.alternate_name IS 'Alternate Registered Name';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ESTABLISHMENT.last_update_date IS 'Indicates the date and time of the last update of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ESTABLISHMENT.last_updated_by IS 'Indicates the user who last updated the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ESTABLISHMENT.creation_date IS 'Indicates the date and time of the creation of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ESTABLISHMENT.created_by IS 'Indicates the user who created the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_ESTABLISHMENT.last_update_login IS 'Indicates the session login associated to the user who last updated the row';

----------------------------------------------------------------------------------------------------
COMMENT ON TABLE XXSTN.XXSTN_DTL_FUTURE IS 'FUTURE (FND_FLEX_VALUES) stores valid values for key and descriptive flexfield segments for Future Use (Reserved). It is one of the Accounting Segment (FND_ID_FLEX_SEGMENTS) that composes the Accounting Reference (GL_CODE_COMBINATIONS) used in Accounting Books (GL_LEDGERS) and Chart of Accounts (FND_ID_FLEX_STRUCTURES). Each row includes the value (FLEX_VALUE) and its hierarchy level if applicable as well as the identifier of the value set the value belongs to. If ENABLED_FLAG contains ''N'', this value is currently invalid, regardless of the start and end dates. If ENABLED_FLAG contains ''Y'', the start and end dates indicate if this value is currently valid. SUMMARY_FLAG indicates if this value is a parent value that has child values.';
----------------------------------------------------------------------------------------------------
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_FUTURE.future_id IS 'Future identifier (FLEX_VALUE_ID)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_FUTURE.chart_of_accounts_id IS 'Chart of Accounts (ID_FLEX_NUM)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_FUTURE.segment_id IS 'Accounting Segment value set identifier (FLEX_VALUE_SET_ID)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_FUTURE.segment_num IS 'Segment number of the Accounting Reference structure';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_FUTURE.segment_name IS 'Segment name';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_FUTURE.category_name IS 'Category name (FLEX_VALUE_SET_NAME)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_FUTURE.future_code IS 'Future segment value (FLEX_VALUE)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_FUTURE.future_name_ptb IS 'Future name in PTB Language (DESCRIPTION)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_FUTURE.future_name_us IS 'Future name in US Language (DESCRIPTION)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_FUTURE.is_enabled IS 'Flag to indicate if the Future is enabled. If ''N'', the Future is currently invalid, regardless of the start and end dates';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_FUTURE.start_date_active IS 'The date the Future segment becomes active';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_FUTURE.end_date_active IS 'The date the Future segment expires';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_FUTURE.is_summary IS 'Flag to indicate if the segment is a parent segment with child segment (when applies)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_FUTURE.is_budgeting_allowed IS 'Indicates whether the segment allows budgeting';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_FUTURE.is_posting_allowed IS 'Indicates whether the segment allows journal posting';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_FUTURE.attribute1 IS 'Descriptive custom attribute for Future segment (FLEXFIELD)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_FUTURE.last_update_date IS 'Indicates the date and time of the last update of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_FUTURE.last_updated_by IS 'Indicates the user who last updated the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_FUTURE.creation_date IS 'Indicates the date and time of the creation of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_FUTURE.created_by IS 'Indicates the user who created the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_FUTURE.last_update_login IS 'Indicates the session login associated to the user who last updated the row';
		

----------------------------------------------------------------------------------------------------
COMMENT ON TABLE XXSTN.XXSTN_DTL_INTERCOMPANY IS 'INTERCOMPANY (FND_FLEX_VALUES) stores valid values for key and descriptive flexfield segments for Intercompany. It is one of the Accounting Segment (FND_ID_FLEX_SEGMENTS) that composes the Accounting Reference (GL_CODE_COMBINATIONS) used in Accounting Books (GL_LEDGERS) and Chart of Accounts (FND_ID_FLEX_STRUCTURES). Each row includes the value (FLEX_VALUE) and its hierarchy level if applicable as well as the identifier of the value set the value belongs to. If ENABLED_FLAG contains ''N'', this value is currently invalid, regardless of the start and end dates. If ENABLED_FLAG contains ''Y'', the start and end dates indicate if this value is currently valid. SUMMARY_FLAG indicates if this value is a parent value that has child values.';
----------------------------------------------------------------------------------------------------
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_INTERCOMPANY.intercompany_id IS 'Intercompany identifier (FLEX_VALUE_ID)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_INTERCOMPANY.chart_of_accounts_id IS 'Chart of Accounts (ID_FLEX_NUM)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_INTERCOMPANY.segment_id IS 'Accounting Segment value set identifier (FLEX_VALUE_SET_ID)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_INTERCOMPANY.segment_num IS 'Segment number of the Accounting Reference structure';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_INTERCOMPANY.segment_name IS 'Segment name';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_INTERCOMPANY.category_name IS 'Category name (FLEX_VALUE_SET_NAME)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_INTERCOMPANY.intercompany_code IS 'Intercompany segment value (FLEX_VALUE)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_INTERCOMPANY.intercompany_name_ptb IS 'Intercompany name in PTB Language (DESCRIPTION)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_INTERCOMPANY.intercompany_name_us IS 'Intercompany name in US Language (DESCRIPTION)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_INTERCOMPANY.is_enabled IS 'Flag to indicate if the Intercompany is enabled. If ''N'', the Intercompany is currently invalid, regardless of the start and end dates';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_INTERCOMPANY.start_date_active IS 'The date the Intercompany segment becomes active';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_INTERCOMPANY.end_date_active IS 'The date the Intercompany segment expires';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_INTERCOMPANY.is_summary IS 'Flag to indicate if the segment is a parent segment with child segment (when applies)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_INTERCOMPANY.is_budgeting_allowed IS 'Indicates whether the segment allows budgeting';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_INTERCOMPANY.is_posting_allowed IS 'Indicates whether the segment allows journal posting';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_INTERCOMPANY.attribute1 IS 'Descriptive custom attribute for Intercompany segment (FLEXFIELD)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_INTERCOMPANY.last_update_date IS 'Indicates the date and time of the last update of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_INTERCOMPANY.last_updated_by IS 'Indicates the user who last updated the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_INTERCOMPANY.creation_date IS 'Indicates the date and time of the creation of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_INTERCOMPANY.created_by IS 'Indicates the user who created the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_INTERCOMPANY.last_update_login IS 'Indicates the session login associated to the user who last updated the row';
		

----------------------------------------------------------------------------------------------------
COMMENT ON TABLE XXSTN.XXSTN_DTL_JOURNAL_BATCH IS 'JOURNAL_BATCH (GL_JE_BATCHES) stores journal entry batches. Each row includes the batch name, description, status, running total debits and credits, and other information. This table corresponds to the Batch window of the Enter Journals form. STATUS is ''U'' for unposted, ''P'' for posted, ''S'' for selected, ''I'' for in the process of being posted. Other values of status indicate an error condition. STATUS_VERIFIED is ''N'' when you create or modify an unposted journal entry batch. The posting program changes STATUS_VERIFIED to ''I'' when posting is in process and ''Y'' after posting is complete.';
----------------------------------------------------------------------------------------------------
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_BATCH.batch_id IS 'Journal entry batch identifier (JE_BATCH_ID)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_BATCH.chart_of_accounts_id IS 'Chart of Accounts (ID_FLEX_NUM)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_BATCH.date_created IS 'Date batch was created (dd-MMM-yy hh:mm:ss)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_BATCH.posted_date IS 'Date batch was posted (dd-MMM-yy hh:mm:ss)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_BATCH.default_period_name IS 'Accounting period for batch (MMM-yy)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_BATCH.default_effective_date IS 'Date within default accounting period (dd-MMM-yy)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_BATCH.earliest_postable_date IS 'Earliest date batch can be posted (dd-MMM-yy hh:mm:ss)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_BATCH.accounted_period_type IS 'Accounting period type (Month, Quarter, Year, Week or Custom)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_BATCH.period_calendar IS 'Accounting calendar name (PERIOD_SET_NAME)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_BATCH.status IS 'Journal entry batch status ''U'' for unposted, ''P'' for posted, ''S'' for selected, ''I'' for in the process of being posted';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_BATCH.status_verified IS 'Batch status verified by posting process ''I'' when in process and ''Y'' after complete';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_BATCH.balance_type IS 'Balance type (ACTUAL_FLAG) ''A'' is Actual, ''B'' is Budget, or ''E'' is Encumbrance';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_BATCH.batch_name IS 'Name of journal entry batch';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_BATCH.batch_description IS 'Journal entry batch description';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_BATCH.is_average_journal IS 'Average journal flag ''N'' is Standard, ''Y'' is Average';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_BATCH.budgetary_control_status IS 'Journal entry batch funds check status ''F'' is Failed, ''I'', In Process, ''N'', N/A, ''P'', Passed, ''R'', Required';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_BATCH.parent_batch_id IS 'Defining column of the parent batch in the source reporting currency ledger (PARENT_JE_BATCH_ID)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_BATCH.approval_status_code IS 'Journal entry batch approval status ''A'' is Approved, ''I'', In Process, ''J'', Rejected, ''R'', Required, ''V'',Validation Failed,''Z'', N/A';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_BATCH.posting_run_id IS 'Posting sequence number';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_BATCH.request_id IS 'Posting concurrent request id';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_BATCH.org_id IS 'Organization defining column';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_BATCH.posted_by IS 'User who posted the journal batch';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_BATCH.group_id IS 'Interface group identifying column';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_BATCH.approver_employee_id IS 'Defining column of the employee who submitted the journal batch for approval';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_BATCH.last_update_date IS 'Indicates the date and time of the last update of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_BATCH.last_updated_by IS 'Indicates the user who last updated the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_BATCH.creation_date IS 'Indicates the date and time of the creation of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_BATCH.created_by IS 'Indicates the user who created the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_BATCH.last_update_login IS 'Indicates the session login associated to the user who last updated the row';
	

----------------------------------------------------------------------------------------------------
COMMENT ON TABLE XXSTN.XXSTN_DTL_JOURNAL_HEADER IS 'JOURNAL_HEADER (GL_JE_HEADERS) stores journal entries. There is a one-to-many relationship between journal entry batches and journal entries. Each row in this table includes the associated batch ID, the journal entry name and description, and other information about the journal entry. This table corresponds to the Journals window of the Enter Journals form. STATUS is ''U'' for unposted and ''P'' for posted. Other statuses indicate that an error condition was found. CONVERSION_FLAG equal to ''N'' indicates that you manually changed a converted amount in the Journal Entry Lines zone of a foreign currency journal entry. In this case, the posting program does not re-convert your foreign amounts. Balancing Company (BALANCING_SEGMENT_VALUE) is null if there is only one balancing segment value in your journal entry.';
----------------------------------------------------------------------------------------------------
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_HEADER.header_id IS 'Journal entry header identifier (JE_HEADER_ID)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_HEADER.accounting_book_id IS 'Accounting Book (LEDGER_ID)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_HEADER.batch_id IS 'Journal entry batch identifier (JE_BATCH_ID)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_HEADER.period_name IS 'Accounting period (MMM-yy)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_HEADER.status IS 'Journal entry header status ''U'' for unposted and ''P'' for posted. Other statuses indicate that an error condition';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_HEADER.currency_code IS 'Currency code (ISO 4217 three-letter)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_HEADER.date_created IS 'Date header created in GL (dd-MMM-yy hh:mm:ss)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_HEADER.posted_date IS 'Date journal entry header was posted (dd-MMM-yy hh:mm:ss)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_HEADER.default_effective_date IS 'Journal entry effective date (dd-MMM-yy)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_HEADER.earliest_postable_date IS 'Earliest date journal entry header can be posted (dd-MMM-yy hh:mm:ss)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_HEADER.category IS 'Journal entry category (Payroll, Intercompany Transfer, Depreciation, Tax, Payments, Purchase Invoices, Adjustment, Reconciled Payments, etc.)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_HEADER.source IS 'Journal entry source (Manual, Payables, Spreadsheet, Receivables, Consolidation, Assets etc.)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_HEADER.header_name IS 'Journal entry header name';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_HEADER.header_description IS 'Journal entry description';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_HEADER.is_accrual_rev IS 'Reversed journal entry flag';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_HEADER.is_multi_bal_seg IS 'Multiple balancing segment flag';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_HEADER.balance_type IS 'Balance type (ACTUAL_FLAG) ''A'' is Actual, ''B'' is Budget, or ''E'' is Encumbrance';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_HEADER.tax_status_code IS 'Journal entry tax status ''N'' is Not Required, ''R'' is Required, ''T'' is Taxed''';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_HEADER.is_conversion IS 'Currency conversion flag';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_HEADER.is_balanced IS 'Balanced journal entry flag';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_HEADER.balancing_company IS 'Key flexfield structure balancing segment value';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_HEADER.accrual_rev_period_name IS 'Reversed journal entry reversal period (MMM-yy)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_HEADER.accrual_rev_status IS 'Reversed journal entry status ''M'' is Marked for Reversal, ''N'' is Not Reversed, ''R'' is Reversed, ''U'' is Unreversable';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_HEADER.accrual_rev_header_id IS 'Reversed journal entry defining column';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_HEADER.is_accrual_rev_change_sign IS 'Type of reversal ''Y'' for Change Sign or ''N'' for Switch DR/CR';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_HEADER.parent_header_id IS 'Defining column of the parent journal entry in the source primary ledger';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_HEADER.reversed_header_id IS 'Defining column of the journal entry that is reversed by this journal entry';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_HEADER.is_from_sla IS 'Journal propagated from subledger flag';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_HEADER.last_update_date IS 'Indicates the date and time of the last update of the row';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_HEADER.last_updated_by IS 'Indicates the user who last updated the row';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_HEADER.creation_date IS 'Indicates the date and time of the creation of the row';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_HEADER.created_by IS 'Indicates the user who created the row';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_HEADER.last_update_login IS 'Indicates the session login associated to the user who last updated the row';
		

----------------------------------------------------------------------------------------------------
COMMENT ON TABLE XXSTN.XXSTN_DTL_JOURNAL_LINES IS 'JOURNAL_LINES (GL_JE_LINES) stores the journal entry lines that you enter in the Enter Journals form. There is a one-to-many relationship between journal entries and journal entry lines. Each row in this table stores the associated journal entry header ID, the line number, the associated Accounting Reference (CODE_COMBINATION_ID), and the debits or credits associated with the journal line. STATUS is ''U'' for unposted or ''P'' for posted.';
----------------------------------------------------------------------------------------------------
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_LINES.line_id IS 'Journal entry identifier (JE_HEADER_ID + JE_LINE_NUM)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_LINES.header_id IS 'Journal entry header reference (JE_HEADER_ID)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_LINES.line_num IS 'Journal entry line number (JE_LINE_NUM)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_LINES.accounting_book_id IS 'Accounting Book (LEDGER_ID)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_LINES.accounting_reference_id IS 'Key combination of Segments (Company, Brand, Product, Account Unit, Cost Center, Intercompany, Business Unit, Future) or other combination, depending on Chart of Accounts setup (CODE_COMBINATION_ID)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_LINES.period_name IS 'Accounting period name (MMM-yy)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_LINES.effective_date IS 'Journal entry line effective date (dd-MMM-yy)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_LINES.status IS 'Journal entry line status ''U'' for unposted or ''P'' for posted.';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_LINES.entered_dr IS 'Journal entry line debit amount in entered currency';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_LINES.entered_cr IS 'Journal entry line credit amount in entered currency';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_LINES.accounted_dr IS 'Journal entry line debit amount in base currency';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_LINES.accounted_cr IS 'Journal entry line credit amount in base currency';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_LINES.line_description IS 'Journal entry line description';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_LINES.line_type_code IS 'Line type (Suspense, Rounding, Inter)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_LINES.reference_1 IS 'Journal entry external reference (depends on entry module AP, AR, PO...)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_LINES.reference_2 IS 'Journal entry external reference (depends on entry module AP, AR, PO...)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_LINES.reference_5 IS 'Journal entry external reference (depends on entry module AP, AR, PO...)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_LINES.reference_3 IS 'Journal entry external reference (depends on entry module AP, AR, PO...)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_LINES.reference_6 IS 'Journal entry external reference (depends on entry module AP, AR, PO...)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_LINES.reference_4 IS 'Journal entry external reference (depends on entry module AP, AR, PO...)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_LINES.reference_7 IS 'Journal entry external reference (depends on entry module AP, AR, PO...)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_LINES.reference_8 IS 'Journal entry external reference (depends on entry module AP, AR, PO...)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_LINES.reference_9 IS 'Journal entry external reference (depends on entry module AP, AR, PO...)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_LINES.reference_10 IS 'Journal entry external reference (depends on entry module AP, AR, PO...)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_LINES.context2 IS 'Descriptive flexfield context column';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_LINES.no1 IS 'Value added tax descriptive flexfield column';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_LINES.ignore_rate IS 'Modify amounts if exchange rate changes';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_LINES.last_update_date IS 'Indicates the date and time of the last update of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_LINES.last_updated_by IS 'Indicates the user who last updated the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_LINES.creation_date IS 'Indicates the date and time of the creation of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_LINES.created_by IS 'Indicates the user who created the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_JOURNAL_LINES.last_update_login IS 'Indicates the session login associated to the user who last updated the row';
   

----------------------------------------------------------------------------------------------------
COMMENT ON TABLE XXSTN.XXSTN_DTL_LEGAL_ENTITY IS 'LEGAL_ENTITY (XLE_REGISTRATIONS) stores the detailed registration information of Legal Entities and Establishments, such as registration number, place of registration, and legal address. (XLE_ENTITY_PROFILES) Party with the classification of Legal Entity.';
----------------------------------------------------------------------------------------------------
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_LEGAL_ENTITY.legal_entity_id IS 'Main Legal Entity Identifier (Headquarters).';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_LEGAL_ENTITY.main_establishment_id IS 'Main Establishment Identifier (Headquarters). Foreign key to ESTABLISHMENT (XLE_ETB_PROFILES).';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_LEGAL_ENTITY.main_location_id IS 'Location ID of the Main (Headquarters) Registered Address. Foreign key to LOCATION (HR_LOCATIONS_ALL).';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_LEGAL_ENTITY.ibge_code IS 'Municipal location code of the Main (Headquarters) Registered Address.';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_LEGAL_ENTITY.country_code IS 'Country or Kingdom. (ISO 3166-1 alpha-2)';	
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_LEGAL_ENTITY.currency_code IS 'Currency code (ISO 4217 three-letter)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_LEGAL_ENTITY.entity_status IS 'Party status flag. ''A'' Active, ''I'' Inactive.';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_LEGAL_ENTITY.company_code IS 'Company segment value (FLEX_VALUE) in (financials_system_params_all)';	
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_LEGAL_ENTITY.federal_tax_document IS 'Federal registration code used for Legal Entity';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_LEGAL_ENTITY.main_registration_number IS 'Main Registration number (Headquarters) against Federal TAX regime.';	
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_LEGAL_ENTITY.registered_name IS 'Registered Name';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_LEGAL_ENTITY.alternate_name IS 'Alternate Registered Name';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_LEGAL_ENTITY.last_update_date IS 'Indicates the date and time of the last update of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_LEGAL_ENTITY.last_updated_by IS 'Indicates the user who last updated the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_LEGAL_ENTITY.creation_date IS 'Indicates the date and time of the creation of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_LEGAL_ENTITY.created_by IS 'Indicates the user who created the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_LEGAL_ENTITY.last_update_login IS 'Indicates the session login associated to the user who last updated the row';

----------------------------------------------------------------------------------------------------
COMMENT ON TABLE XXSTN.XXSTN_DTL_LOCATION IS 'LOCATION (HR_LOCATIONS_ALL and FND_TERRITORIES) holds location and territory information for business units, legal entities and establishments.';
----------------------------------------------------------------------------------------------------
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_LOCATION.location_id IS 'Location ID of the Registered Address';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_LOCATION.location_code IS 'Location Name of the Registered Address';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_LOCATION.country_code IS 'Country or Kingdom. (ISO 3166-1 alpha-2)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_LOCATION.iso_territory_code IS 'Country or Kingdom. (ISO 3166-1 alpha-3)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_LOCATION.territory_name_ptb IS 'Territory name in PTB Language. (ISO 3166-1)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_LOCATION.territory_name_us IS 'Territory name in US Language. (ISO 3166-1)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_LOCATION.state_region IS 'State, Region or Province. (ISO 3166-2:BR)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_LOCATION.city_town IS 'City, Town or District name.';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_LOCATION.street_address IS '1st line of location address. Street address, P.O. box, company name, c/o.';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_LOCATION.street_number IS 'Street number.';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_LOCATION.address_line2 IS '2nd line of location address. Apartment, suite, unit, building, floor, etc.';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_LOCATION.neighborhood IS 'Neighbourhood, Village or Area.';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_LOCATION.postal_code IS 'Postal code.';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_LOCATION.last_update_date IS 'Indicates the date and time of the last update of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_LOCATION.last_updated_by IS 'Indicates the user who last updated the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_LOCATION.creation_date IS 'Indicates the date and time of the creation of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_LOCATION.created_by IS 'Indicates the user who created the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_LOCATION.last_update_login IS 'Indicates the session login associated to the user who last updated the row';

----------------------------------------------------------------------------------------------------
COMMENT ON TABLE XXSTN.XXSTN_DTL_ORGANIZATION_UNIT IS 'ORGANIZATION_UNIT (HR_ALL_ORGANIZATION_UNITS and HR_ORGANIZATION_INFORMATION) holds the definitions that identify business
groups and the organization units within a single business group.';
----------------------------------------------------------------------------------------------------
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_ORGANIZATION_UNIT.organization_id IS 'Organization Identifier.';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_ORGANIZATION_UNIT.location_id IS 'Foreign key to HR_LOCATIONS. Default work site location for all assignments to this organization.';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_ORGANIZATION_UNIT.accounting_book_id IS 'Accounting Book (LEDGER_ID)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_ORGANIZATION_UNIT.legal_entity_id IS 'Main Legal Entity Identifier (Headquarters).';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_ORGANIZATION_UNIT.company_code IS 'Company segment value (FLEX_VALUE) in (financials_system_params_all)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_ORGANIZATION_UNIT.organization_name_ptb IS 'Name of the organization in PTB Language (HR_ALL_ORGANIZATION_UNITS_TL)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_ORGANIZATION_UNIT.organization_name_us IS 'Name of the organization in US Language (HR_ALL_ORGANIZATION_UNITS_TL)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_ORGANIZATION_UNIT.organization_code IS 'Short name of the organization (SHORT_CODE)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_ORGANIZATION_UNIT.date_from IS 'Start date of the organization.';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_ORGANIZATION_UNIT.date_to IS 'End date of the organization.';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_ORGANIZATION_UNIT.last_update_date IS 'Indicates the date and time of the last update of the row';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_ORGANIZATION_UNIT.last_updated_by IS 'Indicates the user who last updated the row';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_ORGANIZATION_UNIT.creation_date IS 'Indicates the date and time of the creation of the row';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_ORGANIZATION_UNIT.created_by IS 'Indicates the user who created the row';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_ORGANIZATION_UNIT.last_update_login IS 'Indicates the session login associated to the user who last updated the row';


----------------------------------------------------------------------------------------------------
COMMENT ON TABLE XXSTN.XXSTN_DTL_PERIOD_TYPE IS 'PERIOD_TYPE (GL_PERIOD_TYPES) stores the period types you define using the Period Types form. Each row includes the period type name, the number of periods per fiscal year, and other information. YEAR_TYPE_IN_NAME is "C" for calendar or "F" for fiscal of the accounting period in the Accounting Calendar form.';
----------------------------------------------------------------------------------------------------
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_PERIOD_TYPE.period_type_id IS 'Period type Id - Internal use only';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_PERIOD_TYPE.period_type IS 'Accounting period type Id';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_PERIOD_TYPE.period_type_name IS 'Calendar period type user defined name';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_PERIOD_TYPE.period_type_description IS 'Accounting period type description';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_PERIOD_TYPE.number_per_fiscal_year IS 'Number of periods per fiscal year';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_PERIOD_TYPE.year_type_in_name IS 'Year type (Calendar or Fiscal)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_PERIOD_TYPE.last_update_date IS 'Indicates the date and time of the last update of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_PERIOD_TYPE.last_updated_by IS 'Indicates the user who last updated the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_PERIOD_TYPE.creation_date IS 'Indicates the date and time of the creation of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_PERIOD_TYPE.created_by IS 'Indicates the user who created the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_PERIOD_TYPE.last_update_login IS 'Indicates the session login associated to the user who last updated the row';
	

----------------------------------------------------------------------------------------------------
COMMENT ON TABLE XXSTN.XXSTN_DTL_PRODUCT IS 'PRODUCT (FND_FLEX_VALUES) stores valid values for key and descriptive flexfield segments for Product. It is one of the Accounting Segment (FND_ID_FLEX_SEGMENTS) that composes the Accounting Reference (GL_CODE_COMBINATIONS) used in Accounting Books (GL_LEDGERS) and Chart of Accounts (FND_ID_FLEX_STRUCTURES). Each row includes the value (FLEX_VALUE) and its hierarchy level if applicable as well as the identifier of the value set the value belongs to. If ENABLED_FLAG contains ''N'', this value is currently invalid, regardless of the start and end dates. If ENABLED_FLAG contains ''Y'', the start and end dates indicate if this value is currently valid. SUMMARY_FLAG indicates if this value is a parent value that has child values.';
----------------------------------------------------------------------------------------------------
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_PRODUCT.product_id IS 'Product identifier (FLEX_VALUE_ID)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_PRODUCT.chart_of_accounts_id IS 'Chart of Accounts (ID_FLEX_NUM)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_PRODUCT.segment_id IS 'Accounting Segment value set identifier (FLEX_VALUE_SET_ID)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_PRODUCT.segment_num IS 'Segment number of the Accounting Reference structure';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_PRODUCT.segment_name IS 'Segment name';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_PRODUCT.category_name IS 'Category name (FLEX_VALUE_SET_NAME)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_PRODUCT.product_code IS 'Product segment value (FLEX_VALUE)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_PRODUCT.product_name_ptb IS 'Product name in PTB Language (DESCRIPTION)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_PRODUCT.product_name_us IS 'Product name in US Language (DESCRIPTION)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_PRODUCT.is_enabled IS 'Flag to indicate if the Product is enabled. If ''N'', the Product is currently invalid, regardless of the start and end dates';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_PRODUCT.start_date_active IS 'The date the Product segment becomes active';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_PRODUCT.end_date_active IS 'The date the Product segment expires';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_PRODUCT.is_summary IS 'Flag to indicate if the segment is a parent segment with child segment (when applies)';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_PRODUCT.is_budgeting_allowed IS 'Indicates whether the segment allows budgeting';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_PRODUCT.is_posting_allowed IS 'Indicates whether the segment allows journal posting';
    COMMENT ON COLUMN XXSTN.XXSTN_DTL_PRODUCT.attribute1 IS 'Descriptive custom attribute for Brand segment (FLEXFIELD)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_PRODUCT.last_update_date IS 'Indicates the date and time of the last update of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_PRODUCT.last_updated_by IS 'Indicates the user who last updated the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_PRODUCT.creation_date IS 'Indicates the date and time of the creation of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_PRODUCT.created_by IS 'Indicates the user who created the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_PRODUCT.last_update_login IS 'Indicates the session login associated to the user who last updated the row';
	

----------------------------------------------------------------------------------------------------
COMMENT ON TABLE XXSTN.XXSTN_DTL_SEGMENT_CATEGORY IS 'SEGMENT_CATEGORY (FND_FLEX_VALUE_SETS) stores information about the value sets used by both key and descriptive Segments of Accounting References (GL_CODE_COMBINATIONS). Each row includes the name and description of the value set, the data format type, the maximum and minimum values and precision for number format type value set. Each row also contains flags that determine what size values can be in this value set, and whether the security feature are enabled for this value set. NUMERIC_MODE_ENABLED_FLAG indicates whether the value should right-justify and zero-fill values that contain only the characters 0 through 9; it does not indicate that values in this value set are of type NUMBER. MAXIMUM_VALUE and MINIMUM_VALUE together do range checks on values.';
----------------------------------------------------------------------------------------------------
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_SEGMENT_CATEGORY.segment_id IS 'Accounting Category value set identifier for Segments (FLEX_VALUE_SET_ID)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_SEGMENT_CATEGORY.category_name IS 'Category name (FLEX_VALUE_SET_NAME)';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_SEGMENT_CATEGORY.category_description IS 'Category description';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_SEGMENT_CATEGORY.is_protected IS 'Flag to indicate if this is a protected value set';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_SEGMENT_CATEGORY.is_security_enabled IS 'Flag to indicate whether the flexfield security rules for the value set are enabled';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_SEGMENT_CATEGORY.format_type IS 'Format type';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_SEGMENT_CATEGORY.maximum_size IS 'The maximum size of values in the value set';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_SEGMENT_CATEGORY.is_alphanumeric_allowed IS 'Flag to indicate whether values with alphanumeric characters can be in the value set';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_SEGMENT_CATEGORY.is_uppercase_only IS 'Flag to indicate if all the values in the value set should all be in uppercase';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_SEGMENT_CATEGORY.is_numeric_mode_enabled IS 'Flag to indicate if Oracle Application Object Library should right-justify and zero-fill values for segments that use the value set';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_SEGMENT_CATEGORY.minimum_value IS 'Minimum value';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_SEGMENT_CATEGORY.maximum_value IS 'Maximum value';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_SEGMENT_CATEGORY.number_precision IS 'Precision';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_SEGMENT_CATEGORY.last_update_date IS 'Indicates the date and time of the last update of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_SEGMENT_CATEGORY.last_updated_by IS 'Indicates the user who last updated the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_SEGMENT_CATEGORY.creation_date IS 'Indicates the date and time of the creation of the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_SEGMENT_CATEGORY.created_by IS 'Indicates the user who created the row';
	COMMENT ON COLUMN XXSTN.XXSTN_DTL_SEGMENT_CATEGORY.last_update_login IS 'Indicates the session login associated to the user who last updated the row';
		

