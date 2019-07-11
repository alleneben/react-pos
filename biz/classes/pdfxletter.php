<?php
// PDF Letter Printing
class PDFXLetter extends PDFBase{
	
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
		$this->writeHTML("<br/><br/><br/><br/><br/>",true,false,false,'');
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

		$contwidth = ($this->GetPageWidth() - $ormargins['left'] - $ormargins['right'])/3;
// 		$ccell = $ormargins['left']+$contwidth;
// 		$rcell = $ormargins['left']+2*$contwidth;
		$this->SetTextColor(0, 2, 106);
		// header title
		$this->SetFont($headerfont[0], 'B', $headerfont[2] + 10);
		//$this->SetX($ccell);

		$this->SetY(8);
		$this->SetX($contwidth-20);
	
		$this->SetFillColor(255,255,255);
	
		$sch=$this->HEAD;
		$head="<tr><td>$sch</td></tr>";	
		$this->writeHTML($head,false,true);
	
		$this->SetLineStyle(array("width" => 0.85 / $this->getScaleFactor(), "cap" => "butt", "join" => "miter", "dash" => 0, "color" => array(186, 156, 0)));
		
		
		if ($this->getRTL()) {
			$this->SetX($ormargins['right']);
		} else {
			$this->SetX($ormargins['left']);
		}
				
