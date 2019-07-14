<?php
	class KPXTemplate extends AppBase{
		//constructor: prepare initializations here
		public function __construct(){
			parent::__construct();
			$p = '{"rid":"n","pid":"n","pyr":"n","sem":"n","eyr":"n","ryr":"n","pgi":"n","xno":"t","gmn":"n","gmx":"n","sts":"n"}';
			$this->props = json_decode($p,true);
			$this->debug = true;
		}
		public function reportheader($pg,$row,$pcd,$nxd){
			$nam = $row['nam'];
			$mno = $row['mno'];
			$pho = $row['pho'];
			$tel = $row['tel'];
			$cfn = strtoupper($row['cfn']);

			//Get system Settings
			$sto=new KPSettings();
			$srs=$sto->Search(array('hsh'=>1));
			$srd= json_decode($srs,true);
			if(!(isset($srd['success'])&&is_array($srd['sd']))){
				//error_log('Error in KPSettings->Search'.$srs);
				return $this->PrintError('Error','Error Retrieving System Settings. Check the logs.');
			}
			$rc = $srd['rc'];
			$hd = $srd['hd'];
			$sch['cnt'] = $hd['ADMLET_CONTACT'];
			$sch['pad'] = $hd['ADMLET_ADDRESS'];
			$sch['ref'] = $hd['ADMLET_REF'];
			$sch['tel'] = $hd['ADMLET_TEL'];
			$sch['fax'] = $hd['ADMLET_FAX'];
			$sch['rdt'] = $hd['ADMLET_REOPEN'];
			$sch['vdt'] = $hd['ADMLET_VACSTART'];
			$sch['add'] = $hd['ADMLET_ADDRESS'];
			$sch['loc'] = $hd['ADM_LOCATION'];
			$rop = $sch['rdt'];
			$vac = $sch['vdt'];
			$dte = date('Y-m-d');
			//$logo = '../photos/kplogo.png';
			$logo = '../photos/kplogo.png';
			$lgo='"'.$logo.'"';

			$pic = file_exists(CONFIG_PHOTOPATH.$pho)?"../photos/$pho":"../photos/sample.png";
			$pho='"'.$pic.'"';


			return <<<EOD
							<table border="0" cellpadding="0" cellspacing="0" align="left">
					<tr nobr="true">
					<td align="left">
					Tel: $sch[tel]<br />
					Address: <font size="9px">$sch[add]</font><br />
					Location: <font size="9px">$sch[loc]</font><br/>
					</td>
					<td align="center">
					<span style="text-align:center;"><img src=$lgo width="303px" height="214px" border="0"></span>
					</td>
					<td align="right">
					<span style="text-align:center;"><img src=$pho width="203px" height="200px" border="0"></span>
					</td>
					</tr>
					</table>

					<table border="0" cellpadding="0" cellspacing="0" nobr="true">

					<tr nobr="true">
					<td align="left">Name: <b>$nam</b></td>
					<td align="right">A/C Number: <b>$mno</b></td>
					</tr>
					<tr nobr="true">
					<td align="left">Mobile: <b>$tel</b></td>
					<td align="right">Date printed: <b>$dte</b></td>
					</tr>
					</table>
					<hr>
EOD
			;

		}

		public function reportform($pg,$row,$pcd,$nxd,$arc){

			$stq=new KPSettings();
			$srs=$stq->Search(array('hsh'=>1));
			$srd= json_decode($srs,true);
			if(!(isset($srd['success'])&&is_array($srd['sd']))){
				//error_log('Error in KPSettings->Search'.$srs);
				return $this->PrintError('Error','Error Retrieving System Settings. Check the logs.');
			}
			$rc = $srd['rc'];
			$hd = $srd['hd'];
			$sch['ndt'] = $hd['ADMLET_DAYS_OF_TERM'];



			$pcs = '';
			$pmt = 0.0;
			foreach($pcd as $pc){
				$amt = number_format($pc[amt],2,'.',',');
				$pmt = number_format($pmt + $pc[amt],2,'.',',');
				$pcs.= <<<EOD
				       <tr nobr="true" bgcolor="#E8E8E8">
					   <td align="left">$pc[dcd]</td>
					   <td align="center">$pc[scd]</td>
					   <td align="center">$amt</td>
					   </tr>
					   <tr>
						  <td>
							&nbsp;
						  </td>
					   </tr>
EOD;
			}

			$prs = '';
			$prt=0.0;
			foreach($nxd as $pc){
				$prc = number_format($pc[prc],2,'.',',');
				$amt = number_format($pc[qty] * $pc[amt],2,'.',',');
				$prt = number_format($prt + $amt,2,'.',',');
				$prs.= <<<EOD
				       <tr nobr="true" bgcolor="#E8E8E8">
					   <td align="left">$pc[nam]</td>
					   <td align="center">$pc[scd]</td>
					   <td align="center">$pc[qty]</td>
						 <td align="center">$prc</td>
						 <td align="center">$amt</td>
						 <td align="center">$pc[dat]</td>
					   </tr>
					   <tr>
						  <td>
							&nbsp;
						  </td>
					   </tr>
EOD;
			}

			return <<<EOD
				<table width=100%>
				 <tr>
				 <td>
				  &nbsp;
				 </td>
			     </tr>
				</table>
				<table width=100%>
				 <tr bgcolor="#E8E8E8" nobr="true">
				  <th width="30%"><b><u>Date Paid</u></b></th>
				  <th align="center" width="30%"><b><u>TransactionID</u></b></th>
				  <th align="center" width="40%"><b><u>Amount (GHC)</u></b></th>
				 </tr>
				<tr>
					<td>
					  &nbsp;
					</td>
			     </tr>
				 	$pcs
				</table>
				<table>
				<tr  bgcolor="#E8E8E8">
					<th width="30%"></th>
					<th align="center" width="30%"><b>TOTAL</b></th>
					<th align="center" width="40%"><b><u>GHC $pmt</u></b></th>
				</tr>
				<tr>
				<td>
				  &nbsp;
        		</td>
				</tr>
				</table>
				<hr>
				<table width=100%>
				<tr>
				<td>
					&nbsp;
					</td>
				</tr>
				 <tr bgcolor="#E8E8E8" nobr="true">
				  <th width="30%"><b><u>Item</u></b></th>
				  <th align="center" width="15%"><b><u>SalesID</u></b></th>
					<th align="center" width="10%"><b><u>Qty</u></b></th>
					<th align="center" width="10%"><b><u>Price (GHC)</u></b></th>
				  <th align="center" width="15%"><b><u>Amount (GHC)</u></b></th>
					<th align="center" width="20%"><b><u>Date</u></b></th>
				 </tr>
				<tr>
					<td>
					  &nbsp;
					</td>
			     </tr>
				 	$prs
				</table>
				<table>
				<tr  bgcolor="#E8E8E8">
					<th width="30%"></th>
					<th align="center" width="20%"><b></b></th>
					<th align="center" width="10%"><b>TOTAL</b></th>
					<th align="center" width="10%"><b></b></th>
					<th align="center" width="15%"><b><u>GHC $prt</u></b></th>
					<th align="center" width="20%"></th>
				</tr>
				<tr>
				<td>
				  &nbsp;
        		</td>
				</tr>
				</table>
EOD;

		}

		public function reportfooter($pg,$xg){
			$dpn = strtoupper($pg['dpn']);
			$dtn = strtoupper($pg['dtn']);
			$hdn = strtoupper($pg['hdn']);
			$unm = $pg['unm'];
			$dnm = strtoupper($pg['dnm']);
			$pnm = strtoupper($pg['nam']);
			$sts = strtoupper($xg['sts']);
			$cls = strtoupper($xg['cls']);
			//$hsg = PDF_ADM_SIGNATURE;
			$stq=new KPSettings();
			$srs=$stq->Search(array('hsh'=>1));
			$srd= json_decode($srs,true);
			if(!(isset($srd['success'])&&is_array($srd['sd']))){
				//error_log('Error in KPSettings->Search'.$srs);
				return $this->PrintError('Error','Error Retrieving System Settings. Check the logs.');
			}
			$rc = $srd['rc'];
			$hd = $srd['hd'];
			$sch['hed'] = $hd['ADMLET_SIGNAME'];
			$unm = $unm.".png";
			$pic = file_exists(CONFIG_PHOTOPATH.$unm)?"../photos/$unm":"../photos/sample.png";
			$sig='"'.$pic.'"';

			$hph = "head.png";
			$hpc = file_exists(CONFIG_PHOTOPATH.$hph)?"../photos/$hph":"../photos/sample.png";
			$hsg='"'.$hpc.'"';

			return <<<EOD
				<br/><br/>
				<table border="0" cellpadding="0" cellspacing="0" align="left">
				<tr>
						<td align="left">

						</td>
						<td align="right">
							<span style="text-align:right"><img style="width:400px; height:200px;" src=$hsg alt="signed" border="0"></span><br/>
							Officer<br/> kofi
						</td>
					</tr>
				</table>
				<table>
				<tr>
					<td>
					  &nbsp;
        			</td>
				</tr>
				<tr>
					<td>
					  &nbsp;
        			</td>
				</tr>
				</table>
				<hr>
				<!--<table border="0" cellpadding="0" cellspacing="0" align="left">
				<tr nobr="true">
				  <th colspan="4" align="center"><b><u>GRADING SYSTEM</u></b></th>
				</tr>
				</table>
				<table colspan="4" border="1">
				<tr nobr="true">
				  <td>75 - 100%&nbsp;   1::Distinction</td>
				  <td>70 - 74%&nbsp;    2 :: Excellent</td>
				  <td>65 - 69%&nbsp;	3 :: Very Good</td>
				  <td>60 - 64%&nbsp;	4 :: Good</td>
				  <td>55 - 59%&nbsp;	5 :: Credit</td>
				</tr>
				<tr nobr="true">
				  <td>50 - 54%&nbsp;	6 :: Pass</td>
				  <td>45 - 49%&nbsp;	7 :: Weak</td>
				  <td>40 - 44%&nbsp;	8 :: Very Weak</td>
				  <td> 0 - 39%&nbsp;	9 :: Fail</td>
				</tr>
				</table>-->
EOD
		;

		}

}
?>
