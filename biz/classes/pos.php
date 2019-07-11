<?php
/* Change to the correct path if you copy this example! */
require __DIR__ . '/escpos/autoload.php';
require __DIR__ . '/receipt.php';
use Mike42\Escpos\Printer;
use Mike42\Escpos\EscposImage;
use Mike42\Escpos\PrintConnectors\FilePrintConnector;

/**
 * On Linux, use the usblp module to make your printer available as a device
 * file. This is generally the default behaviour if you don't install any
 * vendor drivers.
 *
 * Once this is done, use a FilePrintConnector to open the device.
 *
 * Troubleshooting: On Debian, you must be in the lp group to access this file.
 * dmesg to see what happens when you plug in your printer to make sure no
 * other drivers are unloading the module.
 */

try {
    // Enter the device file for your USB printer here
    $connector = new FilePrintConnector("/dev/usb/lp1");
    //$connector = new FilePrintConnector("php://stdout");
    //$connector = new FilePrintConnector("/dev/usb/lp1");
    //$connector = new FilePrintConnector("/dev/usb/lp2");

    $hey = new Receipt();
    $why = $hey -> PrintReciept();

    $why= json_decode($why,true);

    $it = new item();
    /* Date is kept the same for testing */
    // $date = date('l jS \of F Y h:i:s A');
    $date = "Monday 6th of April 2015 02:56:25 PM";
    /* Print a "Hello world" receipt" */
    $printer = new Printer($connector);

    $printer -> selectPrintMode(Printer::MODE_DOUBLE_WIDTH);
    $printer -> text("ExampleMart Ltd.\n");
    $printer -> selectPrintMode();
    $printer -> text("Shop No. 42.\n");
    $printer -> feed();

    $printer -> setEmphasis(true);
    $printer -> text("SALES INVOICE\n");
    $printer -> setEmphasis(false);

    /* Items */
    $printer -> setJustification(Printer::JUSTIFY_LEFT);
    $printer -> setEmphasis(true);
    //$printer -> text(new item('', '$'));
    $printer -> setEmphasis(false);
    foreach ($why['sd'] as $dd) {
        $itt = $it->toString($dd);
        $printer -> text($itt);
    }
    $printer -> setEmphasis(true);
    $printer -> text($subtotal);
    $printer -> setEmphasis(false);
    $printer -> feed();

    /* Tax and total */
    $printer -> text($tax);
    $printer -> selectPrintMode(Printer::MODE_DOUBLE_WIDTH);
    $printer -> text($total);
    $printer -> selectPrintMode();

    /* Footer */
    $printer -> feed(2);
    $printer -> setJustification(Printer::JUSTIFY_CENTER);
    $printer -> text("Thank you for shopping at ExampleMart\n");
    $printer -> text("For trading hours, please visit example.com\n");
    $printer -> feed(2);
    $printer -> text($date . "\n");
    //$printer -> text("          OSEWUS VENTURES \n");
    //$printer -> text(" Tel:0277686939/0209343536 \n Location: Adum/Kejetia \n");
    //$printer -> text("Item              Qty     Price    Amt\n"); 
    //foreach($why['sd'] as $dd){
      //  $printer -> text($dd['pnm'] ."     ".$dd['nqy'] . "           " .   $dd['amt'] . "          " .    $dd['pmt']."\n"); 
        //error_log(print_r($why,true));
    //}
      
    $printer -> cut();
    $printer -> pulse();

    /* Close printer */
    $printer -> close();
} catch (Exception $e) {
    echo "Couldn't print to this printer: " . $e -> getMessage() . "\n";
}

class item
{
   
    
    public function toString($pd)
    {
        $rightCols = 5;
        $leftCols = 20;
        $rCols = 5;
       //if ($this -> dollarSign) {
         //  $leftCols = $leftCols / 2 - $rightCols / 2;
        //}
        $left = str_pad($pd['pnm'], $leftCols) ;
        $nqy = str_pad($pd['nqy'], $rightCols) ;
        $pmt = str_pad($pd['pmt'], $rightCols) ;
        //$sign = ($this -> dollarSign ? '$ ' : '');
        $right = str_pad($pd['amt'], $rCols, ' ', STR_PAD_LEFT);
        return "$left$nqy$pmt$right\n";
    }

}



