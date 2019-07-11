<?php
	class KPLiaison extends KPBase{
		//constructor: prepare initializations here
		public function __construct(){
			parent::__construct(); 
			$p = '{"rid":"n","rfc":"t","ayr":"n","com":"t","cps":"t","dsi":"n","dsn":"t","rei":"n","ren":"t","rsc":"t","twn":"t"'.
				 ',"lmk":"t","asi":"n","asn":"t","sfi":"n","sfn":"t","nam":"t","ixn":"t","sno":"t","xno":"t","sex":"n"'.
				 ',"pid":"n","pnm":"t","dpi":"n","pti":"n","cid":"n","cml":"t","ad1":"t","ad2":"t","ad3":"t"'.
				 ',"det":"t","sti":"n","pyr":"n","eyr":"n","xyr":"n","ryr":"n","rsm":"n","pti":"n","dur":"n","psm":"n"'.
				 ',"sem":"n","ssi":"n","ssn":"t","gpi":"n","rgi":"n","rgs":"n","rgn":"t","stc":"t","stn":"t","sid":"n","dcd":"t"'.
				 ',"pos":"n","plm":"n","sts":"n","ast":"n","stp":"t"}';
			$this->props = json_decode($p,true);
		}

	
		public function Authenticate($pd){
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
				$sql = "SELECT * FROM sp_attachment_check(".
						$dd['sno'].",".
						$this->userid.")"; error_log($sql);
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No student record found with this Student NO",9,1);
				//$rec = array_shift($sd);
				return json_encode(array("success"=>"true","sd"=>$sd[0]));
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
		
	public function AddAttachment($pd){
			try {
				//format
				$fp = $this->props; 
				//required fields
				$rv = array('sid','com','cps','dsi','twn','lmk','ad1');
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);			
				//connect to db
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
				//create sql statement	

				$sql = "SELECT * FROM sp_attachment_add(".
					$dd['sid'].",".
					$dd['ayr'].",".
					$dd['rfc'].",".
					$dd['com'].",".
					$dd['cml'].",".
					$dd['cps'].",".
					$dd['dsi'].",".
					$dd['twn'].",".
					$dd['lmk'].",".
					$dd['ad1'].",".
					$dd['ad2'].",".
					$dd['ad3'].",".							
					$dd['asi'].",".
					$dd['sfi'].",".
					$dd['sts'].",".
					$this->userid.")";
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);error_log($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				//configure success data
				return json_encode(array("success"=>"true",
				"st"=>"Add Attachment",
				"sm"=>"The new attachment has been successfully added",
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

		public function EditAttachment($pd){
			try {
				//validate?
				//format
				$fp = $this->props; 
				//required fields
				$rv = array('rid');
				//call formating function
				
				$dd = $this->formatdump($fp,$pd,$rv);			
				//connect to db
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
				//create sql statement				
				$sql = "SELECT * FROM sp_attachment_edit(".
					$dd['rid'].",".
					$dd['sid'].",".
					$dd['ayr'].",".
					$dd['rfc'].",".
					$dd['com'].",".
					$dd['cml'].",".
					$dd['cps'].",".
					$dd['dsi'].",".
					$dd['twn'].",".
					$dd['lmk'].",".
					$dd['ad1'].",".
					$dd['ad2'].",".
					$dd['ad3'].",".	
					$dd['asi'].",".
					$dd['sfi'].",".
					$dd['dcd'].",".
					$dd['sts'].",".
					$dd['stp'].",".
					$this->userid.")";
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql); error_log($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				//configure success data
				return json_encode(array("success"=>"true",
				"st"=>"Update Attachment",
				"sm"=>"the selected attachment has been successfully updated",
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
		
		public function DelAttachment($pd){
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
				$sql = "SELECT * FROM sp_attachment_delete($rid,$this->userid)";
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				if($cnn)  $cnn->Close();
				//configure success data
				return json_encode(array("success"=>"true",
				"st"=>"Delete Attachment",
				"sm"=>"The selectec attachment has been successfully deleted"));			
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
		
		public function SearchAttachment($pd){
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
				$sql = "SELECT * FROM sp_attachment_find(".
						$dd['rid'].",".
						$dd['ayr'].",".
						$dd['rfc'].",".
						$dd['com'].",".
						$dd['cml'].",".
						$dd['cps'].",".
						$dd['dsi'].",".
						$dd['dsn'].",".
						$dd['rei'].",".
						$dd['ren'].",".
						$dd['twn'].",".
						$dd['lmk'].",".
						$dd['asi'].",".
						$dd['asn'].",".
						$dd['sfi'].",".
						$dd['sfn'].",".
						$dd['dcd'].",".
						$dd['sid'].",".
						$dd['sno'].",".
						$dd['xno'].",".
						$dd['nam'].",".
						$dd['pid'].",".
						$dd['pyr'].",".
						$dd['sem'].",".
						$dd['pos'].",".
						$dd['plm'].",".
					$this->userid.")";
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);error_log($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No Attachemnt records found. Please check your search option or add new company",9,1);
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
        public function Savepdf($pd){
        	try{
        	
        		error_log(print_r($_FILES[$pd['key']],1));
        		$key = empty($pd['key']) ? 'pdf' : $pd['key'];
        		if (!isset($_FILES[$key]))
        			throw new ErrorException("PDF File::Invalid or illegal file upload.", 12, 1);
        
        		$mime = "application/pdf";
        		exec("file -b --mime-type " . $_FILES[$key]["tmp_name"], $TYPE);
        
        		if ($TYPE[0] != $mime) {
        			throw new ErrorException("The uploaded file type ($TYPE[0]) is invalid",12,1);
        		}
        
        		//configure success data
        		$tempname = $_FILES[$key]['tmp_name'];
        		$filename =(!empty($pd['fnm'])?$pd['fnm']: (!empty($pd[$key])?$pd[$key]:($_FILES[$key]['name'])));
        		//             $file = CONFIG_UPLOADPATH."/$pd[pth]/$filename";
        		$file = CONFIG_LIAISONUPLOADS."/$filename";
        		if (!move_uploaded_file($tempname, $file)) {
        			$ec = $_FILES[$key]['error'];
        			throw new ErrorException("The uploaded file cannot be saved: $ec", 12, 1);
        		}
        		if(! chmod($file, 0644)){
        			$msg = "File permission failed";
        		}
        		
        		$pdffile=CONFIG_LIAISONFILES."$pd[rfc].pdf";
        		rename("$file", "$pdffile");
        		
        		//FIX: 3 means uploaded. Automate in DB
        		$rd=array("rid"=>$pd['rid'],"asi"=>3); 
        		$edit =$this->EditAttachment($rd);
        		$rd = json_decode($edit,true);
//         		$sd= $rd[0];
        		$msg = "Your Report has been uploaded and $rd[sm]";
        
        		//configure success data
        		return json_encode(array("success"=>"true",
        				"st"=>"Uploading Report",
        				"sm"=>$msg,
        				"sd"=>array('pdf'=>pathinfo($file,PATHINFO_BASENAME))));
        	}
            catch(Exception $e){
        		return ErrorHandler::Interpret($e);
        	}
        }
        
        public function DownloadPdf($pd){
        	try {
        
	        $file = CONFIG_LIAISONFILES."$pd[rfc].pdf";
	        if(file_exists($file)){
	        	$sd['fnm'] =$file;
		        }else{
		        	throw new ErrorException("There is no file attached to your records. Please upload your report in pdf format", 6, 1);
		        	
		    }        
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
        
        //end of functions
	}
?>