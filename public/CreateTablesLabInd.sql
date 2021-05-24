/*
   Tabelas AutoLab Industrial
   Desenvolvido por MRI Tecnologia Eletrônica
   Versão para Oracle Server
   Desenvolvedor: Junio Cesar Ferreira
   ATENÇÃO: Antes de executar este script deve ser executado o script CreateTablesMRI.sql
   Alterações:
   Migração: 05/08/2020
   25/08/2020 Junio: Modificou os tipos de dados de ID_TREE e FAMILY_LINE em ANALYSES_LABIND
   25/08/2020 Junio: Modificou tipos em GENERAL_SETTINGS_LABIND e adicionou insert de config 'TimeToChangeEvents'
   27/08/2020 Junio: Modificou tipos em GENERAL_SETTINGS_LABIND e adicionou insert de config 'PropertiesAnalysisEditEnable'
   27/08/2020 Junio: Modificou tipos em GENERAL_SETTINGS_LABIND e adicionou insert de config 'FrequencyEditEnable'
   03/09/2020 Junio: Modificou todos tipos CLOB para VARCHAR
*/
CREATE TABLE USER_ACCESS_LABIND
(
    IDENTIFIER INTEGER       NOT NULL,
	COMPANY	   INTEGER       NOT NULL,
    NAME       VARCHAR(32)   NOT NULL,
    HASH       VARCHAR(64)   NOT NULL,
	PROPERTIES VARCHAR(2048) NOT NULL,
	CANCELED   CHAR(1) DEFAULT 'N' NOT NULL,
	PRIMARY KEY(IDENTIFIER, COMPANY)
);
INSERT INTO USER_ACCESS_LABIND (IDENTIFIER, COMPANY, NAME, HASH, PROPERTIES)
VALUES (0, 0, 'MRI', '98B0AFCC11ADBB11BDFB5C4BD3F23D759D8E7AC9CE8B4D7645EE08161C4BB8F0', '54CwBGDDxxBECCxx2DgDbBfBEFmaLjm7smb$nLFWTiiHTXx6MpD5Y546Qhg=');

CREATE TABLE AD_ACCESS_LABIND
(
	AD_GROUP   VARCHAR(2048)    NOT NULL,
	COMPANY	   INTEGER 			NOT NULL,
	PROPERTIES VARCHAR(2048)    NOT NULL,
	CANCELED   CHAR(1) DEFAULT 'N' NOT NULL
);

