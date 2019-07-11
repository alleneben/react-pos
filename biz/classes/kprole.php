<?php
	class KPRole extends KPBase{
		//constructor: prepare initializations here
		public function __construct(){
			parent::__construct(); 
			$p = '{"rid":"n","roi":"n","nam":"t","dsc":"t","eti":"n","pri":"n","sto":"n","ast":"n","stp":"t","sts":"n","pos":"n","plm":"n"}';
			$this->props = json_decode($p,true);
		}
		/*
		public function Add($pd){
			try {
				//format
				$fp = $this->props; 
				//required fields
				$rv = array('nam','sts');
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);			
				//connect to db
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
				//create sql statement				
				$sql = "SELECT * FROM sps_role_add(".
					$dd['nam'].",".
					$dd['sts'].",".
					$this->userid.")";
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				//configure success data
				return json_encode(array("success"=>"true",
				"st"=>"Add Role",
				"sm"=>"The new role has been successfully added",
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
		*/
		public function Edit($pd){
			try {
				//validate?
				//format
				$fp = $this->props; 
				//required fields
				$rv = array('rid','nam','sts','stp');
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);			
				//connect to db
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
				//create sql statement				
				$sql = "SELECT * FROM sps_role_edit(".
					$dd['rid'].",".
					$dd['nam'].",".
					$dd['dsc'].",".
					$dd['eti'].",".
					$dd['sto'].",".
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
				"st"=>"Edit Role",
				"sm"=>"Role has been successfully updated",
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
		/*
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
				$sql = "SELECT * FROM sf_role_delete($rid,$this->userid)";
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				if($cnn)  $cnn->Close();
				//configure success data
				return json_encode(array("success"=>"true",
				"st"=>"Delete Role",
				"sm"=>"Role has been successfully deleted"));			
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
		*/
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
				$sql = "SELECT * FROM sps_role_find(".
					$dd['rid'].",".
					$dd['nam'].",".
					$dd['dsc'].",".
					$dd['eti'].",".
					$dd['sts'].",".
					$dd['ast'].",".
					$dd['pos'].",".
					$dd['plm'].",".
					$this->userid.")";
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No Role record found",9,1);
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
				$sql = "SELECT * FROM sps_role_combo($dd[eti],$this->userid)";
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No Role record found",9,1);
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
        
        public function GetPrivs($pd){
			try
			{
				//validate?
				//format
				$fp = $this->props; 
				//required fields
				$rv = array('roi');
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);			
				//connect to db
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
				//$act=1; $ast=1;$sts=1;
				$sql="SELECT * FROM sps_privilege_list($dd[roi],$this->userid)";
				//AS (rid int8,nam varchar,shc varchar,alv int4,sts int4,ast int4,stp timestamp, act int4)";
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($sql);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No privilege record found",9,1);
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
        
        public function SetPriv($pd){
			try {
				//validate?
				//format
				$fp = $this->props; 
				//required fields
				$rv = array('roi','pri');
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);			
				//connect to db
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
				//create sql statement				
				$sql = "SELECT * FROM sps_privilege_set(".
					$dd['roi'].",".
					$dd['pri'].",".
					$this->userid.")";
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				$sts = $sd[0]['rid'];
				$msg = array("-1"=>"Privilege already set","0"=>"Privilege Disabled","1"=>"Privilege successfully set");
				//sign function
				$sig = (int)((abs($sts)-$sts)? -1:$sts>0);
				$err = 'Privilege update has been cancelled';
				//throw new ADODB_Exception$dbms, $fn, $errno, $errmsg, $p1, $p2, $thisConnection)
				if($sig < 1) throw new ADODB_Exception('POSTGRES','EXECUTE',$sts,$err.$msg[$sig],$sql,'',$cnn);
				else{
					if($cnn)  $cnn->Close();
					//configure success data
					return json_encode(array("success"=>"true",
					"st"=>"Set Privilege",
					"sm"=>"Privilege for this role has been successfully updated",
					"sd"=>$sd[0]));	
				}
							
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
		
		public function UnsetPriv($pd){
			try {
				//validate?
				//format
				$fp = $this->props; 
				//required fields
				$rv = array('roi','pri');
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);			
				//connect to db
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
				//create sql statement				
				$sql = "SELECT * FROM sps_privilege_unset(".
					$dd['roi'].",".
					$dd['pri'].",".
					$this->userid.")";
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				$sts = $sd[0]['rid'];
				$msg = array("-1"=>"Privilege already unset","0"=>"Privilege Disabled","1"=>"Privilege successfully unset");
				//sign function
				$sig = (int)((abs($sts)-$sts)? -1:$sts>0);
				$err = 'Privilege update has been cancelled';
				//throw new ADODB_Exception$dbms, $fn, $errno, $errmsg, $p1, $p2, $thisConnection)
				if($sig < 1) throw new ADODB_Exception('POSTGRES','EXECUTE',$sts,$err.$msg[$sig],$sql,'',$cnn);
				else{
					if($cnn)  $cnn->Close();
					//configure success data
					return json_encode(array("success"=>"true",
					"st"=>"Unset Privilege",
					"sm"=>"Privilege for this role has been successfully updated",
					"sd"=>$sd[0]));	
				}
							
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
