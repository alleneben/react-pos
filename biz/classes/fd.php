<?php
	class Fd extends AppBase{
		//constructor: prepare initializations here
    private $props;
		public function __construct(){
			parent::__construct();

		}


		public function Find($pd){
			try {
				//format
				// error_log(print_r($pd,true));
				$fp = json_decode($pd['dd'],true);
				$f = $pd['df'];
				//required fields
				$rv = array();
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);
				//connect to db
				$dbl=new ConnDB();
				$cnn=$dbl->Connection();


				$d='';
				foreach($dd as $dt){
					//if($dt == 'NULL'){
						$d = $d.$dt.',';
					//}
				}

				$sql = "SELECT * FROM $f(".$d.$this->userid.")";error_log($sql);

				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No record found",9,1);
				$rec = array_shift($sd);
				return json_encode(array("success"=>"true","sd"=>$sd, "rc"=>$rec));
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

		public function FetchReportData($pd){
			try {
				//format
				$fp = json_decode($pd['dd'],true);
				$f = $pd['df'];
				//required fields
				$rv = array();
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);
				//connect to db
				$dbl=new ConnDB();
				$cnn=$dbl->Connection();


				$d='';
				foreach($dd as $dt){
					//if($dt == 'NULL'){
						$d = $d.$dt.',';
					//}
				}

				$sql = "SELECT * FROM $f(".$d.$this->userid.")";error_log($sql);

				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No record found",9,1);
				$rec = array_shift($sd);
				return json_encode(array("success"=>"true","sd"=>$sd, "rc"=>$rec));
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

		public function FetchPaymentData($pd){
			try {
				// error_log(print_r($pd,true));

				//connect to db
				$dbl=new ConnDB();
				$cnn=$dbl->Connection();

				$sql = "SELECT * FROM sp_savings_find(".$pd['rid'].",".$this->userid.")";error_log($sql);


				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No record found",9,1);
				$rec = array_shift($sd);
				return json_encode(array("success"=>"true","sd"=>$sd, "rc"=>$rec));
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

		public function FetchProductData($pd){
			try {

				//connect to db
				$dbl=new ConnDB();
				$cnn=$dbl->Connection();

				$sql = "SELECT * FROM sp_cproducts_find(".$pd['rid'].",".$this->userid.")";error_log($sql);


				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No record found",9,1);
				$rec = array_shift($sd);
				return json_encode(array("success"=>"true","sd"=>$sd, "rc"=>$rec));
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
		public function FindMember($pd){
			try {
				//format

				$fp = json_decode($pd['dd'],true);
				$f = $pd['df'];
				//required fields
				$rv = array();
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);
				//connect to db
				$dbl=new ConnDB();
				$cnn=$dbl->Connection();


				$d='';
				foreach($dd as $dt){
					//if($dt == 'NULL'){
						$d = $d.$dt.',';
					//}
				}

				$sql = "SELECT * FROM $f(".$d.$this->userid.")";error_log($sql);

				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No record found",9,1);
				$rec = array_shift($sd);
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