CREATE TABLE GENERAL_SETTINGS_LABIND
(
    SOFTWARE_MOD  VARCHAR(128) NOT NULL,
	SETTING_NAME  VARCHAR(32)  NOT NULL,
	COMPANY       INTEGER      NOT NULL,
	SETTING_DESC  VARCHAR(128) NOT NULL,
	SETTING_TYPE  VARCHAR(32)  NOT NULL,
	SETTING_VALUE VARCHAR(32)  NOT NULL,
	PRIMARY KEY (SOFTWARE_MOD, SETTING_NAME, COMPANY)
);
INSERT INTO GENERAL_SETTINGS_LABIND (SOFTWARE_MOD, SETTING_NAME, COMPANY, SETTING_DESC, SETTING_TYPE, SETTING_VALUE) 
VALUES ('PreCadastro','Screen3',0,'0 para uso regular da tela 3, 1 para uso direto como adicionar novo evento','int','0');
INSERT INTO GENERAL_SETTINGS_LABIND (SOFTWARE_MOD, SETTING_NAME, COMPANY, SETTING_DESC, SETTING_TYPE, SETTING_VALUE) 
VALUES ('PreCadastro','RequiredAllegation',0,'True para obrigar a adicionar justificativa em eventos novos','bool','False');
INSERT INTO GENERAL_SETTINGS_LABIND (SOFTWARE_MOD, SETTING_NAME, COMPANY, SETTING_DESC, SETTING_TYPE, SETTING_VALUE) 
VALUES ('PreCadastro','RequiredIdAnalyst',0, 'True para obrigar a adicionar ID de analista ao precadastrar','bool','False');
INSERT INTO GENERAL_SETTINGS_LABIND (SOFTWARE_MOD, SETTING_NAME, COMPANY, SETTING_DESC, SETTING_TYPE, SETTING_VALUE) 
VALUES ('PreCadastro/WSTRD','EventMode',0,'0 uso de ponto de controle, 1 uso de plano de amostragem pré-definido','int','1');
INSERT INTO GENERAL_SETTINGS_LABIND (SOFTWARE_MOD, SETTING_NAME, COMPANY, SETTING_DESC, SETTING_TYPE, SETTING_VALUE) 
VALUES ('AnalysesManager','RequiredAllegation',0,'True para obrigar a adicionar justificativa ao editar valor de análises','bool','False');
INSERT INTO GENERAL_SETTINGS_LABIND (SOFTWARE_MOD, SETTING_NAME, COMPANY, SETTING_DESC, SETTING_TYPE, SETTING_VALUE) 
VALUES ('AnalysesManager','RequiredIdAnalyst',0,'True para obrigar a adicionar ID de analista ao habilitar digitação','bool','True');
INSERT INTO GENERAL_SETTINGS_LABIND (SOFTWARE_MOD, SETTING_NAME, COMPANY, SETTING_DESC, SETTING_TYPE, SETTING_VALUE) 
VALUES ('PreCadastro/WSTRD/AnalysesManager','TimeToChangeEvents',0,'Horário de virada do dia da usina','string','00:00:00');
INSERT INTO GENERAL_SETTINGS_LABIND (SOFTWARE_MOD, SETTING_NAME, COMPANY, SETTING_DESC, SETTING_TYPE, SETTING_VALUE) 
VALUES ('LabPlan','PropertiesAnalysisEditEnable',0,'Habilita edição de parâtros da análise','bool','True');
INSERT INTO GENERAL_SETTINGS_LABIND (SOFTWARE_MOD, SETTING_NAME, COMPANY, SETTING_DESC, SETTING_TYPE, SETTING_VALUE) 
VALUES ('LabPlan','FrequencyEditEnable',0,'Habilita edição de frequencia analítica','bool','False');

CREATE TABLE ERP_TREE_LABIND
(
	IDENTIFIER  VARCHAR(128)  NOT NULL,
	FAMILY_LINE VARCHAR(2048) NOT NULL,
	COMPANY     INTEGER       NOT NULL,
	TEXT_TREE   VARCHAR(2048) NOT NULL,
	VISIBLE     VARCHAR(5) DEFAULT 'True' NOT NULL,
	PRIMARY KEY (IDENTIFIER, FAMILY_LINE, COMPANY)
);

CREATE TABLE ANALYSES_LABIND
(
	ID_INTEGRA  VARCHAR(128)  NOT NULL,
	COMPANY     INTEGER       NOT NULL,
	TEXT_NAME   VARCHAR(2048) NOT NULL,
	NICK_NAME   VARCHAR(2048) NOT NULL,
	ID_TREE     INTEGER       NOT NULL,
	ID_FATHER   VARCHAR(128)  NOT NULL,
	FAMILY_LINE VARCHAR(2048) NOT NULL,
	MAX_VALUE   NUMBER(10,5)  DEFAULT 100,
	MIN_VALUE   NUMBER(10,5)  DEFAULT 0.1,
	MAX_BLOCK   NUMBER(10,5)  DEFAULT 1000,
	MIN_BLOCK   NUMBER(10,5)  DEFAULT 0,
	TYPE_VALUE  VARCHAR(16),
	SELECTION   VARCHAR(2048),
	FREQUENCY   VARCHAR(2048),
	CANCELED    CHAR(1)     DEFAULT 'N' NOT NULL,
	PRIMARY KEY (ID_INTEGRA, COMPANY),
	CONSTRAINT   FK_PARENT_TREE_ERP
                 FOREIGN KEY  (ID_FATHER, FAMILY_LINE, COMPANY)
				 REFERENCES   ERP_TREE_LABIND(IDENTIFIER, FAMILY_LINE, COMPANY)
);

