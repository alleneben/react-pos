<?php
	class Ad extends AppBase{
		//constructor: prepare initializations here
		private $props;
		public function __construct(){
			parent::__construct();
			$p = '{"rid":"n","nam":"t","pdc":"t","sid":"n","sdt":"t","edt":"t","cnm":"t","scd":"t","bid":"n","tel":"t","pyf":"n","acy":"n","pid":"n","pyr":"n","ssi":"n","rgs":"n","cur":"t","amt":"n","rcp":"t","ast":"n","stp":"t","sts":"n","pos":"n","plm":"n"}';
			$this->props = json_decode($p,true);
			//TODO: check for valid user (php_cli ?)
		}

		private function fdd($dt,$ft='Y-m-d'){
			return date($ft,strtotime($dt));
		}

		public function AddMember($pd){
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
					if($dt !== 'NULL'){
						$d = $d.$dt.',';
					}
				}

				$sql = "SELECT * FROM $f(".$d.$this->userid.")";error_log($sql);

				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No record found",9,1);
				//$rec = array_shift($sd);
				return json_encode(array("success"=>"true",
				"st"=>"Add Member",
				"sm"=>"The new member has been successfully added",
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
		public function Add($pd){
			try {
				//format

				$fp = json_decode($pd['fp'],true);
				$itm = json_decode($pd['itm'],true);
				$val = json_decode($pd['val'],true);
				$f = $pd['df'];

				// error_log(print_r($fp,true));
				// error_log(print_r($itm,true));
				// error_log(print_r($val,true));


				$val['codt'] = $val['codt'] == '' ? 'mxn' : $val['codt'];
				$val['ptin'] = $val['ptin'] == '' ? 1 : $val['ptin'];

				$dtls = "'".$val['codt']."',".$val['ptin'].",".$val['amtn'].",";
				$sts=1;
				$cv="'";
				foreach($itm as $rc){
					//TODO: format $rc using formatPost or similar...
					$rc['pty'] = $rc['pty'] ? $rc['pty'] : 'prc';
					$cv .= "$rc[rid]|$rc[nqy]|$rc[pty]|$sts::";
				}
				$cv=rtrim($cv,'::')."'";
				//required fields
				$rv = array();
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);
				//connect to db
				$dbl=new ConnDB();
				$cnn=$dbl->Connection();


				$d='';
				foreach($dd as $dt){
					if($dt !== 'NULL'){
						$d = $d.$dt.',';
					}
				}

				$sql = "SELECT * FROM $f(".$dtls.$cv.",".$d.$this->userid.")";error_log($sql);

				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No record found",9,1);
				//$rec = array_shift($sd);

				$rpt = new RP();
				$rct = $rpt->Receipt($sd);

				// error_log(print_r($rct,true));
				// return json_encode(array("success"=>"true",
				// "st"=>"Add Sales",
				// "sm"=>"The new sales has been successfully added",
				// "sd"=>$sd));
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

		public function syncData($pd){
			try {


				$ofs = json_decode($pd['ofs'],true);
				$fp = json_decode($pd['dd'],true);

				// error_log(print_r($ofs,true));
				$cnt=0;
				foreach($ofs as $rd){
					$cvs = json_decode($rd['itm'],true);

					$sts=1;
					$cv="'";
					foreach($cvs as $rc){
						$cv .= "$rc[rid]|$rc[iqty]|$rc[prc]|$sts::";
					}
					$cv=rtrim($cv,'::')."'";

					$f = $pd['df'];



					$rv = array();
					//call formating function
					$dd = $this->formatPost($fp,$rd,$rv);
					//connect to db
					$dbl=new ConnDB();
					$cnn=$dbl->Connection();


					$d='';
					foreach($dd as $dt){
						if($dt !== 'NULL'){
							$d = $d.$dt.',';
						}
					}

					$sql = "SELECT * FROM $f(".$cv.",".$d.$this->userid.")";error_log($sql);

					$cnt++;
					// error_log(print_r($cv,true));
				}
				// $itm = json_decode($fp[0]['itm'],true);
				//error_log(print_r($itm,true));




				// $sts=1;
				// $cv="'";
				// foreach($itm as $rc){
				// 	$cv .= "$rc[rid]|$rc[iqty]|$rc[prc]|$sts::";
				// }
				// $cv=rtrim($cv,'::')."'";

				//error_log(print_r($cv,true));
				//required fields
				// $rv = array();
				// //call formating function
				// $dd = $this->formatPost($fp,$ofs,$rv);
				// //connect to db
				// $dbl=new ConnDB();
				// $cnn=$dbl->Connection();
        //
        //
				// $d='';
				// foreach($dd as $dt){
				// 	if($dt !== 'NULL'){
				// 		$d = $d.$dt.',';
				// 	}
				// }
        //
				// $sql = "SELECT * FROM $f(".$cv.",".$d.$this->userid.")";error_log($sql);

				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No record found",9,1);
				//$rec = array_shift($sd);
				return json_encode(array("success"=>"true",
				"st"=>"Add Sales",
				"sm"=>$cnt." offlinesales has been synced successfully",
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

		public function AddProduct($pd){
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
				// $rec = array_shift($sd);
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

		public function Deposit($pd){
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
				// $rec = array_shift($sd);
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
