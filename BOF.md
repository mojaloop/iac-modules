# Business Operations Framework (BOF) Integration in IaC

The Business Operations Framework (BOF) is utilized for securing backend APIs with authentication and authorization and providing login & logout flows for frontend applications in both mojaloop switch and DFSP (PM4ML) deployments.

## Overview of Business Operations Framework (BOF)

The Business Operations Framework assists Hub Operators / DFSPs in building and deploying business process portals that align with Mojaloop business documentation. It fosters community collaboration in developing a user experience (UX) for Mojaloop Hub Operators / DFSPs, featuring robust APIs, adhering to best practices, and prioritizing security. This aims to bolster adoption and enhance the out-of-the-box value of the Mojaloop solution.


Configuring best practice security involves three levels of control:

1. Access to IAM user interfaces where users are created, suspended, and their roles assigned.
2. Mappings of roles to permissions, which can be edited through a configuration change request.
3. Restrictions on API access based on permissions available to a subject (a user or API client) through their roles.

For more information, refer to the [Mojaloop Hub Operations Framework Documentation](https://mojaloop.github.io/business-operations-framework-docs/).

## Components involved

Here's a breakdown of the components and their respective roles:

| Service                   | Owns                        | Implements                                                                 |
|---------------------------|-----------------------------|----------------------------------------------------------------------------|
| **Keycloak**              | Users                       | 1. User login redirection and UI for token creation<br>2. Standard OIDC authorization code flow |
| **Ory Keto**              | Roles, Participants (Switch deployment) | 1. API RBAC authorization via Ory Oathkeeper<br>2. Backend API call for RBAC authorization |
| **Ory Oathkeeper**        | Permissions related to API access | Decision API for backend APIs with authentication and authorization checks |
| **Ory Kratos**            | User Sessions               | Login and Logout UI flows using cookies |
| **Role-Permission Operator** | -                         | 1. Updates Keto reflecting role-permission assignment changes made in the K8S role custom resource<br>2. Provides na internal API for assigning roles to users |
| **Kubernetes Role Custom Resource** | Roles, Role-Permission assignments | Controlled edits via version control (e.g., GitLab) |
| **Roles Assignment API Service**   | -                      | 1. Role-user API controls<br>2. Participant-user API controls<br>3. Automatic role assignment (`manager` role) to portal_admin users |


## Various Portals Available

### Switch Deployment

- **Finance Portal**
  - https://**finance-portal**.<DOMAIN> (eg: https://finance-portal.example.com)
  - Used by Hub Operators to manage participants, view transfers, perform settlement tasks, and manage user roles.

- **Connection Manager**
  - https://**mcm**.<DOMAIN> (eg: https://mcm.example.com)
  - Used by Hub Operators to onboard participants.

- **Keycloak Admin Console**
  - https://**keycloak**.<DOMAIN> (eg: https://keycloak.example.com)
  - Used by Hub Operators to manage users.


### Payment Manager Deployment

- **PM4ML Portal**
  - https://**portal-<DFSPID>**.<DOMAIN> - (eg: https://portal-DFSP1.example.com)
  - Used by DFSPs to view transfers.

- **Admin Portal**
  - https://**admin-portal-<DFSPID>**.<DOMAIN> (eg: https://admin-portal-DFSP1.example.com)
  - Used by DFSPs to manage user roles. Since there is no finance portal in PM4ML deployment, the admin portal is used to manage the roles of the users.

- **Keycloak Admin Console**
  - https://**keycloak**.<DOMAIN> (eg: https://keycloak.example.com)
  - Used by DFSPs to manage users.


### User Creation

Users can be created via the Keycloak admin console with appropriate privileges.

### Role Assignment

Users with `manager` role can assign roles by logging into the finance portal (Switch deployments) or admin portal (PM4ML deployments). The default `portal_admin` user is provided with `manager` role for initial role assignments. The password for the `portal_admin` user can be seen in Vault.

### Roles and Permissions

New roles or permissions can be created/modified by editing `mojaloop-rbac-permissions.yaml` (Switch deployments) or `pm4ml-rbac-permissions.yaml` (PM4ML deployments). Changes are controlled via version control (e.g., GitLab), the changes to these files are reflected as a new version of the custom resource in the Kubernetes cluster. And the Role-Permission Operator updates Ory Keto accordingly.


### Protecting Backend Endpoints and Enforcing Permissions

Protect backend endpoints by assigning required permissions to roles and users. Ory Oathkeeper enforces these permissions. Configure backend APIs in `mojaloop-rbac-api-resources.yaml` to check user permissions. Changes are managed via version control, and Ory Oathkeeper updates its rules accordingly.

