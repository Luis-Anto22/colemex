<?php

namespace App\Http\Controllers\Api\Valuador;

use App\Http\Controllers\Controller;
use App\Models\Caso;
use Illuminate\Http\Request;

class ValuadorSolicitudController extends Controller
{
    public function index(Request $request)
    {
        $valuadorId = $request->query('valuador_id');

        if (empty($valuadorId)) {
            return response()->json([
                'success' => false,
                'message' => 'valuador_id requerido',
            ], 422);
        }

        $solicitudes = Caso::with('cliente:id,nombre,correo,telefono,ciudad')
            ->where('profesional_id', $valuadorId)
            ->where(function ($query) {
                $query->where('servicio', 'LIKE', '%Valuador%')
                    ->orWhere('servicio', 'LIKE', '%Valuadores%')
                    ->orWhere('servicio', 'LIKE', '%Avalúo%')
                    ->orWhere('servicio', 'LIKE', '%Avaluo%');
            })
            ->orderByDesc('fecha_creacion')
            ->get()
            ->map(function ($caso) {
                return [
                    'id' => $caso->id,
                    'profesional_id' => $caso->profesional_id,
                    'cliente_id' => $caso->cliente_id,
                    'cliente' => $caso->cliente,
                    'servicio' => $caso->servicio,
                    'titulo' => $caso->titulo,
                    'descripcion' => $caso->descripcion,
                    'estado' => $caso->estado,
                    'fecha_creacion' => $caso->fecha_creacion,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $solicitudes,
        ]);
    }

    public function updateEstado(Request $request, $id)
    {
        $validated = $request->validate([
            'estado' => 'required|string|max:50',
        ]);

        $caso = Caso::find($id);

        if (!$caso) {
            return response()->json([
                'success' => false,
                'message' => 'Solicitud no encontrada',
            ], 404);
        }

        $caso->estado = $validated['estado'];
        $caso->save();

        return response()->json([
            'success' => true,
            'message' => 'Solicitud actualizada correctamente.',
            'data' => [
                'id' => $caso->id,
                'estado' => $caso->estado,
            ],
        ]);
    }
}