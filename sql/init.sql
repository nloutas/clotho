-- Schema initialisation SQL script
---------------------------------------------------------
-- Server version	3.23.55-Max-log
-- create DB and grant DB user permissions
CREATE DATABASE IF NOT EXISTS clothodb;
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,REFERENCES,INDEX,ALTER ON clothodb.* TO clotho@"%" IDENTIFIED BY 'mar1kak1';
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,REFERENCES,INDEX,ALTER ON clothodb.* TO clotho@"localhost" IDENTIFIED BY 'mar1kak1';

USE clothodb;

--
-- Table structure for table 'element'
--

DROP TABLE IF EXISTS element;
CREATE TABLE element (
  id bigint(20) NOT NULL auto_increment,
  name varchar(255) NOT NULL default '',
  type varchar(55) NOT NULL default '',
  templateid int(10) NOT NULL default '2',
  pubcontent text,
  privcontent text,
  updatedate timestamp(14) NOT NULL,
  PRIMARY KEY  (id),
  KEY element_template (templateid),
  KEY element_class (type)
) TYPE=InnoDB COMMENT='Table element';

/*!40000 ALTER TABLE element DISABLE KEYS */;

--
-- data for table 'element'
--


LOCK TABLES element WRITE;
INSERT INTO element VALUES 
(NULL,'clotho welcome element','Text',2,'<CONTENT><BODY>&lt;h1&gt; Content Lavisher for Optimal Transformation and Hypermedia Optimisation &lt;/h1&gt;\r\n\r\n&lt;h2&gt;INTRODUCTION &lt;/h2&gt;\r\nThis is an open source Content Management System, relying on PERL templating.&lt;br/&gt;\r\n&lt;p&gt;The content is categorised in &quot;elements&quot;, which are inserted into the page\r\n&quot;template&quot; to dynamically generate a web page. All the data is stored in XML\r\nformat in a MySQL RDBMS.&lt;/p&gt;\r\n&lt;p&gt;Everything can be administrated  on the web-based interface, through wikki-style page editing or\r\nspecial interfaces for advanced admnistration. Basic versioning and workflow is supported.&lt;/p&gt;\r\n\r\n</BODY></CONTENT>','<CONTENT><BODY>&lt;h1&gt;Content Lavisher for Optimal Transformation and Hypermedia Optimisation &lt;/h1&gt;\r\n\r\n&lt;h2&gt;INTRODUCTION &lt;/h2&gt;\r\nThis is an open source Content Management System, relying on PERL templating.&lt;br/&gt;\r\n&lt;p&gt;The content is categorised in &quot;elements&quot;, which are inserted into the page\r\n&quot;template&quot; to dynamically generate a web page. All the data is stored in XML\r\nformat in a MySQL RDBMS.&lt;/p&gt;\r\n&lt;p&gt;Everything can be administrated  on the web-based interface, through wikki-style page editing or\r\nspecial interfaces for advanced admnistration. Basic versioning and workflow is supported.&lt;/p&gt;\r\n\r\n</BODY></CONTENT>',now()),
(NULL,'clotho history','Text',2,'<CONTENT><BODY>&lt;h2&gt;HISTORY&lt;/h2&gt;\r\nClotho, a figure from the Greek Pantheon, is the youngest of the three Fates, but one of the oldest\r\ngoddesses in Greek mythology. She is a daughter of Zeus and Themis. Each fate has a certain job, whether it be measuring thread, spinning it on a spinning wheel, or cutting the thread at the right length. Clotho is the spinner, and she spins the thread of human life with her distaff. The length of the string will determine how long a certain person\\\'s life will be. She is also known to be the daughter of Night, to indicate the darkness and obscurity of human destiny. No one knows for sure how much power Clotho and her sisters have, however, they often disobey the ruler, Zeus, and other gods. For some reason, the gods seem to obey them, whether because the fates do possess greater power, or as some sources suggest, their existence is part of the order of the Universe, and this the gods cannot disturb.</BODY></CONTENT>','<CONTENT><BODY>&lt;h2&gt;HISTORY&lt;/h2&gt;\r\nClotho, a figure from the Greek Pantheon, is the youngest of the three Fates, but one of the oldest\r\ngoddesses in Greek mythology. She is a daughter of Zeus and Themis. Each fate has a certain job, whether it be measuring thread, spinning it on a spinning wheel, or cutting the thread at the right length. Clotho is the spinner, and she spins the thread of human life with her distaff. The length of the string will determine how long a certain person\\\'s life will be. She is also known to be the daughter of Night, to indicate the darkness and obscurity of human destiny. No one knows for sure how much power Clotho and her sisters have, however, they often disobey the ruler, Zeus, and other gods. For some reason, the gods seem to obey them, whether because the fates do possess greater power, or as some sources suggest, their existence is part of the order of the Universe, and this the gods cannot disturb.</BODY></CONTENT>',now()),
(NULL,'bottom element','Text',2,'<CONTENT><BODY>Powered by CLOTHO 1.0</BODY></CONTENT>','<CONTENT><BODY>Powered by CLOTHO 1.0</BODY></CONTENT>',now());

