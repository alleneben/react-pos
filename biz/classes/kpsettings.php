<?php
	class KPSettings extends KPBase{
		//constructor: prepare initializations here
		public function __construct(){
			parent::__construct(); 
			$p = '{"rid":"n","hsh":"n","nam":"t","typ":"t","dsc":"t","val":"t","sts":"n","ast":"n","pos":"n","plm":"n","stp":"t"}';
			$this->props = json_decode($p,true);
		}
		
		public function Edit($pd){
			try {
	            //format
				$fp = $this->props; 
				//required fields
				$rv = array('rid','val','stp');
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);			
				//connect to db
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
				//create sql statement				
				$sql = "SELECT * FROM sps_systemdefault_edit(".
					$dd['rid'].",".
					$dd['val'].",".
					$dd['stp'].",".
					$this->userid.")";  error_log($sql);
			
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($sql);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				return json_encode(array("success"=>"true",
					"st"=>"Systems Settings",
					"sm"=>"Parameter has been successfully updated",
					"sd"=>$sd));
			}
			catch(ADODB_Exception $e)
			{
				if($cnn)  $cnn->Close();
				return ErrorHandler::InterpretADODB($e);
			}
			catch(Exception $e)
			{
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
				$sql = "SELECT * FROM sps_systemdefault_find(".
					$dd['rid'].",".
					$dd['nam'].",".
					$dd['pos'].",".
					$dd['plm'].",".
					$this->userid.")"; 
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No Settings record found",9,1);
				$rec = array_shift($sd);
				//get hash version
				$hash = array();
				if(isset($pd['hsh']) && $pd['hsh']==1 && $rec > 0)
					$hash = $this->GetHash($sd);
				return json_encode(array("success"=>"true","sd"=>$sd,"rc"=>$rec['rid'], 'hd'=>$hash));
			}
			catch(ADODB_Exception $e)
			{
				if($cnn)  $cnn->Close();
				return ErrorHandler::InterpretADODB($e);
			}
			catch(Exception $e)
			{
				if($cnn)  $cnn->Close();
				return ErrorHandler::Interpret($e);
			}
		}
		
		public function GetHash($sd){
			try {
	            //associate the keys
				$new = array();
				foreach($sd as $rec){
					$new[$rec['nam']] = $rec['val'];
				}
				return $new;
			}
			catch(Exception $e){
				return ErrorHandler::Interpret($e);
			}
		}
		
		public function Get($pd){
			try {
				$rs = $this->Search($pd);
				$rd = json_decode($rs,true);
				if(!isset($rd['success'])) return $rs;
				$sd = $rd['sd'];
	            $fds = explode(',',$pd['fds']);
	            $new = array();
				foreach($sd as $rec){
					if(in_array($rec['nam'],$fds))
						$new[$rec['nam']] = $rec['val'];
				}
				unset($rd['sd']);
				$rd['hd'] = $new;
				$rd['rc'] = count($new);
				return json_encode($rd);
			}
			catch(Exception $e){
				return ErrorHandler::Interpret($e);
			}
		}
						
}
?>