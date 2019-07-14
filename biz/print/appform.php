<?php
$sd = $_SESSION['print'];

$c = $sd['cand'];
$cnm = $c['fnm'].' '.$sc['fnm'].' '.$c['snm'];
$sex = ($c['sex'] == 1)?'Male':'Female';
$apdate=new DateTime($c['adt']);
//error_log("PRINTC:: ".print_r($sd['cert'],true));
$photo = file_exists(realpath("../../photos/".$c['pho']))?"../../photos/$c[pho]":"../../photos/sample.png";
error_log("photo is:".$photo);
error_log("db photo is:$c[pho] which is".realpath("../../photos/".$c['pho']));
?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
		<title>Application Form</title>
		<link rel="STYLESHEET" href="reports.css" type="text/css" />
	</head>
	<body>
		<div id="body">
		<div id="section_header"></div>
		<div id="content">
		<div class="page" style="font-size: 7pt">
		<table>
			<tr><td><img class="imagehead" src="kpappflogo.jpg"></td>
				<td class="pageheader"><br>Kumasi Technical University<br>
				 <br>Student Application form<br><?php echo $apdate->format('Y'); ?> Academic Year<br>
				</td>
				<td><img class="imagehead" src="../../photos/sample.png"></td>
			</tr>
		</table>
		<table class="change_order_items">
			<!--caption align="top"><b><h2>Demographic Data</h2></b></caption -->
			<tr>
				<td class="chd">Full Name:</td><td><?=$cnm?></td>
				<td class="chd">Country:</td><td><?php echo $c['coy']?></td>
			</tr>
			<tr>
				<td class="chd">mode of Application:</td><td><?=$c['amn']?></td>
				<td class="chd">Date of Birth:</td><td><?=$c['dob']?></td>
			</tr>
			<tr>
				<td class="chd">First Choice:</td><td><?=$c['fcn']?></td>
				<td class="chd">Gender:</td><td><?=$sex?></td>
			</tr>
			<tr>
				<td class="chd">Second Choice:</td><td><?=$c['scn']?></td>
				<td class="chd">Home Town:</td><td><?=$c['twn']?></td>
			</tr>
			<tr>
				<td class="chd">Telephone</td><td><?=$c['tel']?></td>
				<td class="chd">Address</td><td><?=$c['pad']?></td>
			</tr>
		</table>
		<div id="section_header">Previous Education</div>
		<table class="change_order_items">
			<tr><th class="stmt">Institution/College</th><th class="stmt">Date of attendance</th><th class="stmt">Office Held</th></tr>
			<?php
			$educ = $sd['educ'];
			if(count($educ)==0)
				echo "<tr><td class='stmttext'>N/A</td><td class='stmttext'>N/A</td><td class='stmttext'>N/A</td></tr>";
			else
			foreach($educ as $edu)
				echo "<tr><td class='stmttext'>$edu[nam]</td><td class='stmttext'>$edu[sdt] <b>to</b> $edu[edt]</td><td class='stmttext'>$edu[ohd]</td></tr>";

			?>
		</table>
		<div id="section_header">Details of Relevant Certificates Obtained</div>
		<table class="change_order_items">
			<tr><th class="stmt">Type of Examination</th><th class="stmt">Subject</th><th class="stmt">Grade</th><th class="stmt">Date</th><th class="stmt">Index No.</th></tr>
			<?php
			$cert = $sd['cert'];
			if(count($cert)==0)
				echo "<tr><td class='stmttext'>N/A</td><td class='stmttext'>N/A</td><td class='stmttext'>N/A</td><td class='stmttext'>N/A</td><td class='stmttext'>N/A</td></tr>";
			else
			foreach($sd['cert'] as $cer)
				echo "<tr><td class='stmttext'>$cer[xtn]</td><td class='stmttext'>$cer[sjn]</td><td class='stmttext'>$cer[gdn]</td><td class='stmttext'>$cer[cdt]</td><td class='stmttext'>$cer[ixn]</td></tr>";

			?>
		</table>
		<div id="section_header">Details of Employment Experience</div>
		<table class="change_order_items">
			<tr><th class="stmt">Employer</th><th class="stmt">Address</th><th class="stmt">Start Date</th><th class="stmt">End Date</th><th class="stmt">Position</th></tr>
			<?php
			$empl = $sd['empl'];
			if(count($empl)==0)
				echo "<tr><td class='stmttext'>N/A</td><td class='stmttext'>N/A</td><td class='stmttext'>N/A</td><td class='stmttext'>N/A</td><td class='stmttext'>N/A</td></tr>";
			else
			foreach($empl as $emp)
				echo "<tr><td class='stmttext'>$emp[emn]</td><td class='stmttext'>$emp[ema]</td><td class='stmttext'>$emp[sdt]</td><td class='stmttext'>$emp[edt]</td><td class='stmttext'>$edu[phd]</td></tr>";

			?>
		</table>
		</div>

		</div>
		</div>

<script type="text/php">

if ( isset($pdf) ) {
  $sd = $_SESSION['print'];
  $c = $sd['cand'];
  $font = Font_Metrics::get_font("verdana");;
  $size = 16;
  $color = array(0,0,0);
  $text_height = Font_Metrics::get_font_height($font, $size);

  $foot = $pdf->open_object();

  $w = $pdf->get_width();
  $h = $pdf->get_height();

  // Draw a line along the bottom
  $y = $h - 2 * $text_height - 24;
  $pdf->line(16, $y, $w - 16, $y, $color, 1);

  $y += $text_height;
  $text = "Ref: ".$c['tel'];
  $pdf->text(16, $y, $text, $font, $size, $color);

  $pdf->close_object();
  $pdf->add_object($foot, "all");

  global $initials;
  $initials = $pdf->open_object();

  // Add an initals box
  $text = "Code:";
  $btext = $c['apc'];
  $bwidth = Font_Metrics::get_text_width($btext, $font, $size);
  $width = Font_Metrics::get_text_width($text, $font, $size);
  $pdf->text($w - 16 - $width - $bwidth-2, $y, $text, $font, $size, $color);
  $pdf->rectangle($w - 16 - $bwidth-1, $y - 2, $bwidth+1, $text_height + 4, array(0.5,0.5,0.5), 0.5);
  $pdf->text($w - 16 - $bwidth, $y, $btext, $font, $size, $color);

  $pdf->close_object();
  $pdf->add_object($initials);

  // Mark the document as a duplicate
  $pdf->text(110, $h - 450, "", Font_Metrics::get_font("verdana", "bold"),
             110, array(0.85, 0.85, 0.85), 0, -32);

  // Watermark the document header
  //$pdf->text(210, 30, "KSTU ADMISSION SYSTEM", Font_Metrics::get_font("verdana", "bold"),
  //           10, array(0.85, 0.85, 0.85), 0, 0);

  $text = "Page {PAGE_NUM} of {PAGE_COUNT}";

  // Center the text
  $width = Font_Metrics::get_text_width("Page 1 of 2", $font, $size);
  $pdf->page_text($w / 2 - $width / 2, $y, $text, $font, $size, $color);

}
</script>
	</body>
</html>
