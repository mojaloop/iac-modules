import { createServer } from 'node:http';

const PORT = process.env.PORT || 8080;
const KRATOS_ADMIN_URL = process.env.KRATOS_ADMIN_URL || 'http://kratos-admin';
const KETO_READ_URL = process.env.KETO_READ_URL || 'http://keto-read';

const getUserRoles = async (userSubject) => {
  try {
    const response = await fetch(`${KETO_READ_URL}/relation-tuples?subject_id=user:${userSubject}&namespace=role&relation=member`);
    if (!response.ok) return ['everyone'];
    
    const { relation_tuples = [] } = await response.json();
    const roles = relation_tuples
      .filter(t => t.object?.startsWith('role:'))
      .map(t => t.object.substring(5));
    
    return [...new Set([...roles, 'everyone'])];
  } catch {
    return ['everyone'];
  }
};

const updateIdentityRoles = async (identityId, userSubject) => {
  try {
    const [roles, identity] = await Promise.all([
      getUserRoles(userSubject),
      fetch(`${KRATOS_ADMIN_URL}/admin/identities/${identityId}`).then(r => r.json())
    ]);
    
    console.log(`User ${userSubject} roles:`, roles);
    
    const response = await fetch(`${KRATOS_ADMIN_URL}/admin/identities/${identityId}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ ...identity, traits: { ...identity.traits, roles } })
    });
    
    return response.ok ? { success: true, roles } : { error: 'Update failed' };
  } catch (error) {
    return { error: error.message };
  }
};

createServer(async (req, res) => {
  const respond = (status, data) => {
    res.writeHead(status, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(data));
  };
  
  if (req.method === 'GET' && req.url === '/health') {
    return respond(200, { status: 'healthy' });
  }
  
  if (req.method === 'POST' && req.url === '/inject-roles') {
    const chunks = [];
    for await (const chunk of req) chunks.push(chunk);
    
    try {
      const { identity_id, user_subject } = JSON.parse(Buffer.concat(chunks));
      if (!identity_id || !user_subject) {
        return respond(400, { error: 'Missing required fields' });
      }
      
      console.log(`Processing: ${user_subject}`);
      const result = await updateIdentityRoles(identity_id, user_subject);
      respond(result.error ? 500 : 200, result);
    } catch (error) {
      respond(500, { error: error.message });
    }
    return;
  }
  
  respond(404, { error: 'Not found' });
}).listen(PORT, () => console.log(`Webhook ready on :${PORT}`)); 