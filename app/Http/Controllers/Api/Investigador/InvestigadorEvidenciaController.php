<?php

namespace App\Http\Controllers\Api\Investigador;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class InvestigadorEvidenciaController extends Controller
{
    /**
     * GET /api/investigador/evidencias?caso_id=1
     */
    public function index(Request $request)
    {
        $query = DB::table('caso_archivos')
            ->where('categoria', 'foto')
            ->orderByDesc('id');

        if ($request->filled('caso_id')) {
            $query->where('caso_id', $request->caso_id);
        }

        if ($request->filled('profesional_id')) {
            $query->where('profesional_id', $request->profesional_id);
        }

        if ($request->filled('investigador_id')) {
            $query->where('profesional_id', $request->investigador_id);
        }

        $evidencias = $query->get();

        return response()->json([
            'success' => true,
            'data' => $evidencias,
        ]);
    }

    /**
     * POST /api/investigador/evidencias
     *
     * Enviar como multipart/form-data:
     * - caso_id
     * - profesional_id o investigador_id
     * - descripcion
     * - archivo
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'caso_id' => 'required|integer|exists:casos,id',
            'profesional_id' => 'nullable|integer|exists:profesionales,id',
            'investigador_id' => 'nullable|integer|exists:profesionales,id',
            'descripcion' => 'nullable|string|max:200',
            'archivo' => 'required|file|mimes:jpg,jpeg,png,webp|max:10240',
        ], [
            'caso_id.required' => 'El caso_id es obligatorio.',
            'caso_id.exists' => 'El caso seleccionado no existe.',
            'profesional_id.exists' => 'El profesional seleccionado no existe.',
            'investigador_id.exists' => 'El investigador seleccionado no existe.',
            'archivo.required' => 'Debes seleccionar una imagen.',
            'archivo.file' => 'El archivo no es válido.',
            'archivo.mimes' => 'La evidencia debe ser una imagen jpg, jpeg, png o webp.',
            'archivo.max' => 'La imagen no debe pesar más de 10 MB.',
            'descripcion.max' => 'La descripción no debe pasar de 200 caracteres.',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Datos inválidos.',
                'errors' => $validator->errors(),
            ], 422);
        }

        $profesionalId = $request->input('profesional_id') ?? $request->input('investigador_id');

        if (!$profesionalId) {
            return response()->json([
                'success' => false,
                'message' => 'El profesional_id o investigador_id es obligatorio.',
            ], 422);
        }

        $archivo = $request->file('archivo');

        /*
         * IMPORTANTE:
         * Si en tu .env ya pusiste FILESYSTEM_DISK=s3, déjalo así.
         * Si tu disco de objetos tiene otro nombre, cambia esta línea:
         *
         * $disk = 's3';
         */
        $disk = config('filesystems.default');

        $extension = $archivo->getClientOriginalExtension();

        $nombreArchivo = Str::uuid()->toString() . '.' . $extension;

        $ruta = 'investigador/evidencias/caso_' . $request->caso_id . '/' . $nombreArchivo;

        Storage::disk($disk)->put($ruta, file_get_contents($archivo->getRealPath()), [
            'visibility' => 'public',
        ]);

        $archivoUrl = Storage::disk($disk)->url($ruta);

        $id = DB::table('caso_archivos')->insertGetId([
            'caso_id' => (int) $request->caso_id,
            'profesional_id' => (int) $profesionalId,
            'categoria' => 'foto',
            'tipo' => 'imagen',
            'archivo_url' => $archivoUrl,
            'descripcion' => $request->input('descripcion', ''),
            'creado_en' => now(),
        ]);

        $evidencia = DB::table('caso_archivos')->where('id', $id)->first();

        return response()->json([
            'success' => true,
            'message' => 'Evidencia fotográfica subida correctamente.',
            'data' => $evidencia,
        ], 201);
    }

    /**
     * GET /api/investigador/evidencias/{id}
     */
    public function show($id)
    {
        $evidencia = DB::table('caso_archivos')
            ->where('id', $id)
            ->where('categoria', 'foto')
            ->first();

        if (!$evidencia) {
            return response()->json([
                'success' => false,
                'message' => 'Evidencia no encontrada.',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $evidencia,
        ]);
    }

    /**
     * DELETE /api/investigador/evidencias/{id}
     */
    public function destroy($id)
    {
        $evidencia = DB::table('caso_archivos')
            ->where('id', $id)
            ->where('categoria', 'foto')
            ->first();

        if (!$evidencia) {
            return response()->json([
                'success' => false,
                'message' => 'Evidencia no encontrada.',
            ], 404);
        }

        $disk = config('filesystems.default');

        $ruta = $this->obtenerRutaDesdeUrl($evidencia->archivo_url);

        if ($ruta) {
            try {
                Storage::disk($disk)->delete($ruta);
            } catch (\Throwable $e) {
                // Si falla borrar del servidor de objetos,
                // no detenemos la eliminación del registro.
            }
        }

        DB::table('caso_archivos')->where('id', $id)->delete();

        return response()->json([
            'success' => true,
            'message' => 'Evidencia eliminada correctamente.',
        ]);
    }

    private function obtenerRutaDesdeUrl(?string $url): ?string
    {
        if (!$url) {
            return null;
        }

        $path = parse_url($url, PHP_URL_PATH);

        if (!$path) {
            return null;
        }

        $path = ltrim($path, '/');

        /*
         * Si tu URL viene así:
         * https://bucket.region.provider.com/investigador/evidencias/caso_1/foto.jpg
         * esto devuelve:
         * investigador/evidencias/caso_1/foto.jpg
         *
         * Si tu proveedor agrega el bucket en la URL:
         * bucket/investigador/evidencias/...
         * quizá haya que ajustar esta parte después.
         */
        $pos = strpos($path, 'investigador/evidencias/');

        if ($pos !== false) {
            return substr($path, $pos);
        }

        return $path;
    }
}