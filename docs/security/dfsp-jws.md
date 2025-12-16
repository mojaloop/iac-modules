# DFSP JWS

DFSP JWS (JSON Web Signature) certificates are used for signing FSPIOP messages between DFSPs and the Hub.
Proper rotation is critical to maintain secure and uninterrupted message flows.

---

## Propagation

**Automatic propagation flow:**

1. PM4ML Management API through the MCM client automatically initiates a state machine that creates the JWS key
2. The key is uploaded to MCM through the use of its http api
3. MCM client state machine handles the propagation of JWS to peers

---

## Rotation Support

- **Manual rotation:**
  This can be done through the DFSP's PM4ML UI.

- **Automatic rotation:**
  Supported via [mcm-client PR #74](https://github.com/mojaloop/mcm-client/pull/74).
  The DFSP JWS key is rotated automatically by the PM4ML Management API.

---

## Configuration

Customize the rotation interval by setting the `jwsRotationIntervalMs` parameter in the PM4ML Management API state machine configuration.

```yaml
# Example PM4ML Management API config
jwsRotationIntervalMs: 2419200000   # 28 days in milliseconds (default)
```

---

## Rotation Flow

1. The PM4ML Management API monitors the certificate expiry based on the configured interval.
2. When rotation is due, a new JWS key pair is generated for the DFSP.
3. The new public key is registered with the Mojaloop Central Management (MCM) service.
4. MCM distributes the new public key to the Hub and other DFSPs.
5. The DFSP's services are updated to use the new private key.

---

## Failure Scenarios

| Scenario | Impact | Recovery |
|----------|--------|----------|
| PM4ML Management API down during rotation window | JWS key expires, FSPIOP signatures fail | Restore PM4ML Management API, trigger rotation |
| MCM unavailable | Public key not distributed to Hub/DFSPs | Restore MCM, retry key registration |
| DFSP service not updated with new key | Signature validation fails | Restart DFSP service, verify key update |

---

## Security Impact

**If the DFSP JWS certificate expires or rotation fails:**

- FSPIOP message signature validation fails between DFSP and Hub
- Financial transactions are blocked for the DFSP
- Messages from the DFSP are rejected due to invalid signatures

**Risk Level:** HIGH – Ensure monitoring and alerting are in place for key expiry and rotation failures.

---

## Best Practices

- Set the rotation interval to match Hub JWS rotation (28 days recommended).
- Monitor certificate expiry and rotation status.
- Ensure MCM and PM4ML Management API are highly available.
- Document manual recovery steps for key rotation failures.

---

## Monitoring DFSP JWS Key Health

The only supported method to monitor the health and status of DFSP JWS keys is via the `dfsps-statuses-mcm-api` dashboard.
This dashboard provides real-time insights into key validity, expiry dates, and rotation status for all DFSPs.

**Recommendation:**
Regularly review the Grafana dashboard to ensure all DFSP JWS keys are valid and rotation is occurring as expected.
Set up alerts for key expiry or rotation failures.
