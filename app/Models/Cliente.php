<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Cliente extends Model
{
    protected $table = 'clientes';

    protected $fillable = [
        'nombre',
        'correo',
        'contrasena',
        'estado',
        'ultima_conexion',
    ];

    protected $hidden = [
        'contrasena',
    ];

    public $timestamps = false;
}