		$this->Cell(0, 0, '', 'T', 0, 'C');
	}

	
	public function Footer() {	
		$headerfont = $this->getHeaderFont();
		$cur_y = $this->GetY();
		$ormargins = $this->getOriginalMargins();
		$this->SetTextColor(0, 0, 0);			
		//set style for cell border
		$line_width = 0.85 / $this->getScaleFactor();
		$this->SetLineStyle(array("width" => $line_width, "cap" => "butt", "join" => "miter", "dash" => 0, "color" => array(0, 0, 0)));
		//print document barcode
		$barcode = $this->getBarcode();
		error_log($barcode);
		if (!empty($barcode)) {
			$this->Ln();
			$barcode_width = round(($this->getPageWidth() - $ormargins['left'] - $ormargins['right'])/3);
			$style = array(
					'position' => $this->rtl?'R':'L',
					'align' => $this->rtl?'R':'L',
					'stretch' => false,
					'fitwidth' => true,
					'cellfitalign' => '',
					'border' => false,
					'padding' => 0,
					'fgcolor' => array(0,0,0),
					'bgcolor' => false,
					'text' => true
			);
			$this->write1DBarcode($barcode, "C128B", $this->GetX(), $cur_y + $line_width-12, $barcode_width, (($this->getFooterMargin() / 3) - $line_width), 0.3, $style, '');	
		}

		
		$foot=$this->FootData;
// 		"Industrial Liaison Office:: Tel.: 03223-96131/96724, 03521-95981, 0245881837, Fax:03220-38868, E-mail: ilo@kpoly.edu.gh";
		$this->SetTextColor(0, 0, 0);
// 		$pdf->SetFont('helvetica', '', 10);
		$this->SetFont($headerfont[0], 'I', 7);
		$this->SetY($cur_y-5);
		$this->writeHTML($foot,true,false);
		$this->SetY($cur_y-5);
		$this->SetX($ormargins['right']);
		$this->Cell(0, 0,'' , 'T', 0, 'L');

		
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
	
// 	public function Output($name = 'doc.pdf', $dest = 'I')
// 	{
// 		$this->tcpdflink = false;
// // 		$this->PageBreakTrigger=false;
// // 		$lp=$this->getPage();
// // 		error_log("PAGE:$lp");
// 		return parent::Output($name, $dest);
// 	}

	/**
	 * Remove the specified page.
	 * @param $page (int) page to remove
	 * @return true in case of success, false in case of error.
	 * @public
	 * @since 4.6.004 (2009-04-23)
	 */
	public function deletePage($page) {
		if (($page < 1) OR ($page > $this->getNumPages())) {
			return false;
		}
		// delete current page
		unset($this->pages[$page]);
		unset($this->pagedim[$page]);
		unset($this->pagelen[$page]);
		unset($this->intmrk[$page]);
		unset($this->bordermrk[$page]);
		unset($this->cntmrk[$page]);
		foreach ($this->pageobjects[$page] as $oid) {
			if (isset($this->offsets[$oid])){
				unset($this->offsets[$oid]);
			}
		}
		unset($this->pageobjects[$page]);
		if (isset($this->footerpos[$page])) {
			unset($this->footerpos[$page]);
		}
		if (isset($this->footerlen[$page])) {
			unset($this->footerlen[$page]);
		}
		if (isset($this->transfmrk[$page])) {
			unset($this->transfmrk[$page]);
		}
		if (isset($this->PageAnnots[$page])) {
			unset($this->PageAnnots[$page]);
		}
		if (isset($this->newpagegroup) AND !empty($this->newpagegroup)) {
			for ($i = $page; $i > 0; --$i) {
				if (isset($this->newpagegroup[$i]) AND (($i + $this->pagegroups[$this->newpagegroup[$i]]) > $page)) {
					--$this->pagegroups[$this->newpagegroup[$i]];
					break;
				}
			}
		}
		if (isset($this->pageopen[$page])) {
			unset($this->pageopen[$page]);
		}
		if ($page < $this->numpages) {
			// update remaining pages
			for ($i = $page; $i < $this->numpages; ++$i) {
				$j = $i + 1;
				// shift pages
				$this->setPageBuffer($i, $this->getPageBuffer($j));
				$this->pagedim[$i] = $this->pagedim[$j];
				$this->pagelen[$i] = $this->pagelen[$j];
				$this->intmrk[$i] = $this->intmrk[$j];
				$this->bordermrk[$i] = $this->bordermrk[$j];
				$this->cntmrk[$i] = $this->cntmrk[$j];
				$this->pageobjects[$i] = $this->pageobjects[$j];
				if (isset($this->footerpos[$j])) {
					$this->footerpos[$i] = $this->footerpos[$j];
				} elseif (isset($this->footerpos[$i])) {
					unset($this->footerpos[$i]);
				}
				if (isset($this->footerlen[$j])) {
					$this->footerlen[$i] = $this->footerlen[$j];
				} elseif (isset($this->footerlen[$i])) {
					unset($this->footerlen[$i]);
				}
				if (isset($this->transfmrk[$j])) {
					$this->transfmrk[$i] = $this->transfmrk[$j];
				} elseif (isset($this->transfmrk[$i])) {
					unset($this->transfmrk[$i]);
				}
				if (isset($this->PageAnnots[$j])) {
					$this->PageAnnots[$i] = $this->PageAnnots[$j];
				} elseif (isset($this->PageAnnots[$i])) {
					unset($this->PageAnnots[$i]);
				}
				if (isset($this->newpagegroup[$j])) {
					$this->newpagegroup[$i] = $this->newpagegroup[$j];
					unset($this->newpagegroup[$j]);
				}
				if ($this->currpagegroup == $j) {
					$this->currpagegroup = $i;
				}
				if (isset($this->pageopen[$j])) {
					$this->pageopen[$i] = $this->pageopen[$j];
				} elseif (isset($this->pageopen[$i])) {
					unset($this->pageopen[$i]);
				}
			}
			// remove last page
			unset($this->pages[$this->numpages]);
			unset($this->pagedim[$this->numpages]);
			unset($this->pagelen[$this->numpages]);
			unset($this->intmrk[$this->numpages]);
			unset($this->bordermrk[$this->numpages]);
			unset($this->cntmrk[$this->numpages]);
			foreach ($this->pageobjects[$this->numpages] as $oid) {
				if (isset($this->offsets[$oid])){
					unset($this->offsets[$oid]);
				}
			}
			unset($this->pageobjects[$this->numpages]);
			if (isset($this->footerpos[$this->numpages])) {
				unset($this->footerpos[$this->numpages]);
			}
			if (isset($this->footerlen[$this->numpages])) {
				unset($this->footerlen[$this->numpages]);
			}
			if (isset($this->transfmrk[$this->numpages])) {
				unset($this->transfmrk[$this->numpages]);
			}
			if (isset($this->PageAnnots[$this->numpages])) {
				unset($this->PageAnnots[$this->numpages]);
			}
			if (isset($this->newpagegroup[$this->numpages])) {
				unset($this->newpagegroup[$this->numpages]);
			}
			if ($this->currpagegroup == $this->numpages) {
				$this->currpagegroup = ($this->numpages - 1);
			}
			if (isset($this->pagegroups[$this->numpages])) {
				unset($this->pagegroups[$this->numpages]);
			}
			if (isset($this->pageopen[$this->numpages])) {
				unset($this->pageopen[$this->numpages]);
			}
		}
		--$this->numpages;
		$this->page = $this->numpages;
		// adjust outlines
		$tmpoutlines = $this->outlines;
		foreach ($tmpoutlines as $key => $outline) {
			if (!$outline['f']) {
				if ($outline['p'] > $page) {
					$this->outlines[$key]['p'] = $outline['p'] - 1;
				} elseif ($outline['p'] == $page) {
					unset($this->outlines[$key]);
				}
			}
		}
		// adjust dests
		$tmpdests = $this->dests;
		foreach ($tmpdests as $key => $dest) {
			if (!$dest['f']) {
				if ($dest['p'] > $page) {
					$this->dests[$key]['p'] = $dest['p'] - 1;
				} elseif ($dest['p'] == $page) {
					unset($this->dests[$key]);
				}
			}
		}
		// adjust links
		$tmplinks = $this->links;
		foreach ($tmplinks as $key => $link) {
			if (!$link['f']) {
				if ($link['p'] > $page) {
					$this->links[$key]['p'] = $link['p'] - 1;
				} elseif ($link['p'] == $page) {
					unset($this->links[$key]);
				}
			}
		}
		// adjust javascript
		$jpage = $page;
		if (preg_match_all('/this\.addField\(\'([^\']*)\',\'([^\']*)\',([0-9]+)/', $this->javascript, $pamatch) > 0) {
			foreach($pamatch[0] as $pk => $pmatch) {
				$pagenum = intval($pamatch[3][$pk]) + 1;
				if ($pagenum >= $jpage) {
					$newpage = ($pagenum - 1);
				} elseif ($pagenum == $jpage) {
					$newpage = 1;
				} else {
					$newpage = $pagenum;
				}
				--$newpage;
				$newjs = "this.addField(\'".$pamatch[1][$pk]."\',\'".$pamatch[2][$pk]."\',".$newpage;
				$this->javascript = str_replace($pmatch, $newjs, $this->javascript);
			}
			unset($pamatch);
		}
		// return to last page
		if ($this->numpages > 0) {
			$this->lastPage(true);
		}
		return true;
	}
	
}

?>