/*!40000 ALTER TABLE element ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table 'page'
--

DROP TABLE IF EXISTS page;
CREATE TABLE page (
  id bigint(20) NOT NULL auto_increment,
  name varchar(255) NOT NULL default '',
  simplename varchar(50) NOT NULL default '',
  path varchar(255) NOT NULL default '',
  templateid int(10) NOT NULL default '1',
  statusid int(3) NOT NULL default '1',
  authorid int(10) NOT NULL default '1',
  parentid bigint(20) default NULL,
  public_elements text,
  private_elements text,
  textcontent text,
  keywords varchar(255) default NULL,
  deleted tinyint(1) NOT NULL default '0',
  updatedate timestamp(14) NOT NULL,
  PRIMARY KEY  (id),
  KEY page_name (name),
  UNIQUE KEY page_path (path),
  KEY page_templateid (templateid),
  KEY page_statusid (statusid),
  KEY page_authorid (authorid),
  KEY page_parentid (parentid)
) TYPE=InnoDB COMMENT='Table page';

/*!40000 ALTER TABLE page DISABLE KEYS */;

--
-- data for table 'page'
--


LOCK TABLES page WRITE;
INSERT INTO page VALUES 
INSERT INTO page VALUES (NULL,'Home','index.html','/',1,1,2,NULL,'<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<ELEMENTS>\n  <AREA name=\"bottom\">\n    <ELEMENTID>2</ELEMENTID>\n  </AREA>\n  <AREA name=\"center\">\n    <ELEMENTID>1</ELEMENTID>\n    <ELEMENTID>3</ELEMENTID>\n  </AREA>\n  <AREA name=\"left\">\n  </AREA>\n  <AREA name=\"right\">\n  </AREA>\n</ELEMENTS>\n','<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<ELEMENTS>\n  <AREA name=\"bottom\">\n    <ELEMENTID>2</ELEMENTID>\n  </AREA>\n  <AREA name=\"center\">\n    <ELEMENTID>1</ELEMENTID>\n    <ELEMENTID>3</ELEMENTID>\n  </AREA>\n  <AREA name=\"left\">\n  </AREA>\n  <AREA name=\"right\">\n  </AREA>\n</ELEMENTS>\n','home clotho Home ','home,clotho',0,now()),
(NULL,'Error Page','error','/error/',3,2,2,1,'','','','',0,now());

/*!40000 ALTER TABLE page ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table 'profile'
--

DROP TABLE IF EXISTS profile;
CREATE TABLE profile (
  id int(10) NOT NULL auto_increment,
  profilename varchar(255) NOT NULL default '',
  accessrights varchar(255) default NULL,
  PRIMARY KEY  (id)
) TYPE=InnoDB COMMENT='Table profile';

/*!40000 ALTER TABLE profile DISABLE KEYS */;

--
-- data for table 'profile'
--


LOCK TABLES profile WRITE;
INSERT INTO profile VALUES 
(NULL,'public','none'),
(NULL,'administrator','all'),
(NULL,'editor','edit'),
(NULL,'member','access');

/*!40000 ALTER TABLE profile ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table 'search'
--

DROP TABLE IF EXISTS search;
CREATE TABLE search (
  id bigint(20) NOT NULL auto_increment,
  keyword varchar(255) NOT NULL default '',
  hits int(10) NOT NULL default '0',
  results text,
  updatedate timestamp(14) NOT NULL,
  PRIMARY KEY  (id),
  KEY search_keyword (keyword)
) TYPE=InnoDB COMMENT='Table search';

/*!40000 ALTER TABLE search DISABLE KEYS */;

--
-- data for table 'search'
--


LOCK TABLES search WRITE;

/*!40000 ALTER TABLE search ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table 'status'
--

DROP TABLE IF EXISTS status;
CREATE TABLE status (
  id int(3) NOT NULL auto_increment,
  name varchar(55) NOT NULL default '',
  PRIMARY KEY  (id)
) TYPE=InnoDB COMMENT='Table status';

/*!40000 ALTER TABLE status DISABLE KEYS */;

