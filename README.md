### Technical Challenge - Cubos DevOps

### Requirements
  - [Git](https://git-scm.com/downloads)
  - [Docker](https://docs.docker.com/engine/install/)
  - [Terraform](https://developer.hashicorp.com/terraform/install)
  - Terminal Bash

### Configurations
  - Cloning and accessing the repository:
    ```bash
    git clone \
    https://github.com/RenanMMaciel/technical-challenge-cubos-devops.git && \
    cd technical-challenge-cubos-devops/
    ```

  - Make the setup script executable and run the setup script:
    ```bash
    chmod +x ./setup.sh && ./setup.sh
    ```

  - After running the setup script [`setup.sh`](./setup.sh), the following steps will be performed:

    - The script checks if the repository already contains the `.env` file in the [`backend`](./backend) directory.

    - If the `.env` file **exists**, the script will verify whether the required variables are defined:
      - **`POSTGRES_USER`**
      - **`POSTGRES_PASSWORD`**
      - **`POSTGRES_DB`**
      - **`DATABASE_ADMIN_PASSWORD`**

    - If the `.env` file **does not exist** or is missing any of the required variables, the script will:
      - Prompt the user to input the missing variables.
      - Either **create** a new `.env` file in the [`backend`](./backend) directory or **update** the existing one with the missing variables.

  - After that, the infrastructure will be set up, and the [services](#services) will go up.

### Services
- **Frontend**:
  A static web application served by Nginx, configured to act as a reverse proxy to the backend service.  
  **Access URL:** [http://localhost:80](http://localhost:80)

- **Backend**:
  A Node.js application that interacts with the database, exposing an API for the frontend to consume.  
  **Access URL:** [http://localhost:8080/api](http://localhost:8080/api)

- **Database**:
  A PostgreSQL database instance used to store application data, including user credentials and other structured information.  
  **Access:** Accessible internally by backend at `database:5432`. Use `psql` for direct access.

- **Prometheus**:
  A monitoring and alerting toolkit used to scrape and collect metrics from services frontend, backend and database.  
  **Access URL:** [http://localhost:9090](http://localhost:9090)

- **Grafana**:
  A visualization and analytics platform used to create dashboards and analyze metrics collected by Prometheus.  
  **Access URL:** [http://localhost:3000](http://localhost:3000)  

- **Postgres Exporter**:
  A Prometheus exporter used to collect PostgreSQL database metrics, exposing them for Prometheus to scrape.  
  **Access URL:** [http://localhost:9187](http://localhost:9187)

### Networks
- **Internal**:  
  A private network used for communication between backend and database.  
  **Services:** Backend and Database.

- **External**:  
  A public-facing network that connects the frontend service to external clients and allows communication with the backend.  
  **Services:** Frontend and Backend.

- **Monitoring**:  
  A dedicated network for monitoring services like Prometheus and Grafana, ensuring isolation from application traffic.  
  **Services:** Frontend, Backend, Database, Prometheus, Grafana and Postgres Exporter.

### Notes
- The [`setup.sh`](./setup.sh) script is designed to verify the operating system in use and dynamically adjust the `DOCKER_HOST` variable for the Docker provider in the Terraform configuration. This ensures that the correct communication path is used for Docker, depending on the environment.

  - For **Linux** systems, the `DOCKER_HOST` variable is set to `unix:///var/run/docker.sock`.
  - For **Windows** systems, the `DOCKER_HOST` variable is set to `npipe:////./pipe/docker_engine`.

  The adjusted variable is then passed to the Terraform docker provider configuration, ensuring that all Docker-related operations, such as building images and managing containers, are executed correctly on the target OS.

- All containers are configured with a `restart: always` policy to ensure that services automatically restart in case of failure or system reboot.

- Persistent volumes (`database_data` and `database_logs`) ensure data durability across container restarts.

 ### Repository Tree
```plaintext
technical-challenge-cubos-devops/
├── README.md
├── backend
│   ├── Dockerfile
│   ├── index.js
│   └── package.json
├── database
│   └── script.sh
├── frontend
│   ├── Dockerfile
│   ├── index.html
│   └── nginx.conf
├── monitoring
│   ├── grafana
│   │   └── prometheus-datasource.yml
│   └── prometheus
│       └── prometheus.yml
├── setup.sh
└── terraform
    ├── containers.tf
    ├── images.tf
    ├── networks.tf
    ├── providers.tf
    ├── variables.tf
    └── volumes.tf
