<?php

declare(strict_types=1);

$config = new Config();
$db = $config->getConfig()['dbParams'];
$connection = mysqli_connect(
    $db['db_host'],
    $db['db_user'],
    $db['db_pass'],
    $db['db_name'],
);

if (!$connection) {
    exit ('Connection to database failed: ' . mysqli_connect_error() . PHP_EOL);
}

$connection->select_db($db['db_name']);
