<?php

class Receipt {
	


	 public function PrintReciept(){
         $dte = date('Y-m-d \a\t h:i A');
         $sd = array(array('pnm'=>"Almayasa Infinix", 'nqy'=>"23", 'amt'=>"284", 'pmt'=>"3456"),
         array('pnm'=>"Note Hot 7", 'nqy'=>"26", 'amt'=>"45", 'pmt'=>"456"));
         

         return json_encode(array("success"=>"true","sd"=>$sd));
			
	}
	
}
?>
