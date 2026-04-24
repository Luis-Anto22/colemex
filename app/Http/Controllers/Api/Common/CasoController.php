<?php

namespace App\Http\Controllers\Api\Common;

use App\Http\Controllers\Controller;
use App\Models\Caso;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CasoController extends Controller
{
    public function index(): JsonResponse
    {
        $casos = Caso::with(['cliente', 'profesional'])
            ->orderByDesc('fecha_creacion')
            ->get()
            ->map(function ($caso) {
                return [
                    'id' => $caso->id,
                    'titulo' => $caso->titulo,
                    'descripcion' => $caso->descripcion,
                    'servicio' => $caso->servicio,
                    'estado' => $caso->estado,
                    'fecha_creacion' => $caso->fecha_creacion,
                    'cliente' => [
                        'id' => $caso->cliente?->id,
                        'nombre' => $caso->cliente?->nombre,
                        'correo' => $caso->cliente?->correo,
                        'telefono' => $caso->cliente?->telefono,
                        'ciudad' => $caso->cliente?->ciudad,
                    ],
                    'profesional' => [
                        'id' => $caso->profesional?->id,
                        'nombre' => $caso->profesional?->nombre,
                        'perfil' => $caso->profesional?->perfil,
                        'correo' => $caso->profesional?->correo,
                    ],
                ];
            });

        return response()->json([
            'success' => true,
            'casos' => $casos,
        ], 200);
    }

    public function misCasos(int $profesionalId): JsonResponse
    {
        $casos = Caso::with(['cliente'])
            ->where('profesional_id', $profesionalId)
            ->orderByDesc('fecha_creacion')
            ->get()
            ->map(function ($caso) {
                return [
                    'id' => $caso->id,
                    'titulo' => $caso->titulo,
                    'descripcion' => $caso->descripcion,
                    'servicio' => $caso->servicio,
                    'estado' => $caso->estado,
                    'fecha_creacion' => $caso->fecha_creacion,
                    'cliente' => [
                        'id' => $caso->cliente?->id,
                        'nombre' => $caso->cliente?->nombre,
                        'correo' => $caso->cliente?->correo,
                        'telefono' => $caso->cliente?->telefono,
                        'ciudad' => $caso->cliente?->ciudad,
                    ],
                ];
            });

        return response()->json([
            'success' => true,
            'casos' => $casos,
        ], 200);
    }

    public function show(int $id): JsonResponse
    {
        $caso = Caso::with(['cliente', 'profesional', 'bitacoras'])->find($id);

        if (! $caso) {
            return response()->json([
                'success' => false,
                'mensaje' => '❌ Caso no encontrado',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'caso' => [
                'id' => $caso->id,
                'titulo' => $caso->titulo,
                'descripcion' => $caso->descripcion,
                'servicio' => $caso->servicio,
                'estado' => $caso->estado,
                'fecha_creacion' => $caso->fecha_creacion,
                'cliente' => [
                    'id' => $caso->cliente?->id,
                    'nombre' => $caso->cliente?->nombre,
                    'correo' => $caso->cliente?->correo,
                    'telefono' => $caso->cliente?->telefono,
                    'ciudad' => $caso->cliente?->ciudad,
                ],
                'profesional' => [
                    'id' => $caso->profesional?->id,
                    'nombre' => $caso->profesional?->nombre,
                    'perfil' => $caso->profesional?->perfil,
                    'correo' => $caso->profesional?->correo,
                ],
                'bitacoras' => $caso->bitacoras,
            ],
        ], 200);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'profesional_id' => ['required', 'integer', 'exists:profesionales,id'],
            'cliente_id' => ['required', 'integer', 'exists:clientes,id'],
            'servicio' => ['required', 'string', 'max:255'],
            'titulo' => ['required', 'string', 'max:255'],
            'descripcion' => ['nullable', 'string'],
            'estado' => ['nullable', 'in:pendiente,en proceso,finalizado,cancelado'],
        ]);

        $caso = Caso::create([
            'profesional_id' => $data['profesional_id'],
            'cliente_id' => $data['cliente_id'],
            'servicio' => trim($data['servicio']),
            'titulo' => trim($data['titulo']),
            'descripcion' => isset($data['descripcion']) ? trim($data['descripcion']) : null,
            'estado' => $data['estado'] ?? 'pendiente',
        ]);

        $caso->load(['cliente', 'profesional']);

        return response()->json([
            'success' => true,
            'mensaje' => '✅ Caso creado correctamente',
            'caso' => [
                'id' => $caso->id,
                'titulo' => $caso->titulo,
                'descripcion' => $caso->descripcion,
                'servicio' => $caso->servicio,
                'estado' => $caso->estado,
                'fecha_creacion' => $caso->fecha_creacion,
                'cliente' => [
                    'id' => $caso->cliente?->id,
                    'nombre' => $caso->cliente?->nombre,
                    'correo' => $caso->cliente?->correo,
                    'telefono' => $caso->cliente?->telefono,
                    'ciudad' => $caso->cliente?->ciudad,
                ],
                'profesional' => [
                    'id' => $caso->profesional?->id,
                    'nombre' => $caso->profesional?->nombre,
                    'perfil' => $caso->profesional?->perfil,
                    'correo' => $caso->profesional?->correo,
                ],
            ],
        ], 201);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $caso = Caso::find($id);

        if (! $caso) {
            return response()->json([
                'success' => false,
                'mensaje' => '❌ Caso no encontrado',
            ], 404);
        }

        $data = $request->validate([
            'cliente_id' => ['required', 'integer', 'exists:clientes,id'],
            'servicio' => ['required', 'string', 'max:255'],
            'titulo' => ['required', 'string', 'max:255'],
            'descripcion' => ['nullable', 'string'],
            'estado' => ['nullable', 'in:pendiente,en proceso,finalizado,cancelado'],
        ]);

        $caso->cliente_id = $data['cliente_id'];
        $caso->servicio = trim($data['servicio']);
        $caso->titulo = trim($data['titulo']);
        $caso->descripcion = isset($data['descripcion']) ? trim($data['descripcion']) : null;
        $caso->estado = $data['estado'] ?? $caso->estado;
        $caso->save();

        $caso->load(['cliente', 'profesional']);

        return response()->json([
            'success' => true,
            'mensaje' => '✅ Caso actualizado correctamente',
            'caso' => [
                'id' => $caso->id,
                'titulo' => $caso->titulo,
                'descripcion' => $caso->descripcion,
                'servicio' => $caso->servicio,
                'estado' => $caso->estado,
                'fecha_creacion' => $caso->fecha_creacion,
                'cliente' => [
                    'id' => $caso->cliente?->id,
                    'nombre' => $caso->cliente?->nombre,
                    'correo' => $caso->cliente?->correo,
                    'telefono' => $caso->cliente?->telefono,
                    'ciudad' => $caso->cliente?->ciudad,
                ],
                'profesional' => [
                    'id' => $caso->profesional?->id,
                    'nombre' => $caso->profesional?->nombre,
                    'perfil' => $caso->profesional?->perfil,
                    'correo' => $caso->profesional?->correo,
                ],
            ],
        ], 200);
    }

    public function destroy(int $id): JsonResponse
    {
        $caso = Caso::find($id);

        if (! $caso) {
            return response()->json([
                'success' => false,
                'mensaje' => '❌ Caso no encontrado',
            ], 404);
        }

        $caso->delete();

        return response()->json([
            'success' => true,
            'mensaje' => '✅ Caso eliminado correctamente',
        ], 200);
    }
}