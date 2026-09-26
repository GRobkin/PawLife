#!/usr/bin/env node

/*
 * Carga datos demostrativos idempotentes en Firestore sin guardar credenciales
 * en el repositorio. Usa la sesión ya iniciada de Firebase CLI.
 *
 * Uso:
 *   PAWLIFE_SEED_USERS_JSON='[{"uid":"...","email":"...","nombre":"..."}]' \
 *   FIREBASE_TOOLS_ROOT=/ruta/firebase-tools node tool/seed_firestore.cjs
 */

const path = require('path');

const toolsRoot = process.env.FIREBASE_TOOLS_ROOT;
if (!toolsRoot) throw new Error('Falta FIREBASE_TOOLS_ROOT.');

const auth = require(path.join(toolsRoot, 'lib', 'auth.js'));
const scopes = require(path.join(toolsRoot, 'lib', 'scopes.js'));

const projectId = 'pawlife-84d14';
const database = '(default)';
const base = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/${database}/documents`;
const now = new Date().toISOString();

const users = JSON.parse(process.env.PAWLIFE_SEED_USERS_JSON || '[]');
if (!Array.isArray(users) || users.length === 0) {
  throw new Error('Falta PAWLIFE_SEED_USERS_JSON con al menos un usuario.');
}

function value(input) {
  if (input === null) return { nullValue: null };
  if (typeof input === 'string') return { stringValue: input };
  if (typeof input === 'boolean') return { booleanValue: input };
  if (typeof input === 'number') {
    return Number.isInteger(input) ? { integerValue: String(input) } : { doubleValue: input };
  }
  if (input instanceof Date) return { timestampValue: input.toISOString() };
  if (Array.isArray(input)) return { arrayValue: { values: input.map(value) } };
  const fields = {};
  for (const [key, item] of Object.entries(input)) fields[key] = value(item);
  return { mapValue: { fields } };
}

function fields(data) {
  return Object.fromEntries(Object.entries(data).map(([key, item]) => [key, value(item)]));
}

async function request(token, url, options = {}) {
  const response = await fetch(url, {
    ...options,
    headers: {
      authorization: `Bearer ${token}`,
      'content-type': 'application/json',
      ...(options.headers || {}),
    },
  });
  if (!response.ok) {
    const detail = await response.text();
    throw new Error(`${response.status} ${response.statusText}: ${detail}`);
  }
  return response.status === 204 ? null : response.json();
}

async function getDocument(token, documentPath) {
  const response = await fetch(`${base}/${documentPath}`, {
    headers: { authorization: `Bearer ${token}` },
  });
  if (response.status === 404) return null;
  if (!response.ok) throw new Error(`${response.status}: ${await response.text()}`);
  return response.json();
}

async function createDocumentIfMissing(token, documentPath, data) {
  if (await getDocument(token, documentPath)) return false;
  await request(token, `${base}/${documentPath}?currentDocument.exists=false`, {
    method: 'PATCH',
    body: JSON.stringify({ fields: fields(data) }),
  });
  return true;
}

async function seedUser(token, user) {
  const rootPath = `users/${user.uid}`;
  const current = await getDocument(token, rootPath);
  if (!current) {
    await createDocumentIfMissing(token, rootPath, {
      email: user.email, nombre: user.nombre, fotoUrl: null, premium: false,
      premiumHasta: null, zonaHoraria: 'America/Montevideo',
      creadoEn: new Date(now), actualizadoEn: new Date(now),
    });
  }

  const petId = `${user.uid}_demo-buddy`;
  const vaccineId = `${user.uid}_demo-antirrabica`;
  const medicationId = `${user.uid}_demo-antiparasitario`;
  const owned = { userId: user.uid };
  const care = { userId: user.uid, mascotaId: petId };
  const documents = [
    [`mascotas/${petId}`, {
      ...owned,
      nombre: 'Buddy', especie: 'Perro', raza: 'Golden Retriever',
      fechaNacimiento: new Date('2022-05-14T00:00:00.000Z'), fotoUrl: null,
      notas: 'Mascota de demostración de PawLife.', creadoEn: new Date(now), actualizadoEn: new Date(now),
    }],
    [`vacunas/${vaccineId}`, {
      ...care,
      nombre: 'Antirrábica', fechaAplicacion: new Date('2026-03-10T12:00:00.000Z'),
      proximaFecha: new Date('2027-03-10T12:00:00.000Z'), anticipacionDias: 7,
      creadoEn: new Date(now), actualizadoEn: new Date(now),
    }],
    [`vacunas/${user.uid}_demo-polivalente`, {
      ...care,
      nombre: 'Polivalente', fechaAplicacion: new Date('2025-10-02T12:00:00.000Z'),
      proximaFecha: new Date('2026-10-02T12:00:00.000Z'), anticipacionDias: 5,
      creadoEn: new Date(now), actualizadoEn: new Date(now),
    }],
    [`medicamentos/${medicationId}`, {
      ...care,
      nombre: 'Antiparasitario', dosis: '1 comprimido', horarios: ['09:00', '21:00'],
      fechaInicio: new Date('2026-09-20T09:00:00.000Z'), fechaFin: new Date('2026-09-27T21:00:00.000Z'),
      activo: true, creadoEn: new Date(now), actualizadoEn: new Date(now),
    }],
    [`alimentaciones/${user.uid}_demo-alimentacion`, {
      ...care, tipoAlimento: 'Alimento seco premium', cantidadGramos: 320,
      fechaHora: new Date('2026-09-26T12:30:00.000Z'), notas: 'Ración diaria dividida en dos comidas.',
      creadoEn: new Date(now), actualizadoEn: new Date(now),
    }],
    [`pesos/${user.uid}_demo-peso`, {
      ...care,
      fecha: new Date('2026-09-25T18:00:00.000Z'), valorKg: 28.4,
      creadoEn: new Date(now), actualizadoEn: new Date(now),
    }],
    [`paseos/${user.uid}_demo-paseo`, {
      ...care,
      fechaInicio: new Date('2026-09-25T19:00:00.000Z'), fechaFin: new Date('2026-09-25T19:32:00.000Z'),
      duracionSegundos: 1920, distanciaMetros: 2410.5, velocidadMaximaKmh: 8.7,
      ruta: [
        { lat: -34.9011, lng: -56.1645, timestamp: new Date('2026-09-25T19:00:00.000Z') },
        { lat: -34.9002, lng: -56.1629, timestamp: new Date('2026-09-25T19:12:00.000Z') },
        { lat: -34.8989, lng: -56.1642, timestamp: new Date('2026-09-25T19:24:00.000Z') },
      ], creadoEn: new Date(now), actualizadoEn: new Date(now),
    }],
    [`recordatorios/${user.uid}_demo-vacuna`, {
      ...owned, tipo: 'vacuna', mascotaId: petId, entidadId: vaccineId, fecha: new Date('2026-09-27T12:00:00.000Z'),
      mensaje: 'Revisar próxima vacuna de Buddy', completado: false,
      creadoEn: new Date(now), actualizadoEn: new Date(now),
    }],
    [`recordatorios/${user.uid}_demo-medicamento`, {
      ...owned, tipo: 'medicamento', mascotaId: petId, entidadId: medicationId, fecha: new Date('2026-09-26T21:00:00.000Z'),
      mensaje: 'Dar Antiparasitario a Buddy', completado: false,
      creadoEn: new Date(now), actualizadoEn: new Date(now),
    }],
    [`dispositivos/${user.uid}_demo-inactivo`, {
      ...owned, token: 'disabled_demo_token', plataforma: 'android',
      activo: false, demo: true, creadoEn: new Date(now), actualizadoEn: new Date(now),
    }],
    [`notificaciones/${user.uid}_demo-envio`, {
      ...owned, recordatorioId: `${user.uid}_demo-vacuna`, canal: 'push', estado: 'pendiente',
      programadaPara: new Date('2026-09-27T12:00:00.000Z'), intentos: 0,
      creadoEn: new Date(now), actualizadoEn: new Date(now),
    }],
  ];

  let created = current ? 0 : 1;
  for (const [documentPath, data] of documents) {
    if (await createDocumentIfMissing(token, documentPath, data)) created++;
  }
  return created;
}

async function main() {
  const account = auth.getGlobalDefaultAccount();
  if (!account) throw new Error('No hay una sesión iniciada en Firebase CLI.');
  const tokens = await auth.getAccessToken(account.tokens.refresh_token, [scopes.CLOUD_PLATFORM]);
  let written = 0;
  for (const user of users) written += await seedUser(tokens.access_token, user);

  if (await createDocumentIfMissing(tokens.access_token, 'configuracion/app', {
    zonaHorariaDefault: 'America/Montevideo', diasInactividadPaseo: 3,
    versionEsquema: 2, plataformas: ['android', 'ios', 'web'],
    actualizadoEn: new Date(now),
  })) written++;

  const verification = {};
  for (const collection of ['users', 'mascotas', 'vacunas', 'medicamentos', 'alimentaciones', 'pesos', 'paseos', 'recordatorios', 'dispositivos', 'notificaciones', 'configuracion']) {
    const result = await request(tokens.access_token, `${base}/${collection}?pageSize=100`);
    verification[collection] = (result.documents || []).length;
  }
  console.log(JSON.stringify({ projectId, written, verification }, null, 2));
}

main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
