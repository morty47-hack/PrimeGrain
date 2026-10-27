<?php
require_once __DIR__ . "/../cors.php";
require_once __DIR__ . "/../db.php";

$pdo = db();
$user_id = (int)($_GET["user_id"] ?? 0);

if ($user_id <= 0) {
  respond(["ok" => false, "error" => "Missing user_id"], 422);
}

$stmt = $pdo->prepare("SELECT id FROM carts WHERE user_id = ? AND status = 'active' LIMIT 1");
$stmt->execute([$user_id]);
$cart = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$cart) {
  respond(["ok" => true, "cart_id" => null, "items" => [], "total" => 0]);
}

$cart_id = (int)$cart["id"];

$stmt = $pdo->prepare("
  SELECT
    ci.id AS cart_item_id,
    p.app_product_id,
    p.name,
    ci.segment,
    ci.kg,
    ci.unit_price,
    (ci.kg * ci.unit_price) AS line_total,
    ci.created_at
  FROM cart_items ci
  JOIN products p ON p.id = ci.product_id
  WHERE ci.cart_id = ?
  ORDER BY ci.id DESC
");
$stmt->execute([$cart_id]);
$items = $stmt->fetchAll(PDO::FETCH_ASSOC);

$total = 0;
foreach ($items as $it) {
  $total += (float)$it["line_total"];
}

respond([
  "ok" => true,
  "cart_id" => $cart_id,
  "items" => $items,
  "total" => $total
]);

