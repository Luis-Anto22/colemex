<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\Admin\ProfesionalController;
use App\Http\Controllers\Api\Auth\ClienteAuthController;
use App\Http\Controllers\Api\Auth\ProfesionalAuthController;

Route::post('/login/profesional', [ProfesionalAuthController::class, 'login']);
Route::post('/login/cliente', [ClienteAuthController::class, 'login']);

Route::prefix('admin')->group(function () {
    Route::get('/profesionales', [ProfesionalController::class, 'index']);
    Route::post('/profesionales', [ProfesionalController::class, 'store']);
    Route::put('/profesionales/{id}', [ProfesionalController::class, 'update']);
    Route::delete('/profesionales/{id}', [ProfesionalController::class, 'destroy']);
});