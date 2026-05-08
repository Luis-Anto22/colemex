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
use App\Http\Controllers\Api\Common\PerfilController;
use App\Http\Controllers\Api\Common\ConfiguracionController;
use App\Http\Controllers\Api\Common\UbicacionController;
use App\Http\Controllers\Api\Psicologos\PacientePsicologoController;
use App\Http\Controllers\Api\Psicologos\ExpedienteClinicoController;
use App\Http\Controllers\Api\Psicologos\SesionPsicologicaController;
use App\Http\Controllers\Api\Psicologos\ReportePsicologicoController;
use App\Http\Controllers\Api\Valuador\ValuadorSolicitudController;
use App\Http\Controllers\Api\Valuador\ValuadorAvaluoController;
use App\Http\Controllers\Api\Ajustadores\SiniestroController;
use App\Http\Controllers\Api\Ajustadores\SiniestroParteController;
use App\Http\Controllers\Api\Ajustadores\SiniestroTerceroController;
use App\Http\Controllers\Api\Common\IngresoController;
use App\Http\Controllers\Api\Common\CalificacionController;
use App\Http\Controllers\Api\Valuador\ReporteValuadorController;
use App\Http\Controllers\Api\Investigador\InvestigadorCasoController;
use App\Http\Controllers\Api\Investigador\InvestigadorBitacoraController;
use App\Http\Controllers\Api\Investigador\InvestigadorEvidenciaController;
use App\Http\Controllers\Api\Common\PerfilDocumentoController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

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
    Route::post('/{id}/estado', [CitaController::class, 'updateEstado']);
});

Route::prefix('notificaciones')->group(function () {
    Route::get('/', [NotificacionController::class, 'index']);
    Route::get('/count', [NotificacionController::class, 'countNoLeidas']);
    Route::post('/{id}/leer', [NotificacionController::class, 'marcarLeida']);
    Route::post('/leer-todas', [NotificacionController::class, 'marcarTodasLeidas']);
});

Route::prefix('psicologos')->group(function () {
    Route::get('/pacientes', [PacientePsicologoController::class, 'index']);
    Route::post('/pacientes', [PacientePsicologoController::class, 'store']);
    Route::get('/pacientes/{id}', [PacientePsicologoController::class, 'show']);
    Route::put('/pacientes/{id}', [PacientePsicologoController::class, 'update']);
    Route::delete('/pacientes/{id}', [PacientePsicologoController::class, 'destroy']);

    Route::get('/expedientes', [ExpedienteClinicoController::class, 'index']);
    Route::post('/expedientes', [ExpedienteClinicoController::class, 'store']);
    Route::get('/expedientes/{id}', [ExpedienteClinicoController::class, 'show']);
    Route::put('/expedientes/{id}', [ExpedienteClinicoController::class, 'update']);
    Route::delete('/expedientes/{id}', [ExpedienteClinicoController::class, 'destroy']);

    Route::get('/sesiones', [SesionPsicologicaController::class, 'index']);
    Route::post('/sesiones', [SesionPsicologicaController::class, 'store']);
    Route::get('/sesiones/{id}', [SesionPsicologicaController::class, 'show']);
    Route::put('/sesiones/{id}', [SesionPsicologicaController::class, 'update']);
    Route::delete('/sesiones/{id}', [SesionPsicologicaController::class, 'destroy']);

    Route::get('/evaluaciones', [SesionPsicologicaController::class, 'evaluaciones']);
    Route::get('/tareas', [SesionPsicologicaController::class, 'tareas']);
    Route::get('/seguimientos', [SesionPsicologicaController::class, 'seguimientos']);

    Route::get('/reportes', [ReportePsicologicoController::class, 'index']);
    Route::post('/reportes', [ReportePsicologicoController::class, 'store']);
    Route::get('/reportes/{id}', [ReportePsicologicoController::class, 'show']);
    Route::put('/reportes/{id}', [ReportePsicologicoController::class, 'update']);
    Route::delete('/reportes/{id}', [ReportePsicologicoController::class, 'destroy']);
});

