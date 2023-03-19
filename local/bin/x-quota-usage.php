#!/usr/bin/env php
<?php
error_reporting(E_ALL);

$debug = false;

$quota = '';
$output = [];
$fsCharLenght = 0;

if ($debug) {
    $quota = "Disk quotas for user viir (uid 2913):
         Filesystem  blocks   quota   limit   grace   files   quota   limit   grace
    10.0.0.89:/www/webroots/2 8277615  52428800 52428800               0       0       0
    10.0.0.179:/users1/users/2 1999431  52428800 52428800               0       0       0
    10.0.0.90:/siilo/2 24835106  524288000 524288000               0       0       0";
} else {
    // $quota = system("quota -w");
    $quota = shell_exec("quota -w");
}

function pad($i, $n = 3, $p = ' ') {
    return str_pad($i, $n, $p, STR_PAD_LEFT);
}

if (empty($quota)) {
   var_dump($quota);
   die("quota was empty\n");
}

$quota = explode("\n", $quota);
$quota = array_map('trim', $quota);

foreach ($quota as $lineNum => $line) {
    if ($lineNum < 2) {
        continue;
    }

    $values = array_filter(explode(" ", $line));

    if (count($values) != 4) {
        continue;
    }
    
    $result = array_combine(['fs', 'used', 'quota', 'limit'], $values);
    
    $result['used_percentage'] = round($result['used'] / $result['quota'] * 100, 3);
    $result['used_gb'] = round($result['used'] / 1024 / 1024, 2);
    $result['quota_gb'] = round($result['quota'] / 1024 / 1024, 2);
    
    $char = strlen($result['fs']);
    if ($char > $fsCharLenght) {
        $fsCharLenght = $char;
    }
    
    $output[] = $result;
}

if (!empty($output)) {
    
    $header = sprintf("%s | %s | %s | %s",
        str_pad("Mount", $fsCharLenght),
        'Usage%',
        'Used/Total',
        'Bar'
    );
    $headerWidth = strlen($header);
    
    echo "\n" . $header . "\n";
    echo str_repeat('-', $headerWidth + 24) . "\n";
    
    foreach ($output as $i) {
        $barUsed = round($i['used_percentage']) / 4;
        echo sprintf(
            "%s | %s | %s | [%s]",
            str_pad($i['fs'], $fsCharLenght),
            str_pad(round($i['used_percentage'], 1) . '%', 6, ' ', STR_PAD_LEFT),
            str_pad($i['used_gb'] . '/' . $i['quota_gb'], 10, ' ', STR_PAD_LEFT),
            str_pad(str_repeat('#', $barUsed), 25, '_')
        ) . "\n";
    }

    echo "\n\n";
}

