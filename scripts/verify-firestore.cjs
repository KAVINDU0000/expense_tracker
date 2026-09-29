// Creates a temporary account and expense, verifies access, then removes both.
const fs = require('node:fs');
const { randomUUID } = require('node:crypto');
const key = fs.readFileSync('lib/firebase_options.dart', 'utf8').match(/apiKey: '([^']+)'/)[1];
const authBase = 'https://identitytoolkit.googleapis.com/v1/accounts:';
async function request(url, method, body, token) {
  const response = await fetch(url, {
    method,
    headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  const data = await response.json();
  if (!response.ok) throw new Error(`${method} failed (${response.status}): ${data.error?.message}`);
  return data;
}
async function main() {
  const account = await request(`${authBase}signUp?key=${key}`, 'POST', {
    email: `expense-test-${randomUUID()}@example.com`, password: randomUUID(), returnSecureToken: true,
  });
  const root = 'https://firestore.googleapis.com/v1/projects/newproject-476f2/databases/(default)/documents';
  const document = `${root}/users/${account.localId}/expenses/verification`;
  let created = false;
  try {
    const fields = {title: {stringValue: 'Temporary verification'}, amount: {doubleValue: 12.5}, category: {stringValue: 'Food'}, date: {timestampValue: new Date().toISOString()}, note: {stringValue: ''}};
    await request(document, 'PATCH', {fields}, account.idToken);
    created = true;
    const saved = await request(document, 'GET', undefined, account.idToken);
    if (saved.fields.amount.doubleValue !== 12.5) throw new Error('Saved amount differs');
    fields.amount.doubleValue = 20;
    await request(document, 'PATCH', {fields}, account.idToken);
    const updated = await request(document, 'GET', undefined, account.idToken);
    if (updated.fields.amount.doubleValue !== 20) throw new Error('Updated amount differs');
    const query = await request(`${root}/users/${account.localId}:runQuery`, 'POST', {structuredQuery: {from: [{collectionId: 'expenses'}], orderBy: [{field: {fieldPath: 'date'}, direction: 'DESCENDING'}]}}, account.idToken);
    if (!query.some(row => row.document)) throw new Error('Expense list is empty');
    const denied = await fetch(`${root}/users/another-user/expenses`, {headers: {Authorization: `Bearer ${account.idToken}`}});
    if (denied.status !== 403) throw new Error('Cross-user access was not denied');
    console.log('PASS: create, read, update, ordered list, and cross-user access protection.');
  } finally {
    if (created) await request(document, 'DELETE', undefined, account.idToken);
    await request(`${authBase}delete?key=${key}`, 'POST', {idToken: account.idToken});
    console.log('Removed temporary expense and account.');
  }
}
main().catch(e => { console.error(e.message); process.exitCode = 1; });
