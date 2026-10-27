<?php
require_once __DIR__ . "/../cors.php";
require_once __DIR__ . "/../db.php";

$pdo = db();
$in = json_input();

$email = strtolower(trim($in["email"] ?? ""));
$password = (string)($in["password"] ?? "");

if ($email === "" || $password === "") {
  respond(["ok" => false, "error" => "Missing email/password"], 422);
}

$stmt = $pdo->prepare("SELECT id, password_hash FROM users WHERE email=? LIMIT 1");
$stmt->execute([$email]);
$user = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$user || !password_verify($password, $user["password_hash"])) {
  respond(["ok" => false, "error" => "Invalid credentials"], 401);
}

respond(["ok" => true, "user_id" => (int)$user["id"]]);