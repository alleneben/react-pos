<?php
	class KPLDAPAuth extends KPBase{
		//constructor: prepare initializations here
		public function __construct(){
			parent::__construct(); 
			//LDAP Config
			$ldap['kpoly']['domain'] = 'kpoly.edu.gh';
			$ldap['kpoly']['host'] = 'mail.kpoly.edu.gh';
			$ldap['kpoly']['port'] = 389;
			$ldap['kpoly']['basedn'] = 'ou=people,dc=kpoly,dc=edu,dc=gh';
// 			$ldap['kpoly']['filter'] = "(&(objectClass=zimbraDistributionList)(uid=~DLIST~)(zimbraMailForwardingAddress=*~USERID~@kpoly.edu.gh*))";
// 			$ldap['kpoly']['attrib'] = array("zimbraMailForwardingAddress","zimbraMailStatus");
			
			$ldap["kpoly"]['filter'] = "(|(mail=~USERID~@kpoly.edu.gh*)(zimbraMailAlias=~USERID~@kpoly.edu.gh*))";
			$ldap["kpoly"]['attrib'] = array("mail","cn","sn","gn","displayName","zimbraMailDeliveryAddress","zimbraDomainName","uid","zimbraMailAlias","uid","zimbraDomainName","cn");
				
// 			$ldap['kpoly']['adbinddn'] = "uid=zimbra,cn=admins,cn=zimbra";
			$ldap["kpoly"]['adbinddn'] = "uid=ldapsearch,ou=people,dc=kpoly,dc=edu,dc=gh";				
			$ldap['kpoly']['adpasswd'] = '1kWJvuz9g6WS8bp6AKF3OfugRteosM';
			
			$this->ldapconfig = $ldap['kpoly'];
		}
		
		private function connect() {
		    try {	
		    	$link=ldap_connect($this->ldapconfig['host'],$this->ldapconfig['port']);
		        if(ldap_set_option($link,LDAP_OPT_PROTOCOL_VERSION,3))
				    error_log("Using LDAP v3");
				else
				    throw new ErrorException("Failed to set version to protocol 3",20,1);
				return $link;   
		    }
			catch(ErrorException $e){
				return ErrorHandler::Interpret($e);
			}    
		}
		
		private function bind($link,$dn,$pwd) {
		    try {	
		    	if(ldap_bind( $link, $dn, $pwd) ) {
            		return true;
			    }
                else{
                	error_log("LDAPBindError: $dn".ldap_error($link));
                	throw new ErrorException("LDAPBindError: ".ldap_error($link),1);
                }
			    
		    }
			catch(ErrorException $e){
				return ErrorHandler::Interpret($e);
			}    
		}
		
		private function close($link) {
		    try {	
		    	if(ldap_unbind( $link ) ) {
            		return true;
			    }
                else{
                	error_log("LDAPCloseError: ".ldap_error($link));
                	throw new ErrorException("The authentication server could not exit, please restart your browser",16);
                }
			    
		    }
			catch(ErrorException $e){
				return ErrorHandler::Interpret($e);
			}    
		}
		
		private function search($link,$basedn,$filter,$attrib) {
		    try {	
	    	    $sres = ldap_search($link,$basedn,$filter,$attrib);
				if($sres) {
		        	if(ldap_count_entries($link,$sres) > 0) {
		            	$result = ldap_get_entries( $link, $sres);
		            	return $result;
		            }
		            else{
		            	error_log("LDAPGetEntriesError: ".ldap_error($link));
		            	throw new ErrorException("I am sorry but, I cannot at the moment find your information in our authentication server<br>Please check your details and try again or contact system support for help ",16);
		            }
		        }
		        else{
		        	error_log("LDAPSearchError: $basedn,$filter,".print_r($attrib,true).ldap_error($link));
		        	throw new ErrorException("I can find your information in our authentication server but it appears you are not allowed to access this service. Please check your details and try again or contact system support for help",16);
		        }
            	
		    }
			catch(ErrorException $e){
				return ErrorHandler::Interpret($e);
			}    
		}
		
		private function getlist($result) {
		    try {	
    	        if ($result[0]['mail']) {
	            	//error_log("result is ".print_r($result[0]['zimbramailforwardingaddress'],true));
	            	$list = $result[0]['mail'];
	            	//$email = $usr."@".$this->ldapconfig['domain'];
	            	return $list;
	            }
	            else{
	            	error_log("LDAPGetEntriesError: List not found");
		            	throw new ErrorException("I am sorry but, I cannot at the moment find your information in our list of users<br>Please check your details and try again or contact system support for help ",16);
	            }
		        
		    }
			catch(ErrorException $e){
				return ErrorHandler::Interpret($e);
			}    
		}
		
		private function ismember($list,$item) {
		    try {	
    	    	$match = preg_grep("/^\s*$item\s*/",$list);
		    	if(count($match) > 0){
		    		//error_log("match=".print_r($match,true));
    	    		return true;
		    	}
	            else 
	                throw new ErrorException("LDAP Auth Failed. Not found. See the logs",1);    
		    	
		    }
			catch(ErrorException $e){
				return ErrorHandler::Interpret($e);
			}    
		}
		
		

		private function Authenticate($usr,$pwd,$dlist) {
		    try {	
		    	if($usr == "" && $pwd == "") throw new ErrorException("Invalid username or password!",10,1);
		        $link = $this->connect();
		        $userdn = "uid=$usr,".$this->ldapconfig['basedn'];
		        $ubind = $this->bind($link, $userdn, $pwd);
		        
		        if ($ubind) {
		        	error_log("LDAP bind successful...");
		        }else{
		        	error_log("LDAP bind was not successfull, perhaps user not in LDAP Server");
		        	return false;
		        }
		        
		        $adbind = $this->bind($link, $this->ldapconfig['adbinddn'], $this->ldapconfig['adpasswd']);
		        
// 		        $listdn = "uid=$dlist,".$this->ldapconfig['basedn'];
		        $listdn = $this->ldapconfig['basedn'];
		        $filter = str_replace('~USERID~',$usr,str_replace('~DLIST~',$dlist,$this->ldapconfig['filter']));        
			    $result = $this->search($link,$listdn,$filter,$this->ldapconfig['attrib']);
		        
		        $list = $this->getlist($result);
		        $email = $usr.'@'.$this->ldapconfig['domain'];
		        $ism = $this->ismember($list,$email);
		        $_SESSION['usr'] = $usr; 
		        
		        $return['userid'] = $usr;
			    return $return;
		    }
			catch(ErrorException $e){
				return ErrorHandler::Interpret($e);
			}    
		}
		
		public function Login($unm,$pwd,$dlist='staff'){
			try {
	            $res = $this->Authenticate($unm,$pwd,$dlist);
				return $res;
            }
            catch(Exception $e){
                return ErrorHandler::Interpret($e);
            }
        }
        
	}
?>
