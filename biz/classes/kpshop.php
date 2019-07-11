<?php
	class KPShop extends KPBase{
		//constructor: prepare initializations here
		public function __construct(){
			parent::__construct(); 
			$p = '{"rid":"n","snm":"t","dsc":"t","amt":"n","dts":"t","dte":"t","mob":"t","fnm":"t","sex":"n","coi":"n","dob":"t","twn":"t","grp":"n","lei":"n","pfi":"t","fam":"t","iid":"n","nad":"t","lvl":"t","pnm":"n"'.
			 	 ',"bbi":"n","bhs":"n","tel":"t","tel":"t","mob":"t","eml":"t","pad":"t","had":"t","lan":"t","rst":"n","yfl":"n","hoh":"n","hlm":"t","hnm":"t","tov":"t","cmt":"t"'.
				 ',"idt":"n","aci":"n","ano":"t","nok":"t","noc":"t","cst":"n","idn":"t","est":"n","emr":"n","wad":"t","pho":"t","mst":"n","spn":"t","soc":"t","sag":"t"'.
				 ',"smb":"n","hno":"t","dpt":"t","rei":"n","npn":"t","nad":"t","nml":"t","fan":"t","fad":"n","mon":"t","dov":"t","pov":"n","com":"t"'.
				 ',"mad":"n","wtl":"t","fnk":"t","nkf":"t","cps":"t","dtc":"t","coy":"t","nam":"t","cfn":"t","aug":"n","sts":"n","mno":"t","ast":"n"'.
				 ',"ofh":"n","sdt":"t","enm":"t","plb":"t","rts":"n","htn":"t","nka":"t","ati":"n","mob2":"t"'.
				 ',"cti":"n","pho":"t","dsi":"n","apr":"t","pos":"n","plm":"n","cno":"t","stp":"t"}';
			
			
			$this->props = json_decode($p,true);
		}

		public function Add($pd){
			try {
				//format
				$fp = $this->props; 
				//required fields
				$rv = array('fnm','snm','dob');
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);			
				//connect to db
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
				//create sql statement	
				$dd['dsi']=1;		
				$dd['dsc']="'test'";	
				$dd['dte']="'dte'";
				$dd['dts']="'dts'";
				$sql = "SELECT * FROM cr_customer_bulk_add(".
					"$dd[fnm],$dd[snm],$dd[sex],$dd[rei],$dd[dsi],$dd[htn],$dd[dob],$dd[plb],$dd[ati],".
					"$dd[cti],$dd[had],$dd[hno],$dd[lan],$dd[pfi],$dd[dpt],$dd[wad],$dd[wtl],$dd[mst],".
					"$dd[spn],$dd[noc],$dd[nok],$dd[pad],$dd[eml],$dd[tel],$dd[mob],$dd[idt],".
					"$dd[idn],$dd[pho],$dd[dts],$dd[amt],$dd[dte],$dd[dsc],1,".
					$this->userid.")";error_log("sql:allen ".print_r($sql,true));
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				//configure success data
				return json_encode(array("success"=>"true",
				"st"=>"Add Customer",
				"sm"=>"A new customer has been successfully added",
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
				$rv = array('rid','nam','dsc','sts','stp');
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);			
				//connect to db
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
				//create sql statement				
				$sql = "SELECT * FROM sp_bank_edit(".
					$dd['rid'].",".
					$dd['nam'].",".
					$dd['dsc'].",".
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
				"st"=>"Edit Bank",
				"sm"=>"Bank has been successfully updated",
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
				$sql = "SELECT * FROM sp_bank_delete($rid,$this->userid)";
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				if($cnn)  $cnn->Close();
				//configure success data
				return json_encode(array("success"=>"true",
				"st"=>"Delete Bank",
				"sm"=>"Bank has been successfully deleted"));			
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
				$sql = "SELECT * FROM cr_customeraccounts_find(".
					$dd['rid'].",".
					$dd['snm'].",".
					$dd['fnm'].",".
					$dd['nam'].",".
					$dd['ano'].",".
					$dd['tel'].",".
					$dd['idn'].",".
					$dd['sts'].",".
					$dd['pos'].",".
					$dd['plm'].",".
					$this->userid.")";error_log("sql: ".print_r($sql,true));
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No Customer record found",9,1);
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

		public function Find($pd){
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
				$sql = "SELECT * FROM cr_customer_find(".
					$dd['rid'].",".
					$dd['snm'].",".
					$dd['fnm'].",".
					$dd['nam'].",".
					$dd['cno'].",".
					$dd['tel'].",".
					$dd['idn'].",".
					$dd['cti'].",".
					$dd['sts'].",".
					$dd['pos'].",".
					$dd['plm'].",".
					$this->userid.")";error_log("sql: ".print_r($sql,true));
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No Customer record found",9,1);
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

		public function AccountTypeFind($pd){
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
				$sql = "SELECT * FROM cr_customeraccounts_find(".
					$dd['rid'].",".
					$dd['snm'].",".
					$dd['fnm'].",".
					$dd['nam'].",".
					$dd['ano'].",".
					$dd['tel'].",".
					$dd['idn'].",".
					$dd['ati'].",".
					$dd['sts'].",".
					$dd['pos'].",".
					$dd['plm'].",".
					$this->userid.")";error_log("sql: ".print_r($sql,true));
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No Customer record found",9,1);
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
	            //required fields
				//userid
				//connect to db
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
				//create sql statement				
				$sql = "SELECT * FROM sp_bank_combo(".$this->userid.")";
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No Bank record found",9,1);
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