--
-- data for table 'status'
--


LOCK TABLES status WRITE;
INSERT INTO status VALUES (NULL,'neo'),(NULL,'live'),(NULL,'retired');

/*!40000 ALTER TABLE status ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table 'template'
--

DROP TABLE IF EXISTS template;
CREATE TABLE template (
  id int(10) NOT NULL auto_increment,
  name varchar(255) NOT NULL default '',
  simplename varchar(50) NOT NULL default '',
  path varchar(255) default NULL,
  content text,
  hidden tinyint(1) NOT NULL default '0',
  updatedate timestamp(14) NOT NULL,
  PRIMARY KEY  (id)
) TYPE=InnoDB COMMENT='Table template';

/*!40000 ALTER TABLE template DISABLE KEYS */;

--
-- data for table 'template'
--


LOCK TABLES template WRITE;
INSERT INTO template VALUES 
(NULL,'Default Page template','defaultPage','pages/default.wml','[% page.name %]',0,now()),
(NULL,'Default Element template','defaultElement','defaultElement.wml','[% element.content.body  %]',1,now()),
(NULL,'Error template','error','error.wml','ERROR 404',1,now()),
(NULL,'Add page template','addPage','addPage.wml','',1,now()),
(NULL,'Edit page template','editPage','editPage.wml','',1,now()),
(NULL,'Add element template','addElement','addElement.wml','',1,now()),
(NULL,'Edit element template','editElement','editElement.wml','',1,now()),
(NULL,'Admin Users template','adminUsers','adminUsers.wml','',1,now()),
(NULL,'Admin User template','adminUser','adminUser.wml','',1,now()),
(NULL,'Admin Access Rights template','adminAccessRights','adminAccessRights.wml','',1,now()),
(NULL,'Admin Pages template','adminPages','adminPages.wml','',1,now()),
(NULL,'Site Map template','sitemap','sitemap.wml','',1,now()),
(NULL,'Admin Profiles template','adminProfiles','adminProfiles.wml','',1,now()),
(NULL,'Admin Profile template','adminProfile','adminProfile.wml','',1,now()),
(NULL,'Login template','login','login.wml','',1,now()),
(NULL,'Admin Templates template','adminTemplates','adminTemplates.wml','',1,now()),
(NULL,'Admin Template template','adminTemplate','adminTemplate.wml','',1,now()),
(NULL,'Quick search template','qsearch','qsearch.wml','',1,now()),
(NULL,'Admin Elements template','adminElements','adminElements.wml','',1,now()),
(NULL,'RSS Page ','rss','pages/rss.wml','',0,now()),
(NULL,'Simple Page ','simple','pages/simple.wml','',0,now()) ;

/*!40000 ALTER TABLE template ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table 'usr'
--

DROP TABLE IF EXISTS usr;
CREATE TABLE usr (
  id int(10) NOT NULL auto_increment,
  username varchar(30) NOT NULL default '',
  password BLOB NOT NULL default '',
  fullname varchar(255) default NULL,
  email varchar(255) default NULL,
  tel int(24) default NULL,
  profileid int(10) NOT NULL default '0',
  disabled tinyint(1) NOT NULL default '0',
  updatedate timestamp(14) NOT NULL,
  PRIMARY KEY  (id)
) TYPE=InnoDB COMMENT='Table usr';

/*!40000 ALTER TABLE usr DISABLE KEYS */;

--
-- data for table 'usr'
--

LOCK TABLES usr WRITE;
INSERT INTO usr VALUES 
(NULL,'visitor','','Public User','clotho_guest@loutas.com',NULL,1,0,now()),
(NULL,'admin',ENCRYPT('admin','pi'),'Nikos Loutas','clotho_admin@loutas.com',NULL,2,0,now()),
(NULL,'author',ENCRYPT('author','pi'),'Authoring User','clotho_author@loutas.com',NULL,3,0,now()),
(NULL,'access',ENCRYPT('access','pi'),'Member User','clotho_access@loutas.com',NULL,4,0,now());

/*!40000 ALTER TABLE usr ENABLE KEYS */;
UNLOCK TABLES;

--  Column_priv set('Select','Insert','Update','References') NOT NULL default '',
-- REFERENCES tbl_name [(index_col_name,...)]
--                   [MATCH FULL | MATCH PARTIAL]
--                   [ON DELETE reference_option]
--                   [ON UPDATE reference_option]
-- reference_option: RESTRICT | CASCADE | SET NULL | NO ACTION | SET DEFAULT,

