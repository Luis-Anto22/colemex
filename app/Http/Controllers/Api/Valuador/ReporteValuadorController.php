<?php

namespace App\Http\Controllers\Api\Valuador;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class ReporteValuadorController extends Controller
{
    public function index(Request $request)
    {
        try {
            $request->validate([
                'caso_id' => 'required|integer',
            ]);

            $reportes = DB::table('valuador_reportes')
                ->where('caso_id', $request->caso_id)
                ->orderByDesc('fecha')
                ->get();

            return response()->json([
                'success' => true,
                'data' => $reportes,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al obtener reportes',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    public function store(Request $request)
    {
        try {
            $request->validate([
                'caso_id' => 'required|integer',
                'profesional_id' => 'required|integer',
                'descripcion' => 'nullable|string',
                'file' => 'required|file|max:10240',
            ]);

            $archivo = $request->file('file');

            $ruta = $archivo->store('valuador/reportes', 'public');

            $urlArchivo = asset('storage/' . $ruta);

            $id = DB::table('valuador_reportes')->insertGetId([
                'caso_id' => $request->caso_id,
                'profesional_id' => $request->profesional_id,
                'descripcion' => $request->descripcion,
                'archivo' => $urlArchivo,
                'fecha' => now(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Reporte subido correctamente',
                'data' => [
                    'id' => $id,
                    'archivo' => $urlArchivo,
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al subir reporte',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}