CREATE TABLE ANALYSES_GROUPS_LABIND
(
	IDENTIFIER INTEGER       NOT NULL,
	COMPANY    INTEGER       NOT NULL,
	TEXT_NAME  VARCHAR(2048) NOT NULL,
	METHOD     INTEGER       NOT NULL,
	PRIMARY KEY (IDENTIFIER, COMPANY)
);

CREATE TABLE BONDS_ANALYSES_GROUPS_LABIND
(
    INDEXER    INTEGER  NOT NULL,
	ID_PARENT  INTEGER  NOT NULL,
	COMPANY    INTEGER  NOT NULL,
	ID_CHILD   VARCHAR(128) NOT NULL,
	PRIMARY KEY (ID_PARENT, ID_CHILD),
	CONSTRAINT   FK_ID_PARENT_GROUP
                 FOREIGN KEY  (ID_PARENT,COMPANY)
				 REFERENCES   ANALYSES_GROUPS_LABIND(IDENTIFIER,COMPANY),
	CONSTRAINT   FK_ID_CHILD_ANALYSIS
                 FOREIGN KEY  (ID_CHILD, COMPANY)
				 REFERENCES   ANALYSES_LABIND(ID_INTEGRA, COMPANY)
);

CREATE TABLE GROUPS_LABIND
(
	IDENTIFIER INTEGER     NOT NULL,
	COMPANY    INTEGER     NOT NULL,
	TEXT_DESCR VARCHAR(64) NOT NULL,
	CANCELED   CHAR(1)     DEFAULT 'N' NOT NULL,
	PRIMARY KEY (IDENTIFIER, COMPANY)
);

CREATE TABLE OBJECTS_LABIND
(
	IDENTIFIER INTEGER     NOT NULL,
	COMPANY    INTEGER     NOT NULL,
	TEXT_DESCR VARCHAR(64) NOT NULL,
	NICK_NAME  VARCHAR(12) NOT NULL,
	IDF_FATHER INTEGER     NOT NULL,
	CANCELED   CHAR(1)     DEFAULT 'N' NOT NULL,
	PRIMARY KEY (IDENTIFIER, COMPANY),
	
	CONSTRAINT   FK_ID_GROUP_OBJECT
                 FOREIGN KEY  (IDF_FATHER, COMPANY)
				 REFERENCES   GROUPS_LABIND(IDENTIFIER, COMPANY)
);

CREATE TABLE ATTRIBUTES_LABIND
(
	IDENTIFIER  INTEGER  NOT NULL,
	COMPANY     INTEGER  NOT NULL,
	IDF_FATHER  INTEGER  NOT NULL,
	ID_INTEGRA  VARCHAR(128),
	CANCELED    CHAR(1)     DEFAULT 'N' NOT NULL,
	PRIMARY KEY (IDENTIFIER, COMPANY),
	
	CONSTRAINT   FK_ID_OBJECT_ATTRIBUTE
                 FOREIGN KEY  (IDF_FATHER, COMPANY)
				 REFERENCES   OBJECTS_LABIND(IDENTIFIER, COMPANY),
	CONSTRAINT   FK_ID_INTEGRA_ANALYSIS
                 FOREIGN KEY  (ID_INTEGRA, COMPANY)
				 REFERENCES   ANALYSES_LABIND(ID_INTEGRA, COMPANY)																 
);

CREATE TABLE TALKING_CODES_LABIND
(
	TALKING_CODE INTEGER     NOT NULL,
	COMPANY      INTEGER     NOT NULL,
	ID_GROUP     INTEGER     NOT NULL,
	ID_OBJECT    INTEGER     NOT NULL,
	CANCELED     CHAR(1) DEFAULT 'N' NOT NULL,
	PRIMARY KEY (TALKING_CODE, COMPANY),
	CONSTRAINT   FK_ID_OBJECT_TALKING
                 FOREIGN KEY  (ID_OBJECT, COMPANY)
				 REFERENCES   OBJECTS_LABIND(IDENTIFIER, COMPANY),
	CONSTRAINT   FK_ID_GROUP_TALKING
                 FOREIGN KEY  (ID_GROUP, COMPANY)
				 REFERENCES   GROUPS_LABIND(IDENTIFIER, COMPANY)
);

