<?php
// PDF Grid Printing
class PDFPrinter extends PDFBase{
	
	/**
	* Add page if needed.
	* @param float $h Cell height. Default value: 0.
	* @since 3.2.000 (2008-07-01)
	* @access protected
	*//*
	protected function checkPageBreak($h) {
		if ((($this->y + $h) > $this->PageBreakTrigger) AND (empty($this->InFooter)) AND ($this->AcceptPageBreak())) {
			$rs = "";
			//
			$this->BeforePageBreak();
			//Automatic page break
			$x = $this->x;
			$ws = $this->ws;
			if ($ws > 0) {
				$this->ws = 0;
				$rs .= '0 Tw';
			}
			$this->AddPage($this->CurOrientation);
			if ($ws > 0) {
				$this->ws = $ws;
				$rs .= sprintf('%.3f Tw', $ws * $k);
			}
			$this->_out($rs);
			$this->y = $this->tMargin;
			$this->x = $x;
			$this->AfterPageBreak();
		}
	}*/

	/**
	 * Performs a line break.
	 * The current abscissa goes back to the left margin and the ordinate increases by the amount passed in parameter.
	 * @param $h (float) The height of the break. By default, the value equals the height of the last printed cell.
	 * @param $cell (boolean) if true add the current left (or right o for RTL) padding to the X coordinate
	 * @public
	 * @since 1.0
	 * @see Cell()
	 */
	public function Ln($h='', $cell=false) {
		if (($this->num_columns > 1) AND ($this->y == $this->columns[$this->current_column]['y']) AND isset($this->columns[$this->current_column]['x']) AND ($this->x == $this->columns[$this->current_column]['x'])) {
			// revove vertical space from the top of the column
			return;
		}
		if ($cell) {
			if ($this->rtl) {
				$cellpadding = $this->cell_padding['R'];
			} else {
				$cellpadding = $this->cell_padding['L'];
			}
		} else {
			$cellpadding = 0;
		}
		if ($this->rtl) {
			$this->x = $this->w - $this->rMargin - $cellpadding;
		} else {
			$this->x = $this->lMargin + $cellpadding;
		}
		if (is_string($h)) {
			$h = $this->lasth;
		}
		if (!$this->checkPageBreak($h,$this->y,true)){
			$this->y += $h;
// 		$this->y += $h;
	}else{
		$this->y = PDF_MARGIN_TOP;
	}
		
		$this->newline = true;
	}
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
// 		$this->SetTextColor(0);
// 		$this->SetFont('','B');
// 		if(isset($this->autoHeader) && $this->autoHeader == false);
// 		//elseif(isset($this->TbMeta) && is_array($this->TbMeta)){
// 		else {
// 			$meta = $this->TbMeta;
			
// 			if ($this->HShape==false){
// 				$this->SetFont('','BU');
// 			$this->writeHTML($this->XSumm,true,true);
// 			for($i=0;$i<count($meta);$i++){
// 				$this->xMultiCell($meta[$i]['w'],$this->TBHh,$meta[$i]['t'],'','L','C',0);}
// 			}else{
// 			$this->writeHTML($this->XSumm,true,true);
// 			for($i=0;$i<count($meta);$i++){
// 				//$this->Cell($meta[$i]['w'],6,$meta[$i]['t'],'TLRB',0,'C',0);
// 				//$this->MultiCell($meta[$i]['w'],6,$meta[$i]['t'],'TLRB',0,'C',0,1,'','',true,0,false,true,0,'T',false);
// 				$this->xMultiCell($meta[$i]['w'],$this->TBHh,$meta[$i]['t'],'TLRB','L','C',0);
// 			}
// 			}
// 			$this->Ln();
// 		}
// 		$this->SetFillColor(246,246,246);
// 		$this->SetTextColor(0);
// 		$this->SetFont('','');
		
// 		return true;
// 	}

