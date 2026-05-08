<?php

namespace App\Http\Controllers\Api\Common;

use App\Http\Controllers\Controller;
use App\Models\Profesional;
use Illuminate\Http\Request;

class PerfilController extends Controller
{
    public function show(Request $request)
    {
        $profesionalId = $request->query('profesional_id');

        if (empty($profesionalId)) {
            return response()->json([
                'success' => false,
                'message' => 'profesional_id requerido',
            ], 422);
        }

        $profesional = Profesional::with('especialidad')->find($profesionalId);

        if (!$profesional) {
            return response()->json([
                'success' => false,
                'message' => 'Profesional no encontrado',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $profesional->id,
                'nombre' => $profesional->nombre,
                'correo' => $profesional->correo,
                'telefono' => $profesional->telefono,
                'perfil' => $profesional->perfil,
                'especialidad_id' => $profesional->especialidad_id,
                'especialidad' => $profesional->especialidad?->nombre,
                'ciudad' => $profesional->ciudad,
                'foto' => $profesional->foto,
                'verificado' => $profesional->verificado,
                'estado' => $profesional->estado,
                'latitud' => $profesional->latitud,
                'longitud' => $profesional->longitud,
                'latitude' => $profesional->latitud,
                'longitude' => $profesional->longitud,
                'fecha_registro' => $profesional->fecha_registro,
            ],
        ]);
    }
}