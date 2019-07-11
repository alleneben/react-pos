<?php
	class KPAudit extends KPBase{
		//constructor: prepare initializations here
		public function __construct(){
			parent::__construct(); 
			$p = '{"rid":"n","uid":"n","eid":"n","roi":"n","act":"t","rcd":"t","sdt":"t","edt":"t","pos":"n","plm":"n","sts":"n","stp":"t"}';
			$this->props = json_decode($p,true);
			$this->output = "<div style='position:absolute;left:45%;top:40%;".
							"padding:2px;z-index:20001;height:auto;'>##MSG##</div>";	
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
				$sql = "SELECT * FROM sps_audittrail_find(".
					$dd['uid'].",".
					$dd['eid'].",". //can be eni
					$dd['roi'].",".
					$dd['act'].",".
					$dd['rcd'].",".
					$dd['sdt'].",".
					$dd['edt'].",".
					$dd['pos'].",".
					$dd['plm'].",".
					$this->userid.")";
					error_log($sql);
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No Audit record found",9,1);
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
		
    }
?>