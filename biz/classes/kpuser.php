<?php
	class KPUser extends KPBase{
		//constructor: prepare initializations here
		public function __construct(){
			parent::__construct(); 
			$p = '{"rid":"n","nam":"t","eid":"n","eni":"n","snm":"t","onm":"t","unm":"t","pwd":"t","roi":"n","lst":"n"'.
				 ',"dct":"t","lpd":"t","lld":"t","ct1":"t","ct2":"t","ctn":"t","eml":"t","com":"t"'.
				 ',"ast":"n","stp":"t","sts":"n","pos":"n","plm":"n"}';
			$this->props = json_decode($p,true);
		}
		
		public function Add($pd){
			try{
				//format
				$fp = $this->props; 
				//required fields
				$rv = array('snm','onm',"unm","eid","roi","eml",'sts');
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);			
				$genpass = $this->RandomPassword();
				$passwd = "'".$genpass."'";
				
				//connect to db
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
				//create sql statement				
				$sql = "SELECT * FROM sps_user_add(".
					$dd['snm'].",".
					$dd['onm'].",".
					$dd['unm'].",".
					$passwd.",".
					$dd['eid'].",".
					$dd['roi'].",".
					$dd['ct1'].",".
					$dd['ct2'].",".
					$dd['eml'].",".
					$dd['com'].",".
					$dd['sts'].",".
					$this->userid.")";
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				//user email
				$fnm=trim($dd['onm'],"'").' '.trim($dd['snm'],"'");
				$eml=trim($this->props['email'],"'");
				$lnk=CONFIG_ADMPATH;
				$pfx='NU_';
				$md = array('name'=>$fnm,'email'=>$eml,'pass'=>$genpass,'link'=>$lnk,'pfx'=>$pfx);
				//$sys=new KPSystem();
				//$sys->SendMail($md);	
				
				//configure success data
				return json_encode(array("success"=>"true",
				"st"=>"Add User",
				"sm"=>"A new user has been successfully added<br>".
					  //"The user may check his/her email for details",
					  "The password is: $genpass",
				"sd"=>$sd));
			}
			catch(ADODB_Exception $e){
				if($cnn)  $cnn->Close();
				return ErrorHandler::InterpretADODB($e);
			}
			catch(Exception $e){
				if($cnn)  $cnn->Close();
				return ErrorHandler::Interpret($e);
			}
		}

		public function Edit($pd){
			try{
				//format
				$fp = $this->props; 
				//required fields
				$rv = array('rid','snm','onm','roi','eml','sts','stp');
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);			
				$genpass = $this->RandomPassword();
				$passwd = "'".$genpass."'";
				
				//connect to db
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
				//create sql statement				
				$sql = "SELECT * FROM sps_user_edit(".
					$dd['rid'].",".
					$dd['unm'].",".
					$dd['snm'].",".
					$dd['onm'].",".
					$dd['roi'].",".
					$dd['ct1'].",".
					$dd['ct2'].",".
					$dd['eml'].",".
					$dd['com'].",".
					$dd['sts'].",".
					$dd['stp'].",".
					$this->userid.")";
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				//configure success data
				return json_encode(array("success"=>"true",
				"st"=>"Edit User",
				"sm"=>"User has been successfully updated",
				"sd"=>$sd));
			}
			catch(ADODB_Exception $e){
				if($cnn)  $cnn->Close();
				return ErrorHandler::InterpretADODB($e);
			}
			catch(Exception $e){
				if($cnn)  $cnn->Close();
				return ErrorHandler::Interpret($e);
			}
		}
		
		public function Delete($pd){
			try {
				//validate?
				//format
				$fp = json_decode('{"rid":"n"}'); 
				//required fields
				$rv = array('rid');
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);
				$rid = $dd['rid'];
				//$rid = $this->formatIn($pd['rid'],'n');			
				//connect to db
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
				//create sql statement			
				$sql = "SELECT * FROM sps_user_delete($rid,$this->userid)";
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				if($cnn)  $cnn->Close();
				//configure success data
				return json_encode(array("success"=>"true",
				"st"=>"Delete Application Mode",
				"sm"=>"Application Mode has been successfully deleted"));			
			}
			catch(ADODB_Exception $e){
				if($cnn)  $cnn->Close();
				return ErrorHandler::InterpretADODB($e);
			}
			catch(Exception $e){
				if($cnn)  $cnn->Close();
				return ErrorHandler::Interpret($e);
			}
		}
		
		public function Search($pd){
			try {
	            //format
				$fp = $this->props; 
				//required fields
				$rv = array();
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);			
				//connect to db
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
				//create sql statement				
				$sql = "SELECT * FROM sps_user_find(".
					$dd['rid'].",".
					$dd['nam'].",".
					$dd['eid'].",".
					$dd['roi'].",".
					$dd['unm'].",".
					$dd['ctn'].",".
					$dd['eml'].",".
					$dd['com'].",".
					$dd['sts'].",".
					$dd['ast'].",".
					$dd['pos'].",".
					$dd['plm'].",".
					$this->userid.")";
					error_log($sql);
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No User record found",9,1);
				$rec = array_shift($sd);
				return json_encode(array("success"=>"true","sd"=>$sd,"rc"=>$rec['rid']));
            }
            catch(ADODB_Exception $e){
                if($cnn)  $cnn->Close();
                return ErrorHandler::InterpretADODB($e);
            }
            catch(Exception $e){
                if($cnn)  $cnn->Close();
                return ErrorHandler::Interpret($e);
            }
        }
        
        public function Combo($pd){
			try {
	            $fp = $this->props; 
				//required fields
				$rv = array();
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);			
				//connect to db
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
				//create sql statement				
				$sql = "SELECT * FROM sps_user_combo($dd[eni],$dd[roi],$this->userid)";
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No User record found",9,1);
				return json_encode(array("success"=>"true","sd"=>$sd));
        	}
        	catch(ADODB_Exception $e){
                if($cnn)  $cnn->Close();
                return ErrorHandler::InterpretADODB($e);
            }
            catch(Exception $e){
                if($cnn)  $cnn->Close();
                return ErrorHandler::Interpret($e);
            }    
        }
        
        
    }
?>