<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Ingreso extends Model
{
    protected $table = 'ingresos';

    const CREATED_AT = 'fecha';
    const UPDATED_AT = null;

    protected $fillable = [
        'profesional_id',
        'monto',
        'concepto',
    ];

    protected $casts = [
        'profesional_id' => 'integer',
        'monto' => 'decimal:2',
        'fecha' => 'datetime',
    ];

    public function profesional()
    {
        return $this->belongsTo(Profesional::class, 'profesional_id');
    }
}