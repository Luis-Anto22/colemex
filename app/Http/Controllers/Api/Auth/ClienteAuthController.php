<?php

namespace App\Http\Controllers\Api\Auth;

use App\Http\Controllers\Controller;
use App\Models\Cliente;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class ClienteAuthController extends Controller
{
    public function login(Request $request): JsonResponse
    {
        $data = $request->validate([
            'correo' => ['required', 'email'],
            'contrasena' => ['required', 'string'],
        ]);

        $correo = trim($data['correo']);
        $contrasena = $data['contrasena'];

        $cliente = Cliente::where('correo', $correo)->first();

        if (! $cliente) {
            return response()->json([
                'success' => false,
                'mensaje' => 'Credenciales incorrectas',
            ], 401);
        }

        if (! Hash::check($contrasena, $cliente->contrasena)) {
            return response()->json([
                'success' => false,
                'mensaje' => 'Credenciales incorrectas',
            ], 401);
        }

        if ($cliente->estado !== 'activo') {
            return response()->json([
                'success' => false,
                'mensaje' => 'Cuenta inactiva',
            ], 403);
        }

        $cliente->ultima_conexion = now();
        $cliente->save();

        $cliente->tokens()->delete();
        $token = $cliente->createToken('cliente_app')->plainTextToken;

        return response()->json([
            'success' => true,
            'mensaje' => 'Bienvenido',
            'token' => $token,
            'usuario' => [
                'id' => $cliente->id,
                'nombre' => $cliente->nombre,
                'correo' => $cliente->correo,
                'perfil' => 'cliente',
            ],
        ], 200);
    }
}