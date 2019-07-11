<?php
// CSV Printing
class CSVPrinter {

	public function __construct(){
		//
	}
	public function buildCSV($in,$hd,$fname="filename",$sum=true) {
		try{
			if(count($in)==0){
			}
			else{
				$hashdr = ($sum && is_array($hd)) || false;
				$dhd = $hashdr?array_intersect_key($in[0],$hd):$in[0];
				$hout="";
				foreach($dhd as $key => $val){
					$hdr = (is_array($hd) && $hd[$key]) ? $hd[$key] : $key;
					$hout .= preg_match('/\,|\s|\W/',$hdr)?'"'.$hdr.'",':$hdr.',';
				}
				$out = preg_replace('/^(.*),$/',"$1\n",$hout);
					
				foreach ($in as $rec){
					$rec1 = $hashdr?array_intersect_key($rec,$hd):$rec;
					$rout="";
					foreach($rec1 as $key => $val){
						$rout .= preg_match('/\,|\s|\W|0[1-9]/',$val)?'"'.$val.'",':$val .',';
					}
					$out .= preg_replace('/^(.*),$/',"$1\n",$rout);
				}
				header ("Content-Type: application/msexcel;charset=UTF-8");
				header ("Content-Disposition: attachment; filename=\"$fname.csv\"");
				echo $out;
			}
		}
		catch(Exception $e){
			error_log($e->getMessage());
		}
	}
}

?>
