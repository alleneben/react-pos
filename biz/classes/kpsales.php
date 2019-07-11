<?php
	class KPSales extends KPBase{
		//constructor: prepare initializations here
		public function __construct(){
			parent::__construct(); 
			$p = '{"rid":"n","nam":"t","pdc":"t","sid":"n","sdt":"t","edt":"t","cnm":"t","scd":"t","bid":"n","tel":"t","pyf":"n","acy":"n","pid":"n","pyr":"n","ssi":"n","rgs":"n","cur":"t","amt":"n","rcp":"t","ast":"n","stp":"t","sts":"n","pos":"n","plm":"n"}';
			$this->props = json_decode($p,true);
			//TODO: check for valid user (php_cli ?)
		}

		public function Add($pd){
			try {

                //$dat = json_decode($pd,true);
                error_log(print_r($pd,true));
                $sts=1;
                $cv="'";
                foreach($pd as $rc){
					//TODO: format $rc using formatPost or similar...
					$cv .= "$rc[rid]|$rc[nqy]"."|$rc[prc]|$sts::";
				}
				$cv=rtrim($cv,'::')."'";

                //error_log(print_r($cv,true));
				//format
				$fp = $this->props; 
				//required fields
				//$rv = array('sno','nam','amt','trn');
				$rv = array();
				//call formating function
				$dd = $this->formatPost($fp,$pd[0],$rv);	
                //error_log(print_r($pd,true));		
				//connect to db
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
				//create sql statement				
				$sql = "SELECT * FROM sp_sales_add(".
					$cv.",".
                    $dd['cnm'].",".
                    $dd['tel'].",".
					$this->userid.")";
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);error_log($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				//configure success data
				return json_encode(array("success"=>"true","st"=>"Pay Fees",
				"sm"=>"The new payment record has been successfully added",
				"sd"=>$sd,"cod"=>1,
				"msg"=>"The new payment record has been successfully added"));	
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

        public function GetSales($pd){
			try {
				//error_log(print_r($pd,true));
	            //format
				$fp = $this->props; 
				//required fields
				$rv = array();
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);			
				//connect to db
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
                $dd['sts']=1;
            
				//create sql statement				
				//$sql = "SELECT * FROM sp_applicant_find(".
				$sql = "SELECT * FROM sp_sales_find(".
                    $dd['rid'].",".
					$dd['nam'].",".
					$dd['pdc'].",".
					$dd['sdt'].",".
					$dd['edt'].",".
					$dd['sts'].",".
					$dd['pos'].",".
					$dd['plm'].",".
					$this->userid.")"; error_log($sql);
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No Sales record found",9,1);
				$rec = array_shift($sd);
				
				return json_encode(array("success"=>"true","sd"=>$sd,"rc"=>$rec['rid'],"tt"=>$rec['tot']));
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

        public function GetLatestSales($pd){
			try {
				//error_log(print_r($pd,true));
	            //format
				$fp = $this->props; 
				//required fields
				$rv = array();
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);			
				//connect to db
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
                $dd['sts']=1;
            
				//create sql statement				
				//$sql = "SELECT * FROM sp_applicant_find(".
				$sql = "SELECT * FROM sp_latestsales_find(".
                    $dd['scd'].",".
					$dd['sts'].",".
					$dd['pos'].",".
					$dd['plm'].",".
					$this->userid.")"; error_log($sql);
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No Sales record found",9,1);
				$rec = array_shift($sd);
				
				return json_encode(array("success"=>"true","sd"=>$sd,"rc"=>$rec['rid'],"tt"=>$rec['tot']));
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

		public function toString($pd)
		{
			$rightCols = 5;
			$leftCols = 20;
			$rCols = 5;
		//if ($this -> dollarSign) {
			//  $leftCols = $leftCols / 2 - $rightCols / 2;
			//}
			$left = str_pad($pd['nam'], $leftCols) ;
			$nqy = str_pad($pd['qty'], $rightCols) ;
			$pmt = str_pad($pd['amt'], $rightCols) ;
			//$sign = ($this -> dollarSign ? '$ ' : '');
			$right = str_pad($pd['tot'], $rCols, ' ', STR_PAD_LEFT);
			return "$left$nqy$pmt$right\n";
		}

		public function Edit($pd){
			try {
				//validate?
				//format
				$fp = $this->props; 
				//required fields
				$rv = array('rid','nam','psc','pds','pti','pdi','sts','stp');
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);			
				//connect to db
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
				//create sql statement				
				$sql = "SELECT * FROM sp_payment_edit(".
					$dd['ixn'].",".
					$dd['nam'].",".
					$dd['amt'].",".
					$dd['trn'].",".
					$this->userid.")";
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				//configure success data
				return json_encode(array("success"=>"true",
				"st"=>"Edit Payment",
				"sm"=>"Payment has been successfully updated",
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
				$sql = "SELECT * FROM sp_payment_delete($rid,$this->userid)";
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				if($cnn)  $cnn->Close();
				//configure success data
				return json_encode(array("success"=>"true",
				"st"=>"Delete Payment",
				"sm"=>"Payment has been successfully deleted"));			
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

				$sql = "SELECT * FROM sp_payment_find(".
					$dd['rid'].",".
					$dd['nam'].",".
					$dd['sex'].",".
					$dd['sno'].",".
					$dd['xno'].",".
					$dd['acy'].",".
					$dd['bid'].",".
					$dd['trn'].",".
					$dd['pid'].",".
					$dd['pti'].",".
					$dd['dpi'].",".
					$dd['dti'].",".
					$dd['pyr'].",".
					$dd['sem'].",".
					$dd['ssi'].",".
					$dd['rgs'].",".
					$dd['eyr'].",".
					$dd['xyr'].",".
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
				if(count($sd)<1) throw new ErrorException("No Payment record found",9,1);
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
        
        public function Summary($pd){
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

				$sql = "SELECT * FROM sp_payment_sum(".
					$dd['sno'].",".
					$dd['acy'].",".
					$dd['pos'].",".
					$dd['plm'].",".
					$this->userid.")";
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);error_log($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No Payment record found",9,1);
				$rec = array_shift($sd);
				return json_encode(array("success"=>"true","sd"=>$sd,"rc"=>$rec['cnt']));
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
        
        public function Total($pd){
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

				$sql = "SELECT * FROM sp_payment_tot(".
					$dd['sno'].",".
					$dd['pos'].",".
					$dd['plm'].",".
					$this->userid.")";
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No Payment record found",9,1);
				$rec = array_shift($sd);
				return json_encode(array("success"=>"true","sd"=>$sd,"rc"=>$rec['cnt']));
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
        
        public function Bank($pd){
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

				$sql = "SELECT * FROM sp_payment_ban(".
					$dd['bid'].",".
					$dd['acy'].",".
					$dd['pos'].",".
					$dd['plm'].",".
					$this->userid.")";
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No Payment record found",9,1);
				$rec = array_shift($sd);
				return json_encode(array("success"=>"true","sd"=>$sd,"rc"=>$rec['cnt']));
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
        
        public function Annual($pd){
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

				$sql = "SELECT * FROM sp_payment_all(".
					$dd['acy'].",".
					$dd['pos'].",".
					$dd['plm'].",".
					$this->userid.")";
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);error_log($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No Payment record found",9,1);
				$rec = array_shift($sd);
				return json_encode(array("success"=>"true","sd"=>$sd,"rc"=>$rec['cnt']));
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
        
        public function Balance($pd){
			try {
	            //format
				$fp = $this->props; 
				//required fields
				$rv = array('acy');
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);			
				//connect to db
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
				//create sql statement		

				$sql = "SELECT * FROM sp_payment_bal(".
					$dd['mod'].",".
					$dd['sno'].",".
					$dd['acy'].",".
					$dd['pid'].",".
					$dd['pyr'].",".
					$dd['ssi'].",".
					$dd['pos'].",".
					$dd['plm'].",".
					$this->userid.")";
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);error_log($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No Payment record found",9,1);
				$rec = array_shift($sd);
				return json_encode(array("success"=>"true","sd"=>$sd,"rc"=>$rec['cnt']));
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
        
        public function Defaulters($pd){
        	try {
        		//format
        		$fp = $this->props;
        		//required fields
        		$rv = array('acy');
        		//call formating function
        		$dd = $this->formatPost($fp,$pd,$rv);
        		//connect to db
        		$dbl=new DBLink();
        		$cnn=$dbl->Connection();
        		//create sql statement
        
        		$sql = "SELECT * FROM sp_payment_defaulters(".
        				$dd['mod'].",".
        				$dd['sno'].",".
        				$dd['acy'].",".
        				$dd['pid'].",".
        				$dd['pyr'].",".
        				$dd['ssi'].",".
        				$dd['pos'].",".
        				$dd['plm'].",".
        				$this->userid.")";
        		//prepare and execute sql statement (adodb)
        		$stmt=$cnn->PrepareSP($sql);error_log($sql);
        		$rc=$cnn->Execute($stmt);
        		$sd=$rc->getarray();
        		if($cnn)  $cnn->Close();
        		if(count($sd)<1) throw new ErrorException("No Payment record found",9,1);
        		//$rec = array_shift($sd);
        		return json_encode(array("success"=>"true","sd"=>$sd,"rc"=>$sd['cnt']));
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
        
        public function Feesummary($pd){
        	try {
        		//format
        		$fp = $this->props;
        		//required fields
        		$pd['rgs']=$pd['rgs']==3?'':$pd['rgs'];
        	
        		$rv = array('acy','pyf');
        		//call formating function
        		$dd = $this->formatPost($fp,$pd,$rv);
        		error_log(print_r($dd,1));
        		//connect to db
        		$dbl=new DBLink();
        		$cnn=$dbl->Connection();
        		//create sql statement
        
        		$sql = "SELECT * FROM sp_payment_feesummary(".
          				$dd['pyf'].",".
        				$dd['acy'].",".
        				$dd['rgs'].",".
        				$dd['ssi'].",".
        				$dd['cur'].",".
        				$dd['pos'].",".
        				$dd['plm'].",".
        				$this->userid.")";
        		//prepare and execute sql statement (adodb)
        		$stmt=$cnn->PrepareSP($sql);error_log($sql);
        		$rc=$cnn->Execute($stmt);
        		$sd=$rc->getarray();
        		if($cnn)  $cnn->Close();
        		if(count($sd)<1) throw new ErrorException("No Payment record found",9,1);
        		//$rec = array_shift($sd);
        		return json_encode(array("success"=>"true","sd"=>$sd,"rc"=>$sd['cnt']));
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
        
        
        public function Fees($pd){
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

				$sql = "SELECT * FROM sp_payment_fee(".
					$dd['pid'].",".
					$dd['pyr'].",".
					$dd['pos'].",".
					$dd['plm'].",".
					$this->userid.")";
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);error_log($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No Fee record found",9,1);
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
        
        public function Student($pd){
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

				$sql = "SELECT * FROM sp_payment_stu(".
					$dd['mod'].",".
					$dd['sno'].",".
					$dd['acy'].",".
					$dd['pid'].",".
					$dd['pyr'].",".
					$dd['ssi'].",".
					$dd['pos'].",".
					$dd['plm'].",".
					$this->userid.")"; error_log($sql);
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No student record found",9,1);
				$rec = array_shift($sd);
				return json_encode(array("success"=>"true","sd"=>$sd,"rc"=>$rec['pid']));
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
        
        public function Details($pd){
			try {
	            //format
				$fp = $this->props; 
				//required fields
				$rv = array('sno');
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);			
				//connect to db
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
				//create sql statement		

				$sql = "SELECT * FROM sp_payment_det(".
					$dd['sno'].",".
					$this->userid.")";
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);error_log($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No Payment record found",9,1);
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
        
        public function AcyLedgerDetails($pd){
        	try {
        		//format
        		$fp = $this->props;
        		//required fields
        		$rv = array('sno','acy');
        		//call formating function
        		$dd = $this->formatPost($fp,$pd,$rv);
        		//connect to db
        		$dbl=new DBLink();
        		$cnn=$dbl->Connection();
        		//create sql statement
        
        		$sql = "SELECT * FROM sp_payment_det(".
        				$dd['sno'].",".
        				$this->userid.")".
        				"WHERE acy=". $dd['acy'];
        		//prepare and execute sql statement (adodb)
        		$stmt=$cnn->PrepareSP($sql);error_log($sql);
        		$rc=$cnn->Execute($stmt);
        		$sd=$rc->getarray();
        		if($cnn)  $cnn->Close();
        		if(count($sd)<1) throw new ErrorException("No Payment record found",9,1);
//         		$rec = array_shift($sd);
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
        
        public function Find($pd){
			try {
	            //format
				$fp = $this->props; 
				//required fields
				$rv = array('sno');
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);			
				//connect to db
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
				//create sql statement		

				$sql = "SELECT * FROM sp_payment_find(".
					$dd['rid'].",".
					$dd['nam'].",".
					$dd['sex'].",".
					$dd['sno'].",".
					$dd['xno'].",".
					$dd['acy'].",".
					$dd['bid'].",".
					$dd['trn'].",".
					$dd['pid'].",".
					$dd['pti'].",".
					$dd['dpi'].",".
					$dd['dti'].",".
					$dd['pyr'].",".
					$dd['sem'].",".
					$dd['ssi'].",".
					$dd['rgs'].",".
					$dd['eyr'].",".
					$dd['xyr'].",".
					$dd['sts'].",".
					$dd['ast'].",".
					$dd['pos'].",".
					$dd['plm'].",".
					$this->userid.")";
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);error_log($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No Payment record found",9,1);
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
        
        public function Payer($pd){
        	try {
        		//format
        		$fp = $this->props;
        		//required fields
        		$rv = array('sno');
        		//call formating function
        		$dd = $this->formatPost($fp,$pd,$rv);
        		//connect to db
        		$dbl=new DBLink();
        		$cnn=$dbl->Connection();
        		//create sql statement
        
        		$sql = "SELECT * FROM sp_payment_pos(".
        				$dd['sno'].",".
        				$this->userid.")"; error_log($sql);
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
        
	        public function Findresit($pd){
        	try {
        		//format
        		$fp = $this->props;
        		//required fields
        		$rv = array('sno');
        		//call formating function
        		$dd = $this->formatPost($fp,$pd,$rv);
        		//connect to db
        		$dbl=new DBLink();
        		$cnn=$dbl->Connection();
        		//create sql statement
        
        		$sql = "SELECT * FROM sp_resit_pos(".
        				$dd['sno'].",".
        				$this->userid.")"; error_log($sql);
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
        public function Addresit($pd) {
        	try {
        		//format
        		$fp = $this->props;
        		//required fields
        		$rv = array('bcd', 'sid', 'amt', 'trn');
        		//call formating function
        		$dd = $this->formatPost($fp, $pd, $rv);
        		//connect to db
        		$dbl = new DBLink();
        		$cnn = $dbl->Connection();
        		//create sql statement
        		$sql = "SELECT * FROM sp_payment_resit(" .
        				$dd['sid'] . "," .
        				$dd['amt'] . "," .
        				$dd['bcd'] . "," .
        				$dd['trn'] . "," .
        				"'$_SERVER[HTTP_CLIENT_IP]',".
        				"'$_SERVER[HTTP_X_FORWARDED_FOR]',".
        				"'$_SERVER[REMOTE_ADDR]',".
        				$this->userid . ")"; //error_log($sql);
        		//prepare and execute sql statement (adodb)
        		$stmt = $cnn->PrepareSP($sql);error_log($sql);
        		$rc = $cnn->Execute($stmt);
        		$sd = $rc->getarray();
        		if ($cnn)
        			$cnn->Close();
        		//configure success data
        		return json_encode(array("success" => "true",
        				"st" => "Add Payment",
        				"sm" => "The new payment record has been successfully added",
        				"sd" => $sd, "cod" => 1,
        				"msg" => "The new payment record has been successfully added"));
        	}
        	catch (ADODB_Exception $e) {
        		if ($cnn) $cnn->Close();
        		return ErrorHandler::InterpretADODB($e, 0);
        	}
        	catch (Exception $e) {
        		if ($cnn) $cnn->Close();
        		return ErrorHandler::Interpret($e, 0);
        	}
        }
        
		
	}
?>