<?php

namespace App\Http\Controllers\Api\Common;

use App\Http\Controllers\Controller;
use App\Models\Profesional;
use Illuminate\Http\Request;

class UbicacionController extends Controller
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

        $profesional = Profesional::find($profesionalId);

        if (!$profesional) {
            return response()->json([
                'success' => false,
                'message' => 'Profesional no encontrado',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'profesional_id' => $profesional->id,
                'latitud' => $profesional->latitud,
                'longitud' => $profesional->longitud,
                'latitude' => $profesional->latitud,
                'longitude' => $profesional->longitud,
                'estado' => $profesional->estado,
                'ciudad' => $profesional->ciudad,
            ],
        ]);
    }

    public function update(Request $request)
    {
        $validated = $request->validate([
            'profesional_id' => 'required|integer',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
        ]);

        $profesional = Profesional::find($validated['profesional_id']);

        if (!$profesional) {
            return response()->json([
                'success' => false,
                'message' => 'Profesional no encontrado',
            ], 404);
        }

        $profesional->latitud = $validated['latitude'];
        $profesional->longitud = $validated['longitude'];
        $profesional->save();

        return response()->json([
            'success' => true,
            'message' => 'Ubicación actualizada correctamente.',
            'data' => [
                'profesional_id' => $profesional->id,
                'latitud' => $profesional->latitud,
                'longitud' => $profesional->longitud,
                'latitude' => $profesional->latitud,
                'longitude' => $profesional->longitud,
            ],
        ]);
    }
}