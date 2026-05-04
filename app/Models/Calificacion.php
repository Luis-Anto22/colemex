<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Calificacion extends Model
{
    protected $table = 'calificaciones';

    const CREATED_AT = 'fecha';
    const UPDATED_AT = null;

    protected $fillable = [
        'profesional_id',
        'cliente_id',
        'estrellas',
        'comentario',
    ];

    protected $casts = [
        'profesional_id' => 'integer',
        'cliente_id' => 'integer',
        'estrellas' => 'integer',
        'fecha' => 'datetime',
    ];

    public function profesional()
    {
        return $this->belongsTo(Profesional::class, 'profesional_id');
    }

    public function cliente()
    {
        return $this->belongsTo(Cliente::class, 'cliente_id');
    }
}