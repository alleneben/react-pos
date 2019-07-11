<?php
	class Auth extends AppBase{
		//constructor: prepare initializations here

		public function __construct(){
			parent::__construct();
			$p = '{"unm":"t","pwd":"t","uid":"t","opw":"t","npw":"t","cpw":"t","auc":"t","eml":"t","liv":"n","riv":"n"}';
			$this->props = json_decode($p,true);
		}

		public function Authenticate($cnn,$uname,$upass,$sessid){
			try
			{
				$sql="SELECT * FROM sps_security_login($uname,$upass,'$sessid')";
				$stmt=$cnn->PrepareSP($sql);error_log('sql:'.$sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if(!(is_numeric($sd[0]['rlt'])&&$sd[0]['rlt']>0)){
					throw new ADODB_Exception('POSTGRES','EXECUTE',$sd[0]['rlt'],$sd[0]['msg'],'','',$cnn);
					//exit;
				}

				return $sd[0];
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

		public function UserData($cnn,$userid,$result='*'){
			try
			{
				$cd = "$userid,$userid";
				$sql="SELECT $result FROM sps_security_basicdata($cd)";
				//error_log($sql);
				$stmt=$cnn->PrepareSP($sql); error_log($sql);//echo $cd; echo $sql;
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if(count($sd)<1)
					{throw new ErrorException("No user data found",9,1);
				};
				return $sd[0];
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
			//return $sd[0];
		}

		public function UserPriv($cnn,$gid,$ctx){
			try
			{
				$act=1; $ast=1;$sts=1;
				$sql="SELECT * FROM sps_security_privileges($gid,$ctx) ";
				//AS (rid int8,nam varchar,shc varchar,alv int4,sts int4,ast int4,stp timestamp, act int4)";
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($sql);
				$sd=$rc->getarray();
				if(count($sd)<1){
					throw new ErrorException("<font size=3px color='#FF0000'>No privilege data found, Select the right Service",9,1);
				};
				//$rec = array_shift($sd);
				return $sd;
			}
			catch(ADODB_Exception $e)
			{
				if($cnn)  $cnn->Close();
				return ErrorHandler::InterpretADODB($e);
			}
			catch(Exception $e)
			{
				return ErrorHandler::Interpret($e);
			}
			//return $sd;
		}

		public function Login($pd)
		{
			try
			{

				//has image verification been set
				if(isset($_SESSION['iv']) && ($_SESSION['iv']!=$pd['liv']) ){
					 throw new ErrorException("Invalid Image verification",3,0);
				}

				//format
				//$fp = $this->props;
				$fp = array('unm'=>'t','pwd'=>'t','ctx'=>'n');
				//required fields
				$rv = array('unm','pwd');
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv,false);
				//connect to db
				$dbl=new ConnDB();
				$cnn=$dbl->Connection();
				//create sql statement

				//$this->props['upass']=$this->HashPassword(trim($this->props['upass']));
	 	    	$sid = session_id(); //$_COOKIE[session_name()];
				$unm = $dd['unm'];
				$pwd = $dd['pwd']; //$pwd=$this->HashPassword(trim($dd['pwd']));
				$ctx = 2;//$dd['ctx'];

				$lod = $this->Authenticate($cnn,$unm,$pwd,$sid);
				$uid = $lod['rlt'];
				$_SESSION['us']['rid']=$uid;
				$uda = $this->UserData($cnn,$uid);
				$gid = $uda['roi'];//error_log("uda:".print_r($this->userid,true));
				$upv = $this->UserPriv($cnn,$gid,$ctx);
				//error_log("upv:".print_r($upv,true));
				//Retrieve and setup Data
				$umn = array();
				foreach( $upv as $mr){
					$mnm = $mr["mnm"];
					$mng = $mr["mng"];
					$smn = $mr["smn"];
					$acf = $mr["acf"];
					if(!array_key_exists($mng,$umn)) $umn[$mng]=array("nam"=>$mr["mnm"],'smn'=>array());
					if(!array_key_exists($smn,$umn[$mng]['smn']))
					{
						$umn[$mng]['smn'][$smn] = $acf;
					}
				}
				//Store in session
				$_SESSION['mn']=$umn;//error_log("umn:".print_r($umn,true));
				$_SESSION['pv']=$upv;//error_log("sess0000:".print_r($_SESSION['pv'],true));
	  			$_SESSION['us']=$uda; //error_log("sess0000:".print_r($_SESSION['us'],true));
				$_SESSION['lb']='base';

				//store context in session
				$_SESSION['us']['ctx'] = $ctx;
	  			//configure success data
				$sd=array("LST"=>$_SESSION['us']['lst']);
				//error_log("allen: ".print_r($sd,true));
				return json_encode(array("success"=>"true","sd"=>$sd));
			}
			catch(ADODB_Exception $e){
				return ErrorHandler::InterpretADODB($e);
			}
			catch(Exception $e){
				return ErrorHandler::Interpret($e);
			}
		}

		public function AuthVerify($pd)
		{
			try
			{

				//has image verification been set
				if(isset($_SESSION['iv']) && ($_SESSION['iv']!=$pd['liv']) ){
					 throw new ErrorException("Invalid Image verification",3,0);
				}



				//format
				//$fp = $this->props;
				$fp = array('unm'=>'t','pwd'=>'t','ssi'=>'t','ctx'=>'n');
				//required fields
				$rv = array('unm','pwd');
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv,false);

				//connect to db
				$dbl=new ConnDB();
				$cnn=$dbl->Connection();
				//create sql statement

				//$this->props['upass']=$this->HashPassword(trim($this->props['upass']));
	 	    $sid=$pd['ssi']; //$_COOKIE[session_name()];
				$unm = $dd['unm'];
				$pwd = $dd['pwd']; //$pwd=$this->HashPassword(trim($dd['pwd']));
				$ctx = $dd['ctx'];

				if ($sid == 'undefined') {
					$sess = new KPSessionWrite();
					$sesswrite = $sess->Open(session_id());
					$sid = session_id();
				}


				$lod = $this->Authenticate($cnn,$unm,$pwd,$sid);

				$uid = $lod['rlt'];
				$uda = $this->UserData($cnn,$uid);
				$gid = $uda['roi'];//error_log("uda:".print_r($uda,true));
				$upv = $this->UserPriv($cnn,$gid,$ctx);
				//error_log("upv:".print_r($upv,true));
				//Retrieve and setup Data
				$umn = array();
				foreach( $upv as $mr){
					$mnm = $mr["mnm"];
					$mng = $mr["mng"];
					$smn = $mr["smn"];
					$acf = $mr["acf"];
					if(!array_key_exists($mng,$umn)) $umn[$mng]=array("nam"=>$mr["mnm"],'smn'=>array());
					if(!array_key_exists($smn,$umn[$mng]['smn']))
					{
						$umn[$mng]['smn'][$smn] = $acf;
					}
				}
				//Store in session
				$_SESSION['mn']=$umn;//error_log("umn:".print_r($upv,true));
				$_SESSION['pv']=$upv;//error_log("sess0000:".print_r($_SESSION['pv'],true));
	  		$_SESSION['us']=$uda; //error_log("sess0000:".print_r($_SESSION['us'],true));
				$_SESSION['lb']='base';

				//store context in session
				$_SESSION['us']['ctx'] = $ctx;
	  			//configure success data
				$sd=array("LST"=>$_SESSION['us']['lst']);
				return json_encode(array("success"=>"true","sd"=>$sd,"mn"=>$umn,"pv"=>$upv,"us"=>$uda,"tkn"=>$sid));
			}
			catch(ADODB_Exception $e){
				return ErrorHandler::InterpretADODB($e);
			}
			catch(Exception $e){
				return ErrorHandler::Interpret($e);
			}
		}

		public function ShowImage($id)
		{
			switch($id)
			{
			 case 1:
			 	$_SESSION['vvar'] = "rv"; //reset verification
				break;
			 default:
			 	$_SESSION['vvar'] = "iv"; //image verification
				break;
			}
			return "<img id='imgid' oncontextmenu='return false;' src='biz/imgver.php' border='0'/>";
		}

		public function BasicData()
		{
		   	$umn=$_SESSION['mn'];
		   	$upv=$_SESSION['pv'];
	  		$uda=$_SESSION['us'];
				$this->userid=$_SESSION['us']['rid'];
				$sd =array("LST"=>$_SESSION['us']['lst']);

			array_shift($uda);

			return json_encode(array("success"=>"true","pv"=>$upv,"mn"=>$umn,"bd"=>$uda,"sd"=>$sd));
		}

		public function LogOut()
		{

			$rtn=session_destroy();
			if($rtn){
				return json_encode(array("success"=>"true",
										 "st"=>"Log out",
										 "sm"=>"Log out successful"));
			}
			else return $rtn;
		}

		public function RandomPassword()
		{
			return substr(str_shuffle("BmzCDwFc2rGHgk3JKb4LMfjdh5NP6ypQxR7SnT8VWvt9XsqYZ"),0,rand(7,13));
		}

		public function HashPassword($value)
		{
			return sha1("KpReGiStEr".$value."2010");
		}

		public function SetPassword($pd)
		{
			try
			{
				//format
				$fp = array('uid'=>'t','pwd'=>'t','cpw'=>'t');
				//required fields
				$rv = array('uid','pwd','cpw');
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);
				//connect to db
				$dbl=new DBLink();
				$cnn=$dbl->Connection();

				if($dd['pwd'] <> $dd['cpw']){
					 throw new ErrorException("New password does not match confirmed",7,0);
				}

				$uid = $dd['uid'];//$this->HashPassword($dd['npw']);
				$pwd = $dd['pwd'];//$this->HashPassword($dd['opw']);
				$mid = $this->userid;

				$sql="SELECT * FROM sps_security_pwset($uid,$pwd,$mid)";

				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();

				//throw new ADODB_Exception$dbms, $fn, $errno, $errmsg, $p1, $p2, $thisConnection)
				if($sd[0]['rlt'] != 1) throw new ADODB_Exception('POSTGRES','EXECUTE',$sd[0]['rlt'],$sd[0]['msg'],$sql,'',$cnn);

				return json_encode(array("success"=>"true","st"=>"Set Password",
				"sm"=>$sd[0]['msg'],"sd"=>array("LST"=>$sd[0]['rlt'])));
			}
			catch(ADODB_Exception $e)
			{
				return ErrorHandler::InterpretADODB($e);

			}
			catch(Exception $e)
			{
				return ErrorHandler::Interpret($e);
			}

		}

		public function ChangePassword($pd)
		{
			try
			{
				//format
				//$fp = $this->props;
				$fp = array('opw'=>'t','npw'=>'t','cpw'=>'t');
				//required fields
				$rv = array('opw','npw','cpw');
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);
				//connect to db
				$dbl=new DBLink();
				$cnn=$dbl->Connection();

				if($dd['npw'] <> $dd['cpw']){
					 throw new ErrorException("New password does not match confirmed",7,0);
				}

				$uid = $this->userid;
				$opw = $dd['opw'];//$this->HashPassword($dd['opw']);
				$npw = $dd['npw'];//$this->HashPassword($dd['npw']);

				$sql="SELECT * FROM sps_security_pwchange($uid,$opw,$npw)";
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();

				//if($sd[0]['rlt'] != 1) throw new ErrorException($sd[0]['msg'],$sd[0]['rlt'],0);
				//throw new ADODB_Exception$dbms, $fn, $errno, $errmsg, $p1, $p2, $thisConnection)
				if($sd[0]['rlt'] != 1) throw new ADODB_Exception('POSTGRES','EXECUTE',$sd[0]['rlt'],$sd[0]['msg'],$sql,'',$cnn);

				return json_encode(array("success"=>"true","st"=>"Change Password",
				"sm"=>$sd[0]['msg'],"sd"=>array("LST"=>$sd[0]['rlt'])));
			}
			catch(ADODB_Exception $e)
			{
				return ErrorHandler::InterpretADODB($e);

			}
			catch(Exception $e)
			{
				return ErrorHandler::Interpret($e);
			}

		}

		public function ResetRequest($jsData)
		{
			try
			{
				if(isset($_SESSION['rv']) && ($_SESSION['rv']!=$_POST['riv']) )
				{
					 throw new ErrorException("Invalid Image verification",3,0);
				}
				//$this->DecodeData($jsData);
				//ErrorHandler::ValidateMandatoryFieldsSP($this->props,array("email"));

				//$dbl=new DBLink();
				//$cnn=$dbl->Connection();
				$fp = array('unm'=>'t');
				//required fields
				$rv = array('unm');
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);
				//connect to db
				$dbl=new DBLink();
				$cnn=$dbl->Connection();

				$unm=$dd['unm'];
				//TODO: I dont want uname LIKE and email LIKE. I want =
				$sql="SELECT * FROM sps_security_pwrequest($unm)";
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if(count($sd)<1)
					{throw new ErrorException("No password reset response",15,1);
				};
				$sd = $sd[0];

				//email user with password reset.
				/* TODO
				$fnm=$sd['fnm'];
				$eml=$sd['eml'];
				$auc=$sd['tok'];
				$lnk=CONFIG_ACTPATH.'?a='.$auc;
				$pfx='FP_';
				$md = array('name'=>$fnm,'email'=>$eml,'link'=>$lnk,'pfx'=>$pfx);
				$sys=new SFSystem();
				$sys->SendMail($md);
				*/
				//configure success data
				$sd=array("LST"=>$_SESSION['us']['lst']);
				$msg = "Password Request has been successfully proccessed<br>".
				"Please access your email at <font color='red'>$eml</font> to activate the request";

				return json_encode(array("success"=>"true","st"=>"Reset Password",
				"sm"=>$msg,"sd"=>$sd));
			}
			catch(ADODB_Exception $e)
			{
				return ErrorHandler::InterpretADODB($e);

			}
			catch(Exception $e)
			{
				return ErrorHandler::Interpret($e);
			}

		}

		public function ResetActivate($cnn,$authcode,$newpass,$sessid){
			try
			{
				$sql="SELECT * FROM sps_security_pwactivate('$authcode','$newpass','$sessid')";
				$stmt=$cnn->PrepareSP($sql);//echo $sql;
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if(!(is_numeric($sd[0]['rlt'])&&$sd[0]['rlt']>0)){
					throw new ADODB_Exception('POSTGRES','EXECUTE',$sd[0]['rlt'],$sd[0]['msg'],'***','',$cnn);
					//exit;
				}

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
			//print_r($sd);
			return $sd[0];
		}

		public function PasswordActivate($pd)
		{
			try
			{

				$//this->DecodeData($jsData);
				//ErrorHandler::ValidateMandatoryFieldsSP($this->props,array("newpass","conpass","authcode"));
				//if($this->props['newpass'] <> $this->props['conpass'] )
				//{
				//	 throw new ErrorException("New password does not match confirmed",7,0);
				//}

				//$dbl=new DBLink();
				//$cnn=$dbl->Connection();

				//format
				//$fp = $this->props;
				$fp = array('cpw'=>'t','npw'=>'t','auc'=>'t','ctx'=>'n');
				//required fields
				$rv = array('npw','cpw','auc');
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);
				if($dd['npw'] <> $dd['cpw']){
					 throw new ErrorException("New password does not match confirmed",7,0);
				}
				//connect to db
				$dbl=new DBLink();
				$cnn=$dbl->Connection();

				$sessid=session_id(); //$_COOKIE[session_name()];
				$auc = $dd['auc'];
				$npw = $dd['npw'];
				$ctx = $dd['ctx'];

				$prd = $this->ResetActivate($cnn,$auc,$npw,$sessid);
				$uid = $prd['rlt'];
				$uda = $this->UserData($cnn,$uid);
				$gid = $uda['roi'];
				$upv = $this->UserPriv($cnn,$gid,$ctx);

				//Retrieve and setup Data
				$umn = array();
				foreach( $upv as $mr){
					$mnm = $mr["mnm"];
					$mng = $mr["mng"];
					$smn = $mr["smn"];
					$acf = $mr["acf"];
					if(!array_key_exists($mng,$umn)) $umn[$mng]=array("nam"=>$mr["mnm"],'smn'=>array());
					if(!array_key_exists($smn,$umn[$mng]['smn']))
					{
						$umn[$mng]['smn'][$smn] = $acf;
					}
				}
				//Store in session
				$_SESSION['mn']=$umn;
				$_SESSION['pv']=$upv;
	  			$_SESSION['us']=$uda;
				$_SESSION['lb']='base';

	  			//configure success data
				$sd=array("LST"=>$_SESSION['us']['lst']);

				//$_SESSION['setDomain'];
				setcookie ("kpprac", '', time()-2592000, '/', $_SESSION['setDomain'], 0 );
			}
			catch(ADODB_Exception $e)
			{
				setcookie ("kpprac", '', time()-2592000, '/', $_SESSION['setDomain'], 0 );
				return ErrorHandler::InterpretADODB($e);

			}
			catch(Exception $e)
			{
				setcookie ("kpprac", '', time()-2592000, '/', $_SESSION['setDomain'], 0 );
				return ErrorHandler::Interpret($e);

			}
			return json_encode(array("success"=>"true","sd"=>$sd));
		}
	}
?>
