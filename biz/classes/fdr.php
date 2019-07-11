<?php
	class Fdr extends KPBase{
		//constructor: prepare initializations here
        private $props;
		public function __construct(){
			parent::__construct(); 
			
		}

		private function fdd($dt,$ft='Y-m-d'){
			return date($ft,strtotime($dt));
		}
		
		public function __call($f, $p){
            //$p = '{"rid":"n","nam":"t","pcd":"t","sdt":"t","exd":"t","sts":"n","pos":"n","plm":"n"}';
			$this->props = $p[0][0][1]; //json_decode($params[0][1],true);
            //error_log(print_r($p[0][0][0],true));

			try {				
				$fp = $this->props; 
				$rv = array();
				$dd = $this->formatPost($fp,$p[0][0][0],$rv);	

                //error_log(print_r($dd,true));
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
		
				$d='';
				foreach($dd as $dt){

					//if($dt == 'NULL'){
						$d = $d.$dt.',';
					//}
					
					
				}
				//error_log(print_r($d,true));
				//create sql statement				
				$sql = "SELECT * FROM $f(".$d.$this->userid.")";error_log($sql);
					
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No record found",9,1);
				$rec = array_shift($sd);
				return json_encode(array("success"=>"true","sd"=>$sd,"rc"=>$rec));
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
		

        public function GetEnquiries(){
			try {
	            //format
				$fp = array(); 
				//required fields
				$rv = array();
				//call formating function
				//$dd = $this->formatPost($fp,$pd,$rv);			
				//connect to db
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
                $dd['sts']=1;
                $dd['rid']='NULL';
                $dd['pos']='NULL';
                $dd['plm']='NULL';
				//create sql statement				
				//$sql = "SELECT * FROM sp_applicant_find(".
				$sql = "SELECT * FROM sp_getenquiries_find(".
                    $dd['rid'].",".
					$dd['sts'].",".
					$dd['pos'].",".
					$dd['plm'].",".
					$this->userid.")";
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No Enquiries record found",9,1);
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

		public function GetProducts($pd){
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
				$sql = "SELECT * FROM sp_product_find(".
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
				if(count($sd)<1) throw new ErrorException("No Products record found",9,1);
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

		public function GetFProducts($pd){
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
				$sql = "SELECT * FROM sp_fproduct_find(".
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
				if(count($sd)<1) throw new ErrorException("No Products record found",9,1);
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

		public function GetSalesProducts($pd){
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
				$sql = "SELECT * FROM sp_salesproduct_find(".
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
				if(count($sd)<1) throw new ErrorException("No Products record found",9,1);
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

		public function GetFinishedProducts($pd){
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
				$sql = "SELECT * FROM sp_finisedproduct_find(".
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
				if(count($sd)<1) throw new ErrorException("No Products record found",9,1);
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

		public function EditProducts($pd){
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
                $dd['sts']=1;
				//create sql statement				
				//$sql = "SELECT * FROM sp_applicant_find(".
				$sql = "SELECT * FROM sp_product_edit(".
                    $dd['rid'].",".
					$dd['prc'].",".
					$dd['qty'].",".
					$dd['edt'].",".
					$dd['sts'].",".
					$this->userid.")"; error_log($sql);
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No Products record found",9,1);
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

		public function AddProducts($pd){
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
                $dd['sts']=1;
				//$dd['pdc']=NULL;
				$dd['pmg']="'sample.png'";
				$dd['cti'] =39;
				//create sql statement				
				//$sql = "SELECT * FROM sp_applicant_find(".
				$sql = "SELECT * FROM sp_product_add(".
					$dd['rid'].",".
                    $dd['nam'].",".
					$dd['pdc'].",".
					$dd['prc'].",".
					$dd['qty'].",".
					$dd['pmg'].",".
					$dd['edt'].",".
					$dd['cti'].",".
					$dd['sts'].",".
					$this->userid.")"; error_log($sql);
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No Products record found",9,1);
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

		public function ExtraProducts($pd){
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
                $dd['sts']=1;
				//create sql statement				
				//$sql = "SELECT * FROM sp_applicant_find(".
				$sql = "SELECT * FROM sp_product_extra(".
                    $dd['rid'].",".
					$dd['qty'].",".
					$dd['sts'].",".
					$this->userid.")"; error_log($sql);
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No Products record found",9,1);
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

		public function Issues($pd){
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
                $dd['sts']=1;
				//create sql statement				
				//$sql = "SELECT * FROM sp_applicant_find(".
				$sql = "SELECT * FROM sp_product_issues(".
                    $dd['rid'].",".
					$dd['iss'].",".
					$dd['sts'].",".
					$this->userid.")"; error_log($sql);
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No Products record found",9,1);
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

		public function GetIssues($pd){
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
				$sql = "SELECT * FROM sp_issues_find(".
                    $dd['rid'].",".
					$dd['nam'].",".
					$dd['sts'].",".
					$dd['pos'].",".
					$dd['plm'].",".
					$this->userid.")"; error_log($sql);
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No Issues record found",9,1);
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