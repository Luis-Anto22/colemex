<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CasoBitacora extends Model
{
    protected $table = 'caso_bitacora';

    const CREATED_AT = 'creado_en';
    const UPDATED_AT = null;

    protected $fillable = [
        'caso_id',
        'profesional_id',
        'nota',
        'estado',
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