CREATE TABLE PRECAD_LABIND
(
    IDENTIFIER   VARCHAR(32) NOT NULL,
	COMPANY      INTEGER     NOT NULL,
	CODE_PRECAD  INTEGER     NOT NULL,
	ID_GROUP     INTEGER     NOT NULL,
	ID_OBJECT    INTEGER     NOT NULL,
	ID_ATTRIBUTE INTEGER     NOT NULL,
	ID_EVENT     VARCHAR(64),
	ID_INTEGRA   VARCHAR(128),
	DATE_PRECAD  DATE,
    DATE_EVENT   DATE,
	EVENT        VARCHAR(8),
	ID_ANALYST   VARCHAR(32),
	COMPLETED    CHAR(1) DEFAULT 'N' NOT NULL,
	CANCELED     CHAR(1) DEFAULT 'N' NOT NULL,
	CONSTRAINT   FK_ID_GROUP_PRECAD
                 FOREIGN KEY  (ID_GROUP, COMPANY)
				 REFERENCES   GROUPS_LABIND(IDENTIFIER, COMPANY),
	CONSTRAINT   FK_ID_OBJECT_PRECAD
                 FOREIGN KEY  (ID_OBJECT, COMPANY)
				 REFERENCES   OBJECTS_LABIND(IDENTIFIER, COMPANY),
	CONSTRAINT   FK_ID_ATTRIBUTE_PRECAD
                 FOREIGN KEY  (ID_ATTRIBUTE, COMPANY)
				 REFERENCES   ATTRIBUTES_LABIND(IDENTIFIER, COMPANY)
);

CREATE TABLE EVENTS_CONTROL_LABIND
(
	ID_EVENT    VARCHAR(64) NOT NULL,
	COMPANY     INTEGER     NOT NULL,
	EVENT       VARCHAR(8)  NOT NULL,
	ID_INTEGRA  VARCHAR(128),
	DATE_EVENT  DATE,
	COMPLETED   CHAR(1)     DEFAULT 'N' NOT NULL,
	CANCELED    CHAR(1)     DEFAULT 'N' NOT NULL,
	CONSTRAINT   FK_ID_INTEGRA_EVENTS
                 FOREIGN KEY  (ID_INTEGRA, COMPANY)
				 REFERENCES   ANALYSES_LABIND(ID_INTEGRA, COMPANY)
);

CREATE TABLE ALLEGATION_LABIND
(
	IDENTIFIER   INTEGER      NOT NULL,
	COMPANY      INTEGER      NOT NULL,
	TEXT_DESCR   VARCHAR(2048),
	CANCELED     CHAR(1)  DEFAULT 'N' NOT NULL,
	PRIMARY KEY (IDENTIFIER, COMPANY)
);

CREATE TABLE ANALYSES_RESULTS_LABIND
(
    IDENTIFIER     VARCHAR(16)  NOT NULL,				 
	ID_INTEGRA     VARCHAR(128) NOT NULL,
	COMPANY        INTEGER      NOT NULL,
	ID_EVENT       VARCHAR(64)  NOT NULL,
    EVENT          VARCHAR(8)   NOT NULL,
    DATE_EVENT     DATE			NOT NULL,
    DATE_PRECAD    DATE,
	DATE_ANALYSIS  DATE,
    RESULT_VALUE   NUMBER(10,5),
	ID_ANALYST     VARCHAR(32),
	ID_TRD         INTEGER,
	ID_ALLEGATION  INTEGER,
	REGULAR   	   CHAR(1) DEFAULT 'N' NOT NULL,
    AUTOMATIC      CHAR(1) DEFAULT 'N' NOT NULL,
	CANCELED       CHAR(1) DEFAULT 'N' NOT NULL,
	CAPTURED       CHAR(1) DEFAULT 'N' NOT NULL,
	NOTES    	   VARCHAR(2048),
	PRIMARY KEY (IDENTIFIER, ID_INTEGRA, COMPANY),
	CONSTRAINT   FK_ID_INTEGRA_RESULTS
                 FOREIGN KEY  (ID_INTEGRA, COMPANY)
				 REFERENCES   ANALYSES_LABIND(ID_INTEGRA, COMPANY)
);

