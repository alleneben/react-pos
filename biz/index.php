<?php

	include_once "config.php";
	include_once "autoload.php";
	
	new KPSession();	
	
	//maintenance handling here
	if(CONFIG_MAINTENANCE == true){
		try{
			//construct absolute page name
			$mpage=CONFIG_PAGEPATH."maintenance.js";
			$mpageurl=CONFIG_PAGEURL."maintenance.js";
			//verify if requested mpage exists
			if (file_exists($mpage )){
				echo "<script type='text/javascript' src='$mpageurl'></script>";	
			}
			else{
				//mpage does not exist. return message
				throw new ErrorException("Sorry, system in maintenance mode. Please come back later.",5,2);
			}
		}
		catch(Exception $e)
		{
			die (ErrorHandler::Interpret($e));	
		}
		
	}
	//end of maintenance handling
	
	elseif(isset($_POST['p'])){ //when a page is requested
		try{
			$pp = $fs = array();
			ErrorHandler::ValidateMandatoryFields($pp,$_SESSION['us']['rid'],$fs);
			//construct absolute page name
			$page=CONFIG_PAGEPATH.CONFIG_PREFIX.trim($_POST['p']).".js";
			$pageurl=CONFIG_PAGEURL.CONFIG_PREFIX.trim($_POST['p']).".js";
			
			//verify if requested page exists
			if (file_exists($page )){
				//load requested page
				echo "<script type='text/javascript' src='$pageurl'></script>";	
			}
			else{
				//page does not exist
				throw new ErrorException("The requested page is invalid.",5,2);
			}
		}
		catch(Exception $e){
			die (ErrorHandler::Interpret($e));	
		}
		
	}
	else if(isset($_POST['f'])){ //when a file is requested
		try{
			$pp = $fs = array();
			ErrorHandler::ValidateMandatoryFields($pp,$_SESSION['us']['rid'],$fs);
			//construct absolute page name
			$file=CONFIG_FILEPATH.trim($_POST['f']);
			//verify if requested page exists
			if (file_exists($file )){
				//load requested page
				echo "<pre style=\"white-space: -moz-pre-wrap\">".file_get_contents($file)."</pre>";	
			}
			else{
				//page does not exist
				throw new ErrorException("The requested file is invalid.",5,2);
			}
		}
		catch(Exception $e){
			die (ErrorHandler::Interpret($e));	
		}
		
	}
	else if(isset($_POST['c'])){ //when a client page is requested
		try{
			//construct absolute page name
			$page=CONFIG_CPAGEPATH.trim($_POST['c']).".js";
			$pageurl=CONFIG_CPAGEURL.trim($_POST['c']).".js";
			
			//verify if requested page exists
			if (file_exists($page )){
				//load requested page
				echo "<script type='text/javascript' src='$pageurl'></script>";	
			}
			else{
				//page does not exist
				throw new ErrorException("The requested page is invalid.",5,2);
			}
		}
		catch(Exception $e){
			die (ErrorHandler::Interpret($e));	
		}
		
	}
	elseif(isset($_POST['s'])){ //when a service is requested
		try
		{
			if(isset($_POST['m'])&&$_POST['m']=='c'){
				if(!$_SESSION['us']['rid'])	$_SESSION['us']=array('rid'=>0);
			}
			$s = CONFIG_PREFIX.$_POST['s'];
			$a = $_POST['a'];
			
			if(class_exists($s)) {
				$obj = new $s();
				if(method_exists($s,$a)) echo $obj->{$a}($_POST);
			}
			else
				die("Invalid Service Call 0"); //throw new ErrorException("Invalid Service Call",1);
		}
		catch(Exception $e){
			die (ErrorHandler::Interpret($e));	
		}
	}
	elseif(isset($_GET['s'])&&$_GET['s']==='printing'){
		try{
			$s = CONFIG_PREFIX.$_GET['s'];
			$a = $_GET['a'];
            if(class_exists($s)) {
                $obj = new $s();
                if(method_exists($s,$a)) echo $obj->{$a}($_GET);
            }
            else
               	die("Invalid Service Call $s $a"); //throw new ErrorException("Invalid Service Call",1);
		}
		catch(Exception $e){
			die (ErrorHandler::Interpret($e));	
		}
	}
	elseif(isset($_POST['b'])) {
		$_SESSION['lb'] = $_POST['b']; 
		echo "<script type='text/javascript' src='".CONFIG_PAGEURL.$_SESSION['lb'].".js'></script>";
	}
	else {//b not set, e.g. browser's refresh button hit.
		//if the lastboot value (start page or login page) has already been set, then
		//load it, otherwise, load the login page.
		$_SESSION['lb'] = isset($_SESSION['lb']) ? $_SESSION['lb'] : 'login';
		echo "<script type='text/javascript' src='".CONFIG_PAGEURL.$_SESSION['lb'].".js'></script>";
	}
?>