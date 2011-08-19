#!/usr/bin/env php
<?php

$file = file_get_contents('icon.c');

preg_match('/Uint8 Icon\[\]\s*=\s*{(.*)};/', $file, $matches);
$pixels = explode(',', $matches[1]);

$w = $h = sqrt(count($pixels));

$im = imagecreate($w, $h);

preg_match('/SDL_Color IconPalette\[\d+\]\s*=\s*{{(.*)}};/', $file, $matches);
$colorvalues = explode('},{', $matches[1]);
$colors = array();
foreach ($colorvalues as $i => $colorvalue) {
    $colorvalue = explode(',', $colorvalue);
    $colors[$i] = imagecolorallocatealpha($im, $colorvalue[0], $colorvalue[1], $colorvalue[2], $colorvalue[3]);
    if ($colors[$i] === false) echo "failed to allocate color $i\n";
}

$x = $y = 0;
foreach ($pixels as $i => $pixel) {
    $result = imagesetpixel($im, $x, $y, $colors[$pixel]);
    if ($result === false) echo "failed to set pixel at $x,$y\n";
    $x++;
    if ($x >= $w) {
        $x = 0;
        $y++;
    }
}

imagecolortransparent($im, $colors[$pixels[0]]);

imagepng($im, 'icon.png');

imagedestroy($im);

?>
