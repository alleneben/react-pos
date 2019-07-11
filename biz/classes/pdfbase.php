<?php
// require_once('lib/tcpdf/config/lang/eng.php');
require_once('../lib/tcpdf/tcpdf.php');

// PDF Printing
class PDFBase extends TCPDF{
	//public function __construct($orientation='P', $unit='mm', $format='A4', $unicode=true, $encoding='UTF-8', $diskcache=false) {
	//	parent::__construct($orientation='P', $unit='mm', $format='A4', $unicode=true, $encoding='UTF-8', $diskcache=false);
	//}
	/**
	* checkPageBreak V4
	* Add page if needed.
	* @param float $h Cell height. Default value: 0.
	* @since 3.2.000 (2008-07-01)
	* @access protected
	*/
// 	protected function checkPageBreakV4($h) {
// 		if ((($this->y + $h) > $this->PageBreakTrigger) AND (empty($this->InFooter)) AND ($this->AcceptPageBreak())) {
// 			$rs = "";
// 			//
// 			$this->BeforePageBreak();
// 			//Automatic page break
// 			$x = $this->x;
// 			$ws = $this->ws;
// 			if ($ws > 0) {
// 				$this->ws = 0;
// 				$rs .= '0 Tw';
// 			}
// 			$this->AddPage($this->CurOrientation);
// 			if ($ws > 0) {
// 				$this->ws = $ws;
// 				$rs .= sprintf('%.3f Tw', $ws * $k);
// 			}
// 			$this->_out($rs);
// 			$this->y = $this->tMargin;
// 			$this->x = $x;
// 			$this->AfterPageBreak();
// 		}
// 	}

	/**
	 * checkPageBreak V5
	 * Add page if needed.
	 * @param $h (float) Cell height. Default value: 0.
	 * @param $y (mixed) starting y position, leave empty for current position.
	 * @param $addpage (boolean) if true add a page, otherwise only return the true/false state
	 * @return boolean true in case of page break, false otherwise.
	 * @since 3.2.000 (2008-07-01)
	 * @protected
	 */
// 	protected function checkPageBreak($h=0, $y='', $addpage=true) {
// 		if(!method_exists($this,'getTCPDFVersion')) return $this->checkPageBreakV4($h);
// 		if ($this->empty_string($y)) {
// 			$y = $this->y;
// 		}
// 		$current_page = $this->page;
// 		if ((($y + $h) > $this->PageBreakTrigger) AND ($this->inPageBody()) AND ($this->AcceptPageBreak())) {
// 			if ($addpage) {
// 				$this->BeforePageBreak();
// 				//Automatic page break
// 				$x = $this->x;
// 				$this->AddPage($this->CurOrientation);
// 				$this->y = $this->tMargin;
// 				$oldpage = $this->page - 1;
// 				if ($this->rtl) {
// 					if ($this->pagedim[$this->page]['orm'] != $this->pagedim[$oldpage]['orm']) {
// 						$this->x = $x - ($this->pagedim[$this->page]['orm'] - $this->pagedim[$oldpage]['orm']);
// 					} else {
// 						$this->x = $x;
// 					}
// 				} else {
// 					if ($this->pagedim[$this->page]['olm'] != $this->pagedim[$oldpage]['olm']) {
// 						$this->x = $x + ($this->pagedim[$this->page]['olm'] - $this->pagedim[$oldpage]['olm']);
// 					} else {
// 						$this->x = $x;
// 					}
// 				}
// 			}
// 			return true;
// 		}
// 		if ($current_page != $this->page) {
// 			$this->AfterPageBreak();
// 			// account for columns mode
// 			return true;
// 		}
// 		$this->AfterPageBreak();
// 		return false;
// 	}

	/**
	* An event handler for final operations on a page, e.g table line
	* @return boolean
	* @since 1.4
	*/
// 	protected function BeforePageBreak() {
// 		return true;
// 	}

