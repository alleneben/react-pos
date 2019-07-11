<?php
include_once('config.php');
require_once('lib/phpxls/PHPExcel.php');


// CSV Printing
class XLSPrinter{

    public function __construct(){
			$this->xls = new PHPExcel();        
        $this->error = new ErrorHandler();
    }
	
	public function Nabptex($meta,$gd){		
		try{
		$acy=$gd['ryr']+1;
		$cnt = $meta['ct'];
		$hdr  = $meta['hdr'];
		$fname = $meta['fn'];
		$dur =$meta['dur'];

		// Create new PHPExcel object
		$xls = $this->xls;		
		$headstyle=array('alignment'    => array('horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER),'font'=>array('size'=>12,'bold'=>true));
		$subheadstyle=array('alignment' => array('horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER),'borders'=>array('allborders'=>array( 'style' =>PHPExcel_Style_Border::BORDER_THIN)),'font'=>array('size'=>11,'bold'=>true));
		$bodystyle=array('borders'=>array('allborders'=>array( 'style' => PHPExcel_Style_Border::BORDER_THIN)),'font'=>array('size'=>7,));
		$hstyle=array('borders'=>array('allborders'=>array( 'style' => PHPExcel_Style_Border::BORDER_THIN)),'font'=>array('size'=>7,'bold'=>true));
		$head="Head of Department: ………………………………………………………… Signature: ………………………………………………………… Date: …………………………………………………………";
		$rect="Rector/Vice Rector: ………………………………………………………… Signature: ………………………………………………………… Date: …………………………………………………………";
		$exmn="External Examiner : ………………………………………………………… Signature: ………………………………………………………… Date: …………………………………………………………";
		
		// Set document properties
		//TODO get logged in user and Change creater and last modifier
		$xls->getProperties()->setCreator("Peter Amoako-Yirenkyi")
		->setLastModifiedBy("Peter Amoako-Yirenkyi")
		->setTitle($meta['rpt'])
		->setSubject("general Report")
		->setDescription("This is a report generated from the system")
		->setKeywords("report")
		->setCategory("Main reports");
		
		
		// Prepare header				
		$xls->setActiveSheetIndex(0)
		->setCellValue('A1', $meta['enm'])->mergeCells("A1:AC1")
		->setCellValue('A2', $gd['dtn'])->mergeCells("A2:AC2")
		->setCellValue('A3', "$meta[gnm] $gd[ryr]/$acy Academic Year")->mergeCells("A3:AC3")
		->setCellValue('A4', "$gd[dpn] Department")->mergeCells("A4:AC4")
		->setCellValue('A5', $gd['pnm'])->mergeCells("A5:AC5");
		$xls->getActiveSheet()->getStyle('A1:A5')->applyFromArray($headstyle);
		
		// Get Last column
		$last=($dur==6?'AC': ($dur==4?'U':($dur==3?'Q':'M')));
		
		// Prepare sub header and Merge cells		
		if($dur==6){
		$xls->getActiveSheet()
		->setCellValue('D7',"SEM 1")->mergeCells("D7:F7")
		->setCellValue('G7',"SEM 2")->mergeCells("G7:J7")
		->setCellValue('K7',"SEM 3")->mergeCells("K7:N7")
		->setCellValue('O7',"SEM 4")->mergeCells("O7:R7")
		->setCellValue('S7',"SEM 5")->mergeCells("S7:V7")
		->setCellValue('W7',"SEM 6")->mergeCells("W7:Y7")
		->setCellValue('Z7',"CUMULATIVE")->mergeCells("Z7:AB7")
		->setCellValue('AC7',"");
	
		}elseif ($dur==4){
		$xls->getActiveSheet()
		->setCellValue('D7',"SEM 1")->mergeCells("D7:F7")
		->setCellValue('G7',"SEM 2")->mergeCells("G7:J7")
		->setCellValue('K7',"SEM 3")->mergeCells("K7:N7")
		->setCellValue('O7',"SEM 4")->mergeCells("O7:Q7")
		->setCellValue('R7',"CUMULATIVE")->mergeCells("R7:T7")
		->setCellValue('U7',"");

		}elseif ($dur==3){
		$xls->getActiveSheet()
		->setCellValue('D7',"SEM 1")->mergeCells("D7:F7")
		->setCellValue('G7',"SEM 2")->mergeCells("G7:J7")
		->setCellValue('K7',"SEM 3")->mergeCells("K7:M7")
		->setCellValue('N7',"CUMULATIVE")->mergeCells("N7:P7")
		->setCellValue('Q7',"");

		}else{
		$xls->getActiveSheet()
		->setCellValue('D7',"SEM 1")->mergeCells("D7:F7")
		->setCellValue('G7',"SEM 2")->mergeCells("G7:I7")
		->setCellValue('J7',"CUMULATIVE")->mergeCells("J7:L7")
		->setCellValue('M7',"");

		}
			
		$xls->getActiveSheet()->getStyle('A7:'.$last.'7')->applyFromArray($subheadstyle);
		
		$h=array_values($hdr);
		$l=count($hdr);
		$offset=8;
		for ($c = 0; $c <=$l-1 ; $c++) {
				$xls->getActiveSheet()->setCellValueByColumnAndRow($c,$offset,$h[$c]);
				$xls->getActiveSheet()->getStyleByColumnAndRow($c,$offset)->applyFromArray($hstyle);
				
			}
			
		
		$r=$offset+1;
		$idx=0;$sn=0;
		$k=array_keys($hdr);
		foreach ($meta['sd'] as $rec){
			$rec['rid']=++$sn;
			for ($c = 0; $c <= $l-1; $c++) {				
				$xls->getActiveSheet()->setCellValueExplicitByColumnAndRow($c,$r,$rec[$k[$c]]);
				$xls->getActiveSheet()->getStyleByColumnAndRow($c,$r)->applyFromArray($bodystyle);
				
			}
			$r++;
			$idx++;

		if(($idx==11) && ($sn<$cnt)){
			$idx=0;

		
		$r=$r+2;
		$xls->getActiveSheet()->setCellValueByColumnAndRow(0,$r++,$head);
		$xls->getActiveSheet()->getRowDimension($r)->setRowHeight(25);
		
		$xls->getActiveSheet()->setCellValueByColumnAndRow(0,$r++,$rect);
		$xls->getActiveSheet()->getRowDimension($r)->setRowHeight(25);
		
		$xls->getActiveSheet()->setCellValueByColumnAndRow(0,$r++,$exmn);
		$xls->getActiveSheet()->getRowDimension($r)->setRowHeight(25);
		
		$r=$r+1;
		$offset=$r;
		$xls->getActiveSheet()->setCellValueByColumnAndRow(0,++$r, $meta['enm'])->mergeCellsByColumnAndRow(0,$r,$l-1,$r);		
		$xls->getActiveSheet()->setCellValueByColumnAndRow(0,++$r, $gd['dtn'])->mergeCellsByColumnAndRow(0,$r,$l-1,$r);		
		$xls->getActiveSheet()->setCellValueByColumnAndRow(0,++$r, "$meta[gnm] $gd[ryr]/$acy Academic Year")->mergeCellsByColumnAndRow(0,$r,$l-1,$r);		
		$xls->getActiveSheet()->setCellValueByColumnAndRow(0,++$r, "$gd[dpn] Department")->mergeCellsByColumnAndRow(0,$r,$l-1,$r);		
		$xls->getActiveSheet()->setCellValueByColumnAndRow(0,++$r, $gd['pnm'])->mergeCellsByColumnAndRow(0,$r,$l-1,$r);
		
		$xls->getActiveSheet()->getStyle("A$offset:A$r")->applyFromArray($headstyle);
		
		// Prepare sub header and Merge cells
		$r=$r+2; $c=3;
		if ($dur==6){
		$xls->getActiveSheet()
		->setCellValueByColumnAndRow(3,$r,"SEM 1")->mergeCellsByColumnAndRow(3,$r,5,$r)
		->setCellValueByColumnAndRow(6,$r,"SEM 2")->mergeCellsByColumnAndRow(6,$r,9,$r)
		->setCellValueByColumnAndRow(10,$r,"SEM 3")->mergeCellsByColumnAndRow(10,$r,13,$r)
		->setCellValueByColumnAndRow(14,$r,"SEM 4")->mergeCellsByColumnAndRow(14,$r,17,$r)
		->setCellValueByColumnAndRow(18,$r,"SEM 5")->mergeCellsByColumnAndRow(18,$r,21,$r)
		->setCellValueByColumnAndRow(22,$r,"SEM 6")->mergeCellsByColumnAndRow(22,$r,24,$r)
		->setCellValueByColumnAndRow(25,$r,"CUMULATIVE")->mergeCellsByColumnAndRow(25,$r,27,$r)
		->setCellValueByColumnAndRow(28,$r,"");
		}elseif ($dur==4){
		$xls->getActiveSheet()
		->setCellValueByColumnAndRow(3,$r,"SEM 1")->mergeCellsByColumnAndRow(3,$r,5,$r)
		->setCellValueByColumnAndRow(6,$r,"SEM 2")->mergeCellsByColumnAndRow(6,$r,9,$r)
		->setCellValueByColumnAndRow(10,$r,"SEM 3")->mergeCellsByColumnAndRow(10,$r,13,$r)
		->setCellValueByColumnAndRow(14,$r,"SEM 4")->mergeCellsByColumnAndRow(14,$r,16,$r)
		->setCellValueByColumnAndRow(17,$r,"CUMULATIVE")->mergeCellsByColumnAndRow(17,$r,19,$r)
		->setCellValueByColumnAndRow(20,$r,"");
		}elseif ($dur==3){
		$xls->getActiveSheet()
		->setCellValueByColumnAndRow(3,$r,"SEM 1")->mergeCellsByColumnAndRow(3,$r,5,$r)
		->setCellValueByColumnAndRow(6,$r,"SEM 2")->mergeCellsByColumnAndRow(6,$r,9,$r)
		->setCellValueByColumnAndRow(10,$r,"SEM 3")->mergeCellsByColumnAndRow(10,$r,12,$r)
		->setCellValueByColumnAndRow(13,$r,"CUMULATIVE")->mergeCellsByColumnAndRow(13,$r,15,$r)
		->setCellValueByColumnAndRow(16,$r,"");
		}else {
		$xls->getActiveSheet()
		->setCellValueByColumnAndRow(3,$r,"SEM 1")->mergeCellsByColumnAndRow(3,$r,5,$r)
		->setCellValueByColumnAndRow(6,$r,"SEM 2")->mergeCellsByColumnAndRow(6,$r,8,$r)
		->setCellValueByColumnAndRow(9,$r,"CUMULATIVE")->mergeCellsByColumnAndRow(9,$r,11,$r)
		->setCellValueByColumnAndRow(12,$r,"");
		}
		$xls->getActiveSheet()->getStyle("A$r:$last$r")->applyFromArray($subheadstyle);
		
		$r=$r+1;
		for ($c = 0; $c <=$l-1 ; $c++) {
			$xls->getActiveSheet()->setCellValueByColumnAndRow($c,$r,$h[$c]);
			$xls->getActiveSheet()->getStyleByColumnAndRow($c,$r)->applyFromArray($hstyle);
				
			}
			$r++;
		
		}elseif($sn==$cnt){

			$r=$r+2;
			$xls->getActiveSheet()->setCellValueByColumnAndRow(0,$r++,$head);
			$xls->getActiveSheet()->getRowDimension($r)->setRowHeight(25);
			
			$xls->getActiveSheet()->setCellValueByColumnAndRow(0,$r++,$rect);
			$xls->getActiveSheet()->getRowDimension($r)->setRowHeight(25);
			
			$xls->getActiveSheet()->setCellValueByColumnAndRow(0,$r++,$exmn);
			$xls->getActiveSheet()->getRowDimension($r)->setRowHeight(25);
		}
		}
		
		for($col = 1; $col < $l; $col++) {
			$xls->getActiveSheet()
			->getColumnDimensionByColumn($col)
			->setAutoSize(true);
		}	
		

		$writer = new PHPExcel_Writer_Excel2007($xls);		
		header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
		header ("Content-Disposition: attachment; filename=\"$fname.xlsx\"");
		header('Cache-Control: max-age=0');
		$writer->save('php://output');
		
		}catch(Exception $e){
			error_log($e->getMessage());
		}
	}

	public function CBTNabptexFormular($meta,$gd){
		try{
			$acy=$gd['ryr']+1;
			$cnt = $meta['ct'];
			$hdr  = $meta['hdr'];
			$fname = $meta['fn'];
			$dur =$meta['dur'];
	
			// Create new PHPExcel object
			$xls = $this->xls;
			$headstyle=array('alignment'    => array('horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER),'font'=>array('size'=>12,'bold'=>true));
			$subheadstyle=array('alignment' => array('horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER),'borders'=>array('allborders'=>array( 'style' => PHPExcel_Style_Border::BORDER_THIN)),'font'=>array('size'=>11,'bold'=>true));
			$bodystyle=array('borders'=>array('allborders'=>array( 'style' => PHPExcel_Style_Border::BORDER_THIN)),'font'=>array('size'=>7,));
			$bodyformula=array('borders'=>array('allborders'=>array( 'style' => PHPExcel_Style_Border::BORDER_THIN)),'fill'=>array('type' => PHPExcel_Style_Fill::FILL_SOLID,
					'color' => array('rgb' => 'cdedcd')),'font'=>array('size'=>7,));
				
			$bodynumeric=array('borders'=>array('allborders'=>array( 'style' => PHPExcel_Style_Border::BORDER_THIN)),'fill'=>array('type' => PHPExcel_Style_Fill::FILL_SOLID,
					'color' => array('rgb' => 'c0fdf5')),'font'=>array('size'=>7,));
				
			$bodyclass=array('borders'=>array('allborders'=>array( 'style' => PHPExcel_Style_Border::BORDER_THIN)),'fill'=>array('type' => PHPExcel_Style_Fill::FILL_SOLID,
					'color' => array('rgb' => 'f1e7b3')),'font'=>array('size'=>7,));
	
			$hstyle=array('borders'=>array('allborders'=>array( 'style' => PHPExcel_Style_Border::BORDER_THIN)),'font'=>array('size'=>7,'bold'=>true));
			$head="Head of Department: ………………………………………………………… Signature: ………………………………………………………… Date: …………………………………………………………";
			$rect="Rector/Vice Rector: ………………………………………………………… Signature: ………………………………………………………… Date: …………………………………………………………";
			$exmn="External Examiner : ………………………………………………………… Signature: ………………………………………………………… Date: …………………………………………………………";
	
			// Set document properties
			$xls->getProperties()->setCreator("Peter Amoako-Yirenkyi")
			->setLastModifiedBy("Peter Amoako-Yirenkyi")
			->setTitle($meta['rpt'])
			->setSubject("general Report")
			->setDescription("This is a report generated from the system")
			->setKeywords("report")
			->setCategory("Main reports");
	
	
			// Prepare header
			$xls->setActiveSheetIndex(0)
			->setCellValue('A1', $meta['enm'])->mergeCells("A1:AC1")
			->setCellValue('A2', $gd['dtn'])->mergeCells("A2:AC2")
			->setCellValue('A3', "$meta[gnm] $gd[ryr]/$acy Academic Year")->mergeCells("A3:AC3")
			->setCellValue('A4', "$gd[dpn] Department")->mergeCells("A4:AC4")
			->setCellValue('A5', $gd['pnm'])->mergeCells("A5:AC5");
			$xls->getActiveSheet()->getStyle('A1:A5')->applyFromArray($headstyle);
	
			// Get Last column
			$last=($dur==6?'AC': ($dur==4?'U':($dur==3?'Q':'M')));
	
			// Prepare sub header and Merge cells
			if($dur==6){
				$xls->getActiveSheet()
				->setCellValue('D7',"SEM 1")->mergeCells("D7:F7")
				->setCellValue('G7',"SEM 2")->mergeCells("G7:J7")
				->setCellValue('K7',"SEM 3")->mergeCells("K7:N7")
				->setCellValue('O7',"SEM 4")->mergeCells("O7:R7")
				->setCellValue('S7',"SEM 5")->mergeCells("S7:V7")
				->setCellValue('W7',"SEM 6")->mergeCells("W7:Y7")
				->setCellValue('Z7',"CUMULATIVE")->mergeCells("Z7:AB7")
				->setCellValue('AC7',"");
	
			}elseif ($dur==4){
				$xls->getActiveSheet()
				->setCellValue('D7',"SEM 1")->mergeCells("D7:F7")
				->setCellValue('G7',"SEM 2")->mergeCells("G7:J7")
				->setCellValue('K7',"SEM 3")->mergeCells("K7:N7")
				->setCellValue('O7',"SEM 4")->mergeCells("O7:Q7")
				->setCellValue('R7',"CUMULATIVE")->mergeCells("R7:T7")
				->setCellValue('U7',"");
	
			}elseif ($dur==3){
				$xls->getActiveSheet()
				->setCellValue('D7',"SEM 1")->mergeCells("D7:F7")
				->setCellValue('G7',"SEM 2")->mergeCells("G7:J7")
				->setCellValue('K7',"SEM 3")->mergeCells("K7:M7")
				->setCellValue('N7',"CUMULATIVE")->mergeCells("N7:P7")
				->setCellValue('Q7',"");
	
			}else{
				$xls->getActiveSheet()
				->setCellValue('D7',"SEM 1")->mergeCells("D7:F7")
				->setCellValue('G7',"SEM 2")->mergeCells("G7:I7")
				->setCellValue('J7',"CUMULATIVE")->mergeCells("J7:L7")
				->setCellValue('M7',"");
	
			}
	
			$xls->getActiveSheet()->getStyle('A7:'.$last.'7')->applyFromArray($subheadstyle);
	
			$h=array_values($hdr);
			$l=count($hdr);
			$offset=8;
			for ($c = 0; $c <=$l-1 ; $c++) {
				$xls->getActiveSheet()->setCellValueByColumnAndRow($c,$offset,$h[$c]);
				$xls->getActiveSheet()->getStyleByColumnAndRow($c,$offset)->applyFromArray($hstyle);
	
			}
	
			$r=$offset+1;
			$idx=0;$sn=0;
			$k=array_keys($hdr);
			$g=$last;
			foreach ($meta['sd'] as $rec){
				$rec['rid']=++$sn;
				$rec['ccr']='';
				$rec['cgp']='';
				$rec['cga']='';
				// Fill in the formulas
				if($dur==6){
					$rec['sg1']='=E'.$r.'/D'.$r;
					$rec['sg2']='=H'.$r.'/G'.$r;
					$rec['sg3']='=L'.$r.'/K'.$r;
					$rec['sg4']='=P'.$r.'/O'.$r;
					$rec['sg5']='=T'.$r.'/S'.$r;
					$rec['sg6']='=X'.$r.'/W'.$r;
	
					$rec['cgp']='=sum(E'.$r.',H'.$r.',L'.$r.',P'.$r.',T'.$r.',X'.$r.')';
					$rec['ccr']='=sum(D'.$r.',G'.$r.',K'.$r.',O'.$r.',S'.$r.',W'.$r.')';
					$rec['cga']='=AA'.$r.'/Z'.$r;
					$fmcell=array(5,8,12,16,20,24,25,26,27);
					$g='AB';
						
				}elseif($dur==4){
					$rec['sg1']='=E'.$r.'/D'.$r;
					$rec['sg2']='=H'.$r.'/G'.$r;
					$rec['sg3']='=L'.$r.'/K'.$r;
					$rec['sg4']='=P'.$r.'/O'.$r;
	
					$rec['cgp']='=sum(E'.$r.',H'.$r.',L'.$r.',P'.$r.')';
					$rec['ccr']='=sum(D'.$r.',G'.$r.',K'.$r.',O'.$r.')';
					$rec['cga']='=S'.$r.'/R'.$r;
					$g='T';
					$fmcell=array(5,8,12,16,17,18,19);
	
				}elseif ($dur==3){
					$rec['sg1']='=E'.$r.'/D'.$r;
					$rec['sg2']='=H'.$r.'/G'.$r;
					$rec['sg3']='=L'.$r.'/K'.$r;
	
					$rec['cgp']='=sum(E'.$r.',H'.$r.',L'.$r.')';
					$rec['ccr']='=sum(D'.$r.',G'.$r.',K'.$r.')';
					$rec['cga']='=O'.$r.'/N'.$r;
					$g='P';
					$fmcell=array(5,8,12,13,14,15);
						
				}else{
					$rec['sg1']='=E'.$r.'/D'.$r;
					$rec['sg2']='=H'.$r.'/G'.$r;
						
					$rec['cgp']='=sum(E'.$r.',H'.$r.')';
					$rec['ccr']='=sum(D'.$r.',G'.$r.')';
					$rec['cga']='=K'.$r.'/J'.$r;
					$g='L';
					$fmcell=array(5,8,9,10,11);
				}
// 				$cls='=IF('.$g.$r.'>=4,"FIRST CLASS",IF('.$g.$r.'>=3,"SECOND CLASS UPPER DIVISION",IF('.$g.$r.'>=2,"SECOND CLASS LOWER DIVISION",IF('.$g.$r.'>=1.5,"PASS","FAIL"))))';
// 				$rec['cls']=$rec['vct']==0?$cls:$rec['cls'];
	
				for ($c = 0; $c <= $l-1; $c++){
						
					if($c<3){
						$xls->getActiveSheet()->getStyleByColumnAndRow($c,$r)->applyFromArray($bodystyle);
						$xls->getActiveSheet()->setCellValueExplicitByColumnAndRow($c,$r,$rec[$k[$c]],PHPExcel_Cell_DataType::TYPE_STRING);
					}elseif($c==$l-1){
						$xls->getActiveSheet()->getStyleByColumnAndRow($c,$r)->applyFromArray($bodyclass);
// 						if($rec['vct']==0){
// 							$xls->getActiveSheet()->setCellValueExplicitByColumnAndRow($c,$r,$rec[$k[$c]],PHPExcel_Cell_DataType::TYPE_FORMULA);
// 						}else{
							$xls->getActiveSheet()->setCellValueExplicitByColumnAndRow($c,$r,$rec[$k[$c]],PHPExcel_Cell_DataType::TYPE_STRING);
// 						}
					}elseif (in_array($c,$fmcell,true)){
						$xls->getActiveSheet()->getStyleByColumnAndRow($c,$r)->applyFromArray($bodyformula);
						$xls->getActiveSheet()->setCellValueExplicitByColumnAndRow($c,$r,$rec[$k[$c]],PHPExcel_Cell_DataType::TYPE_FORMULA);
					}else{
						$xls->getActiveSheet()->getStyleByColumnAndRow($c,$r)->applyFromArray($bodynumeric);
						$xls->getActiveSheet()->setCellValueExplicitByColumnAndRow($c,$r,$rec[$k[$c]],PHPExcel_Cell_DataType::TYPE_NUMERIC);
	
					}
						
	
				}
				$r++;
				$idx++;
	
				if(($idx==11) && ($sn<$cnt)){
					$idx=0;
	
	
					$r=$r+2;
					$xls->getActiveSheet()->setCellValueByColumnAndRow(0,$r++,$head);
					$xls->getActiveSheet()->getRowDimension($r)->setRowHeight(25);
	
					$xls->getActiveSheet()->setCellValueByColumnAndRow(0,$r++,$rect);
					$xls->getActiveSheet()->getRowDimension($r)->setRowHeight(25);
	
					$xls->getActiveSheet()->setCellValueByColumnAndRow(0,$r++,$exmn);
					$xls->getActiveSheet()->getRowDimension($r)->setRowHeight(25);
	
					$r=$r+1;
					$offset=$r;
					$xls->getActiveSheet()->setCellValueByColumnAndRow(0,++$r, $meta['enm'])->mergeCellsByColumnAndRow(0,$r,$l-1,$r);
					$xls->getActiveSheet()->setCellValueByColumnAndRow(0,++$r, $gd['dtn'])->mergeCellsByColumnAndRow(0,$r,$l-1,$r);
					$xls->getActiveSheet()->setCellValueByColumnAndRow(0,++$r, "$meta[gnm] $gd[ryr]/$acy Academic Year")->mergeCellsByColumnAndRow(0,$r,$l-1,$r);
					$xls->getActiveSheet()->setCellValueByColumnAndRow(0,++$r, "$gd[dpn] Department")->mergeCellsByColumnAndRow(0,$r,$l-1,$r);
					$xls->getActiveSheet()->setCellValueByColumnAndRow(0,++$r, $gd['pnm'])->mergeCellsByColumnAndRow(0,$r,$l-1,$r);
	
					$xls->getActiveSheet()->getStyle("A$offset:A$r")->applyFromArray($headstyle);
	
					// Prepare sub header and Merge cells
					$r=$r+2; $c=3;
					if ($dur==6){
						$xls->getActiveSheet()
						->setCellValueByColumnAndRow(3,$r,"SEM 1")->mergeCellsByColumnAndRow(3,$r,5,$r)
						->setCellValueByColumnAndRow(6,$r,"SEM 2")->mergeCellsByColumnAndRow(6,$r,9,$r)
						->setCellValueByColumnAndRow(10,$r,"SEM 3")->mergeCellsByColumnAndRow(10,$r,13,$r)
						->setCellValueByColumnAndRow(14,$r,"SEM 4")->mergeCellsByColumnAndRow(14,$r,17,$r)
						->setCellValueByColumnAndRow(18,$r,"SEM 5")->mergeCellsByColumnAndRow(18,$r,21,$r)
						->setCellValueByColumnAndRow(22,$r,"SEM 6")->mergeCellsByColumnAndRow(22,$r,24,$r)
						->setCellValueByColumnAndRow(25,$r,"CUMULATIVE")->mergeCellsByColumnAndRow(25,$r,27,$r)
						->setCellValueByColumnAndRow(28,$r,"");
					}elseif ($dur==4){
						$xls->getActiveSheet()
						->setCellValueByColumnAndRow(3,$r,"SEM 1")->mergeCellsByColumnAndRow(3,$r,5,$r)
						->setCellValueByColumnAndRow(6,$r,"SEM 2")->mergeCellsByColumnAndRow(6,$r,9,$r)
						->setCellValueByColumnAndRow(10,$r,"SEM 3")->mergeCellsByColumnAndRow(10,$r,13,$r)
						->setCellValueByColumnAndRow(14,$r,"SEM 4")->mergeCellsByColumnAndRow(14,$r,16,$r)
						->setCellValueByColumnAndRow(17,$r,"CUMULATIVE")->mergeCellsByColumnAndRow(17,$r,19,$r)
						->setCellValueByColumnAndRow(20,$r,"");
					}elseif ($dur==3){
						$xls->getActiveSheet()
						->setCellValueByColumnAndRow(3,$r,"SEM 1")->mergeCellsByColumnAndRow(3,$r,5,$r)
						->setCellValueByColumnAndRow(6,$r,"SEM 2")->mergeCellsByColumnAndRow(6,$r,9,$r)
						->setCellValueByColumnAndRow(10,$r,"SEM 3")->mergeCellsByColumnAndRow(10,$r,12,$r)
						->setCellValueByColumnAndRow(13,$r,"CUMULATIVE")->mergeCellsByColumnAndRow(13,$r,15,$r)
						->setCellValueByColumnAndRow(16,$r,"");
					}else {
						$xls->getActiveSheet()
						->setCellValueByColumnAndRow(3,$r,"SEM 1")->mergeCellsByColumnAndRow(3,$r,5,$r)
						->setCellValueByColumnAndRow(6,$r,"SEM 2")->mergeCellsByColumnAndRow(6,$r,8,$r)
						->setCellValueByColumnAndRow(9,$r,"CUMULATIVE")->mergeCellsByColumnAndRow(9,$r,11,$r)
						->setCellValueByColumnAndRow(12,$r,"");
					}
					$xls->getActiveSheet()->getStyle("A$r:$last$r")->applyFromArray($subheadstyle);
	
					$r=$r+1;
					for ($c = 0; $c <=$l-1 ; $c++) {
						$xls->getActiveSheet()->setCellValueByColumnAndRow($c,$r,$h[$c]);
						$xls->getActiveSheet()->getStyleByColumnAndRow($c,$r)->applyFromArray($hstyle);
	
					}
					$r++;
	
				}elseif($sn==$cnt){
	
					$r=$r+2;
					$xls->getActiveSheet()->setCellValueByColumnAndRow(0,$r++,$head);
					$xls->getActiveSheet()->getRowDimension($r)->setRowHeight(25);
	
					$xls->getActiveSheet()->setCellValueByColumnAndRow(0,$r++,$rect);
					$xls->getActiveSheet()->getRowDimension($r)->setRowHeight(25);
	
					$xls->getActiveSheet()->setCellValueByColumnAndRow(0,$r++,$exmn);
					$xls->getActiveSheet()->getRowDimension($r)->setRowHeight(25);
				}
			}
	
			for($col = 1; $col < $l; $col++) {
				$xls->getActiveSheet()
				->getColumnDimensionByColumn($col)
				->setAutoSize(true);
			}
	
	
			$writer = new PHPExcel_Writer_Excel2007($xls);
			header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
			header ("Content-Disposition: attachment; filename=\"$fname.xlsx\"");
			header('Cache-Control: max-age=0');
			$writer->save('php://output');
	
		}catch(Exception $e){
			error_log($e->getMessage());
		}
	}
	public function EmptyNabptex($meta,$gd){
		try{
			$acy=$gd['ryr']+1;
			$cnt = $meta['ct'];
			$hdr  = $meta['hdr'];
			$fname = $meta['fn'];
			$dur =$meta['dur'];
	
			// Create new PHPExcel object
			$xls = $this->xls;
			$headstyle=array('alignment'    => array('horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER),'font'=>array('size'=>12,'bold'=>true));
			$subheadstyle=array('alignment' => array('horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER),'borders'=>array('allborders'=>array( 'style' => PHPExcel_Style_Border::BORDER_THIN)),'font'=>array('size'=>11,'bold'=>true));
			$bodystyle=array('borders'=>array('allborders'=>array( 'style' => PHPExcel_Style_Border::BORDER_THIN)),'font'=>array('size'=>7,));
			$bodyformula=array('borders'=>array('allborders'=>array( 'style' => PHPExcel_Style_Border::BORDER_THIN)),'fill'=>array('type' => PHPExcel_Style_Fill::FILL_SOLID,
            'color' => array('rgb' => 'cdedcd')),'font'=>array('size'=>7,));
			
			$bodynumeric=array('borders'=>array('allborders'=>array( 'style' => PHPExcel_Style_Border::BORDER_THIN)),'fill'=>array('type' => PHPExcel_Style_Fill::FILL_SOLID,
            'color' => array('rgb' => 'c0fdf5')),'font'=>array('size'=>7,));
			
			$bodyclass=array('borders'=>array('allborders'=>array( 'style' => PHPExcel_Style_Border::BORDER_THIN)),'fill'=>array('type' => PHPExcel_Style_Fill::FILL_SOLID,
					'color' => array('rgb' => 'f1e7b3')),'font'=>array('size'=>7,));
				
			$hstyle=array('borders'=>array('allborders'=>array( 'style' => PHPExcel_Style_Border::BORDER_THIN)),'font'=>array('size'=>7,'bold'=>true));
			$head="Head of Department: ………………………………………………………… Signature: ………………………………………………………… Date: …………………………………………………………";
			$rect="Rector/Vice Rector: ………………………………………………………… Signature: ………………………………………………………… Date: …………………………………………………………";
			$exmn="External Examiner : ………………………………………………………… Signature: ………………………………………………………… Date: …………………………………………………………";
	
			// Set document properties
			$xls->getProperties()->setCreator("Peter Amoako-Yirenkyi")
			->setLastModifiedBy("Peter Amoako-Yirenkyi")
			->setTitle($meta['rpt'])
			->setSubject("general Report")
			->setDescription("This is a report generated from the system")
			->setKeywords("report")
			->setCategory("Main reports");
	
	
			// Prepare header
			$xls->setActiveSheetIndex(0)
			->setCellValue('A1', $meta['enm'])->mergeCells("A1:AC1")
			->setCellValue('A2', $gd['dtn'])->mergeCells("A2:AC2")
			->setCellValue('A3', "$meta[gnm] $gd[ryr]/$acy Academic Year")->mergeCells("A3:AC3")
			->setCellValue('A4', "$gd[dpn] Department")->mergeCells("A4:AC4")
			->setCellValue('A5', $gd['pnm'])->mergeCells("A5:AC5");
			$xls->getActiveSheet()->getStyle('A1:A5')->applyFromArray($headstyle);
	
			// Get Last column
			$last=($dur==6?'AC': ($dur==4?'U':($dur==3?'Q':'M')));
	
			// Prepare sub header and Merge cells
			if($dur==6){
				$xls->getActiveSheet()
				->setCellValue('D7',"SEM 1")->mergeCells("D7:F7")
				->setCellValue('G7',"SEM 2")->mergeCells("G7:J7")
				->setCellValue('K7',"SEM 3")->mergeCells("K7:N7")
				->setCellValue('O7',"SEM 4")->mergeCells("O7:R7")
				->setCellValue('S7',"SEM 5")->mergeCells("S7:V7")
				->setCellValue('W7',"SEM 6")->mergeCells("W7:Y7")
				->setCellValue('Z7',"CUMULATIVE")->mergeCells("Z7:AB7")
				->setCellValue('AC7',"");
	
			}elseif ($dur==4){
				$xls->getActiveSheet()
				->setCellValue('D7',"SEM 1")->mergeCells("D7:F7")
				->setCellValue('G7',"SEM 2")->mergeCells("G7:J7")
				->setCellValue('K7',"SEM 3")->mergeCells("K7:N7")
				->setCellValue('O7',"SEM 4")->mergeCells("O7:Q7")
				->setCellValue('R7',"CUMULATIVE")->mergeCells("R7:T7")
				->setCellValue('U7',"");
	
			}elseif ($dur==3){
				$xls->getActiveSheet()
				->setCellValue('D7',"SEM 1")->mergeCells("D7:F7")
				->setCellValue('G7',"SEM 2")->mergeCells("G7:J7")
				->setCellValue('K7',"SEM 3")->mergeCells("K7:M7")
				->setCellValue('N7',"CUMULATIVE")->mergeCells("N7:P7")
				->setCellValue('Q7',"");
	
			}else{
				$xls->getActiveSheet()
				->setCellValue('D7',"SEM 1")->mergeCells("D7:F7")
				->setCellValue('G7',"SEM 2")->mergeCells("G7:I7")
				->setCellValue('J7',"CUMULATIVE")->mergeCells("J7:L7")
				->setCellValue('M7',"");
	
			}
				
			$xls->getActiveSheet()->getStyle('A7:'.$last.'7')->applyFromArray($subheadstyle);
	
			$h=array_values($hdr);
			$l=count($hdr);
			$offset=8;
			for ($c = 0; $c <=$l-1 ; $c++) {
				$xls->getActiveSheet()->setCellValueByColumnAndRow($c,$offset,$h[$c]);
				$xls->getActiveSheet()->getStyleByColumnAndRow($c,$offset)->applyFromArray($hstyle);
	
			}
				
			$r=$offset+1;
			$idx=0;$sn=0;
			$k=array_keys($hdr);
			$g=$last;
			foreach ($meta['sd'] as $rec){
				$rec['rid']=++$sn;
				$rec['ccr']='';
				$rec['cgp']='';
				$rec['cga']='';	
			// Fill in the formulas
				if($dur==6){
					$rec['sg1']='=E'.$r.'/D'.$r;
					$rec['sg2']='=H'.$r.'/G'.$r;
					$rec['sg3']='=L'.$r.'/K'.$r;
					$rec['sg4']='=P'.$r.'/O'.$r;
					$rec['sg5']='=T'.$r.'/S'.$r;
					$rec['sg6']='=X'.$r.'/W'.$r;
						
					$rec['cgp']='=sum(E'.$r.',H'.$r.',L'.$r.',P'.$r.',T'.$r.',X'.$r.')';
					$rec['ccr']='=sum(D'.$r.',G'.$r.',K'.$r.',O'.$r.',S'.$r.',W'.$r.')';
					$rec['cga']='=AA'.$r.'/Z'.$r;
					$fmcell=array(5,8,12,16,20,24,25,26,27);	
					$g='AB';
					
				}elseif($dur==4){
					$rec['sg1']='=E'.$r.'/D'.$r;
					$rec['sg2']='=H'.$r.'/G'.$r;
					$rec['sg3']='=L'.$r.'/K'.$r;
					$rec['sg4']='=P'.$r.'/O'.$r;

					$rec['cgp']='=sum(E'.$r.',H'.$r.',L'.$r.',P'.$r.')';
					$rec['ccr']='=sum(D'.$r.',G'.$r.',K'.$r.',O'.$r.')';
					$rec['cga']='=S'.$r.'/R'.$r;
					$g='T';
					$fmcell=array(5,8,12,16,17,18,19);
						
				}elseif ($dur==3){
					$rec['sg1']='=E'.$r.'/D'.$r;
					$rec['sg2']='=H'.$r.'/G'.$r;
					$rec['sg3']='=L'.$r.'/K'.$r;

					$rec['cgp']='=sum(E'.$r.',H'.$r.',L'.$r.')';
					$rec['ccr']='=sum(D'.$r.',G'.$r.',K'.$r.')';
					$rec['cga']='=O'.$r.'/N'.$r;
					$g='P';
					$fmcell=array(5,8,12,13,14,15);	
					
				}else{
					$rec['sg1']='=E'.$r.'/D'.$r;
					$rec['sg2']='=H'.$r.'/G'.$r;
					
					$rec['cgp']='=sum(E'.$r.',H'.$r.')';
					$rec['ccr']='=sum(D'.$r.',G'.$r.')';
					$rec['cga']='=K'.$r.'/J'.$r;
					$g='L';
					$fmcell=array(5,8,9,10,11);	
				}
				$cls='=IF('.$g.$r.'>=4,"FIRST CLASS",IF('.$g.$r.'>=3,"SECOND CLASS UPPER DIVISION",IF('.$g.$r.'>=2,"SECOND CLASS LOWER DIVISION",IF('.$g.$r.'>=1.5,"PASS","FAIL"))))';
				$rec['cls']=$rec['vct']==0?$cls:$rec['cls'];
				
				for ($c = 0; $c <= $l-1; $c++){
					
					if($c<3){
						$xls->getActiveSheet()->getStyleByColumnAndRow($c,$r)->applyFromArray($bodystyle);
						$xls->getActiveSheet()->setCellValueExplicitByColumnAndRow($c,$r,$rec[$k[$c]],PHPExcel_Cell_DataType::TYPE_STRING);
					}elseif($c==$l-1){
						$xls->getActiveSheet()->getStyleByColumnAndRow($c,$r)->applyFromArray($bodyclass);
						if($rec['vct']==0){
							$xls->getActiveSheet()->setCellValueExplicitByColumnAndRow($c,$r,$rec[$k[$c]],PHPExcel_Cell_DataType::TYPE_FORMULA);
						}else{
							$xls->getActiveSheet()->setCellValueExplicitByColumnAndRow($c,$r,$rec[$k[$c]],PHPExcel_Cell_DataType::TYPE_STRING);								
						}
					}elseif (in_array($c,$fmcell,true)){
						$xls->getActiveSheet()->getStyleByColumnAndRow($c,$r)->applyFromArray($bodyformula);
						$xls->getActiveSheet()->setCellValueExplicitByColumnAndRow($c,$r,$rec[$k[$c]],PHPExcel_Cell_DataType::TYPE_FORMULA);
					}else{ 
						$xls->getActiveSheet()->getStyleByColumnAndRow($c,$r)->applyFromArray($bodynumeric);
						$xls->getActiveSheet()->setCellValueExplicitByColumnAndRow($c,$r,$rec[$k[$c]],PHPExcel_Cell_DataType::TYPE_NUMERIC);
						
					}
					
	
				}
				$r++;
				$idx++;
	
				if(($idx==11) && ($sn<$cnt)){
					$idx=0;
	
	
					$r=$r+2;
					$xls->getActiveSheet()->setCellValueByColumnAndRow(0,$r++,$head);
					$xls->getActiveSheet()->getRowDimension($r)->setRowHeight(25);
	
					$xls->getActiveSheet()->setCellValueByColumnAndRow(0,$r++,$rect);
					$xls->getActiveSheet()->getRowDimension($r)->setRowHeight(25);
	
					$xls->getActiveSheet()->setCellValueByColumnAndRow(0,$r++,$exmn);
					$xls->getActiveSheet()->getRowDimension($r)->setRowHeight(25);
	
					$r=$r+1;
					$offset=$r;
					$xls->getActiveSheet()->setCellValueByColumnAndRow(0,++$r, $meta['enm'])->mergeCellsByColumnAndRow(0,$r,$l-1,$r);
					$xls->getActiveSheet()->setCellValueByColumnAndRow(0,++$r, $gd['dtn'])->mergeCellsByColumnAndRow(0,$r,$l-1,$r);
					$xls->getActiveSheet()->setCellValueByColumnAndRow(0,++$r, "$meta[gnm] $gd[ryr]/$acy Academic Year")->mergeCellsByColumnAndRow(0,$r,$l-1,$r);
					$xls->getActiveSheet()->setCellValueByColumnAndRow(0,++$r, "$gd[dpn] Department")->mergeCellsByColumnAndRow(0,$r,$l-1,$r);
					$xls->getActiveSheet()->setCellValueByColumnAndRow(0,++$r, $gd['pnm'])->mergeCellsByColumnAndRow(0,$r,$l-1,$r);
	
					$xls->getActiveSheet()->getStyle("A$offset:A$r")->applyFromArray($headstyle);
	
					// Prepare sub header and Merge cells
					$r=$r+2; $c=3;
					if ($dur==6){
						$xls->getActiveSheet()
						->setCellValueByColumnAndRow(3,$r,"SEM 1")->mergeCellsByColumnAndRow(3,$r,5,$r)
						->setCellValueByColumnAndRow(6,$r,"SEM 2")->mergeCellsByColumnAndRow(6,$r,9,$r)
						->setCellValueByColumnAndRow(10,$r,"SEM 3")->mergeCellsByColumnAndRow(10,$r,13,$r)
						->setCellValueByColumnAndRow(14,$r,"SEM 4")->mergeCellsByColumnAndRow(14,$r,17,$r)
						->setCellValueByColumnAndRow(18,$r,"SEM 5")->mergeCellsByColumnAndRow(18,$r,21,$r)
						->setCellValueByColumnAndRow(22,$r,"SEM 6")->mergeCellsByColumnAndRow(22,$r,24,$r)
						->setCellValueByColumnAndRow(25,$r,"CUMULATIVE")->mergeCellsByColumnAndRow(25,$r,27,$r)
						->setCellValueByColumnAndRow(28,$r,"");
					}elseif ($dur==4){
						$xls->getActiveSheet()
						->setCellValueByColumnAndRow(3,$r,"SEM 1")->mergeCellsByColumnAndRow(3,$r,5,$r)
						->setCellValueByColumnAndRow(6,$r,"SEM 2")->mergeCellsByColumnAndRow(6,$r,9,$r)
						->setCellValueByColumnAndRow(10,$r,"SEM 3")->mergeCellsByColumnAndRow(10,$r,13,$r)
						->setCellValueByColumnAndRow(14,$r,"SEM 4")->mergeCellsByColumnAndRow(14,$r,16,$r)
						->setCellValueByColumnAndRow(17,$r,"CUMULATIVE")->mergeCellsByColumnAndRow(17,$r,19,$r)
						->setCellValueByColumnAndRow(20,$r,"");
					}elseif ($dur==3){
						$xls->getActiveSheet()
						->setCellValueByColumnAndRow(3,$r,"SEM 1")->mergeCellsByColumnAndRow(3,$r,5,$r)
						->setCellValueByColumnAndRow(6,$r,"SEM 2")->mergeCellsByColumnAndRow(6,$r,9,$r)
						->setCellValueByColumnAndRow(10,$r,"SEM 3")->mergeCellsByColumnAndRow(10,$r,12,$r)
						->setCellValueByColumnAndRow(13,$r,"CUMULATIVE")->mergeCellsByColumnAndRow(13,$r,15,$r)
						->setCellValueByColumnAndRow(16,$r,"");
					}else {
						$xls->getActiveSheet()
						->setCellValueByColumnAndRow(3,$r,"SEM 1")->mergeCellsByColumnAndRow(3,$r,5,$r)
						->setCellValueByColumnAndRow(6,$r,"SEM 2")->mergeCellsByColumnAndRow(6,$r,8,$r)
						->setCellValueByColumnAndRow(9,$r,"CUMULATIVE")->mergeCellsByColumnAndRow(9,$r,11,$r)
						->setCellValueByColumnAndRow(12,$r,"");
					}
					$xls->getActiveSheet()->getStyle("A$r:$last$r")->applyFromArray($subheadstyle);
	
					$r=$r+1;
					for ($c = 0; $c <=$l-1 ; $c++) {
						$xls->getActiveSheet()->setCellValueByColumnAndRow($c,$r,$h[$c]);
						$xls->getActiveSheet()->getStyleByColumnAndRow($c,$r)->applyFromArray($hstyle);
	
					}
					$r++;
	
				}elseif($sn==$cnt){
	
					$r=$r+2;
					$xls->getActiveSheet()->setCellValueByColumnAndRow(0,$r++,$head);
					$xls->getActiveSheet()->getRowDimension($r)->setRowHeight(25);
						
					$xls->getActiveSheet()->setCellValueByColumnAndRow(0,$r++,$rect);
					$xls->getActiveSheet()->getRowDimension($r)->setRowHeight(25);
						
					$xls->getActiveSheet()->setCellValueByColumnAndRow(0,$r++,$exmn);
					$xls->getActiveSheet()->getRowDimension($r)->setRowHeight(25);
				}
			}
	
			for($col = 1; $col < $l; $col++) {
				$xls->getActiveSheet()
				->getColumnDimensionByColumn($col)
				->setAutoSize(true);
			}
	
	
			$writer = new PHPExcel_Writer_Excel2007($xls);
			header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
			header ("Content-Disposition: attachment; filename=\"$fname.xlsx\"");
			header('Cache-Control: max-age=0');
			$writer->save('php://output');
	
		}catch(Exception $e){
			error_log($e->getMessage());
		}
	}
	
}

?>
