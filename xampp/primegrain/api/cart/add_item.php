<?php
require_once __DIR__ . "/../cors.php";
require_once __DIR__ . "/../db.php";

$pdo = db();
$in = json_input();

$user_id = (int)($in["user_id"] ?? 0);
$app_product_id = trim($in["app_product_id"] ?? "");
$segment = strtolower(trim($in["segment"] ?? "")); // customer/retailer/wholesaler
$kg = (float)($in["kg"] ?? 0);

if ($user_id <= 0 || $app_product_id === "" || $kg <= 0) {
  respond(["ok" => false, "error" => "Missing fields"], 422);
}
if (!in_array($segment, ["customer", "retailer", "wholesaler"], true)) {
  respond(["ok" => false, "error" => "Invalid segment"], 422);
}

// Load product
$stmt = $pdo->prepare("SELECT id, base_price FROM products WHERE app_product_id = ? AND is_active = 1 LIMIT 1");
$stmt->execute([$app_product_id]);
$product = $stmt->fetch(PDO::FETCH_ASSOC);
if (!$product) {
  respond(["ok" => false, "error" => "Product not found"], 404);
}

// Load rules
$stmt = $pdo->prepare("SELECT price_delta, min_kg, max_kg FROM segment_rules WHERE segment = ? LIMIT 1");
$stmt->execute([$segment]);
$rules = $stmt->fetch(PDO::FETCH_ASSOC);
if (!$rules) {
  respond(["ok" => false, "error" => "Segment rules not found"], 500);
}

$minKg = (float)$rules["min_kg"];
$maxKg = (float)$rules["max_kg"];
if ($kg < $minKg || $kg > $maxKg) {
  respond(["ok" => false, "error" => "Kg out of range"], 422);
}

$unitPrice = (float)$product["base_price"] + (float)$rules["price_delta"];
if ($unitPrice < 0) $unitPrice = 0;

// Get/create active cart and insert item
$pdo->beginTransaction();
try {
  $stmt = $pdo->prepare("SELECT id FROM carts WHERE user_id = ? AND status = 'active' LIMIT 1");
  $stmt->execute([$user_id]);
  $cart = $stmt->fetch(PDO::FETCH_ASSOC);

  if ($cart) {
    $cart_id = (int)$cart["id"];
  } else {
    $stmt = $pdo->prepare("INSERT INTO carts(user_id, status) VALUES(?, 'active')");
    $stmt->execute([$user_id]);
    $cart_id = (int)$pdo->lastInsertId();
  }

  $stmt = $pdo->prepare("
    INSERT INTO cart_items(cart_id, product_id, segment, kg, unit_price)
    VALUES(?, ?, ?, ?, ?)
  ");
  $stmt->execute([$cart_id, (int)$product["id"], $segment, $kg, $unitPrice]);
  $cart_item_id = (int)$pdo->lastInsertId();

  $pdo->commit();
} catch (Exception $e) {
  $pdo->rollBack();
  respond(["ok" => false, "error" => "Server error"], 500);
}

respond([
  "ok" => true,
  "cart_id" => $cart_id,
  "cart_item_id" => $cart_item_id,
  "unit_price" => $unitPrice
]);