	/**
	* An event handler for initial operations on a page, e.g table headers
	* @return boolean
	* @since 1.4
	*/
// 	protected function AfterPageBreak() {
// 		/*
// 		$this->SetTextColor(0);
// 		$this->SetFont('','B');
// 		if(isset($this->autoHeader) && $this->autoHeader == false);
// 		else{
// 			$meta = $this->TbMeta;
// 			for($i=0;$i<count($meta);$i++){
// 				$this->Cell($meta[$i]['w'],6,$meta[$i]['t'],'TLRB',0,'C',0);
// 			}
// 			$this->Ln();
// 		}
// 		$this->SetFillColor(246,246,246);
// 		$this->SetTextColor(0);
// 		$this->SetFont('','');
// 		*/
// 		return true;
// 	}
	// Page footer
	/**
	 * This method is used to render the page footer.
	 * It is automatically called by AddPage() and could be overwritten in your own inherited class.
	 */
	public function Footer() {
		$cur_y = $this->GetY();
		$ormargins = $this->getOriginalMargins();
		$this->SetTextColor(0, 0, 0);
		//set style for cell border
		$line_width = 0.85 / $this->getScaleFactor();
		$this->SetLineStyle(array("width" => $line_width, "cap" => "butt", "join" => "miter", "dash" => 0, "color" => array(0, 0, 0)));
		//print document barcode
		$barcode = $this->getBarcode();
		if (!empty($barcode)) {
			$this->Ln();
			$barcode_width = round(($this->getPageWidth() - $ormargins['left'] - $ormargins['right'])/3);
			$this->write1DBarcode($barcode, "C128B", $this->GetX(), $cur_y + $line_width, $barcode_width, (($this->getFooterMargin() / 3) - $line_width), 0.3, '', '');
		}
		$pagenumtxt = $this->l['w_page']." ".$this->PageNo();
		$this->SetY($cur_y);
		//Print page number
		if ($this->getRTL()) {
			$this->SetX($ormargins['right']);
			$this->Cell(0, 0, $pagenumtxt, 'T', 0, 'L');
		} else {
			$this->SetX($ormargins['left']);
			$this->Cell(0, 0, $pagenumtxt, 'T', 0, 'R');
		}
	}
// 	public function Footer() {
// 		// Position at 15 mm from bottom
// 		$this->SetY(-15);
// 		// Set font
// 		$this->SetFont('helvetica', 'I', 8);
// 		// Page number
// 		$this->Cell(0, 10, 'Page '.$this->getAliasNumPage().'/'.$this->getAliasNbPages(), 0, false, 'C', 0, '', 0, false, 'T', 'M');
// 	}
	/**
 	 * This method is used to render the page header.
 	 * It is automatically called by AddPage() and could be overwritten in your own inherited class.
	 */
	public function Header() {
		$ormargins = $this->getOriginalMargins();
		$headerfont = $this->getHeaderFont();
		$headerdata = $this->getHeaderData();
		if (($headerdata['logo']) AND ($headerdata['logo'] != K_BLANK_IMAGE)) {
			$this->Image(K_PATH_IMAGES.$headerdata['logo'], $this->GetX(), $this->getHeaderMargin(), $headerdata['logo_width']);
			$imgy = $this->getImageRBY();
		} else {
			$imgy = $this->GetY();
		}
		$cell_height = round(($this->getCellHeightRatio() * $headerfont[2]) / $this->getScaleFactor(), 2);
		//ernie:
		$myy = $imgy - $cell_height;
		// set starting margin for text data cell
		if ($this->getRTL()) {
			$header_x = $ormargins['right'] + ($headerdata['logo_width'] * 1.1);
		} else {
			$header_x = $ormargins['left'] + ($headerdata['logo_width'] * 1.1);
		}
		//ernie:
		$contwidth = ($this->GetPageWidth() - $ormargins['left'] - $ormargins['right'])/3;
		$ccell = $ormargins['left']+$contwidth;
		$rcell = $ormargins['left']+2*$contwidth;
		$this->SetTextColor(0, 0, 3);
		// header title
		$this->SetFont($headerfont[0], 'B', $headerfont[2] + 1);
		//$this->SetX($ccell);

		$this->SetY($myy);
		$this->SetX($header_x + $contwidth/3 );

		$this->writeHTML($headerdata['string'],true,true);
		if(isset($this->headerBarcode) && $this->headerBarcode == true)
			$this->write1DBarcode('04210000526', 'UPCE', '', '', 30, 10, 0.4, $style, 'M');
		$this->Ln();

		$this->SetLineStyle(array("width" => 0.85 / $this->getScaleFactor(), "cap" => "butt", "join" => "miter", "dash" => 0, "color" => array(0, 0, 0)));
		$this->SetY(1 + $imgy);
		if ($this->getRTL()) {
			$this->SetX($ormargins['right']);
		} else {
			$this->SetX($ormargins['left']);
		}
		$this->Cell(0, 0, '', 'T', 0, 'C');
	}

