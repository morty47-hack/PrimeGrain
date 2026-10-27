<?php
function db(): PDO {
  $pdo = new PDO("mysql:host=localhost;dbname=primegrain;charset=utf8mb4", "root", "");
  $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
  return $pdo;
}

function json_input(): array {
  $raw = file_get_contents("php://input");
  $data = json_decode($raw, true);
  return is_array($data) ? $data : [];
}

function respond($data, int $code = 200): void {
  http_response_code($code);
  header("Content-Type: application/json");
  echo json_encode($data);
  exit;
}

