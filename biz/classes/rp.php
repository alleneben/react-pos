<?php
use Dompdf\Dompdf;
class Rp extends AppBase{

	//constructor: prepare initializations here
    private $props;
	public function __construct(){
		parent::__construct();
	}

	private function getTbLen($meta){
		$len = 0;
		for($i=0;$i<count($meta);$i++){
			$len+=$meta[$i]['w'];
		}
		return $len;
	}

	private function DocSetup($pdf,$logo,$hdtxt,$rtm=0,$rhm=0) {
		// set document information
		$pdf->SetCreator(PDF_CREATOR);
		$pdf->SetAuthor("Ernie Ofori");
		$pdf->SetTitle("Institutional Support Services");
		$pdf->SetSubject("KPISP v 1.0");
		$pdf->SetKeywords("kpoly, kpportal, portal, admission, registration, examination, finance, ernieofori");
		// set default header data
		$rep_title = "Institutional Support Services";
		$rep_string = $hdtxt;
		$pdf->SetHeaderData($logo, PDF_HEADER_LOGO_WIDTH, $rep_title, $rep_string);
		// set header and footer fonts
		$pdf->setHeaderFont(Array(PDF_FONT_NAME_MAIN, '', PDF_FONT_SIZE_MAIN));
		$pdf->setFooterFont(Array(PDF_FONT_NAME_DATA, '', PDF_FONT_SIZE_DATA));
		//set margins
		$pdf->SetMargins(PDF_MARGIN_LEFT, PDF_MARGIN_TOP-$rtm, PDF_MARGIN_RIGHT);
		$pdf->SetHeaderMargin(PDF_MARGIN_HEADER-$rhm);
		$pdf->SetFooterMargin(PDF_MARGIN_FOOTER);
		//set auto page breaks
		$pdf->SetAutoPageBreak(TRUE, PDF_MARGIN_BOTTOM);
		//set image scale factor
		$pdf->setImageScale(PDF_IMAGE_SCALE_RATIO);
		//set some language-dependent strings
		$l = array('a_meta_charset'=>"UTF-8",'a_meta_dir'=>"ltr",
				'a_meta_language'=>"en",'w_page'=>"page");
		$pdf->setLanguageArray($l);
		//initialize user defined parameters

		//initialize document
// 		$pdf->AliasNbPages();
		// add a page
		$pdf->AddPage();
		//return pdf object
		return $pdf;
	}

	private function GetXTopHeader($gd,$rep=""){
		$uda = $_SESSION['us'];
		$now =date('l jS, F Y \a\t h:i:s A');
		$hdtxt =<<<EOD
		<table>
		<table >
		<tr>
		<td style="text-align:right;font-size:25px;">Created on $now by  as </td>
		</tr>
		</table>
EOD;
		return $hdtxt;
	}

	private function GetXSummary($gd,$ard=false,$extrasumm=false){
		//may come from outside
		$uda = $_SESSION['us'];
		// $amt = number_format($ard['tt'],2,'.',',');
		$sdt = substr($gd['sdt'],0,10);
		$edt = substr($gd['edt'],0,10);

		if($edt==''){
			$edt=date("Y-m-d");
		}
		$extra = $extrasumm?"<tr><td colspan=2>$extrasumm</td></tr>":"";
		//$y=($gd['pyr']=='1'?'First year,':($gd['pyr']=='2'?'Second year,':($gd['pyr']=='3'?'Third year,':($gd['pyr']=='4'?'Fourth year,':''))));
		//$s=($gd['sem']=='1'?'First semester':($gd['sem']=='2'?'Second semester':($gd['sem']=='3'?'Supplementary semester':'')));
		//$course=$gd['pcn']?"<tr><td>Course: <strong>$gd[pcn]</strong></td></tr>":"";
		//$dpn=$gd['dpn']?"$gd[dpn],":"";
		$styl="";
		$top="
		$uda[enm] <br/>$ard[gnm] <br/><br/> TOTAL GHC <br/><br/> From:$sdt  To:$edt
		";
		$summ = <<<EOD
		<table cellspacing="0" cellpadding="1" border="0">
		<tr>
		<td style="text-align:center;">$top</td></tr>

		</table>
		<hr>
EOD;
		return $summ;
	}

	private function GetXProdcutListSummary($gd,$ard=false,$extrasumm=false){
		//may come from outside
		$uda = $_SESSION['us'];
		$amt = number_format($ard['tt'],2,'.',',');
		$sdt = substr($gd['sdt'],0,10);
		$edt = substr($gd['edt'],0,10);
		if($sdt==''){
			$amt='';
		}
		if($edt==''){
			$edt=date("Y-m-d");
		}
		$extra = $extrasumm?"<tr><td colspan=2>$extrasumm</td></tr>":"";
		//$y=($gd['pyr']=='1'?'First year,':($gd['pyr']=='2'?'Second year,':($gd['pyr']=='3'?'Third year,':($gd['pyr']=='4'?'Fourth year,':''))));
		//$s=($gd['sem']=='1'?'First semester':($gd['sem']=='2'?'Second semester':($gd['sem']=='3'?'Supplementary semester':'')));
		//$course=$gd['pcn']?"<tr><td>Course: <strong>$gd[pcn]</strong></td></tr>":"";
		//$dpn=$gd['dpn']?"$gd[dpn],":"";
		$styl="";
		$top="
		$uda[enm] <br/>$ard[gnm] <br/><br/> TOTAL GHC $amt<br/><br/> From:$sdt  To:
		";
		$summ = <<<EOD
		<table cellspacing="0" cellpadding="1" border="0">
		<tr>
		<td style="text-align:center;">$top</td></tr>

		</table>
		<hr>
EOD;
		return $summ;
	}

