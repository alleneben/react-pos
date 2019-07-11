<?php
include_once('config.php');
include_once('lib/smsgh/Api.php');

class SMSGateway{
    private $api;
    private $error;
    //constructor: prepare initializations here
    public function __construct(){
        $this->api = new SmsghApi();
        $this->api->setClientId(CONFIG_SMSCLIENTID);
        $this->api->setClientSecret(CONFIG_SMSCLIENTSECRET);
        $this->api->setContextPath(CONFIG_SMSCONTEXTPATH);
        $this->api->setHttps(CONFIG_SMSHTTPSMODE);
        $this->api->setHostname(CONFIG_SMSHOSTNAME);
        
        $this->error = new ErrorHandler();
    }
    
    private function preparemessage($recipient,$message,$sender=CONFIG_SMSSENDER,$register=CONFIG_SMSREGISTER){
        $apiMessage = new ApiMessage();
        $apiMessage->setFrom($sender);
        $apiMessage->setTo($recipient);
        $apiMessage->setContent($message);
        $apiMessage->setRegisteredDelivery($register);
        return $apiMessage;
    }
    
    public function send($recipient,$message){
        try{
            $apimessage = $this->preparemessage($recipient,$message);
            error_log("from: ".$apimessage->getFrom());
            $response = $this->api->getMessages()->send($apimessage);
            $cref = $response->getClientReference();
            $rdet = $response->getDetail();
            $msgi = $response->getMessageId();
            $neti = $response->getNetworkId();
            $rate = $response->getRate();
            $stat = $response->getStatus();
            error_log("ref: $cref, rdet: $rdet, msgi:$msgi,neti:$neti,rate:$rate,stat:$stat");
            return $response;
        }
        catch(Smsgh_ApiException $e){
        	//         	if($cnn)  $cnn->Close();
        	return ErrorHandler::InterpretSMSGW($e);
        }
        catch(Exception $ee){
        	return ErrorHandler::Interpret($ee);
        
        }
    }
}
//