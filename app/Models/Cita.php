<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Cita extends Model
{
    public const ESTADO_PENDIENTE = 'pendiente';
    public const ESTADO_CONFIRMADA = 'confirmada';
    public const ESTADO_CANCELADA = 'cancelada';
    public const ESTADO_COMPLETADA = 'completada';
    public const ESTADO_NO_ASISTIO = 'no_asistio';

    public const TIPO_PRESENCIAL = 'presencial';
    public const TIPO_VIRTUAL = 'virtual';
    public const TIPO_TELEFONICA = 'telefonica';

    protected $table = 'citas';

    protected $fillable = [
        'profesional_id',
        'cliente_id',
        'titulo',
        'motivo',
        'fecha_cita',
        'fin',
        'estado',
        'tipo',
        'ubicacion',
        'enlace_reunion',
        'notas',
        'creada_por',
        'cancelada_por',
        'motivo_cancelacion',
        'fecha_cancelacion',
    ];

    protected $casts = [
        'fecha_cita' => 'datetime',
        'fin' => 'datetime',
        'fecha_cancelacion' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    public function cliente(): BelongsTo
    {
        return $this->belongsTo(Cliente::class, 'cliente_id');
    }

    public function profesional(): BelongsTo
    {
        return $this->belongsTo(Profesional::class, 'profesional_id');
    }
}