<?php

namespace App\Http\Controllers\Api\Common;

use App\Http\Controllers\Controller;
use App\Models\Caso;
use App\Models\CasoBitacora;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CasoBitacoraController extends Controller
{
    public function index(int $casoId): JsonResponse
    {
        $caso = Caso::with(['cliente', 'profesional'])->find($casoId);

        if (! $caso) {
            return response()->json([
                'success' => false,
                'mensaje' => '❌ Caso no encontrado',
            ], 404);
        }

        $bitacoras = CasoBitacora::where('caso_id', $casoId)
            ->orderByDesc('creado_en')
            ->get();

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
                ],
                'profesional' => [
                    'id' => $caso->profesional?->id,
                    'nombre' => $caso->profesional?->nombre,
                    'perfil' => $caso->profesional?->perfil,
                    'correo' => $caso->profesional?->correo,
                ],
            ],
            'bitacoras' => $bitacoras,
        ], 200);
    }

    public function store(Request $request, int $casoId): JsonResponse
    {
        $data = $request->validate([
            'profesional_id' => ['required', 'integer', 'exists:profesionales,id'],
            'nota' => ['required', 'string'],
            'estado' => ['nullable', 'string', 'max:30'],
        ]);

        $caso = Caso::find($casoId);

        if (! $caso) {
            return response()->json([
                'success' => false,
                'mensaje' => '❌ Caso no encontrado',
            ], 404);
        }

        if ((int) $caso->profesional_id !== (int) $data['profesional_id']) {
            return response()->json([
                'success' => false,
                'mensaje' => '❌ Este caso no pertenece al profesional indicado',
            ], 403);
        }

        $bitacora = CasoBitacora::create([
            'caso_id' => $caso->id,
            'profesional_id' => $data['profesional_id'],
            'nota' => trim($data['nota']),
            'estado' => $data['estado'] ?? 'activo',
        ]);

        return response()->json([
            'success' => true,
            'mensaje' => '✅ Bitácora creada correctamente',
            'bitacora' => $bitacora,
        ], 201);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $data = $request->validate([
            'nota' => ['required', 'string'],
            'estado' => ['nullable', 'string', 'max:30'],
        ]);

        $bitacora = CasoBitacora::find($id);

        if (! $bitacora) {
            return response()->json([
                'success' => false,
                'mensaje' => '❌ Registro de bitácora no encontrado',
            ], 404);
        }

        $bitacora->nota = trim($data['nota']);
        $bitacora->estado = $data['estado'] ?? $bitacora->estado;
        $bitacora->save();

        return response()->json([
            'success' => true,
            'mensaje' => '✅ Bitácora actualizada correctamente',
            'bitacora' => $bitacora,
        ], 200);
    }

    public function destroy(int $id): JsonResponse
    {
        $bitacora = CasoBitacora::find($id);

        if (! $bitacora) {
            return response()->json([
                'success' => false,
                'mensaje' => '❌ Registro de bitácora no encontrado',
            ], 404);
        }

        $bitacora->delete();

        return response()->json([
            'success' => true,
            'mensaje' => '✅ Bitácora eliminada correctamente',
        ], 200);
    }
}