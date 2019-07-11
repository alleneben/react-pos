<?php
	class KPSystem extends KPBase{
		//constructor: prepare initializations here
		public function __construct(){
			parent::__construct(); 
			$p = '{"rid":"n","nam":"t","dsc":"t","key":"t","val":"t","ast":"n","stp":"t","sts":"n","pos":"n","plm":"n"}';
			$this->props = json_decode($p,true);
		}
		
		
		
		public function AddLogo(){
			try
			{		
				//$imgtype = strtolower($_FILES['lfn']['type']);
				if(!isset($_FILES['lfn'])){
					throw new ErrorException("Invalid or illegal file upload.",11,1);
				}
				elseif(!(strtolower($_FILES['lfn']['type'])==="image/gif")&&!(strtolower($_FILES['lfn']['type'])==="image/png")&&!(strtolower($_FILES['lfn']['type'])==="image/jpeg")&&!(strtolower($_FILES['lfn']['type'])==="image/jpg")){
					throw new ErrorException("The uploaded file type is invalid.<br>Uploaded".strtolower($_FILES['lfn']['type']),11,1);
				}
				elseif(!$fp = fopen($_FILES['lfn']['tmp_name'],'r')){
					throw new ErrorException("The uploaded file cannot be opened",11,1);
				}
				$UPLOAD_DIR = CONFIG_LOGOPATH; //'/tmp'; //config file
				$tempname = $_FILES['lfn']['tmp_name'];
				$filename = $_FILES['lfn']['name'];
				if (!move_uploaded_file($tempname,$UPLOAD_DIR ."/". $filename)){
				    $ec = $_FILES['lfn']['error'];
					throw new ErrorException("The uploaded file cannot be saved: $ec",11,1);
				}
				$pmsg = "";
				if(! chmod($UPLOAD_DIR ."/". $filename, 0644)){
				       $pmsg = "File permission failed";
				}
			}
			catch(Exception $e)
			{
				return ErrorHandler::Interpret($e);
			}
			//configure success data
			return json_encode(array("success"=>"true",
			"st"=>"Add Logo",
			"sm"=>"A new logo file has been successfully added",
			"sd"=>$filename));
		}
		/*
		public function CustomerReceipt($jsData)
		{	
			try 
			{
				$this->DecodeData($jsData); 
				ErrorHandler::ValidateMandatoryFields($this->props,$this->userid,array("recid"));
				
			  	$sfp=new SFPayment();
			   	$rd=$sfp->Search(json_encode(array('rid'=>$this->props['recid'],
												   'ast'=>1,
												   'cll'=>"*")));
				
				//$grd = json_decode(stripslashes($rd),true);
				$drd = json_decode($rd,true);
				$grd = $drd['sd'][0];
				$_SESSION['grd'] = $grd;
				//var_dump($grd);
				$fname = 'rcpt-'.$grd['tki'].'.pdf';
				$tpl = isset($_SESSION['us'])&&$_SESSION['us']['rid']>0?'skyfoxreceipt':'customerreceipt';
				$dompdf = new DOMPDF();
				$dompdf->load_html_file(DOMPDF_DIR . "/templates/".$tpl.".php");
				$dompdf->render();
				$dompdf->stream($fname);
				unset($_SESSION['grd']);
			}
			catch(DOMPDF_Exception $e)
			{
				return ErrorHandler::InterpretDOMPDF($e);
			}
			catch(Exception $e)
			{
				return ErrorHandler::Interpret($e);
			}
			
				return true;
		}
		
		public function Statement($jsData)
		{	
			try 
			{
				$this->DecodeData(json_encode(array("sbi"=>$_GET['sbi']))); 
				ErrorHandler::ValidateMandatoryFields($this->props,$this->userid,array('subscriberid'));
				
				//$sbData = json_encode(array("rid"=>$_GET['sbi']));
				$sbData = json_encode(array("rid"=>6,"cll"=>'*'));
				
				$sec=new KPSecurity();
				$urs=$sec->BasicData();
				$urd= json_decode($urs,true);
				if(!(isset($urd['success'])&&is_array($urd['bd']))){
					echo $urs; exit;
					//throw exception
				}
				$usd=$urd['bd'];
							
				$sub=new SFSubscriber();
				$srs=$sub->Search($sbData);
				$srd= json_decode($srs,true);
				if(!(isset($srd['success'])&&is_array($srd['sd']))){
					echo $srs; exit;
				}
				$src = $srd['rc'];
				$ssd=$srd['sd'][0];
				
				$pmt=new SFPayment();
				$prs = $pmt->Search($jsData);
				$prd= json_decode($prs,true);
				if(!(isset($prd['success'])&&is_array($prd['sd']))){
					echo $prs; exit;
					//throw exception
				}
				$prc = $prd['rc'];
				$psd = $prd['sd'];
				
				$csd=json_decode($jsData,true);
				$csd['sdt']=isset($csd['sdt'])?$csd['sdt']:'N/A';
				$csd['edt']=isset($csd['edt'])?$csd['edt']:'N/A';
				$_SESSION['usd'] = $usd;
				$_SESSION['ssd'] = $ssd;
				$_SESSION['psd'] = $psd;
				$_SESSION['csd'] = $csd;
				//var_dump($usd);var_dump($ssd);var_dump($psd);var_dump($csd);
				//var_dump($src);exit;
				
				$stmp = date('Ymdhi');
				$fname = 'stmt-'.$ssd['nam'].'-'.$stmp.'.pdf';
				$dompdf = new DOMPDF();
				$dompdf->load_html_file(DOMPDF_DIR . "/templates/statement.php");
				$dompdf->render();
				$dompdf->stream($fname);
				
			}
			catch(DOMPDF_Exception $e)
			{
				return ErrorHandler::InterpretDOMPDF($e);
			}
			catch(Exception $e)
			{
				return ErrorHandler::Interpret($e);
			}
			
				return true;
		}
		*/
		public function FindDefaults($pd){
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
					$dd['key'].",".
					$dd['pos'].",".
					$dd['plm'].",".
					$this->userid.")";
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No System Default record found",9,1);
				$rec = array_shift($sd);
				return json_encode(array("success"=>"true","sd"=>$sd,"rc"=>$rec['rid']));
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
			//return json_encode(array("success"=>"true","sd"=>$sd,"rc"=>$rec['rid']));
		}
		
		public function EditDefault($jsData){
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
					$dd['val'].",".
					$dd['stp'].",".
					$this->userid.")";
			
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($sql);
				$sd=$rc->getarray();
				
				if($cnn)  $cnn->Close();
// 				return json_encode(array("success"=>"true",
// 					"st"=>"Configure Default",
// 					"sm"=>"Parameter has been successfully configured",
// 					"sd"=>$sd));
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
		
		public function formatMail($tpl,$data){
			$str = ($data['pfx']=='NU_'||$data['pfx']=='FP_')?
				str_replace('#NAME#',$data['name'],$tpl):$tpl;
			switch($data['pfx']){
				case 'NU_':
					$str = str_replace('#PASS#',$data['pass'],$str);
					break;
				case 'FP_':
					$str = str_replace('#LINK#',$data['link'],$str);
					break;
				/*
				case 'PC_':
					$str = str_replace('#TRACKID#',$data['trackid'],$str);
					break;
				case 'PS_':
					$str = str_replace('#TRACKID#',$data['trackid'],$str);
					break;
				case 'PF_':
					$str = str_replace('#TRACKID#',$data['trackid'],$str);
					$str = str_replace('#REASON#',$data['reason'],$str);
					break;
				*/
				default:
					break;	
			}
			
			return $str;
		}
		public function SendMail($mdata){
			$rs=json_decode($this->FindDefaults(json_encode(array())),true);
			$mc = $rs['sd'];
			$ma=array();
			foreach($mc as $v) $ma[$v['key']]=$v['val'];
			
			$pfx = $mdata['pfx'];
			//exit;
			$mail = new PHPMailer();
			$mail->IsSMTP();
			
			$mail->Host=$ma["MAIL_SERVER"];
			$mail->From=$ma["MAIL_FROM"];
			$mail->FromName=$ma["MAIL_FROM_NAME"];
			$mail->WordWrap=$ma["MAIL_WRAP"]; 
			$mail->Subject=$ma[$pfx."SUBJECT"]; 
			$mail->IsHTML(true);
			
			$mail->Body=$this->formatMail($ma[$pfx."HTMLBODY"],$mdata); //stripslashes($ma["HTMLBODY"])
			$mail->AltBody=$this->formatMail($ma[$pfx."TEXTBODY"],$mdata);//stripslashes($ma["TEXTBODY"])
			
			$mail->AddAddress($mdata['email']);
			
			$mail->Send();
			//$mail->ClearAddresses();
			return;
		}
		
		public function Contact($fbData){
			$mdata=json_decode($fbData,true);
			//error_log($fbData);
			$rs=json_decode($this->FindDefaults(json_encode(array())),true);
			$mc = $rs['sd'];
			$ma=array();
			foreach($mc as $v) $ma[$v['key']]=$v['val'];
			
			//$pfx = $mdata['pfx'];
			//exit;
			$mail = new PHPMailer();
			$mail->IsSMTP();
			
			$mail->Host=$ma["MAIL_SERVER"];
			$mail->From=$mdata['eml']; //$ma["MAIL_FROM"];
			$mail->FromName=$mdata['nam']; //$ma["MAIL_FROM_NAME"];
			$mail->WordWrap=$ma["MAIL_WRAP"]; 
			$mail->Subject= "Feedback from Customer"; //$ma[$pfx."SUBJECT"]; 
			$mail->IsHTML(true);
			
			$mail->Body=$mdata['com']; //$this->formatMail($ma[$pfx."HTMLBODY"],$mdata); //stripslashes($ma["HTMLBODY"])
			$mail->AltBody=$mdata['com']; //$this->formatMail($ma[$pfx."TEXTBODY"],$mdata);//stripslashes($ma["TEXTBODY"])
			
			$mail->AddAddress("info@kpoly.edu.gh"); //AddAddress($mdata['email']);
			$mail->AddAddress("ernieofori@yahoo.com");
			
			$mail->Send();
			//$mail->ClearAddresses();
			return json_encode(array("success"=>"true",
			"st"=>"Feedback",
			"sm"=>"Your comments have been successfully sent. You will hear from us soon"));;
		}
		
}
?>