CREATE TABLE ANALYSES_LOG_LABIND
(
    ID_SAMPLE     VARCHAR(16)  NOT NULL,
	ID_INTEGRA    VARCHAR(128) NOT NULL,
	COMPANY       INTEGER      NOT NULL,
	ANALYSIS_NAME VARCHAR(2048),
	EVENT         VARCHAR(8),
	DATE_LOG      DATE,
	ID_ANALYST    VARCHAR(32),
	NAME_ANALYST  VARCHAR(32),
    OLDVALUE      NUMBER(10,5),
    NEWVALUE      NUMBER(10,5),
	ID_ALLEGATION INTEGER,
	ALLEGATION    VARCHAR(2048),
	STATUS        CHAR(1),
	CONSTRAINT FK_ID_RESULTS_LOG
            FOREIGN KEY  (ID_SAMPLE, ID_INTEGRA, COMPANY)
			REFERENCES   ANALYSES_RESULTS_LABIND(IDENTIFIER, ID_INTEGRA, COMPANY) 
);

CREATE TABLE CONTROL_TRD_SCOPE_LABIND
(
	ID_TRD    INTEGER    NOT NULL,
	COMPANY   INTEGER    NOT NULL,
	HISTORY   VARCHAR(2048),
	ACTSCOPE  NUMBER(16,0),
	PRIMARY KEY (ID_TRD, COMPANY)
);

CREATE TABLE ANALYSES_SCOPE_LABIND
(
    IDENTIFIER    NUMBER(16,0) NOT NULL,
	INDEXADOR     INTEGER DEFAULT 0 NOT NULL,
	COMPANY       INTEGER           NOT NULL,
	
	DATE_LOG      DATE NOT NULL,
	
	ID_TRD        INTEGER DEFAULT 0 NOT NULL,
	TRD_STATE     INTEGER DEFAULT 0 NOT NULL,
	TRD_REQUEST   VARCHAR(2048),
	TRD_SOURCE    INTEGER DEFAULT 0,
	
	BAR_CODE      INTEGER DEFAULT 0 NOT NULL,
    TYPE_CODE     INTEGER DEFAULT 0 NOT NULL,
	
	DATE_PRECAD   DATE,
	ID_PRECAD     VARCHAR(32),
	
	ID_GROUP      INTEGER,
	GROUP_DESCR   VARCHAR(64),
	ID_OBJECT     INTEGER,
	OBJECT_DESCR  VARCHAR(64),
	ID_ATTRIBUTE  INTEGER,
	ATTRIBUTE_DESCR VARCHAR(64),
	ATTRIBUTE_NICKNAME VARCHAR(12),
	
	ID_INTEGRA    VARCHAR(128),
	ID_EVENT      VARCHAR(64),
	EVENT         VARCHAR(8), 
	DATE_EVENT    DATE,
	RESULT_VALUE  NUMBER(10,5),

    OUTRANGE      CHAR(1) DEFAULT 'N' NOT NULL,
	OVERFLOW      CHAR(1) DEFAULT 'N' NOT NULL,
    ID_ANALYST    VARCHAR(32),
    ID_ALLEGATION INTEGER,
	TEXT_MSG      VARCHAR(32),
	GET_COUNT     INTEGER DEFAULT 0 NOT NULL,
	CANCELED      CHAR(1) DEFAULT 'N' NOT NULL,
	JSON_AUX      VARCHAR(2048),
	PRIMARY KEY (IDENTIFIER, INDEXADOR, COMPANY),
	CONSTRAINT   FK_ID_TRD_SCOPE
                 FOREIGN KEY  (ID_TRD, COMPANY)
				 REFERENCES   CONTROL_TRD_SCOPE_LABIND(ID_TRD, COMPANY)				  
);

