<?php

namespace App\Http\Controllers\Api\Common;

use App\Http\Controllers\Controller;
use App\Models\Configuracion;
use App\Models\Profesional;
use Illuminate\Http\Request;

class ConfiguracionController extends Controller
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

        $configuracion = Configuracion::where('profesional_id', $profesionalId)->first();

        $preferencias = $configuracion?->preferencias ?? [];

        return response()->json([
            'success' => true,
            'data' => [
                'profesional_id' => (int) $profesionalId,
                'notificaciones' => (bool) ($preferencias['notificaciones'] ?? true),
                'compartir_ubicacion' => (bool) ($preferencias['compartir_ubicacion'] ?? false),
            ],
        ]);
    }

    public function update(Request $request)
    {
        $validated = $request->validate([
            'profesional_id' => 'required|integer',
            'notificaciones' => 'nullable',
            'compartir_ubicacion' => 'nullable',
        ]);

        $profesional = Profesional::find($validated['profesional_id']);

        if (!$profesional) {
            return response()->json([
                'success' => false,
                'message' => 'Profesional no encontrado',
            ], 404);
        }

        $configuracion = Configuracion::firstOrCreate(
            [
                'profesional_id' => $validated['profesional_id'],
            ],
            [
                'preferencias' => [],
            ]
        );

        $preferencias = $configuracion->preferencias ?? [];

        if ($request->has('notificaciones')) {
            $preferencias['notificaciones'] = filter_var(
                $request->input('notificaciones'),
                FILTER_VALIDATE_BOOLEAN
            );
        }

        if ($request->has('compartir_ubicacion')) {
            $preferencias['compartir_ubicacion'] = filter_var(
                $request->input('compartir_ubicacion'),
                FILTER_VALIDATE_BOOLEAN
            );
        }

        $configuracion->preferencias = $preferencias;
        $configuracion->save();

        return response()->json([
            'success' => true,
            'message' => 'Configuración guardada correctamente.',
            'data' => [
                'profesional_id' => $configuracion->profesional_id,
                'notificaciones' => (bool) ($preferencias['notificaciones'] ?? true),
                'compartir_ubicacion' => (bool) ($preferencias['compartir_ubicacion'] ?? false),
            ],
        ]);
    }
}