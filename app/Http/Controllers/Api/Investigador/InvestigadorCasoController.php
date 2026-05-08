<?php

namespace App\Http\Controllers\Api\Investigador;

use App\Http\Controllers\Controller;
use App\Models\Caso;
use Illuminate\Http\Request;

class InvestigadorCasoController extends Controller
{
    public function index(Request $request)
    {
        $investigadorId = $request->query('investigador_id');

        if (!$investigadorId) {
            return response()->json([
                'success' => false,
                'message' => 'El investigador_id es obligatorio',
            ], 400);
        }

        $casos = Caso::where('profesional_id', $investigadorId)
            ->where('servicio', 'Investigadores')
            ->orderByDesc('id')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $casos,
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'investigador_id' => 'required|integer',
            'titulo' => 'required|string|max:255',
            'cliente_id' => 'nullable|integer',
            'descripcion' => 'nullable|string',
        ]);

        $caso = Caso::create([
            'profesional_id' => $request->investigador_id,
            'cliente_id' => $request->cliente_id,
            'servicio' => 'Investigadores',
            'titulo' => $request->titulo,
            'descripcion' => $request->descripcion,
            'estado' => 'pendiente',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Caso creado correctamente',
            'data' => $caso,
        ]);
    }

    public function updateEstado(Request $request)
    {
        $request->validate([
            'id' => 'required|integer',
            'estado' => 'required|string',
        ]);

        $estadosPermitidos = [
            'pendiente',
            'en proceso',
            'finalizado',
            'cancelado',
        ];

        if (!in_array($request->estado, $estadosPermitidos)) {
            return response()->json([
                'success' => false,
                'message' => 'Estado no válido',
            ], 422);
        }

        $caso = Caso::find($request->id);

        if (!$caso) {
            return response()->json([
                'success' => false,
                'message' => 'Caso no encontrado',
            ], 404);
        }

        $caso->estado = $request->estado;
        $caso->save();

        return response()->json([
            'success' => true,
            'message' => 'Estado actualizado correctamente',
            'data' => $caso,
        ]);
    }
}