	private function GetXSalesSummary($gd,$ard=false,$extrasumm=false){
		//may come from outside
    $uda = $_SESSION['us'];
		$sdt = substr($gd['sdt'],0,10);
		$edt = substr($gd['edt'],0,10);

		if($edt==''){
			$edt=date("Y-m-d");
		}
    if ($sdt == '') {
      $sdt = 'Day 1';
    }
		$extra = $extrasumm?"<tr><td colspan=2>$extrasumm</td></tr>":"";
		$styl="";
		$top="
		$uda[enm] <br/>$ard[gnm]  <br/><br/> From:$sdt &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; To:$edt
		";
		$summ = <<<EOD
		<table cellspacing="0" cellpadding="1" border="0">
		<tr>
		<td style="text-align:center;">$top</td></tr>

		</table>
		<hr>
EOD;
		return $summ;
	}


	private function PDFGridXSetup($po,$pf,$meta,$summ,$hdtxt,$hdlogo="",$shp=true,$xsumm="",$tbhh=10){
		$pdf = new PDFPrinter($po, PDF_UNIT, $pf, true);
		$pdf->TbLen = $this->GetTbLen($meta);
		$pdf->TbMeta = $meta;
		$pdf->HShape = $shp;
		$pdf->TBHh = $tbhh;
		$pdf->XSumm = $xsumm;
		$logo=$hdlogo==""?PDF_HEADER_LOGO:$hdlogo;
		$pdf = $this->DocSetup($pdf,$logo,$hdtxt);
		return $pdf;
	}

	private function PDFGridSetup($po,$pf,$meta,$summ,$hdtxt,$hdlogo=""){
		$pdf = new PDFPrinter($po, PDF_UNIT, $pf, true);
		$pdf->TbLen = $this->GetTbLen($meta);
		$pdf->TbMeta = $meta;
		$logo=$hdlogo==""?PDF_HEADER_LOGO:$hdlogo;
		$pdf = $this->DocSetup($pdf,$logo,$hdtxt);
		return $pdf;
	}
	private function PDFXLetterSetup($po,$pf,$meta,$summ,$hdtxt,$foot="",$head="", $rtm=0,$rhm=0){
		$pdf = new PDFXLetter($po, PDF_UNIT, $pf, true);
		$pdf->FootData = $foot;
		$pdf->HEAD = $head;
		$pdf->HDTEXT=$hdtxt;
// 		$pdf->autoHeader=false;
		$pdf = $this->DocSetup($pdf,PDF_MAIN_LOGO,$hdtxt,$rtm,$rhm);
		return $pdf;
	}
	private function PDFLetterSetup($po,$pf,$meta,$summ,$hdtxt,$rtm=0,$rhm=0){
		$pdf = new PDFLetter($po, PDF_UNIT, $pf, true);
		$pdf = $this->DocSetup($pdf,K_BLANK_IMAGE,$hdtxt,$rtm,$rhm);
		return $pdf;
	}

	private function GetAuditData($gd){
		$uda = $_SESSION['us']['bd'];
		$uda['now'] = date('d-m-Y h:i');
		return $uda;
	}

	private function GetTopHeader($gd,$rep=""){
		//$uda = $_SESSION['us'];
		$hdtxt =<<<EOD
		<table style="width: 100%;">
		<tr>
		<td style="vertical-align:middle; text-align:center">XXXXX </td>
		<td style="text-align: right;vertical-align:bottom"><strong>Report:</strong>$rep</td>
		</tr>
		</table>
EOD;
		return $hdtxt;
	}

	private function GetNobHeader($gd,$acy=""){
		$ady= $acy + 1;
		$ayr = "$acy/$ady ADMISSIONS";
		$hdtxt = "
		<table style='width: 100%;'>
		<tr>
		<td style='vertical-align:middle; text-align:center'>XXXX</td>
		<td style='text-align: right;vertical-align:bottom'><strong>$ayr</strong></td>
		</tr>
		</table>";
		return $hdtxt;
	}




	public function getheader(){
		try{

			//Get system Settings
			$sto=new KPSettings();
			$srs=$sto->Search(array('hsh'=>1));
			$srd= json_decode($srs,true);
			if(!(isset($srd['success'])&&is_array($srd['sd']))){
				error_log('Error in KPSettings->Search'.$srs);
				return $this->PrintError('Error','Error Retrieving System Settings. Check the logs.');
			}
			$rc = $srd['rc'];
			$hd = $srd['hd'];

			//         		$cyr = date('Y');
			//         		$nyr = $cyr+1;
			//         		$sch['acy'] = "$cyr/$nyr";
			//         		$sch['rdt'] = $hd['ADMLET_REOPEN'];
			//         		$sch['cnt'] = $hd['ADMLET_CONTACT'];
			$sch['pad'] = $hd['ADMLET_ADDRESS'];
			$sch['ref'] = $hd['ADMLET_REF'];
			$sch['tel'] = $hd['ADMLET_TEL'];
			$sch['fax'] = $hd['ADMLET_FAX'];
			//         		$sch['bnk'] = $hd['ADMLET_BANKNAME'];
			//         		$sch['acc'] = $hd['ADMLET_BANKACCOUNT'];

			//         		$let['sal'] = $hd['ADMLET_SALUTATION'];
			//         		$let['sgn'] = $hd['ADMLET_SIGNAME'];
			//         		$let['sgt'] = $hd['ADMLET_SIGTITLE'];
			//         		$let['ttl'] = $hd['ADMLET_TITLE'];
			$sch['dte'] = date('jS F, Y');

			$sch['lgo'] = '../photos/kplogo.png';
			//         		$btech=$pro['pid']=='5'?"The structure of the program is as follows: i) HND for the first 3 years. ii) 1 year Industrial Work Experience/Relevant National Service and iii) 1 year top-up for the degree.":"";                                   //$btech== = "<span align='justify'>With reference to your  application,br />";
			//         		if($pro['cur']=='USD'){
			//         			$acnt='0451134470095301';
				//         			$sch['bnk']='Ecobank Ghana Limited';
				//         		}elseif($pro['pti']==1 or $pro['pti']==2){
				//         			$acnt='9060508849';
				//         		}elseif($pro['pid']==55){
				//         			$acnt='9060513622';
				//         			//}elseif($pro['pid']==53){
				//         			//	$acnt ='9060513630';
				//         		}elseif($pro['pid']>30 and $pro['pid']<38){
				//         			$acnt ='9060508874';
				//         		}else{
				//         			$acnt ='9060508874';
				//         		}

				$headhtml = "
				<table  style='vertical-align:top' cellspacing='0' cellpadding='0'>
				<tr><td>
				<table id='header' cellspacing='0' cellpadding='0' border='0' align='center'>
				<tr>
				<td align='left'>
				$sch[cnt]:<br />
				Tel: $sch[tel]<br />
				Fax: $sch[fax]<br />
				<!--br /-->
				Our Ref: $sch[ref]<br />
				Your Ref: ........<br />
				</td>
				<td align='center'>
				<span style='text-align:center'><img src='$sch[lgo]' width='68' height='64' border='0' /></span>
				</td>
				<td align='right'>
				$sch[pad]<br />
				<br />
				$sch[dte]
				</td>
				</tr>
				</table>";

				return $headhtml;
			}
			catch(Exception $e){
				return ErrorHandler::Interpret($e);
			}
		}

