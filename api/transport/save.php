<?php
require_once __DIR__ . "/../cors.php";
require_once __DIR__ . "/../db.php";

$pdo = db();
$in = json_input();

$user_id = (int)($in["user_id"] ?? 0);
$transport_type = strtolower(trim($in["transport_type"] ?? "private")); // private/public
$vehicle_plate = trim($in["vehicle_plate"] ?? "");
$driver_name = trim($in["driver_name"] ?? "");
$driver_phone = trim($in["driver_phone"] ?? "");
$carrier_company = trim($in["carrier_company"] ?? "");

if ($user_id <= 0 || $vehicle_plate === "" || $driver_name === "" || $driver_phone === "") {
  respond(["ok" => false, "error" => "Missing fields"], 422);
}
if (!in_array($transport_type, ["private", "public"], true)) {
  respond(["ok" => false, "error" => "Invalid transport_type"], 422);
}
if ($transport_type === "public" && $carrier_company === "") {
  respond(["ok" => false, "error" => "carrier_company required for public"], 422);
}

$stmt = $pdo->prepare("
  INSERT INTO transport_profiles
    (user_id, transport_type, vehicle_plate, driver_name, driver_phone, carrier_company)
  VALUES
    (:user_id, :transport_type, :vehicle_plate, :driver_name, :driver_phone, :carrier_company)
  ON DUPLICATE KEY UPDATE
    transport_type=VALUES(transport_type),
    vehicle_plate=VALUES(vehicle_plate),
    driver_name=VALUES(driver_name),
    driver_phone=VALUES(driver_phone),
    carrier_company=VALUES(carrier_company),
    updated_at=CURRENT_TIMESTAMP
");

$stmt->execute([
  ":user_id" => $user_id,
  ":transport_type" => $transport_type,
  ":vehicle_plate" => $vehicle_plate,
  ":driver_name" => $driver_name,
  ":driver_phone" => $driver_phone,
  ":carrier_company" => ($carrier_company !== "" ? $carrier_company : null),
]);

respond(["ok" => true]);