<?php

namespace App\Http\Controllers\Api\Valuador;

use App\Http\Controllers\Controller;
use App\Models\Caso;
use App\Models\ValuadorAvaluo;
use Illuminate\Http\Request;

class ValuadorAvaluoController extends Controller
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

        $casos = Caso::with([
                'cliente:id,nombre,correo,telefono,ciudad',
            ])
            ->where('profesional_id', $valuadorId)
            ->where(function ($query) {
                $query->where('servicio', 'LIKE', '%Valuador%')
                    ->orWhere('servicio', 'LIKE', '%Valuadores%')
                    ->orWhere('servicio', 'LIKE', '%Avalúo%')
                    ->orWhere('servicio', 'LIKE', '%Avaluo%');
            })
            ->whereIn('estado', ['en proceso', 'finalizado'])
            ->orderByDesc('fecha_creacion')
            ->get();

        $items = $casos->map(function ($caso) use ($valuadorId) {
            $avaluo = ValuadorAvaluo::where('caso_id', $caso->id)
                ->where('profesional_id', $valuadorId)
                ->first();

            return [
                'id' => $avaluo?->id,
                'caso_id' => $caso->id,
                'profesional_id' => $caso->profesional_id,
                'cliente_id' => $caso->cliente_id,
                'cliente' => $caso->cliente,
                'servicio' => $caso->servicio,
                'titulo' => $caso->titulo,
                'descripcion' => $caso->descripcion,
                'estado' => $caso->estado,
                'fecha_creacion' => $caso->fecha_creacion,
                'valor_estimado' => $avaluo?->valor_estimado,
                'notas' => $avaluo?->notas,
                'creado_en' => $avaluo?->creado_en,
                'actualizado_en' => $avaluo?->actualizado_en,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $items,
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'valuador_id' => 'required|integer',
            'caso_id' => 'required|integer',
            'estado' => 'nullable|string|max:50',
            'valor_estimado' => 'nullable|numeric',
            'notas' => 'nullable|string',
        ]);

        $caso = Caso::where('id', $validated['caso_id'])
            ->where('profesional_id', $validated['valuador_id'])
            ->first();

        if (!$caso) {
            return response()->json([
                'success' => false,
                'message' => 'Caso no encontrado para este valuador.',
            ], 404);
        }

        $avaluo = ValuadorAvaluo::updateOrCreate(
            [
                'caso_id' => $validated['caso_id'],
            ],
            [
                'profesional_id' => $validated['valuador_id'],
                'valor_estimado' => $validated['valor_estimado'] ?? null,
                'notas' => $validated['notas'] ?? null,
            ]
        );

        if (!empty($validated['estado'])) {
            $caso->estado = $validated['estado'];
            $caso->save();
        }

        return response()->json([
            'success' => true,
            'message' => 'Avalúo guardado correctamente.',
            'data' => [
                'avaluo' => $avaluo,
                'caso' => $caso,
            ],
        ]);
    }
}