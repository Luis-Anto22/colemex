<?php

namespace App\Http\Controllers\Api\Common;

use App\Http\Controllers\Controller;
use App\Models\Caso;
use Illuminate\Http\Request;

class ClienteCasoController extends Controller
{
    public function misCasosCliente(Request $request)
    {
        $clienteId = $request->query('cliente_id');
        $limit = (int) $request->query('limit', 10);

        if (empty($clienteId)) {
            return response()->json([
                'success' => false,
                'message' => 'cliente_id es obligatorio.',
            ], 422);
        }

        $casos = Caso::query()
            ->where('cliente_id', $clienteId)
            ->orderByDesc('fecha_creacion')
            ->limit($limit)
            ->get();

        return response()->json([
            'success' => true,
            'data' => $casos,
        ]);
    }

    public function solicitarCasoCliente(Request $request)
    {
        $validated = $request->validate([
            'cliente_id' => 'required|integer',
            'profesional_id' => 'required|integer',
            'servicio' => 'required|string|max:100',
            'titulo' => 'required|string|max:255',
            'descripcion' => 'nullable|string',
        ]);

        $caso = Caso::create([
            'cliente_id' => $validated['cliente_id'],
            'profesional_id' => $validated['profesional_id'],
            'servicio' => $validated['servicio'],
            'titulo' => $validated['titulo'],
            'descripcion' => $validated['descripcion'] ?? '',
            'estado' => 'pendiente',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Solicitud enviada correctamente.',
            'data' => [
                'creado' => true,
                'caso' => $caso,
                'caso_id' => $caso->id,
            ],
        ], 201);
    }
}