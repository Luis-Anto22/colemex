<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Profesional;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

class ProfesionalController extends Controller
{
    public function index()
    {
        $profesionales = Profesional::with('especialidad:id,nombre')
            ->orderByDesc('fecha_registro')
            ->get()
            ->map(function ($p) {
                return [
                    'id' => $p->id,
                    'nombre' => $p->nombre,
                    'correo' => $p->correo,
                    'telefono' => $p->telefono,
                    'perfil' => $p->perfil,
                    'especialidad_id' => $p->especialidad_id,
                    'especialidad' => $p->especialidad?->nombre,
                    'ciudad' => $p->ciudad,
                    'foto' => $p->foto,
                    'verificado' => $p->verificado,
                    'estado' => $p->estado,
                    'fecha_registro' => $p->fecha_registro,
                    'latitud' => $p->latitud,
                    'longitud' => $p->longitud,
                ];
            });

        return response()->json([
            'success' => true,
            'profesionales' => $profesionales,
        ]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'nombre' => ['required', 'string', 'max:150'],
            'correo' => ['required', 'email', 'max:150', 'unique:profesionales,correo'],
            'telefono' => ['nullable', 'string', 'max:20'],
            'contrasena' => ['required', 'string', 'min:6'],
            'perfil' => [
                'required',
                Rule::in([
                    'Abogados',
                    'Ajustadores',
                    'Peritos en criminalística',
                    'Valuadores',
                    'Investigadores',
                    'Psicólogos',
                    'Agentes inmobiliarios',
                    'Contadores',
                    'Agentes crediticios',
                    'Asistencia vial',
                ]),
            ],
            'especialidad_id' => ['nullable', 'integer', 'exists:especialidades,id'],
            'ciudad' => ['nullable', 'string', 'max:100'],
            'foto' => ['nullable', 'string', 'max:255'],
            'verificado' => ['nullable', 'boolean'],
            'estado' => ['nullable', Rule::in(['disponible', 'ocupado', 'fuera de servicio'])],
            'latitud' => ['nullable', 'numeric'],
            'longitud' => ['nullable', 'numeric'],
        ]);

        $profesional = Profesional::create([
            'nombre' => $data['nombre'],
            'correo' => $data['correo'],
            'telefono' => $data['telefono'] ?? null,
            'contrasena' => Hash::make($data['contrasena']),
            'perfil' => $data['perfil'],
            'especialidad_id' => $data['especialidad_id'] ?? null,
            'ciudad' => $data['ciudad'] ?? null,
            'foto' => $data['foto'] ?? null,
            'verificado' => $data['verificado'] ?? 1,
            'estado' => $data['estado'] ?? 'disponible',
            'latitud' => $data['latitud'] ?? null,
            'longitud' => $data['longitud'] ?? null,
        ]);

        return response()->json([
            'success' => true,
            'mensaje' => '✅ Profesional creado correctamente',
            'profesional' => $profesional,
        ], 201);
    }

    public function update(Request $request, int $id)
    {
        $profesional = Profesional::find($id);

        if (! $profesional) {
            return response()->json([
                'success' => false,
                'mensaje' => '❌ Profesional no encontrado',
            ], 404);
        }

        $data = $request->validate([
            'nombre' => ['required', 'string', 'max:150'],
            'correo' => [
                'nullable',
                'email',
                'max:150',
                Rule::unique('profesionales', 'correo')->ignore($profesional->id),
            ],
            'telefono' => ['nullable', 'string', 'max:20'],
            'perfil' => [
                'required',
                Rule::in([
                    'Abogados',
                    'Ajustadores',
                    'Peritos en criminalística',
                    'Valuadores',
                    'Investigadores',
                    'Psicólogos',
                    'Agentes inmobiliarios',
                    'Contadores',
                    'Agentes crediticios',
                    'Asistencia vial',
                ]),
            ],
            'especialidad_id' => ['nullable', 'integer', 'exists:especialidades,id'],
            'ciudad' => ['nullable', 'string', 'max:100'],
            'foto' => ['nullable', 'string', 'max:255'],
            'contrasena' => ['nullable', 'string', 'min:6'],
            'verificado' => ['nullable', 'boolean'],
            'estado' => ['nullable', Rule::in(['disponible', 'ocupado', 'fuera de servicio'])],
            'latitud' => ['nullable', 'numeric'],
            'longitud' => ['nullable', 'numeric'],
        ]);

        $profesional->nombre = $data['nombre'];
        $profesional->telefono = $data['telefono'] ?? null;
        $profesional->perfil = $data['perfil'];
        $profesional->correo = $data['correo'] ?? $profesional->correo;
        $profesional->especialidad_id = $data['especialidad_id'] ?? null;
        $profesional->ciudad = $data['ciudad'] ?? null;
        $profesional->foto = $data['foto'] ?? null;
        $profesional->latitud = $data['latitud'] ?? null;
        $profesional->longitud = $data['longitud'] ?? null;

        if (! empty($data['contrasena'])) {
            $profesional->contrasena = Hash::make($data['contrasena']);
        }

        if (array_key_exists('verificado', $data)) {
            $profesional->verificado = $data['verificado'];
        }

        if (! empty($data['estado'])) {
            $profesional->estado = $data['estado'];
        }

        $profesional->save();

        return response()->json([
            'success' => true,
            'mensaje' => '✅ Profesional actualizado correctamente',
        ]);
    }

    public function destroy(int $id)
    {
        $profesional = Profesional::find($id);

        if (! $profesional) {
            return response()->json([
                'success' => false,
                'mensaje' => '❌ Profesional no encontrado',
            ], 404);
        }

        $profesional->delete();

        return response()->json([
            'success' => true,
            'mensaje' => '✅ Profesional eliminado correctamente',
        ]);
    }
}