<?php

namespace App\Http\Controllers\Api\Common;

use App\Http\Controllers\Controller;
use App\Models\Calificacion;
use Illuminate\Http\Request;

class CalificacionController extends Controller
{
    public function index(Request $request)
    {
        $profesionalId = $request->query('profesional_id');

        if (empty($profesionalId)) {
            return response()->json([
                'success' => false,
                'message' => 'profesional_id requerido',
            ], 422);
        }

        $calificaciones = Calificacion::query()
            ->with('cliente:id,nombre,correo')
            ->where('profesional_id', $profesionalId)
            ->orderByDesc('fecha')
            ->get();

        $total = $calificaciones->count();
        $promedio = $total > 0
            ? round($calificaciones->avg('estrellas'), 1)
            : 0;

        return response()->json([
            'success' => true,
            'data' => [
                'items' => $calificaciones->map(function ($calificacion) {
                    return [
                        'id' => $calificacion->id,
                        'profesional_id' => $calificacion->profesional_id,
                        'cliente_id' => $calificacion->cliente_id,
                        'cliente' => $calificacion->cliente,
                        'estrellas' => $calificacion->estrellas,
                        'comentario' => $calificacion->comentario,
                        'fecha' => $calificacion->fecha,
                    ];
                })->values(),
                'promedio' => $promedio,
                'total' => $total,
            ],
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'profesional_id' => 'required|integer',
            'cliente_id' => 'required|integer',
            'estrellas' => 'required|integer|min:1|max:5',
            'comentario' => 'nullable|string',
        ]);

        $calificacion = Calificacion::create([
            'profesional_id' => $validated['profesional_id'],
            'cliente_id' => $validated['cliente_id'],
            'estrellas' => $validated['estrellas'],
            'comentario' => $validated['comentario'] ?? null,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Calificación registrada correctamente.',
            'data' => [
                'id' => $calificacion->id,
                'calificacion' => $calificacion,
            ],
        ], 201);
    }
}