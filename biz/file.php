<?php
    include_once "config.php";
    include_once "autoload.php";
    
    new KPSession();
    $error = new ErrorHandler();
    try {
        #Access Control
        $pp = $fs = array();
        $error->ValidateMandatoryFields($pp, $_SESSION['us']['rid'], $fs);
        #Processing
    $filepath=$_GET['nm'];
    $fpi = pathinfo($filepath);
    $ext=$fpi['extension'];
	$filename = basename(basename($filepath),".$ext");
	
// 	$nam = $_GET['nam'];
// 	error_log($nam);
	
// 	$crvfile=CONFIG_ADMCRVFILES.$filename;
// 	$trsfile=CONFIG_ADMTRSFILES.$filename;
// 	$uplfile=CONFIG_UPLOADPATH.$filename;
// 	$zipphoto=CONFIG_PHOTOPATH.$filename;
// 	$filepath = (file_exists($crvfile)?$crvfile:(file_exists($trsfile)?$trsfile:(file_exists($zipphoto)?$zipphoto:($uplfile))));
	error_log("================================================");
	error_log($filepath);
	error_log($filename);
	error_log("=================================================");
	
// 	if(!preg_match('/^([-_\w]+)\.(\w{3,4})$/',$filename.".$ext",$m)){
//             throw new ErrorException("Unknown file name.", 5, 2);
// 	}
// 	else
		if(file_exists($filepath)) {
//             $fpi = pathinfo($filepath);
//             $ext=$fpi['extension'];
//             $filename = basename(basename($filepath),".ext");
            
            switch($ext){
                case 'pdf':
                    sendpdf($filename, $filepath);
                break;
                case 'doc':
                    senddoc($filename, $filepath);
                break;
                case 'docx':
                    senddocx($filename, $filepath);
                break;
                case 'zip':
                	if(!preg_match('/^([-_\w]+)\.(\w{3,4})$/',$filename.".$ext",$m)){
                		throw new ErrorException("Unknown file name.", 5, 2);
                	}
                	sendzip($filename, $filepath);
                	break;
                default:
                   throw new ErrorException("Invalid file type.", 5, 2);
            }
		
	}
	else {
            throw new ErrorException("File not found.", 5, 2);
	}
        
    } 
    catch (ErrorException $e) {
        die($error->Interpret($e));
    }

    function sendpdf($refno,$filepath){
        header("Cache-control: no-store");
        header("Content-type: application/pdf");
        header("Content-Disposition: inline, filename=$refno.pdf");
        //$filename = '/public_html/syllabus.pdf';
        readfile($filepath);
    }
    
    function senddoc($refno,$filepath){
        header("Cache-control: no-store");
        header("Content-type: application/pdf");
        header("Content-Disposition: inline, filename=$refno.doc");
        //$filename = '/public_html/syllabus.pdf';
        readfile($filepath);
    }
    
            
    function senddocx($refno,$filepath){
        header("Cache-control: no-store");
        header("Content-type: application/vnd.openxmlformats-officedocument.wordprocessingml.document");
        header("Content-Disposition: inline, filename=$refno.docx");
        //$filename = '/public_html/syllabus.pdf';
        readfile($filepath);
    }
    
    function sendzip($refno,$filepath){
    	header("Cache-control: no-store");
    	header("Content-type: application/zip");
    	header("Content-Disposition: attachement, filename=$refno.zip");
    	header("Content-Length: " . filesize($filepath));
    	readfile($filepath);
    	unlink($file);
    }