	/**
 	 * This method is used to render the page header.
 	 * It is automatically called by AddPage() and could be overwritten in your own inherited class.
	 */
	public function Header() {
// 		$this->SetMargins(0, 0, 0);
// 		$this->SetHeaderMargin(0);
// 		$this->SetFooterMargin(0);
		
		
		
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
			$header_x = $ormargins['right'] + ($headerdata['logo_width'] * 0.2);
		} else {
			$header_x = $ormargins['left'] + ($headerdata['logo_width'] * 0.2);
		}
		//ernie:
		$contwidth = ($this->GetPageWidth() - $ormargins['left'] - $ormargins['right'])/3;
		$ccell = $ormargins['left']+$contwidth;
		$rcell = $ormargins['left']+2*$contwidth;
		$this->SetTextColor(0, 0, 3);
		// header title
		
		$this->SetFont('dejavusans', 'B', 14);
		//$this->SetX($ccell);
		
		$this->SetY($myy);
		$this->SetX($header_x + $contwidth/3 );
		
// 		$this->SetAutoPageBreak(FALSE, PDF_MARGIN_BOTTOM);
		$this->writeHTML($headerdata['string'],true,false);
// 		$this->SetTopMargin(PDF_MARGIN_TOP);
// 		$this->writeHTML("<br/><br/>",true,false);
// 		$this->SetAutoPageBreak(TRUE, PDF_MARGIN_BOTTOM);
		if(isset($this->headerBarcode) && $this->headerBarcode == true)
			$this->write1DBarcode('04210000526', 'UPCE', '', '', 30, 10, 0.4, $style, 'M');
		$this->Ln(15);
		
		$this->SetLineStyle(array("width" => 0.85 / $this->getScaleFactor(), "cap" => "butt", "join" => "miter", "dash" => 0, "color" => array(0, 0, 0)));
		$this->SetY(1 + $imgy);
		
		
		
