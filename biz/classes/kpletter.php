<?php
//require_once('lib/tcpdf/config/lang/eng.php');
//require_once('lib/tcpdf/tcpdf.php');

// PDF Letters
class KPLetter extends AppBase{
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

	public function POSReceipt(){
		try{

			$html=<<<EOD
			<!DOCTYPE html>
<html lang="en" >

<head>

  <meta charset="UTF-8">
  <link rel="shortcut icon" type="image/x-icon" href="https://static.codepen.io/assets/favicon/favicon-8ea04875e70c4b0bb41da869e81236e54394d63638a1ef12fa558a4a835f1164.ico" />
  <link rel="mask-icon" type="" href="https://static.codepen.io/assets/favicon/logo-pin-f2d2b6d2c61838f7e76325261b7195c27224080bc099486ddd6dccb469b8e8e6.svg" color="#111" />
  <title>CodePen - POS Receipt Template Html Css</title>
	<link href="reports.css" rel="css" />
</head>

<body translate="no" >


  <div id="invoice-POS">

    <center id="top">
      <div class="logo"></div>
      <div class="info">
        <h2>SBISTechs Inc</h2>
      </div><!--End Info-->
    </center><!--End InvoiceTop-->

    <div id="mid">
      <div class="info">
        <h2>Contact Info</h2>
        <p>
            Address : street city, state 0000</br>
            Email   : JohnDoe@gmail.com</br>
            Phone   : 555-555-5555</br>
        </p>
      </div>
    </div><!--End Invoice Mid-->

    <div id="bot">

                    <div id="table">
                        <table>
                            <tr class="tabletitle">
                                <td class="item"><h2>Item</h2></td>
                                <td class="Hours"><h2>Qty</h2></td>
                                <td class="Rate"><h2>Sub Total</h2></td>
                            </tr>

                            <tr class="service">
                                <td class="tableitem"><p class="itemtext">Communication</p></td>
                                <td class="tableitem"><p class="itemtext">5</p></td>
                                <td class="tableitem"><p class="itemtext">$375.00</p></td>
                            </tr>

                            <tr class="service">
                                <td class="tableitem"><p class="itemtext">Asset Gathering</p></td>
                                <td class="tableitem"><p class="itemtext">3</p></td>
                                <td class="tableitem"><p class="itemtext">$225.00</p></td>
                            </tr>

                            <tr class="service">
                                <td class="tableitem"><p class="itemtext">Design Development</p></td>
                                <td class="tableitem"><p class="itemtext">5</p></td>
                                <td class="tableitem"><p class="itemtext">$375.00</p></td>
                            </tr>

                            <tr class="service">
                                <td class="tableitem"><p class="itemtext">Animation</p></td>
                                <td class="tableitem"><p class="itemtext">20</p></td>
                                <td class="tableitem"><p class="itemtext">$1500.00</p></td>
                            </tr>

                            <tr class="service">
                                <td class="tableitem"><p class="itemtext">Animation Revisions</p></td>
                                <td class="tableitem"><p class="itemtext">10</p></td>
                                <td class="tableitem"><p class="itemtext">$750.00</p></td>
                            </tr>


                            <tr class="tabletitle">
                                <td></td>
                                <td class="Rate"><h2>tax</h2></td>
                                <td class="payment"><h2>$419.25</h2></td>
                            </tr>

                            <tr class="tabletitle">
                                <td></td>
                                <td class="Rate"><h2>Total</h2></td>
                                <td class="payment"><h2>$3,644.25</h2></td>
                            </tr>

                        </table>
                    </div><!--End Table-->

                    <div id="legalcopy">
                        <p class="legal"><strong>Thank you for your business!</strong>  Payment is expected within 31 days; please process this invoice within that time. There will be a 5% interest charge per month on late invoices.
                        </p>
                    </div>


                </div><!--End InvoiceBot-->
  </div><!--End Invoice-->
<button id="btn">Print</button>




</body>

</html>
EOD;

			return $html;
		}
		catch(Exception $e){
			return ErrorHandler::Interpret($e);
		}
	}

}
?>
