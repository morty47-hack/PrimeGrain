<?php
require_once __DIR__ . "/../cors.php";
require_once __DIR__ . "/../db.php";

$pdo = db();
$in = json_input();
$user_id = (int)($in["user_id"] ?? 0);

if ($user_id <= 0) {
  respond(["ok" => false, "error" => "Missing user_id"], 422);
}

$stmt = $pdo->prepare("SELECT id FROM carts WHERE user_id = ? AND status = 'active' LIMIT 1");
$stmt->execute([$user_id]);
$cart = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$cart) {
  respond(["ok" => true, "cleared" => 0]);
}

$cart_id = (int)$cart["id"];
$stmt = $pdo->prepare("DELETE FROM cart_items WHERE cart_id = ?");
$stmt->execute([$cart_id]);

respond(["ok" => true, "cleared" => $stmt->rowCount()]);

