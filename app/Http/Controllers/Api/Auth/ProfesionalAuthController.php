<?php

namespace App\Http\Controllers\Api\Auth;

use App\Http\Controllers\Controller;
use App\Models\Profesional;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class ProfesionalAuthController extends Controller
{
    public function login(Request $request): JsonResponse
    {
        $data = $request->validate([
            'correo' => ['required', 'email'],
            'contrasena' => ['required', 'string'],
        ]);

        $correo = strtolower(trim($data['correo']));
        $contrasena = $data['contrasena'];

        $profesional = Profesional::whereRaw('LOWER(TRIM(correo)) = ?', [$correo])->first();

        if (! $profesional) {
            return response()->json([
                'success' => false,
                'mensaje' => '❌ Usuario no registrado',
            ], 404);
        }

        $correoBd = trim(strtolower($profesional->correo));
        $perfil = trim(strtolower($profesional->perfil));

        // ADMIN ESPECIAL
        if ($correoBd === 'admin@colemex.com') {
            if (! Hash::check($contrasena, $profesional->contrasena)) {
                return response()->json([
                    'success' => false,
                    'mensaje' => '❌ Contraseña incorrecta',
                ], 401);
            }

            $profesional->tokens()->delete();
            $token = $profesional->createToken('profesional_app')->plainTextToken;

            return response()->json([
                'success' => true,
                'token' => $token,
                'usuario' => [
                    'id' => $profesional->id,
                    'nombre' => $profesional->nombre,
                    'correo' => $profesional->correo,
                    'perfil' => 'admin',
                ],
            ], 200);
        }

        // VALIDACIONES PROFESIONAL
        if ((int) $profesional->verificado !== 1) {
            return response()->json([
                'success' => false,
                'mensaje' => '❌ Profesional no verificado',
            ], 403);
        }

        if ($profesional->estado !== 'disponible') {
            return response()->json([
                'success' => false,
                'mensaje' => '❌ Profesional no disponible',
            ], 403);
        }

        if (! Hash::check($contrasena, $profesional->contrasena)) {
            return response()->json([
                'success' => false,
                'mensaje' => '❌ Contraseña incorrecta',
            ], 401);
        }

        $profesional->tokens()->delete();
        $token = $profesional->createToken('profesional_app')->plainTextToken;

        return response()->json([
            'success' => true,
            'token' => $token,
            'usuario' => [
                'id' => $profesional->id,
                'nombre' => $profesional->nombre,
                'correo' => $profesional->correo,
                'perfil' => $perfil,
            ],
        ], 200);
    }
}