	public function UXBarChart($meta,$dataset){
		//TODO: should come in $meta
		$rowLabels = array( "SupaWidget", "WonderWidget", "MegaWidget", "HyperWidget" );
		//TODO: should come in $meta
		$chartWidth = 160;
		$chartHeight = 80;
		$chartTopMargin = 20;
		$chartBottomMargin = 20;
		$chartXPos = 20;
		$chartYPos = (int)$this->GetY() + $chartHeight + $chartTopMargin; //100;
		$chartXLabel = "Product $chartYPos";
		$chartYLabel = "2009 Sales";
		$chartYStep = 20000;
		//TODO: should come in $meta
		$chartColours = array(
                  array( 255, 100, 100 ),
                  array( 100, 255, 100 ),
                  array( 100, 100, 255 ),
                  array( 255, 255, 100 ),
                );
		//TODO: should come in $dataset
		$data = array(
		          array( 9940, 10100, 9490, 11730 ),
		          array( 19310, 21140, 20560, 22590 ),
		          array( 25110, 26260, 25210, 28370 ),
		          array( 27650, 24550, 30040, 31980 ),
		        );

		// Compute the X scale
		$xScale = count($rowLabels) / ( $chartWidth - 40 );

		// Compute the Y scale

		$maxTotal = 0;

		foreach ( $data as $dataRow ) {
			$totalSales = 0;
			foreach ( $dataRow as $dataCell ) $totalSales += $dataCell;
			$maxTotal = ( $totalSales > $maxTotal ) ? $totalSales : $maxTotal;
		}

		$yScale = $maxTotal / $chartHeight;

		// Compute the bar width
		$barWidth = ( 1 / $xScale ) / 1.5;

		// Add the axes:
		$this->SetFont( '', '', 10 );

		// X axis
		$this->Line( $chartXPos + 30, $chartYPos, $chartXPos + $chartWidth, $chartYPos );
		//$this->Arrow( $chartXPos + 30, $chartYPos, $chartXPos + $chartWidth, $chartYPos, 1 );

		for ( $i=0; $i < count( $rowLabels ); $i++ ) {
			$this->SetXY( $chartXPos + 40 +  $i / $xScale, $chartYPos );
			$this->Cell( $barWidth, 10, $rowLabels[$i], 0, 0, 'C' );
		}

		// Y axis
		$this->Line( $chartXPos + 30, $chartYPos, $chartXPos + 30, $chartYPos - $chartHeight - 8 );
		//$this->Arrow( $chartXPos + 30, $chartYPos+2, $chartXPos + 30, $chartYPos - $chartHeight - 8, 1 );
		//Y axis ticks
		//for ( $i=0; $i <= $maxTotal; $i += $chartYStep ) {
		//	$this->SetXY( $chartXPos + 7, $chartYPos - 5 - $i / $yScale );
		//	$this->Cell( 20, 10, '$' . number_format( $i ), 0, 0, 'R' );
		//	$this->Line( $chartXPos + 28, $chartYPos - $i / $yScale, $chartXPos + 30, $chartYPos - $i / $yScale );
		//}

		for ( $i=0; $i <= $maxTotal; $i += $chartYStep ) {
		  $this->SetXY( $chartXPos + 7, $chartYPos - 5 - $i / $yScale );
		  $this->Cell( 20, 10, '$' . number_format( $i ), 0, 0, 'R' );
		  $this->Line( $chartXPos + 28, $chartYPos - $i / $yScale, $chartXPos + $chartWidth, $chartYPos - $i / $yScale, array('dash'=>4) );
		}
		// Add the axis labels
		$this->SetFont( '', 'B', 12 );
		$this->SetXY( $chartWidth / 2 + 20, $chartYPos + 8 );
		$this->Cell( 30, 10, $chartXLabel, 0, 0, 'C' );
		$this->SetXY( $chartXPos + 7, $chartYPos - $chartHeight - 12 );
		$this->Cell( 20, 10, $chartYLabel, 0, 0, 'R' );

		// Create the bars
		$xPos = $chartXPos + 40;
		$bar = 0;

		foreach ( $data as $dataRow ) {
			// Total up the sales figures for this product
			$totalSales = 0;
			foreach ( $dataRow as $dataCell ) $totalSales += $dataCell;
			// Create the bar
			$colourIndex = $bar % count( $chartColours );

			$this->SetFillColor( $chartColours[$colourIndex][0], $chartColours[$colourIndex][1], $chartColours[$colourIndex][2] );
			$this->Rect( $xPos, $chartYPos - ( $totalSales / $yScale ), $barWidth, $totalSales / $yScale, 'DF', array('all'=>array('dash'=>0)));
			$xPos += ( 1 / $xScale );
			$bar++;
		}

	}

