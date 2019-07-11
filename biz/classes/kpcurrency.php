<?php

class KPCurrency extends KPBase{
	/**
	 * 
	 * Class Constructor
	 *   - Initialize superclass
	 */
	public function __construct(){
		parent::__construct(); 
	}
	/**
	 * 
	 * Generate the admission letter in html embedding
	 * the corresponding template data  ...
	 * @param array $let letter data [ttl,dte,sal,sgn,sgt]
	 * @param array $sch school data [cnt,tel,fax,ref,pad,acy,rdt,lgo]
	 * @param array $pro program data [dpt,pnm,fee,bnk,acc,sdt,edt,dln]
	 * @param array $can candidate data [nam,pad,tel,ixn]
	 * @return string
	 */
	public function Moneyinwords($money,$hyphen='-',$conjunction=' and ',$separator=', ',$negative='negative ',$decimal=' Cedis ',$cent=' Pesewas '){
		return (strpos($money, '.') == false?
				$this->digitstomoney($money,$hyphen,$conjunction,$separator,$negative,$decimal,$cent).$decimal:
				(strlen(substr(strrchr(round($money,2), "."), 1))==0?
						$this->digitstomoney($money,$hyphen,$conjunction,$separator,$negative,$decimal,$cent).$decimal:
						($this->digitstomoney($money,$hyphen,$conjunction,$separator,$negative,$decimal,$cent)
						)));
	
	}
	
	public	function digitstomoney($number,$hyphen='-',$conjunction=' and ',$separator=', ',$negative='negative ',$decimal=' Cedis ',$cent=' Pesewas ') {
		$number =round($number,2);
		// 			$hyphen      = '-';
		// 			$conjunction = ' and ';
		// 			$separator   = ', ';
		// 			$negative    = 'negative ';
		// 			$decimal     = ' Cedis ';
		// 			$cent	 = ' Pesewas ';
		$dictionary  = array(
				0                   => '',
				1                   => 'one',
				2                   => 'two',
				3                   => 'three',
				4                   => 'four',
				5                   => 'five',
				6                   => 'six',
				7                   => 'seven',
				8                   => 'eight',
				9                   => 'nine',
				10                  => 'ten',
				11                  => 'eleven',
				12                  => 'twelve',
				13                  => 'thirteen',
				14                  => 'fourteen',
				15                  => 'fifteen',
				16                  => 'sixteen',
				17                  => 'seventeen',
				18                  => 'eighteen',
				19                  => 'nineteen',
				20                  => 'twenty',
				30                  => 'thirty',
				40                  => 'fourty',
				50                  => 'fifty',
				60                  => 'sixty',
				70                  => 'seventy',
				80                  => 'eighty',
				90                  => 'ninety',
				100                 => 'hundred',
				1000                => 'thousand',
				1000000             => 'million',
				1000000000          => 'billion',
				1000000000000       => 'trillion',
				1000000000000000    => 'quadrillion',
				1000000000000000000 => 'quintillion'
		);
	
		if (!is_numeric($number)) {
			return false;
		}
	
		if (($number >= 0 && (int) $number < 0) || (int) $number < 0 - PHP_INT_MAX) {
			// overflow
			trigger_error(
			'the function only accepts numbers between -' . PHP_INT_MAX . ' and ' . PHP_INT_MAX, E_USER_WARNING
			);
			return false;
		}
	
		if ($number < 0) {
			return $negative . $this->digitstomoney(abs($number));
		}
	
		$string = $fraction = null;
	
		if (strpos($number, '.') !== false) {
			list($number, $fraction) = explode('.', strlen(substr(strrchr($number, "."), 1))==1?$number:sprintf("%01.2f",$number));
	
		}
	
		switch (true) {
			case $number < 21:
				$string = $dictionary[$number];
				break;
			case $number < 100:
				$tens   = ((int) ($number / 10)) * 10;
				$units  = $number % 10;
				$string = $dictionary[$tens];
				if ($units) {
					$string .= $hyphen . $dictionary[$units];
				}
				break;
			case $number < 1000:
				$hundreds  = $number / 100;
				$remainder = $number % 100;
				$string = $dictionary[$hundreds] . ' ' . $dictionary[100];
				if ($remainder) {
					$string .= $conjunction . $this->digitstomoney($remainder);
				}
				break;
			default:
				$baseUnit = pow(1000, floor(log($number, 1000)));
				$numBaseUnits = (int) ($number / $baseUnit);
				$remainder = $number % $baseUnit;
				$string = $this->digitstomoney($numBaseUnits) . ' ' . $dictionary[$baseUnit];
				if ($remainder) {
					$string .= $remainder < 100 ? $conjunction : $separator;
					$string .= $this->digitstomoney($remainder);
				}
				break;
		}
	
		if (null !== $fraction && $fraction <>0 && is_numeric($fraction)) {
			$string = $number==0?$string:$string . $decimal . $conjunction ;
			$words = array();
			foreach (str_split((string) $fraction) as $number) {
				$words[] = $dictionary[$number];
			}
			$string .= $this->digitstomoney($fraction).$cent;
			//implode(' ', $words);
			// 			}else {
			// 				$string .= $decimal;
			}
	
			return $string;
	}
	}
?>
