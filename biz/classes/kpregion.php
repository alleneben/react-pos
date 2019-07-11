<?php
	class kpregion extends KPBase{
		//constructor: prepare initializations here
		public function __construct(){
			parent::__construct(); 
			$p = '{"rid":"n","nam":"t","ast":"n","stp":"t","sts":"n","pos":"n","plm":"n"}';
			$this->props = json_decode($p,true);
		}

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
				$sql = "SELECT * FROM sp_region_add(".
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
				"st"=>"Add Region",
				"sm"=>"The new subject type has been successfully added",
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
				$rv = array('rid','nam','sts','stp');
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);			
				//connect to db
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
				//create sql statement				
				$sql = "SELECT * FROM sp_region_edit(".
					$dd['rid'].",".
					$dd['nam'].",".
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
				"st"=>"Edit Region",
				"sm"=>"Region has been successfully updated",
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
				$sql = "SELECT * FROM sp_region_delete($rid,$this->userid)";
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				if($cnn)  $cnn->Close();
				//configure success data
				return json_encode(array("success"=>"true",
				"st"=>"Delete Region",
				"sm"=>"Region has been successfully deleted"));			
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
				$sql = "SELECT * FROM sp_region_find(".
					$dd['rid'].",".
					$dd['nam'].",".
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
				if(count($sd)<1) throw new ErrorException("No Region record found",9,1);
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
	            //validate userid
				ErrorHandler::ValidateUserSession($this->userid);
				//connect to db
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
				//create sql statement				
				$sql = "SELECT * FROM sp_region_combo($this->userid)";
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No Region record found",9,1);
				//$rec = array_shift($sd);
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