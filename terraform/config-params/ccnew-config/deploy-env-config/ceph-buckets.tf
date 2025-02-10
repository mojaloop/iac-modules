
resource "kubernetes_manifest" "namespace" {
  for_each = local.environment_list

  manifest = {
    apiVersion = "v1"
    kind       = "Namespace"
    metadata = {
      name = each.key
    }
  }
}

resource "kubernetes_manifest" "objectbucketclaim_rook_ceph_ceph_bucket_loki" {
  for_each = local.environment_list
  manifest = {
    "apiVersion" = "objectbucket.io/v1alpha1"
    "kind"       = "ObjectBucketClaim"
    "metadata" = {
      "name"      = "${each.key}-loki-bucket"
      "namespace" = each.key
    }
    "spec" = {
      "additionalConfig" = {
        "maxObjects" = var.max_objects
        "maxSize"    = var.max_size
      }
      "bucketName"       = "${each.key}-loki"
      "storageClassName" = var.storage_class
    }
  }
}


resource "kubernetes_manifest" "objectbucketclaim_rook_ceph_ceph_bucket_tempo" {
  for_each = local.environment_list
  manifest = {
    "apiVersion" = "objectbucket.io/v1alpha1"
    "kind"       = "ObjectBucketClaim"
    "metadata" = {
      "name"      = "${each.key}-tempo-bucket"
      "namespace" = each.key
    }
    "spec" = {
      "additionalConfig" = {
        "maxObjects" = var.max_objects
        "maxSize"    = var.max_size
      }
      "bucketName"       = "${each.key}-tempo"
      "storageClassName" = var.storage_class
    }
  }
}


resource "kubernetes_manifest" "objectbucketclaim_rook_ceph_ceph_bucket_longhorn" {
  for_each = local.environment_list
  manifest = {
    "apiVersion" = "objectbucket.io/v1alpha1"
    "kind"       = "ObjectBucketClaim"
    "metadata" = {
      "name"      = "${each.key}-longhorn-backup-bucket"
      "namespace" = each.key
    }
    "spec" = {
      "additionalConfig" = {
        "maxObjects" = var.max_objects
        "maxSize"    = var.max_size
      }
      "bucketName"       = "${each.key}-longhorn-backup"
      "storageClassName" = var.storage_class
    }
  }
}

resource "kubernetes_manifest" "objectbucketclaim_rook_ceph_ceph_bucket_velero" {
  for_each = local.environment_list
  manifest = {
    "apiVersion" = "objectbucket.io/v1alpha1"
    "kind"       = "ObjectBucketClaim"
    "metadata" = {
      "name"      = "${each.key}-velero-bucket"
      "namespace" = each.key
    }
    "spec" = {
      "additionalConfig" = {
        "maxObjects" = var.max_objects
        "maxSize"    = var.max_size
      }
      "bucketName"       = "${each.key}-velero"
      "storageClassName" = var.storage_class
    }
  }
}


resource "kubernetes_manifest" "objectbucketclaim_rook_ceph_ceph_bucket_percona" {
  for_each = local.environment_list
  manifest = {
    "apiVersion" = "objectbucket.io/v1alpha1"
    "kind"       = "ObjectBucketClaim"
    "metadata" = {
      "name"      = "${each.key}-percona-bucket"
      "namespace" = each.key
    }
    "spec" = {
      "additionalConfig" = {
        "maxObjects" = var.max_objects
        "maxSize"    = var.max_size
      }
      "bucketName"       = "${each.key}-percona"
      "storageClassName" = var.storage_class
    }
  }
}