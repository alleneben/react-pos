<?php
	class Adn extends KPBase{
		//constructor: prepare initializations here
		private $props;
		public function __construct(){
			parent::__construct(); 
			//$p = '{"rid":"n","pnm":"t","bpr":"n","spr":"n","lsl":"n","ost":"n","bcd":"t","pct":"n","pnt":"t","exd":"t","img":"t","sts":"n"}';
			//$this->props = json_decode($p,true);
		}

		private function fdd($dt,$ft='Y-m-d'){
			return date($ft,strtotime($dt));
		}
		
		public function __call($func, $params){
            error_log(print_r($params[0]['dd'],true));
            $this->props = $params[0]['ps'];
            
			try {				
				$fp = $this->props; 
				$rv = array();
				$dd = $this->formatPost($fp,$params[0]['dd'],$rv);	

				$dbl=new DBLink();
				$cnn=$dbl->Connection();
		
				$d='';
				foreach($dd as $dt){

					if($dt !== 'NULL'){
						$d = $d.$dt.',';
					}
					
					
				}
				//error_log(print_r($d,true));
				//create sql statement				
				$sql = "SELECT * FROM $func(".$d.$this->userid.")";
					
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