Route::prefix('common')->group(function () {
    Route::get('/perfil', [PerfilController::class, 'show']);

    Route::get('/configuracion', [ConfiguracionController::class, 'show']);
    Route::post('/configuracion', [ConfiguracionController::class, 'update']);

    Route::get('/ubicacion', [UbicacionController::class, 'show']);
    Route::post('/ubicacion', [UbicacionController::class, 'update']);

    Route::get('/ingresos', [IngresoController::class, 'index']);

    Route::get('/calificaciones', [CalificacionController::class, 'index']);
    Route::post('/calificaciones', [CalificacionController::class, 'store']);

    Route::post('/perfil-documentos', [PerfilDocumentoController::class, 'store']);


});

Route::prefix('valuador')->group(function () {
    Route::get('/solicitudes', [ValuadorSolicitudController::class, 'index']);
    Route::post('/solicitudes/{id}/estado', [ValuadorSolicitudController::class, 'updateEstado']);

    Route::get('/avaluos', [ValuadorAvaluoController::class, 'index']);
    Route::post('/avaluos', [ValuadorAvaluoController::class, 'store']);

    Route::get('/reportes', [ReporteValuadorController::class, 'index']);
    Route::post('/reportes', [ReporteValuadorController::class, 'store']);
});

Route::prefix('ajustadores')->group(function () {
    // ==========================
    // SINIESTROS
    // ==========================
    Route::get('/siniestros', [SiniestroController::class, 'index']);
    Route::post('/siniestros', [SiniestroController::class, 'store']);
    Route::get('/siniestros/{id}', [SiniestroController::class, 'show']);
    Route::put('/siniestros/{id}', [SiniestroController::class, 'update']);
    Route::delete('/siniestros/{id}', [SiniestroController::class, 'destroy']);
    Route::put('/siniestros/{id}/estado', [SiniestroController::class, 'cambiarEstado']);
    Route::post('/siniestros/{id}/estado', [SiniestroController::class, 'cambiarEstado']);

    // ==========================
    // PARTES DEL SINIESTRO
    // inspeccion, poliza, danos,
    // dictamen, seguimiento, bitacora
    // ==========================
    Route::get('/partes', [SiniestroParteController::class, 'index']);
    Route::post('/partes', [SiniestroParteController::class, 'store']);
    Route::get('/partes/{id}', [SiniestroParteController::class, 'show']);
    Route::put('/partes/{id}', [SiniestroParteController::class, 'update']);
    Route::delete('/partes/{id}', [SiniestroParteController::class, 'destroy']);
    Route::get('/partes/tipo/{tipo}', [SiniestroParteController::class, 'porTipo']);

    // ==========================
    // TERCEROS INVOLUCRADOS
    // ==========================
    Route::get('/terceros', [SiniestroTerceroController::class, 'index']);
    Route::post('/terceros', [SiniestroTerceroController::class, 'store']);
    Route::get('/terceros/{id}', [SiniestroTerceroController::class, 'show']);
    Route::put('/terceros/{id}', [SiniestroTerceroController::class, 'update']);
    Route::delete('/terceros/{id}', [SiniestroTerceroController::class, 'destroy']);
    Route::get('/siniestros/{siniestroId}/terceros', [SiniestroTerceroController::class, 'porSiniestro']);
});

Route::prefix('investigador')->group(function () {
    Route::get('/casos', [InvestigadorCasoController::class, 'index']);
    Route::post('/casos', [InvestigadorCasoController::class, 'store']);
    Route::post('/casos/estado', [InvestigadorCasoController::class, 'updateEstado']);

    Route::get('/bitacora', [InvestigadorBitacoraController::class, 'index']);
    Route::post('/bitacora', [InvestigadorBitacoraController::class, 'store']);

    Route::get('/evidencias', [InvestigadorEvidenciaController::class, 'index']);
    Route::post('/evidencias', [InvestigadorEvidenciaController::class, 'store']);
    Route::get('/evidencias/{id}', [InvestigadorEvidenciaController::class, 'show']);
    Route::delete('/evidencias/{id}', [InvestigadorEvidenciaController::class, 'destroy']);
});

Route::post('/test-r2', function (Request $request) {
    if (!$request->hasFile('archivo')) {
        return response()->json([
            'success' => false,
            'message' => 'No se envió archivo',
        ], 400);
    }

    $path = Storage::disk('r2')->putFile(
        'pruebas',
        $request->file('archivo')
    );

    return response()->json([
        'success' => true,
        'message' => 'Archivo subido a R2 correctamente',
        'path' => $path,
    ]);
});