<?php
header('Content-Type: application/json');
require_once "conexion.php";

$input = json_decode(file_get_contents("php://input"), true) ?? [];
$email = trim($input["email"] ?? "");
$password = $input["password"] ?? "";

function out($ok, $data=null, $error=null){
  echo json_encode(["ok"=>$ok, "data"=>$data, "error"=>$error]);
  exit;
}

if ($email === "" || $password === "") out(false, null, "Faltan credenciales");

$stmt = $conn->prepare("SELECT id, rol, nombre, email, password_hash, verificado, estado FROM profesionales WHERE email=? LIMIT 1");
$stmt->bind_param("s", $email);
$stmt->execute();
$res = $stmt->get_result();

if ($res->num_rows === 0) out(false, null, "Credenciales inválidas");

$user = $res->fetch_assoc();

if (!password_verify($password, $user["password_hash"])) {
  out(false, null, "Credenciales inválidas");
}

unset($user["password_hash"]);

out(true, ["user"=>$user]);
