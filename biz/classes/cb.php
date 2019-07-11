<?php
	class Cb extends AppBase{
		//constructor: prepare initializations here
		public function __construct(){
			parent::__construct();
			$p = '{"rid":"n","nam":"t","shc":"t","ast":"n","stp":"t","sts":"n","pos":"n","plm":"n"}';
			$this->props = json_decode($p,true);
		}

		public function __call($func, $params){

			//error_log(print_r($func,true));
			$dbl=new ConnDB();
			$cnn=$dbl->Connection();
			//create sql statement
			$sql = "SELECT * FROM $func(".$this->userid.")";
			//prepare and execute sql statement (adodb)
			$stmt=$cnn->PrepareSP($sql);
			$rc=$cnn->Execute($stmt);
			$sd=$rc->getarray();
			if($cnn)  $cnn->Close();
			if(count($sd)<1) throw new ErrorException("No record found",9,1);
			//$rec = array_shift($sd);
			return json_encode(array("success"=>"true","sd"=>$sd));
		}

		public function Combo($pd){

			try {
				//format
				//error_log(print_r($pd,true));
				//$fp = json_decode($pd['dd'],true);
				$f = $pd['df'];
				//required fields
				$rv = array();
				//call formating function
				//$dd = $this->formatPost($fp,$pd,$rv);
				//connect to db
				$dbl=new ConnDB();
				$cnn=$dbl->Connection();


				$sql = "SELECT * FROM $f(".$this->userid.")";error_log($sql);

				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No record found",9,1);
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
