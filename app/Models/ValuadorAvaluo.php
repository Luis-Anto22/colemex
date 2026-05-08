<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ValuadorAvaluo extends Model
{
    protected $table = 'valuador_avaluos';

    const CREATED_AT = 'creado_en';
    const UPDATED_AT = 'actualizado_en';

    protected $fillable = [
        'caso_id',
        'profesional_id',
        'valor_estimado',
        'notas',
    ];

    protected $casts = [
        'caso_id' => 'integer',
        'profesional_id' => 'integer',
        'valor_estimado' => 'decimal:2',
        'creado_en' => 'datetime',
        'actualizado_en' => 'datetime',
    ];

    public function caso()
    {
        return $this->belongsTo(Caso::class, 'caso_id');
    }

    public function profesional()
    {
        return $this->belongsTo(Profesional::class, 'profesional_id');
    }
}