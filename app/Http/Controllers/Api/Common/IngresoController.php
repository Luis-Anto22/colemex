<?php

namespace App\Http\Controllers\Api\Common;

use App\Http\Controllers\Controller;
use App\Models\Ingreso;
use Illuminate\Http\Request;

class IngresoController extends Controller
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

        $ingresos = Ingreso::query()
            ->where('profesional_id', $profesionalId)
            ->orderByDesc('fecha')
            ->get();

        $total = $ingresos->sum('monto');

        return response()->json([
            'success' => true,
            'data' => [
                'total' => round($total, 2),
                'pagado' => round($total, 2),
                'pendiente' => 0,
                'items' => $ingresos->map(function ($ingreso) {
                    return [
                        'id' => $ingreso->id,
                        'profesional_id' => $ingreso->profesional_id,
                        'monto' => $ingreso->monto,
                        'concepto' => $ingreso->concepto,
                        'fecha' => $ingreso->fecha,
                    ];
                })->values(),
            ],
        ]);
    }
}