CREATE TABLE TRD_HARDWARE_CONFIGS_LABIND
(
	IDENTIFIER  INTEGER NOT NULL,
	COMPANY     INTEGER NOT NULL,
	JSONTEXT    VARCHAR(2048),
	PRIMARY KEY (IDENTIFIER, COMPANY)
);

CREATE TABLE TRD_ANALYSES_LINKS_LABIND
(
    ID_TRD   INTEGER NOT NULL,
	ID_GROUP INTEGER NOT NULL,
	COMPANY  INTEGER NOT NULL,
	SOURCE   INTEGER NOT NULL,
	CONSTRAINT   FK_TRD_HARDWARE_LINKS
                 FOREIGN KEY  (ID_TRD, COMPANY)
				 REFERENCES   TRD_HARDWARE_CONFIGS_LABIND(IDENTIFIER, COMPANY),
	CONSTRAINT   FK_TRD_GROUP_ANALYSES
                 FOREIGN KEY  (ID_GROUP, COMPANY)
				 REFERENCES   ANALYSES_GROUPS_LABIND(IDENTIFIER, COMPANY)		
);

CREATE TABLE TRD_CONTEXTS_LABIND
(
    IDENTIFIER INTEGER   NOT NULL,
	CONTEXT    INTEGER   NOT NULL,
	COMPANY    INTEGER   NOT NULL,
	JSONTEXT   VARCHAR(2048),
	PRIMARY KEY(IDENTIFIER, CONTEXT),
	CONSTRAINT   FK_TRD_HARDWARE_CONTEXTS
                 FOREIGN KEY  (IDENTIFIER, COMPANY)
				 REFERENCES   TRD_HARDWARE_CONFIGS_LABIND(IDENTIFIER, COMPANY)
);

CREATE TABLE TRD_TEMP_LABIND
(
    IDENTIFIER   INTEGER NOT NULL,
	COMPANY      INTEGER NOT NULL,
	JSONTEXT     VARCHAR(2048),
	LASTACCESS   DATE,
	PRIMARY KEY (IDENTIFIER, COMPANY),
	CONSTRAINT   FK_TRD_HARDWARE_TEMP
                 FOREIGN KEY  (IDENTIFIER, COMPANY)
				 REFERENCES   TRD_HARDWARE_CONFIGS_LABIND(IDENTIFIER, COMPANY)
);