	public function UXPiechart($meta,$data){
		$xc = 105;
		$yc = 100;
		$r = 50;

		$this->SetFillColor(0, 0, 255);
		$this->PieSector($xc, $yc, $r, 20, 120, 'FD', false, 0, 2);

		$this->SetFillColor(0, 255, 0);
		$this->PieSector($xc, $yc, $r, 120, 250, 'FD', false, 0, 2);

		$this->SetFillColor(255, 0, 0);
		$this->PieSector($xc, $yc, $r, 250, 20, 'FD', false, 0, 2);

		// write labels
		$this->SetTextColor(255,255,255);
		$this->Text(105, 65, 'BLUE');
		$this->Text(60, 95, 'GREEN');
		$this->Text(120, 115, 'RED');

	}


	public function PrintBarcode($btext,$bstyle=""){
		// define barcode style
		$style = (!empty($bstyle))?$bstyle:
		array(
		    'position' => 'S',
		    'border' => true,
		    'padding' => 'auto',
		    'fgcolor' => array(0,0,0),
		    'bgcolor' => false, //array(255,255,255),
		    'text' => true,
		    'font' => 'helvetica',
		    'fontsize' => 8,
		    'stretchtext' => 4
		);
		$text = isset($btext)?$btext:date('Y-m-d');
		$this->write1DBarcode($text, 'C39', 150, 5, 40, 7, 0.4, $style, 'B');
	}

	/**
	 * Public access to checkPageBreak for Developer use
	 * @param type $h
	 * @param type $y
	 * @param type $addpage
	 * @return type
	 */
	public function checkNewPage($h=0, $y='', $addpage=true) {
		return $this->checkPageBreak($h, $y, $addpage);
	}
	/**
	 * This method allows printing text with line breaks.
	 * They can be automatic (as soon as the text reaches the right border of the cell) or explicit (via the \n character). As many cells as necessary are output, one below the other.<br />
	 * Text can be aligned, centered or justified. The cell block can be framed and the background painted.
	 * @param float $w Width of cells. If 0, they extend up to the right margin of the page.
	 * @param float $h Cell minimum height. The cell extends automatically if needed.
	 * @param string $txt String to print
	 * @param mixed $border Indicates if borders must be drawn around the cell block. The value can be either a number:<ul><li>0: no border (default)</li><li>1: frame</li></ul>or a string containing some or all of the following characters (in any order):<ul><li>L: left</li><li>T: top</li><li>R: right</li><li>B: bottom</li></ul>
	 * @param string $align Allows to center or align the text. Possible values are:<ul><li>L or empty string: left align</li><li>C: center</li><li>R: right align</li><li>J: justification (default value when $ishtml=false)</li></ul>
	 * @param int $fill Indicates if the cell background must be painted (1) or transparent (0). Default value: 0.
	 * @param int $ln Indicates where the current position should go after the call. Possible values are:<ul><li>0: to the right</li><li>1: to the beginning of the next line [DEFAULT]</li><li>2: below</li></ul>
	 * @param int $x x position in user units
	 * @param int $y y position in user units
	 * @param boolean $reseth if true reset the last cell height (default true).
	 * @param int $stretch stretch carachter mode: <ul><li>0 = disabled</li><li>1 = horizontal scaling only if necessary</li><li>2 = forced horizontal scaling</li><li>3 = character spacing only if necessary</li><li>4 = forced character spacing</li></ul>
	 * @param boolean $ishtml se to true if $txt is HTML content (default = false).
	 * @return int Return the number of cells or 1 for html mode.
	 * @since 1.3
	 * @see SetFont(), SetDrawColor(), SetFillColor(), SetTextColor(), SetLineWidth(), Cell(), Write(), SetAutoPageBreak()
	 */

