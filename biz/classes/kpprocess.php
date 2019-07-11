<?php
	class KPProcess extends KPBase{
		//constructor: prepare initializations here
		public function __construct(){
			parent::__construct(); 
			$p = '{"rid":"n","cid":"n","apc":"t","ami":"n","chi":"n","pmi":"n","pgp":"t","vty":"t"}';
			$this->props = json_decode($p,true);
			$this->debug = true;
		}
		
		/**===========BUILDING IN PHP ========================**/
        
        public function GetLimits($pd){
			try {
	            //format
				$fp = $this->props; 
				//required fields
				$rv = array('ami','chi'); 
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);			
				
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
				//query sql				
				$sql = "SELECT * FROM pr_limits_get(".
					$dd['chi'].",".
					$dd['ami'].",".
					$dd['pgp'].",".
					$this->userid.")";
				//query statement
				$stmt=$cnn->PrepareSP($sql);
				//query record
				$rc=$cnn->Execute($stmt);
				//query data :: array
				$sd=$rc->getarray();
				if(count($sd)<1) throw new ErrorException("No limits defined for this program mode",13,1);
				
				return json_encode(array("success"=>"true","sd"=>$sd[0]));
            }
            catch(ADODB_Exception $e){
                if($cnn)  $cnn->Close();
                return ErrorHandler::InterpretADODB($e);
            }
            catch(Exception $e){
                if($cnn)  $cnn->Close();
                return ErrorHandler::Interpret($e);
            }
        }
        
        public function GetRequired($pd){
			try {
	            //format
				$fp = $this->props; 
				//required fields
				$rv = array('ami','chi'); 
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);			
				
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
				//query sql				
				$sql = "SELECT * FROM pr_required_get(".
					$dd['chi'].",".
					$dd['ami'].",".
					$this->userid.")";
				//query statement
				$stmt=$cnn->PrepareSP($sql);
				//query record
				$rc=$cnn->Execute($stmt);
				//query data :: array
				$sd=$rc->getarray();
				$rc=count($sd);
				//if(count($sd)<1) throw new ErrorException("No thresholds defined for this program mode",13,1);
				
				return json_encode(array("success"=>"true","sd"=>$sd,"rc"=>$rc));
            }
            catch(ADODB_Exception $e){
                if($cnn)  $cnn->Close();
                return ErrorHandler::InterpretADODB($e);
            }
            catch(Exception $e){
                if($cnn)  $cnn->Close();
                return ErrorHandler::Interpret($e);
            }
        }
        
        public function GetGlobals($pd){
			try {
	            //format
				$fp = $this->props; 
				//required fields
				$rv = array('ami','chi'); 
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);			
				
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
				//query sql				
				$sql = "SELECT * FROM pr_globals_get($this->userid)";
				//query statement
				$stmt=$cnn->PrepareSP($sql);
				//query record
				$rc=$cnn->Execute($stmt);
				//query data :: array
				$sd=$rc->getarray();
				if(count($sd)<1) throw new ErrorException("No system globals found",13,1);
				
				return json_encode(array("success"=>"true","sd"=>$sd[0]));
            }
            catch(ADODB_Exception $e){
                if($cnn)  $cnn->Close();
                return ErrorHandler::InterpretADODB($e);
            }
            catch(Exception $e){
                if($cnn)  $cnn->Close();
                return ErrorHandler::Interpret($e);
            }
        }
        
        public function GetProgram($pd){
			try {
	            //format
				$fp = $this->props; 
				//required fields
				$rv = array('chi','pmi'); 
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);			
				
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
				//query sql				
				$qsq = "SELECT * FROM pr_program_get(".
					$dd['chi'].",".
					$dd['pmi'].",".
					$this->userid.")";
				//query statement
				$qst=$cnn->PrepareSP($qsq);
				//query record
				$qr=$cnn->Execute($qst);
				//query data :: array
				$qd=$qr->getarray();
				if(count($qd)<1) throw new ErrorException("No qualifying definition exist for this program mode",13,1);
				
				return json_encode(array("success"=>"true","sd"=>$qd[0]));
            }
            catch(ADODB_Exception $e){
                if($cnn)  $cnn->Close();
                return ErrorHandler::InterpretADODB($e);
            }
            catch(Exception $e){
                if($cnn)  $cnn->Close();
                return ErrorHandler::Interpret($e);
            }
        }
        
        public function GetSubjects($pd){
			try {
	            //format
				$fp = $this->props; 
				//required fields
				$rv = array('chi');
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);			
				//connect to db
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
				//create sql statement				
				$sql = "SELECT * FROM pr_subject_filter(".
					$dd['chi'].",".
					$this->userid.")";
				//prepare and execute sql statement (adodb)
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				if($cnn)  $cnn->Close();
				if(count($sd)<1) throw new ErrorException("No Subject record found for this program",13,1);
				$rec = array_shift($sd);
				return json_encode(array("success"=>"true","sd"=>$sd,"rc"=>$rec['rid']));
            }
            catch(ADODB_Exception $e){
                if($cnn)  $cnn->Close();
                return ErrorHandler::InterpretADODB($e);
            }
            catch(Exception $e){
                if($cnn)  $cnn->Close();
                return ErrorHandler::Interpret($e);
            }
        }
        
        public function GetExceptions($pd){
			try {
	            //format
				$fp = $this->props; 
				//required fields
				$rv = array('chi'); 
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);			
				
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
				//query sql				
				$qsq = "SELECT * FROM pr_exceptions_get(".
					$dd['chi'].",".
					$this->userid.")";
				//query statement
				$qst=$cnn->PrepareSP($qsq);
				//query record
				$qr=$cnn->Execute($qst);
				//query data :: array
				$qd=$qr->getarray();
				
				$qc=$qr->RecordCount(); //count($qd);
				//error_log($qc);
				return json_encode(array("success"=>"true","sd"=>$qd[0],"rc"=>$qc));
            }
            catch(ADODB_Exception $e){
                if($cnn)  $cnn->Close();
                return ErrorHandler::InterpretADODB($e);
            }
            catch(Exception $e){
                if($cnn)  $cnn->Close();
                return ErrorHandler::Interpret($e);
            }
        }
        
        public function GetCertificates($pd){
			try {
	            //format
				$fp = $this->props; 
				//required fields
				$rv = array('ami','chi','pmi'); 
				//call formating function
				$dd = $this->formatPost($fp,$pd,$rv);			
				
				$dbl=new DBLink();
				$cnn=$dbl->Connection();
				//SQL query to use
				/*
				$sql = "SELECT * FROM pr_getcerts($dd[ami],$dd[chi],$dd[pmi],$this->userid) as ". 
					   "sd(cid int8,nam varchar,apc varchar,adt date,amn varchar,".
					   "fcn varchar,scn varchar,ami int8,fci int8,sci int8,dob date,sex int,tel varchar,twn varchar,coy varchar,sji int8,".
					   "sjn varchar, sti int8, stn varchar, gdi int8,gdn varchar,xti int8,xtn varchar,ntv int4,eqv int4,".
					   "nrq int4,erq int4)";
				*/
				$sql = "SELECT * FROM pr_certificates_get(".
						"$dd[cid],".
						"$dd[apc],".
						"$dd[ami],".
						"$dd[chi],".
						"$dd[pmi],".
						"$this->userid)";
				error_log($sql);
				$stmt=$cnn->PrepareSP($sql);
				$rc=$cnn->Execute($stmt);
				$sd=$rc->getarray();
				$rec=$rc->RecordCount();
				if(count($sd)<1) throw new ErrorException("No valid certificates found",13,1);
				if($cnn)  $cnn->Close();
				return json_encode(array("success"=>"true","sd"=>$sd,"rc"=>$rec));
            }
            catch(ADODB_Exception $e){
                if($cnn)  $cnn->Close();
                return ErrorHandler::InterpretADODB($e);
            }
            catch(Exception $e){
                if($cnn)  $cnn->Close();
                return ErrorHandler::Interpret($e);
            }
        }
		
		public function Ranking($pd,$print=true){
			try {
	            //Use candidate's fci as chi if this is a protocol request
	            $chi = (isset($pd['mod']) && $pd['mod']=='prot')?$pd['fci']:$pd['chi'];
	            //'cid'=>$pd['cid'],
				$cd = array('cid'=>$pd['cid'],'ami'=>$pd['ami'],'chi'=>$chi,'pmi'=>$pd['pmi']);
	            //in equivalent or original mode ?
				$eqmode = ($pd['vty']=='eqv');
				
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
				/** institutional code  //TODO: get this from DB::systemdefault **/
				$ins = trim($hd['INST_CODE']);
				$cyr = date('y');
				$inc = "$ins$cyr"; //'0511';
				//Get Max Optional Cores TODO: get from DB
				$moc = $hd['ADM_MAXOPCORES']; 
				//default threshold
				$wassce_default = 8;
				$sssce_default = 5;
				$dth = $pd['ami'] == 1 ? 5 : 8;
				$dth = ($pd['ami'] == 12 && $eqmode) ? 5 : 8;
				//$dth = $eqmode? $hd['ADM_THREQUIV'] : $hd['ADM_THRORIG'];
				//initialize some local variables
				$totele = $totopc = $totcore = 0;
				$sjlegend = '';
				
	            /**Get All Candidate Certificates**/
				$ars=$this->GetCertificates($cd);
				$ard= json_decode($ars,true);
				if(!(isset($ard['success'])&&is_array($ard['sd']))){
					error_log('Error in KPProcess->GetCertificates');
					echo $ars; exit;
				}
				$arc = $ard['rc'];
				$asd = $ard['sd'];
				if($this->debug) error_log('DEBUG-1: Get Certificates... Complete');
				
				/** Get Thresholds for this request. We need to know how many of them **/
				$rqs=$this->GetRequired($pd);
				$rqd= json_decode($rqs,true);
				if(!(isset($rqd['success'])&&is_array($rqd['sd']))){
					error_log('Error in KPProcess->GetRequired'.$rqs);
					echo $rqs; exit;
				}
				
				$rsd=$rqd['sd'];
				$rhs=$this->GetHashed($rsd,'sji','stc');
				$topc = 0;
				//error_log("tvs::rsd::".print_r($rhs,true));
				//error_log("tvs::rhs::".print_r($rhs,true));
				foreach($rhs as $sn=>$sc){
					$topc+=($sc=='OPC')?1:0;
					//error_log("tvs::$sn--$sc,");
				}
				/** Get Limits for this request. */
				$lrs=$this->GetLimits($pd);
				$lrd= json_decode($lrs,true);
				if(!(isset($lrd['success'])&&is_array($lrd['sd']))){
					error_log('Error in KPProcess->GetLimits');
					echo $lrs; exit;
				}
				
				$lsd=$lrd['sd'];
				$tsu = $lsd['tsu'];
				//number of requirements per program
				$thc=$lsd['thc'];
				//required aggregate, cutoff and worst grade per program
				$agg = ($eqmode)?$lsd['eqv']:$lsd['agv'];
				$cut = ($eqmode)?$lsd['coe']:$lsd['cov']; 
				$max = ($eqmode)?$lsd['mxe']:$lsd['mxv'];
				//max(highest permissible) aggregate, i.e worst fail
				$mag = $tsu*$max;
				
				//Get Optional Cores [soc,int]
				$opc = array(); //array(4,6);
				//Get Total Optional Cores
				$toc = 0; //count($opc); 
				if($this->debug) error_log('DEBUG-2: Get Thresholds... Complete');
				
				/** Get Subjects and sort core and elective ones **/
				$sjs=$this->GetSubjects($pd);
				$sjd= json_decode($sjs,true);
				if(!(isset($sjd['success'])&&is_array($sjd['sd']))){
					echo $sjs; exit;
				}
				$sj = $sjd['sd'];
				error_log("this program has $sjd[rc] subjects");
				$slg = array();
				$sdata = array();
				foreach($sj as $sjr){
					if($sjr['stc']=='COR'){
						$sdata['core'][$sjr['rid']]=$sjr['shc'];
						$sdata['cores']++;
						
					}
					elseif($sjr['stc']=='OPC'){
						$sdata['core'][$sjr['rid']]=$sjr['shc']; //??
						$sdata['opc'][$sjr['rid']]=$sjr['shc'];
						$sdata['opcs']++;
						$opc[] = $sjr['rid'];
						$toc++;
					}
					elseif($sjr['stc']=='ELE'){
						$sdata['ele'][$sjr['rid']]=$sjr['shc'];
						$sdata['eles']++;
					}
					$sdata['shc'][$sjr['rid']]=$sjr['shc'];
					$subj[$sjr['rid']]=$sjr; //this is used
					$sjlegend .="$sjr[shc]:$sjr[nam], ";
					$slg[$sjr['shc']] = $sjr['nam']; //this is used
				}
				
				$tvs = $thc-$topc+$moc; 
				
				//============= Program Details ==============//
				//returns Program Details
				$prs=$this->GetProgram($pd);
				$prd= json_decode($prs,true);
				if(!(isset($prd['success'])&&is_array($prd['sd']))){
					error_log('Error in KPProcess->GetProgram');
					//return $this->PrintError('Error','Error Retrieving Program Details. Check the logs.');
					return ;
				}
				//$prc = $prd['rc'];
				$psd = $prd['sd'];
				$psc = $psd['psc'];
				
				/** Get Admitted  if cutoff is set or in protocol mode **/
				if((isset($pd['svc'])&&$pd['svc']=='cutoff') || (isset($pd['mod'])&&$pd['mod']=='prot')){
					$rnk = 0;
					$admitted = array();
					$ado= new KPAdmission();
					$ads=$ado->GetAdmitted(array('chi'=>$pd['chi']));
					$add= json_decode($ads,true);
					if((isset($add['success'])&&is_array($add['sd']))){
						$rnk = $add['rc'];
						$admitted = array_values($add['sd']);
						//error_log('Error 3');
						if($this->debug) error_log('DEBUG-3: Get Admitted... Success');
				
					}
					//TODO: Get Ranking offset for programs
					//offset ACC,MKT,SMS
					//$rnk = ($psc=='ACT')?max($rnk,468):$rnk;
					//$rnk = ($psc=='MKT')?max($rnk,332):$rnk;
					//if($this->debug) error_log('Stage3: Get Admitted... Complete');
				}
				
				//Retrieve and setup Data
				$vce = array();
				$vsu = array();
				foreach( $asd as $cer){
					$cid = $cer["cid"];		//candidate_id
					$sji = $cer["sji"];		//subject_id
					$gdn = $cer["gdn"];		//grade_name
					$ntv = $cer["ntv"];		//cert_native_value
					$eqv = $cer["eqv"];		//cert_equiv_value
					$nrq = $cer["nrq"];		//native_required(threshold)_default_0
					$erq = $cer["erq"];		//equiv_required(threshold)_default_0
					
					$val = $eqmode?$eqv:$ntv;
					$vrq = $eqmode?$erq:$nrq;
					//For a new candidate, initialize certs and subjects
					if(!array_key_exists($cid,$vce)){
						$ce = array('cid'=>$cer['cid'],'nam'=>$cer['nam'],'apc'=>$cer['apc'],'adt'=>$cer['adt'],'amn'=>$cer['amn'],
						   'nvs'=>0,'tot'=>0,'agv'=>$mag,'qst'=>0,'nrq'=>$cer['nrq'],'erq'=>$cer['erq'],'mks'=>'','opc'=>0,'rqs'=>0,'tth'=>$thc,
						   'xtn'=>$cer['xtn'],'tel'=>$cer['tel'],
						   'fcn'=>$cer['fcn'],'scn'=>$cer['scn'],'dob'=>$cer['dob'],'sex'=>$cer['sex'],'twn'=>$cer['twn'],'coy'=>$cer['coy']);
						$vce[$cid] = $ce;
						$vsu[$cid] = array();
					}
				
					//irq: isrequired (check in hashed thresholds - rhs)
					$irq = array_key_exists($sji,$rhs);
					//ioc: invalid optional core; MAX_OPC=$moc; 
					$ioc = (in_array($sji,$opc) && (!$irq || $vce[$cid]['opc'] >= $moc) );
						
				//	//ioc: invalid optional core; MAX_OPC=$moc; 
				//	$ioc = (in_array($sji,$opc) && $vce[$cid]['opc'] >= $moc);
				//	//irq: isrequired (check in hashed thresholds - rhs)
				//	$irq = array_key_exists($sji,$rhs);
					//is valid subject for this program (in filtered list)
					$isu = array_key_exists($sji,$subj);
					//ivq: valid required subjects
					$ivq = $irq && ($val <= $vrq) && $vrq > 0;
					//ivo: valid optional subjects. dth: default threshold
					$ivo = !$irq && ($val <= $dth) && ($dth > 0);
					//isv: is valid are subjects not more than default
					$isv = $ivq || $ivo;
					//if cand cert subject is in filtered list & has not already been processed & is not ioc & still cand_tot_subjects < ts
					if($isu && !array_key_exists($sji,$vsu[$cid]) && !$ioc && $vce[$cid]['tot'] < $tsu){
						//if subject is opc & candidate's opc < max_opc then add this opc to candidate's opc
						if(in_array($sji,$opc) && $vce[$cid]['opc']<$moc) $vce[$cid]['opc']++;
						//set candidate subject grade value : not used
						$vsu[$cid][$sji] = $gdn;
						//get subject shortcode
						$lab = $subj[$sji]['shc'];
						//append marks for candidate
						$vce[$cid]['mks'] .= "$lab=$gdn,"; 
						//count added subjects for candidate
						$vce[$cid]['tot']++; 
						//count fulfilled req for candidate if irq
						$vce[$cid]['rqs'] += $irq?1:0; 
						//reverse aggregation: deduct a fail and add actual mark
						$vce[$cid]['agv'] = $vce[$cid]['agv']-$max+$val;
						//nvs=thc-count(opc)+$vce[$cid]['opc']
						if($irq && $val <= $vrq && $vrq > 0){
							$vce[$cid]['nvs']++;
						}
						 
						// thc: total compulsory subjects (thresholds), i.e core + opc + compulsory_electives
						// nvs: no. of valid core subjects, nvs <
						// tot: total subjects 
						//calculate qst: 
						/**
						 *  QST=1 => tot=$tsu,nvs=$thc,opc=$moc,agv<=$agg :: naturally admitted
						 *  QST=2 => tot=$tsu,nvs=$thc,opc=$moc,agv>$agg  :: depends on cutoff (if cof>agg)
						 *  QST=3 => tot=$tsu,nvs=$thc,opc<$moc 		  :: not qualified. lacks optional core 
						 *  QST=4 => tot=$tsu,nvs<$thc  				  :: not qualified. does not satisfy required subjects
						 *  QST=5 => (tot<$tsu)							  :: not qualified. did not provide enough subjects
						 */
						//$tvs = $thc-$topc+$moc;
						if($vce[$cid]['tot']==$tsu && $vce[$cid]['nvs']==$tvs && $vce[$cid]['opc'] == $moc && $vce[$cid]['agv'] <= $agg) $vce[$cid]['qst']=1;
						else if($vce[$cid]['tot']==$tsu && $vce[$cid]['nvs']==$tvs && $vce[$cid]['opc'] == $moc && $vce[$cid]['agv'] > $agg) $vce[$cid]['qst']=2;
						else if($vce[$cid]['tot']==$tsu && $vce[$cid]['nvs']==$tvs && $vce[$cid]['opc'] < $moc) $vce[$cid]['qst']=3;
						else if($vce[$cid]['tot']==$tsu && $vce[$cid]['nvs']<$tvs) $vce[$cid]['qst']=4;
						else $vce[$cid]['qst']=5;
						
					}
					
				} 
					
				/** 
				=================Ranking Starts here===================
				sort by sub array key. pick key from desired subarray field
				1st rank: all subj submitted, 
				2nd rank: core requirements met, 
				3rd rank: aggregate below base-offset-for-each-rank=F*ts => all subjects failed (worst case)
				cos: core_subjects offset, 
				ios: initial offset, 0 for those with all tsu
				sk:
				**/
				foreach($vce as $k=>$v) {
					//$cos=$max*$tsu*($thc-$v['nvs']);
					$cos=$mag*($thc-$v['nvs']);
					//$ios=$max*$tsu*($tsu-min($tsu,$v['tot']));
					$ios=$mag*($tsu-min($tsu,$v['tot']));
					$sk = $ios+$v['agv'];
					//$sk = $cos+$ios+$v['agv'];
					$b[$k] = $sk;
				}
				asort($b);
				//reorder vce according to sorted b
				if($this->debug) error_log('DEBUG-4: Ordering '.count($b).' records per Algorithm..');				
				$c = array();
				//error_log(count($admitted).' admitted');
				foreach($b as $key=>$val) {
					
					//is it ranking or admission ? 
					if(isset($pd['svc']) && $pd['svc']=='cutoff'){
						//if($this->debug) error_log('Stage3: Add to Admission');
						if(!in_array($vce[$key]['cid'],$admitted) && $vce[$key]['agv'] <= $cut && $vce[$key]['qst']<3){
							error_log("not admitted yet");
							$rnk++;
							$rank = str_pad($rnk,4,'0',STR_PAD_LEFT);
							$vce[$key]['ixn'] = "$psc$inc$rank";
							//$vce[$key]['id'] = "\\N";
							$c[] = $vce[$key];
						}
					}
					elseif(isset($pd['mod']) && $pd['mod']=='prot'){
						//if not already in admitted list, then create indexno from rank_index
						if(!in_array($vce[$key]['cid'],$admitted) && $vce[$key]['qst']<3){
							$rnk++;
							$rank = str_pad($rnk,4,'0',STR_PAD_LEFT);
							$vce[$key]['ixn'] = "$psc$inc$rank";
							//$vce[$key]['id'] = "\\N";
							$c[] = $vce[$key];
							//error_log('Error 7');
						}
					}
					else
						$c[] = $vce[$key];
					//error_log("admitted ".count($c)." candidates");
				}
				
				$vcd = $c;
				$rc = count($vcd);
				//=================Column Headers here ===================
				$dh = array('apc'=>'Application Code','adt'=>'Application Date','amn'=>'Apprication Mode',
								'nam'=>'Fullname','dob'=>'Date of Birth','sex'=>'Gender','twn'=>'Home Town','coy'=>'Country',
								'fcn'=>'First Choice','scn'=>'Second Choice','qst'=>'Qualification Status',
								'nvs'=>'Valid Subjects','tot'=>'Total Subjects','agv'=>'Aggregate',
								'xtn'=>'Exam Type',
								'nrq'=>'Original Pass Mark','erq'=>'Equivalent Pass Mark','mks'=>'Marks'
								);
				if($print)
					return json_encode(array("success"=>"true","sd"=>$vcd,"rc"=>$rc,"dh"=>$dh,"vs"=>$vsu,"lm"=>$lsd,"sl"=>$slg));
				else
					return json_encode(array("success"=>"true","sd"=>$vcd,"rc"=>$rc));
			}
            catch(ADODB_Exception $e){
                if($cnn)  $cnn->Close();
                return ErrorHandler::InterpretADODB($e);
            }
            catch(Exception $e){
                if($cnn)  $cnn->Close();
                return ErrorHandler::Interpret($e);
            }
        }
		
		public function Admission($pd,$print=true){
			try {
				$ars=$this->Ranking($pd);
				$ard= json_decode($ars,true);
				if(!(isset($ard['success'])&&is_array($ard['sd']))){
					return ars;
				}
				$sjd= json_decode($sjs,true);
				if(!(isset($sjd['success'])&&is_array($sjd['sd']))){
					echo $sjs; exit;
				}
				
				
				$arc = $ard['rc'];
				$vcd = $ard['sd'];
				//$vsu = $ard['vs'];
				//$lms = $ard['lm'];
				//$hdr = $ard['dh'];
				//$slg = $ard['sl'];
				
				$ipr = (isset($pd['mod'])&&$pd['mod']=='prot') || false;
				$mdi = $ipr?3:$pd['pmi'];
				
				//store a copy of trimmed data in DB.
				$adm = array();
				$sts = 1;
				$stp = date('Y-m-d H:i:s');
				foreach ($vcd as $rec){
					$adm[] = "$rec[cid]|$rec[ixn]|$gd[chi]|$rec[mks]|$rec[agv]|$mdi|$sts|$stp";
				}
				$dbl=new DBLink();
				$cnn=$dbl->Connection(true);
				if(!pg_copy_from($cnn, 'tb_admission', $adm, '|')){
	   				$errmsg = pg_last_error($cnn);
	   				error_log($errmsg);
	   				if($cnn) pg_close($cnn);
	   				//throw new ErrorException("DB Error ::$errmsg",1,1);
	   			}
	   			if($cnn) pg_close($cnn);
				
				//$vcd = $c;
				//$rc = count($vcd);
				//=================Column Headers here ===================
				$dh = array('apc'=>'Application Code','adt'=>'Application Date','amn'=>'Apprication Mode',
								'nam'=>'Fullname','dob'=>'Date of Birth','sex'=>'Gender','twn'=>'Home Town','coy'=>'Country',
								'fcn'=>'First Choice','scn'=>'Second Choice','qst'=>'Qualification Status',
								'nvs'=>'Valid Subjects','tot'=>'Total Subjects','agv'=>'Aggregate',
								'xtn'=>'Exam Type',
								'nrq'=>'Original Pass Mark','erq'=>'Equivalent Pass Mark','mks'=>'Marks'
								);
				//if($print) $ard['success'] = 'true';
				if($print)
					return ars;
				else
					return json_encode(array("success"=>"true","sd"=>$vcd,"rc"=>$arc));
			}
            catch(ADODB_Exception $e){
                if($cnn)  $cnn->Close();
                return ErrorHandler::InterpretADODB($e);
            }
            catch(Exception $e){
                if($cnn)  $cnn->Close();
                return ErrorHandler::Interpret($e);
            }
        }
		
		
    }
?>
