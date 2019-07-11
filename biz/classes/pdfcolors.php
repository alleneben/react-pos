<?php
class PDFColors {
    
    private $mode = 'hex';
    
    private $colorcodes = array(
         'red'=>array('rgb'=>array(255,0,0),'hex'=>'#FF0000')
        ,'green'=>array('rgb'=>array(0,255,0),'hex'=>'#00FF00')
        ,'blue'=>array('rgb'=>array(0,0,255),'hex'=>'#0000FF')
        ,'blue01'=>array('rgb'=>array(51,102,255),'hex'=>'#3366FF')
        ,'blue02'=>array('rgb'=>array(102,51,255),'hex'=>'#6633FF')
        ,'blue03'=>array('rgb'=>array(51,204,255),'hex'=>'#33CCFF')
        ,'blue04'=>array('rgb'=>array(0,61,245),'hex'=>'#003DF5')
        ,'blue05'=>array('rgb'=>array(0,46,184),'hex'=>'#002EB8')
        ,'violet01'=>array('rgb'=>array(204,51,255),'hex'=>'#CC33FF')
        ,'violet02'=>array('rgb'=>array(255,51,204),'hex'=>'#FF33CC')
        ,'pink01'=>array('rgb'=>array(255,51,102),'hex'=>'#FF3366')
        ,'orange01'=>array('rgb'=>array(255,102,51),'hex'=>'#FF6633')
        ,'yellow01'=>array('rgb'=>array(184,138,0),'hex'=>'#B88A00')
        ,'yellow02'=>array('rgb'=>array(245,184,0),'hex'=>'#F5B800')
        ,'yellow03'=>array('rgb'=>array(255,204,51),'hex'=>'#FFCC33')
        ,'yellow04'=>array('rgb'=>array(204,255,51),'hex'=>'#CCFF33')
        ,'green01'=>array('rgb'=>array(102,255,51),'hex'=>'#66FF33')
        ,'green02'=>array('rgb'=>array(51,255,102),'hex'=>'#33FF66')
        ,'green03'=>array('rgb'=>array(51,255,204),'hex'=>'#33FFCC')
    	,'black'=>array('rgb'=>array(0,0,0),'hex'=>'#000000')
    		
        //,''=>array('rgb'=>array(,,),''=>'#')
    );
    
    private $colorseq = array(
        'blue01','yellow01','violet02','blue02','green01','pink01','yellow02',
        'green02','blue03','violet01','yellow03','blue04','orange01','yellow04',
        'green03','blue05','black','red','green','blue'
    );
    
    public function __construct($mode='hex'){
        $this->mode = $mode;
    }
    
    public function gethex(){
        $colors = array();
        foreach($this->colorseq as $col){
            $colors[] = $this->colorcodes[$col]['hex'];
        }
        return $colors;
    }
    
    public function getrgb(){
        $colors = array();
        foreach($this->colorseq as $col){
            $colors[] = $this->colorcodes[$col]['rgb'];
        }
        return $colors;
    }
    
    public function getcolor($i,$m='hex'){
        return $this->colorcodes[$this->colorseq[$i]][$m];
    }
    
}