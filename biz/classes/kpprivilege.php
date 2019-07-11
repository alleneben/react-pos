<?php
	class KPPrivilege extends KPBase{
		//constructor: prepare initializations here
		public function __construct(){
			parent::__construct(); 
			$p = '{"rid":"n","nam":"t","shc":"t","mnm":"t","smn":"t","lnm":"t","ord":"n","acl":"n","acf":"t",'.
				 '"mng":"t","btx":"t","bfn":"t","sts":"n","ast":"n","stp":"t","ctx":"n","pos":"n","plm":"n"}';
			$this->props = json_decode($p,true);
		}

		public function Add($pd){
			try {
				//format
				$fp = $this->props; 
				//required fields
				$rv = array('nam','shc','mnm','smn','lnm','ord','acl','acf','mng','btx','bfn','sts','ctx');
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);			
				//connect to db
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
				//create sql statement				
				$sql = "SELECT * FROM sps_privilege_add(".
					$dd['ord'].",".
					$dd['nam'].",".
					$dd['shc'].",".
					$dd['mnm'].",".
					$dd['smn'].",".
					$dd['lnm'].",".
					$dd['ord'].",".
					$dd['acl'].",".
					$dd['acf'].",".
					$dd['mng'].",".
					$dd['btx'].",".
					$dd['bfn'].",".
					$dd['ctx'].",".
					$dd['sts'].",".
					$this->userid.")";
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				//configure success data
				return json_encode(array("success"=>"true",
				"st"=>"Add Privilege",
				"sm"=>"The new privilege has been successfully added",
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
			try {
				//validate?
				//format
				$fp = $this->props; 
				//required fields
				$rv = array('rid','stp');
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);			
				//connect to db
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
				//create sql statement				
				$sql = "SELECT * FROM sps_privilege_edit(".
					$dd['rid'].",".
					$dd['nam'].",".
					$dd['shc'].",".
					$dd['mnm'].",".
					$dd['smn'].",".
					$dd['lnm'].",".
					$dd['ord'].",".
					$dd['acl'].",".
					$dd['acf'].",".
					$dd['mng'].",".
					$dd['btx'].",".
					$dd['bfn'].",".
					$dd['ctx'].",".
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
				"st"=>"Edit Privilege",
				"sm"=>"Privilege has been successfully updated",
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
				$sql = "SELECT * FROM sps_privilege_delete($rid,$this->userid)";
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				if($cnn)  $cnn->Close();
				//configure success data
				return json_encode(array("success"=>"true",
				"st"=>"Delete Privilege",
				"sm"=>"Privilege has been successfully deleted"));			
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
				$sql = "SELECT * FROM sps_privilege_find(".
					$dd['rid'].",".
					$dd['mnm'].",".
					$dd['smn'].",".
					$dd['ctx'].",".
					$dd['sts'].",".
					$this->userid.")"; //error_log($sql);
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No privilege ee record found",9,1);
				//$rec = array_shift($sd);
				$rcc = $rc->RecordCount();
				return json_encode(array("success"=>"true","sd"=>$sd,"rc"=>$rcc));
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
	            //required fields
				//userid
				//connect to db
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
				//create sql statement				
				$sql = "SELECT * FROM sps_privilege_combo(".$this->userid.")";
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No privilege record found",9,1);
				//$rec = array_shift($sd);
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
	}
?>