<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\Admin\ProfesionalController;
use App\Http\Controllers\Api\Auth\ClienteAuthController;
use App\Http\Controllers\Api\Auth\ProfesionalAuthController;
use App\Http\Controllers\Api\Common\CasoController;
use App\Http\Controllers\Api\Common\CasoBitacoraController;
use App\Http\Controllers\Api\Common\ClienteController;
use App\Http\Controllers\Api\Common\CitaController;
use App\Http\Controllers\Api\Common\NotificacionController;

Route::post('/login/profesional', [ProfesionalAuthController::class, 'login']);
Route::post('/login/cliente', [ClienteAuthController::class, 'login']);

Route::prefix('admin')->group(function () {
    Route::get('/profesionales', [ProfesionalController::class, 'index']);
    Route::post('/profesionales', [ProfesionalController::class, 'store']);
    Route::put('/profesionales/{id}', [ProfesionalController::class, 'update']);
    Route::delete('/profesionales/{id}', [ProfesionalController::class, 'destroy']);
});

Route::prefix('clientes')->group(function () {
    Route::get('/', [ClienteController::class, 'index']);
    Route::get('/activos', [ClienteController::class, 'activos']);
    Route::get('/{id}', [ClienteController::class, 'show']);
});

Route::prefix('casos')->group(function () {
    Route::get('/', [CasoController::class, 'index']);
    Route::get('/mis-casos/{profesionalId}', [CasoController::class, 'misCasos']);
    Route::get('/{id}', [CasoController::class, 'show']);
    Route::post('/', [CasoController::class, 'store']);
    Route::put('/{id}', [CasoController::class, 'update']);
    Route::delete('/{id}', [CasoController::class, 'destroy']);

    Route::get('/{casoId}/bitacora', [CasoBitacoraController::class, 'index']);
    Route::post('/{casoId}/bitacora', [CasoBitacoraController::class, 'store']);
    Route::put('/bitacora/{id}', [CasoBitacoraController::class, 'update']);
    Route::delete('/bitacora/{id}', [CasoBitacoraController::class, 'destroy']);
});

Route::prefix('citas')->group(function () {
    Route::get('/', [CitaController::class, 'index']);
    Route::post('/', [CitaController::class, 'store']);
    Route::get('/{id}', [CitaController::class, 'show']);
    Route::put('/{id}', [CitaController::class, 'update']);
    Route::delete('/{id}', [CitaController::class, 'destroy']);
    Route::put('/{id}/estado', [CitaController::class, 'updateEstado']);
});

Route::prefix('notificaciones')->group(function () {
    Route::get('/', [NotificacionController::class, 'index']);
    Route::get('/count', [NotificacionController::class, 'countNoLeidas']);
    Route::post('/{id}/leer', [NotificacionController::class, 'marcarLeida']);
    Route::post('/leer-todas', [NotificacionController::class, 'marcarTodasLeidas']);
});