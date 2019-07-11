<?php
include_once "config.php";

	$imgname = $_GET['nam'];
	$imgpath = CONFIG_PHOTOPATH.$imgname;
	$noimage = CONFIG_PHOTOPATH."sample.jpg";
	if(!preg_match('/^([-_\w]+)\.(\w{3})$/',$imgname,$m)){
		$im  = blankimage($noimage);
	}
	elseif(file_exists($imgpath)) {
		$ipi = pathinfo($imgpath);
		switch($ipi['extension']){
			case 'png':
			  $im = getpng($imgpath);
			break;
			case 'jpg':
			case 'jpeg':
			  $im = getjpg($imgpath);
			break;
			case 'gif':
			  $im = getgif($imgpath);
			break;
			default:
			   $im  = blankimage($imgpath);
		}
		
	}
	else {
		$ipi = pathinfo($imgpath);
		$im = blankimage($imgpath);
	}

	function getjpg($imgpath){
		$im = imagecreatefromjpeg($imgpath);
		if(!$im) $im  = blankimage($imgpath);
		header("Content-Type: image/jpg");
		imagejpeg($im);
		imagedestroy($im);
    }
	
	function getpng($imgpath){
    	$im = imagecreatefrompng($imgpath);
		if(!$im) $im  = blankimage($imgpath);
		header("Content-Type: image/png");
		imagepng($im);
		imagedestroy($im);
    }
	
	function getgif($imgpath){
    	$im = imagecreatefromgif($imgpath);
		if(!$im) $im  = blankimage($imgpath);
		header("Content-Type: image/gif");
		imagegif($im);
		imagedestroy($im);
    }
    
	/* Create a blank image */
	function blankimage($imgpath){
    	$im  = imagecreatetruecolor(150, 30);
		//TODO: create a transparent image by fading
        $bgc = imagecolorallocate($im, 255, 255, 255);
		$tc  = imagecolorallocate($im, 0, 0, 0);
        imagefilledrectangle($im, 0, 0, 150, 30, $bgc);
		//$nam = preg_replace('/^(.*)\/(\w+)\.(\w{3})$/','\2',$imgpath);
		$nam = "";
		imagestring($im, 3, 5, 10, $nam, $tc);
		return $im;
    }
?>