#!/usr/bin/env node

const path = require('path');
const toolsRoot = process.env.FIREBASE_TOOLS_ROOT;
if (!toolsRoot) throw new Error('Falta FIREBASE_TOOLS_ROOT.');
const auth = require(path.join(toolsRoot, 'lib', 'auth.js'));
const scopes = require(path.join(toolsRoot, 'lib', 'scopes.js'));

const projectId = 'pawlife-84d14';
const base = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents`;
const userIds = JSON.parse(process.env.PAWLIFE_MIGRATION_UIDS || '[]');
if (!Array.isArray(userIds) || userIds.length === 0) throw new Error('Falta PAWLIFE_MIGRATION_UIDS.');

async function call(token, url, options = {}, allow404 = false) {
  const response = await fetch(url, {
    ...options,
    headers: { authorization: `Bearer ${token}`, 'content-type': 'application/json', ...(options.headers || {}) },
  });
  if (allow404 && response.status === 404) return null;
  if (!response.ok) throw new Error(`${response.status}: ${await response.text()}`);
  return response.status === 204 ? null : response.json();
}

const idOf = (document) => document.name.split('/').pop();
const stringField = (text) => ({ stringValue: text });

async function list(token, collectionPath) {
  const documents = [];
  let pageToken;
  do {
    const query = new URLSearchParams({ pageSize: '300' });
    if (pageToken) query.set('pageToken', pageToken);
    const result = await call(token, `${base}/${collectionPath}?${query}`);
    documents.push(...(result.documents || []));
    pageToken = result.nextPageToken;
  } while (pageToken);
  return documents;
}

async function createIfMissing(token, collection, id, fields) {
  const existing = await call(token, `${base}/${collection}/${encodeURIComponent(id)}`, {}, true);
  if (existing) {
    for (const field of ['userId', 'mascotaId', 'legadoId']) {
      const expected = fields[field]?.stringValue;
      if (expected !== undefined && existing.fields?.[field]?.stringValue !== expected) {
        throw new Error(`Colision en ${collection}/${id}: el campo ${field} pertenece a otro registro.`);
      }
    }
    return false;
  }
  await call(token, `${base}/${collection}?documentId=${encodeURIComponent(id)}`, {
    method: 'POST', body: JSON.stringify({ fields }),
  });
  return true;
}

async function ensureTimezone(token, uid) {
  const user = await call(token, `${base}/users/${uid}`, {}, true);
  if (!user || user.fields?.zonaHoraria) return false;
  await call(token, `${base}/users/${uid}?updateMask.fieldPaths=zonaHoraria&currentDocument.exists=true`, {
    method: 'PATCH', body: JSON.stringify({ fields: { zonaHoraria: stringField('America/Montevideo') } }),
  });
  return true;
}

async function migrateUser(token, uid) {
  const stats = { created: 0, existing: 0, timezoneAdded: false, collections: {} };
  stats.timezoneAdded = await ensureTimezone(token, uid);
  const petMap = new Map();
  const entityMaps = { vacunas: new Map(), medicamentos: new Map() };
  const pets = await list(token, `users/${uid}/mascotas`);

  for (const pet of pets) {
    const oldPetId = idOf(pet);
    const newPetId = `${uid}_${oldPetId}`;
    petMap.set(oldPetId, newPetId);
    const created = await createIfMissing(token, 'mascotas', newPetId, {
      ...pet.fields, userId: stringField(uid), legadoId: stringField(oldPetId),
    });
    stats[created ? 'created' : 'existing']++;
    stats.collections.mascotas = (stats.collections.mascotas || 0) + 1;

    for (const collection of ['vacunas', 'medicamentos', 'alimentaciones', 'pesos', 'paseos']) {
      const children = await list(token, `users/${uid}/mascotas/${oldPetId}/${collection}`);
      for (const child of children) {
        const oldId = idOf(child);
        const preferredId = `${uid}_${oldId}`;
        const preferred = await call(token, `${base}/${collection}/${encodeURIComponent(preferredId)}`, {}, true);
        const newId = preferred && preferred.fields?.mascotaId?.stringValue !== newPetId
          ? `${uid}_${oldPetId}_${oldId}` : preferredId;
        if (entityMaps[collection]) entityMaps[collection].set(`${oldPetId}/${oldId}`, newId);
        const wasCreated = await createIfMissing(token, collection, newId, {
          ...child.fields,
          userId: stringField(uid), mascotaId: stringField(newPetId), legadoId: stringField(oldId),
        });
        stats[wasCreated ? 'created' : 'existing']++;
        stats.collections[collection] = (stats.collections[collection] || 0) + 1;
      }
    }
  }

  for (const reminder of await list(token, `users/${uid}/recordatorios`)) {
    const oldId = idOf(reminder);
    const oldPetId = reminder.fields?.mascotaId?.stringValue;
    const oldEntityId = reminder.fields?.entidadId?.stringValue;
    const fields = { ...reminder.fields, userId: stringField(uid), legadoId: stringField(oldId) };
    if (oldPetId && petMap.has(oldPetId)) fields.mascotaId = stringField(petMap.get(oldPetId));
    if (oldEntityId) {
      const entityCollection = reminder.fields?.tipo?.stringValue === 'vacuna' ? 'vacunas' : 'medicamentos';
      const mapped = entityMaps[entityCollection].get(`${oldPetId}/${oldEntityId}`);
      if (mapped) fields.entidadId = stringField(mapped);
    }
    const created = await createIfMissing(token, 'recordatorios', `${uid}_${oldId}`, fields);
    stats[created ? 'created' : 'existing']++;
    stats.collections.recordatorios = (stats.collections.recordatorios || 0) + 1;
  }

  for (const device of await list(token, `users/${uid}/dispositivos`)) {
    const oldId = idOf(device);
    const fields = { ...device.fields, userId: stringField(uid), legadoId: stringField(oldId) };
    const created = await createIfMissing(token, 'dispositivos', `${uid}_${oldId}`, fields);
    stats[created ? 'created' : 'existing']++;
    stats.collections.dispositivos = (stats.collections.dispositivos || 0) + 1;
  }
  return stats;
}

async function main() {
  const account = auth.getGlobalDefaultAccount();
  if (!account) throw new Error('No hay sesión de Firebase CLI.');
  const tokens = await auth.getAccessToken(account.tokens.refresh_token, [scopes.CLOUD_PLATFORM]);
  const result = {};
  for (const uid of userIds) result[uid] = await migrateUser(tokens.access_token, uid);
  console.log(JSON.stringify({ projectId, result }, null, 2));
}

main().catch((error) => { console.error(error.message); process.exitCode = 1; });
