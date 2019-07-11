<?php
	class Rcl extends KPBase{
		//constructor: prepare initializations here
        private $props;
		public function __construct(){
			parent::__construct(); 
			
		}

		private function fdd($dt,$ft='Y-m-d'){
			return date($ft,strtotime($dt));
		}
		
		

		public function GetCols($pd){
			try {
                if($pd == 'sp_sales_find'){
                    $m = array(
						array("p"=>0,"c"=>"rid","t"=>"No","w"=>10,"h"=>0,"l"=>"TLB","a"=>"L","f"=>"N"),
						array("p"=>1,"c"=>"nam","t"=>"Product","w"=>50,"h"=>0,"l"=>"TLB","a"=>"L","f"=>"T"),
						array("p"=>2,"c"=>"qty","t"=>"Qty","w"=>15,"h"=>0,"l"=>"TLB","a"=>"L","f"=>"N"),
						array("p"=>3,"c"=>"amt","t"=>"Price","w"=>20,"h"=>0,"l"=>"TLB","a"=>"R","f"=>"M"),
						array("p"=>4,"c"=>"tot","t"=>"Total","w"=>20,"h"=>0,"l"=>"TLB","a"=>"R","f"=>"M"),
						array("p"=>5,"c"=>"scd","t"=>"Sales Code","w"=>30,"h"=>0,"l"=>"TLB","a"=>"R","f"=>"N"),
						array("p"=>6,"c"=>"ctn","t"=>"Category","w"=>30,"h"=>0,"l"=>"TLB","a"=>"L","f"=>"N"),
						array("p"=>7,"c"=>"dat","t"=>"Date Updated","w"=>30,"h"=>0,"l"=>"TLBR","a"=>"R","f"=>"N"));
                    
                    $ard['gnm']="SALES";
					$ls = 'L';
                 } else {
                     $m = array(
						array("p"=>0,"c"=>"rid","t"=>"No","w"=>10,"h"=>0,"l"=>"TLB","a"=>"L","f"=>"N"),
						array("p"=>1,"c"=>"nam","t"=>"Product","w"=>50,"h"=>0,"l"=>"TLB","a"=>"L","f"=>"T"),
						array("p"=>2,"c"=>"qty","t"=>"Qty","w"=>15,"h"=>0,"l"=>"TLB","a"=>"L","f"=>"N"),
						//array("p"=>3,"c"=>"amt","t"=>"Price","w"=>20,"h"=>0,"l"=>"TLB","a"=>"R","f"=>"M"),
						array("p"=>4,"c"=>"tot","t"=>"Total","w"=>20,"h"=>0,"l"=>"TLB","a"=>"R","f"=>"M"),
						//array("p"=>5,"c"=>"scd","t"=>"Sales Code","w"=>30,"h"=>0,"l"=>"TLB","a"=>"R","f"=>"N"),
						array("p"=>6,"c"=>"ctn","t"=>"Category","w"=>30,"h"=>0,"l"=>"TLB","a"=>"L","f"=>"N"),
						array("p"=>7,"c"=>"dat","t"=>"Date Updated","w"=>30,"h"=>0,"l"=>"TLBR","a"=>"R","f"=>"N"));
                    
                    $ard['gnm']="CURRENT PRODUCTS";
					$ls = 'P';
                 }
				
				return array($m,$ard,$ls);
            }
            catch(ADODB_Exception $e){
                //if($cnn)  $cnn->Close();
                return ErrorHandler::InterpretADODB($e);
            }
            catch(Exception $e){
                //if($cnn)  $cnn->Close();
                return ErrorHandler::Interpret($e);
            }
        }

		
		
	}
?>