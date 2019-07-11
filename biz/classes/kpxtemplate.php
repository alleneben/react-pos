<?php
	class KPXTemplate extends KPBase{
		//constructor: prepare initializations here
		public function __construct(){
			parent::__construct();
			$p = '{"rid":"n","pid":"n","pyr":"n","sem":"n","eyr":"n","ryr":"n","pgi":"n","xno":"t","gmn":"n","gmx":"n","sts":"n"}';
			$this->props = json_decode($p,true);
			$this->debug = true;
		}

		public function statementheader($pg,$row,$pcd,$nxd){
			$pnm = strtoupper($pg['nam']);
			$nam = $row['nam'];
			$xno= $row['xno'];
			$dte = date('Y-m-d');
			return <<<EOD
				<table border="0" cellpadding="0" cellspacing="0" nobr="true">

				  <tr nobr="true">
				    <td align="left">Name: <b>$nam</b></td>
				    <td align="right">Exam Number: <b>$xno</b></td>
				  </tr>
				  <tr nobr="true">
				    <td align="left">Programme of Study:<b>$pnm</b></td>
					<td align="right">Date printed: <b>$dte</b></td>
					</tr>
				</table>
				<hr/>
EOD
			;

		}



    }
?>
