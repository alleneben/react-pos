<?php
class PGArray{
	private $array;
	
	private function open(){
        $this->array =  "'{";
    }
        
    private function close(){
    	return rtrim($this->array,',')."}'";
    }
        
    public function __construct(){
		//$this->array = "'{";
		$this->open();
	}
	
	public function push($item){
    	$this->array .= $item.",";
    }
    
    public function pop($item){
    	$pat = '/.*('.$item.'),?$/';
    	return preg_replace($pat,"",$this->array,1);
    }
    
    public function delete($item){
    	$pat = '/('.$item.'),?/';
    	return preg_replace($pat,"",$this->array,1);
    }
    
    public function deletex($item){
    	$pat = '/('.$item.'),?$/';
    	return preg_replace($pat,"",$this->array);
    }
    
    public function get(){
		return $this->close();
	}
	    
}

?>