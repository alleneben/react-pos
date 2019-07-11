<?php
class KPNotification extends KPBase{
    //constructor: prepare initializations here
    public function __construct(){
        parent::__construct(); 
        $p = '{"rid":"n","cid":"n","apc":"t","ami":"n","chi":"n","cmi":"n","ayr":"n","mdi":"n","sdt":"t","edt":"t","ssi":"n",'.
                 '"pmi":"n","pid":"n","pti":"n","dpi":"n","sno":"t","vty":"t","ixp":"t","sts":"n","stc":"t","ids":"t","stp":"t"}';
        $this->props = json_decode($p,true);
    }
    
    public function formatmobile($mobileno){
        $num = preg_replace('/^(0)(2|5)([0-9]+)$/','+233$2$3',$mobileno);
        error_log("formatmobile: in=$mobileno,out=$num");
        return $num;
    }
    
    public function sendsms($mobileno,$message){
        try{
            $recipient = $this->formatmobile($mobileno);
            //$message = $pd['msg'];
            $gw = new SMSGateway();
            $ret = $gw->send($recipient,$message);
            $msgi = $ret->getMessageId();
            error_log($msgi);
            return array('code'=>0,'mesg'=>$msgi); //json_encode(array('success'=>true,'st'=>'SMS Request','sm'=>'Operation Successful','sd'=>$ret,'msg'=>$msgi));
        } 
//         catch (Exception $e) {
// //             return $this->error->Interpret($ex);
//             return ErrorHandler::Interpret($e);
// //             return array('code'=>1,'mesg'=>$ex->getMessage());
//         }
//     }

        catch(Smsgh_ApiException $e){
        	//         	if($cnn)  $cnn->Close();
        	return ErrorHandler::InterpretSMSGW($e);
        }
        catch (Exception $e) {
        	//             return $this->error->Interpret($ex);
        	return ErrorHandler::Interpret($e);
        	//             return array('code'=>1,'mesg'=>$ex->getMessage());
        }
    }
		
    private function admissionMessage($let,$sch,$pro,$can){
        //TODO: Prepare message from these arrays
        $msg = "Congratulations $can[nam], You have been offered admission at Kumasi Technical University($pro[pnm]) with student No:$can[sno]. Your application code is $can[apc]. Visit https://kstu.edu.gh/admissions, check your status and generate your letter";
        return $msg;
    }	
    /**
     * Send Admission Notification to selected candidates
     * @param type $gd
     * @return boolean
     * @throws ErrorException
     */    
    public function Admission($pd){
        try{
            //report name
            //$gnm = "Admission Letters";
            $uda = $_SESSION['us'];
            $data = $let = $sch = $pro = array();

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

            $ayr = $hd['ADMISSION_YEAR'];
            $nyr = $ayr+1;
            $sch['acy'] = "$ayr/$nyr";
            $sch['rdt'] = $hd['ADMLET_REOPEN'];
            $sch['cnt'] = $hd['ADMLET_CONTACT'];
            $sch['pad'] = $hd['ADMLET_ADDRESS'];
            $sch['ref'] = $hd['ADMLET_REF'];
            $sch['tel'] = $hd['ADMLET_TEL'];
            $sch['fax'] = $hd['ADMLET_FAX'];
            $sch['bnk'] = $hd['ADMLET_BANKNAME'];
            $sch['acc'] = $hd['ADMLET_BANKACCOUNT'];

            $let['sal'] = $hd['ADMLET_SALUTATION'];
            $let['sgn'] = $hd['ADMLET_SIGNAME'];
            $let['sgt'] = $hd['ADMLET_SIGTITLE'];
            $let['ttl'] = $hd['ADMLET_TITLE'];
            $let['dte'] = date('jS F, Y');

            // deadline settings
            $wks=$hd['ADM_DEADLINE_WEEKS'];

            //Get List of Admitted Candidates
            $aco=new KPAdmission();
            $ard=$aco->PrintLetter($pd);
            if(isset($ard['failure'])) throw new ErrorException("Request Failed. $ard[em]",5);

            $arc = $ard['rc'];
            error_log("arc: ".print_r($arc,true));
            if(!($arc > 0))
                throw new ErrorException("No candidates found...empty results");
            $asd = $ard['sd'];

            // ---------------------------------------------------------


            //prepare sms for each admission
            //$kpn = new KPNotification();

            foreach($asd as $rec){
                $can = array();
                $pro['sdt'] = date('jS F, Y',strtotime($rec['sdt']));
                $pro['edt'] = date('jS F, Y',strtotime($rec['edt']));
                $pro['dln'] = date('jS F, Y',strtotime("+$wks week"));
                $pro['dpn'] = strtoupper($rec['dpn']);
                $pro['pnm'] = $rec['pnm'];
                $pro['ssn'] = $rec['ssn'];
                $pro['fee'] = $rec['fee'];
                $pro['cur'] = $rec['cur'];
                $pro['pid'] = $rec['pid'];
                $pro['pti'] = $rec['pti'];
                $can['nam'] = $rec['nam'];
                $can['sno'] = $rec['sno'];
                $can['tel'] = $rec['tel'];
                $can['pad'] = $rec['pad'];
                $can['apc'] = $rec['apc'];

                $msg = $this->admissionMessage($let,$sch,$pro,$can);
                $res = $this->sendsms($can['tel'], $msg);
//                 $res = $this->sendsms('0244661064', $msg);
//                 $res = $this->sendsms('0244603503', $msg);
                $can['sts'] = $res['code'];
                $can['msg'] = $res['mesg'];
                $data[] = $can;
            }

            return json_encode(array("success"=>"true",
				"st"=>"Admission Notification",
				"sm"=>"Notification Completed",
				"sd"=>$data));
        }
        catch(Exception $e){
            return ErrorHandler::Interpret($e);
        }
    }

}
