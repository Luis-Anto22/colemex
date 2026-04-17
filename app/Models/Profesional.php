<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Profesional extends Model
{
    protected $table = 'profesionales';

    const CREATED_AT = 'fecha_registro';
    const UPDATED_AT = null;

    protected $fillable = [
        'nombre',
        'correo',
        'telefono',
        'contrasena',
        'perfil',
        'especialidad_id',
        'ciudad',
        'foto',
        'verificado',
        'estado',
        'latitud',
        'longitud',
    ];

    protected $hidden = [
        'contrasena',
    ];

    public function especialidad()
    {
        return $this->belongsTo(Especialidad::class, 'especialidad_id');
    }
}