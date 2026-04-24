<?php

namespace App\Http\Controllers\Api\Common;

use App\Http\Controllers\Controller;
use App\Models\Cliente;
use Illuminate\Http\JsonResponse;

class ClienteController extends Controller
{
    public function index(): JsonResponse
    {
        $clientes = Cliente::query()
            ->orderBy('nombre')
            ->get([
                'id',
                'nombre',
                'correo',
                'telefono',
                'ciudad',
                'estado',
                'foto',
                'fecha_registro',
            ]);

        return response()->json([
            'success' => true,
            'clientes' => $clientes,
        ], 200);
    }

    public function activos(): JsonResponse
    {
        $clientes = Cliente::query()
            ->where('estado', 'activo')
            ->orderBy('nombre')
            ->get([
                'id',
                'nombre',
                'correo',
                'telefono',
                'ciudad',
                'estado',
                'foto',
                'fecha_registro',
            ]);

        return response()->json([
            'success' => true,
            'clientes' => $clientes,
        ], 200);
    }

    public function show(int $id): JsonResponse
    {
        $cliente = Cliente::find($id);

        if (! $cliente) {
            return response()->json([
                'success' => false,
                'mensaje' => '❌ Cliente no encontrado',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'cliente' => $cliente,
        ], 200);
    }
}