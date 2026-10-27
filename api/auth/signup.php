<?php
require_once __DIR__ . "/../cors.php";
require_once __DIR__ . "/../db.php";

$pdo = db();
$in = json_input();

$first = trim($in["first_name"] ?? "");
$middle = trim($in["middle_name"] ?? "");
$last = trim($in["last_name"] ?? "");
$email = strtolower(trim($in["email"] ?? ""));
$password = (string)($in["password"] ?? "");

if ($first === "" || $last === "" || $email === "" || $password === "") {
  respond(["ok" => false, "error" => "Missing required fields"], 422);
}
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
  respond(["ok" => false, "error" => "Invalid email"], 422);
}

$hash = password_hash($password, PASSWORD_BCRYPT);

try {
  $stmt = $pdo->prepare("
    INSERT INTO users(first_name,middle_name,last_name,email,password_hash,default_segment)
    VALUES(?,?,?,?,?, 'customer')
  ");
  $stmt->execute([$first, $middle !== "" ? $middle : null, $last, $email, $hash]);

  respond(["ok" => true, "user_id" => (int)$pdo->lastInsertId()]);
} catch (PDOException $e) {
  if ((int)$e->getCode() === 23000) {
    respond(["ok" => false, "error" => "Email already exists"], 409);
  }
  respond(["ok" => false, "error" => "Server error"], 500);
}