	public function xMultiCell($w, $h, $txt, $border = 0, $align = 'J', $fill = 0, $ln = 1, $x = '', $y = '', $reseth = true, $stretch = 0, $ishtml = false, $autopadding=true, $maxh=0, $valign='T', $fitcell=false) {
		if ((empty($this->lasth)) OR ($reseth)) {
			//set row height
			$this->lasth = $this->FontSize * $this->cell_height_ratio;
		}
		if (!empty($y)) {
			$this->SetY($y);
		} else {
			$y = $this->GetY();
		}
		// check for page break
		$this->checkPageBreak($h);

		$y = $this->GetY();
		// get current page number
		$startpage = $this->page;
		if (!empty($x)) {
			$this->SetX($x);
		} else {
			$x = $this->GetX();
		}
		if (empty($w) OR ($w <= 0)) {
			if ($this->rtl) {
				$w = $this->x - $this->lMargin;
			} else {
				$w = $this->w - $this->rMargin - $this->x;
			}
		}
		// store original margin values
		$lMargin = $this->lMargin;
		$rMargin = $this->rMargin;
		$mc_padding = $this->cell_padding;
		$mc_margin = $this->cell_margin;
		if ($this->rtl) {
			$this->SetRightMargin($this->w - $this->x);
			$this->SetLeftMargin($this->x - $w);
		} else {
			$this->SetLeftMargin($this->x);
			$this->SetRightMargin($this->w - $this->x - $w);
		}
		// calculate remaining vertical space on first page ($startpage)
		$restspace = $this->getPageHeight() - $this->GetY() - $this->getBreakMargin();
		// Adjust internal padding
// 		if ($this->cMargin < ($this->LineWidth / 2)) {
// 			$this->cMargin = ($this->LineWidth / 2);
// 		}
// 		// Add top space if needed
// 		if (($this->lasth - $this->FontSize) < $this->LineWidth) {
// 			$this->y += $this->LineWidth / 2;
// 		}
// 		// add top padding
// 		$this->y += $this->cMargin;
		$this->clMargin = $this->lMargin;
		$this->crMargin = $this->rMargin;
		if ($autopadding) {
			// add top padding
			$this->y += $mc_padding['T'];
		}
		if ($ishtml) {
			// Write HTML text
			$this->writeHTML($txt, true, 0, $reseth, true, $align);
			$nl = 1;
		} else {
			// Write text
			$nl = $this->Write($this->lasth, $txt, '', 0, $align, true, $stretch, false);
		}
		// add bottom padding
// 		$this->y += $this->cMargin;
		$this->y += $mc_padding['B'];
		// Add bottom space if needed
		if (($this->lasth - $this->FontSize) < $this->LineWidth) {
			$this->y += $this->LineWidth / 2;
		}
		// Get end-of-text Y position
		$currentY = $this->GetY();
		// get latest page number
		$endpage = $this->page;
		// check if a new page has been created
		if ($endpage > $startpage) {
			// design borders around HTML cells.
			for ($page = $startpage; $page <= $endpage; $page++) {
				$this->setPage($page);
				if ($page == $startpage) {
					$this->SetY($this->getPageHeight() - $restspace - $this->getBreakMargin());
					$h = $restspace;
				} elseif ($page == $endpage) {
					$this->SetY($this->tMargin); // put cursor at the beginning of text
					$h = $currentY - $this->tMargin;
				} else {
					$this->SetY($this->tMargin); // put cursor at the beginning of text
					$h = $this->getPageHeight() - $this->tMargin - $this->getBreakMargin();
				}
				$this->SetX($x);
				$ccode = $this->getCellCode($w, $h, "", $border, 1, '', $fill);
				if ($border OR $fill) {
					$pstart = substr($this->pages[$this->page], 0, $this->intmrk[$this->page]);
					$pend = substr($this->pages[$this->page], $this->intmrk[$this->page]);
					$this->pages[$this->page] = $pstart . $ccode . "\n" . $pend;
					$this->intmrk[$this->page] += strlen($ccode . "\n");
				}
			}
		} else {
			$h = max($h, ($currentY - $y));
			// put cursor at the beginning of text
			$this->SetY($y);
			$this->SetX($x);
			$ccode = $this->getCellCode($w, $h, "", $border, 1, '', $fill);
			if ($border OR $fill) {
				// design a cell around the text
				$pstart = substr($this->pages[$this->page], 0, $this->intmrk[$this->page]);
				$pend = substr($this->pages[$this->page], $this->intmrk[$this->page]);
				$this->pages[$this->page] = $pstart . $ccode . "\n" . $pend;
				$this->intmrk[$this->page] += strlen($ccode . "\n");
			}
		}
		// Get end-of-cell Y position
		$currentY = $this->GetY();
		// restore original margin values
		$this->SetLeftMargin($lMargin);
		$this->SetRightMargin($rMargin);
		if ($ln > 0) {
			//Go to the beginning of the next line
			$this->SetY($currentY);
			if ($ln == 2) {
				$this->SetX($x + $w);
			}
		} else {
			// go left or right by case
			$this->setPage($startpage);
			$this->y = $y;
			$this->SetX($x + $w);
		}
		return $nl;
	}
}
?>
