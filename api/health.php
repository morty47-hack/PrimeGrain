<?php
require_once __DIR__ . "/cors.php";
require_once __DIR__ . "/db.php";

$pdo = db();
$tables = $pdo->query("SHOW TABLES")->fetchAll(PDO::FETCH_COLUMN);

respond([
  "ok" => true,
  "db" => "primegrain",
  "tables_count" => count($tables),
]);