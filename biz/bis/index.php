<?php

  include_once "config.php";
  include_once "autoload.php";
  require_once 'dompdf/lib/html5lib/Parser.php';
  require_once 'dompdf/lib/php-font-lib/src/FontLib/Autoloader.php';
  require_once 'dompdf/lib/php-svg-lib/src/autoload.php';
  require_once 'dompdf/src/Autoloader.php';
  Dompdf\Autoloader::register();
  session_start();


	header('Access-Control-Allow-Origin: *');
	header('Access-Control-Allow-Methods: GET, POST, PATCH, PUT, DELETE, OPTIONS');
	header('Access-Control-Allow-Headers: Origin, Content-Type,Cookies');
  header('Access-Control-Expose-Headers: Content-Disposition');

	//$POST = json_decode(file_get_contents('php://input'),true);

  // error_log(print_r($_GET,true));

  if(isset($_POST['s']) && $_POST['m']=='l'){ //when a service is requested
		try
		{
		    if(isset($_POST['m']) && $_POST['m']=='c'){
		        if(!$_SESSION['us']['rid'])	$_SESSION['us']=array('rid'=>0);
	        }

            $s = $_POST['s'];
			      $a = $_POST['a'];

            //error_log(print_r($_SESSION['us']['rid'],true));

			$_SESSION['us']['rid']=$_POST['uid'];
			$_SESSION['PHPSESSID'] = $_POST['ssi'];
			if(class_exists($s)) {
              $obj = new $s();
              // error_log(print_r($_POST,true));
				if(method_exists($s,$a)) {
          echo $obj->{$a}($_POST);
        } else {
          // error_log('kjjjjjjjjjjjjjjjjjjjjjjj');
        }

			}
			else
				die("Invalid Service Call 00"); //throw new ErrorException("Invalid Service Call",1);
		}
		catch(Exception $e){
			die (ErrorHandler::Interpret($e));
		}
	}
  elseif(isset($_POST['i']) && $_FILES['image']['size']>0){ //when a service is requested
		try
		{
		    if(isset($_POST['m']) && $_POST['m']=='c'){
		        if(!$_SESSION['us']['rid'])	$_SESSION['us']=array('rid'=>0);
	        }

            $s = $_POST['i'];
			      $a = $_POST['a'];

            //error_log(print_r($_SESSION['us']['rid'],true));

			$_SESSION['us']['rid']=$_POST['uid'];
			$_SESSION['PHPSESSID'] = $_POST['ssi'];
			if(class_exists($s)) {
        $obj = new $s();
				if(method_exists($s,$a)) echo $obj->{$a}($_POST,$_FILES);

			}
			else
				die("Invalid Service Call 0"); //throw new ErrorException("Invalid Service Call",1);
		}
		catch(Exception $e){
			die (ErrorHandler::Interpret($e));
		}
	}
  elseif(isset($_GET['s']) && $_GET['s']==='rp'){

		try{
			$s = $_GET['s'];
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
   elseif (isset($_POST['s']) && $_POST['m']=='undefined') {
     # code...
		$sess = new KPSessionWrite();
		$sesswrite = $sess->Open(session_id());

		echo json_encode(array('PHPSESSID' => session_id() ));
	}




?>
