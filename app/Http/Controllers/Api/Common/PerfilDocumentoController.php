<?php

namespace App\Http\Controllers\Api\Common;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class PerfilDocumentoController extends Controller
{
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'profesional_id' => 'required|integer|exists:profesionales,id',
            'tipo' => 'required|string|max:80',
            'comentarios' => 'nullable|string|max:255',
            'archivo' => 'required|file|mimes:jpg,jpeg,png,webp,pdf|max:10240',
        ], [
            'profesional_id.required' => 'El profesional_id es obligatorio.',
            'profesional_id.exists' => 'El profesional no existe.',
            'tipo.required' => 'El tipo de documento es obligatorio.',
            'archivo.required' => 'Debes seleccionar un archivo.',
            'archivo.file' => 'El archivo no es válido.',
            'archivo.mimes' => 'Solo se permiten jpg, jpeg, png, webp o pdf.',
            'archivo.max' => 'El archivo no debe pesar más de 10 MB.',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Datos inválidos.',
                'errors' => $validator->errors(),
            ], 422);
        }

        $archivo = $request->file('archivo');

        $disk = config('filesystems.default');

        $extension = $archivo->getClientOriginalExtension();
        $nombreArchivo = Str::uuid()->toString() . '.' . $extension;

        $ruta = 'profesionales/documentos/profesional_' .
            $request->profesional_id . '/' .
            $nombreArchivo;

        Storage::disk($disk)->put(
            $ruta,
            file_get_contents($archivo->getRealPath()),
            [
                'visibility' => 'public',
            ]
        );

        $archivoUrl = Storage::disk($disk)->url($ruta);

        /*
         * Tabla esperada: profesional_documentos
         * Este insert está hecho flexible para no romper si tu tabla
         * tiene algunos nombres de columnas diferentes.
         */

        if (!Schema::hasTable('profesional_documentos')) {
            return response()->json([
                'success' => false,
                'message' => 'La tabla profesional_documentos no existe.',
            ], 500);
        }

        $insert = [];

        if (Schema::hasColumn('profesional_documentos', 'profesional_id')) {
            $insert['profesional_id'] = (int) $request->profesional_id;
        }

        if (Schema::hasColumn('profesional_documentos', 'tipo')) {
            $insert['tipo'] = $request->tipo;
        }

        if (Schema::hasColumn('profesional_documentos', 'archivo_url')) {
            $insert['archivo_url'] = $archivoUrl;
        }

        if (Schema::hasColumn('profesional_documentos', 'archivo')) {
            $insert['archivo'] = $archivoUrl;
        }

        if (Schema::hasColumn('profesional_documentos', 'ruta')) {
            $insert['ruta'] = $ruta;
        }

        if (Schema::hasColumn('profesional_documentos', 'comentarios')) {
            $insert['comentarios'] = $request->input('comentarios', '');
        }

        if (Schema::hasColumn('profesional_documentos', 'descripcion')) {
            $insert['descripcion'] = $request->input('comentarios', '');
        }

        if (Schema::hasColumn('profesional_documentos', 'estado')) {
            $insert['estado'] = 'pendiente';
        }

        if (Schema::hasColumn('profesional_documentos', 'created_at')) {
            $insert['created_at'] = now();
        }

        if (Schema::hasColumn('profesional_documentos', 'updated_at')) {
            $insert['updated_at'] = now();
        }

        if (empty($insert)) {
            return response()->json([
                'success' => false,
                'message' => 'No se encontraron columnas compatibles en profesional_documentos.',
            ], 500);
        }

        $id = DB::table('profesional_documentos')->insertGetId($insert);

        $documento = DB::table('profesional_documentos')
            ->where('id', $id)
            ->first();

        return response()->json([
            'success' => true,
            'message' => 'Documento subido correctamente.',
            'data' => $documento,
        ], 201);
    }
}