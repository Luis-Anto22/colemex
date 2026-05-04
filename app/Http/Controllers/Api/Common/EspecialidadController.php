<?php

namespace App\Http\Controllers\Api\Common;

use App\Http\Controllers\Controller;
use App\Models\Especialidad;
use Illuminate\Http\Request;

class EspecialidadController extends Controller
{
    public function index(Request $request)
    {
        $query = $request->query('q');
        $limit = (int) $request->query('limit', 100);

        $especialidades = Especialidad::query()
            ->when(!empty($query), function ($q) use ($query) {
                $q->where('nombre', 'LIKE', '%' . $query . '%');
            })
            ->orderBy('nombre')
            ->limit($limit)
            ->get();

        return response()->json([
            'success' => true,
            'data' => $especialidades,
        ]);
    }
}