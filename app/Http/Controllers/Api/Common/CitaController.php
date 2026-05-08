<?php

namespace App\Http\Controllers\Api\Common;

use App\Http\Controllers\Controller;
use App\Models\Cita;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class CitaController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $profesionalId = (int) $request->query('profesional_id', 0);

        if ($profesionalId <= 0) {
            return response()->json([
                'success' => false,
                'message' => 'profesional_id requerido',
            ], 400);
        }

        $citas = Cita::query()
            ->with([
                'cliente:id,nombre,correo,telefono',
                'profesional:id,nombre,correo,telefono,perfil',
            ])
            ->where('profesional_id', $profesionalId)
            ->orderByDesc('fecha_cita')
            ->orderByDesc('id')
            ->limit(200)
            ->get();

        $data = $citas->map(function (Cita $cita) {
            return [
                'id' => $cita->id,
                'profesional_id' => $cita->profesional_id,
                'cliente_id' => $cita->cliente_id,
                'titulo' => $cita->titulo,
                'motivo' => $cita->motivo,
                'inicio' => optional($cita->fecha_cita)?->format('Y-m-d H:i:s'),
                'fin' => optional($cita->fin)?->format('Y-m-d H:i:s'),
                'estado' => $cita->estado,
                'tipo' => $cita->tipo,
                'ubicacion' => $cita->ubicacion,
                'enlace_reunion' => $cita->enlace_reunion,
                'notas' => $cita->notas,
                'creada_por' => $cita->creada_por,
                'cancelada_por' => $cita->cancelada_por,
                'motivo_cancelacion' => $cita->motivo_cancelacion,
                'fecha_cancelacion' => optional($cita->fecha_cancelacion)?->format('Y-m-d H:i:s'),
                'created_at' => optional($cita->created_at)?->format('Y-m-d H:i:s'),
                'updated_at' => optional($cita->updated_at)?->format('Y-m-d H:i:s'),
                'cliente_nombre' => $cita->cliente?->nombre,
                'profesional_nombre' => $cita->profesional?->nombre,
            ];
        })->values();

        return response()->json([
            'success' => true,
            'data' => $data,
        ], 200);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'profesional_id' => ['required', 'integer', 'min:1'],
            'cliente_id' => ['required', 'integer', 'min:1'],
            'titulo' => ['nullable', 'string', 'max:150'],
            'motivo' => ['nullable', 'string'],
            'inicio' => ['required', 'date_format:Y-m-d H:i:s'],
            'fin' => ['nullable', 'date_format:Y-m-d H:i:s'],
            'estado' => [
                'nullable',
                Rule::in([
                    Cita::ESTADO_PENDIENTE,
                    Cita::ESTADO_CONFIRMADA,
                    Cita::ESTADO_CANCELADA,
                    Cita::ESTADO_COMPLETADA,
                    Cita::ESTADO_NO_ASISTIO,
                ]),
            ],
            'tipo' => [
                'nullable',
                Rule::in([
                    Cita::TIPO_PRESENCIAL,
                    Cita::TIPO_VIRTUAL,
                    Cita::TIPO_TELEFONICA,
                ]),
            ],
            'ubicacion' => ['nullable', 'string', 'max:255'],
            'enlace_reunion' => ['nullable', 'string', 'max:255'],
            'notas' => ['nullable', 'string'],
            'creada_por' => ['nullable', Rule::in(['cliente', 'profesional', 'admin'])],
        ]);

        $cita = Cita::create([
            'profesional_id' => (int) $validated['profesional_id'],
            'cliente_id' => (int) $validated['cliente_id'],
            'titulo' => $validated['titulo'] ?? null,
            'motivo' => $validated['motivo'] ?? null,
            'fecha_cita' => $validated['inicio'],
            'fin' => $validated['fin'] ?? null,
            'estado' => $validated['estado'] ?? Cita::ESTADO_PENDIENTE,
            'tipo' => $validated['tipo'] ?? Cita::TIPO_PRESENCIAL,
            'ubicacion' => $validated['ubicacion'] ?? null,
            'enlace_reunion' => $validated['enlace_reunion'] ?? null,
            'notas' => $validated['notas'] ?? null,
            'creada_por' => $validated['creada_por'] ?? 'profesional',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Cita creada',
            'data' => ['id' => $cita->id],
        ], 201);
    }

    public function show(int $id): JsonResponse
    {
        $cita = Cita::query()
            ->with([
                'cliente:id,nombre,correo,telefono',
                'profesional:id,nombre,correo,telefono,perfil',
            ])
            ->find($id);

        if (! $cita) {
            return response()->json([
                'success' => false,
                'message' => 'Cita no encontrada',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $cita,
        ], 200);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $cita = Cita::find($id);

        if (! $cita) {
            return response()->json([
                'success' => false,
                'message' => 'Cita no encontrada',
            ], 404);
        }

        $validated = $request->validate([
            'titulo' => ['nullable', 'string', 'max:150'],
            'motivo' => ['nullable', 'string'],
            'inicio' => ['nullable', 'date_format:Y-m-d H:i:s'],
            'fin' => ['nullable', 'date_format:Y-m-d H:i:s'],
            'estado' => [
                'nullable',
                Rule::in([
                    Cita::ESTADO_PENDIENTE,
                    Cita::ESTADO_CONFIRMADA,
                    Cita::ESTADO_CANCELADA,
                    Cita::ESTADO_COMPLETADA,
                    Cita::ESTADO_NO_ASISTIO,
                ]),
            ],
            'tipo' => [
                'nullable',
                Rule::in([
                    Cita::TIPO_PRESENCIAL,
                    Cita::TIPO_VIRTUAL,
                    Cita::TIPO_TELEFONICA,
                ]),
            ],
            'ubicacion' => ['nullable', 'string', 'max:255'],
            'enlace_reunion' => ['nullable', 'string', 'max:255'],
            'notas' => ['nullable', 'string'],
            'cancelada_por' => ['nullable', Rule::in(['cliente', 'profesional', 'admin'])],
            'motivo_cancelacion' => ['nullable', 'string'],
            'fecha_cancelacion' => ['nullable', 'date_format:Y-m-d H:i:s'],
        ]);

        if (array_key_exists('titulo', $validated)) $cita->titulo = $validated['titulo'];
        if (array_key_exists('motivo', $validated)) $cita->motivo = $validated['motivo'];
        if (array_key_exists('inicio', $validated)) $cita->fecha_cita = $validated['inicio'];
        if (array_key_exists('fin', $validated)) $cita->fin = $validated['fin'];
        if (array_key_exists('estado', $validated)) $cita->estado = $validated['estado'];
        if (array_key_exists('tipo', $validated)) $cita->tipo = $validated['tipo'];
        if (array_key_exists('ubicacion', $validated)) $cita->ubicacion = $validated['ubicacion'];
        if (array_key_exists('enlace_reunion', $validated)) $cita->enlace_reunion = $validated['enlace_reunion'];
        if (array_key_exists('notas', $validated)) $cita->notas = $validated['notas'];
        if (array_key_exists('cancelada_por', $validated)) $cita->cancelada_por = $validated['cancelada_por'];
        if (array_key_exists('motivo_cancelacion', $validated)) $cita->motivo_cancelacion = $validated['motivo_cancelacion'];
        if (array_key_exists('fecha_cancelacion', $validated)) $cita->fecha_cancelacion = $validated['fecha_cancelacion'];

        $cita->save();

        return response()->json([
            'success' => true,
            'message' => 'Cita actualizada',
            'data' => ['id' => $cita->id],
        ], 200);
    }

    public function destroy(int $id): JsonResponse
    {
        $cita = Cita::find($id);

        if (! $cita) {
            return response()->json([
                'success' => false,
                'message' => 'Cita no encontrada',
            ], 404);
        }

        $cita->delete();

        return response()->json([
            'success' => true,
            'message' => 'Cita eliminada',
        ], 200);
    }

    public function updateEstado(Request $request, int $id): JsonResponse
{
    $cita = Cita::find($id);

    if (! $cita) {
        return response()->json([
            'success' => false,
            'message' => 'Cita no encontrada',
        ], 404);
    }

    $estadoRecibido = strtolower(trim((string) $request->input('estado', '')));

    $mapEstados = [
        'pendiente' => Cita::ESTADO_PENDIENTE,

        'en proceso' => Cita::ESTADO_CONFIRMADA,
        'en_proceso' => Cita::ESTADO_CONFIRMADA,
        'proceso' => Cita::ESTADO_CONFIRMADA,
        'confirmada' => Cita::ESTADO_CONFIRMADA,
        'confirmado' => Cita::ESTADO_CONFIRMADA,

        'finalizado' => Cita::ESTADO_COMPLETADA,
        'finalizada' => Cita::ESTADO_COMPLETADA,
        'completada' => Cita::ESTADO_COMPLETADA,
        'completado' => Cita::ESTADO_COMPLETADA,

        'cancelado' => Cita::ESTADO_CANCELADA,
        'cancelada' => Cita::ESTADO_CANCELADA,

        'no_asistio' => Cita::ESTADO_NO_ASISTIO,
        'no asistio' => Cita::ESTADO_NO_ASISTIO,
        'no asistió' => Cita::ESTADO_NO_ASISTIO,
    ];

    if (! array_key_exists($estadoRecibido, $mapEstados)) {
        return response()->json([
            'success' => false,
            'message' => 'Estado no válido',
            'errors' => [
                'estado' => ['El estado enviado no es válido.'],
            ],
        ], 422);
    }

    $request->merge([
        'estado' => $mapEstados[$estadoRecibido],
    ]);

    $validated = $request->validate([
        'estado' => [
            'required',
            Rule::in([
                Cita::ESTADO_PENDIENTE,
                Cita::ESTADO_CONFIRMADA,
                Cita::ESTADO_CANCELADA,
                Cita::ESTADO_COMPLETADA,
                Cita::ESTADO_NO_ASISTIO,
            ]),
        ],
        'cancelada_por' => ['nullable', Rule::in(['cliente', 'profesional', 'admin'])],
        'motivo_cancelacion' => ['nullable', 'string'],
        'fecha_cancelacion' => ['nullable', 'date_format:Y-m-d H:i:s'],
    ]);

    $cita->estado = $validated['estado'];

    if ($validated['estado'] === Cita::ESTADO_CANCELADA) {
        $cita->cancelada_por = $validated['cancelada_por'] ?? null;
        $cita->motivo_cancelacion = $validated['motivo_cancelacion'] ?? null;
        $cita->fecha_cancelacion = $validated['fecha_cancelacion'] ?? now();
    }

    $cita->save();

    return response()->json([
        'success' => true,
        'message' => 'Estado actualizado',
        'data' => [
            'id' => $cita->id,
            'estado' => $cita->estado,
        ],
    ], 200);
    }
}

