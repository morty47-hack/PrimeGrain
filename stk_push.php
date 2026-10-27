<?php
declare(strict_types=1);

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

if (($_SERVER["REQUEST_METHOD"] ?? "GET") === "OPTIONS") {
  http_response_code(200);
  exit();
}

if (($_SERVER["REQUEST_METHOD"] ?? "GET") !== "POST") {
  http_response_code(405);
  echo json_encode(["ok" => false, "message" => "Method not allowed"]);
  exit();
}

require_once __DIR__ . "/api/db.php";

function respond(array $payload, int $code = 200): void {
  http_response_code($code);
  echo json_encode($payload);
  exit();
}

function env_or_default(string $key, string $default = ""): string {
  $value = getenv($key);
  return $value === false ? $default : trim($value);
}

function normalize_phone(string $phone): string {
  $digits = preg_replace("/\D+/", "", $phone ?? "") ?? "";
  if ($digits === "") return "";
  if (str_starts_with($digits, "0")) return "254" . substr($digits, 1);
  if (str_starts_with($digits, "7")) return "254" . $digits;
  if (str_starts_with($digits, "254")) return $digits;
  return $digits;
}

// Supports both JSON body and x-www-form-urlencoded (current Flutter code).
$rawBody = file_get_contents("php://input");
$json = json_decode($rawBody, true);
$request = is_array($json) ? $json : $_POST;

$phone = normalize_phone((string)($request["phone"] ?? ""));
$amount = (int)($request["amount"] ?? 0);

if ($phone === "" || strlen($phone) !== 12 || !str_starts_with($phone, "254")) {
  respond(["ok" => false, "message" => "Invalid phone format"], 422);
}
if ($amount <= 0) {
  respond(["ok" => false, "message" => "Amount must be greater than 0"], 422);
}

$consumerKey = env_or_default("MPESA_CONSUMER_KEY");
$consumerSecret = env_or_default("MPESA_CONSUMER_SECRET");
$shortCode = env_or_default("MPESA_SHORTCODE");
$passkey = env_or_default("MPESA_PASSKEY");
$callbackUrl = env_or_default("MPESA_CALLBACK_URL");
$tokenUrl = env_or_default("MPESA_TOKEN_URL", "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials");
$stkUrl = env_or_default("MPESA_STK_URL", "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest");

if (
  $consumerKey === "" || $consumerSecret === "" || $shortCode === "" ||
  $passkey === "" || $callbackUrl === ""
) {
  respond([
    "ok" => false,
    "message" => "M-Pesa server credentials are missing",
  ], 500);
}

$tokenCh = curl_init($tokenUrl);
curl_setopt_array($tokenCh, [
  CURLOPT_RETURNTRANSFER => true,
  CURLOPT_HTTPHEADER => [
    "Authorization: Basic " . base64_encode($consumerKey . ":" . $consumerSecret),
  ],
  CURLOPT_TIMEOUT => 30,
]);
$tokenRaw = curl_exec($tokenCh);
$tokenErr = curl_error($tokenCh);
$tokenCode = (int)curl_getinfo($tokenCh, CURLINFO_HTTP_CODE);
curl_close($tokenCh);

if ($tokenErr !== "") {
  respond(["ok" => false, "message" => "Token request failed: " . $tokenErr], 500);
}

$tokenData = json_decode((string)$tokenRaw, true);
$accessToken = $tokenData["access_token"] ?? null;
if ($tokenCode >= 400 || !$accessToken) {
  respond([
    "ok" => false,
    "message" => "Failed to generate access token",
    "data" => $tokenData,
  ], 500);
}

$timestamp = date("YmdHis");
$password = base64_encode($shortCode . $passkey . $timestamp);

$payload = [
  "BusinessShortCode" => $shortCode,
  "Password" => $password,
  "Timestamp" => $timestamp,
  "TransactionType" => "CustomerPayBillOnline",
  "Amount" => $amount,
  "PartyA" => $phone,
  "PartyB" => $shortCode,
  "PhoneNumber" => $phone,
  "CallBackURL" => $callbackUrl,
  "AccountReference" => "PrimeGrain",
  "TransactionDesc" => "PrimeGrain payment",
];

$stkCh = curl_init($stkUrl);
curl_setopt_array($stkCh, [
  CURLOPT_RETURNTRANSFER => true,
  CURLOPT_POST => true,
  CURLOPT_POSTFIELDS => json_encode($payload),
  CURLOPT_HTTPHEADER => [
    "Content-Type: application/json",
    "Authorization: Bearer " . $accessToken,
  ],
  CURLOPT_TIMEOUT => 30,
]);
$stkRaw = curl_exec($stkCh);
$stkErr = curl_error($stkCh);
$stkCode = (int)curl_getinfo($stkCh, CURLINFO_HTTP_CODE);
curl_close($stkCh);

if ($stkErr !== "") {
  respond(["ok" => false, "message" => "STK request failed: " . $stkErr], 500);
}

$stkData = json_decode((string)$stkRaw, true);
if (!is_array($stkData)) {
  respond(["ok" => false, "message" => "Invalid STK response", "raw" => $stkRaw], 500);
}

if (isset($stkData["CheckoutRequestID"])) {
  try {
    $pdo = db();
    $stmt = $pdo->prepare("
      INSERT INTO payments (phone, amount, status, checkout_request_id)
      VALUES (?, ?, ?, ?)
    ");
    $stmt->execute([$phone, $amount, "PENDING", $stkData["CheckoutRequestID"]]);
  } catch (Throwable $e) {
    // Keep response successful even if local logging fails.
  }
}

if ($stkCode >= 400) {
  respond([
    "ok" => false,
    "message" => $stkData["errorMessage"] ?? "STK push failed",
    "data" => $stkData,
  ], $stkCode);
}

respond([
  "ok" => true,
  "message" => $stkData["ResponseDescription"] ?? "STK Push initiated",
  "data" => $stkData,
]);

