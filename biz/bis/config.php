<?php
//turn off display of errors to screen.
//init_set("display_errors", "0");
//override default cookie liftime
ini_set('session.cookie_lifetime',0);
ini_set('session.gc_maxlifetime', 60);

//maintenance mode
define('CONFIG_MAINTENANCE',false);

define('CONFIG_PREFIX','kp');
define('CONFIG_CONTEXT','adm');
#Base Paths
define('APP_PROT',(isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on')?'https://':'http://');
define('APP_HOST',$_SERVER['HTTP_HOST']);
#PATHS: Means config.php must always be in BIZ
define('APP_PATH',dirname(dirname($_SERVER['PHP_SELF'])));
define('BIZ_PATH',dirname($_SERVER['PHP_SELF']));
#define('ADM_PATH',APP_PATH."/admin");
define('ADM_PATH',APP_PATH."");
#URLs
define('APP_URL',APP_PROT.APP_HOST.APP_PATH);
define('ADM_URL',APP_PROT.APP_HOST.ADM_PATH);
define('BIZ_URL',APP_PROT.APP_HOST.BIZ_PATH);
//ROOTS: Must end with a forward slash.
define('BIZROOT',dirname(__FILE__)."/");
define('LIBROOT',ADM_PATH."/lib/js/");
#authorized(admin)
define('APP_ROOT',realpath(dirname(dirname(__FILE__))));
#define('CONFIG_PAGEPATH',realpath("../admin/lib/js").'/');
define('CONFIG_PAGEPATH',realpath("../lib/js").'/');
define('CONFIG_PAGEURL',BIZ_PATH."/minify.php?files=".LIBROOT);
#FILE DOWNLOADS
#define('CONFIG_FILEPATH',realpath("print").'/');
define('CONFIG_FILEURL',BIZROOT.'print/');
#unauthorized(client)
define('CONFIG_CPAGEPATH',realpath("../lib/js").'/');
define('CONFIG_CPAGEURL',BIZ_PATH."/minify.php?files=".LIBROOT);
#define('CONFIG_CPAGEURL',APP_PATH."/lib/js/");
define('CONFIG_LOGOPATH',APP_ROOT.'/photos/');
define('CONFIG_PHOTOPATH',APP_ROOT.'/photos/');
#INTERNAL USE
define('CONFIG_SERVICEPATH',BIZROOT."services/");
define('CONFIG_CLASSPATH',BIZROOT."classes/");
define('CONFIG_LIBPATH',BIZROOT."lib/");
define('CONFIG_PRINTPATH',BIZROOT."print/");
define('CONFIG_FILEPATH',BIZROOT."print/");
define('CONFIG_UPLOADPATH',BIZROOT."upload/");
#PASSWORD RESET & ACTIVATION
define('CONFIG_ACTPATH',BIZ_URL."/activate.php");
define('CONFIG_ADMPATH',ADM_URL);
#PAYMENT GW
define('CONFIG_GW_RETURL',BIZ_URL."/pay.php");
#LDAP AUTHENTICATION
define('CONFIG_LDAP_HOST','mail.sts.sts.gh');
define('CONFIG_LDAP_PORT',389);
define('CONFIG_LDAP_BASEDN','ou=people,dc=sts,dc=sts,dc=gh');
define('CONFIG_LDAP_DOMAIN','sts.sts.gh');
#DEFINE LOGO CONSTANTS
define ("PDF_HEADER_REG","../../../print/icon-reg.png");
define ("PDF_HEADER_SYS","../../../print/icon-sys.png");
define ("PDF_HEADER_FIN","../../../print/icon-fin.png");
define ("PDF_HEADER_ADM","../../../print/icon-adm.png");
define ("PDF_HEADER_LOGO","./print/icon-aps.png");
define ("PDF_HEADER_EXAM","../../../print/icon-exm.png");
define ("PDF_ADM_SIGNATURE","../biz/print/sgn-adm.png");
define ("PDF_ILO_SIGNATURE","../biz/print/sgn-ilo.png");
define ("PDF_MAIN_LOGO","../../../print/logo.png");
define ("PDF_LOGO_WATERMARK",CONFIG_PRINTPATH."logo.png");
#SMS API CONFIGURATION
define('CONFIG_SMSCLIENTID','xxx');
define('CONFIG_SMSCLIENTSECRET','xxx');
define('CONFIG_SMSCONTEXTPATH','v3');
define('CONFIG_SMSHTTPSMODE',true);
define('CONFIG_SMSHOSTNAME','api.smsgh.com');
define('CONFIG_SMSSENDER','STS');
define('CONFIG_SMSREGISTER',true);

#LIAASON FILES
define('CONFIG_LIAISONFILES',APP_ROOT.'/files/liaison/');
define('CONFIG_LIAISONUPLOADS',APP_ROOT.'/files/uploads/');

define('PHPEXCEL_ROOT',CONFIG_LIBPATH."phpxls/");


?>