CREATE TABLE TRD_STD_MESSAGES_LABIND
(
    TITLE    VARCHAR(32) NOT NULL,
	COMPANY  INTEGER     NOT NULL,
	JSONTEXT VARCHAR(2048),
	PRIMARY KEY (TITLE, COMPANY)
);
INSERT INTO TRD_STD_MESSAGES_LABIND (TITLE, COMPANY, JSONTEXT)
VALUES
(
'FailConnectDb',0,	
'
{
 "id":0,
 "state":0,
 "Output": {
  "index": 0,
  "text": "   Falha na conexao com       Banco de dados",
  "pos": 51,
  "timer":5,
  "alert":false
 },
 "Input": {
     "source": 4,
  "length": 0,
  "pos": 150,
  "labels": {
   "length": 0,
   "array":null
  }
 }
}
');
INSERT INTO TRD_STD_MESSAGES_LABIND (TITLE, COMPANY, JSONTEXT)
VALUES
(
'SuccessfullyCompleted',0,
'	
{
 "id":0,
 "state":0,
 "Output": {
  "index": 0,
  "text": "Finalizado com sucesso",
  "pos": 77,
  "timer":5,
  "alert":false
 },
 "Input": {
     "source": 4,
  "length": 0,
  "pos": 150,
  "labels": {
   "length": 0,
   "array":null
  }
 }
}
');
INSERT INTO TRD_STD_MESSAGES_LABIND (TITLE, COMPANY, JSONTEXT)
VALUES
(
'InvalidAnalyst',0,
'
{
 "id":0,
 "state":0,
 "Output": {
  "index": 0,
  "text": "    Codigo de analista        NAO  cadastrado",
  "pos": 51,
  "timer":5,
  "alert":true
 },
 "Input": {
     "source": 4,
  "length": 0,
  "pos": 150,
  "labels": {
   "length": 0,
   "array":null
  }
 }
}
');
INSERT INTO TRD_STD_MESSAGES_LABIND (TITLE, COMPANY, JSONTEXT)
VALUES
(
'InvalidCode',0,
'
{
 "id":0,
 "state":0,
 "Output": {
  "index": 0,
  "text":"Codigo NAO Cadastrado",
  "pos": 53,
  "timer":5,
  "alert":false
 },
 "Input": {
     "source": 4,
  "length": 0,
  "pos": 150,
  "labels": {
   "length": 0,
   "array":null
  }
 }
}
');
INSERT INTO TRD_STD_MESSAGES_LABIND (TITLE, COMPANY, JSONTEXT)
VALUES
(
'InvalidValue',0,
'	
{
 "id":0,
 "state":0,
 "Output": {
  "index": 0,
  "text": "      Valor invalido         NAO foi possivel        converter em numero",
  "pos": 51,
  "timer":5,
  "alert":false
 },
 "Input": {
     "source": 4,
  "length": 0,
  "pos": 150,
  "labels": {
   "length": 0,
   "array":null
  }
 }
}
');
INSERT INTO TRD_STD_MESSAGES_LABIND (TITLE, COMPANY, JSONTEXT)
VALUES
( 
'NotAnalysis',0,
'	
{
 "id":0,
 "state":0,
 "Output": {
  "index": 0,
  "text": "   NAO possui analises         para este TRD",
  "pos": 51,
  "timer":5,
  "alert":false
 },
 "Input": {
     "source": 4,
  "length": 0,
  "pos": 150,
  "labels": {
   "length": 0,
   "array":null
  }
 }
}
');
INSERT INTO TRD_STD_MESSAGES_LABIND (TITLE, COMPANY, JSONTEXT)
VALUES
(
'OutOfRange',0,
'	
{
 "id":0,
 "state":0,
 "Output": {
  "index": 0,
  "text": "Valor fora de faixa",
  "pos": 54,
  "timer":5,
  "alert":false
 },
 "Input": {
     "source": 4,
  "length": 0,
  "pos": 150,
  "labels": {
   "length": 0,
   "array":null
  }
 }
}
');
INSERT INTO TRD_STD_MESSAGES_LABIND (TITLE, COMPANY, JSONTEXT)
VALUES
(
'ParametersDoestMatch',0,
'	
{
 "id":0,
 "state":0,
 "Output": {
  "index": 0,
  "text": "Quantidade de parametros      NAO esperada",
  "pos": 52,
  "timer":5,
  "alert":false
 },
 "Input": {
     "source": 4,
  "length": 0,
  "pos": 150,
  "labels": {
   "length": 0,
   "array":null
  }
 }
}
');
INSERT INTO TRD_STD_MESSAGES_LABIND (TITLE, COMPANY, JSONTEXT)
VALUES
(
'NotRegistered',0,
'	
{
 "id":0,
 "state":0,
 "Output": {
  "index": 0,
  "text": " Este ID de TRD NAO esta       cadastrado",
  "pos": 52,
  "timer":5,
  "alert":false
 },
 "Input": {
     "source": 4,
  "length": 0,
  "pos": 150,
  "labels": {
   "length": 0,
   "array":null
  }
 }
}
');
INSERT INTO TRD_STD_MESSAGES_LABIND (TITLE, COMPANY, JSONTEXT)
VALUES
(
'InitializeErro',0,
'	
{
 "id":0,
 "state":0,
 "Output": {
  "index": 0,
  "text": "NAO foi possivel iniciar        o TRD",
  "pos": 52,
  "timer":5,
  "alert":false
 },
 "Input": {
     "source": 4,
  "length": 0,
  "pos": 150,
  "labels": {
   "length": 0,
   "array":null
  }
 }
}
');
INSERT INTO TRD_STD_MESSAGES_LABIND (TITLE, COMPANY, JSONTEXT)
VALUES
(
'InvalidAllegationCode',0,
'	
{
 "id":0,
 "state":0,
 "Output": {
  "index": 0,
  "text": " Codigo de justificativa         Invalido        ",
  "pos": 52,
  "timer":5,
  "alert":false
 },
 "Input": {
     "source": 4,
  "length": 0,
  "pos": 150,
  "labels": {
   "length": 0,
   "array":null
  }
 }
}
');
INSERT INTO TRD_STD_MESSAGES_LABIND (TITLE, COMPANY, JSONTEXT)
VALUES
(
'OverFlowValue',0,
'	
{
 "id":0,
 "state":0,
 "Output": {
  "index": 0,
  "text": "Fora de faixa de bloqueio",
  "pos": 51,
  "timer":5,
  "alert":false
 },
 "Input": {
     "source": 4,
  "length": 0,
  "pos": 150,
  "labels": {
   "length": 0,
   "array":null
  }
 }
}
');

INSERT INTO TRD_STD_MESSAGES_LABIND (TITLE, COMPANY, JSONTEXT)
VALUES
(
'NotAuth',0,
'	
{
 "id":0,
 "state":0,
 "Output": {
  "index": 0,
  "text": "Usuario nao autenticado",
  "pos": 52,
  "timer":5,
  "alert":false
 },
 "Input": {
     "source": 4,
  "length": 0,
  "pos": 150,
  "labels": {
   "length": 0,
   "array":null
  }
 }
}
');

INSERT INTO TRD_STD_MESSAGES_LABIND (TITLE, COMPANY, JSONTEXT)
VALUES
(
'FailedRegistry',0,
'	
{
 "id":0,
 "state":0,
 "Output": {
  "index": 0,
  "text": "     Falha ao tentar          registrar dados",
  "pos": 51,
  "timer":5,
  "alert":false
 },
 "Input": {
     "source": 4,
  "length": 0,
  "pos": 150,
  "labels": {
   "length": 0,
   "array":null
  }
 }
}
');
INSERT INTO TRD_STD_MESSAGES_LABIND (TITLE, COMPANY, JSONTEXT)
VALUES
(
'EventAlreadyRegistered',0,
'	
{
 "id":0,
 "state":0,
 "Output": {
  "index": 0,
  "text": "    Evento ja existe        tente outro valor",
  "pos": 51,
  "timer":5,
  "alert":false
 },
 "Input": {
     "source": 4,
  "length": 0,
  "pos": 150,
  "labels": {
   "length": 0,
   "array":null
  }
 }
}
');
INSERT INTO TRD_STD_MESSAGES_LABIND (TITLE, COMPANY, JSONTEXT)
VALUES
(
'NegativeConsumptionResult',0,
'	
{
 "id":0,
 "state":0,
 "Output": {
  "index": 0,
  "text": "     Nao foi possivel     registrar esse consumo    o valor resultado deu          negativo",
  "pos": 26,
  "timer":5,
  "alert":false
 },
 "Input": {
     "source": 4,
  "length": 0,
  "pos": 150,
  "labels": {
   "length": 0,
   "array":null
  }
 }
}
');
INSERT INTO TRD_STD_MESSAGES_LABIND (TITLE, COMPANY, JSONTEXT)
VALUES
(
'EventNotHour',0,
'	
{
 "id":0,
 "state":0,
 "Output": {
  "index": 0,
  "text": "    O valor informado      NAO corresponde a um        horario valido",
  "pos": 51,
  "timer":5,
  "alert":false
 },
 "Input": {
     "source": 4,
  "length": 0,
  "pos": 150,
  "labels": {
   "length": 0,
   "array":null
  }
 }
}
');