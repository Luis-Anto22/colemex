<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Caso extends Model
{
    protected $table = 'casos';

    const CREATED_AT = 'fecha_creacion';
    const UPDATED_AT = null;

    protected $fillable = [
        'profesional_id',
        'cliente_id',
        'servicio',
        'titulo',
        'descripcion',
        'estado',
    ];

    public function profesional()
    {
        return $this->belongsTo(Profesional::class, 'profesional_id');
    }

    public function cliente()
    {
        return $this->belongsTo(Cliente::class, 'cliente_id');
    }

    public function bitacoras()
    {
        return $this->hasMany(CasoBitacora::class, 'caso_id');
    }
}