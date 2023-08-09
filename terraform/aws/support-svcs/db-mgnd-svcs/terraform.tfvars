databases = {
    centralledger = {
      db_name = "centralledger"
      engine = "mysql"
      engine_version = "5.7"
      instance_class = "db.t2.micro"
      allocated_storage = 5
      storage_encrypted = false
      skip_final_snapshot = true
      username = "userdb"
      port = "3306"
      maintenance_window = "Sun:04:00-Sun:06:00"
      backup_window = "01:00-04:00"
      monitoring_interval = "30"
      family = "mysql5.7"
      major_engine_version = "5.7"
      deletion_protection = false
      parameters = [
        {
        name = "character_set_client"
        value = "utf8mb4"
        },
        {
          name = "character_set_server"
          value = "utf8mb4"
        }
      ]
      options = [
        {
          option_name = "MARIADB_AUDIT_PLUGIN"
          option_settings = [
            {
              name = "SERVER_AUDIT_EVENTS"
              value = "CONNECT"
            },
            {
              name = "SERVER_AUDIT_FILE_ROTATIONS"
              value = "37"
            }
          ]
        }
      ]
      tags = {}
    },
    accountlookup = {
      db_name = "accountlookup"
      engine = "mysql"
      engine_version = "5.7"
      instance_class = "db.t2.micro"
      allocated_storage = 5
      storage_encrypted = false
      skip_final_snapshot = true
      username = "userdb"
      port = "3306"
      maintenance_window = "Sun:04:00-Sun:06:00"
      backup_window = "01:00-04:00"
      monitoring_interval = "30"
      family = "mysql5.7"
      major_engine_version = "5.7"
      deletion_protection = false
      parameters = [
        {
        name = "character_set_client"
        value = "utf8mb4"
        },
        {
          name = "character_set_server"
          value = "utf8mb4"
        }
      ]
      options = [
        {
          option_name = "MARIADB_AUDIT_PLUGIN"
          option_settings = [
            {
              name = "SERVER_AUDIT_EVENTS"
              value = "CONNECT"
            },
            {
              name = "SERVER_AUDIT_FILE_ROTATIONS"
              value = "37"
            }
          ]
        }
      ]
      tags = {}      
    }
}