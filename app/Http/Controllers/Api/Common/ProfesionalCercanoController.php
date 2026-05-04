<?php

namespace App\Http\Controllers\Api\Common;

use App\Http\Controllers\Controller;
use App\Models\Profesional;
use Illuminate\Http\Request;

class ProfesionalCercanoController extends Controller
{
    public function index(Request $request)
    {
        $perfil = $request->query('perfil');
        $especialidad = $request->query('especialidad');
        $lat = $request->query('lat');
        $lng = $request->query('lng');
        $limit = (int) $request->query('limit', 50);

        $query = Profesional::with('especialidad')
            ->whereNotNull('latitud')
            ->whereNotNull('longitud');

        if (!empty($perfil)) {
            $query->where('perfil', $perfil);
        }

        if (!empty($especialidad)) {
            $query->whereHas('especialidad', function ($q) use ($especialidad) {
                $q->where('nombre', 'LIKE', '%' . $especialidad . '%');
            });
        }

        $profesionales = $query->get()->map(function ($profesional) use ($lat, $lng) {
            $distancia = null;

            if (
                !empty($lat) &&
                !empty($lng) &&
                !empty($profesional->latitud) &&
                !empty($profesional->longitud)
            ) {
                $radioTierra = 6371;

                $dLat = deg2rad($profesional->latitud - $lat);
                $dLng = deg2rad($profesional->longitud - $lng);

                $a = sin($dLat / 2) * sin($dLat / 2) +
                    cos(deg2rad($lat)) *
                    cos(deg2rad($profesional->latitud)) *
                    sin($dLng / 2) *
                    sin($dLng / 2);

                $c = 2 * atan2(sqrt($a), sqrt(1 - $a));

                $distancia = $radioTierra * $c;
            }

            return [
                'id' => $profesional->id,
                'nombre' => $profesional->nombre,
                'correo' => $profesional->correo,
                'telefono' => $profesional->telefono,
                'perfil' => $profesional->perfil,
                'especialidad_id' => $profesional->especialidad_id,
                'especialidad' => $profesional->especialidad?->nombre,
                'ciudad' => $profesional->ciudad,
                'foto' => $profesional->foto,
                'verificado' => $profesional->verificado,
                'estado' => $profesional->estado,
                'latitude' => $profesional->latitud,
                'longitude' => $profesional->longitud,
                'latitud' => $profesional->latitud,
                'longitud' => $profesional->longitud,
                'distancia_km' => $distancia !== null ? round($distancia, 2) : null,
                'rating_promedio' => 0,
                'total_calificaciones' => 0,
            ];
        })
        ->sortBy(function ($profesional) {
            return $profesional['distancia_km'] ?? 999999;
        })
        ->take($limit)
        ->values();

        return response()->json([
            'success' => true,
            'data' => $profesionales,
        ]);
    }
}