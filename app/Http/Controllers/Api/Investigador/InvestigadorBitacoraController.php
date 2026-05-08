<?php

namespace App\Http\Controllers\Api\Investigador;

use App\Http\Controllers\Controller;
use App\Models\CasoBitacora;
use Illuminate\Http\Request;

class InvestigadorBitacoraController extends Controller
{
    public function index(Request $request)
    {
        $casoId = $request->query('caso_id');

        if (!$casoId) {
            return response()->json([
                'success' => false,
                'message' => 'El caso_id es obligatorio',
            ], 400);
        }

        $bitacora = CasoBitacora::where('caso_id', $casoId)
            ->orderByDesc('creado_en')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $bitacora,
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'caso_id' => 'required|integer',
            'profesional_id' => 'required|integer',
            'nota' => 'required|string',
            'estado' => 'nullable|string|max:30',
        ]);

        $nota = CasoBitacora::create([
            'caso_id' => $request->caso_id,
            'profesional_id' => $request->profesional_id,
            'nota' => $request->nota,
            'estado' => $request->estado,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Nota agregada correctamente',
            'data' => $nota,
        ]);
    }
}