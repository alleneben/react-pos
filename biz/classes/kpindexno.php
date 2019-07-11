<?php
	class KPIndexNo extends KPBase{
		//constructor: prepare initializations here
		public function __construct(){
			parent::__construct(); 
			$p = '{"rid":"n","nam":"t","ixn":"t","sex":"n","pid":"n","pdi":"n","cid":"n","pyr":"n","pos":"n","plm":"n","sts":"n","ast":"n","stp":"t"}';
			$this->props = json_decode($p,true);
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
				$sql = "SELECT * FROM sp_student_combo($dd[pid],$dd[cid],$this->userid)";
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No student record found",9,1);
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