		public function PrintTableHead($pdf,$meta,$h=6,$fontsize=10,$border='TLRB',$valign='C',$fill=false){
			$pdf->SetFont('','B',$fontsize);
			$len = 0;
			for($i=0;$i<count($meta);$i++){
				$pdf->MultiCell($meta[$i]['w'],$h,$meta[$i]['t'],$border,0,$valign,$fill);
				$len+=$meta[$i]['w'];
			}
			$pdf->Ln();
			$pdf->SetFont('','',$fontsize);
			return $len;
		}
	private function GetSummary($extrasumm=false){
		//may come from outside
		$uda = $_SESSION['us'];
		$now = date('d-m-Y h:i');
		$extra = $extrasumm?"<tr><td colspan=2>$extrasumm</td></tr>":"";
		$summ = "
		<table>
		<tr><td>Created On: <strong>$now</strong></td><td>Created For: <strong>$uda[enm]</strong></td></tr>
		<tr><td>Requested By: <strong>$uda[nam]</strong></td><td>Role: <strong>$uda[rnm]</strong></td></tr>
		$extra
		</table>
		<hr>
		";
		return $summ;
	}




	public function RemoteForm($pd){
		try{
			$cd = array("cid"=>$pd['rid']);
			$sd = array("post"=>$pd);
			//report name
			$gnm = "Candidate Report";
			$sd['user']=$_SESSION['uda'];

			/** Candidate **/
			$can = new KPCandidate();
			$ars=$can->Search($pd);
			$ard= json_decode($ars,true);
			if(!(isset($ard['success'])&&is_array($ard['sd']))){
				echo $ars; exit;
			}
			$arc1 = $ard['rec'];
			$sd['cand']=$ard['sd'][0];
			/** Education (use $cd) **/
			$can = new KPEducation();
			$ars=$can->Search($cd);
			$ard= json_decode($ars,true);
			if(!(isset($ard['success'])&&is_array($ard['sd']))){
				echo $ars; exit;
			}
			$arc = $ard['rec'];
			$sd['educ']=$ard['sd'];
			/** Certificates **/
			$can = new KPCertificate();
			$ars=$can->Search($cd);
			$ard= json_decode($ars,true);
			if(!(isset($ard['success'])&&is_array($ard['sd']))){
				echo $ars; exit;
			}
			$arc = $ard['rec'];
			$sd['cert']=$ard['sd'];
			/** Employments **/
			$can = new KPEmployment();
			$ars=$can->Search($cd);
			$ard= json_decode($ars,true);
			if(!(isset($ard['success'])&&is_array($ard['sd']))){
				echo $ars; exit;
			}
			$arc = $ard['rec'];
			$sd['empl']=$ard['sd'];
			$_SESSION['print']=$sd;

			$stmp = date('Ymdhi');
			$fname = "kpcandidate.pdf";
			$dompdf = new DOMPDF();
			//$dompdf->set_paper("A4","landscape");
			$dompdf->load_html_file("print/appform.php");
			$dompdf->render();
			$dompdf->stream($fname);
			return true;
		}
		catch(DOMPDF_Exception $e){
			return ErrorHandler::InterpretDOMPDF($e);
		}
		catch(Exception $e){
			return ErrorHandler::Interpret($e);
		}
	}

	private function shorten($text,$nows=2){
		$new = preg_replace('/(.+)?\b\s\b(.*)?\b/','$1|$2',$text);
// 		error_log("ellipsed is $new");
	}


