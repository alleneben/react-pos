<?php
// PDF Letter Printing
class PDFLetter extends PDFBase{
	
	/**
	* checkPageBreak V4 
	* Add page if needed.
	* @param float $h Cell height. Default value: 0.
	* @since 3.2.000 (2008-07-01)
	* @access protected
	*//*
	protected function checkPageBreakV4($h) {
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
	}
	*/
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
	/*
	protected function checkPageBreak($h=0, $y='', $addpage=true) {
		if ($this->empty_string($y)) {
			$y = $this->y;
		}
		$current_page = $this->page;
		if ((($y + $h) > $this->PageBreakTrigger) AND ($this->inPageBody()) AND ($this->AcceptPageBreak())) {
			if ($addpage) {
				$this->BeforePageBreak();
				//Automatic page break
				$x = $this->x;
				$this->AddPage($this->CurOrientation);
				$this->y = $this->tMargin;
				$oldpage = $this->page - 1;
				if ($this->rtl) {
					if ($this->pagedim[$this->page]['orm'] != $this->pagedim[$oldpage]['orm']) {
						$this->x = $x - ($this->pagedim[$this->page]['orm'] - $this->pagedim[$oldpage]['orm']);
					} else {
						$this->x = $x;
					}
				} else {
					if ($this->pagedim[$this->page]['olm'] != $this->pagedim[$oldpage]['olm']) {
						$this->x = $x + ($this->pagedim[$this->page]['olm'] - $this->pagedim[$oldpage]['olm']);
					} else {
						$this->x = $x;
					}
				}
			}
			return true;
		}
		if ($current_page != $this->page) {
			// account for columns mode
			return true;
		}
		return false;
	}
	*/
	/**
	* An event handler for final operations on a page, e.g table line
	* @return boolean
	* @since 1.4
	*/
	protected function BeforePageBreak() {
		return true;
	}
	
	/**
	* An event handler for initial operations on a page, e.g table headers
	* @return boolean
	* @since 1.4
	*/
	protected function AfterPageBreak() {
		$this->SetTextColor(0);
		$this->SetFont('','B');
		//if(isset($this->autoHeader) && $this->autoHeader == false);
		//else{
			//$meta = $this->TbMeta;
			//for($i=0;$i<count($meta);$i++){
			//	$this->Cell($meta[$i]['w'],6,$meta[$i]['t'],'TLRB',0,'C',0);
			//}
			//$this->Ln();
		//}
		$this->SetFillColor(246,246,246);
		$this->SetTextColor(0);
		$this->SetFont('','');
		
		return true;
	}
	/**
 	 * This method is used to render the page header.
 	 * It is automatically called by AddPage() and could be overwritten in your own inherited class.
	 */
	
	public function Header() {
		$ormargins = $this->getOriginalMargins();
		$headerfont = $this->getHeaderFont();
		$headerdata = $this->getHeaderData();
		if (($headerdata['logo']) AND ($headerdata['logo'] != K_BLANK_IMAGE)) {
			//$this->Image(K_PATH_IMAGES.$headerdata['logo'], $this->GetX(), $this->getHeaderMargin(), $headerdata['logo_width']);
			$imgy = $this->getImageRBY();
		} else {
			$imgy = 8+$this->GetY();
		}
		//error_log("img y is $imgy");
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
		//ERNIE-start
		$this->SetFillColor(255,255,255);
		//$pdf->SetTextColor(0);
		//ERNIE-end
	
		$this->writeHTML($headerdata['string'],true,true);
	
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
		//ERNIE-start
		$this->SetY($cur_y);
		$this->SetX($ormargins['right']);
		$this->Cell(0, 0, '', 'T', 0, 'L');
		//ERNIE-end
		
	//	$pagenumtxt = $this->l['w_page']." ".$this->PageNo().' / '.$this->getAliasNbPages();
	//	$this->SetY($cur_y);
	//	//Print page number
	//	if ($this->getRTL()) {
	//		$this->SetX($ormargins['right']);
	//		$this->Cell(0, 0, $pagenumtxt, 'T', 0, 'L');
	//	} else {
	//		$this->SetX($ormargins['left']);
	//		$this->Cell(0, 0, $pagenumtxt, 'T', 0, 'R');
	//	}
	}
	
}

?>