		if ($this->getRTL()) {
			$this->SetX($ormargins['right']);
		} else {
			$this->SetX($ormargins['left']);
		}
		$this->Cell(0, 0, '', 'T', 0, 'C');
	}
	
	public function Footer() {
		$cur_y = $this->y;
		$this->SetTextColorArray($this->footer_text_color);
		//set style for cell border
		$line_width = (0.55 / $this->k);
		$this->SetLineStyle(array('width' => $line_width, 'cap' => 'butt', 'join' => 'miter', 'dash' => 0, 'color' => $this->footer_line_color));
		//print document barcode
	
		if (isset($this->BCText)) {
			$barcode = $this->BCText;
			$this->Ln($line_width);
			$barcode_width = round(($this->w - $this->original_lMargin - $this->original_rMargin) / 3);
			$style = array(
					'position' => $this->rtl?'R':'L',
					'align' => $this->rtl?'R':'L',
					'stretch' => true,
					'fitwidth' => true,
					'cellfitalign' => '',
					'border' => false,
					'padding' => 0,
					'fgcolor' => array(0,0,0),
					'bgcolor' => false,
					'font' => 'helvetica',
					'fontsize' => 100,
					'text' => true
			);
			$this->write1DBarcode($barcode, 'C128', '', $cur_y + $line_width, '', (($this->footer_margin / 3) - $line_width), 0.3, $style, '');
		}
		$w_page = isset($this->l['w_page']) ? $this->l['w_page'].' ' : '';
		if (empty($this->pagegroups)) {
			$pagenumtxt = $w_page.$this->getAliasNumPage().' / '.$this->getAliasNbPages();
		} else {
			$pagenumtxt = $w_page.$this->getPageNumGroupAlias().' / '.$this->getPageGroupAlias();
		}
		$this->SetY($cur_y);
		//Print page number
		
		if ($this->getRTL()) {
			$this->SetX($this->original_rMargin);
			$this->Cell(0, 0, $pagenumtxt, 'T', 0, 'L');
		} else {
			$this->SetX($this->original_lMargin);
			$this->Cell(0, 0, $this->getAliasRightShift().$pagenumtxt, 'T', 0, 'R');
		}
	}
	public function SummaryBChart($meta,$dataset){
		//TODO: should come in $meta
// 		$rowLabels = array("A+","A","B+","B","C+","C","D+","D","F"); 
		$rowLabels = array("Very Good","Good","Average","Poor","very Poor");
		
		//array( "SupaWidget", "WonderWidget", "MegaWidget", "HyperWidget" );
		//TODO: should come in $meta
		$chartWidth = 160;
		$chartHeight = 80;
		$chartTopMargin = 20;
		$chartBottomMargin = 20;
		$chartXPos = 20;
		$chartYPos = (int)$this->GetY() + $chartHeight + $chartTopMargin; //100;
		$chartXLabel = "Grades";
		$chartYLabel = "Grading Score";
		
		//TODO: should come in $meta
		$chartColours = array(
				array( 255, 100, 100 ),
				array( 100, 255, 100 ),
				array( 100, 100, 255 ),
				array( 255, 255, 100 ),
				array( 255, 200, 200 ),
// 				array( 200, 255, 200 ),
// 				array( 200, 200, 255 ),
// 				array( 255, 255, 200 ),
// 				array(  50, 100, 200 ),
		);
		//TODO: should come in $dataset
		// Compute the X scale
		$data=$this->transpose($dataset);
		$xScale = count($rowLabels) / ( $chartWidth - 40 );
	
		// Compute the Y scale
	
		$maxTotal = 0;
	
		foreach ( $data as $dataRow ) {
			$totalSales = 0;
			foreach ($dataRow as $dataCell) $totalSales += $dataCell;
			$maxTotal = ( $totalSales > $maxTotal ) ? $totalSales : $maxTotal;
		}
	
		$yScale = $maxTotal / $chartHeight;
		$chartYStep = $maxTotal/10;
	
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
			$this->Cell( 20, 10, '' . number_format( $i ), 0, 0, 'R' );
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
	
		foreach ($data as $dataRow ) {
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
	
	function transpose($array) {
		$transposed_array = array();
		if ($array) {
			foreach ($array as $row_key => $row) {
				if (is_array($row) && !empty($row)) { //check to see if there is a second dimension
					foreach ($row as $column_key => $element) {
						$transposed_array[$column_key][$row_key] = $element;
						}
						}
						else {
							$transposed_array[0][$row_key] = $row;
							}
							}
							return $transposed_array;
							}
							}

		/**
		 * Convert color codes from hex to rgb for use by Charts
		 * @param type $string
		 * @return type
		 */
		private function hex2rgb($string){
			$resp = preg_split('/#([0-9A-F]{1,2})([0-9A-F]{1,2})([0-9A-F]{1,2})/',$string,-1,PREG_SPLIT_DELIM_CAPTURE);
			return array('r'=>  hexdec($resp[1]),'g'=>hexdec($resp[2]),'b'=>hexdec($resp[3]));
		}
		
		/**
		 * Compute maxima of Chart plot based on dataset
		 * @param type $data
		 * @return type
		 */
		private function chartmax($data){
			$max = 0;
			foreach($data as $row){
				$max = max($max,$row['value']);
			}
			return $max;
		}
		
		public function UXBarChart($cfg,$data,$legend=false){
			// Compute the X scale
			$xScale = count($data) / ( $cfg['width'] - 40 );
			$maxTotal = $this->chartmax($data);
			$yScale = $maxTotal / $cfg['height'];
		
			// Compute the bar width
			$barWidth = ( 1 / $xScale ) / 1.5;
		
			// Add the axes:
			$this->SetFont( '', '', 10);
		
			// X axis
			$this->Line( $cfg['xpos'] + 30, $cfg['ypos'], $cfg['xpos'] + $cfg['width'], $cfg['ypos'] );
			//$this->Arrow( $cfg['xpos'] + 30, $cfg['ypos'], $cfg['xpos'] + $cfg['width'], $cfg['ypos'], 1 );
		
			$this->SetTextColor(200,200,200);
			for ( $i=0; $i < count( $data ); $i++ ) {
				$this->SetXY( $cfg['xpos'] + 40 +  $i / $xScale, $cfg['ypos'] );
				$this->Cell( $barWidth, 10, $data[$i]['label'], 0, 0, 'C' );
			}
		
			// Y axis
			$this->Line( $cfg['xpos'] + 30, $cfg['ypos'], $cfg['xpos'] + 30, $cfg['ypos'] - $cfg['height'] - 8 );
		
			for ( $i=0; $i <= $maxTotal; $i += $cfg['ystep'] ) {
				$this->SetXY( $cfg['xpos'] + 7, $cfg['ypos'] - 5 - $i / $yScale );
				$this->Cell( 20, 10, number_format( $i ), 0, 0, 'R' );
				$this->Line( $cfg['xpos'] + 28, $cfg['ypos'] - $i / $yScale, $cfg['xpos'] + $cfg['width'], $cfg['ypos'] - $i / $yScale, array('dash'=>4) );
			}
			// Add the axis labels
			$this->SetTextColor(0,0,255);
			$this->SetFont( '', 'B', 10 );
			$this->SetXY( $cfg['width'] / 2 + 20, $cfg['ypos'] + 8 );
			$this->Cell( 30, 10, $cfg['xtitle'], 0, 0, 'C' );
			$this->SetXY( $cfg['xpos'] + 7, $cfg['ypos'] - $cfg['height'] - 12 );
			$this->Cell( 20, 10, $cfg['ytitle'], 0, 0, 'R' );
		
			// Create the bars
			$this->SetFont( '', 'B', 5 );
			$xPos = $cfg['xpos'] + 40;
			$bar = 0;
		
			$count = count($data);
			
// 			$this->SetFont( '', 'B', 10 );
			foreach ( $data as $ix => $row ) {
				$color = $this->hex2rgb($row['color']);
				$this->SetFillColor( $color['r'], $color['g'], $color['b'] );
				$this->Rect( $xPos, $cfg['ypos'] - ( $row['value'] / $yScale ), $barWidth, $row['value'] / $yScale, 'DF', array('all'=>array('dash'=>0)));
				//valuetext: test
				$this->SetXY($xPos, $cfg['ypos'] - ( $row['value'] / $yScale ) - 10);
				$this->Cell($barWidth, 10, $row['value'], 0, 0, 'C' );
				
				//Legend: test				
				if($legend){
					$this->SetFont('', 'B', 10 );
					$this->Rect($cfg['xleg'], $cfg['yleg']+$bar*10, 5, 5, 'DF', array('all'=>array('dash'=>0)));
					$this->SetXY($cfg['xleg']+10, $cfg['yleg']+$bar*10-3);
					$this->Cell( $this->getStringWidth($row['legend']), 10, $row['legend'], 0, 0, 'L' );					
				}
				$this->SetFont('', 'B', 5 );
				$xPos += ( 1 / $xScale );
				$bar++;
// 				}
			}
		
		}
		 
		public function UXPiechart($cfg,$data){
			$xc = $cfg['cx']; //105;$barWidth$barWidth
			$yc = $cfg['cy']; //100;
			$r = $cfg['r']; //50;
		
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
	
		/**
		 * This method allows printing text with line breaks.
		 * They can be automatic (as soon as the text reaches the right border of the cell) or explicit (via the \n character). As many cells as necessary are output, one below the other.<br />
		 * Text can be aligned, centered or justified. The cell block can be framed and the background painted.
		 * @param $w (float) Width of cells. If 0, they extend up to the right margin of the page.
		 * @param $h (float) Cell minimum height. The cell extends automatically if needed.
		 * @param $txt (string) String to print
		 * @param $border (mixed) Indicates if borders must be drawn around the cell. The value can be a number:<ul><li>0: no border (default)</li><li>1: frame</li></ul> or a string containing some or all of the following characters (in any order):<ul><li>L: left</li><li>T: top</li><li>R: right</li><li>B: bottom</li></ul> or an array of line styles for each border group - for example: array('LTRB' => array('width' => 2, 'cap' => 'butt', 'join' => 'miter', 'dash' => 0, 'color' => array(0, 0, 0)))
		 * @param $align (string) Allows to center or align the text. Possible values are:<ul><li>L or empty string: left align</li><li>C: center</li><li>R: right align</li><li>J: justification (default value when $ishtml=false)</li></ul>
		 * @param $fill (boolean) Indicates if the cell background must be painted (true) or transparent (false).
		 * @param $ln (int) Indicates where the current position should go after the call. Possible values are:<ul><li>0: to the right</li><li>1: to the beginning of the next line [DEFAULT]</li><li>2: below</li></ul>
		 * @param $x (float) x position in user units
		 * @param $y (float) y position in user units
		 * @param $reseth (boolean) if true reset the last cell height (default true).
		 * @param $stretch (int) font stretch mode: <ul><li>0 = disabled</li><li>1 = horizontal scaling only if text is larger than cell width</li><li>2 = forced horizontal scaling to fit cell width</li><li>3 = character spacing only if text is larger than cell width</li><li>4 = forced character spacing to fit cell width</li></ul> General font stretching and scaling values will be preserved when possible.
		 * @param $ishtml (boolean) INTERNAL USE ONLY -- set to true if $txt is HTML content (default = false). Never set this parameter to true, use instead writeHTMLCell() or writeHTML() methods.
		 * @param $autopadding (boolean) if true, uses internal padding and automatically adjust it to account for line width.
		 * @param $maxh (float) maximum height. It should be >= $h and less then remaining space to the bottom of the page, or 0 for disable this feature. This feature works only when $ishtml=false.
		 * @param $valign (string) Vertical alignment of text (requires $maxh = $h > 0). Possible values are:<ul><li>T: TOP</li><li>M: middle</li><li>B: bottom</li></ul>. This feature works only when $ishtml=false and the cell must fit in a single page.
		 * @param $fitcell (boolean) if true attempt to fit all the text within the cell by reducing the font size (do not work in HTML mode). $maxh must be greater than 0 and equal to $h.
		 * @return int Return the number of cells or 1 for html mode.
		 * @public
		 * @since 1.3
		 * @see SetFont(), SetDrawColor(), SetFillColor(), SetTextColor(), SetLineWidth(), Cell(), Write(), SetAutoPageBreak()
		 */
		public function MultiCell($w, $h, $txt, $border=0, $align='J', $fill=false, $ln=1, $x='', $y='', $reseth=true, $stretch=0, $ishtml=false, $autopadding=true, $maxh=0, $valign='T', $fitcell=false) {
			$prev_cell_margin = $this->cell_margin;
			$prev_cell_padding = $this->cell_padding;
			// adjust internal padding
			$this->adjustCellPadding($border);
			$mc_padding = $this->cell_padding;
			$mc_margin = $this->cell_margin;
			$this->cell_padding['T'] = 0;
			$this->cell_padding['B'] = 0;
			$this->setCellMargins(0, 0, 0, 0);
			if (TCPDF_STATIC::empty_string($this->lasth) OR $reseth) {
				// reset row height
				$this->resetLastH();
			}
			if (!TCPDF_STATIC::empty_string($y)) {
				$this->SetY($y);
			} else {
				$y = $this->GetY();
			}
			
			$resth = 0;
			if (($h > 0) AND $this->inPageBody() AND (($y + $h + $mc_margin['T'] + $mc_margin['B']) > $this->PageBreakTrigger)) {
				// spit cell in more pages/columns
				$newh = ($this->PageBreakTrigger - $y);
				$resth = ($h - $newh); // cell to be printed on the next page/column
				$h = $newh;
			}
			// get current page number
			$startpage = $this->page;
			// get current column
			$startcolumn = $this->current_column;
			if (!TCPDF_STATIC::empty_string($x)) {
				$this->SetX($x);
			} else {
				$x = $this->GetX();
			}
			// check page for no-write regions and adapt page margins if necessary
			list($x, $y) = $this->checkPageRegions(0, $x, $y);
			// apply margins
			$oy = $y + $mc_margin['T'];
			if ($this->rtl) {
				$ox = ($this->w - $x - $mc_margin['R']);
			} else {
				$ox = ($x + $mc_margin['L']);
			}
			$this->x = $ox;
			$this->y = $oy;
			// set width
			if (TCPDF_STATIC::empty_string($w) OR ($w <= 0)) {
				if ($this->rtl) {
					$w = ($this->x - $this->lMargin - $mc_margin['L']);
				} else {
					$w = ($this->w - $this->x - $this->rMargin - $mc_margin['R']);
				}
			}
			// store original margin values
			$lMargin = $this->lMargin;
			$rMargin = $this->rMargin;
			if ($this->rtl) {
				$this->rMargin = ($this->w - $this->x);
				$this->lMargin = ($this->x - $w);
			} else {
				$this->lMargin = ($this->x);
				$this->rMargin = ($this->w - $this->x - $w);
			}
			$this->clMargin = $this->lMargin;
			$this->crMargin = $this->rMargin;
			if ($autopadding) {
				// add top padding
				$this->y += $mc_padding['T'];
			}
			if ($ishtml) { // ******* Write HTML text
				$this->writeHTML($txt, true, false, $reseth, true, $align);
				$nl = 1;
			} else { // ******* Write simple text
				$prev_FontSizePt = $this->FontSizePt;
				if ($fitcell) {
					// ajust height values
					$tobottom = ($this->h - $this->y - $this->bMargin - $this->cell_padding['T'] - $this->cell_padding['B']);
					$h = $maxh = max(min($h, $tobottom), min($maxh, $tobottom));
				}
				// vertical alignment
				if ($maxh > 0) {
					// get text height
					$text_height = $this->getStringHeight($w, $txt, $reseth, $autopadding, $mc_padding, $border);
					if ($fitcell AND ($text_height > $maxh) AND ($this->FontSizePt > 1)) {
						// try to reduce font size to fit text on cell (use a quick search algorithm)
						$fmin = 1;
						$fmax = $this->FontSizePt;
						$diff_epsilon = (1 / $this->k); // one point (min resolution)
						$maxit = (2 * min(100, max(10, intval($fmax)))); // max number of iterations
						while ($maxit >= 0) {
							$fmid = (($fmax + $fmin) / 2);
							$this->SetFontSize($fmid, false);
							$this->resetLastH();
							$text_height = $this->getStringHeight($w, $txt, $reseth, $autopadding, $mc_padding, $border);
							$diff = ($maxh - $text_height);
							if ($diff >= 0) {
								if ($diff <= $diff_epsilon) {
									break;
								}
								$fmin = $fmid;
							} else {
								$fmax = $fmid;
							}
							--$maxit;
						}
						if ($maxit < 0) {
							// premature exit, we get the minimum font value to fit the cell
							$this->SetFontSize($fmin);
							$this->resetLastH();
							$text_height = $this->getStringHeight($w, $txt, $reseth, $autopadding, $mc_padding, $border);
						} else {
							$this->SetFontSize($fmid);
							$this->resetLastH();
						}
					}
					if ($text_height < $maxh) {
						if ($valign == 'M') {
							// text vertically centered
							$this->y += (($maxh - $text_height) / 2);
						} elseif ($valign == 'B') {
							// text vertically aligned on bottom
							$this->y += ($maxh - $text_height);
						}
					}
				}
				$nl = $this->Write($this->lasth, $txt, '', 0, $align, true, $stretch, false, true, $maxh, 0, $mc_margin);
				if ($fitcell) {
					// restore font size
					$this->SetFontSize($prev_FontSizePt);
				}
			}
			if ($autopadding) {
			// add bottom padding
			$this->y += $mc_padding['B'];
			}
			// Get end-of-text Y position
			$currentY = $this->y;
			// get latest page number
			$endpage = $this->page;
			if ($resth > 0) {
				$skip = ($endpage - $startpage);
				$tmpresth = $resth;
				while ($tmpresth > 0) {
					if ($skip <= 0) {
						// add a page (or trig AcceptPageBreak() for multicolumn mode)
						$this->checkPageBreak($this->PageBreakTrigger + 1);
					}
					if ($this->num_columns > 1) {
						$tmpresth -= ($this->h - $this->y - $this->bMargin);
					} else {
						$tmpresth -= ($this->h - $this->tMargin - $this->bMargin);
					}
					--$skip;
				}
				$currentY = $this->y;
				$endpage = $this->page;
			}
			// get latest column
			$endcolumn = $this->current_column;
			if ($this->num_columns == 0) {
				$this->num_columns = 1;
			}
			// disable page regions check
			$check_page_regions = $this->check_page_regions;
			$this->check_page_regions = false;
			// get border modes
			$border_start = TCPDF_STATIC::getBorderMode($border, $position='start', $this->opencell);
			$border_end = TCPDF_STATIC::getBorderMode($border, $position='end', $this->opencell);
			$border_middle = TCPDF_STATIC::getBorderMode($border, $position='middle', $this->opencell);
			// design borders around HTML cells.
			for ($page = $startpage; $page <= $endpage; ++$page) { // for each page
				$ccode = '';
				$this->setPage($page);
				if ($this->num_columns < 2) {
					// single-column mode
					$this->SetX($x);
					$this->y = $this->tMargin;
				}
				// account for margin changes
				if ($page > $startpage) {
					if (($this->rtl) AND ($this->pagedim[$page]['orm'] != $this->pagedim[$startpage]['orm'])) {
						$this->x -= ($this->pagedim[$page]['orm'] - $this->pagedim[$startpage]['orm']);
					} elseif ((!$this->rtl) AND ($this->pagedim[$page]['olm'] != $this->pagedim[$startpage]['olm'])) {
						$this->x += ($this->pagedim[$page]['olm'] - $this->pagedim[$startpage]['olm']);
					}
				}
				if ($startpage == $endpage) {
					// single page
					for ($column = $startcolumn; $column <= $endcolumn; ++$column) { // for each column
						$this->selectColumn($column);
						if ($this->rtl) {
							$this->x -= $mc_margin['R'];
						} else {
							$this->x += $mc_margin['L'];
						}
						if ($startcolumn == $endcolumn) { // single column
							$cborder = $border;
							$h = max($h, ($currentY - $oy));
							$this->y = $oy;
						} elseif ($column == $startcolumn) { // first column
							$cborder = $border_start;
							$this->y = $oy;
							$h = $this->h - $this->y - $this->bMargin;
						} elseif ($column == $endcolumn) { // end column
							$cborder = $border_end;
							$h = $currentY - $this->y;
							if ($resth > $h) {
								$h = $resth;
							}
						} else { // middle column
							$cborder = $border_middle;
							$h = $this->h - $this->y - $this->bMargin;
							$resth -= $h;
						}
						$ccode .= $this->getCellCode($w, $h, '', $cborder, 1, '', $fill, '', 0, true)."\n";
					} // end for each column
				} elseif ($page == $startpage) { // first page
					for ($column = $startcolumn; $column < $this->num_columns; ++$column) { // for each column
						$this->selectColumn($column);
						if ($this->rtl) {
							$this->x -= $mc_margin['R'];
						} else {
							$this->x += $mc_margin['L'];
						}
						if ($column == $startcolumn) { // first column
							$cborder = $border_start;
							$this->y = $oy;
							$h = $this->h - $this->y - $this->bMargin;
						} else { // middle column
							$cborder = $border_middle;
							$h = $this->h - $this->y - $this->bMargin;
							$resth -= $h;
						}
						$ccode .= $this->getCellCode($w, $h, '', $cborder, 1, '', $fill, '', 0, true)."\n";
					} // end for each column
				} elseif ($page == $endpage) { // last page
					for ($column = 0; $column <= $endcolumn; ++$column) { // for each column
						$this->selectColumn($column);
						if ($this->rtl) {
							$this->x -= $mc_margin['R'];
						} else {
							$this->x += $mc_margin['L'];
						}
						if ($column == $endcolumn) {
							// end column
							$cborder = $border_end;
							$h = $currentY - $this->y;
							if ($resth > $h) {
								$h = $resth;
							}
						} else {
							// middle column
							$cborder = $border_middle;
							$h = $this->h - $this->y - $this->bMargin;
							$resth -= $h;
						}
						$ccode .= $this->getCellCode($w, $h, '', $cborder, 1, '', $fill, '', 0, true)."\n";
					} // end for each column
				} else { // middle page
					for ($column = 0; $column < $this->num_columns; ++$column) { // for each column
						$this->selectColumn($column);
						if ($this->rtl) {
							$this->x -= $mc_margin['R'];
						} else {
							$this->x += $mc_margin['L'];
						}
						$cborder = $border_middle;
						$h = $this->h - $this->y - $this->bMargin;
						$resth -= $h;
						$ccode .= $this->getCellCode($w, $h, '', $cborder, 1, '', $fill, '', 0, true)."\n";
					} // end for each column
				}
				if ($cborder OR $fill) {
					$offsetlen = strlen($ccode);
					// draw border and fill
					if ($this->inxobj) {
						// we are inside an XObject template
						if (end($this->xobjects[$this->xobjid]['transfmrk']) !== false) {
							$pagemarkkey = key($this->xobjects[$this->xobjid]['transfmrk']);
							$pagemark = $this->xobjects[$this->xobjid]['transfmrk'][$pagemarkkey];
							$this->xobjects[$this->xobjid]['transfmrk'][$pagemarkkey] += $offsetlen;
						} else {
							$pagemark = $this->xobjects[$this->xobjid]['intmrk'];
							$this->xobjects[$this->xobjid]['intmrk'] += $offsetlen;
						}
						$pagebuff = $this->xobjects[$this->xobjid]['outdata'];
						$pstart = substr($pagebuff, 0, $pagemark);
						$pend = substr($pagebuff, $pagemark);
						$this->xobjects[$this->xobjid]['outdata'] = $pstart.$ccode.$pend;
					} else {
						if (end($this->transfmrk[$this->page]) !== false) {
							$pagemarkkey = key($this->transfmrk[$this->page]);
							$pagemark = $this->transfmrk[$this->page][$pagemarkkey];
							$this->transfmrk[$this->page][$pagemarkkey] += $offsetlen;
						} elseif ($this->InFooter) {
							$pagemark = $this->footerpos[$this->page];
							$this->footerpos[$this->page] += $offsetlen;
						} else {
							$pagemark = $this->intmrk[$this->page];
							$this->intmrk[$this->page] += $offsetlen;
						}
						$pagebuff = $this->getPageBuffer($this->page);
						$pstart = substr($pagebuff, 0, $pagemark);
						$pend = substr($pagebuff, $pagemark);
						$this->setPageBuffer($this->page, $pstart.$ccode.$pend);
					}
				}
			} // end for each page
			// restore page regions check
			$this->check_page_regions = $check_page_regions;
			// Get end-of-cell Y position
			$currentY = $this->GetY();
			// restore previous values
			if ($this->num_columns > 1) {
				$this->selectColumn();
			} else {
				// restore original margins
				$this->lMargin = $lMargin;
				$this->rMargin = $rMargin;
				if ($this->page > $startpage) {
					// check for margin variations between pages (i.e. booklet mode)
					$dl = ($this->pagedim[$this->page]['olm'] - $this->pagedim[$startpage]['olm']);
					$dr = ($this->pagedim[$this->page]['orm'] - $this->pagedim[$startpage]['orm']);
					if (($dl != 0) OR ($dr != 0)) {
						$this->lMargin += $dl;
						$this->rMargin += $dr;
					}
				}
			}
			if ($ln > 0) {
				//Go to the beginning of the next line
				$this->SetY($currentY + $mc_margin['B']);
				if ($ln == 2) {
					$this->SetX($x + $w + $mc_margin['L'] + $mc_margin['R']);
				}
			} else {
				// go left or right by case
				$this->setPage($startpage);
				$this->y = $y;
				$this->SetX($x + $w + $mc_margin['L'] + $mc_margin['R']);
			}
			$this->setContentMark();
			$this->cell_padding = $prev_cell_padding;
			$this->cell_margin = $prev_cell_margin;
			$this->clMargin = $this->lMargin;
			$this->crMargin = $this->rMargin;
			return $nl;
		}
		
}
?>