	private function FormatAddress($addr,$os = ',',$ns = '<br>'){
		$new = preg_replace('/\n/','<br />',$addr);
		$new = preg_replace('/([A-Z0-9])\s*(n)([A-Z\s])/','$1'.$os.'$3',$new);
		$new = preg_replace('/([A-Z])\s*n$/','$1',$new);
		$nn = strlen($new);
		$oc = strlen($os);
		$nc = strlen($ns);
		$pp = 0;
		for($i=0;$i<$nn;){
			if(!$cp = strpos($new,$os,$i)) break;
			elseif(($cp-$pp)>40){
				$new = substr_replace($new,$ns,$cp,$oc);
				$i = $pp = $cp+$nc;
			}
			else $i = $cp+$oc;
		}
		return $new;
	}
  public function Receipt($pd)
    {
        try {
            $type='lh';
            if ($type == 'alh') {
                // prepare Letter
                $kpl = new KPLetter();

                $html = $kpl->POSReceipt();

                // error_log($html);
                // ---------------------------------------------------------
                $hdtxt = "KXXXX";
                // Initialize and setup PDF
                $pdf = $this->PDFLetterSetup('P', 'A7', false, false, '', 7, 1);
                // set font
                $pdf->SetFont('helvetica', '', 2);
                $pdf->lastPage();
                $pdf->writeHTML($html, true, true);

                // Close and output PDF document
                $stmp = date('Ymdhi');
                $basefn = str_replace(array(
                    " ",
                    ","
                ), '_', 'allen') . '_' . $stmp;
                $pdf->Output("$basefn.pdf", "D");
            } else {
              $cv = '';
              $sum=0.0;
              // error_log(print_r($pd,true));
              foreach($pd as $rc){
                $sbt = number_format($rc['qty'] * $rc['prc'],2,'.',',');
                $prc = number_format($rc['prc'],2,'.',',');
                $sum = $sum + $sbt;
                $cv .= <<<EOD
                <tr class="service">
                    <td class="tableitem"><p class="itemtext">$rc[nam]</p></td>
                    <td class="tableitem"><p class="itemtext">$rc[qty]</p></td>
                    <td class="tableitem"><p class="itemtext">$prc</p></td>
                    <td class="tableitem"><p class="itemtext">$sbt</p></td>
                </tr>
EOD;
      				}
              $page = '
                <!DOCTYPE html>
                <html lang="en" >
                <head>
                  <meta charset="UTF-8">
                  <title>Receipt</title>
                  <style>
                    @media print {
                      .page-break { display: block; page-break-before: always; }
                    }
                    #invoice-POS {
                      box-shadow: 0 0 1in -0.25in rgba(0, 0, 0, 0.5);
                      padding: 2mm;
                      width: 58mm;
                      background: #FFF;
                    }
                    #invoice-POS ::selection {
                      background: #f31544;
                      color: #FFF;
                    }
                    #invoice-POS ::moz-selection {
                      background: #f31544;
                      color: #FFF;
                    }
                    #invoice-POS h1 {
                      font-size: 1.5em;
                      color: #222;
                    }
                    #invoice-POS h2 {
                      font-size: .9em;
                    }
                    #invoice-POS h3 {
                      font-size: 1.2em;
                      font-weight: 300;
                      line-height: 2em;
                    }
                    #invoice-POS p {
                      font-size: .7em;
                      color: #666;
                      line-height: 1.2em;
                    }
                    #invoice-POS #top, #invoice-POS #mid, #invoice-POS #bot {
                      border-bottom: 1px solid #EEE;
                    }
                    #invoice-POS #top {
                      min-height: 100px;
                    }
                    #invoice-POS #mid {
                      min-height: 80px;
                    }
                    #invoice-POS #bot {
                      min-height: 50px;
                    }
                    #invoice-POS #top .logo {
                      height: 60px;
                      width: 60px;
                      background: url(logo1.png) no-repeat;
                      background-size: 60px 60px;
                    }
                    #invoice-POS .clientlogo {
                      float: left;
                      height: 60px;
                      width: 60px;
                      background: url(client.jpg) no-repeat;
                      background-size: 60px 60px;
                      border-radius: 50px;
                    }
                    #invoice-POS .info {
                      display: block;
                      margin-left: 0;
                    }
                    #invoice-POS .title {
                      float: right;
                    }
                    #invoice-POS .title p {
                      text-align: right;
                    }
                    #invoice-POS table {
                      width: 100%;
                      border-collapse: collapse;
                    }
                    #invoice-POS .tabletitle {
                      font-size: .6em;
                      background: #EEE;
                    }
                    #invoice-POS .service {
                      border-bottom: 1px solid #EEE;
                    }
                    #invoice-POS .item {
                      width: 24mm;
                    }
                    #invoice-POS .itemtext {
                      font-size: .6em;
                    }
                    #invoice-POS #legalcopy {
                      margin-top: 5mm;
                    }
                  </style>
                  <script>
                    window.console = window.console || function(t) {};
                  </script>
                  <script>
                    if (document.location.search.match(/type=embed/gi)) {
                      window.parent.postMessage("resize", "*");
                    }
                  </script>
                </head>
                <body translate="no" >
                  <div id="invoice-POS">
                    <center id="top">
                      <div class="logo"></div>
                      <div class="info">
                        <h2>Mackerd</h2>
                      </div>
                    </center>
                    <div id="mid">
                      <div class="info">
                        <h2>Contact Info</h2>
                        <p>
                            Address : street city, state 0000</br>
                            Email   : JohnDoe@gmail.com</br>
                            Phone   : 555-555-5555</br>
                            Invoice#: '.$pd[0]['scd'].'</br>
                        </p>
                      </div>
                    </div>
                    <div id="bot">
                      <div id="table">
                        <table>
                          <tr class="tabletitle">
                            <td class="item"><h2>Item</h2></td>
                            <td class="Hours"><h2>Qty</h2></td>
                            <td class="Hours"><h2>Price</h2></td>
                            <td class="Rate"><h2>Sub Total</h2></td>
                          </tr>
                          '.$cv.'
                          <tr class="tabletitle">
                              <td></td>
                              <td></td>
                              <td class="Rate"><h2>tax</h2></td>
                              <td class="payment"><h2>GHC 0.00</h2></td>
                          </tr>
                          <tr class="tabletitle">
                              <td></td>
                              <td></td>
                              <td class="Rate"><h2>Total</h2></td>
                              <td class="payment"><h2> GHC '.number_format($sum,2,'.',',').'</h2></td>
                          </tr>
                        </table>
                    </div>
                    <div id="legalcopy">
                        <p class="legal">
                          <strong></strong>Payment is expected within 31 days; please process this invoice within that time. There will be a 5% interest charge per month on late invoices.
                        </p>
                    </div>
                    </div>
                  </div>
                </body>
                </html>
                ';

                // instantiate and use the dompdf class
                $dompdf = new Dompdf();
                $dompdf->loadHtml($page);

                // (Optional) Setup the paper size and orientation
                // $dompdf->setPaper('58mm', 'portrait');

                // Render the HTML as PDF
                $dompdf->render();

                // Output the generated PDF to Browser
                $dompdf->stream("kpcandidate.pdf");
            }
            return true;
        } catch (DOMPDF_Exception $e) {
            return ErrorHandler::InterpretDOMPDF($e);
        } catch (Exception $e) {
            return ErrorHandler::Interpret($e);
        }
    }

    public function Sales($gd){
  		try {
        // error_log(print_r($gd,true));
  			//Get List of registered Student for a course
  			$aco=new FD();
  			$ars=$aco->FetchReportData($gd);
  			$ard= json_decode($ars,true);
        // error_log(print_r($ard,true));
  			if(isset($ard['failure']))
  				return $this->PrintError($ard['et'],$ard['em']);
  			elseif(isset($ard['success'])&&!is_array($ard['sd'])){
  				return $this->PrintError('Error','Student not found in the registered list');
  			}
  			elseif(!(isset($ard['success'])&&is_array($ard['sd']))){
  				return $this->PrintError('Error','Error Retrieving registration list');
  			}
  			$arc = $ard['rc'];
  			$vcd = $ard['sd'];
  			$type = $gd['fmt'];

  			//=================Create Filename here===================
  			$gnm = 'h';//'Course Marksheet'; // = $gd['nam'];
        $ard['gnm'] = 'MACKERD ENT.';
  			$enm = 'Group'; //$usd['ENM'];
  			$stmp = date('Ymdhi');
  			$basefn = str_replace(' ','_','rep').'_'.str_replace(' ','_',$enm).'_'.$stmp;
  			//=================CSV Printing Starts here===================
  			if($type == 'csv'){
  				$hdr = array('rid'=>'Record',
  						'nam'=>'Name of Member',
  						'mno'=>'Member No.',
  						'cmn'=>'Biometric No.',
  						'tel'=>'Mobile No.',
  						'gpn'=>'Group'
  				);
  				$dmode = true; //($form=='sum') || false;
  				$csvhdr = $hdr;
  				$ocsv = new CSVPrinter();
  				return $ocsv->buildCSV($vcd,$csvhdr,$basefn,$dmode);
  			}
  			//=================PDF Printing Starts here===================
  			$pdffn = "$basefn.pdf";

  			$meta = array(
  					array("p"=>0,"c"=>"rid","t"=>"No","w"=>15,"h"=>0,"l"=>"TLB","a"=>"L","f"=>"N"),
  					array("p"=>1,"c"=>"nam","t"=>"Items","w"=>50,"h"=>0,"l"=>"TLB","a"=>"L","f"=>"T"),
  					array("p"=>2,"c"=>"qty","t"=>"Quantity","w"=>20,"h"=>0,"l"=>"TLB","a"=>"C","f"=>"T"),
  					array("p"=>3,"c"=>"amt","t"=>"Price/Unit, GHC","w"=>30,"h"=>0,"l"=>"TLB","a"=>"R","f"=>"M"),
            array("p"=>3,"c"=>"tot","t"=>"Total, GHC","w"=>20,"h"=>0,"l"=>"TLB","a"=>"R","f"=>"M"),
            array("p"=>3,"c"=>"pft","t"=>"Profit, GHC","w"=>20,"h"=>0,"l"=>"TLB","a"=>"R","f"=>"M"),
  					array("p"=>4,"c"=>"dat","t"=>"Dat","w"=>35,"h"=>0,"l"=>"TLB","a"=>"C","f"=>"T"),
            array("p"=>3,"c"=>"scd","t"=>"Code","w"=>40,"h"=>0,"l"=>"TLB","a"=>"C","f"=>"T"),
  					array("p"=>5,"c"=>"tel","t"=>"CustomerID","w"=>38,"h"=>0,"l"=>"TLBR","a"=>"C","f"=>"T")
  			);

        $pdff = 9;
  			$hdtxt = $this->GetXTopHeader($gd,$gnm);
  			$summ = $this->GetXSalesSummary($gd,$ard);
  			$pdf = $this->PDFGridXSetup('L','A4',$meta,$summ,$hdtxt,PDF_HEADER_SYS,true);
  			$pdf->SetTextColor(0);
  			$pdf->SetDrawColor(0,0,0);
  			$pdf->SetFont('dejavusans','B',14);
  			//Header
  			$fill=0;
  			$pdf->writeHTML($summ,true,true);
  			$pdf->Ln();
  			$pdf->SetLineWidth(.1);
  			$pdf->SetFont('','B',$pdff);
  			$pdf->SetFillColor(192, 192, 192);
  			//$len = 0;
  			for($i=0;$i<count($meta);$i++){
  				$pdf->xMultiCell($meta[$i]['w'],10,$meta[$i]['t'],'TLRB','L','C',$fill);
  				//$len+=$meta[$i]['w']
  			}
  			$pdf->Ln();
  			//Color and font restoration
  			$pdf->SetFillColor(246,246,246);
  			$pdf->SetTextColor(0);
  			$pdf->SetFont('','',$pdff);

  			$idx=0;$c=0;$d=0;$tot=0.0;$pft=0.0;

  			foreach($vcd as $row) {
  				$idx++;
  				$fill=!$fill;
  // 				$row['rmk'] = '';
  				$row['rid'] = $idx;
          $tot = $tot + $row['pft'];
          $pft = $pft + $row['tot'];
  				// if($row['bal'] < 0 ) $pdf->SetTextColor(255,0,0);
  				// elseif ($row['bal'] > 0 ) $pdf->SetTextColor(0,0,255);
  				// else $pdf->SetTextColor(0,0,0);
  				for($i=0;$i<count($meta);$i++){
  					$val = $row[$meta[$i]['c']];
  					// $val = $meta[$i]['f']=='M'?substr($val,0,4):$val;
            $val = $meta[$i]['f']=='M' ? number_format($row[$meta[$i]['c']],2,'.',',') : $row[$meta[$i]['c']];
  					$pdf->xMultiCell($meta[$i]['w'],10,$val,$meta[$i]['l'],$meta[$i]['a'],$fill,0);
  				}
  				$pdf->Ln();
  			}
  			$pdf->Ln();
  			$pdf->autoHeader = false;
  			$pdf->SetFont("dejavusans", "", 12);
  			$pdf->SetTextColor(0);
  			$pdf->SetDrawColor(0,0,0);
  			$uda = $_SESSION['us'];
        $tot = number_format($tot,2,'.',',');
        $pft = number_format($pft,2,'.',',');
  			$signing="<table border='0' cellpadding='0' cellspacing='0' align='left'>
  			<tr nobr='true'>
  			<td align='right'>Total Sales: GHC $tot<br/><br/>
  			</td>
        <td align='right'>Total Profit: GHC $pft<br/><br/>
  			</td>
        <td align='right'>Signature:..........................<br/>
  			Officer, $gnm
  			</td>
  			</tr>
  			</table>";
  			//Header
  			$fill=1;
  			$pdf->writeHTML($signing,true,true);
  			$pdf->Ln();

  			//Close and output PDF document
  			$pdf->Output($pdffn, "D");
  			return true;
  		}
  		catch(Exception $e){
  			return ErrorHandler::Interpret($e);
  		}
  	}

    public function Products($gd){
  		try {
        // error_log(print_r($gd,true));
  			//Get List of registered Student for a course
  			$aco=new FD();
  			$ars=$aco->FetchReportData($gd);
  			$ard= json_decode($ars,true);
        // error_log(print_r($ard,true));
  			if(isset($ard['failure']))
  				return $this->PrintError($ard['et'],$ard['em']);
  			elseif(isset($ard['success'])&&!is_array($ard['sd'])){
  				return $this->PrintError('Error','Student not found in the registered list');
  			}
  			elseif(!(isset($ard['success'])&&is_array($ard['sd']))){
  				return $this->PrintError('Error','Error Retrieving registration list');
  			}
  			$arc = $ard['rc'];
  			$vcd = $ard['sd'];
  			$type = $gd['fmt'];

  			//=================Create Filename here===================
  			$gnm = 'h';//'Course Marksheet'; // = $gd['nam'];
  			$enm = 'Group'; //$usd['ENM'];
  			$stmp = date('Ymdhi');
  			$basefn = str_replace(' ','_','rep').'_'.str_replace(' ','_',$enm).'_'.$stmp;
  			//=================CSV Printing Starts here===================
  			if($type == 'csv'){
  				$hdr = array('rid'=>'Record',
  						'nam'=>'Name of Member',
  						'mno'=>'Member No.',
  						'cmn'=>'Biometric No.',
  						'tel'=>'Mobile No.',
  						'gpn'=>'Group'
  				);
  				$dmode = true; //($form=='sum') || false;
  				$csvhdr = $hdr;
  				$ocsv = new CSVPrinter();
  				return $ocsv->buildCSV($vcd,$csvhdr,$basefn,$dmode);
  			}
  			//=================PDF Printing Starts here===================
  			$pdffn = "$basefn.pdf";

  			$meta = array(
  					array("p"=>0,"c"=>"rid","t"=>"No","w"=>15,"h"=>0,"l"=>"TLB","a"=>"L","f"=>"N"),
  					array("p"=>1,"c"=>"nam","t"=>"Items","w"=>50,"h"=>0,"l"=>"TLB","a"=>"L","f"=>"T"),
  					array("p"=>2,"c"=>"qty","t"=>"Quantity","w"=>30,"h"=>0,"l"=>"TLB","a"=>"L","f"=>"T"),
  					array("p"=>3,"c"=>"prc","t"=>"Price/Unit GHC","w"=>40,"h"=>0,"l"=>"TLB","a"=>"L","f"=>"M"),
  					array("p"=>5,"c"=>"ctn","t"=>"Category","w"=>38,"h"=>0,"l"=>"TLBR","a"=>"L","f"=>"T")
  			);

        $pdff = 9;
  			$hdtxt = $this->GetXTopHeader($gd,$gnm);
  			$summ = $this->GetXSalesSummary($gd,$ard);
  			$pdf = $this->PDFGridXSetup('P','A4',$meta,$summ,$hdtxt,PDF_HEADER_SYS,true);
  			$pdf->SetTextColor(0);
  			$pdf->SetDrawColor(0,0,0);
  			$pdf->SetFont('dejavusans','B',14);
  			//Header
  			$fill=0;
  			$pdf->writeHTML($summ,true,true);
  			$pdf->Ln();
  			$pdf->SetLineWidth(.1);
  			$pdf->SetFont('','B',$pdff);
  			$pdf->SetFillColor(192, 192, 192);
  			//$len = 0;
  			for($i=0;$i<count($meta);$i++){
  				$pdf->xMultiCell($meta[$i]['w'],10,$meta[$i]['t'],'TLRB','L','C',$fill);
  				//$len+=$meta[$i]['w']
  			}
  			$pdf->Ln();
  			//Color and font restoration
  			$pdf->SetFillColor(246,246,246);
  			$pdf->SetTextColor(0);
  			$pdf->SetFont('','',$pdff);

  			$idx=0;$c=0;$d=0;

  			foreach($vcd as $row) {
  				$idx++;
  				$fill=!$fill;
  // 				$row['rmk'] = '';
  				$row['rid'] = $idx;
  				if($row['bal'] < 0 ) $pdf->SetTextColor(255,0,0);
  				elseif ($row['bal'] > 0 ) $pdf->SetTextColor(0,0,255);
  				else $pdf->SetTextColor(0,0,0);
          for($i=0;$i<count($meta);$i++){
  					$val = $row[$meta[$i]['c']];
  					// $val = $meta[$i]['f']=='M'?substr($val,0,4):$val;
            $val = $meta[$i]['f']=='M' ? number_format($row[$meta[$i]['c']],2,'.',',') : $row[$meta[$i]['c']];
  					$pdf->xMultiCell($meta[$i]['w'],10,$val,$meta[$i]['l'],$meta[$i]['a'],$fill,0);
  				}
  				$pdf->Ln();
  			}
  			$pdf->Ln();
  			$pdf->autoHeader = false;
  			$pdf->SetFont("dejavusans", "", 12);
  			$pdf->SetTextColor(0);
  			$pdf->SetDrawColor(0,0,0);
  			$uda = $_SESSION['us'];

        $signing="<table border='0' cellpadding='0' cellspacing='0' align='left'>
  			<tr nobr='true'>
  			<td align='right'>
  			</td>
        <td align='right'>
  			</td>
        <td align='right'>Signature:..........................<br/>
  			Officer, $gnm
  			</td>
  			</tr>
  			</table>";
  			//Header
  			$fill=1;
  			$pdf->writeHTML($signing,true,true);
  			$pdf->Ln();

  			//Close and output PDF document
  			$pdf->Output($pdffn, "D");
  			return true;
  		}
  		catch(Exception $e){
  			return ErrorHandler::Interpret($e);
  		}
  	}

    public function Member($gd){
  		try {
        // error_log(print_r($gd,true));
  			//Get List of registered Student for a course
  			$aco=new FD();
  			$ars=$aco->FetchReportData($gd);
  			$ard= json_decode($ars,true);
        // error_log(print_r($ard,true));
  			if(isset($ard['failure']))
  				return $this->PrintError($ard['et'],$ard['em']);
  			elseif(isset($ard['success'])&&!is_array($ard['sd'])){
  				return $this->PrintError('Error','Student not found in the registered list');
  			}
  			elseif(!(isset($ard['success'])&&is_array($ard['sd']))){
  				return $this->PrintError('Error','Error Retrieving registration list');
  			}
  			$arc = $ard['rc'];
  			$vcd = $ard['sd'];
  			$type = $gd['fmt'];

  			//=================Create Filename here===================
  			$gnm = 'h';//'Course Marksheet'; // = $gd['nam'];
  			$enm = 'Group'; //$usd['ENM'];
  			$stmp = date('Ymdhi');
  			$basefn = str_replace(' ','_','rep').'_'.str_replace(' ','_',$enm).'_'.$stmp;
  			//=================CSV Printing Starts here===================
  			if($type == 'csv'){
  				$hdr = array('rid'=>'Record',
  						'nam'=>'Name of Member',
  						'mno'=>'Member No.',
  						'cmn'=>'Biometric No.',
  						'tel'=>'Mobile No.',
  						'gpn'=>'Group'
  				);
  				$dmode = true; //($form=='sum') || false;
  				$csvhdr = $hdr;
  				$ocsv = new CSVPrinter();
  				return $ocsv->buildCSV($vcd,$csvhdr,$basefn,$dmode);
  			}
  			//=================PDF Printing Starts here===================
  			$pdffn = "$basefn.pdf";

  			$meta = array(
  					array("p"=>0,"c"=>"rid","t"=>"No","w"=>10,"h"=>0,"l"=>"TLB","a"=>"L","f"=>"N"),
  					array("p"=>1,"c"=>"nam","t"=>"Customer","w"=>50,"h"=>0,"l"=>"TLB","a"=>"L","f"=>"T"),
            array("p"=>2,"c"=>"mno","t"=>"Code","w"=>25,"h"=>0,"l"=>"TLB","a"=>"L","f"=>"T"),
            array("p"=>2,"c"=>"tel","t"=>"Mobile 1","w"=>30,"h"=>0,"l"=>"TLB","a"=>"L","f"=>"T"),
  					array("p"=>2,"c"=>"mob","t"=>"Mobile 2","w"=>30,"h"=>0,"l"=>"TLB","a"=>"L","f"=>"T"),
  					array("p"=>5,"c"=>"tot","t"=>"Amt Saved (GHC)","w"=>38,"h"=>0,"l"=>"TLBR","a"=>"R","f"=>"M")
  			);

        $pdff = 9;
  			$hdtxt = $this->GetXTopHeader($gd,$gnm);
  			$summ = $this->GetXSalesSummary($gd,$ard);
  			$pdf = $this->PDFGridXSetup('P','A4',$meta,$summ,$hdtxt,PDF_HEADER_SYS,true);
  			$pdf->SetTextColor(0);
  			$pdf->SetDrawColor(0,0,0);
  			$pdf->SetFont('dejavusans','B',14);
  			//Header
  			$fill=0;
  			$pdf->writeHTML($summ,true,true);
  			$pdf->Ln();
  			$pdf->SetLineWidth(.1);
  			$pdf->SetFont('','B',$pdff);
  			$pdf->SetFillColor(192, 192, 192);
  			//$len = 0;
  			for($i=0;$i<count($meta);$i++){
  				$pdf->xMultiCell($meta[$i]['w'],10,$meta[$i]['t'],'TLRB','L','C',$fill);
  				//$len+=$meta[$i]['w']
  			}
  			$pdf->Ln();
  			//Color and font restoration
  			$pdf->SetFillColor(246,246,246);
  			$pdf->SetTextColor(0);
  			$pdf->SetFont('','',$pdff);

  			$idx=0;$c=0;$d=0;

  			foreach($vcd as $row) {
  				$idx++;
  				$fill=!$fill;
  // 				$row['rmk'] = '';
  				$row['rid'] = $idx;
  				if($row['bal'] < 0 ) $pdf->SetTextColor(255,0,0);
  				elseif ($row['bal'] > 0 ) $pdf->SetTextColor(0,0,255);
  				else $pdf->SetTextColor(0,0,0);
          for($i=0;$i<count($meta);$i++){
  					$val = $row[$meta[$i]['c']];
  					// $val = $meta[$i]['f']=='M'?substr($val,0,4):$val;
            $val = $meta[$i]['f']=='M' ? number_format($row[$meta[$i]['c']],2,'.',',') : $row[$meta[$i]['c']];
  					$pdf->xMultiCell($meta[$i]['w'],10,$val,$meta[$i]['l'],$meta[$i]['a'],$fill,0);
  				}
  				$pdf->Ln();
  			}
  			$pdf->Ln();
  			$pdf->autoHeader = false;
  			$pdf->SetFont("dejavusans", "", 12);
  			$pdf->SetTextColor(0);
  			$pdf->SetDrawColor(0,0,0);
  			$uda = $_SESSION['us'];

        $signing="<table border='0' cellpadding='0' cellspacing='0' align='left'>
  			<tr nobr='true'>
  			<td align='right'>
  			</td>
        <td align='right'>
  			</td>
        <td align='right'>Signature:..........................<br/>
  			Officer, $gnm
  			</td>
  			</tr>
  			</table>";
  			//Header
  			$fill=1;
  			$pdf->writeHTML($signing,true,true);
  			$pdf->Ln();

  			//Close and output PDF document
  			$pdf->Output($pdffn, "D");
  			return true;
  		}
  		catch(Exception $e){
  			return ErrorHandler::Interpret($e);
  		}
  	}

    public function Members($pd){
      try {
        // error_log(print_r($pd,true));
        $type = $pd['fmt'];
  			$aco=new FD();
        $ard= json_decode($aco->FindMember($pd),true);
  			if($ard['sts']>0)
  				return $this->PrintError($ard['et'],$ard['em']);

        $prd= json_decode($aco->FetchPaymentData($pd),true);
  			if($prd['sts']>0)
  				return $this->PrintError($prd['et'],$prd['em']);

        $pro= json_decode($aco->FetchProductData($pd),true);
  			if($pro['sts']>0)
  				return $this->PrintError($pro['et'],$pro['em']);

  			$vcd = $ard['sd'];
  			$pcd = $prd['sd'];
  			$nxd = $pro['sd'];

  			$fn = 'Customer_Statement';//$ard['fln'];
  			$pdffn = "$fn.pdf";


  			$stq=new KPSettings();
  			$srs=$stq->Search(array('hsh'=>1));
  			$srd= json_decode($srs,true);
  			if(!(isset($srd['success'])&&is_array($srd['sd']))){
  				//error_log('Error in KPSettings->Search'.$srs);
  				return $this->PrintError('Error','Error Retrieving System Settings. Check the logs.');
  			}
  			$rc = $srd['rc'];
  			$hd = $srd['hd'];
  			$sch['ndt'] = $hd['CURRENT_YEAR'];
  			$sch['ttl'] = $hd['ADMLET_TITLE'];
  			$sch['add'] = $hd['ADMLET_ADDRESS'];
  			$sch['loc'] = $hd['ADM_LOCATION'];
  			$bse=$sch['ndt'];
  			$upp = $sch['ndt']+1;


  			//report name
  			$gnm = "Result ";
  			// ---------------------------------------------------------
  			$hdtxt =$sch['ttl']; //"SALVATION INTERNATIONAL ACADEMY";
  			$divider = "<p>---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- </p>";

  			//Initialize and setup PDF
  			$pdf = $this->PDFLetterSetup('P','A4',false,false,$hdtxt,9,1);

  			$kxt = new KPXTemplate();

  			$idx=0;$c=0;$d=0;
  			foreach($vcd as $row) {
          // error_log(print_r($vcd,true));
  				$idx++;
  				$fill=!$fill;
  				$html = $kxt->reportform($vpg,$row,$pcd,$nxd,$arc);
  				$head = $kxt->reportheader($vpg,$row,$pcd,$nxd);

  				$pdf->SetFont('helvetica', 'B', 10);

  				// if($idx>0) $pdf->AddPage();
  				$pdf->Write(1, 'CUSTOMER STATEMENT', '', 0, 'C', true, 0, false, false, 0);
  				$pdf->SetFont('times', '', 11);
  				$pdf->writeHTML($head, true, true);
  				$pdf->writeHTML($html, true, false, false, false, '');
  				$pdf->SetLineWidth(.1);

  				//$pdf->writeHTML($divider, true, false, false, false, '');
  				//$pdf->writeHTML($head, true, true);
  				//$pdf->writeHTML($html, true, false, false, false, '');
          $signing="<table border='0' cellpadding='0' cellspacing='0' align='left'>
    			<tr nobr='true'>
    			<td align='right'>
    			</td>
          <td align='right'>
    			</td>
          <td align='right'>Signature:..........................<br/><br/>
    			Officer, Kofi
    			</td>
    			</tr>
    			</table>";
  				// $foot = $kxt->reportfooter($row,$xgd);
  				$pdf->SetFont('helvetica', '', 9);
  				$pdf->writeHTML($signing, true, false, false, false, '');

  				//Barcoding here
  				$pdf->SetFont('helvetica', '', 10);
  				$pdf->setBarcode($row['mno']);
  				$pdf->PrintBarcode($row['mno']);
  			}
  			//Close and output PDF document
  			$pdf->Output($pdffn, "D");
  			return true;
      }
  		catch(Exception $e){
  			return ErrorHandler::Interpret($e);
  		}
    }
}
?>
